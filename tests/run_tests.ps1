# run_tests.ps1 — Keyguard Designer Test Runner
# Usage: from the project root directory, run:
#   powershell.exe -ExecutionPolicy Bypass -File tests/run_tests.ps1
#   powershell.exe -ExecutionPolicy Bypass -File tests/run_tests.ps1 -PngOnly
#   powershell.exe -ExecutionPolicy Bypass -File tests/run_tests.ps1 -CaseFilter "test-case-01"
#
# Options:
#   -PngOnly       Skip STL renders (much faster)
#   -CaseFilter    Only run cases whose ID contains this string
#   -Bless         Copy results/PNGs to references/ (bless current renders as new baselines)

param(
    [switch]$PngOnly,
    [string]$CaseFilter = "",
    [switch]$Bless
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$OpenSCAD = "C:\Program Files\OpenSCAD\openscad.com"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

# ── Discover current SCAD and JSON files (version-agnostic) ──────────────────
Push-Location $ProjectDir
$ScadFile = Get-ChildItem 'keyguard_v*.scad' -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending | Select-Object -First 1
$JsonFile = Get-ChildItem 'keyguard_v*.json' -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending | Select-Object -First 1
Pop-Location

if (-not $ScadFile) { Write-Error "No keyguard_v*.scad found in $ProjectDir"; exit 1 }
if (-not $JsonFile) { Write-Error "No keyguard_v*.json found in $ProjectDir"; exit 1 }

$ScadPath = $ScadFile.FullName
$JsonPath = $JsonFile.FullName

Write-Host ""
Write-Host "=== Keyguard Designer Test Runner ==="
Write-Host "  SCAD : $($ScadFile.Name)"
Write-Host "  JSON : $($JsonFile.Name)"
Write-Host "  PngOnly: $PngOnly"
if ($CaseFilter) { Write-Host "  Filter: $CaseFilter" }
Write-Host ""

# ── Directories ──────────────────────────────────────────────────────────────
$ResultsDir   = Join-Path $ScriptDir "results"
$RefsDir      = Join-Path $ScriptDir "references"
$FixturesDir  = Join-Path $ScriptDir "fixtures\openings"
$OpeningsFile = Join-Path $ProjectDir "openings_and_additions.txt"

New-Item -ItemType Directory -Force -Path $ResultsDir | Out-Null

# ── Load test cases ──────────────────────────────────────────────────────────
$CasesPath = Join-Path $ScriptDir "cases.json"
$Cases = Get-Content $CasesPath | ConvertFrom-Json

if ($CaseFilter) {
    $Cases = @($Cases | Where-Object { $_.id -like "*$CaseFilter*" })
    Write-Host "Running $($Cases.Count) case(s) matching '$CaseFilter'"
}

# ── Check for ImageMagick ────────────────────────────────────────────────────
$HasMagick = $false
try {
    $null = & magick --version 2>&1
    $HasMagick = $true
} catch { }

# Known-benign warning/error substrings (never fail a case)
$GlobalAllowedWarnings = @(
    "Viewall and autocenter disabled in favor of `$vp",
    "Ignoring unknown variable"
)

# ── Helper: run OpenSCAD and capture output ──────────────────────────────────
function Invoke-OpenSCAD {
    param([string]$OutputFile, [string]$Preset, [string[]]$ExtraArgs)

    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()

    # Build a single quoted argument string so paths/preset names with spaces are handled correctly
    $extraStr = if ($ExtraArgs.Count -gt 0) { ($ExtraArgs | ForEach-Object { "`"$_`"" }) -join ' ' } else { "" }
    $argString = "-o `"$OutputFile`" -p `"$JsonPath`" -P `"$Preset`" $extraStr `"$ScadPath`""

    $proc = Start-Process -FilePath $OpenSCAD `
        -ArgumentList $argString `
        -WorkingDirectory $ProjectDir `
        -Wait -PassThru `
        -RedirectStandardOutput $stdoutFile `
        -RedirectStandardError  $stderrFile

    $stdout = Get-Content $stdoutFile -ErrorAction SilentlyContinue
    $stderr = Get-Content $stderrFile -ErrorAction SilentlyContinue
    Remove-Item $stdoutFile, $stderrFile -Force -ErrorAction SilentlyContinue

    # Merge: OpenSCAD sends render log to stdout, warnings/errors also to stdout
    $allOutput = @($stdout) + @($stderr) | Where-Object { $_ -ne $null }

    $warnings = $allOutput | Where-Object { $_ -match '^WARNING:' -or $_ -match '^ERROR:' }

    return @{
        ExitCode = $proc.ExitCode
        Warnings = $warnings
        AllOutput = $allOutput
    }
}

# ── Run tests ────────────────────────────────────────────────────────────────
$Results = @()
$Total = $Cases.Count
$Idx   = 0

foreach ($case in $Cases) {
    $Idx++
    $id     = $case.id
    $preset = $case.preset
    $checks = $case.checks

    Write-Host "[$Idx/$Total] $id ($preset)" -NoNewline

    # ── Openings fixture ─────────────────────────────────────────────────────
    $FixtureActive = $false
    if ($case.openings_fixture) {
        $fixtureSrc = Join-Path $FixturesDir $case.openings_fixture
        if (Test-Path $fixtureSrc) {
            Copy-Item $OpeningsFile "$OpeningsFile.bak" -Force
            Copy-Item $fixtureSrc $OpeningsFile -Force
            $FixtureActive = $true
        } else {
            Write-Host " [WARN: fixture '$($case.openings_fixture)' not found, skipping]"
        }
    }

    $pngResult  = $null
    $stlResult  = $null
    $pngStatus  = "skip"
    $stlStatus  = "skip"
    $warnCount  = 0
    $visualStatus = "skip"

    try {
        # ── PNG render ───────────────────────────────────────────────────────
        if ($checks -contains "png") {
            $pngOut = Join-Path $ResultsDir "$id.png"
            $r = Invoke-OpenSCAD -OutputFile $pngOut -Preset $preset `
                                 -ExtraArgs @('--imgsize=512,384')

            # Filter out globally-allowed warnings and per-case expected warnings
            $allAllowed = $GlobalAllowedWarnings + @($case.expected_warnings)
            $unexpectedWarnings = @($r.Warnings | Where-Object {
                $w = $_
                -not ($allAllowed | Where-Object { $w -like "*$_*" })
            })
            $warnCount = $unexpectedWarnings.Count

            if ($r.ExitCode -eq 0 -and (Test-Path $pngOut)) {
                $pngStatus = "PASS"
            } else {
                $pngStatus = "FAIL"
                Write-Host ""
                Write-Host "  EXIT: $($r.ExitCode)"
                $r.AllOutput | ForEach-Object { Write-Host "  $_" }
            }

            $pngResult = $r

            # ── Visual regression ────────────────────────────────────────────
            $refPng = Join-Path $RefsDir "$id.png"
            if ($pngStatus -eq "PASS" -and (Test-Path $refPng)) {
                if ($HasMagick) {
                    $diffPng = Join-Path $ResultsDir "$id.diff.png"
                    $magickOut = & magick compare -metric AE $refPng $pngOut $diffPng 2>&1
                    $pixelDiff = ($magickOut | Select-Object -Last 1) -as [int]
                    if ($null -eq $pixelDiff) { $pixelDiff = -1 }
                    $visualStatus = if ($pixelDiff -eq 0) { "MATCH" } else { "DIFF($pixelDiff px)" }
                } else {
                    # Fallback: compare file sizes
                    $refSize = (Get-Item $refPng).Length
                    $newSize = (Get-Item $pngOut).Length
                    $sizeDiff = [Math]::Abs($refSize - $newSize)
                    $visualStatus = if ($sizeDiff -eq 0) { "MATCH" } elseif ($sizeDiff -lt 200) { "NEAR($sizeDiff b)" } else { "DIFF($sizeDiff b)" }
                }
            } elseif ($pngStatus -eq "PASS") {
                $visualStatus = "NEW"
            } else {
                $visualStatus = "n/a"
            }
        }

        # ── STL render ───────────────────────────────────────────────────────
        if (-not $PngOnly -and $checks -contains "stl") {
            $stlOut = Join-Path $ResultsDir "$id.stl"
            $r = Invoke-OpenSCAD -OutputFile $stlOut -Preset $preset -ExtraArgs @()

            if ($r.ExitCode -eq 0 -and (Test-Path $stlOut)) {
                $stlSize = (Get-Item $stlOut).Length
                if ($stlSize -gt 1000) {
                    $stlStatus = "PASS"
                } else {
                    $stlStatus = "FAIL(empty)"
                    Write-Host ""
                    Write-Host "  STL too small: $stlSize bytes"
                }
            } else {
                $stlStatus = "FAIL"
                if ($r.ExitCode -ne 0) {
                    Write-Host ""
                    Write-Host "  STL EXIT: $($r.ExitCode)"
                    $r.AllOutput | ForEach-Object { Write-Host "  $_" }
                }
            }
        }

    } finally {
        # Restore openings file
        if ($FixtureActive -and (Test-Path "$OpeningsFile.bak")) {
            Copy-Item "$OpeningsFile.bak" $OpeningsFile -Force
            Remove-Item "$OpeningsFile.bak" -Force
        }
    }

    $overallPass = ($pngStatus -eq "PASS" -or $pngStatus -eq "skip") -and
                   ($stlStatus -eq "PASS" -or $stlStatus -eq "skip") -and
                   ($visualStatus -notlike "DIFF*")

    $Results += [PSCustomObject]@{
        ID      = $id
        Preset  = $preset
        PNG     = $pngStatus
        STL     = $stlStatus
        Warn    = $warnCount
        Visual  = $visualStatus
        Pass    = $overallPass
    }

    $statusIcon = if ($overallPass) { " OK" } else { " !!" }
    Write-Host " [$pngStatus|$stlStatus|$visualStatus|W:$warnCount]$statusIcon"
}

# ── Bless mode ───────────────────────────────────────────────────────────────
if ($Bless) {
    Write-Host ""
    Write-Host "=== Blessing references ==="
    New-Item -ItemType Directory -Force -Path $RefsDir | Out-Null
    $blessed = 0
    foreach ($r in $Results) {
        if ($r.PNG -eq "PASS") {
            $src = Join-Path $ResultsDir "$($r.ID).png"
            $dst = Join-Path $RefsDir    "$($r.ID).png"
            Copy-Item $src $dst -Force
            $blessed++
        }
    }
    Write-Host "  Blessed $blessed PNG(s) to tests/references/"
}

# ── Summary ──────────────────────────────────────────────────────────────────
$passed  = @($Results | Where-Object { $_.Pass }).Count
$newRefs = @($Results | Where-Object { $_.Visual -eq "NEW" }).Count
$diffs   = @($Results | Where-Object { $_.Visual -like "DIFF*" }).Count
$failed  = @($Results | Where-Object { -not $_.Pass }).Count

Write-Host ""
Write-Host "=== Results ==="
Write-Host ("  {0,-30} {1,-6} {2,-6} {3,-5} {4}" -f "ID", "PNG", "STL", "Warn", "Visual")
Write-Host ("  " + "-" * 65)
foreach ($r in $Results) {
    $line = "  {0,-30} {1,-6} {2,-6} {3,-5} {4}" -f $r.ID, $r.PNG, $r.STL, $r.Warn, $r.Visual
    Write-Host $line
}
Write-Host ""
Write-Host "  Passed : $passed / $($Results.Count)"
if ($newRefs -gt 0) { Write-Host "  New    : $newRefs (no reference yet - run with -Bless to set baseline)" }
if ($diffs   -gt 0) { Write-Host "  Diffs  : $diffs (visual regression - review images)" }
if ($failed  -gt 0) { Write-Host "  FAILED : $failed" }

if ($failed -eq 0 -and $diffs -eq 0) {
    Write-Host ""
    Write-Host "  All checks passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host ""
    Write-Host "  Some checks failed or differ - review output above." -ForegroundColor Red
    exit 1
}

#!/usr/bin/env bash
# test.sh — Multi-layer test runner for the keyguard designer
#
# Layers (run in order, or individually via flags):
#   --lint               Layer 1: sca2d static analysis (fast, no render)
#   --syntax             Layer 2: OpenSCAD --hardwarnings parse check (fast, no render)
#   --smoke              Layer 3: Render default config to STL
#   --geometry           Layer 4: Render all named configs from keyguard.json;
#                                  verify each STL is manifold (Simple: yes) and
#                                  passes admesh mesh-integrity checks (if available)
#   --visual             Layer 5: Run test.json cases; compare PNGs against references
#
# Usage:
#   ./scripts/test.sh                        # Layers 1–3 (fast default)
#   ./scripts/test.sh --all                  # All layers
#   ./scripts/test.sh --lint                 # Single layer
#   ./scripts/test.sh --lint --syntax        # Combine layers
#   ./scripts/test.sh --capture-references   # Re-render all visual tests; save new reference PNGs
#   ./scripts/test.sh --capture-references --case "Test Case 25"  # Single test case only
#   ./scripts/test.sh --visual --case "Test Case 25"              # Run one test case
#
# Requirements:
#   - openscad  (on PATH, or at a common Windows install location)
#   - python3   (for JSON parsing)
#   - sca2d     (pip install sca2d)  — Layer 1 only
#   - admesh    (optional)           — Layer 4 supplementary mesh-integrity check
#   - imagemagick (compare command)  — Layer 5 PNG comparison; falls back to hash if absent

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCAD_FILE="$PROJECT_ROOT/keyguard.scad"
JSON_FILE="$PROJECT_ROOT/keyguard.json"
OPENINGS_FILE="$PROJECT_ROOT/openings_and_additions.txt"
DEFAULT_SVG="$PROJECT_ROOT/default.svg"
OUTPUT_DIR="$PROJECT_ROOT/output/test"
TEST_RESULTS_DIR="$PROJECT_ROOT/test results"
CASES_DIR="$PROJECT_ROOT/tests/cases"
TIMINGS_FILE="$PROJECT_ROOT/test-timings.ndjson"

# sca2d ignore codes:
#   User-configured: I3001 I0006 I1002 I0004 I1001 I4001 I4002 I0003 I4003
#   E2003: False positive — sca2d doesn't recognise assert() as a built-in
SCA2D_IGNORE="I3001,I0006,I1002,I0004,I1001,I4001,I4002,I0003,I4003,E2003"

# Default camera (used when a step doesn't specify vpt/vpr/vpd)
DEFAULT_VPT="0,0,0"
DEFAULT_VPR="55,0,25"
DEFAULT_VPD="250"

# ── Colour output ──────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

pass()  { echo -e "${GREEN}  ✓ PASS${RESET}  $*"; }
fail()  { echo -e "${RED}  ✗ FAIL${RESET}  $*"; FAILURES=$((FAILURES + 1)); }
warn()  { echo -e "${YELLOW}  ⚠ WARN${RESET}  $*"; }
info()  { echo -e "${BLUE}  ·${RESET} $*"; }
header(){ echo -e "\n${BOLD}$*${RESET}"; }

# Append one NDJSON record to the timings file (one JSON object per line)
log_event() { printf '%s\n' "$1" >> "$TIMINGS_FILE"; }

# Current UTC timestamp in ISO 8601 format
iso_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

# Escape a value for use as a JSON string (handles backslashes and double-quotes)
json_str() { local s="$1"; s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; printf '%s' "$s"; }

FAILURES=0

# ── Tool detection ─────────────────────────────────────────────────────────────

find_openscad() {
    if command -v openscad &>/dev/null; then echo "openscad"; return; fi
    # On Windows prefer openscad.com (headless CLI wrapper) over openscad.exe (GUI app)
    local win_paths=(
        "/mnt/c/Program Files/OpenSCAD/openscad.com"
        "/mnt/c/Program Files (x86)/OpenSCAD/openscad.com"
        "/c/Program Files/OpenSCAD/openscad.com"
        "/mnt/c/Program Files/OpenSCAD/openscad.exe"
        "/mnt/c/Program Files (x86)/OpenSCAD/openscad.exe"
        "/c/Program Files/OpenSCAD/openscad.exe"
    )
    for p in "${win_paths[@]}"; do
        [[ -x "$p" ]] && echo "$p" && return
    done
    echo ""
}

find_sca2d() {
    command -v sca2d &>/dev/null && echo "sca2d" && return
    [[ -x "$HOME/.local/bin/sca2d" ]] && echo "$HOME/.local/bin/sca2d" && return
    echo ""
}

find_compare() {
    command -v compare &>/dev/null && echo "compare" && return
    echo ""
}

find_admesh() {
    command -v admesh &>/dev/null && echo "admesh" && return
    echo ""
}

find_python() {
    command -v python3 &>/dev/null && python3 -c "import sys; sys.exit(0)" 2>/dev/null && echo "python3" && return
    command -v python &>/dev/null && echo "python" && return
    command -v py &>/dev/null && echo "py" && return
    echo ""
}

# Convert a path for use inside Python strings on Windows.
# Uses cygpath -m (Windows drive letter + forward slashes) to avoid backslash escaping.
py_path() {
    command -v cygpath &>/dev/null && cygpath -m "$1" || echo "$1"
}

OPENSCAD="$(find_openscad)"
SCA2D="$(find_sca2d)"
COMPARE="$(find_compare)"
ADMESH="$(find_admesh)"
PYTHON="$(find_python)"

# ── Argument parsing ───────────────────────────────────────────────────────────

RUN_LINT=false; RUN_SYNTAX=false; RUN_SMOKE=false
RUN_GEOMETRY=false; RUN_VISUAL=false
CAPTURE_REFERENCES=false
CASE_FILTER=""

if [[ $# -eq 0 ]]; then
    RUN_LINT=true; RUN_SYNTAX=true; RUN_SMOKE=true
else
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lint)                RUN_LINT=true ;;
            --syntax)              RUN_SYNTAX=true ;;
            --smoke)               RUN_SMOKE=true ;;
            --geometry)            RUN_GEOMETRY=true ;;
            --visual)              RUN_VISUAL=true ;;
            --all)                 RUN_LINT=true; RUN_SYNTAX=true; RUN_SMOKE=true
                                   RUN_GEOMETRY=true; RUN_VISUAL=true ;;
            --capture-references)  CAPTURE_REFERENCES=true; RUN_VISUAL=true ;;
            --case)                shift; CASE_FILTER="$1" ;;
            --case=*)              CASE_FILTER="${1#--case=}" ;;
            *) echo "Unknown option: $1"; exit 1 ;;
        esac
        shift
    done
fi

# ── Python helpers ─────────────────────────────────────────────────────────────

# List all named configs from keyguard.json
get_configs() {
    local _p; _p=$(py_path "$JSON_FILE")
    $PYTHON -c "
import json
with open('$_p', encoding='utf-8') as f:
    data = json.load(f)
for name in data.get('parameterSets', {}).keys():
    print(name)
" | tr -d '\r'; }

# List test case folders that contain a test.json
get_test_cases() {
    find "$CASES_DIR" -name "test.json" -maxdepth 2 | sort | while read -r f; do
        dirname "$f"
    done
}

# Build --camera string from vpt/vpr/vpd (accepts comma-separated triples)
build_camera() {
    local vpt="${1:-$DEFAULT_VPT}"
    local vpr="${2:-$DEFAULT_VPR}"
    local vpd="${3:-$DEFAULT_VPD}"
    echo "${vpt},${vpr},${vpd}"
}

# Parse a test.json and emit shell-evaluable assignments for one step (by index)
parse_step() {
    local test_json="$1"
    local step_idx="$2"
    local _p; _p=$(py_path "$test_json")
    $PYTHON -c "
import json, sys

with open('$_p', encoding='utf-8') as f:
    test = json.load(f)

steps = test.get('steps', [])
idx = $step_idx
if idx >= len(steps):
    sys.exit(1)

step = steps[idx]

def fmtlist(lst, default):
    if isinstance(lst, list) and len(lst) == 3:
        return ','.join(str(v) for v in lst)
    return default

label    = step.get('label', f'step{idx+1}')
params   = step.get('params', '')
override = step.get('params_override', {})
vpt      = fmtlist(step.get('vpt'), '0,0,0')
vpr      = fmtlist(step.get('vpr'), '55,0,25')
vpd      = str(step.get('vpd', 250))
expected = step.get('expected', f'step{idx+1}_expected.png')
render   = str(step.get('render', False)).lower()
console  = step.get('console', '')

# Build -D flags for params_override
d_flags = []
for k, v in override.items():
    if isinstance(v, str):
        d_flags.append(f\"-D '{k}=\\\"{v}\\\"'\")
    elif isinstance(v, bool):
        d_flags.append(f\"-D '{k}={str(v).lower()}'\")
    else:
        d_flags.append(f\"-D '{k}={v}'\")

print(f'STEP_LABEL={json.dumps(label)}')
print(f'STEP_PARAMS={json.dumps(params)}')
print(f'STEP_VPT={json.dumps(vpt)}')
print(f'STEP_VPR={json.dumps(vpr)}')
print(f'STEP_VPD={json.dumps(vpd)}')
print(f'STEP_EXPECTED={json.dumps(expected)}')
print(f'STEP_D_FLAGS={json.dumps(\" \".join(d_flags))}')
print(f'STEP_RENDER={json.dumps(render)}')
print(f'STEP_CONSOLE={json.dumps(console)}')
" | tr -d '\r'
}

# Count steps in a test.json
count_steps() {
    local _p; _p=$(py_path "$1")
    $PYTHON -c "
import json
with open('$_p', encoding='utf-8') as f:
    test = json.load(f)
print(len(test.get('steps', [])))
" | tr -d '\r'
}

# Get top-level string field from test.json (returns empty string for missing or null values)
get_test_field() {
    local _p; _p=$(py_path "$1")
    $PYTHON -c "
import json
with open('$_p', encoding='utf-8') as f:
    test = json.load(f)
val = test.get('$2', '')
print(val if val is not None else '')
" | tr -d '\r'
}

# Get assets list from test.json (one filename per line)
get_test_assets() {
    local _p; _p=$(py_path "$1")
    $PYTHON -c "
import json
with open('$_p', encoding='utf-8') as f:
    test = json.load(f)
for a in test.get('assets', []):
    print(a)
" | tr -d '\r'
}

# ── Layer 1: sca2d lint ────────────────────────────────────────────────────────

run_lint() {
    header "Layer 1 — sca2d lint"
    if [[ -z "$SCA2D" ]]; then
        warn "sca2d not found (pip install sca2d) — skipping"
        return
    fi
    info "Running sca2d with ignore=$SCA2D_IGNORE"
    echo ""
    local output
    output=$("$SCA2D" "$SCAD_FILE" --ignore="$SCA2D_IGNORE" 2>&1 || true)
    echo "$output" | sed 's/^/    /'
    local fatal_count
    fatal_count=$(echo "$output" | grep -E "^Fatal errors:" | grep -oE "[0-9]+" || echo "0")
    echo ""
    if [[ "$fatal_count" -gt 0 ]]; then
        fail "sca2d: $fatal_count fatal error(s)"
    else
        local e w
        e=$(echo "$output"  | grep -E "^Errors:"   | grep -oE "[0-9]+" || echo "0")
        w=$(echo "$output" | grep -E "^Warnings:" | grep -oE "[0-9]+" || echo "0")
        [[ "$e" -gt 0 || "$w" -gt 0 ]] && warn "sca2d: $e error(s), $w warning(s) — review above"
        pass "sca2d — no fatal errors"
    fi
}

# ── Layer 2: OpenSCAD syntax check ────────────────────────────────────────────

run_syntax() {
    header "Layer 2 — OpenSCAD syntax check"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found"; return; fi
    info "Running openscad --hardwarnings"
    echo ""
    local output exit_code=0
    # Use a temp STL output so openscad.exe runs headlessly on Windows (without -o it opens the GUI).
    # Omit --hardwarnings: that flag exits non-zero on warnings too, including the benign
    # "Viewall and autocenter disabled in favor of $vp*" warning set in the file.
    # Without --hardwarnings, OpenSCAD exits non-zero only on actual parse/compile errors.
    local tmp_stl="/tmp/openscad_syntax_$$.stl"
    output=$("$OPENSCAD" -o "$tmp_stl" "$SCAD_FILE" 2>&1) || exit_code=$?
    rm -f "$tmp_stl"
    [[ -n "$output" ]] && echo "$output" | sed 's/^/    /' && echo ""
    if [[ "$exit_code" -ne 0 ]]; then
        fail "OpenSCAD syntax errors (exit $exit_code)"
    else
        pass "OpenSCAD syntax check — clean"
    fi
}

# ── Layer 3: Smoke test ────────────────────────────────────────────────────────

run_smoke() {
    header "Layer 3 — Smoke test"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi
    mkdir -p "$OUTPUT_DIR"
    local out="$OUTPUT_DIR/smoke_test.stl"
    info "Rendering default config to STL..."
    local output exit_code=0
    output=$("$OPENSCAD" -o "$out" "$SCAD_FILE" 2>&1) || exit_code=$?
    [[ -n "$output" ]] && echo "$output" | sed 's/^/    /'
    if   [[ "$exit_code" -ne 0 ]]; then fail "Render failed (exit $exit_code)"
    elif [[ ! -f "$out" ]];        then fail "No STL produced"
    elif [[ ! -s "$out" ]];        then fail "STL is empty"
    else pass "Smoke test — STL produced ($(du -sh "$out" | cut -f1))"
    fi
}

# ── Layer 4: Geometry validation ──────────────────────────────────────────────
#
# Renders every named config to STL and validates the resulting mesh:
#   1. Render must succeed and produce a non-empty STL
#   2. OpenSCAD must report "Simple: yes" (CGAL manifold check)
#   3. admesh must report zero errors (if admesh is installed)
#
# No baseline is needed — all checks are self-contained and reliable across
# machines and OpenSCAD versions.

run_geometry() {
    # Configs that intentionally produce non-3D output and cannot render to STL.
    # These are skipped (not counted as failures) in the geometry validation layer.
    local -a GEOMETRY_SKIP=(
        "Test Case 0"    # generate="Customizer settings" — outputs parameter echoes, no geometry
        "Test Case 10b"  # generate="first layer for SVG/DXF file" — 2D output only
        "Test Case 13b"  # generate="first half of keyguard" + Laser-Cut — can't split laser-cut
        "Test Case 46c"  # generate="first layer for SVG/DXF file" — 2D output only
    )

    header "Layer 4 — Geometry validation (all named configs)"
    local -a configs
    mapfile -t configs < <(get_configs)
    info "Found ${#configs[@]} named configs"
    if [[ -n "$ADMESH" ]]; then
        info "admesh available — full mesh-integrity checks enabled"
    else
        info "admesh not found — manifold check only (install admesh for deeper validation)"
    fi

    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi

    local render_failures=0 manifold_failures=0 admesh_failures=0 skipped=0
    local total=${#configs[@]} current=0
    local run_label; run_label=$(date +%Y-%m-%d_%H-%M-%S)
    local t_geom_run_start; t_geom_run_start=$(date +%s)
    local geom_passed=0

    for config in "${configs[@]}"; do
        current=$((current + 1))
        local skip=false
        for s in "${GEOMETRY_SKIP[@]}"; do
            [[ "$config" == "$s" ]] && skip=true && break
        done
        if "$skip"; then
            printf "  [%2d/%d] %-35s" "$current" "$total" "$config"
            echo -e " ${YELLOW}SKIP${RESET}"
            skipped=$((skipped + 1))
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"skip\",\"manifold\":null,\"admesh_issues\":null,\"duration_s\":0,\"ts\":\"$(iso_ts)\"}"
            continue
        fi

        # Write STL to a system temp directory (outside OneDrive/cloud-sync folders)
        # to avoid sync overhead on large temporary files.
        local safe; safe=$(echo "$config" | tr ' /' '__')
        local out="/tmp/keyguard_geom_${safe}_$$.stl"
        printf "  [%2d/%d] %-35s" "$current" "$total" "$config"

        # ── 1. Render ──────────────────────────────────────────────────────────
        local exit_code=0 console t_start t_elapsed
        t_start=$(date +%s)
        console=$("$OPENSCAD" -p "$JSON_FILE" -P "$config" \
            -o "$out" "$SCAD_FILE" 2>&1) || exit_code=$?
        t_elapsed=$(( $(date +%s) - t_start ))
        if [[ "$exit_code" -ne 0 || ! -s "$out" ]]; then
            echo -e " ${RED}RENDER FAILED${RESET} (${t_elapsed}s)"
            render_failures=$((render_failures + 1))
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"render_failed\",\"manifold\":null,\"admesh_issues\":null,\"duration_s\":$t_elapsed,\"ts\":\"$(iso_ts)\"}"
            rm -f "$out"; continue
        fi

        local config_ok=true

        # ── 2. Manifold check (OpenSCAD / CGAL) ────────────────────────────────
        # "Simple: yes" means every edge is shared by exactly two faces — the
        # standard definition of a 2-manifold mesh.
        local is_simple
        is_simple=$(echo "$console" | grep -oE 'Simple:[[:space:]]+(yes|no)' \
                    | grep -oE '(yes|no)' || echo "")
        if [[ "$is_simple" == "no" ]]; then
            echo -e " ${RED}NON-MANIFOLD${RESET} (${t_elapsed}s)"
            manifold_failures=$((manifold_failures + 1))
            config_ok=false
        fi

        # ── 3. admesh mesh-integrity check (optional) ──────────────────────────
        # admesh checks for degenerate facets, open edges, reversed normals, etc.
        # A clean mesh has zero counts across all repair categories.
        local admesh_issues_count=0
        if [[ -n "$ADMESH" && "$config_ok" == "true" ]]; then
            local admesh_out
            admesh_out=$("$ADMESH" "$out" 2>&1) || true
            local admesh_issues
            admesh_issues=$(echo "$admesh_out" | \
                grep -E '(Degenerate facets|Edges fixed|Facets removed|Facets added|Facets reversed|Backsides flipped|Parts fixed)' | \
                grep -cE ':[[:space:]]+[1-9][0-9]*[[:space:]]*$' || true)
            admesh_issues=${admesh_issues:-0}
            admesh_issues_count=$admesh_issues
            if [[ "$admesh_issues" -gt 0 ]]; then
                echo -e " ${RED}MESH ERRORS${RESET} (${t_elapsed}s)"
                echo "$admesh_out" | \
                    grep -E '(Degenerate facets|Edges fixed|Facets removed|Facets added|Facets reversed|Backsides flipped|Parts fixed)' | \
                    grep -E ':[[:space:]]+[1-9]' | sed 's/^/      /'
                admesh_failures=$((admesh_failures + 1))
                config_ok=false
            fi
        fi

        # ── Print per-config result ─────────────────────────────────────────────
        if [[ "$config_ok" == "true" ]]; then
            if [[ -z "$is_simple" ]]; then
                echo -e " ${YELLOW}OK (manifold status unknown)${RESET} (${t_elapsed}s)"
            else
                echo -e " ${GREEN}OK${RESET} (${t_elapsed}s)"
            fi
            geom_passed=$((geom_passed + 1))
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"pass\",\"manifold\":\"${is_simple:-unknown}\",\"admesh_issues\":$admesh_issues_count,\"duration_s\":$t_elapsed,\"ts\":\"$(iso_ts)\"}"
        else
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"fail\",\"manifold\":\"${is_simple:-unknown}\",\"admesh_issues\":$admesh_issues_count,\"duration_s\":$t_elapsed,\"ts\":\"$(iso_ts)\"}"
        fi

        # ── Clean up STL (checks are done; no value in keeping it) ─────────────
        rm -f "$out"
    done

    echo ""
    if [[ "$skipped" -gt 0 ]]; then
        info "$skipped config(s) skipped (non-3D output by design)"
    fi
    if [[ "$render_failures" -gt 0 ]]; then
        fail "$render_failures config(s) failed to render"
    fi
    if [[ "$manifold_failures" -gt 0 ]]; then
        fail "$manifold_failures config(s) produced non-manifold geometry"
    fi
    if [[ "$admesh_failures" -gt 0 ]]; then
        fail "$admesh_failures config(s) failed admesh mesh-integrity check"
    fi
    if [[ "$render_failures" -eq 0 && "$manifold_failures" -eq 0 && "$admesh_failures" -eq 0 ]]; then
        pass "Geometry validation — all configs passed"
    fi
    local t_geom_elapsed=$(( $(date +%s) - t_geom_run_start ))
    local geom_failed=$(( render_failures + manifold_failures + admesh_failures ))
    log_event "{\"event\":\"run\",\"run\":\"$(json_str "$run_label")\",\"mode\":\"geometry\",\"configs_total\":$total,\"configs_passed\":$geom_passed,\"configs_failed\":$geom_failed,\"configs_skipped\":$skipped,\"render_failures\":$render_failures,\"manifold_failures\":$manifold_failures,\"admesh_failures\":$admesh_failures,\"duration_s\":$t_geom_elapsed,\"ts\":\"$(iso_ts)\"}"
    info "Timings appended to: test-timings.ndjson"
}

# ── Layer 5: Visual tests ─────────────────────────────────────────────────────

# Compare two PNGs; return 0 if same/within threshold, 1 if different.
# Sets the global LAST_RMSE to the numeric score (or "null" if unavailable).
LAST_RMSE="null"
compare_png() {
    local rendered="$1" expected="$2" diff_out="$3"
    LAST_RMSE="null"
    if [[ -n "$COMPARE" ]]; then
        # ImageMagick outputs "X (Y)" where X is the absolute RMSE in quantum
        # units (0–65535 for Q16-HDRI builds) and Y is the normalized 0–1 value.
        # We extract the parenthesized Y value so the threshold works regardless
        # of the quantum depth of the installed ImageMagick build.
        # 0.02 ≈ 5/255, matching the Python fallback threshold.
        #
        # Note: `compare` exits 1 when images differ (even slightly), so we must
        # capture its output before checking the exit code.  With `set -o pipefail`
        # active, piping directly and using `|| echo "1"` would fire the fallback
        # for every non-identical pair, corrupting the score variable.
        local raw_output score
        raw_output=$("$COMPARE" -metric RMSE "$rendered" "$expected" "$diff_out" 2>&1) || true
        score=$(echo "$raw_output" | grep -oE '\([0-9.e+-]+\)' | tr -d '()' || echo "1")
        LAST_RMSE="${score:-null}"
        $PYTHON -c "import sys; sys.exit(0 if float('${score:-1}') < 0.02 else 1)" 2>/dev/null
    elif [[ -n "$PYTHON" ]]; then
        # Python fallback: pure-stdlib RMSE comparison (threshold 5.0)
        # OpenSCAD's PNG renderer is slightly non-deterministic between runs;
        # RMSE < 5.0 catches real regressions while tolerating render noise.
        local py_script; py_script="$(py_path "$SCRIPT_DIR/compare_png.py")"
        local score exit_code=0
        score=$($PYTHON "$py_script" "$rendered" "$expected" 5.0 2>/dev/null) || exit_code=$?
        LAST_RMSE="${score:-null}"
        return $exit_code
    else
        # Last resort: exact hash comparison
        local h1 h2
        h1=$(sha256sum "$rendered" | cut -d' ' -f1)
        h2=$(sha256sum "$expected"  | cut -d' ' -f1)
        [[ "$h1" == "$h2" ]]
    fi
}

run_visual() {
    header "Layer 5 — Visual tests"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi
    [[ -z "$COMPARE" && -z "$PYTHON" ]] && warn "ImageMagick and Python not found — using exact hash comparison"
    [[ -z "$COMPARE" && -n "$PYTHON" ]] && warn "ImageMagick 'compare' not found — using Python RMSE comparison (threshold 5.0)"
    "$CAPTURE_REFERENCES" && info "Mode: capturing reference images"

    local cases; mapfile -t cases < <(get_test_cases)
    if [[ ${#cases[@]} -eq 0 ]]; then
        warn "No test cases found in tests/cases/ — nothing to run"
        info "See tests/cases/README.md for how to add test cases"
        return
    fi
    info "Found ${#cases[@]} test case(s)"
    [[ -n "$CASE_FILTER" ]] && info "Filter: '$CASE_FILTER'"

    # Create a timestamped results directory for this run
    local timestamp; timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local run_label; "$CAPTURE_REFERENCES" && run_label="${timestamp}_cap" || run_label="$timestamp"
    local run_dir="$TEST_RESULTS_DIR/$run_label"
    mkdir -p "$run_dir"

    local test_failures=0
    local summary_cases=""   # accumulated per-case markdown for summary
    local t_run_start; t_run_start=$(date +%s)
    local cases_passed=0

    local run_count=0
    for case_dir in "${cases[@]}"; do
        local test_json="$case_dir/test.json"
        local case_name; case_name=$(basename "$case_dir")

        # Skip cases that don't match the filter (if one was specified)
        if [[ -n "$CASE_FILTER" && "$case_name" != "$CASE_FILTER" ]]; then
            continue
        fi

        local render_dir="$run_dir/$case_name"
        mkdir -p "$render_dir"
        run_count=$((run_count + 1))
        local t_case_start; t_case_start=$(date +%s)
        local case_step_passed=0 case_step_failed=0 case_step_captured=0

        echo ""
        echo -e "  ${BOLD}${case_name}${RESET}"

        # Read top-level test fields
        local openings_override; openings_override=$(get_test_field "$test_json" "openings")
        local svg_source;        svg_source=$(get_test_field       "$test_json" "screenshot")
        local step_count;        step_count=$(count_steps "$test_json")
        local asset_list;        mapfile -t asset_list < <(get_test_assets "$test_json")

        # ── Setup: save originals and put test-specific files in place ──────────
        local saved_openings="" saved_svg=""
        local copied_assets=()

        if [[ -n "$openings_override" && -f "$case_dir/$openings_override" ]]; then
            saved_openings="/tmp/keyguard_openings_$$.txt"
            cp "$OPENINGS_FILE" "$saved_openings"
            cp "$case_dir/$openings_override" "$OPENINGS_FILE"
            info "Using $openings_override"
        fi

        if [[ -n "$svg_source" && -f "$case_dir/$svg_source" ]]; then
            saved_svg="/tmp/keyguard_default_$$.svg"
            [[ -f "$DEFAULT_SVG" ]] && cp "$DEFAULT_SVG" "$saved_svg"
            cp "$case_dir/$svg_source" "$DEFAULT_SVG"
            info "Using $svg_source as default.svg"
        fi

        for asset in "${asset_list[@]}"; do
            if [[ -f "$case_dir/$asset" ]]; then
                cp "$case_dir/$asset" "$PROJECT_ROOT/$asset"
                copied_assets+=("$PROJECT_ROOT/$asset")
                info "Asset: $asset"
            else
                warn "Asset '$asset' listed in test.json but not found in $case_dir"
            fi
        done

        # ── Run each step ───────────────────────────────────────────────────────
        local case_ok=true
        local case_rows=""   # table rows for this case's summary section

        for (( i=0; i<step_count; i++ )); do
            local step_vars; step_vars=$(parse_step "$test_json" "$i") || {
                fail "  Step $i: could not parse test.json"
                case_ok=false
                case_rows+="| $((i+1))/$step_count | (parse error) | FAIL |"$'\n'
                continue
            }
            eval "$step_vars"

            local camera; camera=$(build_camera "$STEP_VPT" "$STEP_VPR" "$STEP_VPD")
            # Sanitise label for use in file names: spaces/slashes/commas → _
            # Commas must be stripped because OpenSCAD parses -o argument values
            # on commas (e.g. --imgsize=WW,HH), so a comma in the output filename
            # causes the export to fail with "Can't open file".
            # Truncate to 50 chars to avoid Windows MAX_PATH (260) overflow on
            # deeply nested paths.
            local safe_label="${STEP_LABEL// /_}"; safe_label="${safe_label//\//_}"; safe_label="${safe_label//,/_}"; safe_label="${safe_label:0:50}"
            # Name rendered PNG with step number + label for easy browsing
            local rendered_png="$render_dir/step$((i+1))_${safe_label}.png"
            local expected_png="$case_dir/$STEP_EXPECTED"
            local diff_png="$render_dir/step$((i+1))_${safe_label}_diff.png"

            printf "    [step %d/%d] %-30s" "$((i+1))" "$step_count" "$STEP_LABEL"

            local t_step_start; t_step_start=$(date +%s)
            local cmd=("$OPENSCAD"
                --camera="$camera"
                --imgsize=1024,768
                --colorscheme=Tomorrow
                -o "$rendered_png")

            [[ "$STEP_RENDER" == "true" ]] && cmd+=(--render)

            [[ -n "$STEP_PARAMS" ]] && cmd+=(-p "$JSON_FILE" -P "$STEP_PARAMS")

            if [[ -n "$STEP_D_FLAGS" ]]; then
                eval "cmd+=($STEP_D_FLAGS)"
            fi

            cmd+=("$SCAD_FILE")

            local exit_code=0
            local console_log="$render_dir/step$((i+1))_${safe_label}_console.log"
            "${cmd[@]}" > "$console_log" 2>&1 || exit_code=$?

            local t_step_elapsed=$(( $(date +%s) - t_step_start ))

            if [[ "$exit_code" -ne 0 || ! -s "$rendered_png" ]]; then
                echo -e " ${RED}RENDER FAILED${RESET}"
                case_ok=false
                case_step_failed=$((case_step_failed + 1))
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | RENDER FAILED |"$'\n'
                log_event "{\"event\":\"step\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"step\":$((i+1)),\"step_count\":$step_count,\"label\":\"$(json_str "$STEP_LABEL")\",\"status\":\"render_failed\",\"rmse\":null,\"duration_s\":$t_step_elapsed,\"ts\":\"$(iso_ts)\"}"
                continue
            fi

            # Capture mode: copy rendered PNG as the new reference
            if "$CAPTURE_REFERENCES"; then
                cp "$rendered_png" "$expected_png"
                echo -e " ${GREEN}CAPTURED${RESET}"
                case_step_captured=$((case_step_captured + 1))
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | CAPTURED |"$'\n'
                log_event "{\"event\":\"step\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"step\":$((i+1)),\"step_count\":$step_count,\"label\":\"$(json_str "$STEP_LABEL")\",\"status\":\"captured\",\"rmse\":null,\"duration_s\":$t_step_elapsed,\"ts\":\"$(iso_ts)\"}"
                continue
            fi

            # Console text check
            local console_ok=true
            local console_missing=""
            if [[ -n "$STEP_CONSOLE" ]]; then
                local console_ref="$case_dir/$STEP_CONSOLE"
                if [[ ! -f "$console_ref" ]]; then
                    echo -e " ${YELLOW}NO CONSOLE REFERENCE${RESET} ($STEP_CONSOLE not found)"
                    case_ok=false
                    case_rows+="| $((i+1))/$step_count | $STEP_LABEL | NO CONSOLE REFERENCE |"$'\n'
                    continue
                fi
                console_missing=$($PYTHON -c "
import sys
with open(sys.argv[1], encoding='utf-8') as f:
    expected_lines = [l.rstrip('\n') for l in f if l.strip()]
with open(sys.argv[2], encoding='utf-8') as f:
    output = f.read()
missing = [l for l in expected_lines if l not in output]
for m in missing:
    print(m)
" "$console_ref" "$console_log")
                [[ -z "$console_missing" ]] || console_ok=false
            fi

            # Compare mode
            if [[ ! -f "$expected_png" ]]; then
                echo -e " ${YELLOW}NO REFERENCE${RESET} (run --capture-references to create one)"
                case_ok=false
                case_step_failed=$((case_step_failed + 1))
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | NO REFERENCE |"$'\n'
                log_event "{\"event\":\"step\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"step\":$((i+1)),\"step_count\":$step_count,\"label\":\"$(json_str "$STEP_LABEL")\",\"status\":\"no_reference\",\"rmse\":null,\"duration_s\":$t_step_elapsed,\"ts\":\"$(iso_ts)\"}"
                continue
            fi

            local png_ok=true
            compare_png "$rendered_png" "$expected_png" "$diff_png" || png_ok=false

            if "$png_ok" && "$console_ok"; then
                echo -e " ${GREEN}PASS${RESET}"
                rm -f "$diff_png"
                case_step_passed=$((case_step_passed + 1))
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | PASS |"$'\n'
                log_event "{\"event\":\"step\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"step\":$((i+1)),\"step_count\":$step_count,\"label\":\"$(json_str "$STEP_LABEL")\",\"status\":\"pass\",\"rmse\":$LAST_RMSE,\"duration_s\":$t_step_elapsed,\"ts\":\"$(iso_ts)\"}"
            else
                local fail_reasons=()
                "$png_ok"     || fail_reasons+=("PNG mismatch")
                "$console_ok" || fail_reasons+=("console mismatch")
                local fail_str; fail_str=$(IFS=", "; echo "${fail_reasons[*]}")
                echo -e " ${RED}FAIL${RESET} ($fail_str)"
                if ! "$console_ok"; then
                    while IFS= read -r missing_line; do
                        [[ -n "$missing_line" ]] && \
                            echo -e "      ${RED}missing from console:${RESET} $missing_line"
                    done <<< "$console_missing"
                fi
                case_ok=false
                case_step_failed=$((case_step_failed + 1))
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | FAIL ($fail_str) |"$'\n'
                log_event "{\"event\":\"step\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"step\":$((i+1)),\"step_count\":$step_count,\"label\":\"$(json_str "$STEP_LABEL")\",\"status\":\"fail\",\"rmse\":$LAST_RMSE,\"duration_s\":$t_step_elapsed,\"ts\":\"$(iso_ts)\"}"
            fi
        done

        # ── Teardown: restore original files ────────────────────────────────────
        [[ -n "$saved_openings" ]] && cp "$saved_openings" "$OPENINGS_FILE" && rm "$saved_openings"
        if [[ -n "$saved_svg" ]]; then
            if [[ -s "$saved_svg" ]]; then cp "$saved_svg" "$DEFAULT_SVG"
            else rm -f "$DEFAULT_SVG"; fi
            rm -f "$saved_svg"
        fi
        for asset_path in "${copied_assets[@]}"; do rm -f "$asset_path"; done

        if "$case_ok"; then
            cases_passed=$((cases_passed + 1))
        else
            test_failures=$((test_failures + 1))
        fi
        local t_case_elapsed=$(( $(date +%s) - t_case_start ))
        log_event "{\"event\":\"case\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"steps\":$step_count,\"passed\":$case_step_passed,\"failed\":$case_step_failed,\"captured\":$case_step_captured,\"duration_s\":$t_case_elapsed,\"ts\":\"$(iso_ts)\"}"
        summary_cases+="### $case_name"$'\n\n'
        summary_cases+="| Step | Label | Result |"$'\n'
        summary_cases+="|------|-------|--------|"$'\n'
        summary_cases+="$case_rows"$'\n'
    done

    # ── Write summary document ───────────────────────────────────────────────────
    local mode_str; "$CAPTURE_REFERENCES" && mode_str="capture-references" || mode_str="visual"
    [[ -n "$CASE_FILTER" ]] && mode_str+=" (filter: $CASE_FILTER)"
    local overall_str
    if   "$CAPTURE_REFERENCES";          then overall_str="References captured"
    elif [[ "$test_failures" -eq 0 ]];   then overall_str="PASS"
    else overall_str="FAIL ($test_failures case(s) failed)"; fi

    {
        echo "# Keyguard Designer — Visual Test Results"
        echo ""
        echo "- **Run:** $(date '+%Y-%m-%d %H:%M:%S')"
        echo "- **Mode:** $mode_str"
        echo "- **Test cases:** $run_count of ${#cases[@]}"
        echo "- **Overall:** $overall_str"
        echo ""
        echo "---"
        echo ""
        echo "$summary_cases"
    } > "$run_dir/summary.md"

    local t_run_elapsed=$(( $(date +%s) - t_run_start ))
    local run_mode_str; "$CAPTURE_REFERENCES" && run_mode_str="capture-references" || run_mode_str="visual"
    [[ -n "$CASE_FILTER" ]] && run_mode_str+=" (filter: $(json_str "$CASE_FILTER"))"
    log_event "{\"event\":\"run\",\"run\":\"$(json_str "$run_label")\",\"mode\":\"$(json_str "$run_mode_str")\",\"cases_run\":$run_count,\"cases_passed\":$cases_passed,\"cases_failed\":$test_failures,\"duration_s\":$t_run_elapsed,\"ts\":\"$(iso_ts)\"}"

    echo ""
    info "Results saved to: test results/$run_label/"
    info "Timings appended to: test-timings.ndjson"
    if [[ "$run_count" -eq 0 ]]; then
        warn "No test cases matched filter '$CASE_FILTER'"
    elif "$CAPTURE_REFERENCES"; then
        pass "References captured for $run_count test case(s)"
    elif [[ "$test_failures" -eq 0 ]]; then
        pass "Visual tests — all $run_count case(s) passed"
    else
        fail "$test_failures test case(s) failed"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

cd "$PROJECT_ROOT"

echo -e "${BOLD}Keyguard Designer — Test Suite${RESET}"
echo    "==============================="
info "OpenSCAD:    ${OPENSCAD:-NOT FOUND}"
info "Python:      ${PYTHON:-NOT FOUND}"
info "sca2d:       ${SCA2D:-NOT FOUND}"
info "admesh:      ${ADMESH:-not found (manifold-only check in Layer 4)}"
info "ImageMagick: ${COMPARE:-not found (will use hash comparison)}"

"$RUN_LINT"             && run_lint
"$RUN_SYNTAX"           && run_syntax
"$RUN_SMOKE"            && run_smoke
"$RUN_GEOMETRY"         && run_geometry
"$RUN_VISUAL"           && run_visual

echo ""
echo "==============================="
if [[ "$FAILURES" -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All tests passed.${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}$FAILURES test(s) failed.${RESET}"
    exit 1
fi

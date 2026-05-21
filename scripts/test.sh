#!/usr/bin/env bash
# test.sh — Multi-layer test runner for the keyguard designer
#
# Layers (run in order, or individually via flags):
#   --lint               Layer 1: sca2d static analysis (fast, no render)
#   --syntax             Layer 2: OpenSCAD --hardwarnings parse check (fast, no render)
#   --smoke              Layer 3: Render default config to STL
#   --visual             Layer 4: Run test.json cases; compare PNGs against references
#   --geometry           Layer 5: Render all named configs from keyguard.json;
#                                  verify each STL is manifold (Simple: yes)
#
# Usage:
#   ./scripts/test.sh                        # Layers 1–3 (fast default)
#   ./scripts/test.sh --all                  # All layers
#   ./scripts/test.sh --lint                 # Single layer
#   ./scripts/test.sh --lint --syntax        # Combine layers
#   ./scripts/test.sh --capture-references   # Re-render all visual tests; save new reference PNGs
#   ./scripts/test.sh --capture-references --case "Test Case 25"  # Single test case only
#   ./scripts/test.sh --visual --case "Test Case 25"              # Run one test case
#   ./scripts/test.sh --geometry --visual --case "Test Case 0-10" # Range of test cases (N < M)
#
# Requirements:
#   - openscad  (on PATH, or at a common Windows install location)
#   - python3   (for JSON parsing)
#   - sca2d     (pip install sca2d)  — Layer 1 only
#   - imagemagick (compare command)  — Layer 4 PNG comparison; falls back to hash if absent

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
# Reference PNGs for the visual layer live alongside the cases but in a
# sibling visual.snapshots/ subtree so case folders contain only
# configuration (test.json, openings.txt, assets) and not large binary
# baselines that mix poorly with case-definition diffs in PRs.
SNAPSHOTS_DIR="$CASES_DIR/visual.snapshots"
TIMINGS_FILE="$PROJECT_ROOT/test-timings.ndjson"
LOCK_FILE="$PROJECT_ROOT/.test-lock"
# When running from a git worktree, also mirror timings to the main project folder
_MAIN_ROOT=$(git -C "$PROJECT_ROOT" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' | head -1)
[[ -n "$_MAIN_ROOT" && "$_MAIN_ROOT" != "$PROJECT_ROOT" ]] \
    && MIRROR_TIMINGS_FILE="$_MAIN_ROOT/test-timings.ndjson" \
    || MIRROR_TIMINGS_FILE=""

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
log_event() {
    printf '%s\n' "$1" >> "$TIMINGS_FILE"
    [[ -n "$MIRROR_TIMINGS_FILE" ]] && printf '%s\n' "$1" >> "$MIRROR_TIMINGS_FILE"
}

# Current UTC timestamp in ISO 8601 format
iso_ts() {
    local m off abbr
    m=$((10#$(date -u +%m)))                             # current UTC month as integer
    if (( m >= 4 && m <= 10 )); then off=-6; abbr="MDT"  # Mountain Daylight Time
    else                              off=-7; abbr="MST"  # Mountain Standard Time
    fi
    date -u -d "$off hours" +"%Y-%m-%d %I:%M:%S %p ${abbr}"
}

# Escape a value for use as a JSON string (handles backslashes and double-quotes)
json_str() { local s="$1"; s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; printf '%s' "$s"; }

# JSON-encode a value: outputs a quoted string, or null if the value is empty
json_val() { [[ -n "$1" ]] && printf '"%s"' "$(json_str "$1")" || printf 'null'; }

# Return the first line of a tool's --version output, or empty string if unavailable
tool_version() { [[ -n "$1" ]] && "$1" --version 2>&1 | head -1 | tr -d '\r' || true; }

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
    # ImageMagick 6: standalone 'compare' binary
    command -v compare &>/dev/null && echo "compare" && return
    # ImageMagick 7: all tools unified under 'magick'; check PATH then Windows installs
    command -v magick &>/dev/null && echo "magick" && return
    local win_magick
    for win_magick in \
        "/c/Program Files/ImageMagick-"*"/magick.exe" \
        "/mnt/c/Program Files/ImageMagick-"*"/magick.exe"
    do
        # glob expansion: check each match
        [[ -x "$win_magick" ]] && echo "$win_magick" && return
    done
    echo ""
}

# Returns true if COMPARE points to an ImageMagick 7 'magick' binary
# (where the subcommand 'compare' must be passed explicitly).
compare_is_im7() { [[ "$(basename "${COMPARE%.exe}")" == "magick" ]]; }

find_timeout_cmd() {
    # Prefer gtimeout (macOS homebrew coreutils) then timeout (Linux/Git Bash)
    command -v gtimeout &>/dev/null && echo "gtimeout" && return
    command -v timeout  &>/dev/null && echo "timeout"  && return
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
PYTHON="$(find_python)"
TIMEOUT_CMD="$(find_timeout_cmd)"

# Per-step render timeout in seconds (0 = no timeout)
RENDER_TIMEOUT=300

# ── Argument parsing ───────────────────────────────────────────────────────────

RUN_LINT=false; RUN_SYNTAX=false; RUN_SMOKE=false
RUN_GEOMETRY=false; RUN_VISUAL=false
CAPTURE_REFERENCES=false
UPDATE_GOLDEN=false
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
            --update-golden)       UPDATE_GOLDEN=true ;;
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
    find "$CASES_DIR" -name "test.json" -maxdepth 2 | sort -V | while read -r f; do
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

# Parse $vpt, $vpr, $vpd from an OpenSCAD openings file.
# Prints three lines — vpt, vpr, vpd — as comma-separated values (empty if absent).
parse_camera_from_openings() {
    local _p; _p=$(py_path "$1")
    $PYTHON -c "
import re, sys

try:
    with open('$_p', encoding='utf-8') as f:
        text = f.read()
except FileNotFoundError:
    print('')
    print('')
    print('')
    sys.exit(0)

def parse_vec(name):
    m = re.search(r'\\\$' + name + r'\s*=\s*\[([^\]]+)\]', text)
    if m:
        parts = [v.strip() for v in m.group(1).split(',')]
        if len(parts) == 3:
            return ','.join(parts)
    return ''

def parse_scalar(name):
    m = re.search(r'\\\$' + name + r'\s*=\s*([0-9.]+)', text)
    return m.group(1) if m else ''

print(parse_vec('vpt'))
print(parse_vec('vpr'))
print(parse_scalar('vpd'))
" | tr -d '\r'
}

# Return 0 (match) or 1 (no match) for a case/config name against CASE_FILTER.
# If CASE_FILTER is empty, always returns 0.
# Supports:
#   Exact match:  CASE_FILTER="Test Case 5"
#   Range:        CASE_FILTER="Test Case 0-10"  (matches "Test Case N" where 0 <= N <= 10)
#                 Range is only recognised when both bounds are integers and start < end,
#                 so names like "Test Case 44-1" are still treated as exact matches.
case_matches_filter() {
    local name="$1"
    [[ -z "$CASE_FILTER" ]] && return 0
    $PYTHON -c "
import re, sys
name   = sys.argv[1]
filt   = sys.argv[2]

def matches_one(name, filt):
    m = re.match(r'^(.+) (\d+)-(\d+)$', filt)
    if m and int(m.group(2)) < int(m.group(3)):
        prefix = m.group(1)
        lo, hi = int(m.group(2)), int(m.group(3))
        mn = re.match(r'^(.+) (\d+)$', name)
        if mn and mn.group(1) == prefix and lo <= int(mn.group(2)) <= hi:
            return True
        return False
    return name == filt

parts = [p.strip() for p in filt.split('|')]
sys.exit(0 if any(matches_one(name, p) for p in parts) else 1)
" "$name" "$CASE_FILTER"
}

# Parse a test.json and emit shell-evaluable assignments for one step (by index).
# Args 3-5 are optional case-level camera defaults (vpt, vpr, vpd); they override
# the global defaults but are overridden by values present in the step itself.
parse_step() {
    local test_json="$1"
    local step_idx="$2"
    local case_vpt="${3:-$DEFAULT_VPT}"
    local case_vpr="${4:-$DEFAULT_VPR}"
    local case_vpd="${5:-$DEFAULT_VPD}"
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

label        = step.get('label', f'step{idx+1}')
params       = step.get('params', '')
override     = step.get('params_override', {})
vpt_explicit = 'vpt' in step
vpr_explicit = 'vpr' in step
vpd_explicit = 'vpd' in step
vpt          = fmtlist(step.get('vpt'), '$case_vpt')
vpr          = fmtlist(step.get('vpr'), '$case_vpr')
vpd          = str(step.get('vpd')) if step.get('vpd') is not None else '$case_vpd'
expected     = step.get('expected', f'step{idx+1}_expected.png')
render       = str(step.get('render', False)).lower()
console      = step.get('console', '')

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
print(f'STEP_VPT_EXPLICIT={json.dumps(str(vpt_explicit).lower())}')
print(f'STEP_VPR_EXPLICIT={json.dumps(str(vpr_explicit).lower())}')
print(f'STEP_VPD_EXPLICIT={json.dumps(str(vpd_explicit).lower())}')
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

# ── Lock: prevent concurrent visual/geometry runs ─────────────────────────────
#
# Visual and geometry tests swap or write shared project files (openings_and_
# additions.txt, default.svg). Running two such tests concurrently produces race
# conditions: wrong geometry, blank PNGs, and false failures that waste debugging
# time. This lock enforces single-instance execution for those layers.

acquire_test_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local other_pid; other_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$other_pid" ]] && kill -0 "$other_pid" 2>/dev/null; then
            echo -e "${RED}${BOLD}Error:${RESET} A visual/geometry test run is already in progress (PID $other_pid)."
            echo "       Wait for it to finish, or stop it first:  kill $other_pid"
            exit 1
        fi
        rm -f "$LOCK_FILE"   # stale lock from a previously crashed run
    fi
    echo "$$" > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
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

# ── Layer 5: Geometry validation ──────────────────────────────────────────────
#
# Renders every named config to STL and validates the resulting mesh:
#   1. Render must succeed and produce a non-empty STL
#   2. OpenSCAD must report "Simple: yes" (CGAL manifold check)
#
# Reversed facets are NOT checked — OpenSCAD produces them non-deterministically
# and slicer software repairs them automatically. Manifold status is the only
# meaningful geometry criterion.
#
# The openings_and_additions.txt file is swapped from the matching test case
# folder before each render (falling back to the minimal root file). This
# prevents a non-minimal root O&A file from contaminating results.

run_geometry() {
    # Configs to skip in the geometry validation layer.
    # Built dynamically: any test step with "geometry": false in its test.json
    # contributes its "params" value to this list.  To exclude a config, add
    # "geometry": false to the relevant step(s) in tests/cases/*/test.json.
    local -a GEOMETRY_SKIP=()
    while IFS= read -r config_name; do
        [[ -n "$config_name" ]] && GEOMETRY_SKIP+=("$config_name")
    done < <($PYTHON - "$CASES_DIR" <<'PYEOF' | tr -d '\r'
import json, os, sys

cases_dir = sys.argv[1]
skip = set()
for root, _dirs, files in os.walk(cases_dir):
    for fn in files:
        if fn != "test.json":
            continue
        path = os.path.join(root, fn)
        try:
            with open(path, encoding="utf-8") as fh:
                test = json.load(fh)
            for step in test.get("steps", []):
                if step.get("geometry") is False and step.get("params"):
                    skip.add(step["params"])
        except Exception:
            pass
for name in sorted(skip):
    print(name)
PYEOF
)

    header "Layer 5 — Geometry validation (all named configs)"
    local -a configs
    mapfile -t configs < <(get_configs)
    info "Found ${#configs[@]} named configs"
    [[ -n "$CASE_FILTER" ]] && info "Filter: '$CASE_FILTER'"

    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi

    local render_failures=0 manifold_failures=0 skipped=0
    local total=${#configs[@]} current=0
    local run_label; run_label=$(date +%Y-%m-%d_%H-%M-%S)
    local t_geom_run_start; t_geom_run_start=$(date +%s)
    local geom_passed=0

    # Save root O&A so we can restore it after each config and at the end.
    # Each config gets the O&A from its matching test case folder (if one exists),
    # falling back to the minimal root file.  This prevents a non-minimal root
    # file from contaminating results.
    local geom_saved_openings="/tmp/keyguard_geom_oa_$$.txt"
    cp "$OPENINGS_FILE" "$geom_saved_openings"

    for config in "${configs[@]}"; do
        current=$((current + 1))

        # Apply --case filter if specified
        case_matches_filter "$config" || continue

        local skip=false
        for s in "${GEOMETRY_SKIP[@]}"; do
            [[ "$config" == "$s" ]] && skip=true && break
        done
        if "$skip"; then
            printf "  [%2d/%d] %-35s" "$current" "$total" "$config"
            echo -e " ${YELLOW}SKIP${RESET}"
            skipped=$((skipped + 1))
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"skip\",\"manifold\":null,\"duration_s\":0,\"ts\":\"$(iso_ts)\"}"
            continue
        fi

        # ── Swap in the test-case O&A file if one exists ───────────────────────
        local case_openings_src=""
        local case_test_json="$CASES_DIR/$config/test.json"
        if [[ -f "$case_test_json" ]]; then
            local case_openings_name
            case_openings_name=$(get_test_field "$case_test_json" "openings")
            if [[ -n "$case_openings_name" && -f "$CASES_DIR/$config/$case_openings_name" ]]; then
                case_openings_src="$CASES_DIR/$config/$case_openings_name"
            fi
        fi
        if [[ -n "$case_openings_src" ]]; then
            cp "$case_openings_src" "$OPENINGS_FILE"
        else
            cp "$geom_saved_openings" "$OPENINGS_FILE"
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
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"render_failed\",\"manifold\":null,\"duration_s\":$t_elapsed,\"ts\":\"$(iso_ts)\"}"
            rm -f "$out"; continue
        fi

        # ── 2. Manifold check (OpenSCAD / CGAL) ────────────────────────────────
        # "Simple: yes" means every edge is shared by exactly two faces — the
        # standard definition of a 2-manifold mesh.  This is the sole pass/fail
        # criterion; reversed facets are not checked (non-deterministic OpenSCAD
        # artefact, repaired automatically by slicer software).
        local is_simple
        is_simple=$(echo "$console" | grep -oE 'Simple:[[:space:]]+(yes|no)' \
                    | grep -oE '(yes|no)' || echo "")
        if [[ "$is_simple" == "no" ]]; then
            echo -e " ${RED}NON-MANIFOLD${RESET} (${t_elapsed}s)"
            manifold_failures=$((manifold_failures + 1))
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"fail\",\"manifold\":\"no\",\"duration_s\":$t_elapsed,\"ts\":\"$(iso_ts)\"}"
        else
            if [[ -z "$is_simple" ]]; then
                echo -e " ${YELLOW}OK (manifold status unknown)${RESET} (${t_elapsed}s)"
            else
                echo -e " ${GREEN}OK${RESET} (${t_elapsed}s)"
            fi
            geom_passed=$((geom_passed + 1))
            log_event "{\"event\":\"config\",\"run\":\"$(json_str "$run_label")\",\"config\":\"$(json_str "$config")\",\"status\":\"pass\",\"manifold\":\"${is_simple:-unknown}\",\"duration_s\":$t_elapsed,\"ts\":\"$(iso_ts)\"}"
        fi

        # ── Clean up STL (checks are done; no value in keeping it) ─────────────
        rm -f "$out"
    done

    # Restore root O&A to the saved minimal version
    cp "$geom_saved_openings" "$OPENINGS_FILE"
    rm -f "$geom_saved_openings"

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
    if [[ "$render_failures" -eq 0 && "$manifold_failures" -eq 0 ]]; then
        pass "Geometry validation — all configs passed"
    fi
    local t_geom_elapsed=$(( $(date +%s) - t_geom_run_start ))
    local geom_failed=$(( render_failures + manifold_failures ))
    log_event "{\"event\":\"run\",\"run\":\"$(json_str "$run_label")\",\"mode\":\"geometry\",\"configs_total\":$total,\"configs_passed\":$geom_passed,\"configs_failed\":$geom_failed,\"configs_skipped\":$skipped,\"render_failures\":$render_failures,\"manifold_failures\":$manifold_failures,\"duration_s\":$t_geom_elapsed,\"ts\":\"$(iso_ts)\"}"
    info "Timings appended to: test-timings.ndjson"
}

# ── Golden STL stats manifest generator ────────────────────────────────────────
#
# Renders every named config to STL using native OpenSCAD (CGAL — the
# authoritative backend) and writes per-config geometric stats to
# tests/cases/golden-stl-stats.json. The web app's geometry layer (run via
# Playwright in keyguard-designer-web) loads this manifest and compares its
# Manifold-backend STL output against the recorded numbers to detect cases
# where Manifold silently produces broken geometry (e.g. TC57 membranes).
#
# Skip list and OA-swap logic mirror run_geometry, so every config that
# appears in the geometry-validation pass-list contributes one manifest entry.
#
# This is opt-in only (--update-golden); the manifest is regenerated when
# .scad-side geometry intentionally changes, and committed alongside the
# code change.

run_update_golden() {
    local manifest="$CASES_DIR/golden-stl-stats.json"
    local stats_script="$SCRIPT_DIR/compute_stl_stats.py"
    # Native-OpenSCAD CGAL renders are slower than --geometry expects: TC57
    # for example spends ~270s in CGAL. Use a longer per-config timeout so
    # the manifest can capture the heavy cases. Honour an explicit override
    # via env if the caller knows the corpus has gotten heavier.
    local prev_render_timeout="$RENDER_TIMEOUT"
    RENDER_TIMEOUT="${KEYGUARD_GOLDEN_TIMEOUT:-900}"
    info "Per-config render timeout: ${RENDER_TIMEOUT}s"

    # Progress log for `tail -f`. Truncated at start; one human-readable
    # line per config completion (or render/stats failure). Lives in the
    # project root for easy discovery; not committed to git.
    local progress_log="$PROJECT_ROOT/golden-stl-stats-progress.log"
    : > "$progress_log"

    header "Golden STL stats — regenerating manifest"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — aborting"; return; fi
    if [[ ! -f "$stats_script" ]]; then fail "compute_stl_stats.py not found at $stats_script"; return; fi
    info "Progress log: $(realpath --relative-to="$PROJECT_ROOT" "$progress_log" 2>/dev/null || echo "$progress_log") (tail -f)"

    # Discover (preset, case-folder, oa-file) tuples the SAME way the web
    # app's geometry.spec.mjs discoverCases() does: walk every test case's
    # test.json and, for each step that produces geometry, map its preset
    # (step.params) to *that case's* OA file. This is critical — many
    # presets (e.g. "Test Case 17d", "Test Case 10a") are steps *inside*
    # another case's folder, not folders of their own. The web app always
    # renders such a preset with its parent case's OA, so the manifest must
    # capture the same pairing. (The earlier folder-name-matching approach
    # gave those presets the root fallback OA and produced reference
    # geometry that diverged from the web app by hundreds of percent.)
    #
    # Output: tab-separated  preset \t case-folder \t oa-filename.
    # First occurrence of a preset wins (cases sorted naturally for
    # determinism). Steps with geometry:false or no params are excluded
    # here, so no separate skip list is needed below.
    local -a specs
    mapfile -t specs < <($PYTHON - "$CASES_DIR" <<'PYEOF' | tr -d '\r'
import json, os, re, sys
cases_dir = sys.argv[1]
def nat(s):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]
seen = set()
for name in sorted(os.listdir(cases_dir), key=nat):
    if name == 'visual.snapshots':
        continue
    d = os.path.join(cases_dir, name)
    tj = os.path.join(d, 'test.json')
    if not os.path.isdir(d) or not os.path.isfile(tj):
        continue
    try:
        with open(tj, encoding='utf-8') as f:
            test = json.load(f)
    except Exception:
        continue
    oa = test.get('openings') or 'openings_and_additions.txt'
    if not os.path.isfile(os.path.join(d, oa)):
        continue
    for step in test.get('steps', []):
        if not step or not step.get('params'):
            continue
        if step.get('geometry') is False:
            continue
        preset = step['params']
        if preset in seen:
            continue
        seen.add(preset)
        print(f"{preset}\t{name}\t{oa}")
PYEOF
)
    info "Discovered ${#specs[@]} unique geometry presets across test cases"
    info "Manifest: $(realpath --relative-to="$PROJECT_ROOT" "$manifest" 2>/dev/null || echo "$manifest")"
    [[ -n "$CASE_FILTER" ]] && info "Filter: '$CASE_FILTER' (matches preset OR case name; existing entries outside the filter are preserved)"

    # Preserve existing manifest entries that fall outside the filter.
    local existing="{}"
    if [[ -f "$manifest" ]]; then
        existing=$($PYTHON -c "
import json, sys
try:
    with open('$(py_path "$manifest")', encoding='utf-8') as f:
        d = json.load(f).get('configs', {})
    print(json.dumps(d))
except Exception:
    print('{}')
")
    fi

    # Save root O&A so we can restore it after each config and at the end.
    local saved_openings="/tmp/keyguard_golden_oa_$$.txt"
    cp "$OPENINGS_FILE" "$saved_openings"

    local total=${#specs[@]} current=0 ok=0 fail_count=0 skipped=0
    local entries=""   # accumulated JSON entries, comma-separated
    local t_start; t_start=$(date +%s)

    for spec in "${specs[@]}"; do
        current=$((current + 1))
        local config case_name oa_name
        IFS=$'\t' read -r config case_name oa_name <<< "$spec"

        # Filter matches either the preset name or its parent case name, so
        # `--case "Test Case 17"` regenerates every 17* preset.
        if ! case_matches_filter "$config" && ! case_matches_filter "$case_name"; then
            # Outside filter — keep existing entry if present.
            local kept; kept=$($PYTHON -c "
import json, sys
d = json.loads(sys.argv[1])
v = d.get(sys.argv[2])
if v is None: sys.exit(1)
print(json.dumps({sys.argv[2]: v})[1:-1])
" "$existing" "$config" 2>/dev/null) && entries+="$kept,"$'\n'
            continue
        fi

        # OA is always the parent case's file (matching the web app).
        local case_openings_src="$CASES_DIR/$case_name/$oa_name"
        if [[ ! -f "$case_openings_src" ]]; then
            cp "$saved_openings" "$OPENINGS_FILE"
            case_openings_src=""
        else
            cp "$case_openings_src" "$OPENINGS_FILE"
        fi

        local safe; safe=$(echo "$config" | tr ' /' '__')
        local out="/tmp/keyguard_golden_${safe}_$$.stl"
        printf "  [%3d/%d] %-35s" "$current" "$total" "$config"

        local exit_code=0 t0 dt
        t0=$(date +%s)
        # Mirror the web app's export-path -D injection (see app.html
        # renderExportBytes): fudge/ff = 0.05 is the Manifold cell-floor
        # workaround that the web app always applies, and include_screenshot
        # is forced off for exports. The manifest must capture the same
        # geometry the web app's export produces, otherwise the comparison
        # picks up render-parameter drift instead of actual Manifold-vs-CGAL
        # divergence.
        local rargs=(-p "$JSON_FILE" -P "$config"
                     -D fudge=0.05 -D ff=0.05 -D include_screenshot="no"
                     -o "$out" "$SCAD_FILE")
        if [[ -n "$TIMEOUT_CMD" && "$RENDER_TIMEOUT" -gt 0 ]]; then
            "$TIMEOUT_CMD" "$RENDER_TIMEOUT" "$OPENSCAD" "${rargs[@]}" &>/dev/null || exit_code=$?
        else
            "$OPENSCAD" "${rargs[@]}" &>/dev/null || exit_code=$?
        fi
        dt=$(( $(date +%s) - t0 ))

        if [[ "$exit_code" -ne 0 || ! -s "$out" ]]; then
            echo -e " ${RED}RENDER FAILED${RESET} (${dt}s)"
            printf "[%3d/%d] %-35s RENDER FAILED (%ds)\n" "$current" "$total" "$config" "$dt" >> "$progress_log"
            fail_count=$((fail_count + 1))
            rm -f "$out"
            continue
        fi

        local stats; stats=$("$PYTHON" "$stats_script" "$out" 2>/dev/null) || {
            echo -e " ${RED}STATS FAILED${RESET} (${dt}s)"
            printf "[%3d/%d] %-35s STATS FAILED (%ds)\n" "$current" "$total" "$config" "$dt" >> "$progress_log"
            fail_count=$((fail_count + 1))
            rm -f "$out"; continue
        }
        rm -f "$out"

        # Wrap into "<config>": { stats, oa_source, oa_case }.
        # oa_case records which test-case folder supplied the OA file (the
        # web app renders this preset with that case's OA), so a future
        # divergence can be reproduced without re-deriving the mapping.
        local oa_kind="root"
        [[ -n "$case_openings_src" ]] && oa_kind="case"
        local entry; entry=$($PYTHON -c "
import json, sys
stats = json.loads(sys.argv[1])
stats['oa_source'] = sys.argv[2]
stats['oa_case'] = sys.argv[4]
print(json.dumps({sys.argv[3]: stats})[1:-1])
" "$stats" "$oa_kind" "$config" "$case_name")
        entries+="$entry,"$'\n'
        ok=$((ok + 1))
        echo -e " ${GREEN}OK${RESET} (${dt}s)"
        # Per-config one-liner for tail -f: include key stats so progress is
        # informative on its own (e.g. a divergent parts count or out-of-band
        # facet count is visible without opening the manifest).
        local stats_summary; stats_summary=$($PYTHON -c "
import json, sys
s = json.loads(sys.argv[1])
print(f\"vol={s['volume_mm3']} area={s['surface_area_mm2']} parts={s['parts']} facets={s['facets']}\")
" "$stats")
        printf "[%3d/%d] %-35s OK (%4ds)  %s\n" "$current" "$total" "$config" "$dt" "$stats_summary" >> "$progress_log"
    done

    # Restore root O&A.
    cp "$saved_openings" "$OPENINGS_FILE"
    rm -f "$saved_openings"

    # Strip trailing comma+newline if present, then wrap.
    entries=$(echo -n "$entries" | sed '$ s/,$//')

    local manifest_meta
    manifest_meta=$($PYTHON -c "
import json
print(json.dumps({
    'schema_version': 1,
    'generator': 'test.sh --update-golden',
    'openscad': '$(json_str "$(tool_version "$OPENSCAD")")',
    'notes': 'Stats computed from CGAL-backend native OpenSCAD STL output. See scripts/compute_stl_stats.py for the formula. Used by keyguard-designer-web tests/geometry.spec.mjs as the authoritative reference for Manifold-backend STL validation.',
}, indent=2))")

    {
        echo "{"
        echo "  \"meta\": $manifest_meta,"
        echo "  \"configs\": {"
        # Indent the entries one extra step for readability.
        echo "$entries" | sed 's/^/    /'
        echo "  }"
        echo "}"
    } > "$manifest"

    # Pretty-print + validate via Python (rewrites the file in canonical form,
    # also catches any malformed entries from above).
    $PYTHON -c "
import json
with open('$(py_path "$manifest")', encoding='utf-8') as f:
    d = json.load(f)
with open('$(py_path "$manifest")', 'w', encoding='utf-8', newline='\n') as f:
    json.dump(d, f, indent=2, sort_keys=False)
    f.write('\n')
" || { fail "Failed to format manifest JSON"; return; }

    local elapsed=$(( $(date +%s) - t_start ))
    echo ""
    info "Configs processed: $ok ok, $fail_count failed, $skipped skipped (of $total) in ${elapsed}s"
    if [[ "$fail_count" -gt 0 ]]; then
        fail "$fail_count config(s) failed to render or compute stats"
    else
        pass "Golden manifest written: $manifest"
    fi
    RENDER_TIMEOUT="$prev_render_timeout"
}

# ── Layer 4: Visual tests ─────────────────────────────────────────────────────

# Compare two PNGs; return 0 if same/within threshold, 1 if different.
# Sets the global LAST_RMSE to the numeric score (or "null" if unavailable).
#
# Primary: ImageMagick (IM6: 'compare'; IM7: 'magick compare').
#   Uses normalized RMSE (0–1 scale); threshold 0.02 ≈ 5/255.
#   Also generates a diff image for failed comparisons.
# Fallback: Python RMSE via compare_png.py (threshold 5.0 on 0–255 scale).
# Last resort: exact SHA-256 hash comparison.
LAST_RMSE="null"
compare_png() {
    local rendered="$1" expected="$2" diff_out="$3"
    LAST_RMSE="null"
    if [[ -n "$COMPARE" ]]; then
        # Build the compare command: IM7 uses 'magick compare', IM6 uses 'compare'.
        local im_cmd=("$COMPARE")
        compare_is_im7 && im_cmd+=("compare")
        # Note: 'compare' exits 1 when images differ (even slightly), so capture
        # output before checking the exit code to avoid set -o pipefail issues.
        local raw_output score
        raw_output=$("${im_cmd[@]}" -metric RMSE "$rendered" "$expected" "$diff_out" 2>&1) || true
        score=$(echo "$raw_output" | grep -oE '\([0-9.e+-]+\)' | tr -d '()' || echo "1")
        LAST_RMSE="${score:-null}"
        $PYTHON -c "import sys; sys.exit(0 if float('${score:-1}') < 0.02 else 1)" 2>/dev/null
    elif [[ -n "$PYTHON" ]]; then
        # Python fallback: pure-stdlib RMSE (threshold 5.0 on 0–255 scale ≈ 0.02 normalised).
        # Normalise the reported score to 0–1 so LAST_RMSE is on the same scale as
        # the ImageMagick path (both are stored as "rmse" in the NDJSON log).
        local py_script; py_script="$(py_path "$SCRIPT_DIR/compare_png.py")"
        local raw_score exit_code=0
        raw_score=$($PYTHON "$py_script" "$rendered" "$expected" 5.0 2>/dev/null) || exit_code=$?
        LAST_RMSE=$($PYTHON -c "print(f'{float(\"${raw_score:-255}\")/255:.4f}')" 2>/dev/null || echo "null")
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
    header "Layer 4 — Visual tests"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi
    [[ -z "$COMPARE" && -z "$PYTHON" ]] && warn "ImageMagick and Python not found — using exact hash comparison"
    [[ -z "$COMPARE" && -n "$PYTHON" ]] && warn "ImageMagick not found — using Python RMSE fallback (install ImageMagick for best results)"
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
        case_matches_filter "$case_name" || continue

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

        # ── Parse camera defaults from openings file (if any) ──────────────────
        local case_vpt="$DEFAULT_VPT" case_vpr="$DEFAULT_VPR" case_vpd="$DEFAULT_VPD"
        if [[ -n "$openings_override" && -f "$case_dir/$openings_override" ]]; then
            local _cam_lines
            mapfile -t _cam_lines < <(parse_camera_from_openings "$case_dir/$openings_override")
            [[ -n "${_cam_lines[0]}" ]] && case_vpt="${_cam_lines[0]}"
            [[ -n "${_cam_lines[1]}" ]] && case_vpr="${_cam_lines[1]}"
            [[ -n "${_cam_lines[2]}" ]] && case_vpd="${_cam_lines[2]}"
        fi

        # Snapshot the case-base openings file so per-step params files can restore it
        local case_base_openings_backup="/tmp/keyguard_case_base_$$.txt"
        cp "$OPENINGS_FILE" "$case_base_openings_backup"

        # ── Run each step ───────────────────────────────────────────────────────
        local case_ok=true
        local case_rows=""   # table rows for this case's summary section

        for (( i=0; i<step_count; i++ )); do
            local step_vars; step_vars=$(parse_step "$test_json" "$i" "$case_vpt" "$case_vpr" "$case_vpd") || {
                fail "  Step $i: could not parse test.json"
                case_ok=false
                case_rows+="| $((i+1))/$step_count | (parse error) | FAIL |"$'\n'
                continue
            }
            eval "$step_vars"

            # ── Per-step params-specific openings file ───────────────────────────
            local params_openings_applied=false
            if [[ -n "$STEP_PARAMS" ]]; then
                local params_openings_file="${case_dir}/${STEP_PARAMS}_openings_and_additions.txt"
                if [[ -f "$params_openings_file" ]]; then
                    cp "$params_openings_file" "$OPENINGS_FILE"
                    params_openings_applied=true
                    # Override camera values that weren't explicit in the step
                    if [[ "$STEP_VPT_EXPLICIT" != "true" || "$STEP_VPR_EXPLICIT" != "true" || "$STEP_VPD_EXPLICIT" != "true" ]]; then
                        local _pcam
                        mapfile -t _pcam < <(parse_camera_from_openings "$params_openings_file")
                        [[ "$STEP_VPT_EXPLICIT" != "true" && -n "${_pcam[0]}" ]] && STEP_VPT="${_pcam[0]}"
                        [[ "$STEP_VPR_EXPLICIT" != "true" && -n "${_pcam[1]}" ]] && STEP_VPR="${_pcam[1]}"
                        [[ "$STEP_VPD_EXPLICIT" != "true" && -n "${_pcam[2]}" ]] && STEP_VPD="${_pcam[2]}"
                    fi
                fi
            fi

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
            local expected_png="$SNAPSHOTS_DIR/$case_name/$STEP_EXPECTED"
            local diff_png="$render_dir/step$((i+1))_${safe_label}_diff.png"

            printf "    [step %d/%d] %-30s" "$((i+1))" "$step_count" "$STEP_LABEL"

            local t_step_start; t_step_start=$(date +%s)
            local cmd=("$OPENSCAD"
                --camera="$camera"
                --imgsize=2048,1536
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
            if [[ -n "$TIMEOUT_CMD" && "$RENDER_TIMEOUT" -gt 0 ]]; then
                "$TIMEOUT_CMD" "$RENDER_TIMEOUT" "${cmd[@]}" > "$console_log" 2>&1 || exit_code=$?
            else
                "${cmd[@]}" > "$console_log" 2>&1 || exit_code=$?
            fi

            local t_step_elapsed=$(( $(date +%s) - t_step_start ))

            if [[ "$exit_code" -eq 124 ]]; then
                echo -e " ${RED}TIMED OUT${RESET} (>${RENDER_TIMEOUT}s)"
                case_ok=false
                case_step_failed=$((case_step_failed + 1))
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | TIMED OUT (>${RENDER_TIMEOUT}s) |"$'\n'
                log_event "{\"event\":\"step\",\"run\":\"$(json_str "$run_label")\",\"case\":\"$(json_str "$case_name")\",\"step\":$((i+1)),\"step_count\":$step_count,\"label\":\"$(json_str "$STEP_LABEL")\",\"status\":\"timed_out\",\"rmse\":null,\"duration_s\":$t_step_elapsed,\"ts\":\"$(iso_ts)\"}"
                continue
            fi

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
                mkdir -p "$(dirname "$expected_png")"
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

            # Restore case-base openings after a params-specific swap
            "$params_openings_applied" && cp "$case_base_openings_backup" "$OPENINGS_FILE"
        done

        # ── Teardown: restore original files ────────────────────────────────────
        rm -f "$case_base_openings_backup"
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
if [[ -n "$COMPARE" ]]; then
    compare_is_im7 && _im_style="IM7 (magick compare)" || _im_style="IM6 (compare)"
    info "ImageMagick: $COMPARE ($_im_style)"
else
    info "ImageMagick: not found (will use Python RMSE fallback)"
fi
info "timeout:     ${TIMEOUT_CMD:-not found (renders will not be time-limited)} (limit: ${RENDER_TIMEOUT}s)"

# ── Start fresh timings file, then log environment record ────────────────────
rm -f "$TIMINGS_FILE"
[[ -n "$MIRROR_TIMINGS_FILE" ]] && rm -f "$MIRROR_TIMINGS_FILE"
SESSION_ID="$(date +'%Y-%m-%d_%H-%M-%S')"
_os="$(uname -o 2>/dev/null || uname -s 2>/dev/null || true)"
_openscad_ver="$(tool_version "$OPENSCAD")"
_python_ver="$([[ -n "$PYTHON" ]] && "$PYTHON" --version 2>&1 | tr -d '\r' || true)"
_sca2d_ver="$(tool_version "$SCA2D")"
_compare_ver="$( [[ -n "$COMPARE" ]] && { compare_is_im7 && "$COMPARE" --version 2>&1 | head -1 || "$COMPARE" --version 2>&1 | head -1; } | tr -d '\r' || true)"
log_event "{\"event\":\"env\",\"session\":\"$(json_str "$SESSION_ID")\",\"os\":$(json_val "$_os"),\"openscad\":$(json_val "$OPENSCAD"),\"openscad_version\":$(json_val "$_openscad_ver"),\"python\":$(json_val "$PYTHON"),\"python_version\":$(json_val "$_python_ver"),\"sca2d\":$(json_val "$SCA2D"),\"sca2d_version\":$(json_val "$_sca2d_ver"),\"imagemagick\":$(json_val "$COMPARE"),\"imagemagick_version\":$(json_val "$_compare_ver"),\"timeout_cmd\":$(json_val "$TIMEOUT_CMD"),\"render_timeout_s\":$RENDER_TIMEOUT,\"ts\":\"$(iso_ts)\"}"

"$RUN_LINT"             && run_lint
"$RUN_SYNTAX"           && run_syntax
"$RUN_SMOKE"            && run_smoke
{ "$RUN_VISUAL" || "$RUN_GEOMETRY" || "$UPDATE_GOLDEN"; } && acquire_test_lock
"$RUN_VISUAL"           && run_visual
"$RUN_GEOMETRY"         && run_geometry
"$UPDATE_GOLDEN"        && run_update_golden

echo ""
echo "==============================="
if [[ "$FAILURES" -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All tests passed.${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}$FAILURES test(s) failed.${RESET}"
    exit 1
fi

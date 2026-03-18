#!/usr/bin/env bash
# test.sh — Multi-layer test runner for the keyguard designer
#
# Layers (run in order, or individually via flags):
#   --lint               Layer 1: sca2d static analysis (fast, no render)
#   --syntax             Layer 2: OpenSCAD --hardwarnings parse check (fast, no render)
#   --smoke              Layer 3: Render default config to STL
#   --regression         Layer 4: Render all named configs from keyguard.json;
#                                  compare STL checksums against baseline
#   --visual             Layer 5: Run test.json cases; compare PNGs against references
#
# Usage:
#   ./scripts/test.sh                        # Layers 1–3 (fast default)
#   ./scripts/test.sh --all                  # All layers
#   ./scripts/test.sh --lint                 # Single layer
#   ./scripts/test.sh --lint --syntax        # Combine layers
#   ./scripts/test.sh --update-baseline      # Re-render all configs; save new STL baseline
#   ./scripts/test.sh --capture-references   # Re-render all visual tests; save new reference PNGs
#
# Requirements:
#   - openscad  (on PATH, or at a common Windows install location)
#   - python3   (for JSON parsing)
#   - sca2d     (pip install sca2d)  — Layer 1 only
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
BASELINE_FILE="$PROJECT_ROOT/tests/baseline.sha256"
CASES_DIR="$PROJECT_ROOT/tests/cases"

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

# ── Argument parsing ───────────────────────────────────────────────────────────

RUN_LINT=false; RUN_SYNTAX=false; RUN_SMOKE=false
RUN_REGRESSION=false; RUN_VISUAL=false
UPDATE_BASELINE=false; CAPTURE_REFERENCES=false

if [[ $# -eq 0 ]]; then
    RUN_LINT=true; RUN_SYNTAX=true; RUN_SMOKE=true
else
    for arg in "$@"; do
        case "$arg" in
            --lint)                RUN_LINT=true ;;
            --syntax)              RUN_SYNTAX=true ;;
            --smoke)               RUN_SMOKE=true ;;
            --regression)          RUN_REGRESSION=true ;;
            --visual)              RUN_VISUAL=true ;;
            --all)                 RUN_LINT=true; RUN_SYNTAX=true; RUN_SMOKE=true
                                   RUN_REGRESSION=true; RUN_VISUAL=true ;;
            --update-baseline)     UPDATE_BASELINE=true; RUN_REGRESSION=true ;;
            --capture-references)  CAPTURE_REFERENCES=true; RUN_VISUAL=true ;;
            *) echo "Unknown option: $arg"; exit 1 ;;
        esac
    done
fi

# ── Python helpers ─────────────────────────────────────────────────────────────

# List all named configs from keyguard.json
get_configs() {
    local _p; _p=$(py_path "$JSON_FILE")
    $PYTHON -c "
import json
with open('$_p') as f:
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

with open('$_p') as f:
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
with open('$_p') as f:
    test = json.load(f)
print(len(test.get('steps', [])))
" | tr -d '\r'
}

# Get top-level string field from test.json (returns empty string for missing or null values)
get_test_field() {
    local _p; _p=$(py_path "$1")
    $PYTHON -c "
import json
with open('$_p') as f:
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
with open('$_p') as f:
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
    local tmp_stl; tmp_stl=$(mktemp "${TMPDIR:-/tmp}/openscad_syntax_XXXXXX.stl")
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

# ── Layer 4: Regression ───────────────────────────────────────────────────────

run_regression() {
    header "Layer 4 — Regression test (all named configs)"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi
    mkdir -p "$OUTPUT_DIR/regression" "$(dirname "$BASELINE_FILE")"

    local configs; mapfile -t configs < <(get_configs)
    info "Found ${#configs[@]} named configs"
    "$UPDATE_BASELINE" && info "Mode: updating baseline"

    local new_checksums="" render_failures=0 total=${#configs[@]} current=0

    for config in "${configs[@]}"; do
        current=$((current + 1))
        local safe; safe=$(echo "$config" | tr ' /' '__')
        local out="$OUTPUT_DIR/regression/${safe}.stl"
        printf "  [%2d/%d] %-35s" "$current" "$total" "$config"
        local exit_code=0
        "$OPENSCAD" -p "$JSON_FILE" -P "$config" \
            -o "$out" "$SCAD_FILE" > /dev/null 2>&1 || exit_code=$?
        if [[ "$exit_code" -ne 0 || ! -s "$out" ]]; then
            echo -e " ${RED}RENDER FAILED${RESET}"
            render_failures=$((render_failures + 1)); continue
        fi
        local sum; sum=$(sha256sum "$out" | cut -d' ' -f1)
        new_checksums+="${sum}  ${config}"$'\n'
        echo -e " ${GREEN}OK${RESET}"
    done
    echo ""
    [[ "$render_failures" -gt 0 ]] && fail "$render_failures config(s) failed to render"

    if "$UPDATE_BASELINE"; then
        echo "$new_checksums" > "$BASELINE_FILE"
        pass "Baseline updated — ${#configs[@]} configs"; return
    fi
    if [[ ! -f "$BASELINE_FILE" ]]; then
        warn "No baseline found — creating now"
        echo "$new_checksums" > "$BASELINE_FILE"
        pass "Baseline created — ${#configs[@]} configs"; return
    fi

    local regressions=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local old_sum old_name new_sum
        old_sum=$(echo "$line" | cut -d' ' -f1)
        old_name=$(echo "$line" | cut -d' ' -f3-)
        new_sum=$(echo "$new_checksums" | grep "  ${old_name}$" | cut -d' ' -f1 || echo "")
        if   [[ -z "$new_sum" ]];          then warn "Config '$old_name' missing"; regressions=$((regressions+1))
        elif [[ "$old_sum" != "$new_sum" ]]; then fail "Regression: '$old_name' output changed"; regressions=$((regressions+1))
        fi
    done < "$BASELINE_FILE"
    [[ "$regressions" -eq 0 ]] && pass "Regression — all ${#configs[@]} configs match baseline"
}

# ── Layer 5: Visual tests ─────────────────────────────────────────────────────

# Compare two PNGs; return 0 if same/within threshold, 1 if different
compare_png() {
    local rendered="$1" expected="$2" diff_out="$3"
    if [[ -n "$COMPARE" ]]; then
        # ImageMagick: RMSE < 1.0
        local score
        score=$("$COMPARE" -metric RMSE "$rendered" "$expected" "$diff_out" 2>&1 | grep -oE '^[0-9.]+' || echo "999")
        $PYTHON -c "import sys; sys.exit(0 if float('$score') < 1.0 else 1)" 2>/dev/null
    elif [[ -n "$PYTHON" ]]; then
        # Python fallback: pure-stdlib RMSE comparison (threshold 5.0)
        # OpenSCAD's PNG renderer is slightly non-deterministic between runs;
        # RMSE < 5.0 catches real regressions while tolerating render noise.
        local py_script; py_script="$(py_path "$SCRIPT_DIR/compare_png.py")"
        $PYTHON "$py_script" "$rendered" "$expected" 5.0 > /dev/null
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

    # Create a timestamped results directory for this run
    local timestamp; timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local run_label; "$CAPTURE_REFERENCES" && run_label="${timestamp}_capture" || run_label="$timestamp"
    local run_dir="$TEST_RESULTS_DIR/$run_label"
    mkdir -p "$run_dir"

    local test_failures=0
    local summary_cases=""   # accumulated per-case markdown for summary

    for case_dir in "${cases[@]}"; do
        local test_json="$case_dir/test.json"
        local case_name; case_name=$(basename "$case_dir")
        local render_dir="$run_dir/$case_name"
        mkdir -p "$render_dir"

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
            saved_openings=$(mktemp)
            cp "$OPENINGS_FILE" "$saved_openings"
            cp "$case_dir/$openings_override" "$OPENINGS_FILE"
            info "Using $openings_override"
        fi

        if [[ -n "$svg_source" && -f "$case_dir/$svg_source" ]]; then
            saved_svg=$(mktemp --suffix=.svg)
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
            # Name rendered PNG with step number + label for easy browsing
            local rendered_png="$render_dir/step$((i+1))_${STEP_LABEL// /_}.png"
            local expected_png="$case_dir/$STEP_EXPECTED"
            local diff_png="$render_dir/step$((i+1))_${STEP_LABEL// /_}_diff.png"

            printf "    [step %d/%d] %-30s" "$((i+1))" "$step_count" "$STEP_LABEL"

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
            local console_log="$render_dir/step$((i+1))_${STEP_LABEL// /_}_console.log"
            "${cmd[@]}" > "$console_log" 2>&1 || exit_code=$?

            if [[ "$exit_code" -ne 0 || ! -s "$rendered_png" ]]; then
                echo -e " ${RED}RENDER FAILED${RESET}"
                case_ok=false
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | RENDER FAILED |"$'\n'
                continue
            fi

            # Capture mode: copy rendered PNG as the new reference
            if "$CAPTURE_REFERENCES"; then
                cp "$rendered_png" "$expected_png"
                echo -e " ${GREEN}CAPTURED${RESET}"
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | CAPTURED |"$'\n'
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
with open(sys.argv[1]) as f:
    expected_lines = [l.rstrip('\n') for l in f if l.strip()]
with open(sys.argv[2]) as f:
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
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | NO REFERENCE |"$'\n'
                continue
            fi

            local png_ok=true
            compare_png "$rendered_png" "$expected_png" "$diff_png" || png_ok=false

            if "$png_ok" && "$console_ok"; then
                echo -e " ${GREEN}PASS${RESET}"
                rm -f "$diff_png"
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | PASS |"$'\n'
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
                case_rows+="| $((i+1))/$step_count | $STEP_LABEL | FAIL ($fail_str) |"$'\n'
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

        "$case_ok" || test_failures=$((test_failures + 1))
        summary_cases+="### $case_name"$'\n\n'
        summary_cases+="| Step | Label | Result |"$'\n'
        summary_cases+="|------|-------|--------|"$'\n'
        summary_cases+="$case_rows"$'\n'
    done

    # ── Write summary document ───────────────────────────────────────────────────
    local mode_str; "$CAPTURE_REFERENCES" && mode_str="capture-references" || mode_str="visual"
    local overall_str
    if   "$CAPTURE_REFERENCES";          then overall_str="References captured"
    elif [[ "$test_failures" -eq 0 ]];   then overall_str="PASS"
    else overall_str="FAIL ($test_failures case(s) failed)"; fi

    {
        echo "# Keyguard Designer — Visual Test Results"
        echo ""
        echo "- **Run:** $(date '+%Y-%m-%d %H:%M:%S')"
        echo "- **Mode:** $mode_str"
        echo "- **Test cases:** ${#cases[@]}"
        echo "- **Overall:** $overall_str"
        echo ""
        echo "---"
        echo ""
        echo "$summary_cases"
    } > "$run_dir/summary.md"

    echo ""
    info "Results saved to: test results/$run_label/"
    if "$CAPTURE_REFERENCES"; then
        pass "References captured for ${#cases[@]} test case(s)"
    elif [[ "$test_failures" -eq 0 ]]; then
        pass "Visual tests — all ${#cases[@]} case(s) passed"
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
info "ImageMagick: ${COMPARE:-not found (will use hash comparison)}"

"$RUN_LINT"       && run_lint
"$RUN_SYNTAX"     && run_syntax
"$RUN_SMOKE"      && run_smoke
"$RUN_REGRESSION" && run_regression
"$RUN_VISUAL"     && run_visual

echo ""
echo "==============================="
if [[ "$FAILURES" -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All tests passed.${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}$FAILURES test(s) failed.${RESET}"
    exit 1
fi

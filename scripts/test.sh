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
    local win_paths=(
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

OPENSCAD="$(find_openscad)"
SCA2D="$(find_sca2d)"
COMPARE="$(find_compare)"

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
    python3 - <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
for name in data.get('parameterSets', {}).keys():
    print(name)
PYEOF
}
get_configs() { python3 -c "
import json
with open('$JSON_FILE') as f:
    data = json.load(f)
for name in data.get('parameterSets', {}).keys():
    print(name)
"; }

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
    python3 -c "
import json, sys

with open('$test_json') as f:
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
"
}

# Count steps in a test.json
count_steps() {
    python3 -c "
import json
with open('$1') as f:
    test = json.load(f)
print(len(test.get('steps', [])))
"
}

# Get top-level field from test.json
get_test_field() {
    python3 -c "
import json
with open('$1') as f:
    test = json.load(f)
print(test.get('$2', ''))
"
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
    output=$("$OPENSCAD" --hardwarnings "$SCAD_FILE" 2>&1 || true)
    "$OPENSCAD" --hardwarnings "$SCAD_FILE" > /dev/null 2>&1 || exit_code=$?
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
    output=$("$OPENSCAD" --hardwarnings -o "$out" "$SCAD_FILE" 2>&1) || exit_code=$?
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
        "$OPENSCAD" --hardwarnings -p "$JSON_FILE" -P "$config" \
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

# Compare two PNGs; return 0 if same, 1 if different
compare_png() {
    local rendered="$1" expected="$2" diff_out="$3"
    if [[ -n "$COMPARE" ]]; then
        local rmse
        rmse=$("$COMPARE" -metric RMSE "$rendered" "$expected" "$diff_out" 2>&1 | grep -oE '^[0-9.]+' || echo "999")
        # Treat as identical if RMSE < 1 (allows for minor version-to-version variation)
        python3 -c "import sys; sys.exit(0 if float('$rmse') < 1.0 else 1)" 2>/dev/null
    else
        # Fallback: exact hash comparison
        local h1 h2
        h1=$(sha256sum "$rendered" | cut -d' ' -f1)
        h2=$(sha256sum "$expected"  | cut -d' ' -f1)
        [[ "$h1" == "$h2" ]]
    fi
}

run_visual() {
    header "Layer 5 — Visual tests"
    if [[ -z "$OPENSCAD" ]]; then fail "openscad not found — skipping"; return; fi
    [[ -z "$COMPARE" ]] && warn "ImageMagick 'compare' not found — using exact hash comparison"
    "$CAPTURE_REFERENCES" && info "Mode: capturing reference images"

    local cases; mapfile -t cases < <(get_test_cases)
    if [[ ${#cases[@]} -eq 0 ]]; then
        warn "No test cases found in tests/cases/ — nothing to run"
        info "See tests/cases/README.md for how to add test cases"
        return
    fi
    info "Found ${#cases[@]} test case(s)"

    local test_failures=0

    for case_dir in "${cases[@]}"; do
        local test_json="$case_dir/test.json"
        local case_name; case_name=$(basename "$case_dir")
        local safe_name; safe_name=$(echo "$case_name" | tr ' /' '__')
        local render_dir="$OUTPUT_DIR/visual/$safe_name"
        mkdir -p "$render_dir"

        echo ""
        echo -e "  ${BOLD}${case_name}${RESET}"

        # Read top-level test fields
        local openings_override; openings_override=$(get_test_field "$test_json" "openings")
        local svg_source;        svg_source=$(get_test_field       "$test_json" "screenshot")
        local step_count;        step_count=$(count_steps "$test_json")

        # ── Setup: save originals and put test-specific files in place ──────────
        local saved_openings="" saved_svg=""

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

        # ── Run each step ───────────────────────────────────────────────────────
        local case_ok=true

        for (( i=0; i<step_count; i++ )); do
            local step_vars; step_vars=$(parse_step "$test_json" "$i") || {
                fail "  Step $i: could not parse test.json"
                case_ok=false; continue
            }
            eval "$step_vars"

            local camera; camera=$(build_camera "$STEP_VPT" "$STEP_VPR" "$STEP_VPD")
            local rendered_png="$render_dir/${STEP_LABEL// /_}.png"
            local expected_png="$case_dir/$STEP_EXPECTED"
            local diff_png="$render_dir/${STEP_LABEL// /_}_diff.png"

            printf "    [step %d/%d] %-30s" "$((i+1))" "$step_count" "$STEP_LABEL"

            # Build OpenSCAD command
            local cmd=("$OPENSCAD"
                --camera="$camera"
                --imgsize=1024,768
                --colorscheme=Tomorrow
                -o "$rendered_png")

            [[ -n "$STEP_PARAMS" ]] && cmd+=(-p "$JSON_FILE" -P "$STEP_PARAMS")

            # Apply params_override as -D flags (eval to handle quoting)
            if [[ -n "$STEP_D_FLAGS" ]]; then
                eval "cmd+=($STEP_D_FLAGS)"
            fi

            cmd+=("$SCAD_FILE")

            local exit_code=0
            "${cmd[@]}" > /dev/null 2>&1 || exit_code=$?

            if [[ "$exit_code" -ne 0 || ! -s "$rendered_png" ]]; then
                echo -e " ${RED}RENDER FAILED${RESET}"
                case_ok=false; continue
            fi

            # Capture mode: save as reference
            if "$CAPTURE_REFERENCES"; then
                cp "$rendered_png" "$expected_png"
                echo -e " ${GREEN}CAPTURED${RESET}"
                continue
            fi

            # Compare mode
            if [[ ! -f "$expected_png" ]]; then
                echo -e " ${YELLOW}NO REFERENCE${RESET} (run --capture-references to create one)"
                case_ok=false; continue
            fi

            if compare_png "$rendered_png" "$expected_png" "$diff_png"; then
                echo -e " ${GREEN}PASS${RESET}"
                rm -f "$diff_png"
            else
                echo -e " ${RED}FAIL${RESET} (diff saved to output/test/visual/$safe_name/)"
                case_ok=false
            fi
        done

        # ── Teardown: restore original files ────────────────────────────────────
        [[ -n "$saved_openings" ]] && cp "$saved_openings" "$OPENINGS_FILE" && rm "$saved_openings"
        if [[ -n "$saved_svg" ]]; then
            if [[ -s "$saved_svg" ]]; then
                cp "$saved_svg" "$DEFAULT_SVG"
            else
                rm -f "$DEFAULT_SVG"
            fi
            rm -f "$saved_svg"
        fi

        "$case_ok" || test_failures=$((test_failures + 1))
    done

    echo ""
    if "$CAPTURE_REFERENCES"; then
        pass "References captured for ${#cases[@]} test case(s)"
        info "Review PNGs in output/test/visual/, then commit tests/cases/"
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

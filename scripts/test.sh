#!/usr/bin/env bash
# test.sh — Multi-layer test runner for the keyguard designer
#
# Layers (run in order, or individually via flags):
#   --lint        Layer 1: sca2d static analysis (fast, no render)
#   --syntax      Layer 2: OpenSCAD --hardwarnings parse check (fast, no render)
#   --smoke       Layer 3: Render default config to STL (confirms basic geometry)
#   --regression  Layer 4: Render all named configs from keyguard.json and compare
#                           checksums against a stored baseline
#   --visual      Layer 5: Render all named configs to PNG for manual inspection
#
# Usage:
#   ./scripts/test.sh                   # Run lint + syntax + smoke (fast default)
#   ./scripts/test.sh --all             # Run all layers
#   ./scripts/test.sh --lint            # Run a single layer
#   ./scripts/test.sh --regression      # Run regression only
#   ./scripts/test.sh --lint --syntax   # Combine layers
#   ./scripts/test.sh --update-baseline # Re-render all configs and save new baseline
#
# Requirements:
#   - sca2d    (pip install sca2d)
#   - openscad (on PATH, or detected at common Windows install locations)
#   - python3  (for JSON parsing)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCAD_FILE="$PROJECT_ROOT/keyguard.scad"
JSON_FILE="$PROJECT_ROOT/keyguard.json"
OUTPUT_DIR="$PROJECT_ROOT/output/test"
BASELINE_FILE="$PROJECT_ROOT/tests/baseline.sha256"

# sca2d ignore codes:
#   User-configured: I3001 I0006 I1002 I0004 I1001 I4001 I4002 I0003 I4003
#   E2003: False positive — sca2d doesn't recognise assert() as a built-in
SCA2D_IGNORE="I3001,I0006,I1002,I0004,I1001,I4001,I4002,I0003,I4003,E2003"

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
    # 1. Check PATH first
    if command -v openscad &>/dev/null; then
        echo "openscad"; return
    fi
    # 2. Common Windows install via WSL / Git Bash
    local win_paths=(
        "/mnt/c/Program Files/OpenSCAD/openscad.exe"
        "/mnt/c/Program Files (x86)/OpenSCAD/openscad.exe"
        "/c/Program Files/OpenSCAD/openscad.exe"
    )
    for p in "${win_paths[@]}"; do
        if [[ -x "$p" ]]; then echo "$p"; return; fi
    done
    echo ""
}

find_sca2d() {
    if command -v sca2d &>/dev/null; then
        echo "sca2d"; return
    fi
    # pip --user install location
    if [[ -x "$HOME/.local/bin/sca2d" ]]; then
        echo "$HOME/.local/bin/sca2d"; return
    fi
    echo ""
}

OPENSCAD="$(find_openscad)"
SCA2D="$(find_sca2d)"

# ── Argument parsing ───────────────────────────────────────────────────────────

RUN_LINT=false; RUN_SYNTAX=false; RUN_SMOKE=false
RUN_REGRESSION=false; RUN_VISUAL=false; UPDATE_BASELINE=false

if [[ $# -eq 0 ]]; then
    # Default: fast layers only
    RUN_LINT=true; RUN_SYNTAX=true; RUN_SMOKE=true
else
    for arg in "$@"; do
        case "$arg" in
            --lint)             RUN_LINT=true ;;
            --syntax)           RUN_SYNTAX=true ;;
            --smoke)            RUN_SMOKE=true ;;
            --regression)       RUN_REGRESSION=true ;;
            --visual)           RUN_VISUAL=true ;;
            --all)              RUN_LINT=true; RUN_SYNTAX=true; RUN_SMOKE=true
                                RUN_REGRESSION=true; RUN_VISUAL=true ;;
            --update-baseline)  UPDATE_BASELINE=true; RUN_REGRESSION=true ;;
            *) echo "Unknown option: $arg"; exit 1 ;;
        esac
    done
fi

# ── Helper: list named configs from keyguard.json ─────────────────────────────

get_configs() {
    python3 -c "
import json, sys
with open('$JSON_FILE') as f:
    data = json.load(f)
for name in data.get('parameterSets', {}).keys():
    print(name)
"
}

# ── Layer 1: sca2d lint ────────────────────────────────────────────────────────

run_lint() {
    header "Layer 1 — sca2d lint"

    if [[ -z "$SCA2D" ]]; then
        warn "sca2d not found. Install with: pip install sca2d"
        warn "Skipping lint layer."
        return
    fi

    info "Running: sca2d keyguard.scad --ignore=$SCA2D_IGNORE"
    echo ""

    local output
    output=$("$SCA2D" "$SCAD_FILE" --ignore="$SCA2D_IGNORE" 2>&1 || true)
    echo "$output" | sed 's/^/    /'

    # Extract fatal error count from summary
    local fatal_count
    fatal_count=$(echo "$output" | grep -E "^Fatal errors:" | grep -oE "[0-9]+" || echo "0")

    echo ""
    if [[ "$fatal_count" -gt 0 ]]; then
        fail "sca2d found $fatal_count fatal error(s) — must be fixed before proceeding"
    else
        local err_count warn_count
        err_count=$(echo "$output"  | grep -E "^Errors:"   | grep -oE "[0-9]+" || echo "0")
        warn_count=$(echo "$output" | grep -E "^Warnings:" | grep -oE "[0-9]+" || echo "0")
        if [[ "$err_count" -gt 0 || "$warn_count" -gt 0 ]]; then
            warn "sca2d found $err_count error(s) and $warn_count warning(s) — review above"
            pass "No fatal errors (lint layer passed)"
        else
            pass "sca2d — no issues found"
        fi
    fi
}

# ── Layer 2: OpenSCAD syntax check ────────────────────────────────────────────

run_syntax() {
    header "Layer 2 — OpenSCAD syntax check"

    if [[ -z "$OPENSCAD" ]]; then
        fail "openscad not found on PATH or at common Windows locations"
        return
    fi

    info "Running: openscad --hardwarnings keyguard.scad"
    echo ""

    local output exit_code
    output=$("$OPENSCAD" --hardwarnings "$SCAD_FILE" 2>&1 || true)
    exit_code=$("$OPENSCAD" --hardwarnings "$SCAD_FILE" > /dev/null 2>&1; echo $?)

    if [[ -n "$output" ]]; then
        echo "$output" | sed 's/^/    /'
        echo ""
    fi

    if [[ "$exit_code" -ne 0 ]]; then
        fail "OpenSCAD reported errors (exit code $exit_code)"
    else
        pass "OpenSCAD syntax check — no errors"
    fi
}

# ── Layer 3: Smoke test ────────────────────────────────────────────────────────

run_smoke() {
    header "Layer 3 — Smoke test (default config render)"

    if [[ -z "$OPENSCAD" ]]; then
        fail "openscad not found — skipping smoke test"
        return
    fi

    mkdir -p "$OUTPUT_DIR"
    local out_stl="$OUTPUT_DIR/smoke_test.stl"

    info "Rendering default config to STL..."
    local output exit_code=0
    output=$("$OPENSCAD" --hardwarnings -o "$out_stl" "$SCAD_FILE" 2>&1) || exit_code=$?

    if [[ -n "$output" ]]; then
        echo "$output" | sed 's/^/    /'
    fi

    if [[ "$exit_code" -ne 0 ]]; then
        fail "Render failed (exit code $exit_code)"
    elif [[ ! -f "$out_stl" ]]; then
        fail "No STL produced"
    elif [[ ! -s "$out_stl" ]]; then
        fail "STL file is empty"
    else
        local size
        size=$(du -sh "$out_stl" | cut -f1)
        pass "Smoke test — STL produced ($size)"
    fi
}

# ── Layer 4: Regression test ──────────────────────────────────────────────────

run_regression() {
    header "Layer 4 — Regression test (all named configs)"

    if [[ -z "$OPENSCAD" ]]; then
        fail "openscad not found — skipping regression test"
        return
    fi

    mkdir -p "$OUTPUT_DIR/regression"
    mkdir -p "$(dirname "$BASELINE_FILE")"

    local configs
    mapfile -t configs < <(get_configs)
    info "Found ${#configs[@]} named configs in keyguard.json"

    if "$UPDATE_BASELINE"; then
        info "Updating baseline checksums..."
    fi

    local new_checksums=""
    local render_failures=0
    local total=${#configs[@]}
    local current=0

    for config in "${configs[@]}"; do
        current=$((current + 1))
        # Sanitise config name for use as filename
        local safe_name
        safe_name=$(echo "$config" | tr ' /' '__')
        local out_stl="$OUTPUT_DIR/regression/${safe_name}.stl"

        printf "  [%2d/%d] %-35s" "$current" "$total" "$config"

        local exit_code=0
        "$OPENSCAD" --hardwarnings \
            -p "$JSON_FILE" -P "$config" \
            -o "$out_stl" "$SCAD_FILE" > /dev/null 2>&1 || exit_code=$?

        if [[ "$exit_code" -ne 0 || ! -s "$out_stl" ]]; then
            echo -e " ${RED}RENDER FAILED${RESET}"
            render_failures=$((render_failures + 1))
            continue
        fi

        local checksum
        checksum=$(sha256sum "$out_stl" | cut -d' ' -f1)
        new_checksums+="${checksum}  ${config}"$'\n'
        echo -e " ${GREEN}OK${RESET}"
    done

    echo ""

    if [[ "$render_failures" -gt 0 ]]; then
        fail "$render_failures config(s) failed to render"
    fi

    if "$UPDATE_BASELINE"; then
        echo "$new_checksums" > "$BASELINE_FILE"
        pass "Baseline updated — ${#configs[@]} configs stored in tests/baseline.sha256"
        return
    fi

    if [[ ! -f "$BASELINE_FILE" ]]; then
        warn "No baseline found. Run with --update-baseline to create one."
        info "Storing current renders as baseline now..."
        echo "$new_checksums" > "$BASELINE_FILE"
        pass "Baseline created — ${#configs[@]} configs stored in tests/baseline.sha256"
        return
    fi

    # Compare against baseline
    local regressions=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local old_sum old_name
        old_sum=$(echo "$line" | cut -d' ' -f1)
        old_name=$(echo "$line" | cut -d' ' -f3-)
        local new_sum
        new_sum=$(echo "$new_checksums" | grep "  ${old_name}$" | cut -d' ' -f1 || echo "")
        if [[ -z "$new_sum" ]]; then
            warn "Config '$old_name' missing from new renders"
            regressions=$((regressions + 1))
        elif [[ "$old_sum" != "$new_sum" ]]; then
            fail "Regression: '$old_name' output changed"
            regressions=$((regressions + 1))
        fi
    done < "$BASELINE_FILE"

    if [[ "$regressions" -eq 0 ]]; then
        pass "Regression test — all ${#configs[@]} configs match baseline"
    fi
}

# ── Layer 5: Visual review ────────────────────────────────────────────────────

run_visual() {
    header "Layer 5 — Visual review (PNG previews)"

    if [[ -z "$OPENSCAD" ]]; then
        fail "openscad not found — skipping visual layer"
        return
    fi

    mkdir -p "$OUTPUT_DIR/visual"

    local configs
    mapfile -t configs < <(get_configs)
    local total=${#configs[@]}
    local current=0
    local failures=0

    info "Rendering ${total} configs to PNG..."

    for config in "${configs[@]}"; do
        current=$((current + 1))
        local safe_name
        safe_name=$(echo "$config" | tr ' /' '__')
        local out_png="$OUTPUT_DIR/visual/${safe_name}.png"

        printf "  [%2d/%d] %-35s" "$current" "$total" "$config"

        local exit_code=0
        "$OPENSCAD" \
            -p "$JSON_FILE" -P "$config" \
            --camera=0,0,0,55,0,25,250 \
            --imgsize=512,384 \
            --colorscheme=Tomorrow \
            -o "$out_png" "$SCAD_FILE" > /dev/null 2>&1 || exit_code=$?

        if [[ "$exit_code" -ne 0 || ! -s "$out_png" ]]; then
            echo -e " ${RED}FAILED${RESET}"
            failures=$((failures + 1))
        else
            echo -e " ${GREEN}OK${RESET}"
        fi
    done

    echo ""
    if [[ "$failures" -gt 0 ]]; then
        fail "$failures PNG render(s) failed"
    else
        pass "Visual renders complete — PNGs in output/test/visual/"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

cd "$PROJECT_ROOT"

echo -e "${BOLD}Keyguard Designer — Test Suite${RESET}"
echo    "==============================="
info "Project root: $PROJECT_ROOT"
info "OpenSCAD:     ${OPENSCAD:-NOT FOUND}"
info "sca2d:        ${SCA2D:-NOT FOUND}"

"$RUN_LINT"       && run_lint
"$RUN_SYNTAX"     && run_syntax
"$RUN_SMOKE"      && run_smoke
"$RUN_REGRESSION" && run_regression
"$RUN_VISUAL"     && run_visual

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "==============================="
if [[ "$FAILURES" -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}All tests passed.${RESET}"
    exit 0
else
    echo -e "${RED}${BOLD}$FAILURES test(s) failed.${RESET}"
    exit 1
fi

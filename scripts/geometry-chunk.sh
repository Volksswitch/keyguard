#!/usr/bin/env bash
# geometry-chunk.sh — run one chunk of the golden geometry validation.
#
# The full `test.sh --geometry` suite is 154 CGAL renders (~10 h of wall time).
# This splits it into 9 balanced chunks so the work can run on several machines
# AT THE SAME TIME.
#
# Why chunks are independent across machines:
#   --geometry only READS the committed golden manifest
#   (tests/cases/golden-stl-stats.json) and diffs each render against it. It
#   never writes the manifest. So every chunk is self-contained — there is
#   NOTHING to merge afterwards. Each machine only needs its own up-to-date
#   checkout of `main`; results are per-machine.
#
# Usage (on each machine):
#   git pull                            # get the gate + this plan
#   ./scripts/geometry-chunk.sh list    # show the plan
#   ./scripts/geometry-chunk.sh 3       # run chunk 3 on this machine
#
# Assign a different chunk number to each machine (or several chunks to a fast
# one). A chunk PASSES if every config prints OK — i.e. no DRIFT, NON-MANIFOLD,
# or RENDER FAILED. Per-config progress streams to golden-stl-stats-progress.log
# (project root, tail -f friendly).
#
# Chunk plan — balanced by the May-2026 full-run render times. Every test-case
# folder (0-57 plus the "17 portrait" and "44-1/2/3" variants) is covered
# exactly once. Range filters only match numeric "Test Case N", so the
# non-numeric variant folders are listed explicitly with the | alternation.
#
#   #  --case filter                                              ~min
#   1  Test Case 0-8                                               70
#   2  Test Case 9-12                                              90
#   3  Test Case 13-18 | Test Case 17 portrait                     55
#   4  Test Case 19-23                                             84
#   5  Test Case 24-33                                             67
#   6  Test Case 34-37                                             82
#   7  Test Case 38-46 | Test Case 44-1 | 44-2 | 44-3              78
#   8  Test Case 47-55                                             51
#   9  Test Case 56-57                                             42
#
# Heavy single cases (TC12, TC23, TC37, TC46, TC56) dominate their chunks; the
# per-config render timeout can be raised with KEYGUARD_GOLDEN_TIMEOUT if needed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# chunk number -> --case filter (single source of truth)
chunk_filter() {
  case "$1" in
    1) echo "Test Case 0-8" ;;
    2) echo "Test Case 9-12" ;;
    3) echo "Test Case 13-18|Test Case 17 portrait" ;;
    4) echo "Test Case 19-23" ;;
    5) echo "Test Case 24-33" ;;
    6) echo "Test Case 34-37" ;;
    7) echo "Test Case 38-46|Test Case 44-1|Test Case 44-2|Test Case 44-3" ;;
    8) echo "Test Case 47-55" ;;
    9) echo "Test Case 56-57" ;;
    *) return 1 ;;
  esac
}

if [[ "${1:-}" == "list" || "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]]; then
  echo "Geometry validation chunks (run different chunks on different machines simultaneously):"
  for i in 1 2 3 4 5 6 7 8 9; do printf "  %d  %s\n" "$i" "$(chunk_filter "$i")"; done
  echo
  echo "  ./scripts/geometry-chunk.sh <n>   run chunk n (validates against the committed golden)"
  exit 0
fi

filter="$(chunk_filter "$1")" || { echo "Unknown chunk '$1' — see: ./scripts/geometry-chunk.sh list" >&2; exit 1; }
echo "Chunk $1 → test.sh --geometry --case \"$filter\""
exec "$SCRIPT_DIR/test.sh" --geometry --case "$filter"

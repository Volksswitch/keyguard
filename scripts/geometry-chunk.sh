#!/usr/bin/env bash
# geometry-chunk.sh - run one chunk of the golden geometry validation and PERSIST
# its pass/fail result so it is visible across machines (via the OneDrive folder).
#
# The full `test.sh --geometry` suite is 154 CGAL renders. This splits it into 9
# chunks. Each run records a result file under geometry-chunk-results/ so the
# pass/fail of every chunk is retained (the live golden-stl-stats-progress.log is
# truncated by every run, so on its own it only ever shows the LAST chunk).
#
# Results (in <project>/geometry-chunk-results/, which is inside the OneDrive
# folder, so both machines + any Claude session can read them):
#   chunk-<N>.result        key=value summary: status, counts, host, timestamp
#   chunk-<N>.progress.log  the per-config log for that chunk (preserved)
#
# Usage:
#   ./scripts/geometry-chunk.sh list      show the chunk plan
#   ./scripts/geometry-chunk.sh <n>       run chunk n and record its result
#   ./scripts/geometry-chunk.sh status    print the recorded pass/fail ledger
#
# IMPORTANT - shared OneDrive folder: a geometry run swaps openings_and_additions.txt,
# takes a lock, and rewrites golden-stl-stats-progress.log. Do NOT run two geometry
# chunks at the same time against the SAME OneDrive copy (e.g. laptop AND desktop) -
# they will collide. Run chunks sequentially on ONE machine, or give each machine an
# independent local clone. The per-chunk result files are distinct, so sequential
# runs (even alternating machines, one at a time) accumulate cleanly.
#
# Chunk plan (ranges only match numeric "Test Case N"; variant folders listed
# explicitly). Times below are pre-gate-off estimates; actual gate-off runs are
# roughly 2.5x faster.
#
#   #  --case filter                                              ~min (gate-on est.)
#   1  Test Case 0-8                                               70
#   2  Test Case 9-12                                              90
#   3  Test Case 13-18 | Test Case 17 portrait                     55
#   4  Test Case 19-23                                             84
#   5  Test Case 24-33                                             67
#   6  Test Case 34-37                                             82
#   7  Test Case 38-46 | Test Case 44-1 | 44-2 | 44-3              78
#   8  Test Case 47-55                                             51
#   9  Test Case 56-57                                             42
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESULTS="$ROOT/geometry-chunk-results"
PROG="$ROOT/golden-stl-stats-progress.log"

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

cmd="${1:-list}"

if [[ "$cmd" == "list" || "$cmd" == "-h" || "$cmd" == "--help" ]]; then
  echo "Geometry validation chunks:"
  for i in 1 2 3 4 5 6 7 8 9; do printf "  %d  %s\n" "$i" "$(chunk_filter "$i")"; done
  echo
  echo "  ./scripts/geometry-chunk.sh <n>       run chunk n and record pass/fail"
  echo "  ./scripts/geometry-chunk.sh status    show recorded results"
  exit 0
fi

if [[ "$cmd" == "status" ]]; then
  echo "Geometry chunk results ($RESULTS):"
  printf "  %-5s %-6s %-8s %-6s %-7s %-7s %-20s %s\n" chunk status configs drift nonman failed host when
  any=0
  get() { grep -E "^$2=" "$1" | head -1 | cut -d= -f2-; }
  for n in 1 2 3 4 5 6 7 8 9; do
    f="$RESULTS/chunk-$n.result"
    [[ -f "$f" ]] || continue
    any=1
    printf "  %-5s %-6s %-8s %-6s %-7s %-7s %-20s %s\n" \
      "$n" "$(get "$f" status)" "$(get "$f" configs)" "$(get "$f" drift)" \
      "$(get "$f" nonmanifold)" "$(get "$f" failed)" "$(get "$f" host)" "$(get "$f" timestamp)"
  done
  if [[ "$any" == 0 ]]; then echo "  (no chunk results recorded yet)"; fi
  exit 0
fi

# ---- run a chunk ----
N="$cmd"
filter="$(chunk_filter "$N")" || { echo "Unknown chunk '$N' - see: ./scripts/geometry-chunk.sh list" >&2; exit 1; }
mkdir -p "$RESULTS"
echo "Chunk $N -> test.sh --geometry --case \"$filter\""
rc=0
bash "$SCRIPT_DIR/test.sh" --geometry --case "$filter" || rc=$?

configs=0; drift=0; nonman=0; failed=0
if [[ -f "$PROG" ]]; then
  cp "$PROG" "$RESULTS/chunk-$N.progress.log"
  configs=$(wc -l < "$RESULTS/chunk-$N.progress.log" | tr -d ' ')
  drift=$(grep -c 'DRIFT' "$RESULTS/chunk-$N.progress.log"); drift=${drift:-0}
  nonman=$(grep -c 'NON-MANIFOLD' "$RESULTS/chunk-$N.progress.log"); nonman=${nonman:-0}
  failed=$(grep -cE 'RENDER FAILED|STATS FAILED' "$RESULTS/chunk-$N.progress.log"); failed=${failed:-0}
fi
status=PASS
if [[ "$rc" -ne 0 || "$drift" -ne 0 || "$nonman" -ne 0 || "$failed" -ne 0 ]]; then status=FAIL; fi

{
  echo "chunk=$N"
  echo "filter=$filter"
  echo "host=$(hostname)"
  echo "timestamp=$(date '+%Y-%m-%d %H:%M:%S')"
  echo "exit=$rc"
  echo "status=$status"
  echo "configs=$configs"
  echo "drift=$drift"
  echo "nonmanifold=$nonman"
  echo "failed=$failed"
} > "$RESULTS/chunk-$N.result"

echo ""
echo "Chunk $N: $status  (configs=$configs drift=$drift nonman=$nonman failed=$failed, exit=$rc)"
echo "Recorded -> $RESULTS/chunk-$N.result   (run './scripts/geometry-chunk.sh status' to see all)"
exit "$rc"

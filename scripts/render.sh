#!/usr/bin/env bash
# render.sh — Render one or all .scad files to STL
#
# Usage:
#   ./scripts/render.sh                   # Render all .scad files in project root
#   ./scripts/render.sh enclosure.scad    # Render a specific file
#   ./scripts/render.sh enclosure.scad -D 'wall=3'   # Render with parameter overrides
#
# Output: STL files are written to ./output/stl/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/output/stl"

# Check that openscad is available
if ! command -v openscad &>/dev/null; then
  echo "ERROR: 'openscad' not found on PATH."
  echo "Install from https://openscad.org/downloads.html"
  echo "On macOS: brew install openscad"
  echo "On Ubuntu/Debian: sudo apt install openscad"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

render_file() {
  local scad_file="$1"
  shift
  local extra_args=("$@")

  local base
  base="$(basename "$scad_file" .scad)"
  local out_file="$OUTPUT_DIR/${base}.stl"

  echo "Rendering: $scad_file  →  $out_file"
  openscad --hardwarnings "${extra_args[@]}" -o "$out_file" "$scad_file" 2>&1 \
    | grep -v "^$" \
    | sed 's/^/  /'

  if [[ -f "$out_file" ]]; then
    local size
    size=$(du -sh "$out_file" | cut -f1)
    echo "  ✓ OK  ($size)"
  else
    echo "  ✗ FAILED — no output produced"
    exit 1
  fi
}

# --- Main ---

if [[ $# -ge 1 && -f "$PROJECT_ROOT/$1" ]]; then
  # Specific file provided
  target="$PROJECT_ROOT/$1"
  shift
  render_file "$target" "$@"
else
  # Render all .scad files in project root (not recursively, to avoid rendering lib files)
  shopt -s nullglob
  scad_files=("$PROJECT_ROOT"/*.scad)

  if [[ ${#scad_files[@]} -eq 0 ]]; then
    echo "No .scad files found in $PROJECT_ROOT"
    exit 1
  fi

  echo "Rendering ${#scad_files[@]} file(s) to $OUTPUT_DIR"
  echo ""
  for f in "${scad_files[@]}"; do
    render_file "$f"
  done
fi

echo ""
echo "Done. STL files are in: $OUTPUT_DIR"

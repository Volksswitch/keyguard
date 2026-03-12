#!/usr/bin/env bash
# preview.sh — Render one or all .scad files to PNG for quick visual inspection
#
# Usage:
#   ./scripts/preview.sh                   # Preview all .scad files in project root
#   ./scripts/preview.sh enclosure.scad    # Preview a specific file
#   ./scripts/preview.sh enclosure.scad --camera=0,0,0,45,0,45,300
#
# Output: PNG files are written to ./output/preview/
#
# Camera format: translateX,Y,Z,rotateX,Y,Z,distance
# Handy camera angles:
#   Front:         0,0,0,90,0,0,200
#   Top:           0,0,0,0,0,0,200
#   Isometric:     0,0,0,55,0,25,200   (default)
#   Front-right:   0,0,0,70,0,45,200

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/output/preview"

# Default render settings (override via CLI args)
CAMERA="0,0,0,55,0,25,200"
IMG_SIZE="1024,768"
COLOR_SCHEME="Tomorrow"

# Check that openscad is available
if ! command -v openscad &>/dev/null; then
  echo "ERROR: 'openscad' not found on PATH."
  echo "Install from https://openscad.org/downloads.html"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

preview_file() {
  local scad_file="$1"
  shift
  local extra_args=("$@")

  # Extract any --camera arg from extra_args
  local camera="$CAMERA"
  for arg in "${extra_args[@]}"; do
    if [[ "$arg" == --camera=* ]]; then
      camera="${arg#--camera=}"
    fi
  done

  local base
  base="$(basename "$scad_file" .scad)"
  local out_file="$OUTPUT_DIR/${base}.png"

  echo "Previewing: $scad_file  →  $out_file"
  openscad \
    --hardwarnings \
    --camera="$camera" \
    --imgsize="$IMG_SIZE" \
    --colorscheme="$COLOR_SCHEME" \
    -o "$out_file" \
    "$scad_file" 2>&1 \
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
  preview_file "$target" "$@"
else
  # Preview all .scad files in project root
  shopt -s nullglob
  scad_files=("$PROJECT_ROOT"/*.scad)

  if [[ ${#scad_files[@]} -eq 0 ]]; then
    echo "No .scad files found in $PROJECT_ROOT"
    exit 1
  fi

  echo "Previewing ${#scad_files[@]} file(s) — camera: $CAMERA"
  echo ""
  for f in "${scad_files[@]}"; do
    preview_file "$f"
  done
fi

echo ""
echo "Done. PNG previews are in: $OUTPUT_DIR"
echo ""
echo "To open all previews (macOS):"
echo "  open $OUTPUT_DIR/*.png"
echo ""
echo "To open all previews (Linux with eog):"
echo "  eog $OUTPUT_DIR/*.png"

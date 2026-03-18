#!/usr/bin/env python3
"""
compare_png.py — Compare two PNG files and report RMSE.

Usage: python compare_png.py <rendered.png> <expected.png> [threshold]
  threshold  RMSE threshold for pass (default: 5.0)

Exits 0 (same / within threshold) or 1 (different / above threshold).
Uses only Python stdlib — no Pillow/numpy required.
"""

import sys
import struct
import zlib


def decode_png_pixels(path):
    """Return (width, height, channels, bytearray-of-pixels) from a PNG file."""
    with open(path, 'rb') as f:
        data = f.read()

    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f"Not a PNG file: {path}")

    pos = 8
    width = height = bit_depth = color_type = 0
    idat_chunks = []

    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        if chunk_type == b'IHDR':
            width, height = struct.unpack('>II', chunk_data[:8])
            bit_depth = chunk_data[8]
            color_type = chunk_data[9]
        elif chunk_type == b'IDAT':
            idat_chunks.append(chunk_data)
        elif chunk_type == b'IEND':
            break
        pos += 12 + length

    if bit_depth != 8:
        raise ValueError(f"Only 8-bit PNG supported, got {bit_depth}-bit")

    # channels per pixel
    channels = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}.get(color_type, 3)

    raw = zlib.decompress(b''.join(idat_chunks))
    stride = width * channels  # bytes per row (excluding filter byte)

    pixels = bytearray()
    prev = bytearray(stride)

    for y in range(height):
        row_start = y * (stride + 1)
        f = raw[row_start]
        row = bytearray(raw[row_start+1 : row_start+1+stride])

        if f == 1:    # Sub
            for i in range(channels, stride):
                row[i] = (row[i] + row[i - channels]) & 0xFF
        elif f == 2:  # Up
            for i in range(stride):
                row[i] = (row[i] + prev[i]) & 0xFF
        elif f == 3:  # Average
            for i in range(stride):
                a = row[i - channels] if i >= channels else 0
                row[i] = (row[i] + (a + prev[i]) // 2) & 0xFF
        elif f == 4:  # Paeth
            for i in range(stride):
                a = row[i - channels] if i >= channels else 0
                b = prev[i]
                c = prev[i - channels] if i >= channels else 0
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2*c)
                paeth = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                row[i] = (row[i] + paeth) & 0xFF

        pixels.extend(row)
        prev = row

    return width, height, channels, pixels


def rmse(pix1, pix2):
    if len(pix1) != len(pix2):
        return float('inf')
    total = sum((int(a) - int(b)) ** 2 for a, b in zip(pix1, pix2))
    return (total / len(pix1)) ** 0.5


def main():
    if len(sys.argv) < 3:
        print("Usage: compare_png.py <rendered> <expected> [threshold]", file=sys.stderr)
        sys.exit(2)

    rendered_path = sys.argv[1]
    expected_path = sys.argv[2]
    threshold = float(sys.argv[3]) if len(sys.argv) > 3 else 5.0

    try:
        w1, h1, c1, pix1 = decode_png_pixels(rendered_path)
        w2, h2, c2, pix2 = decode_png_pixels(expected_path)
    except Exception as e:
        print(f"Error reading PNG: {e}", file=sys.stderr)
        sys.exit(2)

    if w1 != w2 or h1 != h2 or c1 != c2:
        print(f"999.0")
        sys.exit(1)

    score = rmse(pix1, pix2)
    print(f"{score:.4f}")
    sys.exit(0 if score <= threshold else 1)


if __name__ == '__main__':
    main()

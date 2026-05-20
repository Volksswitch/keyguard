#!/usr/bin/env python3
# compute_stl_stats.py — compute geometric stats from an STL file.
#
# Used by the golden-STL regression gate. Reads binary or ASCII STL,
# emits a JSON record with volume, surface area, bounding box, part count,
# and facet count. The same computation runs on the web app side (see
# keyguard-designer-web/tests/lib/stl-stats.mjs) so both pipelines produce
# directly comparable numbers.
#
# Volume uses the signed-tetrahedron formula (sum of (1/6) v1 . (v2 x v3)),
# which is exact for a 2-manifold mesh and produces a small non-zero delta
# for non-manifold artefacts like TC57's membranes — which is precisely
# what surface_area also catches and what we need the gate to detect.
#
# Parts uses union-find over quantised shared edges (4-decimal precision,
# which matches the float resolution OpenSCAD writes to STL).
#
# Usage:  python3 compute_stl_stats.py <path/to/file.stl>
# Output: one JSON object on stdout: {"volume_mm3":..., "surface_area_mm2":...,
#           "bbox":[x0,y0,z0,x1,y1,z1], "parts":N, "facets":M}

import json
import struct
import sys
from pathlib import Path


def _read_triangles(data: bytes):
    """Yield (v1, v2, v3) tuples where each v is (x, y, z) floats."""
    # ASCII STL starts with "solid" and contains "facet normal" lines.
    # Binary STL is identified by its 84-byte header + facet count layout;
    # the "solid " prefix is not reliable (binary files may also start with it).
    is_ascii = False
    if data[:5] == b"solid":
        # Differentiate: binary files have exactly 84 + 50*n bytes;
        # if the total matches the count in the header, treat as binary.
        if len(data) >= 84:
            n = struct.unpack("<I", data[80:84])[0]
            if 84 + 50 * n == len(data):
                is_ascii = False
            else:
                is_ascii = True
        else:
            is_ascii = True

    if is_ascii:
        text = data.decode("utf-8", errors="replace")
        verts = []
        for line in text.splitlines():
            s = line.strip()
            if s.startswith("vertex"):
                parts = s.split()
                verts.append((float(parts[1]), float(parts[2]), float(parts[3])))
                if len(verts) == 3:
                    yield tuple(verts)
                    verts = []
    else:
        n = struct.unpack("<I", data[80:84])[0]
        off = 84
        for _ in range(n):
            # 12 floats: normal(3) + v1(3) + v2(3) + v3(3), then 2-byte attr
            f = struct.unpack("<12f", data[off + 0 : off + 48])
            yield ((f[3],  f[4],  f[5]),
                   (f[6],  f[7],  f[8]),
                   (f[9],  f[10], f[11]))
            off += 50


def compute_stats(stl_path: Path) -> dict:
    data = Path(stl_path).read_bytes()

    volume = 0.0
    area = 0.0
    bx0 = by0 = bz0 = float("inf")
    bx1 = by1 = bz1 = float("-inf")
    n_facets = 0

    # For parts: union-find over triangle indices, joined via shared edges.
    # Quantise vertex coords to 1e-4 mm to absorb float-write rounding.
    QUANT = 10000.0
    def qk(v):
        return (int(round(v[0] * QUANT)),
                int(round(v[1] * QUANT)),
                int(round(v[2] * QUANT)))

    parent = []
    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i
    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    edge_owner = {}  # edge_key -> first triangle index seen

    for v1, v2, v3 in _read_triangles(data):
        idx = n_facets
        n_facets += 1
        parent.append(idx)

        # Volume: signed tetrahedron from origin.
        volume += (v1[0] * (v2[1] * v3[2] - v2[2] * v3[1])
                 + v1[1] * (v2[2] * v3[0] - v2[0] * v3[2])
                 + v1[2] * (v2[0] * v3[1] - v2[1] * v3[0])) / 6.0

        # Surface area: 0.5 * |cross(v2-v1, v3-v1)|
        a1, a2, a3 = v2[0] - v1[0], v2[1] - v1[1], v2[2] - v1[2]
        b1, b2, b3 = v3[0] - v1[0], v3[1] - v1[1], v3[2] - v1[2]
        c1 = a2 * b3 - a3 * b2
        c2 = a3 * b1 - a1 * b3
        c3 = a1 * b2 - a2 * b1
        area += 0.5 * (c1 * c1 + c2 * c2 + c3 * c3) ** 0.5

        # Bbox
        for v in (v1, v2, v3):
            if v[0] < bx0: bx0 = v[0]
            if v[1] < by0: by0 = v[1]
            if v[2] < bz0: bz0 = v[2]
            if v[0] > bx1: bx1 = v[0]
            if v[1] > by1: by1 = v[1]
            if v[2] > bz1: bz1 = v[2]

        # Parts: register each edge; on second visit, union the two triangles.
        k1, k2, k3 = qk(v1), qk(v2), qk(v3)
        for ea, eb in ((k1, k2), (k2, k3), (k3, k1)):
            edge = (ea, eb) if ea < eb else (eb, ea)
            other = edge_owner.get(edge)
            if other is None:
                edge_owner[edge] = idx
            else:
                union(idx, other)

    if n_facets == 0:
        return {
            "volume_mm3": 0.0, "surface_area_mm2": 0.0,
            "bbox": [0, 0, 0, 0, 0, 0], "parts": 0, "facets": 0,
        }

    roots = {find(i) for i in range(n_facets)}
    return {
        "volume_mm3":       round(abs(volume), 4),
        "surface_area_mm2": round(area, 4),
        "bbox":             [round(bx0, 4), round(by0, 4), round(bz0, 4),
                             round(bx1, 4), round(by1, 4), round(bz1, 4)],
        "parts":            len(roots),
        "facets":           n_facets,
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.stderr.write("usage: compute_stl_stats.py <file.stl>\n")
        sys.exit(2)
    stats = compute_stats(Path(sys.argv[1]))
    print(json.dumps(stats))

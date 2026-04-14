#!/usr/bin/env python3
"""
Converts v2 openings files from explicit-undef format to compact format.

In the explicit format every row has 14 columns for screen/case/tablet openings
(or 9 columns for case_additions), with unused columns written as 'undef'.

In the compact format unused columns are simply omitted, and the shape determines
which positional fields are present.  Compact layouts:

  Screen/case/tablet openings:
    "r"/rr/r1-r4/rr2/rr4: [ID, shape, h, w, corner(explicit!), x, y, {cb}, {"c"}, {"b"}, [es], [sp]]
    "c":                   [ID, "c",   h, 0,                    x, y, {cb},        {"b"}, [es], [sp]]
    "hd":                  [ID, "hd",  h, w,                    x, y, {cb}, {"c"}, {"b"}, [es], [sp]]
    "bump":                [ID, "bump",h, x, y,                                            [es], [sp]]
    "vridge"/"hridge":     [ID, shape, x, y, cb, len, thickness,                           [es], [sp]]
    "text":                [ID, "text",h, z_pos,                x, y,        {"b"},        [es], [sp]]
    "svg":                 [ID, "svg", h, w, rotation,          x, y,                     [es], [sp]]
    (fallback/unknown):    row kept unchanged

  Case additions:
    [ID, shape, h, w, corner(explicit!), x, y, {cb}, [trim]]

Usage:
    python3 scripts/convert_v2_compact.py          # convert all v2 openings files
    python3 scripts/convert_v2_compact.py FILE...  # convert specific files
"""

import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def split_top_level(s):
    """Split string s by commas not inside brackets. Returns list of strings."""
    elements = []
    depth = 0
    current = []
    in_string = False
    escape = False
    for c in s:
        if escape:
            current.append(c)
            escape = False
        elif c == '\\' and in_string:
            current.append(c)
            escape = True
        elif c == '"' and not in_string:
            in_string = True
            current.append(c)
        elif c == '"' and in_string:
            in_string = False
            current.append(c)
        elif in_string:
            current.append(c)
        elif c in '([':
            depth += 1
            current.append(c)
        elif c in ')]':
            depth -= 1
            current.append(c)
        elif c == ',' and depth == 0:
            elements.append(''.join(current))
            current = []
        else:
            current.append(c)
    if current:
        elements.append(''.join(current))
    return elements


def is_undef(v):
    return v.strip() == 'undef'


def fmt(parts):
    """Format a list of parts as a compact row string (no outer brackets)."""
    return ', '.join(str(p).strip() for p in parts)


# ---------------------------------------------------------------------------
# Row converters
# ---------------------------------------------------------------------------

def convert_opening_row(parts):
    """
    Convert a 14-element screen/case/tablet opening row to compact format.
    Returns a list of string parts, or None if the shape is unknown/unchanged.
    """
    if len(parts) != 14:
        return None

    ID        = parts[0].strip()
    shape_q   = parts[1].strip()          # includes surrounding quotes, e.g. "r"
    shape     = shape_q.strip('"')
    h         = parts[2].strip()
    w         = parts[3].strip()
    corner    = parts[4].strip()
    x         = parts[5].strip()
    y         = parts[6].strip()
    cb        = parts[7].strip()
    anchor    = parts[8].strip()
    surface   = parts[9].strip()
    length    = parts[10].strip()
    thickness = parts[11].strip()
    es        = parts[12].strip()
    sp        = parts[13].strip()

    def keep(v):
        return not is_undef(v)

    if shape in ('r', 'rr', 'r1', 'r2', 'r3', 'r4', 'rr2', 'rr4'):
        # r-type: corner always explicit (0 if was undef)
        c_out = '0' if is_undef(corner) else corner
        new = [ID, shape_q, h, w, c_out, x, y]
        if keep(cb):      new.append(cb)
        if keep(anchor):  new.append(anchor)
        if keep(surface): new.append(surface)
        new += [es, sp]

    elif shape == 'c':
        # circle: no corner; w always 0
        new = [ID, shape_q, h, '0', x, y]
        if keep(cb):      new.append(cb)
        if keep(surface): new.append(surface)
        new += [es, sp]

    elif shape == 'hd':
        # half-disk: no corner
        new = [ID, shape_q, h, w, x, y]
        if keep(cb):      new.append(cb)
        if keep(anchor):  new.append(anchor)
        if keep(surface): new.append(surface)
        new += [es, sp]

    elif shape == 'bump':
        # bump: only h, x, y
        new = [ID, shape_q, h, x, y, es, sp]

    elif shape in ('vridge', 'hridge'):
        # vridge/hridge: x, y, cb, length, thickness (no h, no corner)
        new = [ID, shape_q, x, y, cb, length, thickness, es, sp]

    elif shape == 'text':
        # text: h, z_pos (= corner), x, y, optional surface
        # corner holds the z-position (= cut/build) for text shapes;
        # the cb field in explicit format is a redundant duplicate — drop it.
        new = [ID, shape_q, h, corner, x, y]
        if keep(surface): new.append(surface)
        new += [es, sp]

    elif shape == 'svg':
        # svg: h, w, rotation (= corner), x, y
        # cb in explicit format is a redundant duplicate of corner — drop it.
        new = [ID, shape_q, h, w, corner, x, y, es, sp]

    else:
        return None  # unknown shape — leave unchanged

    return new


def convert_case_addition_row(parts):
    """
    Convert a 9-element case_additions row to compact format.
    Returns a list of string parts, or None if the element count is unexpected.
    """
    if len(parts) != 9:
        return None

    ID      = parts[0].strip()
    shape_q = parts[1].strip()
    h       = parts[2].strip()
    w       = parts[3].strip()
    corner  = parts[4].strip()
    x       = parts[5].strip()
    y       = parts[6].strip()
    cb      = parts[7].strip()
    trim    = parts[8].strip()

    # corner always explicit (0 if was undef)
    c_out = '0' if is_undef(corner) else corner
    new = [ID, shape_q, h, w, c_out, x, y]
    if not is_undef(cb):
        new.append(cb)
    new.append(trim)
    return new


# ---------------------------------------------------------------------------
# Line-level processing
# ---------------------------------------------------------------------------

# Context tags for the four vector types
OPENING_TAGS = {'screen_openings', 'case_openings', 'tablet_openings'}
ADDITION_TAG  = 'case_additions'
ALL_TAGS = OPENING_TAGS | {ADDITION_TAG}


def find_bracket_end(line, start):
    """Find the index of the closing ']' that matches the '[' at `start`."""
    depth = 0
    in_string = False
    escape = False
    for i in range(start, len(line)):
        c = line[i]
        if escape:
            escape = False
            continue
        if c == '\\' and in_string:
            escape = True
            continue
        if c == '"' and not in_string:
            in_string = True
            continue
        if c == '"' and in_string:
            in_string = False
            continue
        if in_string:
            continue
        if c == '[':
            depth += 1
        elif c == ']':
            depth -= 1
            if depth == 0:
                return i
    return -1


def process_line(line, context):
    """
    Try to convert a single row line in the given context.
    context: 'opening' or 'addition' or None
    Returns the (possibly converted) line, preserving trailing content.
    """
    stripped = line.rstrip('\n\r')
    # Find the opening '[' of the row (skip leading whitespace / comments)
    m = re.match(r'^(\s*)(\[)', stripped)
    if not m:
        return line
    indent = m.group(1)
    bstart = m.start(2)

    end = find_bracket_end(stripped, bstart)
    if end == -1:
        return line  # no matching ']' — leave unchanged

    content  = stripped[bstart+1:end]
    suffix   = stripped[end+1:]  # trailing text (comma, comment, etc.)

    parts = split_top_level(content)

    # Decide which converter to use
    if context == 'opening':
        new_parts = convert_opening_row(parts)
    elif context == 'addition':
        new_parts = convert_case_addition_row(parts)
    else:
        new_parts = None

    if new_parts is None:
        return line  # unchanged

    new_line = f"{indent}[{fmt(new_parts)}]{suffix}\n"
    return new_line


def convert_file(path):
    """Convert a single v2 openings file in-place."""
    text = path.read_text(encoding='utf-8')
    lines = text.splitlines(keepends=True)

    context = None  # 'opening', 'addition', or None
    out_lines = []

    for line in lines:
        stripped_line = line.strip()

        # Update context when we enter a known vector assignment
        for tag in ALL_TAGS:
            # Match lines like: `screen_openings=[` or `case_openings = [`
            # or `case_additions=[` possibly with preceding code
            if re.search(r'\b' + re.escape(tag) + r'\s*=', line):
                context = 'opening' if tag in OPENING_TAGS else 'addition'
                break

        # Reset context after the closing `];` of a vector
        # (heuristic: a line that is just `];` or ends with `];`)
        if re.search(r'\]\s*;', line) and context is not None:
            out_lines.append(line)
            context = None
            continue

        # Process row lines
        if context is not None and stripped_line.startswith('['):
            # Skip comment rows
            comment_m = re.match(r'^\s*//', line)
            if not comment_m:
                line = process_line(line, context)

        out_lines.append(line)

    path.write_text(''.join(out_lines), encoding='utf-8')
    print(f"  Converted: {path}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def find_v2_files(root):
    """Find all V2 openings files (detected by V2 row format, not oa_version declaration)."""
    files = []
    for p in sorted(root.rglob('openings_and_additions.txt')):
        try:
            text = p.read_text(encoding='utf-8', errors='replace')
            # V2 files have rows where the second field is a quoted shape name, e.g. "r", "c".
            if re.search(r'\[\s*[^,\[\]]+\s*,\s*"[a-z]', text):
                files.append(p)
        except Exception:
            pass
    return files


def main():
    root = Path(__file__).parent.parent  # project root

    if len(sys.argv) > 1:
        targets = [Path(a) for a in sys.argv[1:]]
    else:
        targets = find_v2_files(root)

    if not targets:
        print('No v2 openings files found.')
        return

    print(f'Converting {len(targets)} file(s)...')
    for p in targets:
        try:
            convert_file(p)
        except Exception as e:
            print(f'  ERROR in {p}: {e}')
            raise

    print('Done.')


if __name__ == '__main__':
    main()

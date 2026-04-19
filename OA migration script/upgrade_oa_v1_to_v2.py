#!/usr/bin/env python3
from __future__ import annotations

import argparse
import concurrent.futures
import os
import re
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


def _center_cell(value: str, width: int) -> str:
    value = value or ""
    if width <= len(value):
        return value
    pad = width - len(value)
    left = pad // 2
    right = pad - left
    return (" " * left) + value + (" " * right)


def _render_comment_table(title: str, rows: list[list[str]]) -> str:
    col_count = max(len(r) for r in rows)
    normalized = [r + [""] * (col_count - len(r)) for r in rows]
    widths = [max(len(row[i]) for row in normalized) for i in range(col_count)]
    lines = [title]
    for row in normalized:
        rendered = []
        for i, cell in enumerate(row):
            if i == 0:
                rendered.append(cell.ljust(widths[i]))
            else:
                rendered.append(_center_cell(cell, widths[i]))
        lines.append("  " + "  ".join(rendered).rstrip())
    return "\n".join(lines)


def build_standard_footer() -> str:
    region_rows = [
        ["Shape", "height", "width", "corner", "cut | build", "anchor", "surface", "length", "thickness", "[edge slopes]", "[special params]"],
        ["r", "x", "x", "x", "x", "x", "x", "", "", "x", ""],
        ["c", "x", "", "", "x", "", "x", "", "", "x", ""],
        ["hd", "x", "x", "", "x", "x", "x", "", "", "x", ""],
        ["oa1–4", "", "", "x", "x", "", "", "", "", "", ""],
        ["text", "x", "", "", "x", "", "x", "", "", "", "x"],
        ["svg", "x", "x", "", "x", "", "", "", "", "", "x"],
        ["bump", "x", "", "", "", "", "", "", "", "", ""],
        ["ridge", "", "", "", "x", "x", "", "x", "x", "", "x"],
        ["hridge", "", "", "", "x", "x", "", "x", "x", "", ""],
        ["vridge", "", "", "", "x", "x", "", "x", "x", "", ""],
        ["cridge", "x", "", "", "x", "", "", "", "x", "", ""],
        ["rridge", "x", "x", "x", "x", "x", "", "", "x", "", ""],
        ["aridge1–4", "", "", "", "x", "", "", "", "x", "", ""],
    ]

    case_addition_rows = [
        ["Shape", "height", "width", "corner", "cut | build", "[trim]"],
        ["r", "x", "x", "x", "x", "x"],
        ["c", "x", "", "", "x", "x"],
        ["r1–4", "x", "x", "x", "x", "x"],
        ["tab1–4", "x", "x", "x", "x", "x"],
        ["cm1–4", "x", "x", "", "x", "x"],
        ["t1–4", "x", "x", "", "x", "x"],
        ["f1–4", "x", "x", "x", "x", "x"],
        ["oa1–4", "", "", "x", "", ""],
        ["ped1–4", "", "", "", "", ""],
    ]

    parts = [
        "/*********** Column Usage",
        "  All shapes require values in the x and y columns.",
        "",
        _render_comment_table("** Screen, Case, Tablet Openings", region_rows),
        "",
        "  [special params]  Contents",
        '  text              ["text value", direction, font style, h-align, v-align]',
        '  svg               ["filename", direction]',
        "  ridge             [direction]",
        "",
        _render_comment_table("** Case Additions", case_addition_rows),
        '\n\n\n/***********SCREEN VARIABLES\nThese special variables can be used to locate screen openings relative to the (0,0) location of the screen opening region\n\n** screen variables\n\tsh \tscreen height (the value is in millimeters or pixels as appropriate)\n\tsw\tscreen width (the value is in millimeters or pixels as appropriate)\n\n\tmpp\tmillimeters per pixel\t\n\tppm\tpixels per millimeter\n\n\tnr\tnumber of rows in grid\n\tnc\tnumber of columns in grid\n\n** app variables (the value is in millimeters or pixels as appropriate)\n\tsbh\tstatus bar height\n\tumbh\tupper message bar height\n\tucbh\tupper command bar height\n\tlmbh\tlower message bar height\n\tlcbh\tlower command bar height\n\n\tsbb\tstatus bar bottom\n\tumbb\tupper message bar bottom\n\tucbb\tupper command bar bottom\n\tlmbt\tlower message bar top\n\tlmbb\tlower message bar bottom\n\tlcbb\tlower command bar bottom\n\t\n** grid variables (the value is in millimeters or pixels as appropriate)\n\tgw\tgrid width\n\tgh\tgrid height\n\tgt \tgrid top\n\tgb\tgrid bottom\n\n\ttp\ttop padding - specified in Grid Special Settings\n\tbp\tbottom padding - specified in Grid Special Settings\n\tlp\tleft padding - specified in Grid Special Settings\n\trp\tright padding - specified in Grid Special Settings\n\t\n** cell variables (the value is in millimeters)\n\tcw\tcell width (doesn\'t apply to cells that are affected by left/right compensation for tight cases)\n\tch\tcell height (doesn\'t apply to cells that are affected by top/bottom compensation for tight cases)\n\tccr\tcell corner radius\n\n\thor\theight of ridge - specified in Grid Special Settings\n\ttor\tthickness of ridge - specified in Grid Special Settings\n\n\n\n\n/***********CASE VARIABLES\nThese special variables can be used to locate openings and place additions relative to the (0,0) location of the case opening\n[Note that the (0,0) location of the case opening is not absolute and can move if the screen doesn\'t sit in the middle of the opening.  These variables are independent of that movement. All variables are in millimeters]\n\tcoh\tcase opening height - specified in Case Info\n\tcow \tcase opening width - specified in Case Info\n\tcocr\tcase opening corner radius - specified in Case Info\n\n\tkh\tkeyguard height - specified in Keyguard Frame Info\n\tkw\tkeyguard width - specified in Keyguard Frame Info\n\tkcr\tkeyguard corner radius - specified in Keyguard Frame Info\n\trh\trail height (also keyguard thickness)\n\thrw\thorizontal rail width\n\tvrw\tvertical rail width\n\n\tlcow\tthe default width of the left side of case opening when in landscape mode\n\tbcoh\tthe default height of the bottom side of case opening when in landscape mode\n\n\tc_h\tcase height\n\tc_w\tcase width\n\tc_cr\tcase corner_radius\n\tctsd\tcase to screen_depth\n\tsew\tsloped edge width\n\n\n\n/***********CAMERA and HOME BUTTON VARIABLES\nThe designer thinks of the camera and home button as positioned relative to the edge of the screen, not the edge of the tablet or the edget of the case opening so these variables will work best in the screen_openings set of instructions. Note that all the measurements in this set are in millimeters.  If you use these in a design that assumes all screen measurements are in pixels, multiply the variable times ppm (pixels per millimeter).\n\n\thloc\thome button location: 1,2,3,4 (adjusted for orientation)\n\thbd\tdistance from screen to home button in millimeters\n\thbh\thome button height in millimeters\n\thbw\thome button width in millimeters\n\tcloc\tcamera location: 1,2,3,4 (adjusted for orientation)\n\tcmd\tdistance from screen to camera in millimeters\n\tcmh\tcamera height in millimeters\n\tcmw\tcamera width in millimeters\n\n\tsxo\tsign of x offset, if measuring from standard home/camera locations\n\tsyo\tsign of y offset, if measuring from standard home/camera locations\n\t\n\txols\tx location of the left side of the case opening adjusted for swapping camera and home button\n\txors\tx location of the right side of the case opening adjusted for swapping camera and home button\n\tyobs\ty location of the bottom side of the case opening adjusted for swapping the camera and home button\n\tyots\ty location of the top side of the case opening adjusted for swapping the camera and home button\n\n\n\n\n/***********TABLET VARIABLES\n\tr180   "yes" or "no" whether the tablet has been rotated 180 degrees\n\tth     height of tablet in millimeters\n\ttw     width of tablet in millimeters - specified in internal designer data\n\ttcr    tablet corner radius in millimeters - specified in internal designer data\n\n\n\n\n/************ DISPLAYING THE VALUE OF A VARIABLE\nIf you just want to see what the contents of a variable is you use the "echo" command and look for what is displayed in the console\npane.  For example, if you wanted to see what the designer thinks the height of the tablet is in millimeters, put this line at the\ntop of this file:\n\necho(th=th);\n\nDon\'t forget the semicolon at the end of the line.  Save the file and look at the Console pane in OpenSCAD.  You should see a line that\nlooks something like this:\n\nECHO: th = 184\n\nSo the designer thinks that the height of the tablet is 184 millimeters.\n\n\n\n\n/************ CREATING YOUR OWN VARIABLES\nYou may want to create your own variables and use them to place features of your keyguard.  For example, you may want to put a\nbump between each column of cells to aid in navigation by a visually impaired individual. The distance from the left edge of the grid\nto the middle of the rail between column 1 and column 2 is the width of the grid divided by the number of columns.  That looks like\nthis: gw/nc.  The distance to the center of the rail between column 2 and column 3 is (gw/nc)*2, and so on.  You may want a variable\nthat is shorter in length so that your instruction lines don\'t get too long.  Just create your own variables:\nc1 = gw/nc;\nc2 = (gw/nc)*2;\nc3 = (gw/nc)*3;\nc4 = (gw/nc)*4;\nc5 = (gw/nc)*5;\n...\n\nPut these lines at the top of the openings_and_additions.txt file then use the variables in the "x" column.\n\nNote: if you create a variable that is already being used in the keyguard designer, you will see a Warning message like this:\n\n   "WARNING: c1 was assigned on line 1101 of "keyguard.scad" but was overwritten in file openings_and_additions.txt, line 1"\n\nwith a yellow background. It\'s telling you that you are trying to define "c1" but the keyguard designer is also trying to define it.\n\nYou will need to change the name of your variable until it doesn\'t collide with the keyguard designer program.\n\n\n************************************************************************************************************************************/\n',
    ]
    return "\n".join(parts)


STANDARD_FOOTER = build_standard_footer()


SECTION_RE = re.compile(
    r'(?P<name>screen_openings|case_openings|case_additions|tablet_openings)\s*=\s*\[(?P<body>.*?)\];',
    re.DOTALL,
)

REGION_HEADERS = {
    "screen_openings": ["ID", "shape", "height", "width", "corner", "x", "y", "cut | build", "anchor", "surface", "length", "thickness", "[edge_slopes]", "[special parms]"],
    "case_openings": ["ID", "shape", "height", "width", "corner", "x", "y", "cut | build", "anchor", "surface", "length", "thickness", "[edge_slopes]", "[special parms]"],
    "tablet_openings": ["ID", "shape", "height", "width", "corner", "x", "y", "cut | build", "anchor", "surface", "length", "thickness", "[edge_slopes]", "[special parms]"],
}
CASE_ADD_HEADERS = ["ID", "shape", "height", "width", "corner", "x", "y", "cut | build", "[trim]"]

REGION_SHAPES = {
    "r", "c", "hd", "oa1", "oa2", "oa3", "oa4", "text", "svg", "bump",
    "ridge", "hridge", "vridge", "cridge", "rridge", "aridge1", "aridge2", "aridge3", "aridge4",
}
CASE_ADD_SHAPES = {
    "r", "c",
    "tab1", "tab2", "tab3", "tab4", "cm1", "cm2", "cm3", "cm4",
    "t1", "t2", "t3", "t4", "f1", "f2", "f3", "f4", "oa1", "oa2", "oa3", "oa4",
    "ped1", "ped2", "ped3", "ped4", "r1", "r2", "r3", "r4",
}
TEXT_FONT_STYLES = {'"normal"', '"bold"', '"italic"', '"bold/italic"'}
TEXT_HALIGN = {'"left"', '"center"', '"right"'}
TEXT_VALIGN = {'"bottom"', '"baseline"', '"center"', '"top"'}
TARGET_FILENAME = "openings_and_additions.txt"


@dataclass
class Row:
    values: list[str]
    comment: str = ""


@dataclass
class ConversionResult:
    path: Path
    converted: bool
    warnings: list[str]
    validation_errors: list[str]
    backup_path: Optional[Path] = None
    message: str = ""


class ValidationError(Exception):
    pass


@dataclass
class TernaryBody:
    """A vector assigned via a ternary expression: name = condition ? [true] : [false]"""
    condition: str
    true_body: str
    false_body: str


@dataclass
class TernaryRows:
    """Converted output of a ternary-assigned vector."""
    condition: str
    true_rows: list[Row]
    false_rows: list[Row]


def strip_block_comments(text: str) -> str:
    return re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)


def extract_header_comment(text: str) -> str:
    """Return the leading block of // comment and blank lines from the top of the file."""
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith('//') or stripped == '':
            lines.append(line)
        else:
            break
    while lines and lines[-1].strip() == '':
        lines.pop()
    return '\n'.join(lines)


def extract_preserved_assignment_statements(text: str) -> list[str]:
    # Strip block comments first so assignments inside /* ... */ blocks are not collected.
    cleaned = strip_block_comments(text)

    spans: list[tuple[int, int]] = []
    for m in SECTION_RE.finditer(cleaned):
        spans.append((m.start(), m.end()))

    def in_section(pos: int) -> bool:
        return any(start <= pos < end for start, end in spans)

    assignments: list[str] = []
    seen: set[str] = set()
    assign_re = re.compile(r'^\s*([\$A-Za-z_][\$A-Za-z0-9_]*)\s*=\s*.*?;\s*(?://.*)?$')

    for m in re.finditer(r'^.*$', cleaned, flags=re.MULTILINE):
        line = m.group(0)
        if not line.strip() or in_section(m.start()):
            continue
        stripped = line.strip()
        mm = assign_re.match(line)
        if not mm:
            continue
        name = mm.group(1)
        if name in {'screen_openings', 'case_openings', 'case_additions', 'tablet_openings'}:
            continue
        if name == 'oa_version':
            continue
        if stripped not in seen:
            assignments.append(stripped)
            seen.add(stripped)

    return assignments


SECTION_NAME_RE = re.compile(
    r'(?P<name>screen_openings|case_openings|case_additions|tablet_openings)\s*=\s*'
)


def _extract_bracket_body(text: str) -> tuple[str | None, str]:
    """Given text starting with '[', return (inner_body, remainder) up to the matching ']'.
    Returns (None, text) if no matching ']' is found."""
    assert text.startswith('[')
    depth = 0
    in_str = False
    str_char = ''
    i = 0
    while i < len(text):
        ch = text[i]
        if in_str:
            if ch == '\\':
                i += 2
                continue
            if ch == str_char:
                in_str = False
        elif ch in ('"', "'"):
            in_str = True
            str_char = ch
        elif ch == '[':
            depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0:
                return text[1:i], text[i + 1:]
        i += 1
    return None, text


def _extract_assignment_rhs(text: str, pos: int) -> tuple[str, int]:
    """Extract the RHS of an assignment from pos (position just after '=').
    Returns (rhs_stripped, end_pos) where end_pos is just after the terminating ';'.
    Handles bracket counting, strings, and '//' line comments."""
    depth = 0
    in_str = False
    str_char = ''
    i = pos
    while i < len(text):
        ch = text[i]
        if in_str:
            if ch == '\\':
                i += 2
                continue
            if ch == str_char:
                in_str = False
        elif ch in ('"', "'"):
            in_str = True
            str_char = ch
        elif ch == '/' and i + 1 < len(text) and text[i + 1] == '/':
            while i < len(text) and text[i] != '\n':
                i += 1
            continue
        elif ch in ('([{'):
            depth += 1
        elif ch in (')]}'):
            depth -= 1
        elif ch == ';' and depth == 0:
            return text[pos:i].strip(), i + 1
        i += 1
    return text[pos:].strip(), len(text)


def _parse_ternary_rhs(rhs: str) -> TernaryBody | None:
    """Parse 'condition ? [true_body] : [false_body]' from an assignment RHS.
    Returns None if the RHS is not a simple ternary with plain-array branches."""
    # Find '?' at depth 0 (outside brackets and strings)
    depth = 0
    in_str = False
    str_char = ''
    q_pos: int | None = None
    i = 0
    while i < len(rhs):
        ch = rhs[i]
        if in_str:
            if ch == '\\':
                i += 2
                continue
            if ch == str_char:
                in_str = False
        elif ch in ('"', "'"):
            in_str = True
            str_char = ch
        elif ch in ('([{'):
            depth += 1
        elif ch in (')]}'):
            depth -= 1
        elif ch == '?' and depth == 0:
            q_pos = i
            break
        i += 1

    if q_pos is None:
        return None  # not a ternary

    condition = rhs[:q_pos].strip()
    rest = rhs[q_pos + 1:].lstrip()

    if not rest.startswith('['):
        return None  # true branch is not a plain array

    true_body, rest = _extract_bracket_body(rest)
    if true_body is None:
        return None

    rest = rest.lstrip()
    if not rest.startswith(':'):
        return None  # no colon separator

    rest = rest[1:].lstrip()
    if not rest.startswith('['):
        return None  # false branch is not a plain array

    false_body, _ = _extract_bracket_body(rest)
    if false_body is None:
        return None

    return TernaryBody(condition=condition, true_body=true_body, false_body=false_body)


def extract_section_bodies(text: str, warnings: list[str]) -> dict[str, str | TernaryBody]:
    cleaned = strip_block_comments(text)
    out: dict[str, str | TernaryBody] = {}

    # First pass: plain array assignments  name = [...];
    for m in SECTION_RE.finditer(cleaned):
        out[m.group('name')] = m.group('body')

    # Second pass: try to parse any remaining section as a ternary
    for m in SECTION_NAME_RE.finditer(cleaned):
        name = m.group('name')
        if name in out:
            continue
        rhs, _ = _extract_assignment_rhs(cleaned, m.end())
        ternary = _parse_ternary_rhs(rhs)
        if ternary is not None:
            out[name] = ternary
        else:
            warnings.append(
                f"'{name}' is assigned via an expression the script cannot parse. "
                f"Its rows could not be automatically migrated — please convert them manually."
            )

    # Missing vectors fall back to empty
    for name in ('screen_openings', 'case_openings', 'case_additions', 'tablet_openings'):
        out.setdefault(name, '')

    return out


def split_top_level_commas(s: str) -> list[str]:
    parts: list[str] = []
    buf: list[str] = []
    depth = 0
    in_str = False
    quote = ''
    escape = False
    for ch in s:
        if in_str:
            buf.append(ch)
            if escape:
                escape = False
            elif ch == '\\':
                escape = True
            elif ch == quote:
                in_str = False
            continue
        if ch in ('"', "'"):
            in_str = True
            quote = ch
            buf.append(ch)
            continue
        if ch == '[':
            depth += 1
            buf.append(ch)
            continue
        if ch == ']':
            depth -= 1
            buf.append(ch)
            continue
        if ch == ',' and depth == 0:
            parts.append(''.join(buf).strip())
            buf = []
            continue
        buf.append(ch)
    parts.append(''.join(buf).strip())
    return parts


def parse_rows(body: str) -> list[tuple[list[str], str]]:
    rows: list[tuple[list[str], str]] = []
    for line in body.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith('//'):
            continue
        if '[' not in stripped or ']' not in stripped:
            continue
        row_text = stripped[stripped.find('[')+1:stripped.rfind(']')]
        comment = ''
        if '//' in stripped[stripped.rfind(']')+1:]:
            comment = stripped[stripped.rfind('//'):].rstrip()
        values = split_top_level_commas(row_text)
        while values and values[-1] == '':
            values.pop()
        rows.append((values, comment))
    return rows


def normalize_atom(v: str) -> str:
    return v.strip()


def is_number_literal(v: str) -> bool:
    return bool(re.fullmatch(r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)', v.strip()))


def pretty_number(v: str) -> str:
    s = v.strip().replace(' ', '')
    if not is_number_literal(s):
        return v.strip()
    neg = s.startswith('-')
    core = s[1:] if neg else s
    if core.startswith('.'):
        core = '0' + core
    if '.' in core:
        a, b = core.split('.', 1)
        if b == '':
            return ('-' if neg else '') + a
        return ('-' if neg else '') + f"{a}.{b}"
    return ('-' if neg else '') + core


def atom(v: str) -> str:
    v = normalize_atom(v)
    if v == '':
        return ''
    return pretty_number(v)


def compact_number_or_expr(v: str) -> str:
    return normalize_atom(v).replace(' ', '') if is_number_literal(v.replace(' ', '')) else normalize_atom(v)


def slope_vector_for_region(shape: str, top: str, bottom: str, left: str, right: str) -> str:
    vals = [normalize_atom(top), normalize_atom(bottom), normalize_atom(left), normalize_atom(right)]
    if shape == 'c':
        t = vals[0] or '90'
        return '[]' if compact_number_or_expr(t) in ('90', '0') else f'[{atom(t)}]'
    normalized = [v or '90' for v in vals]
    normalized = ['90' if compact_number_or_expr(v) == '0' else v for v in normalized]
    if all(compact_number_or_expr(v) == '90' for v in normalized):
        return '[]'
    if len({compact_number_or_expr(v) for v in normalized}) == 1:
        return f'[{atom(normalized[0])}]'
    return '[' + ','.join(atom(v) for v in normalized) + ']'


def trim_vector(ta: str, tb: str, tr: str, tl: str) -> str:
    vals = [normalize_atom(ta), normalize_atom(tb), normalize_atom(tl), normalize_atom(tr)]
    vals = ['' if compact_number_or_expr(v) == '-999' else v for v in vals]
    if all(v == '' for v in vals):
        return '[]'
    nv = [v if v != '' else '-999' for v in vals]
    if len({compact_number_or_expr(v) for v in nv}) == 1:
        return f'[{atom(nv[0])}]'
    return '[' + ','.join(atom(v) for v in nv) + ']'


def font_style(code: str) -> str:
    return {'0': '"normal"', '1': '"bold"', '2': '"italic"', '3': '"bold/italic"'}.get(compact_number_or_expr(code), '"normal"')


def h_align(code: str) -> str:
    return {'0': '"left"', '1': '"left"', '2': '"center"', '3': '"right"'}.get(compact_number_or_expr(code), '"left"')


def v_align(code: str) -> str:
    return {'0': '"bottom"', '1': '"bottom"', '2': '"baseline"', '3': '"center"', '4': '"top"'}.get(compact_number_or_expr(code), '"bottom"')


def region_row_is_placeholder(values: list[str]) -> bool:
    vals = values + [''] * (12 - len(values))
    _id, x, y, width, height, shape, top, bottom, left, right, corner, other = [normalize_atom(v) for v in vals[:12]]
    return (
        x in ('0', '') and y in ('0', '') and width in ('0', '') and height in ('0', '')
        and shape in ('"r"', '"cr"', '"rr"', '"crr"', 'r', 'cr', 'rr', 'crr')
        and top in ('90', '0', '') and bottom in ('90', '0', '') and left in ('90', '0', '') and right in ('90', '0', '')
        and corner in ('0', '') and other in ('',)
    )


def additions_row_is_placeholder(values: list[str]) -> bool:
    vals = values + [''] * (12 - len(values))
    _id, x, y, width, height, shape, thickness, ta, tb, tr, tl, corner = [normalize_atom(v) for v in vals[:12]]
    return (
        x in ('0', '') and y in ('0', '') and width in ('0', '') and height in ('0', '')
        and shape in ('"r"', '"r1"', 'r', 'r1') and thickness in ('0', '') and corner in ('0', '')
        and ta in ('-999', '') and tb in ('-999', '') and tr in ('-999', '') and tl in ('-999', '')
    )


def is_known_shape_literal(value: str, allowed_shapes: set[str]) -> bool:
    value = normalize_atom(value)
    return is_string_literal(value) and value.strip('"') in allowed_shapes


def as_preserved_region_v2_row(values: list[str]) -> Row:
    vals = (values + [''] * 14)[:14]
    normalized: list[str] = []
    for i, value in enumerate(vals):
        if i in (1, 8, 9, 12, 13):
            normalized.append(normalize_atom(value))
        else:
            normalized.append(atom(value))
    normalized[12] = normalized[12] or '[]'
    normalized[13] = normalized[13] or '[]'
    # Apply explicit defaults for any blank fields
    normalized[8]  = '"C"' if normalized[8] in ('"c"', '"C"') else '"L"'
    normalized[9]  = '"B"' if normalized[9] in ('"b"', '"B"') else '"T"'
    for i in (2, 3, 4, 7, 10, 11):
        normalized[i] = normalized[i] or '0'
    return Row(normalized)


def as_preserved_case_add_v2_row(values: list[str]) -> Row:
    vals = (values + [''] * 9)[:9]
    normalized: list[str] = []
    for i, value in enumerate(vals):
        if i in (1, 8):
            normalized.append(normalize_atom(value))
        else:
            normalized.append(atom(value))
    normalized[8] = normalized[8] or '[]'
    # Apply explicit defaults for blank corner and cut/build fields
    normalized[4] = normalized[4] or '0'
    normalized[7] = normalized[7] or '0'
    return Row(normalized)


def convert_region_row(values: list[str], warnings: list[str], section_name: str) -> Optional[Row]:
    vals = values + [''] * (12 - len(values))
    id_, x, y, width, height, shape, top, bottom, left, right, corner, other = vals[:12]
    id_, x, y, width, height, shape, top, bottom, left, right, corner, other = map(normalize_atom, [id_, x, y, width, height, shape, top, bottom, left, right, corner, other])
    bare_shape = shape.strip('"')

    # Non-literal shape (variable or expression): pass through with column reordering only
    if not is_string_literal(shape) and shape != '':
        cut_build = atom(other) if other not in ('', '0') else '0'
        return Row([
            atom(id_),
            shape,
            atom(height) or '0',
            atom(width)  or '0',
            atom(corner) if corner not in ('', '0') else '0',
            atom(x),
            atom(y),
            cut_build,
            '"L"', '"T"', '0', '0', '[]', '[]',
        ])

    new_shape = bare_shape
    anchor = ''
    surface = ''
    length = ''
    thickness = ''
    edge_slopes = '[]'
    special = '[]'
    cut_build = ''
    new_corner = ''
    new_width = atom(width)
    new_height = atom(height)
    new_x = atom(x)
    new_y = atom(y)

    if bare_shape in ('r', 'cr', 'rr', 'crr'):
        new_shape = 'r'
        anchor = '"c"' if bare_shape in ('cr', 'crr') else ''
        new_corner = '' if bare_shape in ('r', 'cr') or compact_number_or_expr(corner) in ('0', '') else atom(corner)
        edge_slopes = slope_vector_for_region('r', top, bottom, left, right)
    elif bare_shape == 'c':
        new_shape = 'c'
        new_width = atom(width) if normalize_atom(width) not in ('0', '') else '0'
        new_corner = ''
        edge_slopes = slope_vector_for_region('c', top, bottom, left, right)
    elif bare_shape == 'hd':
        new_shape = 'hd'
        new_corner = ''
        edge_slopes = slope_vector_for_region('hd', top, bottom, left, right)
    elif bare_shape in ('oa1', 'oa2', 'oa3', 'oa4'):
        new_shape = bare_shape
        new_height = ''
        new_width = ''
        new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
        edge_slopes = '[]'
    elif bare_shape in ('ttext', 'btext'):
        new_shape = 'text'
        new_width = ''
        new_corner = ''
        cut_build = atom(corner) if corner != '' else ''
        surface = '"b"' if bare_shape == 'btext' else ''
        special = '[' + ','.join([
            other if other else '""',
            atom(top or '0'),
            font_style(bottom or '0'),
            h_align(left or '0'),
            v_align(right or '0'),
        ]) + ']'
    elif bare_shape == 'svg':
        new_shape = 'svg'
        new_corner = '' if corner == '' else atom(corner)
        cut_build = atom(corner) if corner != '' else ''
        special = '[' + ','.join([
            other if other else '""',
            atom(top or '0'),
        ]) + ']'
    elif bare_shape == 'bump':
        new_shape = 'bump'
        new_height = atom(width)  # V1 width holds the diameter → V2 height
        new_width = ''
        new_corner = ''
    elif bare_shape in ('hridge', 'vridge', 'ridge', 'cridge', 'rridge', 'crridge') or bare_shape.startswith('aridge'):
        ridge_map = {'crridge': 'rridge'}
        new_shape = ridge_map.get(bare_shape, bare_shape)
        cut_build = atom(top) if top != '' else ''
        thickness = atom(bottom)
        if bare_shape == 'hridge':
            length = atom(width)
            new_width = ''
            new_height = ''
        elif bare_shape == 'vridge':
            length = atom(height)
            new_width = ''
            new_height = ''
        elif bare_shape == 'ridge':
            length = atom(width)
            new_width = ''
            new_height = ''
            special = '[' + atom(left or '0') + ']'
        elif bare_shape == 'cridge':
            new_width = ''
        elif bare_shape == 'rridge':
            new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
        elif bare_shape == 'crridge':
            anchor = '"c"'
            new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
        elif bare_shape.startswith('aridge'):
            new_width = ''
            new_height = ''
            new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
    else:
        warnings.append(f'Dropped unsupported {section_name} shape {shape}.')
        return None

    if bare_shape not in ('ttext', 'btext', 'svg', 'ridge', 'hridge', 'vridge', 'cridge', 'rridge', 'crridge') and not bare_shape.startswith('aridge'):
        if other != '' and not other.startswith('"'):
            if other.startswith('-'):
                cut_build = atom(other)
                surface = '"b"'
            else:
                cut_build = atom(other)

    # Apply explicit defaults for all blank fields
    anchor    = '"C"' if anchor  in ('"c"', '"C"') else '"L"'
    surface   = '"B"' if surface in ('"b"', '"B"') else '"T"'
    cut_build  = cut_build  or '0'
    new_corner = new_corner or '0'
    length     = length     or '0'
    thickness  = thickness  or '0'
    new_height = new_height or '0'
    new_width  = new_width  or '0'

    return Row([
        atom(id_),
        f'"{new_shape}"',
        new_height,
        new_width,
        new_corner,
        new_x,
        new_y,
        cut_build,
        anchor,
        surface,
        length,
        thickness,
        edge_slopes,
        special,
    ])


def _encode_cb(negative: bool, thickness: str) -> str:
    """Encode the V2 cut/build value for a case_additions row.

    negative, thickness == 0  → -9  (full-height 2-D subtraction)
    negative, thickness > 0   → -thickness  (pocket subtraction)
    positive, thickness == 0  → 0   (full-height 2-D addition)
    positive, thickness > 0   → thickness   (extruded addition)
    """
    if negative:
        t = atom(thickness) if thickness not in ('', '-999') else ''
        return '-9' if t in ('', '0') else '-' + t
    t = atom(thickness) if thickness not in ('', '-999') else ''
    return t if t not in ('', '0') else '0'


def convert_addition_row(values: list[str], warnings: list[str]) -> Optional[Row]:
    vals = values + [''] * (12 - len(values))
    id_, x, y, width, height, shape, thickness, ta, tb, tr, tl, corner = map(normalize_atom, vals[:12])
    bare = shape.strip('"')
    negative = bare.startswith('-')
    base_shape = bare[1:] if negative else bare
    comment = ''

    # Non-literal shape (variable or expression): pass through with column reordering only
    if not is_string_literal(shape) and shape != '':
        new_corner = atom(corner) if corner not in ('', '0', '-999') else '0'
        cut_build  = _encode_cb(negative, thickness)
        return Row([
            atom(id_),
            shape,
            atom(height) or '0',
            atom(width)  or '0',
            new_corner,
            atom(x),
            atom(y),
            cut_build,
            trim_vector(ta, tb, tr, tl),
        ], comment=comment)

    if base_shape == 'c':
        # V1 "c" = circle; height holds the diameter; width and corner unused
        new_shape = 'c'
        cut_build = _encode_cb(negative, thickness)
        return Row([
            atom(id_),
            f'"{new_shape}"',
            atom(height) or '0',
            '0',
            '0',
            atom(x),
            atom(y),
            cut_build,
            trim_vector(ta, tb, tr, tl),
        ], comment=comment)
    elif base_shape == 'cr':
        # V1 "cr" = centre-anchored rectangle → V2 "r" (always centre-anchored)
        new_shape = 'r'
        new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
        new_corner = new_corner or '0'
        cut_build = _encode_cb(negative, thickness)
        return Row([
            atom(id_),
            f'"{new_shape}"',
            atom(height) or '0',
            atom(width)  or '0',
            new_corner,
            atom(x),
            atom(y),
            cut_build,
            trim_vector(ta, tb, tr, tl),
        ], comment=comment)
    elif base_shape == 'crr':
        # V1 "crr" = centre-anchored rounded rectangle → V2 "r" with corner radius
        new_shape = 'r'
        new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
        new_corner = new_corner or '0'
        cut_build = _encode_cb(negative, thickness)
        return Row([
            atom(id_),
            f'"{new_shape}"',
            atom(height) or '0',
            atom(width)  or '0',
            new_corner,
            atom(x),
            atom(y),
            cut_build,
            trim_vector(ta, tb, tr, tl),
        ], comment=comment)
    elif base_shape == 'rr':
        warnings.append(f"Dropped case_additions 'rr' (V2 case_additions does not support 'rr'; use 'r' for a centre-anchored rectangle).")
        return None
    elif re.fullmatch(r'rr([1-4])', base_shape):
        m = re.fullmatch(r'rr([1-4])', base_shape)
        assert m is not None
        new_shape = f'r{m.group(1)}'
        new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
    elif base_shape in CASE_ADD_SHAPES:
        new_shape = base_shape  # always use positive shape name; subtraction encoded in cb
        new_corner = '' if compact_number_or_expr(corner) in ('0', '') else atom(corner)
    else:
        warnings.append(f"Dropped unsupported case_additions shape {shape}.")
        return None

    cut_build = _encode_cb(negative, thickness)

    new_corner = new_corner or '0'

    return Row([
        atom(id_),
        f'"{new_shape}"',
        atom(height) or '0',
        atom(width)  or '0',
        new_corner,
        atom(x),
        atom(y),
        cut_build,
        trim_vector(ta, tb, tr, tl),
    ], comment=comment)


def default_region_row() -> Row:
    return Row(['0', '"r"', '0', '0', '0', '0', '0', '0', '"L"', '"T"', '0', '0', '[]', '[]'])


def default_addition_row() -> Row:
    return Row(['0', '"r"', '0', '0', '0', '0', '0', '0', '[]'])


def _convert_region_body(body: str, name: str, warnings: list[str]) -> list[Row]:
    parsed = parse_rows(body)
    if not parsed or (len(parsed) == 1 and region_row_is_placeholder(parsed[0][0])):
        return [default_region_row()]
    rows: list[Row] = []
    for values, _comment in parsed:
        if is_known_shape_literal(values[1] if len(values) > 1 else '', REGION_SHAPES):
            rows.append(as_preserved_region_v2_row(values))
            continue
        converted = convert_region_row(values, warnings, name)
        if converted is not None:
            rows.append(converted)
    return rows or [default_region_row()]


def _convert_addition_body(body: str, warnings: list[str]) -> list[Row]:
    parsed = parse_rows(body)
    if not parsed or (len(parsed) == 1 and additions_row_is_placeholder(parsed[0][0])):
        return [default_addition_row()]
    rows: list[Row] = []
    for values, _comment in parsed:
        if is_known_shape_literal(values[1] if len(values) > 1 else '', CASE_ADD_SHAPES):
            rows.append(as_preserved_case_add_v2_row(values))
            continue
        converted = convert_addition_row(values, warnings)
        if converted is not None:
            rows.append(converted)
    return rows or [default_addition_row()]


def convert_sections(sections: dict[str, str | TernaryBody]) -> tuple[dict[str, list[Row] | TernaryRows], list[str]]:
    warnings: list[str] = []
    out: dict[str, list[Row] | TernaryRows] = {}

    for name in ('screen_openings', 'case_openings', 'tablet_openings'):
        body = sections[name]
        if isinstance(body, TernaryBody):
            out[name] = TernaryRows(
                condition=body.condition,
                true_rows=_convert_region_body(body.true_body, name, warnings),
                false_rows=_convert_region_body(body.false_body, name, warnings),
            )
        else:
            out[name] = _convert_region_body(body, name, warnings)

    body = sections['case_additions']
    if isinstance(body, TernaryBody):
        out['case_additions'] = TernaryRows(
            condition=body.condition,
            true_rows=_convert_addition_body(body.true_body, warnings),
            false_rows=_convert_addition_body(body.false_body, warnings),
        )
    else:
        out['case_additions'] = _convert_addition_body(body, warnings)

    return out, warnings


def align_right_for_column(section_name: str, column_index: int) -> bool:
    return True



def compute_widths(rows: list[Row], headers: list[str]) -> list[int]:
    widths = [len(h) for h in headers]
    for row in rows:
        for i, value in enumerate(row.values):
            widths[i] = max(widths[i], len(value))
    # Ensure x and y column headers have at least 3 leading spaces (minimum width 4)
    for i, h in enumerate(headers):
        if h in ('x', 'y'):
            widths[i] = max(widths[i], 4)
    return widths



def format_rows(rows: list[Row], headers: list[str], section_name: str) -> list[str]:
    widths = compute_widths(rows, headers)
    out: list[str] = []

    header_cells: list[str] = []
    for i, header in enumerate(headers):
        header_cells.append(header.rjust(widths[i]))
    out.append('// ' + ', '.join(header_cells))

    row_prefix = '[  '
    row_suffix = ' ],'
    for row in rows:
        cells: list[str] = []
        for i, value in enumerate(row.values):
            cells.append(value.rjust(widths[i]))
        line = row_prefix + ', '.join(cells) + row_suffix
        if row.comment:
            line += ' ' + row.comment
        out.append(line)
    return out


def _format_ternary_section(name: str, ternary: TernaryRows) -> list[str]:
    headers = REGION_HEADERS.get(name, CASE_ADD_HEADERS)
    parts = [f'{name} = {ternary.condition} ?']
    parts.append('[')
    parts.extend(format_rows(ternary.true_rows, headers, name))
    parts.append('] :')
    parts.append('[')
    parts.extend(format_rows(ternary.false_rows, headers, name))
    parts.append('];')
    return parts


def build_output(converted: dict[str, list[Row] | TernaryRows], preserved_assignments: list[str] | None = None, header_comment: str = '') -> str:
    preserved_assignments = preserved_assignments or []
    parts = []
    if header_comment:
        parts.append(header_comment)
        parts.append('')
    if preserved_assignments:
        parts.extend(preserved_assignments)
    parts.append('')
    for name in ('screen_openings', 'case_openings', 'case_additions', 'tablet_openings'):
        section = converted[name]
        if isinstance(section, TernaryRows):
            parts.extend(_format_ternary_section(name, section))
        else:
            parts.append(f'{name}=[')
            headers = REGION_HEADERS.get(name, CASE_ADD_HEADERS)
            parts.extend(format_rows(section, headers, name))
            parts.append('];')
        parts.append('')
    parts.append('')
    parts.append(STANDARD_FOOTER.rstrip())
    parts.append('')
    return '\n'.join(parts)


def parse_vector_literal(text: str) -> list[str]:
    stripped = normalize_atom(text)
    if stripped == '[]':
        return []
    if not (stripped.startswith('[') and stripped.endswith(']')):
        raise ValidationError(f'Expected vector literal, got: {text}')
    inner = stripped[1:-1].strip()
    if inner == '':
        return []
    return split_top_level_commas(inner)


def is_string_literal(v: str) -> bool:
    v = normalize_atom(v)
    return len(v) >= 2 and v[0] == '"' and v[-1] == '"'


def validate_region_row(row: Row, section_name: str, row_index: int) -> list[str]:
    errors: list[str] = []
    vals = row.values
    if len(vals) != 14:
        return [f'{section_name} row {row_index}: expected 14 columns, found {len(vals)}']

    shape = vals[1]
    bare_shape = shape.strip('"')
    if shape == '':
        errors.append(f'{section_name} row {row_index}: shape must not be empty')
    elif not is_string_literal(shape):
        pass  # variable or expression — validated by OpenSCAD at render time
    elif bare_shape not in REGION_SHAPES:
        errors.append(f'{section_name} row {row_index}: unsupported V2 shape {shape}')

    anchor = vals[8]
    surface = vals[9]
    if anchor not in ('"L"', '"C"'):
        errors.append(f'{section_name} row {row_index}: anchor must be "L" or "C"')
    if surface not in ('"T"', '"B"'):
        errors.append(f'{section_name} row {row_index}: surface must be "T" or "B"')

    try:
        edge_vals = parse_vector_literal(vals[12])
        special_vals = parse_vector_literal(vals[13])
    except ValidationError as exc:
        errors.append(f'{section_name} row {row_index}: {exc}')
        return errors

    if bare_shape == 'c' and len(edge_vals) not in (0, 1):
        errors.append(f'{section_name} row {row_index}: circle edge slopes must have 0 or 1 values')
    elif bare_shape == 'hd' and len(edge_vals) not in (0, 1, 4):
        errors.append(f'{section_name} row {row_index}: hd edge slopes must have 0, 1, or 4 values')
    elif bare_shape != 'c' and bare_shape != 'hd' and len(edge_vals) not in (0, 1, 4):
        errors.append(f'{section_name} row {row_index}: edge slopes must have 0, 1, or 4 values')

    if bare_shape == 'text':
        if len(special_vals) != 5:
            errors.append(f'{section_name} row {row_index}: text special params must have 5 values')
        else:
            if not is_string_literal(special_vals[0]):
                errors.append(f'{section_name} row {row_index}: text string must be quoted')
            if special_vals[2] not in TEXT_FONT_STYLES:
                errors.append(f'{section_name} row {row_index}: invalid text font style {special_vals[2]}')
            if special_vals[3] not in TEXT_HALIGN:
                errors.append(f'{section_name} row {row_index}: invalid text h-align {special_vals[3]}')
            if special_vals[4] not in TEXT_VALIGN:
                errors.append(f'{section_name} row {row_index}: invalid text v-align {special_vals[4]}')
    elif bare_shape == 'svg':
        if len(special_vals) != 2:
            errors.append(f'{section_name} row {row_index}: svg special params must have 2 values')
        elif not is_string_literal(special_vals[0]):
            errors.append(f'{section_name} row {row_index}: svg filename must be quoted')
    elif bare_shape == 'ridge':
        if len(special_vals) not in (0, 1):
            errors.append(f'{section_name} row {row_index}: ridge special params must have 0 or 1 values')

    # Ignore extra data in columns that the shape does not use.
    return errors


def validate_case_addition_row(row: Row, row_index: int) -> list[str]:
    errors: list[str] = []
    vals = row.values
    if len(vals) != 9:
        return [f'case_additions row {row_index}: expected 9 columns, found {len(vals)}']

    shape = vals[1]
    bare_shape = shape.strip('"')
    if shape == '':
        errors.append(f'case_additions row {row_index}: shape must not be empty')
    elif not is_string_literal(shape):
        pass  # variable or expression — validated by OpenSCAD at render time
    elif bare_shape not in CASE_ADD_SHAPES:
        errors.append(f'case_additions row {row_index}: unsupported V2 shape {shape}')

    try:
        trim_vals = parse_vector_literal(vals[8])
    except ValidationError as exc:
        errors.append(f'case_additions row {row_index}: {exc}')
        return errors

    if len(trim_vals) not in (0, 1, 4):
        errors.append(f'case_additions row {row_index}: trim vector must have 0, 1, or 4 values')

    # Ignore extra data in columns that the shape does not use
    # (for example trim data for ped1-4).
    return errors


def validate_converted_sections(converted: dict[str, list[Row] | TernaryRows]) -> list[str]:
    errors: list[str] = []
    for section_name in ('screen_openings', 'case_openings', 'tablet_openings'):
        section = converted[section_name]
        all_rows = (section.true_rows + section.false_rows) if isinstance(section, TernaryRows) else section
        for idx, row in enumerate(all_rows, start=1):
            errors.extend(validate_region_row(row, section_name, idx))
    section = converted['case_additions']
    all_rows = (section.true_rows + section.false_rows) if isinstance(section, TernaryRows) else section
    for idx, row in enumerate(all_rows, start=1):
        errors.extend(validate_case_addition_row(row, idx))
    return errors


def convert_text(source: str, validate: bool = True) -> tuple[str, list[str], list[str]]:
    warnings: list[str] = []
    sections = extract_section_bodies(source, warnings)
    preserved_assignments = extract_preserved_assignment_statements(source)
    header_comment = extract_header_comment(source)
    converted, conv_warnings = convert_sections(sections)
    warnings.extend(conv_warnings)
    validation_errors = validate_converted_sections(converted) if validate else []
    if validation_errors:
        raise ValidationError('\n'.join(validation_errors))
    return build_output(converted, preserved_assignments=preserved_assignments, header_comment=header_comment), warnings, validation_errors


def find_target_files(root_dir: Path, recursive: bool = True, filename: str = TARGET_FILENAME) -> list[Path]:
    if root_dir.is_file():
        return [root_dir] if root_dir.name == filename else []
    if recursive:
        return sorted(p for p in root_dir.rglob(filename) if p.is_file())
    return sorted(p for p in root_dir.glob(filename) if p.is_file())


def safe_backup_path(filepath: Path) -> Path:
    backup = filepath.with_name(filepath.name + '.bak')
    if not backup.exists():
        return backup
    index = 1
    while True:
        candidate = filepath.with_name(f'{filepath.name}.bak{index}')
        if not candidate.exists():
            return candidate
        index += 1


def convert_single_file(
    filepath: Path,
    *,
    overwrite: bool,
    output_file: Optional[Path],
    suffix: str,
    make_backup: bool,
    validate: bool,
) -> ConversionResult:
    warnings: list[str] = []
    try:
        source = filepath.read_text(encoding='utf-8')
        output_text, conversion_warnings, _validation = convert_text(source, validate=validate)
        warnings.extend(conversion_warnings)

        backup_path: Optional[Path] = None
        if overwrite:
            destination = filepath
            if make_backup:
                backup_path = safe_backup_path(filepath)
                shutil.copy2(filepath, backup_path)
        else:
            destination = output_file if output_file else filepath.with_name(filepath.stem + suffix + filepath.suffix)

        destination.write_text(output_text, encoding='utf-8', newline='\n')
        return ConversionResult(
            path=filepath,
            converted=True,
            warnings=warnings,
            validation_errors=[],
            backup_path=backup_path,
            message=f'Wrote {destination}',
        )
    except ValidationError as exc:
        return ConversionResult(
            path=filepath,
            converted=False,
            warnings=warnings,
            validation_errors=str(exc).splitlines(),
            message='Validation failed',
        )
    except Exception as exc:
        return ConversionResult(
            path=filepath,
            converted=False,
            warnings=warnings,
            validation_errors=[str(exc)],
            message='Conversion failed',
        )


def convert_tree(
    root: Path,
    *,
    recursive: bool,
    filename: str,
    overwrite: bool,
    make_backup: bool,
    validate: bool,
    workers: int,
) -> list[ConversionResult]:
    targets = find_target_files(root, recursive=recursive, filename=filename)
    if not targets:
        return []

    max_workers = max(1, workers)
    results: list[ConversionResult] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_map = {
            executor.submit(
                convert_single_file,
                path,
                overwrite=overwrite,
                output_file=None,
                suffix='_v2',
                make_backup=make_backup,
                validate=validate,
            ): path
            for path in targets
        }
        for future in concurrent.futures.as_completed(future_map):
            results.append(future.result())
    return sorted(results, key=lambda r: str(r.path))


def print_result(result: ConversionResult) -> None:
    status = 'OK' if result.converted else 'FAILED'
    print(f'[{status}] {result.path}')
    if result.backup_path is not None:
        print(f'  Backup: {result.backup_path}')
    print(f'  {result.message}')
    for warning in result.warnings:
        print(f'  WARNING: {warning}')
    for error in result.validation_errors:
        print(f'  ERROR: {error}')


def default_worker_count() -> int:
    cpu = os.cpu_count() or 4
    return min(32, max(4, cpu))


def main() -> int:
    parser = argparse.ArgumentParser(description='Upgrade VolksSwitch O&A files from V1 to V2.')
    parser.add_argument('path', help='Input file or root directory')
    parser.add_argument('output_file', nargs='?', help='Optional explicit output file for single-file conversion when not overwriting')
    parser.add_argument('--overwrite', action='store_true', help='Overwrite the original file(s) in place')
    parser.add_argument('--no-backup', action='store_true', help='Do not create backup files when using --overwrite')
    parser.add_argument('--no-recursive', action='store_true', help='Do not traverse subdirectories when path is a directory')
    parser.add_argument('--filename', default=TARGET_FILENAME, help=f'Filename to match during directory traversal (default: {TARGET_FILENAME})')
    parser.add_argument('--workers', type=int, default=default_worker_count(), help='Parallel worker count for directory traversal')
    parser.add_argument('--no-validate', action='store_true', help='Skip V2 schema validation of converted output')
    parser.add_argument('--suffix', default='_v2', help='Suffix for non-overwrite single-file output names')
    args = parser.parse_args()

    path = Path(args.path)
    validate = not args.no_validate
    make_backup = not args.no_backup

    if path.is_file():
        result = convert_single_file(
            path,
            overwrite=args.overwrite,
            output_file=Path(args.output_file) if args.output_file else None,
            suffix=args.suffix,
            make_backup=make_backup,
            validate=validate,
        )
        print_result(result)
        return 0 if result.converted else 1

    if not path.exists():
        print(f'ERROR: path does not exist: {path}', file=sys.stderr)
        return 1

    results = convert_tree(
        path,
        recursive=not args.no_recursive,
        filename=args.filename,
        overwrite=args.overwrite,
        make_backup=make_backup,
        validate=validate,
        workers=args.workers,
    )

    if not results:
        print(f'No files named {args.filename} were found under {path}')
        return 0

    failures = 0
    for result in results:
        print_result(result)
        if not result.converted:
            failures += 1

    successes = len(results) - failures
    print(f'\nProcessed {len(results)} file(s): {successes} succeeded, {failures} failed.')
    return 0 if failures == 0 else 1


if __name__ == '__main__':
    raise SystemExit(main())

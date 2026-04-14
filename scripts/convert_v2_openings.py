#!/usr/bin/env python3
"""
Convert V2 openings files from visual-column-with-blanks format
to explicit format with all defaults filled in.

Modifies all four vectors:
  - screen_openings, case_openings, tablet_openings  (14 columns)
  - case_additions                                   (9 columns)

Usage:
    python scripts/convert_v2_openings.py [--dry-run]
"""

import re
import os
import sys
import glob

TESTS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                         "tests", "cases")

# Sections whose rows need the 14-column treatment
OPENINGS_SECTIONS = {"screen_openings", "case_openings", "tablet_openings"}

# Section whose rows need the 9-column treatment
ADDITIONS_SECTIONS = {"case_additions"}


def tokenize_row_content(content):
    """
    Split the inner content of a row (between outer [ and ]) into tokens,
    respecting nested brackets and quoted strings.
    Returns a list of stripped strings; blank entries are represented as ''.
    """
    tokens = []
    current = []
    depth = 0
    in_string = False
    string_char = None

    for ch in content:
        if in_string:
            current.append(ch)
            if ch == string_char:
                in_string = False
        elif ch in ('"', "'"):
            in_string = True
            string_char = ch
            current.append(ch)
        elif ch == '[':
            depth += 1
            current.append(ch)
        elif ch == ']':
            depth -= 1
            current.append(ch)
        elif ch == ',' and depth == 0:
            tokens.append(''.join(current).strip())
            current = []
        else:
            current.append(ch)

    remaining = ''.join(current).strip()
    if remaining or tokens:  # always append last token (may be empty for trailing comma)
        tokens.append(remaining)

    return tokens


def get_shape(tokens):
    """Return the bare shape name from the token at index 1."""
    if len(tokens) < 2:
        return ''
    s = tokens[1]
    if s.startswith('"') and s.endswith('"'):
        return s[1:-1]
    if s.startswith("'") and s.endswith("'"):
        return s[1:-1]
    return s


def is_blank(t):
    return t == '' or t == 'undef'


def fill_defaults(tokens):
    """
    Ensure tokens has exactly 14 entries with appropriate defaults.
    Returns the updated token list.
    """
    # Pad to 14 if short (shouldn't normally happen)
    if len(tokens) < 14:
        tokens = tokens + [''] * (14 - len(tokens))
    # Trim to 14 (ignore anything beyond, e.g. a stray trailing '')
    tokens = list(tokens[:14])

    shape = get_shape(tokens)

    # ── Column [8]: anchor — blank → "L", keep "C" as-is
    if is_blank(tokens[8]):
        tokens[8] = '"L"'
    # normalise just in case
    elif tokens[8] in ('"l"', "'L'", "'l'"):
        tokens[8] = '"L"'
    elif tokens[8] in ('"c"', "'C'", "'c'"):
        tokens[8] = '"C"'

    # ── Column [9]: surface — blank → "T", "b"/"t" → "B"/"T"
    if is_blank(tokens[9]):
        tokens[9] = '"T"'
    elif tokens[9] in ('"b"', "'b'", "'B'"):
        tokens[9] = '"B"'
    elif tokens[9] in ('"t"', "'t'"):
        tokens[9] = '"T"'
    # "B" and "T" are already correct

    # ── Shape-specific column defaults
    if shape in ('vridge', 'hridge'):
        # height[2], width[3], corner[4] unused — default 0
        if is_blank(tokens[2]):  tokens[2] = '0'
        if is_blank(tokens[3]):  tokens[3] = '0'
        if is_blank(tokens[4]):  tokens[4] = '0'
        # [7]=ridge_height, [10]=length, [11]=thickness — must be explicit;
        # default to 0 only if truly blank (shouldn't happen in well-formed files)
        if is_blank(tokens[7]):  tokens[7] = '0'
        if is_blank(tokens[10]): tokens[10] = '0'
        if is_blank(tokens[11]): tokens[11] = '0'

    elif shape in ('ridge', 'cridge', 'rridge', 'crridge',
                   'aridge1', 'aridge2', 'aridge3', 'aridge4'):
        # width[3], corner[4] unused
        if is_blank(tokens[3]):  tokens[3] = '0'
        if is_blank(tokens[4]):  tokens[4] = '0'
        if is_blank(tokens[7]):  tokens[7] = '0'
        if is_blank(tokens[10]): tokens[10] = '0'
        if is_blank(tokens[11]): tokens[11] = '0'

    elif shape == 'bump':
        # width[3], corner[4] unused; diameter is at [2]
        if is_blank(tokens[3]):  tokens[3] = '0'
        if is_blank(tokens[4]):  tokens[4] = '0'
        if is_blank(tokens[7]):  tokens[7] = '0'
        if is_blank(tokens[10]): tokens[10] = '0'
        if is_blank(tokens[11]): tokens[11] = '0'

    elif shape == 'text':
        # width[3] unused
        if is_blank(tokens[3]):  tokens[3] = '0'
        # [4]=z_pos, [7]=cut/build — may be explicit; default 0 if blank
        if is_blank(tokens[7]):  tokens[7] = '0'
        if is_blank(tokens[10]): tokens[10] = '0'
        if is_blank(tokens[11]): tokens[11] = '0'

    elif shape == 'svg':
        # [4]=rotation, [7]=cut/build — may be explicit; default 0 if blank
        if is_blank(tokens[7]):  tokens[7] = '0'
        if is_blank(tokens[10]): tokens[10] = '0'
        if is_blank(tokens[11]): tokens[11] = '0'

    else:
        # Standard shapes: r, rr, c, hd, oa1-4, cr, crr, etc.
        if is_blank(tokens[4]):  tokens[4] = '0'
        if is_blank(tokens[7]):  tokens[7] = '0'
        if is_blank(tokens[10]): tokens[10] = '0'
        if is_blank(tokens[11]): tokens[11] = '0'

    return tokens


def fill_addition_defaults(tokens):
    """
    Ensure a 9-column case_additions row has explicit defaults.
    Columns: [ID, shape, height, width, corner, x, y, cut/build, [trim]]
             [0]  [1]    [2]     [3]    [4]    [5] [6]  [7]      [8]
    """
    if len(tokens) < 9:
        tokens = tokens + [''] * (9 - len(tokens))
    tokens = list(tokens[:9])
    # [4] corner: blank → 0
    if is_blank(tokens[4]): tokens[4] = '0'
    # [7] cut/build: blank → 0
    if is_blank(tokens[7]): tokens[7] = '0'
    return tokens


def is_data_row_line(line):
    """
    Return True if the line looks like a data row (starts with '[' after stripping,
    and the first token is a valid opening ID: a number, "#", or a quoted string).
    Comment lines, section headers, and the reference comment block are excluded.
    """
    stripped = line.strip()
    if not stripped.startswith('['):
        return False
    # Find the matching closing bracket at depth 0
    inner = stripped[1:]  # skip leading '['
    tokens = tokenize_row_content(inner.rstrip('],').rstrip())
    if not tokens:
        return False
    id_tok = tokens[0].strip()
    # Accept: numeric literal, "#", or a quoted string (any valid OpenSCAD ID value)
    if id_tok == '"#"' or id_tok == '#':
        return True
    unquoted = id_tok.strip('"').strip("'")
    if unquoted == '#':
        return True
    if unquoted.lstrip('-').replace('.','',1).isdigit():
        return True
    # Also accept quoted string IDs (e.g. "Ctrl", "Windows") — valid in case_openings
    if (id_tok.startswith('"') and id_tok.endswith('"')) or \
       (id_tok.startswith("'") and id_tok.endswith("'")):
        return True
    return False


def convert_data_row(line, ncols=14):
    """
    Take a line containing a V2 data row and return a converted line
    with all blank entries filled with explicit defaults.
    Preserves leading whitespace and trailing comment.

    ncols=14  screen/case/tablet openings (14-column format)
    ncols=9   case_additions (9-column format)
    """
    stripped = line.rstrip('\n')
    leading = len(stripped) - len(stripped.lstrip())
    indent = stripped[:leading]

    # Isolate trailing comment (if any) after the row's closing ]
    row_match = re.match(r'^(\s*\[)(.*?)(\]\s*,?\s*)(//.*)?$', stripped, re.DOTALL)
    if not row_match:
        return line  # can't parse, leave unchanged

    prefix    = row_match.group(1)
    inner_raw = row_match.group(2)
    comment   = row_match.group(4) or ''

    tokens = tokenize_row_content(inner_raw)

    if ncols == 14:
        if len(tokens) < 12 or len(tokens) > 15:
            return line  # unexpected structure, leave alone
        tokens = fill_defaults(tokens)
    else:  # ncols == 9
        if len(tokens) < 7 or len(tokens) > 10:
            return line  # unexpected structure, leave alone
        tokens = fill_addition_defaults(tokens)

    inner_new = ', '.join(tokens)
    result = prefix + inner_new + '],'
    if comment:
        result += ' ' + comment

    return indent + result.lstrip() + '\n'


def convert_file(filepath, dry_run=False):
    """Convert a single openings file in-place."""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    out_lines = []
    current_section = None
    changed = 0

    for line in lines:
        stripped = line.strip()

        # Detect section boundaries
        sec_match = re.match(r'^(\w+)\s*=\s*\[', stripped)
        if sec_match:
            current_section = sec_match.group(1)
        if stripped == '];':
            current_section = None

        # Convert data rows — 14-column for openings, 9-column for additions
        if current_section in OPENINGS_SECTIONS and is_data_row_line(line):
            new_line = convert_data_row(line, ncols=14)
            if new_line != line:
                changed += 1
            out_lines.append(new_line)
        elif current_section in ADDITIONS_SECTIONS and is_data_row_line(line):
            new_line = convert_data_row(line, ncols=9)
            if new_line != line:
                changed += 1
            out_lines.append(new_line)
        else:
            out_lines.append(line)

    if changed == 0:
        return 0  # nothing to do

    if not dry_run:
        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            f.writelines(out_lines)

    return changed


def main():
    dry_run = '--dry-run' in sys.argv

    # Find all V2 openings files
    pattern = os.path.join(TESTS_DIR, '**', 'openings_and_additions.txt')
    files = glob.glob(pattern, recursive=True)

    v2_files = []
    for fp in sorted(files):
        with open(fp, 'r', encoding='utf-8') as f:
            content = f.read()
        # V2 files have rows where the second field is a quoted shape name, e.g. "r", "c".
        # Detect by looking for a data row with a quoted string at position [1].
        if re.search(r'\[\s*[^,\[\]]+\s*,\s*"[a-z]', content):
            v2_files.append(fp)

    print(f"Found {len(v2_files)} V2 openings files.")
    if dry_run:
        print("DRY RUN — no files will be written.\n")

    total_changed = 0
    for fp in v2_files:
        rel = os.path.relpath(fp, TESTS_DIR)
        n = convert_file(fp, dry_run=dry_run)
        if n:
            total_changed += 1
            print(f"  {'(would modify)' if dry_run else 'Modified'} {rel}  ({n} rows changed)")

    print(f"\nDone. {total_changed} files {'would be' if dry_run else 'were'} modified.")


if __name__ == '__main__':
    main()

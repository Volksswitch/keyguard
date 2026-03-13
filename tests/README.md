# Keyguard Designer — Test Suite

## Running the tests

Just ask Claude Code:

> *"Run the tests"*

Claude will execute `tests/run_tests.ps1` from the project root, capture results, and show you any
failures or visual regressions.

To run PNG-only (faster, skips STL renders):

> *"Run the tests, PNG only"*

To run a single case:

> *"Run the tests for test-case-01"*

---

## How tests work

For each entry in `tests/cases.json`:

1. **PNG render** — renders to `tests/results/{id}.png` at 512×384 px.
   Pass = exit 0 + file created.

2. **STL render** (if `"stl"` in `checks`) — renders to `tests/results/{id}.stl`.
   Pass = exit 0 + file > 1 KB.

3. **Visual regression** — compares `tests/results/{id}.png` against `tests/references/{id}.png`
   (if a reference exists). Uses ImageMagick `compare` (pixel-exact diff) when available,
   file-size proxy otherwise.
   Status: `MATCH`, `DIFF(N px)`, or `NEW` (no reference yet).

Warnings emitted by the SCAD file are captured and counted. The always-present
`"Viewall and autocenter disabled in favor of $vp*"` warning is globally ignored.

---

## Blessing references

After reviewing the rendered PNGs visually, ask Claude to bless them:

> *"Bless the references"*

This copies all passing `tests/results/*.png` → `tests/references/*.png` and commits those
files. On subsequent runs, those references are used for visual regression.

To bless only specific cases:

> *"Bless the reference for test-case-01"*

---

## Adding a test case

1. Add a new preset to `keyguard_v76.json` (the OpenSCAD Customizer JSON).
2. Add a corresponding entry to `tests/cases.json`:

```json
{
  "id": "test-case-51",
  "preset": "Test Case 51",
  "checks": ["png", "stl"],
  "openings_fixture": null,
  "expected_warnings": []
}
```

3. Ask Claude to run the new case and bless its reference.

---

## Adding an openings fixture

When a test case requires specific content in `openings_and_additions.txt`:

1. Create the fixture file at `tests/fixtures/openings/my-fixture.txt`
   (use the same format as `openings_and_additions.txt`).
2. Set `"openings_fixture": "my-fixture.txt"` in the `cases.json` entry.

The runner will swap in the fixture before rendering and restore the original file afterwards.

---

## Version upgrades

When the designer version increments (e.g. v76 → v77), rename the SCAD and JSON files.
The test runner discovers them via glob (`keyguard_v*.scad`, `keyguard_v*.json`) and picks the
highest version automatically — no changes to `run_tests.ps1` needed.

---

## Directory layout

```
tests/
  cases.json            — test case definitions
  run_tests.ps1         — test runner (invoke via PowerShell)
  README.md             — this file
  fixtures/
    openings/           — openings_and_additions.txt variants for specific tests
  references/           — blessed reference PNGs (committed to git)
  results/              — current-run output (gitignored)
```

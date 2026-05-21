# Keyguard Designer — Claude Code Context

## Project Overview

**What does this project model?**
A parametric keyguard designer. Keyguards are physical overlays with precision cutouts that mount
over tablet screens (iPads, Surface, AAC communication devices, etc.) to help users with motor
impairments interact with touchscreen apps. The designer supports grid-based, free-form, and hybrid
layouts, and outputs either 3D-printed or laser-cut keyguards.

**Author:** Volksswitch (www.volksswitch.org) — released to the public domain (CC0)

**Main output files:**
- `keyguard.scad` — the entire parametric designer (single file)
- `keyguard.json` — named Customizer parameter sets (saved configurations)
- `openings_and_additions.txt` — user-edited include file defining custom screen/case openings
- `default.svg` — optional screenshot import (used for fit testing; only loaded when
  `include_screenshot = "yes"`)

**Target use:** FDM 3D printing and laser cutting

---

## What Is OpenSCAD?

OpenSCAD is a **script-based parametric 3D CAD tool**. Models are described entirely in code using
**Constructive Solid Geometry (CSG)** — you build shapes by unioning, differencing, and intersecting
primitive solids, rather than editing a mesh directly. There is no interactive GUI modeling; every
change is a code change.

Key implications for code work:
- "Running" the program means **rendering** it to a mesh (STL) or image (PNG).
- There is **no traditional debugging** — errors show in the console, and visual inspection of the
  rendered output is the primary feedback mechanism.
- OpenSCAD is **not a general-purpose language**. Variables are constants (evaluated at parse time,
  not runtime). There are no classes, no I/O, and no mutable state.

---

## How to Render / Test Changes

### Prerequisites
OpenSCAD must be installed and on the PATH. Test with:
```bash
openscad --version
```

### Render to STL (full geometry, for printing)
```bash
openscad -o output.stl keyguard.scad
```

### Render to PNG (quick visual check)
```bash
openscad -o preview.png \
  --camera=0,0,0,55,0,25,200 \
  --imgsize=1024,768 \
  --colorscheme=Tomorrow \
  keyguard.scad
```

### Check for syntax errors without rendering
```bash
openscad --hardwarnings keyguard.scad 2>&1 | head -40
```

### Pass parameters on the command line
```bash
openscad -o output.stl \
  -D 'type_of_tablet="iPad 9th generation"' \
  -D 'orientation="landscape"' \
  keyguard.scad
```

### Helper scripts
See `scripts/render.sh`, `scripts/preview.sh`, and `scripts/test.sh` for convenient wrappers.

---

## Running Tests

Use `scripts/test.sh` to validate changes. It has five layers, selectable via flags:

| Flag | Layer | Speed | What it checks |
|---|---|---|---|
| `--lint` | 1 | Fast | sca2d static analysis — fails on fatal errors only |
| `--syntax` | 2 | Fast | OpenSCAD `--hardwarnings` parse check |
| `--smoke` | 3 | Minutes | Render default config to STL |
| `--visual` | 4 | Slow | Run `test.json` cases in `tests/cases/`; compare PNGs against references |
| `--geometry` | 5 | Slow | Render all named configs; verify each STL is manifold + passes admesh checks |
| `--all` | 1–5 | Slow | All of the above |
| _(no flag)_ | 1–3 | Fast | Lint + syntax + smoke (good for quick checks during development) |

```bash
./scripts/test.sh                        # Fast default (lint + syntax + smoke)
./scripts/test.sh --all                  # Full suite
./scripts/test.sh --geometry             # Geometry validation only
./scripts/test.sh --capture-references   # Re-render all visual tests and save new reference PNGs
./scripts/test.sh --update-golden        # Regenerate tests/cases/golden-stl-stats.json
```

**Golden STL stats manifest** (`tests/cases/golden-stl-stats.json`): records
per-config CGAL geometry stats (volume, surface area, bbox, parts, facets) for
every named config. The web app's geometry test layer
(`keyguard-designer-web/tests/geometry.spec.mjs`) reads it as the authoritative
reference for Manifold-backend STL validation — Manifold sometimes produces
broken STLs (e.g. TC57 membranes) that pass admesh but diverge from CGAL in
surface area / part count. Regenerate via `--update-golden` whenever .scad-side
geometry intentionally changes, and commit the manifest alongside the code change.
Same render rules as `--geometry`: skips steps marked `"geometry": false`, uses
case-folder OA when one exists. Filter with `--case` to update a subset
(entries outside the filter are preserved). Add `--keep-stls` to also retain
each CGAL STL under `output/golden-stl/` (gitignored) for slicer comparison
when a gate failure needs investigating. Per-config render timeout defaults to
900s; override with `KEYGUARD_GOLDEN_TIMEOUT` for heavy cases (e.g. TC46).
Progress streams one line per config to `golden-stl-stats-progress.log`
(project root, gitignored, `tail -f`-friendly).

**Geometry validation layer (`--geometry`):** Renders every geometry-producing
preset (discovered from the test cases' `test.json`) to STL with native
OpenSCAD/CGAL — using the web app's export flags (`fudge=0.05 ff=0.05
include_screenshot="no"`) — then for each:
(1) checks `Simple: yes` (CGAL 2-manifold check) and flags `NON-MANIFOLD`;
(2) computes geometry stats and **diffs them against the committed golden
manifest** (`tests/cases/golden-stl-stats.json`) within a near-exact
CGAL-vs-CGAL threshold (vol/area 0.1%, bbox 0.01 mm, parts exact), flagging
`DRIFT`. This is the .scad self-regression gate: it catches a .scad change
that unintentionally moved geometry, or an OpenSCAD version bump. On the first
run (no manifest) it falls back to capturing one. See `docs/golden-stl-gate.md`.
`--update-golden` is the capture counterpart (writes the manifest). Both share
one render core; `--keep-stls` retains the CGAL STLs under `output/golden-stl/`.

**Visual test cases:** `tests/cases/` contains one subfolder per test case. Each folder
holds a `test.json` describing a sequence of render steps (parameters, camera position,
expected PNG). See `tests/cases/README.md` for the full format. Reference PNGs are
committed to Git. Run `--capture-references` after adding a new test case or after an
intentional visual change.

**PNG comparison:** Uses ImageMagick `compare` (RMSE < 1.0 threshold) if available;
falls back to exact SHA-256 hash comparison.

**sca2d ignored codes:**
- `I3001, I0006, I1002, I0004, I1001, I4001, I4002, I0003, I4003` — user-configured
- `E2003` — false positive: sca2d doesn't recognise `assert()` as an OpenSCAD built-in

---

## Project File Structure

```
.
├── CLAUDE.md                        ← This file
├── keyguard.scad                ← Complete parametric designer (single file)
├── keyguard.json                ← Named Customizer parameter sets
├── openings_and_additions.txt       ← Included by the .scad file; defines custom openings
├── default.svg                      ← Optional screenshot for fit testing
├── docs/
│   └── openscad-reference.md        ← OpenSCAD tips for Claude Code
├── scripts/
│   ├── render.sh                    ← Render to STL
│   ├── preview.sh                   ← Render to PNG
│   └── test.sh                      ← Multi-layer test runner
├── tests/
│   ├── baseline.sha256              ← Regression baseline checksums (committed)
│   └── cases/                       ← Visual test cases (committed)
│       ├── README.md                ← Test case format documentation
│       └── Test Case NN/            ← One folder per test case
│           ├── test.json            ← Steps, params, camera, expected filenames
│           ├── openings.txt         ← Custom openings file (optional)
│           ├── *.svg                ← Asset SVGs imported by openings.txt (optional)
│           │                           and/or screenshot SVG used as default.svg (optional)
│           └── stepN_expected.png   ← Committed reference renders
└── output/                          ← Created by scripts; not committed to Git
    ├── stl/
    ├── preview/
    └── test/                        ← Test artefacts
        ├── regression/              ← STL renders for regression layer
        └── visual/                  ← PNG renders + diff images for visual layer
```

---

## Key Parameters

All user-tunable parameters are declared near the top of `keyguard.scad`. The most
commonly adjusted ones are:

| Parameter | Default | Purpose |
|---|---|---|
| `type_of_keyguard` | `"3D-Printed"` | `"3D-Printed"` or `"Laser-Cut"` |
| `generate` | `"keyguard"` | What to output (keyguard, frame, cell insert, clip, SVG layer, etc.) |
| `type_of_tablet` | `"iPad 9th generation"` | Selects built-in tablet dimensions; supports 100+ devices |
| `orientation` | `"landscape"` | `"portrait"` or `"landscape"` |
| `have_a_case` | `"yes"` | Whether the tablet is in a case |
| `keyguard_thickness` | `4.0` | Overall keyguard thickness in mm |
| `include_screenshot` | `"no"` | Set to `"yes"` to import `default.svg` as a fit-test layer |
| `screenshot_file` | `"default.svg"` | Filename of the SVG screenshot to import |

---

## How `openings_and_additions.txt` Works

This file is pulled into the main `.scad` at line 1816 via:
```openscad
include <openings_and_additions.txt>
```

It defines four OpenSCAD vectors that the designer uses to place custom cutouts and additions:

- `screen_openings` — openings positioned relative to the screen area
- `case_openings` — openings positioned relative to the case opening
- `tablet_openings` — openings positioned relative to the tablet
- `case_additions` — solid shapes added on top of the case opening

Each row in the vectors specifies: ID, x, y, width, height, shape, slopes, corner radius, and
other options. The file also contains a large reference comment block explaining all available
special variables (screen dimensions, grid dimensions, cell sizes, camera/home button locations,
etc.).

**Do not rename or move this file** — it is referenced by name with no path prefix, so it must
remain in the same directory as `keyguard.scad`.

---

## How `default.svg` Works

When `include_screenshot = "yes"`, the designer imports `default.svg` (a screenshot of the
tablet app the keyguard is being designed for) as a 2D layer to help verify that cutout
positions align with the on-screen targets.

**The file must be named exactly `default.svg`** (hardcoded in `screenshot_file`).
It only needs to be present when this feature is in use.

---

## Code Conventions

- **Single-file design:** The entire designer lives in `keyguard.scad`. There are no
  external library dependencies — all modules and functions are self-contained.
- **Variable naming:** `snake_case` throughout
- **Parameters:** All user-tunable values are declared near the top in a clearly marked section
  with Customizer-compatible `// [option1, option2]` comments
- **Units:** All dimensions in **millimetres**
- **`$fn`:** Controlled by the `number_of_facets` parameter (default 90) rather than hardcoded
- **Version history:** Extensively documented in comments at the top of the file

---

## Design Constraints & Non-Negotiables

- **Do not alter built-in tablet dimension data** — the tablet database is carefully measured
  and any changes could produce ill-fitting keyguards
- **Do not rename `openings_and_additions.txt` or `default.svg`** — they are referenced by
  hardcoded filename in the `.scad` code
- **Do not add external library dependencies** — the designer is intentionally self-contained
  so end users only need a single `.scad` file
- **Maintain backward compatibility** of the `openings_and_additions.txt` vector format —
  users may have saved copies of this file with their own custom openings

---

## Known Issues / Current Work

### Priority Key
- **(Clean-up)** — tidy when 2+ months between releases
- **(Low)** — wait until reported as a problem
- **(Medium vXX)** — fix within the next few releases (vXX = version in which the issue was identified, to show how long it has been waiting)
- **(High)** — fix in next release
- **(Super High)** — immediate fix unless related to work in the current development

### Open Items

- [ ] (Clean-up) Go through all `translate` statements and ensure fudge is included where necessary (should be possible to make it as small as 0.001)
- [ ] (Low) "ridge around cells" doesn't play well with "cell top edge slope" and bottom edge slope
- [x] (Medium v67) Make snap-in tabs a function of the screen area thickness, not keyguard thickness. Test case 17: snap-in features not playing well with screen area thickness (keyguard frame thickness=10, keyguard thickness=6, screen area thickness=4, keyguard height=119). It's currently possible to omit snap-in tabs on the top and/or bottom — that may resolve this if keyguard width is large enough to exceed screen width.
- [ ] (Clean-up) Funky-looking raised tabs in Test Case 15
- [ ] (Low) Need to move clip-on strap pedestals and grooves inward as keyguard edge chamfer increases (Test Case 3: set keyguard edge chamfer to 3.2)
- [ ] (Clean-up) Figure out when and how to put an outer arc on the sharp corner after merging
- [ ] (Clean-up) Revisit Test Case 43 — ridges around merged cells. Also verify that widening the ridge (thickening) doesn't encroach on the interior space of a cell.
- [x] (Low) Should a portrait-oriented keyguard have raised tabs on its long side?
- [ ] (Medium) Should the outer corner on a ridge be pointed if the corner radius is 0? (If ridge gets narrow this may cause a break in the ridge at the corner — also a sharp raised feature)
- [ ] (Medium) Tablet height and width should be bezel-to-bezel, not overall tablet size, because the keyguard would sit up on the edge of the bezel when used without a case. Requires updating all supported tablet dimensions and the wording on the "extending the keyguard designer" page.
- [ ] (Low) Case elements showing up in keyguard when it has a frame and is split (Test Case 17 portrait)
- [ ] (Medium) Add more complete handling in iPad 6/7 and iPad 10/11 `openings_and_additions.txt` files for rotation and column count merging/cutting
- [ ] (Medium) Too many variables calculating borders and offsets with overlapping definitions
- [ ] (Medium) Why don't the offsets need to be part of the `case_xy0` values as well?
- [ ] (Low) Hiding the screen region doesn't play well with 2D rendering
- [ ] (Low) Add support for a centre-anchored vertical, horizontal, and angled ridge
- [ ] (Low) Test Case 10 — fillet shouldn't be in the first layer because it's removed by a `-f2` instruction. Low priority because `-` shapes are used to create features that sit up in the air, which is irrelevant for laser-cut keyguards.
- [x] (Medium) Move all quadrant and edge-based case addition shapes toward their anchor points by `ff` to eliminate the appearance of a small wall or gap on those surfaces
- [ ] (Low) MakerWorld has three known bugs: (1) displaying a keyguard frame requires `have_a_keyguard_frame="yes"` first or an odd error appears; (2) it ignores shapes less than 1.00001 mm thick when differencing; (3) it ignores anything after a comment even if separated by a carriage return
- [ ] (Medium v73) Add support for all `case_additions` shapes (including their negatives?) to `screen_openings` and `case_openings`
- [x] Make outer arcs (and potentially other shapes) placed in the screen region sensitive to cell chamfer values, and those in the case region sensitive to keyguard chamfer
- [ ] Add support for case measurements and sloped edge measurements to `openings_and_additions.txt`
- [ ] (Medium v75) Mini tabs on post mounting are not documented and are broken — rotating the tabs produces incorrect results (may be acceptable since tab rotation is only used when the keyguard edge is curved)
- [ ] (Medium v76) Test Case 1 — changing to laser-cut and generating DXF/SVG shows "Customizer settings" in the console because the related `else` statement still sees raised tabs and doesn't execute, causing the final `else` (Customizer settings) to run

---

## Code Quality Improvements (identified 2026-03-20)

A full code review was completed on 2026-03-20. Items are listed roughly highest-to-lowest priority.
Address these one at a time, running the test suite after each change.

### High Priority
- [ ] **Fix hardcoded `$fn=60`** in `cut()` (line ~4134) and `cut_2d()` (line ~4179) — these override the global `smoothness_of_circles_and_arcs` parameter; replace with the global `$fn`
- [ ] **Remove dead module** `add_manual_mount_slide_in_tabs` (lines ~6035–6125) — entirely commented out; either restore and use it or delete it
- [ ] **Deduplicate bar height conversion** (lines ~1373–1392) — the same 4-level ternary expression is repeated 5 times (once per bar type); extract into a reusable function
- [ ] **Refactor tablet lookup chain** (lines ~942–1056) — 100+ chained ternaries to select tablet data; replace with a lookup-table approach using `search()` on a `[name, data]` array

### Medium Priority
- [ ] **Name the magic numbers** — groove dimensions (lines ~1609–1611), clip offsets (~1564), scale factors (~6191–6231), and other unexplained literals should be named constants
- [ ] **Document array field indices** — `tablet_params[18]`, `tablet_params[21]` etc. are opaque; add a comment block listing what each index means
- [ ] **Rename cryptic variables** — `sxo`, `xtls`, `ytbs`, `ff`, `sat`, `cts`, `cbs` and similar abbreviations should have clearer names or at least a legend
- [ ] **Add `type_of_tablet` validation** — if the tablet name matches nothing the designer silently falls back to default data; add an echo warning when this happens
- [ ] **Add opening dimension validation** — zero or negative widths/heights in `screen_openings` / `case_openings` fail silently; add guards with informative echoes
- [ ] **Catch conflicting settings early** — e.g. laser-cut + cell inserts, incompatible frame/case settings — add an explicit validation section near the top
- [ ] **Deduplicate case additions logic** (lines ~5470–5599) — near-identical `add`/`sub` blocks with trimming logic repeated 4+ times; extract shared logic into a module
- [ ] **Remove `#` debug modifiers from production code** — `#cut_opening(...)` etc. appear in ~20 locations; safe as examples but risky if copied into active geometry

### Lower Priority
- [x] **Move version history to `CHANGELOG.md`** — the 493-line header dominates the file; keep only a brief note pointing to the external file
- [x] **Add a module index near the top** — 87+ modules with no table of contents; a brief index would aid navigation
- [x] **Standardise docstrings** — some modules have them, others don't; ensure all public modules have consistent docblock comments
- [x] **Document initialisation order** — ~200 global variables must be defined in a specific sequence; add a clear warning comment so future edits don't accidentally break ordering
- [x] **Use named string constants** — values like `"yes"`, `"landscape"`, `"3D-Printed"` appear in many conditionals; typos fail silently; define constants at the top for the most-used ones

---

## Working Conventions

### Git workflow
1. Before starting any code change, run `git status` in the main project folder. If Ken has
   made manual edits, commit them immediately with the message `"Save manual edits before
   automated work"` before touching anything else.
2. Do all code work in a worktree branch — never edit files directly in the main project
   folder. This prevents keyguard.json merge conflicts. If a conflict does occur in
   `keyguard.json`, resolve it with `git checkout --theirs keyguard.json` (the worktree
   version is authoritative).
3. After each successful change, immediately merge the worktree branch into `main` and push
   — do not wait to be asked.
4. Commit and push all changes immediately after completing them. Do not wait for the user
   to ask.

### Testing
- **Always read `scripts/test.sh` before running it.** Never assume flags, paths, or
  behavior from memory or CLAUDE.md alone — the script is the authoritative source.
- `test-timings.ndjson` is deleted automatically at the start of every `test.sh` run —
  no need to delete it manually.
- Run `scripts/test.sh` (layers 1–3) after any change as a quick sanity check.
- Run `scripts/test.sh --visual` before declaring a feature complete.
- **Never run `--geometry` or `--all` without explicit permission from Ken.** Geometry
  tests render every named config to STL and take a very long time. Always explain why
  they are needed and wait for approval before running them.

#### Scope test runs to what you are validating

The full visual suite takes ~25 minutes. When iterating on a **localized bug** —
a regression flagged in one or two specific test cases while you are fixing a
single feature — run **only** those test cases, not the full suite. Each tight
debugging cycle should be measured in single-digit minutes, not in 25-minute
suite runs.

Use the full `--visual` suite for the **landing** step, when you believe a phase
is complete and want to confirm nothing unrelated regressed. Use it for the
**baseline** step, when you need to know whether a failing case was already
failing before your change. **Do not** use it as your inner-loop validation
tool while iterating on a known regression.

Rule of thumb before launching any test run: *"Which test cases could possibly
produce different output as a result of the change I just made?"* If the answer
is a short, specific list, run only that list. If the answer is genuinely "any
of them could," run the full suite.

This applies equally to the geometry, smoke, and lint layers — match the test
scope to the change being validated, not to habit.

---

## Code Style Preferences

- **Cryptic variable names are intentional** — `sxo`, `xtls`, `ytbs`, `ff`, `sat`, `cts`,
  `cbs`, `cec`, `kec`, `kw`, `kh`, `cm` (crescent moon shape), etc. are deliberate
  abbreviations chosen by the author. Do not flag, rename, or "clean up" these names.
- **Prefer short expressions over abstraction** — Ken prefers concise repeated patterns over
  extracting shared logic into helper functions, unless duplication is extreme.
- **Module index line numbers** drift after insertions and need periodic systematic updates —
  do not update individual entries ad hoc.

---

## OpenSCAD Gotchas — Please Read

See `docs/openscad-reference.md` for a full reference. Critical points:

1. **Variables are constants.** You cannot reassign a variable inside a scope and have it affect
   later geometry. Use conditional expressions or modules instead.
2. **`use` vs `include`:** `use <lib.scad>` imports only modules/functions (not variables).
   `include <lib.scad>` is like a literal copy-paste — it brings in variables too.
   `openings_and_additions.txt` uses `include` so its vector variables are available globally.
3. **Preview vs render:** The F5 preview uses OpenCSG (fast but approximate). F6/`-o .stl` uses
   CGAL (slow but exact). A model can look fine in preview and fail to render.
4. **Non-manifold geometry is silent:** OpenSCAD will silently produce broken STLs if geometry
   is non-manifold. Always check rendered STLs in a slicer after significant changes.

---

## Asking Claude Code for Help

Suggested prompts:

- *"Render `keyguard.scad` and show me any errors or warnings."*
- *"The cutout for the home button is 1 mm too narrow. Find and fix the relevant code."*
- *"Add a new tablet — the Acme Tab X with screen dimensions 180 × 240 mm."*
- *"Explain how the `screen_openings` vector in `openings_and_additions.txt` is processed."*
- *"Add a parameter to control the chamfer depth on the top edges of all openings."*
- *"Generate a PNG preview of the current design and show it to me."*

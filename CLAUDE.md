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

## ⚠ The web app: TWO folders exist, and only one is live

This project has a companion web app. There are two sibling folders for it and
they look nearly identical — editing the wrong one feels completely normal and
changes nothing any clinician runs. **This has happened twice** (1 Sep 2026, and
again 17 Sep 2026 while adding keyguard inset mode).

| Folder | Repo | What it is |
|---|---|---|
| **`…/Keyguard/keyguard-web`** | `Volksswitch/keyguard-web` | **THE LIVE APP.** Serves `keyguard.volksswitch.org`. Its `CLAUDE.md` governs. |
| `…/Keyguard/keyguard-designer-web` | `Volksswitch/keyguard-designer-web` | **RETIRED APP**, frozen at the old address. Gets no updates, ever. |

**`APP_RELEASE` in `app.html` tells them apart instantly: ≥100 is live, ≤21 is
retired.** Check it before believing you are in the right place.

The retired folder is NOT dead weight, which is what makes this confusing: the
**Playwright test harness** (`tests/`), **`RELEASING.md`**, the **RTP/cross-compare
tooling** and the **RTP trigger phrases** still live ONLY there and are still
authoritative there. So a path under `keyguard-designer-web` in this file is
correct when it names harness or tooling, and wrong if it seems to name the app.

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
(`keyguard-designer-web/tests/geometry.spec.mjs` — the harness folder, not the
live app; see the two-folder warning above) reads it as the authoritative
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

**RTP (ready-to-print) fixtures** (`tests/rtp/`): a SECOND test corpus,
separate from the TC `tests/cases/` corpus above. It holds the real clinician
"ready-to-print" designs: `keyguard.json` (RTP presets — distinct from the
root TC `keyguard.json`), the OA tree (`Cases and App Specifics/`, `Standard
Openings and Additions/`), the preset→OA / preset→golden mapping CSVs, and
`golden-stl/` (the keep-forever CGAL golden `golden-rtp-cgal-stats.json` plus
the downloaded-website stats and `manifest.csv`). `keyguard.scad` is NOT
duplicated here — RTP renders use the project-root `keyguard.scad`. The web
app's `tests/ready-to-print.spec.mjs` consumes this via `KEYGUARD_RTP_ROOT`
(default: `<this project>/tests/rtp`), and `compare-rtp-membranes.py` diffs the
app's Manifold export stats against the CGAL golden. Relocated here from the
former Desktop `Web-App-Test` folder on 2026-05-23.

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
| `screenshot_filename` | `"screenshot.svg"` | Filename of the SVG screenshot to import |

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

**The filename is set by the `screenshot_filename` parameter** (default `"screenshot.svg"`).
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
- **Changelog-as-you-go (mandatory):** `CHANGELOG.md` is kept **in lockstep with the root
  `keyguard.scad`** — it is NOT a pre-release step. The moment you change `keyguard.scad` in a way
  a clinician can see or do differently (a new feature or a visible bug fix), add or edit the
  matching plain-English entry under the topmost **`## Unreleased (next release)` heading**
  (replace its `- _In development._` placeholder with the first real bullet; it is renamed to
  `## Version N` at release) **in the same edit, before you consider that change
  done** — so the code Ken tests in the root and the changelog he reads always describe the same
  program. Write it the way a clinician would read it, matching the voice of the existing bullets.
  This matters more here than usual: the web app's `publish-scad-version.mjs` copies this section
  **verbatim** into `latest_scad_version.json`, which is exactly the "What's new" list clinicians
  see in the in-app **Keyguard update** dialog — so these bullets are literally clinician-facing
  UI text, not just a repo note. **This cuts both ways: if a feature or fix is later backed out of
  `keyguard.scad`, delete its `## Version N` entry in the same edit.** The section must always
  mirror exactly what is in the root code — no more, no less. **Exclude** internal-only changes
  (tests, tooling, refactors, geometry-harness work with no visible effect); when in doubt, ask
  Ken. **Committing is Claude's job, never Ken's** — Ken does not run git/commit commands; Claude
  commits the code + changelog change together as part of finishing the work. **Ken's own edits to
  `CHANGELOG.md` are authoritative and must be preserved** — he may reword, reorder, or rewrite
  entries whenever he likes; treat his phrasing as final. Only ever make *surgical* changes to
  `CHANGELOG.md` (a targeted `Edit`, NEVER a whole-file `Write` or regenerate): add an entry when
  new clinician-facing code lands, delete one when a change is backed out, and otherwise leave the
  file exactly as Ken left it. Never overwrite, reword, or reorder his existing entries; if you
  believe one is inaccurate, ask him rather than change it. At release the notes are already
  complete — the ritual only renames `## Unreleased (next release)` to `## Version N`; nothing is
  authored at the end. See [RELEASING.md](RELEASING.md) for the full release ritual.

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
- **Do not introduce a UTF-8 BOM in `keyguard.json`.** OpenSCAD 2021.01 (the official
  release, which Ken and many users run) rejects a BOM-prefixed parameter file with
  `expected value` at column 1 and silently falls back to .scad defaults — the
  Customizer GUI's preset dropdown stops loading any preset, and the CLI's
  `-p keyguard.json -P "..."` does the same. The file must start with `{` as its
  first byte. A BOM was accidentally added by commit `0360338` (the
  `mounting_method` rename) and lurked for a couple of weeks before anyone
  noticed; strip it back out (commit `d673077`). When editing
  `keyguard.json` programmatically, read it as `utf-8-sig` (which discards a BOM
  if present) and write it back as `utf-8` (no BOM) with `\r\n` line endings to
  match the existing format. `scripts/test.sh` has a defensive BOM-strip preflight
  for the CLI path, but that doesn't help the GUI — the on-disk file itself must
  stay BOM-less.

---

## Known Issues / Current Work

### Pending Uncommitted Branches (do not lose track of these)

_(none currently)_

### Backward-Compatibility Notes

- **`mounting_method = "- none -"`** (renamed from `"No Mount"`, 2026-06-03). No normalization
  shim exists in `keyguard.scad` — the code only recognises `"- none -"`. OpenSCAD's Customizer
  silently maps an unrecognised preset value to the first dropdown option, so user-held `.json`
  presets self-heal on load. Two paths could still pass the old string to the WASM renderer and
  produce incorrect output: (1) command-line `-D 'mounting_method="No Mount"'`; (2) the web app
  forwarding a saved `"No Mount"` value directly to WASM. If either surfaces as a bug, add a
  normalization variable near the top of `keyguard.scad`:
  ```openscad
  _mm_norm = (mounting_method == "No Mount") ? "- none -" : mounting_method;
  ```
  and thread `_mm_norm` through all comparison sites.

### Priority Key
- **(Clean-up)** — tidy when 2+ months between releases
- **(Low)** — wait until reported as a problem
- **(Medium vXX)** — fix within the next few releases (vXX = version in which the issue was identified, to show how long it has been waiting)
- **(High)** — fix in next release
- **(Super High)** — immediate fix unless related to work in the current development

### Open Items

- [x] (Clean-up) Remove or gate explicit `color()` calls on specialty output types — normalised to
  Turquoise for all non-SVG/DXF output (e640262 + visual refs updated 72f8712, 2026-06-04)
- [x] (Clean-up) Go through all `translate` statements and ensure fudge is included where necessary (should be possible to make it as small as 0.001)
- [x] (Low) "ridge around cells" doesn't play well with "cell top edge slope" and bottom edge slope
- [x] (Medium v67) Make snap-in tabs a function of the screen area thickness, not keyguard thickness. Test case 17: snap-in features not playing well with screen area thickness (keyguard frame thickness=10, keyguard thickness=6, screen area thickness=4, keyguard height=119). It's currently possible to omit snap-in tabs on the top and/or bottom — that may resolve this if keyguard width is large enough to exceed screen width.
- [ ] (Clean-up) Funky-looking raised tabs in Test Case 15
- [x] (Low) Need to move clip-on strap pedestals and grooves inward as keyguard edge chamfer increases (Test Case 3: set keyguard edge chamfer to 3.2)
- [x] (Clean-up) Figure out when and how to put an outer arc on the sharp corner after merging
- [ ] (Clean-up) Revisit Test Case 43 — ridges around merged cells. Also verify that widening the ridge (thickening) doesn't encroach on the interior space of a cell.
- [x] (Super High v79) Merged-cell ridge — square/rectangular merge produces a spurious free-floating small ridge floor in the middle of the opening (instead of just the outer perimeter ridge). Visible when merging a 2×2 (or larger) rectangular block of cells. Fixed b2674e1: `merged_group_ridge` now detects when both ends of a bridge transverse are INTERIOR (perpendicular bridge present AND diagonal cell in group) and suppresses the transverse instead of drawing it. TC43/TC59 unaffected.
- [x] (Super High v80) Merged-cell ridge — U-shaped, horseshoe-shaped, C-shaped, and other concave-perimeter merges failed to wrap the ridge around the central "tooth" (the interior cell wall sticking into the merged opening); the perimeter ridge stopped at the outer boundary and left the tooth ridge-less. Repro arrived 2026-06-07 as "u and horse shoe.json" (4×3 grid, v-merge 1,2,3,4 + h-merge 5,3, ridge around cells 1,3). Fixed in `merged_group_ridge`: (a) the bridge-transverse "interior" suppression now also checks that the wall on the far side of the transverse is bridged (`search(c±ncols, m_cell_h)` / `search(c±1, m_c_v)`) — without that, a U/horseshoe's tooth-top transverse was incorrectly suppressed as if it were a square-merge 2×2 interior; (b) per-cell side-ridge offsets at an XOR-diag-in corner now terminate flush (offset 0) instead of extending by `_ov`, so the side ridge meets the new tooth-top transverse with a clean square corner. Test Case 61 added as the regression gate.
- [x] (Super High v80) Merged-cell ridge — round the convex tooth-tip corners (the earlier v80 fix left them square). Done 2026-06-07. Each tooth tip gets an OA cut (in `cells()`) that rounds the tooth SOLID corner at radius `eff_mrr` (=mrr+t with a ridge, else `ccr`) plus a convex `aridge` (in `merged_group_ridge`) sitting on that rounded corner. Key subtlety that took three passes: the tip sits at the **capping cell** — the cell across the inter-cell RAIL whose perpendicular bridge caps the tooth — not at the flanking cell whose corner "owns" the tip. With zero rail they coincide; with real (wide) rails the fillets landed stranded mid-tooth (Ken's "special test case", right merge). Fix: new helpers `_cell_ox/_cell_oy/_cell_ow/_cell_oh` give any cell's opening rect (with the loops' row/col trims), so the along-tooth coordinate is the capping cell's edge while the cross-tooth coordinate stays the tooth wall; convex offset is `+t` (matching the interior-convex aridge). Also REMOVED the tooth-tip shortening from the flanking cell's side ridges — that edge is mid-tooth, so shortening there punched a gap into an otherwise continuous tooth side; the bridge transverse that actually reaches the tip handles the shortening instead. Gates: TC61 (U/horseshoe vertical teeth), TC62 (C/backward-C horizontal teeth), TC63 (snake, 3 teeth incl. an asymmetric one), TC64 (Ken's "special test case" — covered-cell tooth vs rail tooth side by side). Non-tooth merges (TC43/TC59) unaffected (every changed branch keys on a real tooth tip).
- [x] (Super High v80) Merged-cell ridge — tooth-tip cleanup follow-up (2026-06-07). Three residual defects, all traced via CGAL top-down zoom renders of the "special test case": (1) **divots** — small notches wherever two merged-perimeter ridge segments butt at a tangent (convex corners, tooth tips), caused by the 0.5mm end chamfers in `ridge()`. Fixed per Ken's additive-overlap approach: new `_mridge()` wrapper extends each merged-perimeter segment by the chamfer width (0.5) at BOTH ends so every chamfer buries under its neighbour, exactly matching the continuous `rounded_rectangle_wall` the non-merged ridge is built from. `ridge()` itself is untouched (still chamfered for OA additions / free ends). All 8 straight-segment calls in `merged_group_ridge` now use `_mridge`. (2) **vertical-tooth tabs** (TC61/63, special right-U) and (3) **horizontal-tooth tabs + overlong cap** (TC62) — bridge-transverse ends overshot the tip aridge tangent by a chamfer width because the tooth-tip retraction only fired for a PERPENDICULAR tooth (direction-specific `=="W"`/`=="N"`/`=="S"`), missing the COLLINEAR rail-tooth case (`"N"` along a vertical transverse) and the horizontal-tooth cap (`"E"`/`"W"`). Fixed by replacing all 8 direction-specific checks with the general rule `_tt_dir != "" ? shorten : 0` — retract at ANY tooth tip, offset 0 only at a true 2×2 interior corner. Verified clean (no tabs/divots/breaks) on the special test case, TC61, TC62, TC63 (incl. asymmetric snake tooth), TC64; TC43/TC59 pass visual unchanged (overlap is sub-threshold; `_tt_dir != ""` is a no-op without a tooth).
- [x] (Low) Should a portrait-oriented keyguard have raised tabs on its long side?
- [x] (Medium) Should the outer corner on a ridge be pointed if the corner radius is 0? (If ridge gets narrow this may cause a break in the ridge at the corner — also a sharp raised feature)
- [x] (Medium) Tablet height and width should be bezel-to-bezel, not overall tablet size, because the keyguard would sit up on the edge of the bezel when used without a case. Requires updating all supported tablet dimensions and the wording on the "extending the keyguard designer" page.
- [x] (Low) Case elements showing up in keyguard when it has a frame and is split (Test Case 17 portrait)
- [x] (Medium) Add more complete handling in iPad 6/7 and iPad 10/11 `openings_and_additions.txt` files for rotation and column count merging/cutting
- [x] (Medium) Too many variables calculating borders and offsets with overlapping definitions
- [x] (Medium) Why don't the offsets need to be part of the `case_xy0` values as well?
- [x] (Low) Hiding the screen region doesn't play well with 2D rendering. **FIXED
  2026-09-17** (see below for the diagnosis that led to it). `lc_keyguard` now applies
  all three region cuts in its last-minute-cuts slot, and `cut_screen`/`cut_app`/`cut_grid`
  each grew a flat `t=0` branch (`square` instead of `cube`) alongside the 3D one, the same
  shape `case_opening_blank` already uses. Verified: all three settings now cut in 2D, and
  all 174 presets render byte-identical CSG in 3D. **Still outstanding:** the
  `column_count`/`row_count` zeroing on `hide_screen_region=="yes"` (line ~1348) is now dead
  in BOTH paths and could be removed — it would change only console output (rail-width
  warnings and the `__KG_DIMS__` rail echo would start reporting for a hidden screen), not
  geometry. Left in place deliberately; ask Ken before removing. Original diagnosis:
  **Diagnosed
  2026-09-17.** The laser-cut path (`lc_keyguard`, reached only by
  `generate="first layer for SVG/DXF file"`) never calls `cut_screen()` / `cut_grid()` —
  those calls exist ONLY in `keyguard()` and `keyguard_frame()`. So in 2D the setting
  cannot remove the screen area; you get a solid slab with the grid missing, not a hole.
  The zeroing of `column_count`/`row_count` on `hide_screen_region=="yes"` (line ~1348) is
  the workaround that makes the setting do *anything* at all in 2D: verified by removing
  it — the 2D render then comes out pixel-identical to not hiding at all. On the 3D path
  that zeroing is **redundant**: verified identical with and without it for a plain grid,
  a grid with raised ridges, and a keyguard frame (the screen cutter spans well above the
  top face, so it takes the ridges too). **This is one bug, not two.** The real fix is to
  give the laser-cut path its own region cuts, after which the zeroing can come out
  entirely. `hide_app_region` (added 2026-09-17) has the SAME gap for the same reason —
  fix all three together. NOTE: the web app hits this too; its SVG button drives the same
  `keyguard.scad` with the same two flags, so it is not a desktop-only issue.
- [x] (Low) Add support for a centre-anchored vertical, horizontal, and angled ridge — C-anchor added for hridge, vridge, angled ridge, rridge (9af16c3)
- [x] (Low) Test Case 10 — fillet shouldn't be in the first layer because it's removed by a `-f2` instruction. Low priority because `-` shapes are used to create features that sit up in the air, which is irrelevant for laser-cut keyguards.
- [x] (Medium) Move all quadrant and edge-based case addition shapes toward their anchor points by `ff` to eliminate the appearance of a small wall or gap on those surfaces
- [x] (Low) MakerWorld has three known bugs: (1) displaying a keyguard frame requires `have_a_keyguard_frame="yes"` first or an odd error appears; (2) it ignores shapes less than 1.00001 mm thick when differencing; (3) it ignores anything after a comment even if separated by a carriage return
- [x] (Medium v73) Add support for all `case_additions` shapes (including their negatives?) to `screen_openings` and `case_openings`
- [x] Make outer arcs (and potentially other shapes) placed in the screen region sensitive to cell chamfer values, and those in the case region sensitive to keyguard chamfer
- [x] Add support for case measurements and sloped edge measurements to `openings_and_additions.txt`
- [x] (Medium v75) Mini tabs on post mounting are not documented and are broken — rotating the tabs produces incorrect results (may be acceptable since tab rotation is only used when the keyguard edge is curved)
- [x] (Medium v76) Test Case 1 — laser-cut + Raised Tabs/Clip-on Straps now emit a clear error instead of falling through to "Customizer settings" (lc-mount-errors branch)
- [x] (Medium v77) Test Case 53 renders NON-MANIFOLD in CGAL (`Simple: no`; the solid splits into 7 disconnected parts — vol=146705.59, area=81361.13, parts=7). **Resolved 2026-05-31**: hand-rendered and opened in PrusaSlicer — "No errors detected". CGAL's strict 2-manifold check is a false positive here; the STL is printable. TC53's step is now marked `"geometry": false` in its test.json to exempt it from the CGAL gate. Stats are still captured in `golden-stl-stats.json` for reference.
- [x] (Low) Native OpenSCAD desktop F5 (OpenCSG) preview shows spurious "membrane" triangles in cell openings — a preview-only z-fighting artifact from the cut tools' near-coincident faces; F6/CGAL and STL export are clean, so it is purely cosmetic. Distinct from the Manifold/web-app cell-floor membrane fixed in v78 (the `hole_cutter` single-prism refactor) — that one was real geometry. Verified fix approach: gate the screen through-cut extender on `$preview` in `cut_opening_v2` (the extender already exists for `extend_through_cuts`); `$preview` is false during F6/STL export, so the preview becomes faithful while the exported geometry stays byte-identical. Prototyped 2026-05-24, set aside to focus on the web-app issue; not merged.

---

## Code Quality Improvements (identified 2026-03-20)

A full code review was completed on 2026-03-20. Items are listed roughly highest-to-lowest priority.
Address these one at a time, running the test suite after each change.

### High Priority
- [x] **Fix hardcoded `$fn=60`** in `cut()` (line ~4134) and `cut_2d()` (line ~4179) — these override the global `smoothness_of_circles_and_arcs` parameter; replace with the global `$fn`
- [x] **Remove dead module** `add_manual_mount_slide_in_tabs` (lines ~6035–6125) — entirely commented out; either restore and use it or delete it
- [x] **Deduplicate bar height conversion** (lines ~1373–1392) — the same 4-level ternary expression is repeated 5 times (once per bar type); extract into a reusable function — now `function bar_height(px_val, mm_val)` at line ~1133
- [x] **Refactor tablet lookup chain** (lines ~942–1056) — 100+ chained ternaries to select tablet data; replace with a lookup-table approach using `search()` on a `[name, data]` array

### Medium Priority
- [x] **Purge V1-flavored parameter names from V2 code paths** (e.g. `top_slope_mm` → `cb_mm`, `bottom_slope_mm` → `thickness_mm`, `left_slope` → `rotation` inside `place_addition_v2` / `cut_opening_v2` and their V2 dispatchers). Leave the V1 `place_addition` / `cut_opening` modules untouched so V1 OA files still process unchanged — the `is_v2()` dispatcher already routes V1 rows there. Also update the guard warning strings to use V2 terms ("invalid length, cb, or thickness" instead of "invalid dimensions or slopes"). Rename one module at a time; after each, run `scripts/test.sh` then a scoped visual on OA-heavy cases (TC3, TC15, TC17, TC18, TC24, TC43, TC47). Watch out for two traps: (1) any named-arg call sites (grep before renaming); (2) the `ttext` branch overloads those slots as font/halign/valign strings, so pick neutral names there. Motivation: the slope-named params caused real diagnostic confusion (2026-05-27 thread on a `vridge` guard). — Done 2026-05-29: `place_addition_v2` only; `cut_opening_v2` skipped (collides with its existing `rotation=0` param + `left_slope` is a real slope there); V2 dispatcher locals also skipped (they're slot-provenance names, not module params).
- [x] **Name the magic numbers** — groove/pedestal/clip display constants named (c55873e); clip body geometry constants named: clip_chamfer_depth/leg, clip_spur_profile, bumper dims, strap slot dims (clip-magic-numbers branch)
- [x] **Document array field indices** — comment block at line 556 documents all 22 fields (indices 0–21)
- [x] **Rename cryptic variables** — intentionally short; these are the public API for user O&A files and must not be renamed
- [x] **Add `type_of_tablet` validation** — if the tablet name matches nothing the designer silently falls back to default data; add an echo warning when this happens — warning echo now at line ~807
- [x] **Add opening dimension validation** — zero or negative widths/heights now warn and skip (1e74aee)
- [x] **Catch conflicting settings early** — all known invalid laser-cut combos now emit errors: laser+frame, laser+cell inserts, laser+Raised Tabs, laser+Clip-on Straps (lc-mount-errors branch closes the last two gaps)
- [x] **Deduplicate case additions logic** — moot: `my_*` parameters (the source of the duplication) are slated for removal in a future release (originally added for MakerWorld support)
- [x] **Remove `#` debug modifiers from production code** — O&A context replaced with color() overlays (01e95f4); remaining instances in built-in geometry (frame ghost, split-line guide, magnet indicator, text highlight) are all intentional visualization tools and should stay

### Lower Priority
- [x] **Move version history to `CHANGELOG.md`** — the 493-line header dominates the file; keep only a brief note pointing to the external file
- [x] **Add a module index near the top** — 87+ modules with no table of contents; a brief index would aid navigation
- [x] **Standardise docstrings** — some modules have them, others don't; ensure all public modules have consistent docblock comments
- [x] **Document initialisation order** — ~200 global variables must be defined in a specific sequence; add a clear warning comment so future edits don't accidentally break ordering
- [x] **Use named string constants** — values like `"yes"`, `"landscape"`, `"3D-Printed"` appear in many conditionals; typos fail silently; define constants at the top for the most-used ones

---

## Working Conventions

### Recording feedback
- **Always record ongoing-behavior feedback in this `CLAUDE.md`, never in the per-machine
  memory system.** Memory is per-machine and does not sync — both machines must see the rule,
  so it has to live in the shared OneDrive-synced `CLAUDE.md`. Applies equally to the
  web app — which means **`keyguard-web`'s `CLAUDE.md`**, the live one. Do not record
  feedback in the retired `keyguard-designer-web`; nothing reads it.

### Version bumps

The full release process is in **[RELEASING.md](RELEASING.md)** — the same shape used
across all Volksswitch projects (*work locally; log user-visible changes to
`## Unreleased` in clinician language; say **"bump keyguard designer"** to release*).
The essentials specific to the `.scad`:

- **PC = dev, GitHub = release, single `main`.** Commit each change to local `main` but
  do **not** push; the copy of `keyguard.scad` on `main` is what clinicians download, so
  **pushing `main` is the release.** Nothing is pushed between releases.
- **`keyguard_designer_version`** (in `keyguard.scad`, line ~522) is **pre-bumped** to
  `(last release + 1)` at the end of each release, so the dev banner always reads one
  ahead of public. The pre-bump lives **locally only (unpushed)** until its release.
- **The updater gate (this bit us once):** on GitHub `main`, `keyguard.scad`'s version and
  `latest_scad_version.json`'s `version` must **always match** — the web app's updater
  downloads `main/keyguard.scad` and **aborts** if the two disagree. So a pre-bumped
  `.scad` never reaches `main` ahead of a matching manifest; at release the file and the
  manifest are pushed together, both reading `N`.
- **`## Unreleased (next release)` in `CHANGELOG.md`** holds the in-dev clinician notes; at
  release it is renamed to `## Version N` and `publish-scad-version.mjs` copies those
  bullets verbatim into the manifest (it reads the version from the constant and the notes
  from `## Version N`, falling back to `## Unreleased`).

### Progress logging (mandatory)
- **For ANY multi-step or long-running task, continuously write progress to a single
  human-readable log file named `progress.log` at the MAIN project root** (the
  OneDrive-synced `…/keyguard designer/` folder — derive it from `$env:OneDrive`, never
  hardcode a user path). This is the minimum bar: progress MUST be discoverable there
  even when it is also tracked elsewhere (the task list, the chat, or a per-job log).
- **Always write to the MAIN project root, never a worktree root**, even when the code
  work happens in a worktree under `C:\kg-wt\…`. Logs buried in a worktree are invisible
  to Ken and to the other machine; the whole point is that anyone can
  `tail -f "…/keyguard designer/progress.log"` regardless of which worktree is active.
- **Every record MUST begin with a wall-clock timestamp** in `[YYYY-MM-DD HH:MM:SS]`
  form (local time). No exceptions — a line without a leading timestamp is a bug. When you
  mirror a background job's output into `progress.log`, prepend the timestamp at the moment
  you write the line. Append timestamped lines as each step starts and finishes — what was
  done, status, and the key result (e.g. a render's vol/area/parts, a test's PASS/FAIL
  count, a commit SHA). Append; do not overwrite (this is a running session journal).
  `progress.log` is gitignored — git is the history of the code, `progress.log` is the
  history of the work.
- Background jobs (renders, test suites) may ALSO keep their own stable per-job logs
  (see Log file naming below), but their progress must flow into `progress.log` LIVE —
  redirect/tee the job into the main log from the start (timestamping each line), or run a
  follower that mirrors new lines as they appear. Do not leave a running job's progress
  stranded in a worktree-local log where Ken cannot see it.

### Log file naming
- **For any test/job whose stdout you redirect to a log, use a stable per-job-type
  filename (e.g. `geometry-gate.log`, `visual-update.log`, `compare-visual-references.log`).
  Never name the log after the specific subset being run** (`geometry-tc43-tc59.log`,
  `visual-tc18.log`, etc.). Stable names mean Ken, both machines, and future sessions
  always know where to look — and `tail -f <name>.log` keeps working regardless of scope.
  The previous run's log is overwritten; git is the history.

### Git workflow

**Mental model:** a **worktree** is the dev sandbox; the **root project folder** is
Ken's test bench (he thinks of it as "main"). Ken does all his manual testing in the
root folder and does not want to hunt for the right worktree. **GitHub (`origin`) is
the deployed/release channel** — it is updated ONLY on Ken's explicit command.

1. Before starting any code change, run `git status` in the root project folder. If Ken
   has made manual edits, commit them locally first with the message `"Save manual edits
   before automated work"`.
2. Do development in a worktree branch — do your iterative/exploratory editing there, not
   directly in the root folder. This keeps the root folder stable and avoids `keyguard.json`
   churn. If a `keyguard.json` conflict occurs, resolve it with
   `git checkout --theirs keyguard.json` (the worktree version is authoritative).
3. **When a change is ready for Ken to test, DELIVER it into the root project folder** —
   merge the worktree branch into local `main` (or copy the files) — so Ken always tests in
   the one familiar place and never has to locate a worktree.
4. **NEVER push to GitHub (`origin`) on your own.** A changed file's presence in the root
   folder does **not** qualify it for GitHub. Committing locally to `main` is fine and
   expected; **pushing to `origin` happens ONLY when Ken explicitly directs it** — that is
   his release action (see Version bumps). Local `main` may sit ahead of `origin/main` with
   unpushed dev work; that is the normal, intended state between releases.
   - **Why:** GitHub `main` is served straight to clinicians (the web-app updater downloads
     raw `main/keyguard.scad`), so anything pushed to `main` is effectively deployed.
     Un-commanded pushes have deployed unreleased, pre-bumped work and broken the updater.

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

#### Test-file cleanup is deferred to the next significant .scad change (Ken, 2026-08-05)

Ken's standing decision: **the testing-related files get cleaned up in one pass when we
next make really significant changes to the `.scad` code** — not piecemeal as small
changes land. So when a change leaves a reference or a captured artifact stale, **say so
once and move on**; do not offer to regenerate it each time, and do not treat a stale
reference as blocking a release (v84 and web Release 18 both shipped with one outstanding).

Known outstanding as of 2026-08-05:
- The **web app's** visual reference PNGs — stale for every case containing an O&A
  highlight, after the highlight material went solid (web `4057ef7`). The `.scad`'s own
  visual references are NOT affected by that change (it is web-side only).

When the cleanup window arrives, ask Ken what he wants in scope before starting — "clean
up the testing files" could reasonably mean regenerating references and goldens, clearing
out accumulated logs and `-Helix2` duplicates, or both.

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

## Multi-Machine Work & Trigger Phrases

Work happens on **two machines** (a laptop and a faster desktop) that share **one
OneDrive copy** of this project. Either machine may be used depending on CPU
availability.

**For that to work, every workflow and trigger phrase must be written HERE in
`CLAUDE.md`** — not just established in a chat on one machine. `CLAUDE.md` syncs
via OneDrive and is auto-loaded by Claude in this project, so it is the only
shared "brain" across machines. (Claude's own memory lives under
`C:\Users\<user>\.claude\` and is **per-machine — it does NOT sync**, so never
rely on memory for anything the other machine needs to know.)

A session loads `CLAUDE.md` at startup, so after this file changes, a session
already running on the other machine must be **restarted/reloaded** (and OneDrive
must have synced the file) to pick up the change.

### Machine-name suffixed files are ALWAYS suspect (`…-Helix2…`, or any machine name)

OneDrive resolves a two-machine edit collision by keeping both versions and
renaming one after the machine that lost — `app-Helix2.html`, `CLAUDE-Helix2.md`,
`keyguard-Helix2.scad`, `progress-Helix2.log`. **These are sync-conflict debris,
never authoritative.** `Helix2` is one machine's name; the same thing happens
under the other machine's name, so treat **any** `-<MachineName>` suffix the same
way.

**The test is whether the same name WITHOUT the machine suffix exists:**

- **Canonical twin exists** (the normal case) → the suffixed file is a stale
  duplicate: **ignore it entirely** and work from the canonical one. Everything
  below applies.
- **No canonical twin** → do NOT ignore it. It may be the only copy of something
  (created on the other machine and never synced under its real name, or its
  canonical was deleted). Don't rename, adopt, or delete it on a guess — tell Ken
  what it is and let him decide.

Rules for the normal (duplicate) case:

- **Never read one as instructions or as the current state of the code.** A
  `CLAUDE-<machine>.md` is a stale snapshot of THIS file and will confidently
  state conventions that have since been retired. (Real example, 2026-08-10: both
  projects' `CLAUDE-Helix2.md` still said to push after every change and described
  a `dev`/`main` branch split that no longer exists — following either would have
  deployed unreleased work to clinicians.)
- **Never edit one, and never treat one as the file to change.** Editing
  `app-Helix2.html` looks like it worked and changes nothing Ken runs.
- **Do not consult one to answer a question about the code.** Read the canonical
  file (the name without the suffix).
- When you notice one, **say so** and offer to clean it up. They pile up silently.
- **Before deleting, verify nothing lives only there** — they are untracked, so
  git cannot bring them back. Check each against the canonical file: a code file
  is safe when `git hash-object <copy>` matches a historical blob for the
  canonical path (i.e. it is an exact old commit); a `.json` preset file is safe
  when its parameter-set names are a subset of the canonical's; a changelog or
  doc is safe when its unique lines are superseded wording. Logs, timings, and
  generated artifacts are disposable by policy. Report what you verified.

### Working by trigger phrase (no manual shell commands)
Ken does not run PowerShell/Bash/Python commands by hand. For ANY repeatable
operation:
1. Create or reuse a script under `scripts/`.
2. Give it a trigger phrase of the form **"run &lt;name&gt;"** and document that
   phrase (and exactly what it runs) HERE in CLAUDE.md, in the same change.
3. When Ken says the phrase, Claude runs the script for him — in the background if
   it is long-running — and reports the result. Never hand Ken raw commands to type.

Scripts must run unchanged on either machine: derive paths from `$env:OneDrive`
(never hardcode `C:\Users\<name>`), and let Claude pick the interpreter
(bash/PowerShell/Python) so the phrase is all Ken needs. A new phrase only works
after OneDrive syncs this file AND the other machine's Claude session is restarted.

**Known trigger phrases:**
- **"bump keyguard designer"** → RELEASE the dev (pre-bumped) `keyguard.scad` and
  manifest to GitHub `main` for deployment to clinicians. Full steps are under
  **Version bumps → "Releasing version N"** above. This is the only phrase that
  pushes `.scad` work to `origin`.
- **"run chunk N" / "chunk status" / "list chunks"** → geometry validation chunks
  (see below).

### Geometry validation chunks (this project)
The golden geometry suite is split into 9 chunks, run via
`scripts/geometry-chunk.sh`:
- **"run chunk N"** (N = 1..9) → run `bash scripts/geometry-chunk.sh N` in the
  background (a multi-minute CGAL render of that chunk's test cases).
- **"chunk status"** → `bash scripts/geometry-chunk.sh status` — the pass/fail ledger.
- **"list chunks"** → `bash scripts/geometry-chunk.sh list`.

Each run writes `geometry-chunk-results/chunk-N.result` and `…progress.log` in
this OneDrive folder, so **both machines and any Claude session can read the
results**. A chunk PASSES when `status=PASS` (0 drift / non-manifold / failed).
Report the result after each run.

**One machine at a time:** a geometry run swaps the shared
`openings_and_additions.txt`, takes a lock, and rewrites
`golden-stl-stats-progress.log` (all in this OneDrive folder). **Never run a
geometry chunk on both machines simultaneously** — run them sequentially (on
either machine); the per-chunk result files accumulate cleanly.

NOTE: the ready-to-print **Manifold-vs-CGAL** work ("run RTP chunk N", "merge the
RTP golden", "run the membrane comparison") is a SEPARATE thing that lives with the
**test harness**, in `keyguard-designer-web`, and is documented in *that* folder's
`CLAUDE.md`. That is the RETIRED app folder, but it is the right place for this —
the harness never moved (see the two-folder warning above). Don't confuse "run
chunk N" (geometry, here) with "run RTP chunk N" (ready-to-print, harness).

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

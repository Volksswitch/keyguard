# Golden STL gate — consolidated spec

Supersedes `next-session-golden-stl-gate.md`, `golden-stl-gate-phase2-preserve-stls.md`,
and `golden-stl-gate-phase3-scad-self-check.md` (all deleted).

## Purpose

Two projects render the same keyguard designs to STL through two different
geometry engines:

- **`.scad` project** → native OpenSCAD, **CGAL** backend (slow, exact, the
  reference).
- **`keyguard-designer-web`** → openscad-wasm, **Manifold** backend (fast, what
  clinicians actually download).

Manifold has known UB that occasionally produces a *manifold-but-wrong* STL —
e.g. TC57's membranes inside cell cavities, or a solid that splits into extra
parts. These pass a manifold check but are visibly broken in a slicer. The gate
catches them by comparing **geometry stats** (volume, surface area, bbox, parts,
facets) against the CGAL reference.

The CGAL stats are the **golden** values, captured by the `.scad` project and
committed to git. Both projects compare against them.

## The two engines, the two thresholds

There are two distinct comparisons, and they have **different** acceptable
deviations:

| Comparison | Where | What it detects | Threshold |
|---|---|---|---|
| CGAL vs CGAL (self) | `.scad` `--geometry` | A `.scad` change that unintentionally moved geometry; an OpenSCAD version bump | **near-exact** (same engine + version is deterministic) |
| Manifold vs CGAL | web `geometry.spec.mjs` | Manifold-backend defects (membranes, part splits, bbox shifts) | **calibrated cross-engine** (triangulation differs even when correct) |

Same golden reference, two thresholds. Do not conflate them.

### Threshold values

CGAL-vs-CGAL (`.scad` self-regression) — tight, only float noise / version drift
should move these:

- volume: 0.1 %
- surface area: 0.1 %
- bbox: 0.01 mm
- parts: exact
- facets: informational (not gated — leave headroom for CGAL minor nondeterminism)

Manifold-vs-CGAL (web) — calibrated against the clean corpus (committed in
`keyguard-designer-web/tests/lib/stl-stats.mjs` `DEFAULT_TOLERANCES`):

- volume: 1 %
- surface area: 2.5 %  (chamfer/slope tessellation differs between engines)
- bbox: 0.05 mm
- parts: exact  (the strongest membrane signal — a membrane often splits the solid)

## CRITICAL: render-flag consistency

The golden stats are captured with the **exact `-D` flags the web app's export
injects**:

```
-D fudge=0.05 -D ff=0.05 -D include_screenshot="no"
```

`fudge=0.05` is the Manifold cell-floor workaround; it alone shifts volume ~2.25 %.
**Every render that compares against golden — on both sides — must use these same
flags**, or the comparison measures render-parameter drift instead of real
divergence. This means the `.scad` self-regression test validates *the geometry
the web app exports*, not the bare default-fudge geometry. That is the deliberate,
correct choice: it keeps the clinician-facing deliverable stable.

## On manifoldness checks

- **`.scad` (CGAL):** the `Simple: yes` check is meaningful — CGAL can produce
  non-manifold output, and we want to know. Keep it as a hard gate.
- **web (Manifold):** a manifoldness check is **uninformative**, not unreliable.
  Manifold emits manifold meshes by design, so the check almost always passes;
  and Manifold's real failures are *manifold-but-wrong* (the TC57 membrane STL
  passed admesh's `disconnected==0`). Keep admesh only as a cheap secondary catch
  for gross corruption (open mesh / missing facets). **The stats comparison is the
  primary web gate.**

## `.scad` project geometry test (`scripts/test.sh`)

A single layer with two modes over the same render+stats core:

1. **Discover** every `(preset, case-folder, OA-file)` from the test cases'
   `test.json` files — for each step that produces geometry (skip
   `"geometry": false`). A preset is rendered with **its parent case's OA**
   (many presets like `Test Case 17d` are steps inside another case's folder).
2. **Render** each preset to STL with native OpenSCAD / CGAL, using the golden
   `-D` flags above.
3. **Manifold check:** `Simple: yes` → otherwise flag NON-MANIFOLD and report.
4. **Stats:** compute volume / area / bbox / parts / facets
   (`scripts/compute_stl_stats.py`).
5. **Capture mode** (`--update-golden`, or any `--geometry` run when no manifest
   exists yet — "first run"): write the stats to
   `tests/cases/golden-stl-stats.json` (committed). Non-manifold configs are still
   flagged.
6. **Compare mode** (`--geometry` when a manifest exists): diff stats against
   golden within the **CGAL-vs-CGAL** threshold. Flag + report any non-manifold
   STL or any stat that deviates beyond threshold.
7. **`--keep-stls`:** retain each CGAL STL under `output/golden-stl/<preset>.stl`
   (gitignored) for slicer comparison.

Progress streams one line per preset to `golden-stl-stats-progress.log` (project
root, gitignored, `tail -f`-friendly). Per-config render timeout defaults to 900 s;
override with `KEYGUARD_GOLDEN_TIMEOUT` for heavy cases (TC46 needs ~2400 s).

Updating golden after an intentional `.scad` change: run `--update-golden` (re-run
the affected `--case` subset, or the whole corpus), eyeball the change, and commit
`golden-stl-stats.json` alongside the `.scad` change. A PR that moves geometry
without moving the manifest is either incomplete or genuinely regression-free.

## web project geometry test (`tests/geometry.spec.mjs`)

For every shared test-case step that produces geometry:

1. **Render** the STL through the app's own export path
   (`window.__exportSTLBytes` → `renderExportBytes`, Manifold backend, same flags).
2. **Manifold check (secondary):** admesh `disconnected==0` — cheap catch for
   gross corruption only; not the primary signal (see above).
3. **Stats:** compute the same five stats from the exported bytes
   (`tests/lib/stl-stats.mjs`).
4. **Compare** to the golden entry for that preset within the **Manifold-vs-CGAL**
   threshold. A missing manifest entry warns (doesn't fail) so adding a test case
   before a golden refresh is non-blocking.
5. **On failure** (non-manifold OR stats deviation): flag + report which
   stat/threshold, and **preserve the Manifold STL** to
   `output/failed-stl/<case>_step<N>.stl` (gitignored) so it can be opened in a
   slicer next to the CGAL golden STL (`.scad` `output/golden-stl/`).

The manifest is loaded read-only via `KEYGUARD_DESIGNER_ROOT`; it lives in and is
committed to the `.scad` project only.

## File locations

| What | Path | In git? |
|---|---|---|
| Golden stats manifest | `.scad/tests/cases/golden-stl-stats.json` | yes |
| Golden CGAL STLs (`--keep-stls`) | `.scad/output/golden-stl/` | no (gitignored) |
| `.scad` progress log | `.scad/golden-stl-stats-progress.log` | no |
| Failing Manifold STLs | `web/output/failed-stl/` | no (gitignored) |
| Stats computation (py / js) | `.scad/scripts/compute_stl_stats.py`, `web/tests/lib/stl-stats.mjs` | yes |

## Open / future

- If openscad-wasm's Manifold output proves unstable across versions, add a
  `wasm_version` field to the manifest so a stale golden fails loudly. (Not yet
  observed.)
- `facets` is recorded but not gated on either side; revisit if it proves a useful
  early signal.

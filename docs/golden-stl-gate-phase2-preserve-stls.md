# Golden STL gate — phase 2: preserve STLs for slicer inspection

The phase-1 gate (committed 2026-05-20) compares derived stats only — no
STL files are kept. That's the right default for git hygiene (STLs are
binary, don't pack, and 150+ × ~MB each would bloat the repo permanently).

But when the gate flags a divergence, the next debugging step is almost
always "open both STLs in a slicer and look." Today that requires
re-running both pipelines by hand to regenerate the bytes. Phase 2 adds
opt-in preservation so the artefacts are sitting on disk waiting.

## Plan

### 1. `.scad` side — opt-in `--keep-stls` flag

Extend `scripts/test.sh --update-golden` with `--keep-stls`:

- Each rendered CGAL STL is copied to `output/golden-stl/<safe-config>.stl`
  before deletion (currently they're written to `/tmp` and removed once
  stats are computed).
- `output/` is already gitignored (`output/` in `.gitignore`); no new
  ignore rule needed.
- Default behaviour unchanged: STLs deleted, only stats kept. The flag
  is purely additive.
- File-naming convention: same `safe=$(echo "$config" | tr ' /' '__')`
  scheme already used for the temp filename, so e.g.
  `Test Case 57` → `output/golden-stl/Test_Case_57.stl`.

Document in `CLAUDE.md` alongside the existing `--update-golden`
description: "Add `--keep-stls` to retain CGAL STLs at
`output/golden-stl/` for slicer comparison when a gate failure needs
investigating."

### 2. Web app — auto-preserve Manifold STLs on gate failure

In `keyguard-designer-web/tests/geometry.spec.mjs`, when a test fails
the golden stats comparison (or admesh — both gates), write the
exported Manifold STL bytes to a known folder before the test errors
out. Implementation:

- New folder: `keyguard-designer-web/output/failed-stl/`
  (the web app doesn't currently have an `output/` ignore rule — add
  `output/` to `keyguard-designer-web/.gitignore`).
- Filename: `<safe-case-name>_step<N>.stl`. Same safety transform.
- Write the bytes before the `expect(...).toBe(...)` so the file
  exists regardless of which gate fails.
- On a passing test, do nothing — keeps the folder clean and small
  so the next failure is easy to find.
- Print the absolute path of the saved file in the test failure
  message so the slicer-comparison step is one click away.

### 3. Cross-referencing in failure output

When the web spec fails, the failure message should point to **both**
candidate files:

```
  Manifold STL: keyguard-designer-web/output/failed-stl/Test_Case_2_step2.stl
  CGAL  STL:   ../My SCAD files/keyguard designer/output/golden-stl/Test_Case_2.stl
                (run `scripts/test.sh --update-golden --keep-stls` in
                 the .scad project to regenerate)
```

The CGAL path is best-effort — the user may not have run --keep-stls
yet, in which case the hint tells them how to.

## Trigger

Implement phase 2 the next time we regenerate the golden manifest, so
the `--keep-stls` run produces the CGAL artefacts in the same pass and
the web spec gains its preservation behaviour at the same time.

## Non-goals

- No auto-diff between the two STLs (slicers already do this visually
  better than any text/HTML diff).
- No commit of either folder. Both stay gitignored.
- No retention policy — failures pile up in `output/failed-stl/` until
  the user clears it. (Cheap to add later if it becomes a problem.)

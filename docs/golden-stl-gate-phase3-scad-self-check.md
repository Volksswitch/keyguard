# Golden STL gate — phase 3: .scad self-regression via the manifest

Phase 1 (landed) uses the golden manifest one direction: the **web app**
checks its Manifold STLs against the .scad-generated CGAL reference.

Phase 3 closes the loop: the **.scad project itself** uses the same
manifest as a regression baseline. Every `--geometry` run will re-derive
stats from the current CGAL render and compare to the committed manifest,
so an unintentional change to `keyguard.scad` that perturbs geometry is
caught at PR time — before it reaches the web app pipeline at all.

## Plan

### 1. Extend `--geometry` with stats comparison

In `scripts/test.sh`'s `run_geometry()`, after the existing `Simple:`
manifold check, do the equivalent of what `run_update_golden` does:

- Run `compute_stl_stats.py` on the rendered STL.
- Look up the manifest entry for the same config name (same lookup the
  manifest generator uses).
- Compare with the same tolerances the web app uses (or a tighter
  CGAL-vs-CGAL set — see calibration note below).
- Report mismatches in the same per-line format the layer already uses:
  `OK` / `NON-MANIFOLD` / `STATS DRIFT (vol Δ X% / parts Y/Z / ...)`.
- A mismatch fails the layer, alongside the existing manifold failures.

Configs without a manifest entry (new test cases, the two timed-out
TC46 entries) print a warning and pass — same convention as the web
app side. Adding a new case shouldn't break CI before the manifest is
regenerated.

### 2. Tolerances: CGAL-vs-CGAL should be near-zero

When both sides are native OpenSCAD / CGAL, identical render args
should produce byte-identical STLs (modulo openscad version drift).
Tolerances should be **much tighter** than the web app's
Manifold-vs-CGAL tolerances:

- volume: 0.01% (effectively exact)
- surface area: 0.05% (allow for floating-point noise)
- bbox: 0.001 mm
- parts: exact
- facets: exact (CGAL is deterministic for a given openscad version)

If openscad itself is upgraded, all of these may move at once — that's
the cue to regenerate the manifest (phase 1 already supports this:
`--update-golden`).

### 3. `--accept-golden`: opt-in manifest update on intentional change

When `keyguard.scad` is intentionally changed (a real geometry fix
landing, not a regression), the manifest needs to be updated for the
affected configs. Today the only path is `--update-golden` which
re-renders everything — heavy.

New flag: `--accept-golden`, intended to follow a failing `--geometry`
run:

- For each config that `--geometry` flagged as `STATS DRIFT`, write
  the new stats into the manifest (replacing the old entry).
- For each config that passed, leave the manifest entry alone.
- For each config that failed to render or hit the `Simple: no`
  manifold gate, **do not** update — those are bugs, not intentional
  changes.
- Respects `--case` filter the same way `--update-golden` does.
- Prints a per-config diff line so the user sees what they're
  accepting (`vol 86490.07 → 86512.31  area 45551.7 → 45580.4`).

Mechanically simple: `--accept-golden` is a thin wrapper that runs
`--geometry`, captures the diffs, and writes back. Implementation can
either re-render or trust the STLs from the just-completed `--geometry`
pass (faster but requires keeping the STLs around — couples to phase 2's
`--keep-stls`).

A reasonable shape:

```bash
./scripts/test.sh --geometry                 # detect drift
./scripts/test.sh --geometry --accept-golden # detect AND accept drift in one pass
./scripts/test.sh --accept-golden --case "Test Case 2"  # accept just one
```

### 4. Workflow integration

The intended PR workflow becomes:

1. Make a .scad change.
2. Run `./scripts/test.sh --geometry` (or eventually have it in
   `--all`).
3. If the layer reports stats drift on configs you didn't mean to
   change → bug; fix it.
4. If the drift is on configs you *did* mean to change, and a visual
   spot-check confirms the new geometry is correct →
   `./scripts/test.sh --accept-golden --case "Test Case N"` to update
   the manifest entry, then commit `golden-stl-stats.json` alongside
   the .scad change.

This makes the manifest part of the change-review surface: a PR that
modifies `keyguard.scad` without also modifying the manifest for the
affected configs is flagged as either incomplete (forgot to accept) or
genuinely regression-free (no configs affected).

## Open questions to settle when implementing

- **Should `--accept-golden` run interactively** (per-config y/N
  prompt) or **blindly accept all drift**? Blind is simpler but
  riskier; interactive is more typing. Default to blind given that
  the user is supposed to have eyeballed the change already, and the
  diff is printed for each accepted config.
- **Should phase 3 live inside `run_geometry` or be a sibling
  function** (`run_geometry_stats`)? Sibling is cleaner conceptually
  but doubles the loop time. Inside is faster — the STL is already
  rendered for the manifold check. Default to inside.
- **What if the manifest is missing entirely** (someone cloned without
  regenerating)? Warn loudly but don't fail; phase 1 already takes
  this stance on the web side.

## Non-goals

- No CGAL-vs-Manifold delta tracking inside the .scad project. That
  belongs in the web pipeline (phase 1).
- No incremental manifest update inside `--update-golden`. Use
  `--accept-golden` for the targeted-update path; `--update-golden`
  stays as the "blow it all away and start fresh" tool.

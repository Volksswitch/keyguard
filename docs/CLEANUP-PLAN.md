# Workspace Cleanup Plan (handoff)

_Written 2026-05-23. **Review-only when written; approved by Ken for execution in a
fresh session.** This file is itself temporary — delete it as the last cleanup step._

After ~a week of membrane/gate/security work, artifacts (~4.5 GB) and a few stale
files accumulated across three locations. This plan removes the waste, fixes
misplaced files, and prunes stale docs. **Nothing here has been executed yet.**

## Locations
- **`.scad` project:** `C:\Users\ken\OneDrive\4 T-Z\Volksswitch\Keyguard\My SCAD files\keyguard designer` (git, branch `main`; work via worktree)
- **web app:** `C:\Users\ken\OneDrive\4 T-Z\Volksswitch\Keyguard\keyguard-designer-web` (git, commit to `dev` only)
- **Web-App-Test assets:** `C:\Users\ken\OneDrive\Desktop\web app\Web-App-Test` (NOT a git repo; OneDrive)

## Current-state facts the executor needs
- All deletions in OneDrive folders can be slow / hit placeholder locks — PowerShell `Remove-Item -Recurse -Force` is the reliable tool (git-bash `rm` sometimes fails on cloud placeholders).
- Geometry chunk ledger lives in `.scad/geometry-chunk-results/` (chunk 1 PASS, chunk 2 result present). Don't delete that folder.
- Membrane review deliverables (keep until manual review done): `keyguard-designer-web\output\ready-to-print\{MEMBRANE-REVIEW.md,MEMBRANE-REVIEW.docx,membrane-comparison.csv,results\}`.
- `golden-rtp-cgal-stats.json` (in Web-App-Test\golden-stl) is the keep-forever membrane reference.
- `.scad main` and web app `dev` are pushed and current.

## ⚠️ Immediate (do first — blocks the next geometry run)
1. Delete stale lock `.scad\.test-lock` (PID 364, no OpenSCAD running). It will make the next "run chunk N" refuse to start.
2. Fix `.scad CLAUDE.md` half-staged index state (OneDrive-during-git artifact; working file already matches HEAD): `git add CLAUDE.md` then confirm `git status` is clean for it.

## Inventory & actions

### A. `.scad` project (small cruft)
| Item | Action | Regenerable |
|---|---|---|
| `.test-lock` | delete (stale) | yes |
| `test-timings.ndjson.bak`, `test-timings-*.ndjson` (per-machine) | delete | yes |
| `docs\test-failures.md`, `docs\test-failures-2026-03-14_15-25-17.md` | delete (old run logs) | yes |
| `OA migration script\` (+ `__pycache__`) | review → archive/delete (one-off V2 migration) | n/a |
| `test results\`, `output\` (gitignored) | delete (render artifacts) | yes |
| `golden-stl-stats-progress.log` | delete (regenerated each run) | yes |
| `geometry-chunk-results\` | **keep** (active ledger) | — |

### B. Web app (mostly gitignored `output\`, ~3 GB)
| Item | Size | Action |
|---|---|---|
| `output\ready-to-print\stl\` | 2.7 G | delete **after** manual membrane review (optionally keep the ~46 SEVERE/MODERATE suspect + 4 control STLs) |
| `output\failed-stl\` | 164 M | delete (geometry-test failure captures) |
| `output\diag-tc57\` | 35 M | delete (one-off diagnostic output) |
| `output\cross-compare\` | 14 M | delete unless still using `compare-cross.sh` |
| `capture-run.log`, `output\*.log`, `render-progress.log`, `results.jsonl`, `cgal-sample.log`, `test-timings*.ndjson`, `scripts\__pycache__\` | ~1.5 M | delete (logs/scratch) |
| `scripts\diag-tc57.mjs`, `probe-cgal-import.mjs`, `calibrate-cgal-probe.mjs`, `emit-broken-cases-md.mjs` | — | review → delete one-off diagnostics; commit removal to `dev` |
| `output\ready-to-print\{MEMBRANE-REVIEW.*, membrane-comparison.csv, results\, visual\, *-review.pdf}` | ~25 M | keep until review done |
| RTP suite scripts, `SECURITY.md/.docx`, `compare-cross.sh` | — | keep |

### C. Web-App-Test assets (~1.5 G)
| Item | Size | Action |
|---|---|---|
| `golden-stl\iPad_7_8_9` + `iPad_mini_6_7` + `iPad_10_11` | 1.08 G | **DECISION:** archive or delete (stale downloaded website STLs, superseded by `golden-rtp-cgal-stats.json`) |
| `golden-stl\cgal\` | 176 M | delete (kept CGAL STLs; stats already in JSON) |
| `v77\`, `v78\` | 50 M | delete (render-time investigation STLs) |
| `keyguard_v77.scad`, `keyguard_v77.json` | 6 M | delete (v77 comparison copies) |
| `design default values.stl` | 2.8 M | delete (stray) |
| `openings_and_additions.txt.rtpsave`, `rtp-cgal-progress.log` | small | delete (stale backup + old log) |
| `golden-stl\cgal-chunks\` | 148 K | delete (intermediate; merged into golden JSON) |
| `ready to print designs.zip` (63 M), `SVG files\` (79 M) | 142 M | **DECISION:** archive off the working tree if not actively used |
| `scad render test results.docx` | 16 K | keep/archive (render-time analysis) |
| `keyguard.scad/.json`, `Cases and App Specifics\`, `Standard Openings…\`, mapping CSVs, `golden-rtp-cgal-stats.json` | — | keep (active) |

### D. Stale documentation (audit pass, last)
Grep the `.md` files for references to anything deleted above and prune the prose:
- web app `results.md`, `CGAL_NEF_BROKEN_CASES.md` — likely superseded by the membrane review → review → delete or fold in.
- both `CLAUDE.md`s — check for mentions of removed scripts/logs.

## Execution order (with checkpoints)
1. **Immediate:** `.test-lock` + `CLAUDE.md` index.
2. **Zero-risk regenerables:** all gitignored `output\`, logs, `__pycache__`, `.bak`, scratch ndjson (~3 GB).
3. **Investigation artifacts:** v77/v78, keyguard_v77.*, diag-tc57, failed-stl, design-default stl, .rtpsave, rtp-cgal-progress.log.
4. **CHECKPOINT — Ken decides:** archive vs delete the 1.08 G website STLs + `ready to print designs.zip` + `SVG files\`.
5. **AFTER manual membrane review:** delete `output\ready-to-print\stl\` (2.7 G) keeping only suspect/control STLs.
6. **Scripts:** remove the 4 web-app diagnostics → commit to `dev`, push.
7. **Docs audit:** prune stale prose → commit (web app `dev`; `.scad` via worktree → main).
8. **Last:** delete this `CLEANUP-PLAN.md` (commit the removal).

Git-tracked removals go to the right branch (`.scad` → main via worktree; web app → `dev`). Gitignored/asset deletions are just file removals.

---

# Going-Forward Plan (once all chunks processed)
1. **Finish geometry validation** — run chunks 2–9 (chunk 1 PASS, chunk 2 result present); confirm the `geometry-chunk.sh status` ledger is all PASS. Validates the gate-off default across the whole `.scad` suite.
2. **Triage membrane findings** — 9 export crashes + 64 suspects (~23% of corpus) mean the `fudge=0.05`+extender workaround doesn't hold everywhere. Decide per cluster (LWFL, Grid, TouchChat WP, iPad 10/11) whether to fix in `.scad`/Manifold or document as known limitations.
3. **Browser smoke-test the web app** — verify the CSP + Save As changes in Chrome/Edge (couldn't be automated).
4. **Release the web app** — `dev → main` per `RELEASING.md` (CACHE_NAME bump) so the security fixes + Save As reach clinicians; ship `SECURITY.md/.docx`.
5. **Cut the `.scad` v78 release** — `extend_through_cuts` gate + V2-OA work are on `main` and validated; update `CHANGELOG.md` and tag.
6. **Retention** — keep `golden-rtp-cgal-stats.json` + the membrane review as the record; archive/drop the multi-GB STL corpora.
7. **Keep scaffolding, drop its artifacts** — retain `geometry-chunk.sh` / RTP scripts for future re-validation; routinely clear their logs/results.
8. **Hygiene** — every repeatable op stays a script + "run …" phrase in `CLAUDE.md`; keep generated output under gitignored `output\` so cleanup is always "delete output\".

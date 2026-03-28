# Admesh Failure Baseline — 2026-03-28

All 19 configs that failed the overnight `--geometry` run were re-rendered fresh
with the current code and re-checked with the same admesh criteria used by `test.sh`
(non-zero count in: Degenerate facets, Edges fixed, Facets removed, Facets added,
Facets reversed, Backsides flipped, Parts fixed).

All 19 configs passed the manifold check (Simple: yes).

---

## Currently failing (9 configs)

| Config | Facets reversed | Notes |
|---|---|---|
| Test Case 7c | 4 | |
| Test Case 7d | 6 | |
| Test Case 23a | 1460 | Severe — large number of reversed facets |
| Test Case 23c | 2 | |
| Test Case 37a | 2 | |
| Test Case 38 | 4 | |
| Test Case 47a | 258 | Severe |
| Test Case 49 | 6 | |
| Test Case 50 | 2 | |

All failures are `Facets reversed > 0`. No other admesh repair categories
(degenerate facets, open edges, etc.) are triggered.

---

## Overnight-failing but now passing (10 configs)

These configs failed the overnight run but pass with the current code.
All have `Facets reversed = 0`. They have non-zero `Normals fixed` counts
(which the test does not check).

| Config | Normals fixed (not checked) |
|---|---|
| Test Case 3 | 5 |
| Test Case 23b | 125 |
| Test Case 29 | 287 |
| Test Case 37 | 1145 |
| Test Case 37b | 1144 |
| Test Case 37c | 1158 |
| Test Case 42 | 1530 |
| Test Case 45 | 31 |
| Test Case 47 | 182 |
| Test Case 48 | 181 |

---

## Note on overnight vs current discrepancy

The 10 configs listed above were marked failing overnight but pass now.
The reason is not yet investigated (per Ken's instruction). It may reflect
code changes made between the overnight run and this session, or other factors.

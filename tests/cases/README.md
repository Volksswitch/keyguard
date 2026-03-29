# Test Cases

Each subfolder here represents one visual test case. The folder name must exactly
match a named parameter set in `keyguard.json`.

The test runner (`scripts/test.sh --visual`) finds every `test.json` in these
subfolders, executes each step in sequence, and compares the rendered PNG against
the committed reference image.

---

## Folder contents

| File | Required | Purpose |
|---|---|---|
| `test.json` | **Yes** | Describes the test steps (see format below) |
| `step1_expected.png`, `step2_expected.png`, … | **Yes** | Committed reference renders; one per step |
| Console reference text file(s) | No | Plain text file(s) containing expected console output for steps that use `console`; named freely and referenced from `test.json` |
| `openings.txt` | No | Custom `openings_and_additions.txt` for this test; if absent the project-level file is used |
| Asset SVG(s) | No | SVG files imported by name in `openings_and_additions.txt` (e.g. `butterfly.svg`); listed in `assets` and copied to the project root before rendering |
| Screenshot SVG | No | SVG used as a fit-test overlay; listed in `screenshot` and copied to `default.svg` before rendering |

---

## test.json format

```json
{
  "description": "Human-readable summary of what this test verifies",
  "openings": "openings.txt",
  "assets": ["butterfly.svg"],
  "screenshot": "overlay.svg",
  "steps": [
    {
      "label": "full view",
      "params": "Test Case 15",
      "params_override": { "orientation": "portrait" },
      "vpt": [0, 0, 0],
      "vpr": [55, 0, 25],
      "vpd": 250,
      "expected": "step1_expected.png"
    },
    {
      "label": "home button detail",
      "params": "Test Case 15",
      "vpt": [120, -40, 0],
      "vpr": [45, 0, 0],
      "vpd": 80,
      "console": "step2_console.txt",
      "expected": "step2_expected.png"
    }
  ]
}
```

### Top-level fields

| Field | Required | Description |
|---|---|---|
| `description` | Yes | What this test verifies |
| `openings` | No | Filename of the custom openings file in this folder (e.g. `"openings.txt"`) |
| `assets` | No | List of SVG filenames imported by name in `openings_and_additions.txt`; each is copied from this folder to the project root before rendering and removed afterwards |
| `screenshot` | No | Filename of an SVG in this folder to use as `default.svg` (for fit-test overlay); copied to `default.svg` before rendering and restored afterwards |
| `steps` | Yes | Ordered list of render steps |

**`assets` vs `screenshot`:**
- Use `assets` for SVG files that `openings_and_additions.txt` references directly by name via `import("filename.svg")`. They are placed in the project root under their own names.
- Use `screenshot` for the fit-test overlay that `keyguard.scad` imports when `include_screenshot = "yes"`. It is always placed as `default.svg`.
- Both can be present in the same test if needed.

### Step fields

| Field | Required | Description |
|---|---|---|
| `label` | Yes | Short name for this step (used in output and filenames) |
| `params` | No | Named parameter set from `keyguard.json`; if absent, renders with current defaults |
| `params_override` | No | Key/value pairs applied on top of `params` as `-D` flags |
| `vpt` | No | Viewport translation `[x, y, z]` — equivalent to OpenSCAD's `$vpt`; defaults to `[0, 0, 0]` |
| `vpr` | No | Viewport rotation `[x, y, z]` — equivalent to OpenSCAD's `$vpr`; defaults to `[55, 0, 25]` |
| `vpd` | No | Viewport distance — equivalent to OpenSCAD's `$vpd`; defaults to `250` |
| `render` | No | If `true`, passes `--render` to OpenSCAD (CGAL full render, equivalent to F6); default `false` (preview renderer). Useful for 2D/SVG-generate steps where preview and render look different. |
| `geometry` | No | If `false`, the named config referenced by `params` is excluded from the geometry validation layer (`--geometry`). Use this for steps that produce non-3D output (e.g. `generate="first layer for SVG/DXF file"`) that cannot be rendered to STL. Default `true` (included). |
| `console` | No | Filename of a text file in this folder containing expected console output (copy-pasted from a valid run). Every non-empty line in the file must appear somewhere in OpenSCAD's actual console output for this step to pass. Simple substring match; case-sensitive. |
| `expected` | Yes | Filename of the committed reference PNG in this folder |

### Console reference files

A console reference file is a plain text file containing lines copy-pasted from
OpenSCAD's console during a known-good run. Name it anything you like (e.g.
`step1_console.txt`) and reference it from the step's `console` field.

The test runner checks that every non-empty line in the file appears somewhere in the
actual console output for that step. Blank lines and lines containing only whitespace
are ignored, so you can paste the full console output and the test will still pass as
long as none of the expected lines go missing.

The console log for each step is saved to `output/test/visual/` as a `_console.log`
file alongside the rendered PNG — useful for inspecting output when building a new
console reference.

### Camera note

`vpt`, `vpr`, and `vpd` use the same names and values as OpenSCAD's `$vpt`, `$vpr`,
and `$vpd` viewport variables. You can read current values directly from the OpenSCAD
GUI (View → View All, then check the console for `echo($vpt=..., $vpr=..., $vpd=...)`),
or set them in your `openings.txt` to control the interactive starting view.

If `openings.txt` sets `$vpt`, `$vpr`, and `$vpd` at the top, the first step's camera
values are a natural copy of those — keeping interactive and automated views in sync.

---

## Workflow: adding a new test case

1. Create a subfolder with the exact name of a `keyguard.json` named config, e.g.:
   ```
   tests/cases/Test Case 42/
   ```

2. Position the view in OpenSCAD, then read the viewport values from the console.

3. Write `test.json` with those values and describe each step.

4. Add any `openings.txt`, asset SVGs, or screenshot SVG the test needs.

5. Run the capture command to generate reference images:
   ```bash
   ./scripts/test.sh --capture-references
   ```

6. Review the generated PNGs in `output/test/visual/`, then commit everything:
   ```bash
   git add tests/cases/Test\ Case\ 42/
   git commit -m "Add visual test for Test Case 42"
   ```

7. Future runs of `./scripts/test.sh --visual` will compare against these references.

---

## Workflow: updating a reference after an intentional change

If you intentionally change geometry and the visual tests now fail, regenerate the
references for the affected test(s):

```bash
./scripts/test.sh --capture-references
# review output/test/visual/ to confirm the new renders look correct
git add tests/cases/
git commit -m "Update visual references after <description of change>"
```

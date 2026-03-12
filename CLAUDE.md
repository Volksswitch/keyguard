# OpenSCAD Project — Claude Code Context

## Project Overview

> **TODO:** Fill in this section before sharing with Claude Code.
>
> - **What does this project model?** (e.g., "A parametric enclosure for a Raspberry Pi")
> - **Main output files:** (e.g., `enclosure.scad`, `lid.scad`)
> - **Key parameters / design intent:** (e.g., "All wall thicknesses are driven by the `wall` variable")
> - **Target use:** (e.g., FDM 3D printing on a Prusa MK4, 0.2 mm layers, no supports)

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
openscad -o output.stl your_file.scad
```

### Render to PNG (quick visual check)
```bash
openscad -o preview.png \
  --camera=0,0,0,55,0,25,200 \
  --imgsize=1024,768 \
  --colorscheme=Tomorrow \
  your_file.scad
```

### Check for syntax errors without rendering
```bash
openscad --hardwarnings your_file.scad 2>&1 | head -40
```

### Pass parameters on the command line
```bash
openscad -o output.stl -D 'wall=3' -D 'height=50' your_file.scad
```

### Helper scripts
See `scripts/render.sh` and `scripts/preview.sh` for convenient wrappers.

---

## Project File Structure

> **TODO:** Update this to reflect your actual project layout.

```
.
├── CLAUDE.md               ← This file
├── main.scad               ← Top-level entry point (update name as needed)
├── lib/                    ← Reusable modules/libraries (if any)
├── docs/
│   └── openscad-reference.md  ← OpenSCAD tips for Claude Code
└── scripts/
    ├── render.sh           ← Render all parts to STL
    └── preview.sh          ← Generate PNG previews
```

---

## Code Conventions Used in This Project

> **TODO:** Document your own conventions here. Examples below — keep, edit, or remove as appropriate.

- **Module naming:** `snake_case` for modules, e.g. `lid_panel()`, `mounting_boss()`
- **Variable naming:** `snake_case` for parameters; uppercase for physical constants (e.g., `NOZZLE_D = 0.4`)
- **Parameters:** All user-tunable values are declared at the top of the file in a clearly marked section
- **Tolerances:** Fit tolerances are defined as named variables (e.g., `fit = 0.2`) — do not hardcode them
- **Units:** All dimensions are in **millimetres** unless otherwise noted
- **$fn:** Set per-object using a named variable (e.g., `$fn = CIRCLE_DETAIL`) rather than globally, to allow fast preview vs. high-quality render
- **Comments:** Each module has a comment block describing its parameters and purpose

---

## Known Issues / Current Work

> **TODO:** List any known bugs, geometry problems, or active areas of improvement.

- [ ] Example: `lid.scad` — screw boss height is 0.5 mm too tall; needs adjustment
- [ ] Example: `enclosure.scad` — `difference()` leaves a non-manifold edge at the USB cutout

---

## Design Constraints & Non-Negotiables

> **TODO:** Document things Claude should NOT change without explicit permission.

- The overall external dimensions (`width`, `depth`, `height`) are fixed — do not alter these defaults
- The mounting hole pattern must remain compatible with the VESA 75×75 standard
- Avoid `minkowski()` on large objects — it is extremely slow to render

---

## OpenSCAD Gotchas — Please Read

See `docs/openscad-reference.md` for a full reference. Critical points:

1. **Variables are constants.** You cannot reassign a variable inside a scope and have it affect
   later geometry. Use conditional expressions or modules instead.
2. **`use` vs `include`:** `use <lib.scad>` imports only modules/functions (not variables).
   `include <lib.scad>` is like a literal copy-paste — it brings in variables too.
3. **`children()` and `$children`:** Modules can receive child geometry and pass it through.
   Be careful not to break modules that rely on children when refactoring.
4. **Preview vs render:** The F5 preview uses OpenCSG (fast but approximate). F6/`-o .stl` uses
   CGAL (slow but exact). A model can look fine in preview and fail to render — always test with
   a full render after significant changes.
5. **Non-manifold geometry is silent:** OpenSCAD will silently produce broken STLs if geometry
   is non-manifold. Always check rendered STLs in a slicer or mesh repair tool.

---

## Asking Claude Code for Help

Suggested prompts:

- *"Render `main.scad` and show me any errors or warnings."*
- *"Refactor the `mounting_boss` module to accept a `diameter` parameter instead of hardcoding 5."*
- *"The lid doesn't fit the body — the `fit` tolerance might be wrong. Check and fix it."*
- *"Add a `chamfer` parameter to the `enclosure` module that bevels the top four vertical edges."*
- *"Add docstring comments to every module in `main.scad`."*

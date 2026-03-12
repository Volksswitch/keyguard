# OpenSCAD Reference for Claude Code

This document exists to help Claude Code work effectively with OpenSCAD source files.
It covers language quirks, common patterns, and things that differ from general-purpose
programming languages.

---

## Language Fundamentals

### Variables Are Constants (This Is Not a Bug)

```openscad
x = 5;
x = 10;  // This does NOT reassign — both declarations exist; the last one wins at parse time
```

OpenSCAD variables are resolved at **parse time**, not at runtime. Within a module, a variable
declared with `=` is scoped to that block, but you cannot mutate it:

```openscad
// WRONG — this does not work as expected
for (i = [0:5]) {
    count = count + 1;  // 'count' is not accumulated
}

// RIGHT — use the loop variable directly
for (i = [0:5]) {
    translate([i * 10, 0, 0]) cube(5);
}
```

### Modules vs. Functions

| | Module | Function |
|---|---|---|
| Creates geometry | ✅ Yes | ❌ No |
| Returns a value | ❌ No | ✅ Yes |
| Can have children | ✅ Yes | ❌ No |
| Syntax | `module foo() { ... }` | `function foo() = expr;` |

```openscad
// Module — creates geometry
module rounded_box(w, h, d, r) {
    minkowski() {
        cube([w - 2*r, h - 2*r, d - 2*r], center=true);
        sphere(r);
    }
}

// Function — returns a value (must be a single expression)
function hypotenuse(a, b) = sqrt(a*a + b*b);
```

### Special Variables

| Variable | Purpose | Typical values |
|---|---|---|
| `$fn` | Fixed number of facets for circles/spheres | 12 (fast), 64–128 (quality) |
| `$fa` | Minimum angle per facet (degrees) | 12 (default) |
| `$fs` | Minimum facet size (mm) | 2 (default) |
| `$t` | Animation time (0.0–1.0) | Used only in animation mode |
| `$children` | Number of children passed to a module | Read-only inside modules |

Set `$fn` locally to avoid degrading global quality:
```openscad
cylinder(h=10, r=5, $fn=64);   // High quality just for this object
```

---

## Geometry Operations

### Boolean Operations

```openscad
union() { ... }        // Combine shapes (default when no op is specified)
difference() {
    base_shape();      // First child is the base
    cutout_shape();    // All subsequent children are subtracted
}
intersection() { ... } // Keep only the overlapping region
```

**Important:** `difference()` subtracts ALL children after the first from the first child.

### Transformations (always applied to ALL children)

```openscad
translate([x, y, z]) { ... }
rotate([x_deg, y_deg, z_deg]) { ... }
scale([x, y, z]) { ... }
mirror([x, y, z]) { ... }    // Mirror across a plane defined by the normal vector
resize([x, y, z]) { ... }    // Resize to absolute dimensions
```

### Hull and Minkowski

```openscad
hull() { ... }          // Convex hull of all children — useful for smooth transitions
minkowski() { ... }     // Minkowski sum — adds the shape of the second child to every
                        // point of the first. Great for rounded boxes, but VERY SLOW.
```

**Performance note:** Never use `minkowski()` with complex geometry or in tight loops.
Prefer `hull()` for simple rounding when possible.

---

## 2D to 3D Extrusion

```openscad
// Linear extrusion
linear_extrude(height=10, twist=0, scale=1.0, center=false) {
    circle(r=5);
}

// Rotational extrusion (revolve a 2D profile around the Z axis)
rotate_extrude(angle=360, $fn=64) {
    // Profile must be in the XY plane, X >= 0
    translate([10, 0, 0]) circle(r=3);
}
```

---

## Modules with Children

Modules can accept and use child geometry passed to them:

```openscad
module centered_on_face(face_z) {
    translate([0, 0, face_z])
        children();   // Renders whatever was passed as children
}

centered_on_face(10) {
    cylinder(h=5, r=2);
}

// Multiple children — use children(index)
module place_two(offset) {
    children(0);                         // First child
    translate([offset, 0, 0]) children(1); // Second child
}
```

---

## `use` vs `include`

```openscad
use <library.scad>      // Import modules and functions only — NOT variables/constants
include <library.scad>  // Import everything (modules, functions, AND variables)
                        // Equivalent to copy-pasting the file's content here
```

Use `use` when you only need functions/modules and don't want the library's top-level
geometry to appear. Use `include` when you also need shared constants or configuration.

---

## Loops and Conditionals

```openscad
// For loop — generates multiple objects
for (i = [0:2:10]) {          // [start:step:end]
    translate([i, 0, 0]) cube(1);
}

// For loop over a list
for (pos = [[0,0], [10,5], [20,0]]) {
    translate([pos[0], pos[1], 0]) cylinder(h=5, r=1);
}

// Conditional geometry
if (add_lid) {
    lid();
}

// Ternary expression (in value context)
wall = (thick_walls) ? 3 : 1.5;
```

---

## Common Patterns

### Parametric model at the top of the file

```openscad
/* ===== PARAMETERS — edit these ===== */
width       = 80;     // [10:200] External width in mm
depth       = 60;     // [10:200] External depth in mm
height      = 40;     // [10:200] External height in mm
wall        = 2.0;    // [0.5:0.5:5] Wall thickness in mm
fit         = 0.2;    // Clearance for press-fit joints
CIRCLE_DETAIL = 64;   // $fn for curved surfaces
/* =================================== */
```

The `[min:max]` comments are picked up by the OpenSCAD Customizer UI.

### Avoiding redundant geometry

When subtracting a hole that should pass completely through an object, extend it slightly
beyond both faces to avoid zero-thickness artifacts:

```openscad
eps = 0.01;   // Small epsilon to avoid z-fighting
difference() {
    cube([10, 10, 10]);
    translate([5, 5, -eps])
        cylinder(h = 10 + 2*eps, r=2);
}
```

### Named constants for readability

```openscad
TOP    = [0,  0,  1];
BOTTOM = [0,  0, -1];
FRONT  = [0, -1,  0];

mirror(BOTTOM) children();   // Far more readable than mirror([0,0,-1])
```

---

## Debugging Tips

### Echo values to the console

```openscad
echo("wall =", wall, "  computed inner =", width - 2*wall);
```

### Highlight a specific object

```openscad
#cube(10);    // Shows the cube in transparent pink (highlight mode)
%cube(10);    // Shows ghost/transparent (debug mode — not included in render)
*cube(10);    // Disables the object completely
!cube(10);    // Renders ONLY this object (ignores everything else)
```

These modifiers (`#`, `%`, `*`, `!`) are extremely useful for isolating geometry problems.

### Checking for non-manifold output

After rendering to STL, check with:
```bash
# Using OpenSCAD's own checker:
openscad --hardwarnings your_file.scad

# Or open the STL in PrusaSlicer / Bambu Studio — they show mesh errors visually
```

---

## Performance Tips

| Operation | Speed | Notes |
|---|---|---|
| `cube`, `cylinder`, `sphere` (low `$fn`) | Fast | Use for iterative development |
| `hull()` | Fast–medium | Good for rounding |
| `minkowski()` | Very slow | Avoid on complex geometry |
| `linear_extrude` | Medium | Avoid high `$fn` on the profile |
| `rotate_extrude` | Medium | Keep profile simple |
| Large `$fn` values | Slow | Use 12–24 during dev, 64–128 for final |
| Deep nested booleans | Slow | Try to flatten where possible |

Use a low-resolution preview variable during development:
```openscad
PREVIEW = $preview;   // true in F5/preview, false in F6/render
$fn = PREVIEW ? 16 : 64;
```

---

## CLI Rendering Reference

```bash
# Render to STL
openscad -o model.stl model.scad

# Render to PNG with a specific camera angle
# Camera args: translate_x,y,z, rotate_x,y,z, distance
openscad -o preview.png \
  --camera=0,0,0,55,0,25,200 \
  --imgsize=1024,768 \
  --colorscheme=Tomorrow \
  model.scad

# Render with parameter overrides
openscad -o model.stl \
  -D 'width=100' \
  -D 'wall=2.5' \
  model.scad

# Check warnings without full render
openscad --hardwarnings model.scad 2>&1

# List all modules/functions (useful for refactoring)
grep -n "^module\|^function" model.scad
```

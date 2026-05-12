// Written by Volksswitch <www.volksswitch.org>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
//
// keyguard.scad would not have been possible without the generous help of the following therapists and makers:
//	Justus Reynolds, Angela Albrigo, Kerri Hindinger, Sarah Winn, Matthew Provost, Jamie Cain Nimtz, Ron VanArsdale, 
//  Michael O Daly, Duane Dominick (JDD Printing), Joanne Roybal, Melissa Hoffmann, Annette M. A. Cooprider, 
//  Ashley Larisey, Janel Comerford, Joy Hyzny
//
//
// Version History: see CHANGELOG.md in the same directory as this file.
//
//------------------------------------------------------------------
// Module Index
// Search for "module name(" to jump to any entry.
//------------------------------------------------------------------
//
// TOP-LEVEL GENERATORS
//   keyguard()                          1860  Main 3D-printed keyguard
//   lc_keyguard()                       2143  Laser-cut keyguard
//   keyguard_frame()                    2255  Keyguard frame
//
// SPLITTING
//   split_keyguard()                    2507  Split keyguard into halves for printing
//   show_line_split_location()          2622  Visualise the split line
//   split_keyguard_frame()              2702  Split keyguard frame into halves
//   dovetails()                         2733  Dovetail joint geometry
//
// FRAME & SNAP-IN MOUNTING
//   add_keyguard_frame_post_slots()     2388  Slots in frame for post mounting
//   add_keyguard_frame_posts()          2402  Posts that attach keyguard to frame
//   add_mounting_posts()                2430  Mounting posts (Via Pro etc.)
//   snap_in_tab_grooves()               6819  Grooves for snap-in tabs in frames
//   add_snap_ins()                      6855  Add snap-in tabs
//   make_snap_ins()                     6894  Single snap-in tab geometry
//
// MOUNTING METHODS
//   case_mounts()                       2748  Dispatch mounting method geometry
//   add_2d_slide_in_tabs()              2770  Slide-in tabs (2D layout)
//   create_2D_slide_in_tab()            2825  Single slide-in tab geometry
//   add_clip_on_strap_pedestals()       2868  Pedestals for clip-on straps
//   add_raised_tabs()                   2915  Raised tabs
//   raised_tab()                        2975  Single raised tab geometry
//   mounting_points()                   3205  Suction-cup / screw mounting points
//   suction_cups()                      3225  Suction cup geometry
//   velcro()                            3263  Velcro slot geometry
//   screw_on_straps()                   3299  Screw-on strap geometry
//   clip_on_straps_groove()             3352  Groove for clip-on straps
//   add_manual_mount_pedestals()        6622  Manually placed strap pedestals (V1 format)
//   add_manual_mount_pedestals_v2()     4869  Manually placed strap pedestals (V2 format)
//   cut_manual_mount_pedestal_slots()   6694  Slots for manually placed pedestals (V1 format)
//   cut_manual_mount_pedestal_slots_v2() 4919 Slots for manually placed pedestals (V2 format)
//
// CLIPS
//   create_clip()                       5703  Standard clip geometry
//   create_mini_clip1()                 5785  Mini clip geometry
//   create_mini_clip2()                 5854  Micro clip geometry
//
// GRID & CELLS
//   trim_keyguard_to_bar()              2417  Trim keyguard height to bar region
//   bars()                              3411  Message / command / status bars
//   bounded_cells()                     3476  Cell openings (bounded by bars)
//   cells()                             3496  Individual cell openings
//   cell_ridges()                       3561  Ridges around cell openings
//   create_cell_insert()                3890  Cell insert / Braille insert
//
// RIDGES & WALLS
//   hridge()                            5598  Horizontal ridge
//   vridge()                            5626  Vertical ridge
//   ridge()                             5656  Ridge at arbitrary angle
//   aridge()                            5684  Arc-shaped ridge
//   circular_wall()                     3611  Circular wall
//   rounded_rectangle_wall()            3623  Rounded-rectangle wall
//   rr_wall1()                          3648  Rounded-rectangle wall (variant 1)
//   rr_wall2()                          3662  Rounded-rectangle wall (variant 2)
//   rr_corner_wall()                    3676  Rounded-rectangle corner wall
//
// OPENINGS & CUTS (high-level)
//   cut_screen_openings()               4033  Apply screen_openings vector (V1 format)
//   cut_screen_openings_v2()            4277  Apply screen_openings vector (V2 format)
//   cut_case_openings()                 4974  Apply case_openings vector (V1 format)
//   cut_case_openings_v2()              4427  Apply case_openings vector (V2 format)
//   cut_tablet_openings()               5029  Apply tablet_openings vector (V1 format)
//   cut_tablet_openings_v2()            4537  Apply tablet_openings vector (V2 format)
//   cut_als_openings()                  5073  Apply ALS openings
//   home_camera()                       3155  Home button and camera openings
//   trim_to_the_screen()                6766  Trim keyguard to screen boundary
//   trim_to_rectangle()                 6775  Trim keyguard to arbitrary rectangle
//   cut_screen()                        6803  Cut out entire screen area
//   cut_grid()                          6810  Cut out grid area
//
// OPENINGS & CUTS (primitives)
//   cut_hole()                          5121  Flip-aware hole cut helper (used by cut_opening)
//   cut_opening()                       5147  Shape-dispatching opening cutter
//   cut_opening_2d()                    5323  2D version of cut_opening
//   cut()                               3841  Core 3D cut primitive (chamfered box)
//   cut_2d()                            3882  Core 2D cut primitive
//   hole_cutter()                       3695  Sloped-edge hole (primary)
//   hole_cutter2()                      3763  Sloped-edge hole (variant)
//   hole_cutter_3()                     3747  Sloped-edge hole (variant)
//   hole_cutter_2d()                    3807  2D hole outline
//   create_cutting_tool()               3122  Rotary cutting tool shape
//   create_cutting_tool_2d()            3142  2D rotary cutting tool shape
//
// CASE ADDITIONS
//   adding_plastic()                    5392  Add plastic to case (dispatch, V1 format)
//   adding_plastic_v2()                 4636  Add plastic to case (dispatch, V2 format)
//   place_addition()                    5468  Place a single addition shape (V1 format)
//   place_addition_v2()                 5758  Place a single addition shape (V2 format)
//   add_case_full_height_shapes()       6084  Full-height case addition shapes (V1 format)
//   add_case_full_height_shapes_v2()    4805  Full-height case addition shapes (V2 format)
//   apply_flex_height_shapes()          6459  Add or subtract flexible-height shapes (V1 format)
//   apply_flex_height_shapes_v2()       4763  Add or subtract flexible-height shapes (V2 format)
//   build_addition()                    6178  Build a single addition solid
//   build_trimmed_addition()            6506  Addition solid with edge trimming
//   add_case_cylinders()                6537  Cylindrical mounting posts
//   half_rounded_rectangle()            6590  Half rounded-rectangle primitive
//
// BASE GEOMETRY
//   base_keyguard()                     5923  Outer keyguard body
//   chamfer_slice()                     5992  Chamfer layer for keyguard edge
//   case_opening_blank()                6014  Solid fill of case opening area
//   case_opening_blank_2d()             6031  2D version of case opening fill
//
// SCREENSHOT & VISUALISATION
//   show_screenshot()                   6904  Display SVG screenshot layer
//   show_screenshotMW()                 6915  Screenshot layer for Maker World
//   engrave_emboss_instruction()        6927  Engrave/emboss an opening shape
//
// TEXT & BRAILLE
//   add_engraved_text()                 7529  Engrave or emboss text
//   add_braille()                       7458  Add Braille dots from a word
//   word_flat()                         7467  Lay out a word in Braille cells
//   braille_by_row()                    7477  Braille dot pattern by row
//   dots_letter()                       7497  Individual Braille character dots
//
// GEOMETRY HELPERS
//   chamfered_cuboid()                  7388  Cuboid with chamfered top edge
//   chamfered_shape()                   7417  Rounded-rectangle with chamfer
//   rounded_rect()                      3817  Simple rounded rectangle (2D)
//
// DIAGNOSTICS & SETTINGS OUTPUT
//   echo_settings()                     6999  Echo all Customizer settings to console
//   issues()                            7271  Echo known issues / warnings
//   key_settings()                      7314  Echo key parameter summary
//
//------------------------------------------------------------------
// User Inputs
//------------------------------------------------------------------

/*[Keyguard Basics]*/
type_of_keyguard = "3D-Printed"; // [3D-Printed,Laser-Cut]
//not for use with Laser-Cut keyguards
keyguard_thickness = 4.0; // .1
//cannot exceed the keyguard thickness
screen_area_thickness = 4.0; // .1
generate = "keyguard"; //[keyguard,first half of keyguard,second half of keyguard,horizontal clip,vertical clip,horizontal mini clip,vertical mini clip,horizontal micro clip,vertical micro clip,keyguard frame,first half of keyguard frame,second half of keyguard frame,cell insert,first layer for SVG/DXF file,Customizer settings]


/*[Tablet]*/
type_of_tablet = "iPad 9th generation"; //[iPad, iPad2, iPad 3rd generation, iPad 4th generation, iPad 5th generation,iPad 6th generation, iPad 7th generation, iPad 8th generation, iPad 9th generation, iPad 10th generation, iPad 11th generation A16, iPad Pro 9.7-inch, iPad Pro 10.5-inch, iPad Pro 11-inch 1st Generation, iPad Pro 11-inch 2nd Generation, iPad Pro 11-inch 3rd Generation, iPad Pro 11-inch 4th Generation, iPad Pro 11-inch M4, iPad Pro 11-inch M5, iPad Pro 12.9-inch 1st Generation, iPad Pro 12.9-inch 2nd Generation, iPad Pro 12.9-inch 3rd Generation, iPad Pro 12.9-inch 4th Generation, iPad Pro 12.9-inch 5th Generation, iPad Pro 12.9-inch 6th Generation, iPad Pro 13-inch M4, iPad Pro 13-inch M5, iPad mini, iPad mini 2, iPad mini 3, iPad mini 4, iPad mini 5, iPad mini 6, iPad mini 7 A17 Pro, iPad Air, iPad Air 2, iPad Air 3, iPad Air 4, iPad Air 5, iPad Air 11-inch M2, iPad Air 11-inch M3, iPad Air 11-inch M4, iPad Air 13-inch M2, iPad Air 13-inch M3, iPad Air 13-inch M4, Dynavox I-12+, Dynavox Indi, Tobii-Dynavox I-110, Tobii-Dynavox T-15+, Tobii-Dynavox I-13, Tobii-Dynavox I-16, NovaChat 5, NovaChat 5.3, NovaChat 5.4, NovaChat 8.5, NovaChat 12, Chat Fusion 10, Surface 2, Surface 3, Surface Pro 3, Surface Pro 4, Surface Pro 5, Surface Pro 6, Surface Pro 7, Surface Pro 8, Surface Pro 9, Surface Pro X, Surface Go, Surface Go 3, Accent 800-30, Accent 800-40, Accent 1000-20, Accent 1000-30, Accent 1000-40, Accent 1400-20, Accent 1400-30a, Accent 1400-30b, Via Nano, Via Mini, Via Pro, GridPad 10s, GridPad 11, GridPad 12, GridPad 13, GridPad 15, Samsung Galaxy Tab A 8.4, Samsung Galaxy Tab A7 10.4, Samsung Galaxy Tab A7 Lite, Samsung Galaxy Tab A8, Samsung Galaxy Tab A9, Samsung Galaxy Tab A9+, Samsung Galaxy Tab Active 2, Samsung Galaxy Tab Active 3, Samsung Galaxy Tab Active 5, Samsung Galaxy Tab Active 4 Pro, Samsung Galaxy Tab S3, Samsung Galaxy Tab S6, Samsung Galaxy Tab S6 Lite, Samsung Galaxy Tab S7, Samsung Galaxy Tab S7 FE, Samsung Galaxy Tab S7+, Samsung Galaxy Tab S8, Samsung Galaxy Tab S8 Ultra, Samsung Galaxy Tab S8+, Samsung Galaxy Tab S9, Samsung Galaxy Tab S9 FE, Samsung Galaxy Tab S9 FE+, Samsung Galaxy Tab S9 Ultra, Samsung Galaxy Tab S9+, Samsung Galaxy Tab Pro 12.2, Amazon Fire HD 7, Amazon Fire HD 8, Amazon Fire HD 8 Plus, Amazon Fire HD 10, Amazon Fire HD 10 Plus, Amazon Fire Max 11, blank, other tablet]
orientation = "landscape"; //[portrait,landscape]
expose_home_button = "yes"; //[yes,no]
home_button_edge_slope = 30;
expose_camera = "yes"; //[yes,no]
rotate_tablet_180_degrees = "no"; //[yes,no]
//cannot be used with unequal case opening sides or with keyguard frames
add_symmetric_openings = "no"; //[yes,no]
expose_ambient_light_sensors = "yes"; //[yes,no]


/*[Tablet Case]*/
have_a_case = "yes"; //[yes,no]
height_of_opening_in_case = 170;
width_of_opening_in_case = 245;
case_opening_corner_radius = 5;
case_height = 220;
case_width = 275;
case_thickness = 15;
case_corner_radius = 20;
case_to_screen_depth = 5.0; //.1
top_edge_compensation_for_tight_cases = 0.0; // .1
bottom_edge_compensation_for_tight_cases = 0.0; // .1
left_edge_compensation_for_tight_cases = 0.0; // .1
right_edge_compensation_for_tight_cases = 0.0; // .1


/*[App Layout in px]*/
bottom_of_status_bar = 0; //[0:10000]
bottom_of_upper_message_bar = 0; //[0:10000]
bottom_of_upper_command_bar = 0; //[0:10000]
top_of_lower_message_bar = 0; //[0:10000]
top_of_lower_command_bar = 0; //[0:10000]


/*[App Layout in mm]*/
status_bar_height = 0.0; // .1
upper_message_bar_height = 0.0; // .1
upper_command_bar_height = 0.0; // .1
lower_message_bar_height = 0.0; // .1
lower_command_bar_height = 0.0; // .1


/*[Bar Info]*/
expose_status_bar = "no"; //[yes,no]
expose_upper_message_bar = "no"; //[yes,no]
expose_upper_command_bar = "no"; //[yes,no]
expose_lower_message_bar = "no"; //[yes,no]
expose_lower_command_bar = "no"; //[yes,no]
bar_edge_slope = 90; 
bar_corner_radius = 2; // .1


/*[Grid Info]*/
number_of_rows = 3;
number_of_columns = 4;
cell_shape = "rectangular"; // [rectangular,circular]
cell_height_in_px = 0;
cell_width_in_px = 0;
cell_height_in_mm = 25;
cell_width_in_mm = 25;
cell_corner_radius = 3;
cell_diameter = 15;


/*[Grid Special Settings]*/
cell_edge_slope = 90;
// example: 3,6,12
cover_these_cells = "";
// example: 5,8 merges cells 5&6 and 8&9
merge_cells_horizontally_starting_at = "";
// example: 3,4 merges cell 3 and the cell above and cell 4 and the cell above
merge_cells_vertically_starting_at = "";
// example: 3,6,12
add_a_ridge_around_these_cells = "";
height_of_ridge = 2.0; // .1
thickness_of_ridge = 2.0; // .1
cell_top_edge_slope = 90;
cell_bottom_edge_slope = 90;
top_padding = 0.0; // .1
bottom_padding = 0.0; // .1
left_padding = 0.0; // .1
right_padding = 0.0; // .1
hide_grid_region = "no"; //[yes,no]


/*[Mounting Method]*/
mounting_method = "No Mount"; // [No Mount,Suction Cups,Velcro,Screw-on Straps,Clip-on Straps,Posts,Shelf,Slide-in Tabs,Raised Tabs]


/*[Velcro Info]*/
velcro_size = 1; // [1:10mm -3/8 in- Dots, 2:16mm -5/8 in- Dots, 3:20mm -3/4 in- Dots, 4:3/8 in Squares, 5:5/8 in Squares, 6:3/4 in Squares]


/*[Clip-on Straps Info]*/
clip_locations="horizontal only"; //[horizontal only, vertical only, horizontal and vertical]
horizontal_clip_width=20;
vertical_clip_width=20;
distance_between_horizontal_clips=60;
distance_between_vertical_clips=40;
clip_bottom_length = 35;


/*[Posts Info]*/
post_diameter = 4.0; // .1
post_length = 5;
mount_to_top_of_opening_distance = 5; // .1
notch_in_post = "yes"; // [yes,no]
add_mini_tabs = "no"; // [yes,no]
mini_tab_width = 10;
mini_tab_length = 2.0; // .1
mini_tab_inset_distance = 20;
mini_tab_height = 1.0; // .1
rotate_mini_tab = 0;


/*[Shelf Info]*/
shelf_thickness = 2.0; // .1
shelf_depth = 3; // .1
shelf_corner_radius = 5;


/*[Slide-in Tabs Info]*/
slide_in_tab_locations="horizontal only"; //[horizontal only, vertical only, horizontal and vertical]
preferred_slide_in_tab_thickness = 2.0; // .1
horizontal_slide_in_tab_length = 4;
vertical_slide_in_tab_length = 4;
horizontal_slide_in_tab_width=20;
vertical_slide_in_tab_width=20;
distance_between_horizontal_slide_in_tabs=60;
distance_between_vertical_slide_in_tabs=60;


/*[Raised Tabs Info]*/
raised_tab_locations = "horizontal only"; //[horizontal only, vertical only, horizontal and vertical]
raised_tab_height=6;
horizontal_raised_tab_length=8;
horizontal_raised_tab_width=20;
distance_between_horizontal_raised_tabs=60;
vertical_raised_tab_length=8;
vertical_raised_tab_width=20;
distance_between_vertical_raised_tabs=60;
preferred_raised_tab_thickness=2; // .1
raised_tabs_starting_height = 0.0; // .1
ramp_angle = 30;
embed_magnets = "no"; // [yes, no]
magnet_size = "20 x 8 x 1.5"; // [20 x 8 x 1.5, 40 x 10 x 2]


/*[Keyguard Frame Info]*/
have_a_keyguard_frame = "no"; //[yes,no]
keyguard_frame_thickness = 5.0; // .1
keyguard_height = 160;
keyguard_width = 210;
keyguard_corner_radius = 2;
mount_keyguard_with = "snap-in tabs"; //[snap-in tabs, posts]
snap_in_tab_on_top_edge_of_keyguard = "yes"; // [yes,no]
snap_in_tab_on_bottom_edge_of_keyguard = "yes"; // [yes,no]
snap_in_tabs_on_left_and_right_edges_of_keyguard = "yes"; // [yes,no]
//the larger the number the tighter the fit, affects only the keyguard frame
post_tightness_of_fit = 0; //[-10:10]
post_extension_distance = 4; // [1:5]
// set this option to "no" before rendering your design
show_keyguard_with_frame = "no"; //[yes,no]
//the larger the number the tighter the fit
keyguard_vertical_tightness_of_fit = 0; // [-1:.1:1]
//the larger the number the tighter the fit
keyguard_horizontal_tightness_of_fit = 0; // [-1:.1:1]


/*[Split Keyguard Info]*/
split_line_location = 0; // [-300:.1:300]
// set this option to "no" before rendering your design
show_split_line = "no"; //[yes,no]
split_line_type = "flat"; //[flat,dovetails]
dovetail_width = 4.0; //[3:.1:6]
slide_dovetails = 0; // [-3:.1:3]
//the larger the number the tighter the fit, affects only the second half of the keyguard
tightness_of_dovetail_joint = 0; // [-.5:.1:.5]


/*[Sloped Keyguard Edge Info]*/
//can only be applied to 3D-printed, rounded-rectangular keyguards
add_sloped_keyguard_edge = "no"; //[yes,no]
sloped_edge_starting_height = 1.0; //.1
horizontal_sloped_edge_width = 10.0; //.1
vertical_sloped_edge_width = 10.0; //.1
case_to_slope_depth = 0.0; //.1
extend_lip_to_edge_of_case = "no"; //[yes,no]


/*[Engraved/Embossed Text]*/
text = "";
//measured in millimeters
text_height = 5.0; //.1
font_style = "normal"; //[normal,bold,italic,bold italic]
keyguard_location = "top surface"; //[top surface,bottom surface]
show_back_of_keyguard = "no"; // [yes,no]
keyguard_region = "screen region"; //[screen region,case region,tablet region]
//positive numbers for embossed text, only on top surface
text_depth = -2.0; // .1
text_horizontal_alignment = "center"; //[left,center,right]
text_vertical_alignment = "center"; //[bottom,baseline,center,top]
text_angle = "horizontal"; // [vertical downward,horizontal,vertical upward,horizontal inverted]
//% of screen, case opening, or tablet width
slide_horizontally = 0; //[0:100]
//% of screen, case opening, or tablet height
slide_vertically = 0; //[0:100]


/*[Cell Inserts]*/
Braille_location = "above opening"; //[above opening, below opening, above and below opening, left of opening, right of opening, left and right of opening]
//separate Braille elements with a comma and no space
Braille_text = "";
// 10 = standard size Braille
Braille_size_multiplier = 10; //[1:30]
add_circular_opening = "yes"; //[yes,no]
diameter_of_opening = 10; // .1
Braille_to_opening_distance = 5.0; // .1
engraved_text = "";
//the larger the number the tighter the fit
insert_tightness_of_fit = 0; //[-1:.1:1]
insert_recess = 0.0; // .1


/*[Free-form and Hybrid Keyguard Openings]*/
//px = pixels, mm = millimeters
unit_of_measure_for_screen = "px"; //[px,mm]
//which corner is (0,0)?
starting_corner_for_screen_measurements = "upper-left"; //[upper-left, lower-left]


/*[Special Actions and Settings]*/
// set this option to "no" before rendering your design
include_screenshot = "no"; //[yes,no]
keyguard_display_angle = 0; // [0,30,45,60,75,90]
unequal_left_side_of_case_opening = 0.0; // .1
unequal_bottom_side_of_case_opening = 0.0; // .1
unequal_left_side_of_case = 0;
unequal_bottom_side_of_case = 0;
//see instructions in Console pane
move_screenshot_horizontally = 0.0; // [-50:.1:50]
//see instructions in Console pane
move_screenshot_vertically = 0.0; // [-50:.1:50]
//not for use with laser-cut keyguards
keyguard_edge_chamfer = 1.0; // .1
//not for use with laser-cut keyguards
cell_edge_chamfer = 1.0; // .1
hide_screen_region = "no"; //[yes,no]
//assuming 0.2 mm layers for a total of 0.4 mm
first_two_layers_only = "no"; //[yes,no]
//specify the lower left coordinate (example: 10,50)
trim_to_rectangle_lower_left = "";
//specify the upper right coordinate (example: 80,125)
trim_to_rectangle_upper_right = "";
use_Laser_Cutting_best_practices = "yes"; // [yes,no]
//21 entries e.g., 190,140,10,150,100,20,20,20,20,5,5,5,2,10,4,4,4,10,10,10,10
other_tablet_general_sizes = "";
//3 entries e.g., 1000,1500,0.100
other_tablet_pixel_sizes = "";
//for use with Maker World's online customizer
my_screen_openings = "";
//for use with Maker World's online customizer
my_case_openings = "";
//for use with Maker World's online customizer
my_case_additions = "";
//for use with Maker World's online customizer
my_tablet_openings = "";
//for use with Maker World's online customizer
screenshot_file = "default.svg";




/*[Hidden]*/

// IMPORTANT — DECLARATION ORDER IN THIS SECTION
// ----------------------------------------------
// OpenSCAD variables are constants evaluated at parse time. In practice this means
// a variable's value is determined by the *last* assignment in the file, but a
// variable used inside another variable's expression must have already appeared
// earlier in the file or the reference will resolve to 0 / undef.
//
// All variables below depend on the User Input parameters above, and many depend
// on other variables earlier in this Hidden section. When adding a new variable:
//   1. Place it AFTER all variables it references.
//   2. Place it BEFORE any variables that reference it.
//   3. Do not insert variables between unrelated groups without checking dependencies.
//
// The rough dependency order is:
//   version / flags → fudge constants → laser-cut variables → tablet data →
//   tablet selection → screen/case geometry → grid geometry → bar geometry →
//   cell geometry → opening/addition helpers → mounting geometry → text/SVG helpers

keyguard_designer_version = 78; //*****************************

// if this is the "MW" version for Maker World set this statement to true and comment the include statement before start of Main
MW_version = false;

// Boolean shorthands for the most-used string comparisons.
// Use these in conditionals instead of comparing against string literals
// directly: a typo in a constant name causes an immediate parse error,
// while a typo in a string literal fails silently.
is_3d_printed     = (type_of_keyguard == "3D-Printed");
is_laser_cut      = (type_of_keyguard == "Laser-Cut");
has_case          = (have_a_case == "yes");
has_frame         = (have_a_keyguard_frame == "yes");
is_landscape      = (orientation == "landscape");
using_px          = (unit_of_measure_for_screen == "px");
lc_best_practices = (use_Laser_Cutting_best_practices == "yes");
screenshotcolor = (MW_version) ? "white" : "magenta";

// the "true" outcome of the following line of code is for controling keyguard frame mounting options
// orientation = (generate=="keyguard frame") ? "landscape" : orientation;

fudge = 0.01;
ff = fudge; // i.e. fudge factor
camera_cut_angle = 50;

//laser-cut variables
acrylic_thickness = 3.175;
acrylic_slide_in_tab_thickness = (lc_best_practices) ?  1 : preferred_slide_in_tab_thickness;
horizontal_acrylic_slide_in_tab_length = (lc_best_practices) ?  acrylic_thickness : horizontal_slide_in_tab_length;
vertical_acrylic_slide_in_tab_length = (lc_best_practices) ?  acrylic_thickness : vertical_slide_in_tab_length;
acrylic_case_corner_radius = (lc_best_practices) ?  2 : case_opening_corner_radius;
sat_incl_acrylic = (is_laser_cut) ? acrylic_thickness : screen_area_thickness;
camera_offset_acrylic = (is_laser_cut) ? sat_incl_acrylic/tan(camera_cut_angle) : 0;


rs_inc_acrylic = (is_3d_printed) ? cell_edge_slope : 90;

bar_edge_slope_inc_acrylic = (is_3d_printed) ? bar_edge_slope : 90;
m_m = (is_3d_printed)  ? mounting_method :
	(is_laser_cut && mounting_method=="Slide-in Tabs") ? "Slide-in Tabs" :
	"No Mount";
hbes = (is_3d_printed) ? home_button_edge_slope : 90;


//Tablet Parameters -- 0:Tablet Width, 1:Tablet Height, 2:Tablet Thickness, 3:Screen Width, 4:Screen Height, 
//                     5:Right Border Width, 6:Left Border Width, 7:Bottom Border Height, 8:Top Border Height, 
//                     9:Distance from edge of screen to Home Button, 10:Home Button Height, 11:Home Button Width, 12:Home Button Location,
//                     13:Distance from edge of screen to Camera, 14:Camera Height, 15:Camera Width, 16:Camera Location,
//                     17:Conversion Factors (# vertical pixels, # horizontal pixels, pixel size (mm)), 
//                     18:Tablet Top Left Corner Radius, 19:Tablet Top Right Corner Radius, 20:Tablet Bottom Left Corner Radius, 21:Tablet Bottom Right Corner Radius
iPad_data=[242.9,189.7,13.4,197.0176,147.7632,22.929,22.929,20.959,20.959,11.329,11.2,11.2,2,12.529,4.5,4.5,4,[768,1024,0.1924],10,10,10,10];
iPad2_data=[241.3,185.8,8.8,197.0176,147.7632,22.129,22.129,19.009,19.009,11.329,11.3,11.3,2,11.029,4.5,4.5,4,[768,1024,0.1924],10,10,10,10];
iPad3rdgeneration_data=[241.3,185.8,9.41,197.0176,147.7632,22.129,22.129,19.009,19.009,11.329,11.3,11.3,2,11.029,4.5,4.5,4,[1536,2048,0.0962],10,10,10,10];
iPad4thgeneration_data=iPad3rdgeneration_data;
iPad5thgeneration_data=[240.0,169.47,6.1,197.0176,147.7632,21.479,21.479,10.844,10.844,11.379,14.6,14.6,2,10.409,12.5,4.5,4,[1536,2048,0.0962],10,10,10,10];
iPad6thgeneration_data=iPad5thgeneration_data;
iPad7thgeneration_data=[250.59,174.08,7.5,207.792,155.844,21.386,21.386,9.108,9.108,11.326,12.6,12.6,2,10.316,12.5,4.5,4,[1620,2160,0.0962],10,10,10,10];
iPad8thgeneration_data=iPad7thgeneration_data;
iPad9thgeneration_data=iPad7thgeneration_data;
iPad10thgeneration_data=[248.63,179.51,7.03,227.032,157.768,10.784,10.784,10.861,10.861,0,0,0,0,5.621,5.621,30,1,[1640,2360,0.0962],10,10,10,10];
iPad11thgeneration_A16_data=iPad10thgeneration_data;
iPadPro97inch_data=[240.0,169.47,6.1,197.0176,147.7632,21.479,21.479,10.844,10.844,11.379,14.6,14.6,2,10.379,4.5,4.5,4,[1536,2048,0.0962],10,10,10,10];
iPadPro105inch_data=[250.59,174.08,6.1,213.9488,160.4616,18.307,18.307,6.799,6.799,9.347,14.6,14.6,2,9.107,4.5,4.5,4,[1668,2224,0.0962],10,10,10,10];
iPadPro11inch1stGeneration_data=[247.64,178.52,5.953,229.7256,160.4616,8.943,8.943,9.019,9.019,0,0.0,0.0,2,4.573,4.5,4.5,4,[1668,2388,0.0962],10,10,10,10];
iPadPro11inch2ndGeneration_data=iPadPro11inch1stGeneration_data;
iPadPro11inch3rdGeneration_data=iPadPro11inch1stGeneration_data;
iPadPro11inch4thGeneration_data=iPadPro11inch1stGeneration_data;
iPadPro11inch_M4_data=[249.7,177.51,5.3,232.804,160.4616,8.4333,8.4333,8.5141,8.5141,0,0.0,0.0,2,3.8041,3.5,42.5,1,[1668,2420,0.0962],10,10,10,10];
iPadPro11inch_M5_data=iPadPro11inch_M4_data;
iPadPro129inch1stGeneration_data=[305.69,220.58,6.9,262.8184,197.0176,21.419,21.419,11.769,11.769,11.319,14.6,14.6,2,10.319,4.5,4.5,4,[2048,2732,0.0962],10,10,10,10];
iPadPro129inch2ndGeneration_data=iPadPro129inch1stGeneration_data;
iPadPro129inch3rdGeneration_data=[280.66,214.99,5.908,262.8184,197.0176,9.2,9.2,9.18,9.18,0,0,0,0,4.534,33,4.5,4,[2048,2732,0.0962],10,10,10,10];
iPadPro129inch4thGeneration_data=iPadPro129inch3rdGeneration_data;
iPadPro129inch5thGeneration_data=[280.66,214.99,6.44,262.8184,197.0176,9.2,9.2,9.18,9.18,0,0,0,0,4.534,33,4.5,4,[2048,2732,0.0962],10,10,10,10];
iPadPro129inch6thGeneration_data=iPadPro129inch5thGeneration_data;
iPadPro13inch_M4_data=[281.58,215.53,5.3,264.7424,198.5568,8.4021,8.4021,8.4741,8.4741,0,0,0,0,3.7641,3.5,42,1,[2064,2752,0.0962],10,10,10,10];
iPadPro13inch_M5_data=iPadPro13inch_M4_data;
iPadmini_data=[200.1,134.7,7.2,159.5392,119.6544,20.266,20.266,7.512,7.512,11,10.0,10.0,2,10,12.5,4.5,4,[768,1024,0.1558],10,10,10,10];
iPadmini2_data=[200.1,134.7,7.5,159.5392,119.6544,20.266,20.266,7.512,7.512,11,10.0,10.0,2,10,4.5,4.5,4,[1536,2048,0.0779],10,10,10,10];
iPadmini3_data=iPadmini2_data;
iPadmini4_data=[203.16,134.75,6.1,159.5392,119.6544,21.796,21.796,7.537,7.537,12.286,10.6,10.6,2,11.296,4.5,4.5,4,[1536,2048,0.0779],10,10,10,10];
iPadmini5_data=iPadmini4_data;
iPadmini6_data=[195.43,134.75,6.32,176.5214,115.9152,9.438313,9.438313,9.406902,9.406902,0,0,0,0,5.058313,6,6,4,[1488,2266,0.0779],12,12,12,12];
iPadmini7_A17Pro_data=iPadmini6_data;
iPadAir_data=[240.0,169.5,7.5,197.0176,147.7632,21.479,21.479,10.859,10.859,11.379,10.7,10.7,2,10.379,4.5,4.5,4,[1536,2048,0.0962],10,10,10,10];
iPadAir2_data=[240.0,169.5,6.1,197.0176,147.7632,21.479,21.479,10.844,10.844,11.379,14.6,14.6,2,10.409,4,4,4,[1536,2048,0.0962],10,10,10,10];
iPadAir3_data=[250.59,174.08,6.1,213.9488,160.4616,18.307,18.307,6.799,6.799,9.347,14.6,14.6,2,8.687,4,4,4,[1668,2224,0.0962],10,10,10,10];
iPadAir4_data=[247.64,178.51,6.123,227.032,157.768,10.2697,10.2697,10.3561,10.3561,0,0,0,0,5.03,4.5,4.5,4,[1640,2360,0.0962],12,12,12,12];
iPadAir5_data=iPadAir4_data;
iPadAir11inch_M2_data=[247.64,178.52,6.123,227.032,157.768,10.2897,10.2897,10.3661,10.3661,0,0,0,0,5.8761,4.5,34,1,[1640,2360,0.0962],12,12,12,12];
iPadAir11inch_M3_data=iPadAir11inch_M2_data;
iPadAir11inch_M4_data=iPadAir11inch_M2_data;
iPadAir13inch_M2_data=[280.66,215.0,6.1,262.8184,197.0176,8.9042,8.9042,8.9788,8.9788,0,0,0,0,4.7588,3.5,35,1,[2048,2732,0.0962],12,12,12,12];
iPadAir13inch_M3_data=iPadAir13inch_M2_data;
iPadAir13inch_M4_data=iPadAir13inch_M2_data;
surface_2_data=[275.0,173,8.9,234.432,131.868,20.269,20.269,20.558,20.558,0,0.0,0.0,0,6.24,5.0,50.0,1,[1080,1920,0.1221],5,5,5,5];
surface_3_data=[267.0,187,8.6,227.904,151.936,19.556,19.556,17.537,17.537,0,0.0,0.0,6.24,0,5.0,50.0,1,[1280,1920,0.1187],5,5,5,5];
surface_pro_3_data=[290.0,201,9.1,254.016,169.344,18,18,15.833,15.833,0,0.0,0.0,0,6.24,5.0,50.0,1,[1440,2160,0.1176],5,5,5,5];
surface_pro_4_data=[292.1,201.42,8.45,260.1936,173.4624,15.911,15.911,13.95,13.95,0,0.0,0.0,0,6.24,5.0,50.0,1,[1824,2736,0.0951],5,5,5,5];
surface_pro_5_data=[292.0,201,8.5,260.1936,173.4624,15.861,15.861,13.74,13.74,0,0.0,0.0,0,6.24,5.0,50.0,1,[1824,2736,0.0951],5,5,5,5];
surface_pro_6_data=[292.0,201,8.5,260.1936,173.4624,15.861,15.861,13.74,13.74,0,0.0,0.0,0,6.24,5.0,50.0,1,[1824,2736,0.0951],5,5,5,5];
surface_pro_7_data=[292.0,201,8.5,260.1936,173.4624,15.861,15.861,13.74,13.74,0,0.0,0.0,0,6.24,5.0,50.0,1,[1824,2736,0.0951],5,5,5,5];
surface_pro_8_data=[287,208,9.3,273.888,182.592,6.556,6.556,12.704,12.704,0,0.0,0.0,0,6.24,5.0,50.0,1,[1920,2880,0.0951],5,5,5,5];
surface_pro_9_data=[287,209,9.3,273.888,182.592,6.556,6.556,13.204,13.204,0,0.0,0.0,0,6.24,5.0,50.0,1,[1920,2880,0.0951],5,5,5,5];
surface_pro_x_data=[287,208,7.3,273.888,182.592,6.556,6.556,12.704,12.704,0,0.0,0.0,0,6.24,5.0,50.0,1,[1920,2880,0.0951],5,5,5,5];
surface_go_data=[245,175,8.3,210.78,140.52,17.154,17.154,17.27,17.27,0,0.0,0.0,0,0,0.0,0.0,0,[1200,1800,0.1171],5,5,5,5];
surface_go_2_data=[245,175,8.3,221.76,147.84,11.6635,11.6635,13.58,13.58,0,0.0,0.0,0,0,0.0,0.0,0,[1280,1920,0.1155],5,5,5,5];
surface_go_3_data=[245,175,8.3,221.76,147.84,11.6635,11.6635,13.58,13.58,0,0.0,0.0,0,0,0.0,0.0,0,[1280,1920,0.1155],5,5,5,5];
surface_go_4_data=[245,175,8.3,221.76,147.84,11.6635,11.6635,13.58,13.58,0,0.0,0.0,0,0,0.0,0.0,0,[1280,1920,0.1155],5,5,5,5];
accent_800_30_data=[0,0,0,173,108,0,0,0,0,8,10,10,3,8.5,4.5,4.5,1,[1200,1920,0.090],0,0,0,0];
accent_800_40_data=[0,0,0,173,108,0,0,0,0,8,10,10,3,8.5,4.5,4.5,1,[1200,1920,0.090],0,0,0,0];
accent_1000_20_data=[0,0,0,216.7552,135.472,0,0,0,0,10,10,10,3,11,6,6,1,[800,1280,0.16934],0,0,0,0];
accent_1000_30_data=[0,0,0,216.768,135.48,0,0,0,0,10,10,10,3,10,4,4,1,[1200,1920,0.1129],0,0,0,0];
accent_1000_40_data=[0,0,0,216.768,135.48,0,0,0,0,10,10,10,3,10,4,4,1,[1200,1920,0.1129],0,0,0,0];
accent_1400_20_data=[0,0,0,308.736,173.664,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[1080,1920,0.1608],0,0,0,0];
accent_1400_30a_data=[0,0,0,310.784,174.816,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[1440,2560,0.1214],0,0,0,0];
accent_1400_30b_data=[0,0,0,305.664,171.936,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[2160,3840,0.0796],0,0,0,0];
Via_Pro_data=iPadPro11inch2ndGeneration_data;
Via_Mini_data=iPadmini6_data;
Via_Nano_data=[147.64,71.63,7.81,141.0912,65.0808,3.275,3.275,3.275,3.275,0,0,0,0,0,0,0,0,[1179,2556,0.0552],10,10,10,10];
amazon_fire_hd_7_data=[192,115,9.6,152.064,89.1,19.949,19.949,12.939,12.939,0,0.0,0.0,0,7,4.5,4.5,1,[600,1024,0.1485],10,10,10,10];
amazon_fire_hd_8_data=[202,137,9.7,172.032,107.52,14.989,14.989,14.743,14.743,0,0.0,0.0,0,7,4.5,4.5,1,[800,1280,0.1344],10,10,10,10];
amazon_fire_hd_8_plus_data=[202,137,9.7,172.032,107.52,14.989,14.989,14.743,14.743,0,0.0,0.0,0,7,4.5,4.5,1,[800,1280,0.1344],10,10,10,10];
amazon_fire_hd_10_data=[262,157,9.8,217.728,136.08,22.135,22.135,10.46,10.46,0,0.0,0.0,0,7,4.5,4.5,1,[1200,1920,0.1134],10,10,10,10];
amazon_fire_hd_10_plus_data=[247,166,9.2,217.728,136.08,14.635,14.635,14.96,14.96,0,0.0,0.0,0,7,4.5,4.5,1,[1200,1920,0.1134],10,10,10,10];
amazon_fire_max_11_data=[259.1,163.7,7.5,238.4,143.04,10.3,10.3,10.3,10.3,0,0.0,0.0,0,7,4.5,4.5,1,[1200,2000,0.1192],10,10,10,10];
dynavox_i_12_plus_data=[288,222.5,23,246.3744,184.7808,21,21,13,24,0,0.0,0.0,0,14.5,5,5,1,[768,1024,0.2406],10,10,10,10];
dynavox_indi_data=[239,165,20,216.576,135.36,11.6,11.6,14,16,7,8,8,3,10,3.5,3.5,1,[1200,1920,0.1128],10,10,10,10];
tobii_t_15Plus_data=[352,276,0,307.5,230.5,23,21.5,17,31,0,0,0,0,17,6,6,1,[768,1024,0.3001],17,17,5,5];
tobii_i_110_data=[0,0,0,216.576,135.36,0,0,0,0,10,10,10,3,10,6,35,1,[1200,1920,0.1128],0,0,0,0];
tobii_i_13_data=[322.5,210,0,293.5,165,14.5,14.5,26,16,0,0,0,0,10,5,5,1,[1080,1920,0.1528],10,10,2,2];
tobii_i_16_data=[376,236,0,344.352,193.698,15.5,15.5,25,17,0,0,0,0,10,8.5,8.5,1,[1080,1920,0.17935],10,10,2,2];
gridpad_10s_data=[0,0,0,216.96,135.6,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[1200,1920,0.113],0,10,10,10];
gridpad_11_data=[0,0,0,257.088,144.612,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[1080,1920,0.1339],5,5,5,5];
gridpad_12_data=[0,0,0,276.1,155.306,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[1080,1920,0.1438],5,5,5,5];
gridpad_13_data=[333,228,17,294.912,165.888,19,19,44,19,0,0,0,0,0,0,0,0,[1080,1920,0.1536],15,15,15,15];
gridpad_15_data=[0,0,0,343,193,0,0,0,0,0,0,0,0,0,0,0,0,[1080,1920,0.1787],4,4,4,4];
SamsungGalaxyTabS3_data=[237.3,169,6,197.0424,147.7818,20.129,20.129,10.609,10.609,0,0.0,0.0,0,0,0.0,0.0,0,[1536,2048,0.0962],5,5,5,5];
SamsungGalaxyTabA84_data=[202,125.2,7.1,180.6222,112.8889,10.689,10.689,6.156,6.156,0,0,0,0,0,0,0,0,[1200,1920,0.094074074],10,10,10,10];
SamsungGalaxyTabA7104_data=[247.6,157.4,7,226.7857,136.0714,10.407,10.407,10.664,10.664,0,0,0,0,0,0,0,0,[1200,2000,0.113392857],10,10,10,10];
SamsungGalaxyTabA7Lite_data=[212.5,124.7,8,190.1453,113.5196,11.177,11.177,5.59,5.59,0,0,0,0,0,0,0,0,[800,1340,0.141899441],10,10,10,10];
SamsungGalaxyTabA8_data=[246.8,161.9,6.9,225.7778,141.1111,10.511,10.511,10.394,10.394,0,0,0,0,0,0,0,0,[1200,1920,0.117592593],10,10,10,10];
SamsungGalaxyTabA9_data=[211,124.7,8,190.1453,113.5196,10.427,10.427,5.59,5.59,0,0,0,0,0,0,0,0,[800,1340,0.141899441],10,10,10,10];
SamsungGalaxyTabA9Plus_data=[257.1,168.7,6.9,236.7379,147.9612,10.181,10.181,10.369,10.369,0,0,0,0,0,0,0,0,[1200,1920,0.123300971],10,10,10,10];
SamsungGalaxyTabActive5_data=[213.8,126.8,10.1,172.3251,107.7032,20.737,20.737,9.548,9.548,0,0,0,0,0,0,0,0,[1200,1920,0.08975265],10,10,10,10];
SamsungGalaxyTabActive3_data=[213.8,126.8,9.9,172.3251,107.7032,20.737,20.737,9.548,9.548,0,0,0,0,0,0,0,0,[1200,1920,0.08975265],10,10,10,10];
SamsungGalaxyTabActive2_data=[214.7,127.6,9.9,172.0212,107.5132,21.3394,21.3394,10.0434,10.0434,0,0,0,0,0,0,0,0,[1200,1920,0.1344],10,10,10,10];
SamsungGalaxyTabActive4Pro_data=[242.9,170.2,10.2,217.7143,136.0714,12.593,12.593,17.064,17.064,0,0,0,0,0,0,0,0,[1200,1920,0.113392857],10,10,10,10];
SamsungGalaxyTabS6_data=[244.5,159.5,5.7,226.5645,141.6028,8.968,8.968,8.949,8.949,0,0,0,0,0,0,0,0,[1600,2560,0.088501742],10,10,10,10];
SamsungGalaxyTabS6Lite_data=[244.5,154.3,7,226.7857,136.0714,8.857,8.857,9.114,9.114,0,0,0,0,0,0,0,0,[1200,2000,0.113392857],10,10,10,10];
SamsungGalaxyTabS7_data=[253.8,165.3,6.3,237.3139,148.3212,8.243,8.243,8.489,8.489,0,0,0,0,0,0,0,0,[1600,2560,0.09270073],10,10,10,10];
SamsungGalaxyTabS7FE_data=[284.8,185,6.3,267.5885,167.2428,8.606,8.606,8.879,8.879,0,0,0,0,0,0,0,0,[1600,2560,0.104526749],10,10,10,10];
SamsungGalaxyTabS7Plus_data=[285,185,5.7,267.3684,167.2962,8.816,8.816,8.852,8.852,0,0,0,0,0,0,0,0,[1752,2800,0.095488722],10,10,10,10];
SamsungGalaxyTabS8_data=[253.8,165.3,6.3,237.3139,148.3212,8.243,8.243,8.489,8.489,0,0,0,0,0,0,0,0,[1600,2560,0.09270073],10,10,10,10];
SamsungGalaxyTabS8Ultra_data=[326.4,208.6,5.5,313.2667,195.58,6.567,6.567,6.51,6.51,0,0,0,0,0,0,0,0,[1848,2960,0.105833333],10,10,10,10];
SamsungGalaxyTabS8Plus_data=[285,185,5.7,267.3684,167.2962,8.816,8.816,8.852,8.852,0,0,0,0,0,0,0,0,[1752,2800,0.095488722],10,10,10,10];
SamsungGalaxyTabS9_data=[254.3,165.8,5.9,237.3139,148.3212,8.493,8.493,8.739,8.739,0,0,0,0,0,0,0,0,[1600,2560,0.09270073],10,10,10,10];
SamsungGalaxyTabS9FE_data=[254.3,165.8,6.5,235.0265,146.8916,9.637,9.637,9.454,9.454,0,0,0,0,0,0,0,0,[1440,2304,0.102008032],10,10,10,10];
SamsungGalaxyTabS9FEPlus_data=[285.4,185.4,6.5,267.5885,167.2428,8.906,8.906,9.079,9.079,0,0,0,0,0,0,0,0,[1600,2560,0.104526749],10,10,10,10];
SamsungGalaxyTabS9Ultra_data=[326.4,208.6,5.5,314.5774,196.3983,5.911,5.911,6.101,6.101,0,0,0,0,0,0,0,0,[1848,2960,0.106276151],10,10,10,10];
SamsungGalaxyTabS9Plus_data=[285.4,185.4,5.7,267.3684,167.2962,9.016,9.016,9.052,9.052,0,0,0,0,0,0,0,0,[1752,2800,0.095488722],10,10,10,10];
SamsungGalaxyTabPro12_2_data=[295.6,204,8,263.168,164.48,16.172,16.172,19.733,19.733,0,0.0,0.0,0,0,0.0,0.0,0,[1600,2560,0.1028],5,5,5,5];
novachat_5_data=[156.2,76.2,5,121.536,68.364,17.292,17.292,3.896,3.896,0,0.0,0.0,0,0,0.0,0.0,0,[1080,1920,0.0633],5,5,5,5];
novachat_5_3_data=[0,0,0,125.952,70.848,0,0,0,0,0,0,0,0,0,0,0,0,[1440,2560,0.0492],0,0,0,0];
novachat_5_4_data=[0,0,0,121.6128,68.4072,0,0,0,0,0,0,0,0,0,0,0,0,[1080,1920,0.06334],0,0,0,0];
novachat_8_5_data=[0,0,0,172.416,107.76,0,0,0,0,0,0,0,0,0,0,0,0,[1200,1920,0.0898],0,0,0,0];
novachat12_data=[295.6,204,8,263.168,164.48,16.172,16.172,19.733,19.733,0,0.0,0.0,0,0,0.0,0.0,0,[1600,2560,0.1028],5,5,5,5];
chatfusion10_data=[0,0,0,218.496,136.56,0,0,0,0,0,0.0,0.0,0,0,0.0,0.0,0,[1200,1920,0.1138],0,0,0,0];
blank_data=[200,60,3,200,60,0,0,0,0,0,0,0,0,0,0,0,0,[60,200,1],0,0,0,0];
catch_all_data=[400,100,20,216.576,135.36,11.6,11.6,14,16,7,8,8,3,10,3.5,3.5,1,[1200,1920,0.1128],10,10,10,10];


tablet_params = 
    (type_of_tablet=="iPad")? iPad_data
  : (type_of_tablet=="iPad2")? iPad2_data
  : (type_of_tablet=="iPad 3rd generation")? iPad3rdgeneration_data
  : (type_of_tablet=="iPad 4th generation")? iPad4thgeneration_data
  : (type_of_tablet=="iPad 5th generation")? iPad5thgeneration_data
  : (type_of_tablet=="iPad 6th generation")? iPad6thgeneration_data
  : (type_of_tablet=="iPad 7th generation")? iPad7thgeneration_data
  : (type_of_tablet=="iPad 8th generation")? iPad8thgeneration_data
  : (type_of_tablet=="iPad 9th generation")? iPad9thgeneration_data
  : (type_of_tablet=="iPad 11th generation A16")? iPad11thgeneration_A16_data
  : (type_of_tablet=="iPad 10th generation")? iPad10thgeneration_data
  : (type_of_tablet=="iPad Pro 9.7-inch")? iPadPro97inch_data
  : (type_of_tablet=="iPad Pro 10.5-inch")? iPadPro105inch_data
  : (type_of_tablet=="iPad Pro 11-inch 1st Generation")? iPadPro11inch1stGeneration_data
  : (type_of_tablet=="iPad Pro 11-inch 2nd Generation")? iPadPro11inch2ndGeneration_data
  : (type_of_tablet=="iPad Pro 11-inch 3rd Generation")? iPadPro11inch3rdGeneration_data
  : (type_of_tablet=="iPad Pro 11-inch 4th Generation")? iPadPro11inch4thGeneration_data
  : (type_of_tablet=="iPad Pro 11-inch M4")? iPadPro11inch_M4_data
  : (type_of_tablet=="iPad Pro 11-inch M5")? iPadPro11inch_M5_data
  : (type_of_tablet=="iPad Pro 12.9-inch 1st Generation")? iPadPro129inch1stGeneration_data
  : (type_of_tablet=="iPad Pro 12.9-inch 2nd Generation")? iPadPro129inch2ndGeneration_data
  : (type_of_tablet=="iPad Pro 12.9-inch 3rd Generation")? iPadPro129inch3rdGeneration_data
  : (type_of_tablet=="iPad Pro 12.9-inch 4th Generation")? iPadPro129inch4thGeneration_data
  : (type_of_tablet=="iPad Pro 12.9-inch 5th Generation")? iPadPro129inch5thGeneration_data
  : (type_of_tablet=="iPad Pro 12.9-inch 6th Generation")? iPadPro129inch6thGeneration_data
  : (type_of_tablet=="iPad Pro 13-inch M4")? iPadPro13inch_M4_data
  : (type_of_tablet=="iPad Pro 13-inch M5")? iPadPro13inch_M5_data
  : (type_of_tablet=="iPad mini")? iPadmini_data
  : (type_of_tablet=="iPad mini 2")? iPadmini2_data
  : (type_of_tablet=="iPad mini 3")? iPadmini3_data
  : (type_of_tablet=="iPad mini 4")? iPadmini4_data
  : (type_of_tablet=="iPad mini 5")? iPadmini5_data
  : (type_of_tablet=="iPad mini 6")? iPadmini6_data
  : (type_of_tablet=="iPad mini 7 A17 Pro")? iPadmini7_A17Pro_data
  : (type_of_tablet=="iPad Air")? iPadAir_data
  : (type_of_tablet=="iPad Air 2")? iPadAir2_data
  : (type_of_tablet=="iPad Air 3")? iPadAir3_data
  : (type_of_tablet=="iPad Air 4")? iPadAir4_data
  : (type_of_tablet=="iPad Air 5")? iPadAir5_data
  : (type_of_tablet=="iPad Air 11-inch M2")? iPadAir11inch_M2_data
  : (type_of_tablet=="iPad Air 11-inch M3")? iPadAir11inch_M3_data
  : (type_of_tablet=="iPad Air 11-inch M4")? iPadAir11inch_M4_data
  : (type_of_tablet=="iPad Air 13-inch M2")? iPadAir13inch_M2_data
  : (type_of_tablet=="iPad Air 13-inch M3")? iPadAir13inch_M3_data
  : (type_of_tablet=="iPad Air 13-inch M4")? iPadAir13inch_M4_data
  : (type_of_tablet=="NovaChat 5")? novachat_5_data
  : (type_of_tablet=="NovaChat 5.3")? novachat_5_3_data
  : (type_of_tablet=="NovaChat 5.4")? novachat_5_4_data
  : (type_of_tablet=="NovaChat 8.5")? novachat_8_5_data
  : (type_of_tablet=="NovaChat 12")? novachat12_data
  : (type_of_tablet=="Chat Fusion 10")? chatfusion10_data
  : (type_of_tablet=="Surface 2")? surface_2_data
  : (type_of_tablet=="Surface 3")? surface_3_data
  : (type_of_tablet=="Surface Pro 3")? surface_pro_3_data
  : (type_of_tablet=="Surface Pro 4")? surface_pro_4_data
  : (type_of_tablet=="Surface Pro 5")? surface_pro_5_data
  : (type_of_tablet=="Surface Pro 6")? surface_pro_6_data
  : (type_of_tablet=="Surface Pro 7")? surface_pro_7_data
  : (type_of_tablet=="Surface Pro 8")? surface_pro_8_data
  : (type_of_tablet=="Surface Pro 9")? surface_pro_9_data
  : (type_of_tablet=="Surface Pro X")? surface_pro_x_data
  : (type_of_tablet=="Surface Go")? surface_go_data
  : (type_of_tablet=="Surface Go 2")? surface_go_2_data
  : (type_of_tablet=="Surface Go 3")? surface_go_3_data
  : (type_of_tablet=="Surface Go 4")? surface_go_4_data
  : (type_of_tablet=="Accent 800-30")? accent_800_30_data
  : (type_of_tablet=="Accent 800-40")? accent_800_40_data
  : (type_of_tablet=="Accent 1000-20")? accent_1000_20_data
  : (type_of_tablet=="Accent 1000-30")? accent_1000_30_data
  : (type_of_tablet=="Accent 1000-40")? accent_1000_40_data
  : (type_of_tablet=="Accent 1400-20")? accent_1400_20_data
  : (type_of_tablet=="Accent 1400-30a")? accent_1400_30a_data
  : (type_of_tablet=="Accent 1400-30b")? accent_1400_30b_data
  : (type_of_tablet=="Via Nano")? Via_Nano_data
  : (type_of_tablet=="Via Mini")? Via_Mini_data
  : (type_of_tablet=="Via Pro")? Via_Pro_data
  : (type_of_tablet=="Amazon Fire HD 7")? amazon_fire_hd_7_data
  : (type_of_tablet=="Amazon Fire HD 8")? amazon_fire_hd_8_data
  : (type_of_tablet=="Amazon Fire HD 8 Plus")? amazon_fire_hd_8_plus_data
  : (type_of_tablet=="Amazon Fire HD 10")? amazon_fire_hd_10_data
  : (type_of_tablet=="Amazon Fire HD 10 Plus")? amazon_fire_hd_10_plus_data
  : (type_of_tablet=="Amazon Fire Max 11")? amazon_fire_max_11_data
  : (type_of_tablet=="Dynavox I-12+")? dynavox_i_12_plus_data
  : (type_of_tablet=="Tobii-Dynavox T-15+")? tobii_t_15Plus_data
  : (type_of_tablet=="Tobii-Dynavox I-110")? tobii_i_110_data
  : (type_of_tablet=="Tobii-Dynavox I-13")? tobii_i_13_data
  : (type_of_tablet=="Tobii-Dynavox I-16")? tobii_i_16_data
  : (type_of_tablet=="Dynavox Indi")? dynavox_indi_data
  : (type_of_tablet=="GridPad 10s") ? gridpad_10s_data
  : (type_of_tablet=="GridPad 11") ? gridpad_11_data
  : (type_of_tablet=="GridPad 12") ? gridpad_12_data
  : (type_of_tablet=="GridPad 13") ? gridpad_13_data
  : (type_of_tablet=="GridPad 15") ? gridpad_15_data
  : (type_of_tablet=="Samsung Galaxy Tab A 8.4")? SamsungGalaxyTabA84_data
  : (type_of_tablet=="Samsung Galaxy Tab A7 10.4")? SamsungGalaxyTabA7104_data
  : (type_of_tablet=="Samsung Galaxy Tab A7 Lite")? SamsungGalaxyTabA7Lite_data
  : (type_of_tablet=="Samsung Galaxy Tab A8")? SamsungGalaxyTabA8_data
  : (type_of_tablet=="Samsung Galaxy Tab A9")? SamsungGalaxyTabA9_data
  : (type_of_tablet=="Samsung Galaxy Tab A9+")? SamsungGalaxyTabA9Plus_data
  : (type_of_tablet=="Samsung Galaxy Tab Active 5")? SamsungGalaxyTabActive5_data
  : (type_of_tablet=="Samsung Galaxy Tab Active 3")? SamsungGalaxyTabActive3_data
  : (type_of_tablet=="Samsung Galaxy Tab Active 2")? SamsungGalaxyTabActive2_data
  : (type_of_tablet=="Samsung Galaxy Tab Active 4 Pro")? SamsungGalaxyTabActive4Pro_data
  : (type_of_tablet=="Samsung Galaxy Tab S3")? SamsungGalaxyTabS3_data
  : (type_of_tablet=="Samsung Galaxy Tab S6")? SamsungGalaxyTabS6_data
  : (type_of_tablet=="Samsung Galaxy Tab S6 Lite")? SamsungGalaxyTabS6Lite_data
  : (type_of_tablet=="Samsung Galaxy Tab S7")? SamsungGalaxyTabS7_data
  : (type_of_tablet=="Samsung Galaxy Tab S7 FE")? SamsungGalaxyTabS7FE_data
  : (type_of_tablet=="Samsung Galaxy Tab S7+")? SamsungGalaxyTabS7Plus_data
  : (type_of_tablet=="Samsung Galaxy Tab S8")? SamsungGalaxyTabS8_data
  : (type_of_tablet=="Samsung Galaxy Tab S8 Ultra")? SamsungGalaxyTabS8Ultra_data
  : (type_of_tablet=="Samsung Galaxy Tab S8+")? SamsungGalaxyTabS8Plus_data
  : (type_of_tablet=="Samsung Galaxy Tab S9")? SamsungGalaxyTabS9_data
  : (type_of_tablet=="Samsung Galaxy Tab S9 FE")? SamsungGalaxyTabS9FE_data
  : (type_of_tablet=="Samsung Galaxy Tab S9 FE+")? SamsungGalaxyTabS9FEPlus_data
  : (type_of_tablet=="Samsung Galaxy Tab S9 Ultra")? SamsungGalaxyTabS9Ultra_data
  : (type_of_tablet=="Samsung Galaxy Tab S9+")? SamsungGalaxyTabS9Plus_data  
  : (type_of_tablet=="Samsung Galaxy Tab Pro 12.2")? SamsungGalaxyTabPro12_2_data  
  : (type_of_tablet=="blank") ? blank_data
  : catch_all_data;

if (tablet_params == catch_all_data && type_of_tablet != "blank" && type_of_tablet != "other tablet") {
    echo(str("WARNING: '", type_of_tablet, "' is not a recognised tablet name. ",
             "Check the spelling or select 'other tablet' to enter custom dimensions. ",
             "Using catch-all defaults."));
}


//logic to handle strings/vectors as input - primarily for use on Maker World
c_t_c = parse_csv_mixed_top(cover_these_cells); // same call handles plain CSV
m_cell_h = parse_csv_mixed_top(merge_cells_horizontally_starting_at); // same call handles plain CSV
m_c_v = parse_csv_mixed_top(merge_cells_vertically_starting_at); // same call handles plain CSV
a_r_a = parse_csv_mixed_top(add_a_ridge_around_these_cells); // same call handles plain CSV

t_t_r_ll = parse_csv_mixed_top(trim_to_rectangle_lower_left); // same call handles plain CSV
t_t_r_ur = parse_csv_mixed_top(trim_to_rectangle_upper_right); // same call handles plain CSV
o_t_g_s = parse_csv_mixed_top(other_tablet_general_sizes); // same call handles plain CSV
o_t_p_s = parse_csv_mixed_top(other_tablet_pixel_sizes); // same call handles plain CSV
	
	
// Tablet variables
ot_test = (type_of_tablet=="other tablet" && len(o_t_g_s)==21) && (len(o_t_p_s)==3);

st_tablet_width = (is_landscape) ? tablet_params[0] : tablet_params[1];
ot_tablet_width = (is_landscape) ? o_t_g_s[0] : o_t_g_s[1];
tablet_width = (ot_test) ? ot_tablet_width : st_tablet_width;
tablet_width_l = (ot_test) ? o_t_g_s[0] : tablet_params[0]; //in landscape mode

st_tablet_height = (is_landscape) ? tablet_params[1] : tablet_params[0];
ot_tablet_height = (is_landscape) ? o_t_g_s[1] : o_t_g_s[0];
tablet_height = (ot_test) ? ot_tablet_height : st_tablet_height;
tablet_height_l = (ot_test) ? o_t_g_s[1] : tablet_params[1]; //in landscape mode

th = tablet_height;	// height of tablet in millimeters
tw = tablet_width;	// width of tablet in millimeters

st_tablet_tl_corner_radius = tablet_params[18];
ot_tablet_tl_corner_radius = o_t_g_s[17]; //this vector is one value shorter than the standard tablet data vector
tablet_tl_corner_radius = (ot_test) ? ot_tablet_tl_corner_radius : st_tablet_tl_corner_radius;

st_tablet_tr_corner_radius = tablet_params[19];
ot_tablet_tr_corner_radius = o_t_g_s[18]; //this vector is one value shorter than the standard tablet data vector
tablet_tr_corner_radius = (ot_test) ? ot_tablet_tr_corner_radius : st_tablet_tr_corner_radius;

st_tablet_bl_corner_radius = tablet_params[20];
ot_tablet_bl_corner_radius = o_t_g_s[19]; //this vector is one value shorter than the standard tablet data vector
tablet_bl_corner_radius = (ot_test) ? ot_tablet_bl_corner_radius : st_tablet_bl_corner_radius;

st_tablet_br_corner_radius = tablet_params[21];
ot_tablet_br_corner_radius = o_t_g_s[20]; //this vector is one value shorter than the standard tablet data vector
tablet_br_corner_radius = (ot_test) ? ot_tablet_br_corner_radius : st_tablet_br_corner_radius;

st_tablet_thickness = tablet_params[2];
ot_tablet_thickness = o_t_g_s[2];
tablet_thickness = (ot_test) ? ot_tablet_thickness : st_tablet_thickness;

st_right_border_width = (is_landscape) ? tablet_params[5] : tablet_params[8];
ot_right_border_width = (is_landscape) ? o_t_g_s[5] : o_t_g_s[8];
pre_right_border_width = (ot_test) ? ot_right_border_width : st_right_border_width;

st_left_border_width = (is_landscape) ? tablet_params[6] : tablet_params[7];
ot_left_border_width = (is_landscape) ? o_t_g_s[6] : o_t_g_s[7];
pre_left_border_width = (ot_test) ? ot_left_border_width : st_left_border_width;

st_top_border_height = (is_landscape) ? tablet_params[8] : tablet_params[6];
ot_top_border_height = (is_landscape) ? o_t_g_s[8] : o_t_g_s[6];
pre_top_border_height = (ot_test) ? ot_top_border_height : st_top_border_height;

st_bottom_border_height = (is_landscape) ? tablet_params[7] : tablet_params[5];
ot_bottom_border_height = (is_landscape) ? o_t_g_s[7] : o_t_g_s[5];
pre_bottom_border_height = (ot_test) ? ot_bottom_border_height : st_bottom_border_height;

right_border_width = (rotate_tablet_180_degrees=="no") ? pre_right_border_width : pre_left_border_width;
left_border_width = (rotate_tablet_180_degrees=="no") ? pre_left_border_width : pre_right_border_width;
top_border_height = (rotate_tablet_180_degrees=="no") ? pre_top_border_height : pre_bottom_border_height;
bottom_border_height = (rotate_tablet_180_degrees=="no") ? pre_bottom_border_height : pre_top_border_height;

st_distance_from_screen_to_home_button = tablet_params[9];
ot_distance_from_screen_to_home_button = o_t_g_s[9];
distance_from_screen_to_home_button = (ot_test) ? ot_distance_from_screen_to_home_button : st_distance_from_screen_to_home_button;

st_home_button_height = (is_landscape) ? tablet_params[10] : tablet_params[11];
ot_home_button_height = (is_landscape) ? o_t_g_s[10] : o_t_g_s[11];
home_button_height = (ot_test) ? ot_home_button_height : st_home_button_height;

st_home_button_width = (is_landscape) ? tablet_params[11] : tablet_params[10];
ot_home_button_width = (is_landscape) ? o_t_g_s[11] : o_t_g_s[10];
home_button_width = (ot_test) ? ot_home_button_width : st_home_button_width;

st_hb_loc = tablet_params[12];
ot_hb_loc = o_t_g_s[12];
st_home_loc = (is_landscape) ? st_hb_loc : search(st_hb_loc,[0,4,1,2,3])[0];
ot_home_loc = (is_landscape) ? ot_hb_loc : search(ot_hb_loc,[0,4,1,2,3])[0];
home_loc = (ot_test) ? ot_home_loc : st_home_loc;

st_distance_from_screen_to_camera = tablet_params[13];
ot_distance_from_screen_to_camera = o_t_g_s[13];
distance_from_screen_to_camera = (ot_test) ? ot_distance_from_screen_to_camera : st_distance_from_screen_to_camera;

st_camera_height = (is_landscape) ? tablet_params[14] : tablet_params[15];
ot_camera_height = (is_landscape) ? o_t_g_s[14] : o_t_g_s[15];
camera_height = (ot_test) ? ot_camera_height : st_camera_height;

st_camera_width = (is_landscape) ? tablet_params[15] : tablet_params[14];
ot_camera_width = (is_landscape) ? o_t_g_s[15] : o_t_g_s[14];
camera_width = (ot_test) ? ot_camera_width : st_camera_width;

st_c_loc = tablet_params[16];
ot_c_loc = o_t_g_s[16];
st_cam_loc = (is_landscape) ? st_c_loc : search(st_c_loc,[0,4,1,2,3])[0];
ot_cam_loc = (is_landscape) ? ot_c_loc : search(ot_c_loc,[0,4,1,2,3])[0];
cam_loc = (ot_test) ? ot_cam_loc : st_cam_loc;

swap=[0,3,4,1,2];
home_button_location = (rotate_tablet_180_degrees=="no") ? home_loc : swap[home_loc];
camera_location = (rotate_tablet_180_degrees=="no") ? cam_loc : swap[cam_loc];

case_opening_corner_radius_incl_acrylic = (is_3d_printed) ? case_opening_corner_radius : max(case_opening_corner_radius,acrylic_case_corner_radius);


// Case and Screen variables
coh = (has_case) ? height_of_opening_in_case : 0;
cow = (has_case) ? width_of_opening_in_case : 0;
cocr = case_opening_corner_radius_incl_acrylic;

c_h = case_height;
c_w = case_width;
c_cr = case_corner_radius;
ctsd = case_to_screen_depth;

vtf = keyguard_vertical_tightness_of_fit;
htf = keyguard_horizontal_tightness_of_fit;

//overall keyguard measurements - not, necessarily, the size of the keyguard opening in a keyguard frame
kw = (!has_case && !has_frame) ? tablet_width : 
	 (has_case && !has_frame) ? cow :
															 keyguard_width+htf;
kh = (!has_case && !has_frame) ? tablet_height : 
	 (has_case && !has_frame) ? coh :
															 keyguard_height+vtf;
tt1cr = tablet_tl_corner_radius;
ttrcr = tablet_tr_corner_radius;
tb1cr = tablet_bl_corner_radius;
tbrcr = tablet_br_corner_radius;

r180 = rotate_tablet_180_degrees; // boolean, is camera on right and home button on left
tcr	= (r180=="no") ? [tt1cr,ttrcr,tb1cr,tbrcr] : [tbrcr,tb1cr,ttrcr,tt1cr];

cocria = case_opening_corner_radius_incl_acrylic;

kcrf = keyguard_corner_radius;  // the keyguard corner radius when in a frame 

kcr = (!has_case && !has_frame) ? tcr : 
	 (has_case && !has_frame) ? [cocria,cocria,cocria,cocria] :
															 [kcrf,kcrf,kcrf,kcrf];

fw = (has_case && has_frame) ? cow : 
      (!has_case && has_frame) ? tw :
	  0;
fh = (has_case && has_frame) ? coh : 
      (!has_case && has_frame) ? th :
	  0;
fcr = (has_case && has_frame) ? [cocria,cocria,cocria,cocria] : 
      (!has_case && has_frame) ? tcr :
	  [0,0,0,0];

st_screen_width = (is_landscape) ? tablet_params[3] : tablet_params[4];
ot_screen_width = (is_landscape) ? o_t_g_s[3] : o_t_g_s[4];
screen_width = (ot_test) ? ot_screen_width : st_screen_width;
swm = screen_width;

st_screen_height = (is_landscape) ? tablet_params[4] : tablet_params[3];
ot_screen_height = (is_landscape) ? o_t_g_s[4] : o_t_g_s[3];
screen_height = (ot_test) ? ot_screen_height : st_screen_height;
shm = screen_height;

st_ps = tablet_params[17]; //pixel settings
ot_ps = (ot_test) ? o_t_p_s : [0,0,0]; //pixel settings

ps = (type_of_tablet=="other tablet") ? ot_ps : st_ps; //pixel settings
shp = (is_landscape) ? ps[0] : ps[1]; // screen height in pixels
swp = (is_landscape) ? ps[1] : ps[0]; // screen width in pixels
mpp =  ps[2]; // millimeters per pixel
ppm = 1/mpp; // pixels per millimeter

lec = (!has_frame) ? left_edge_compensation_for_tight_cases : 0;  // you won't use a frame if the case opening is tight to the screen
rec = (!has_frame) ? right_edge_compensation_for_tight_cases : 0;
bec = (!has_frame) ? bottom_edge_compensation_for_tight_cases : 0;
tec = (!has_frame) ? top_edge_compensation_for_tight_cases : 0;

equal_tablet_border_left = (tablet_width-swm)/2;
equal_tablet_border_bottom = (tablet_height-shm)/2;
equal_co_border_left = (cow-swm)/2;
equal_co_border_bottom = (coh-shm)/2;

unequal_tablet_left_side_offset = left_border_width-equal_tablet_border_left;
unequal_tablet_bottom_side_offset = bottom_border_height-equal_tablet_border_bottom;

unequal_co_left_side_offset = (unequal_left_side_of_case_opening>0) ? unequal_left_side_of_case_opening-equal_co_border_left : 0;
unequal_co_bottom_side_offset = (unequal_bottom_side_of_case_opening>0) ? unequal_bottom_side_of_case_opening-equal_co_border_bottom : 0;
						
unequal_left_side_offset = (!has_case) ? unequal_tablet_left_side_offset : unequal_co_left_side_offset;
unequal_bottom_side_offset = (!has_case) ? unequal_tablet_bottom_side_offset : unequal_co_bottom_side_offset;
							
// the size of the case borders accounting for edge compensation							
adj_case_border_left = (unequal_left_side_of_case_opening>0) ? unequal_left_side_of_case_opening : equal_co_border_left;
adj_case_border_right = cow-swm-adj_case_border_left;	

adj_case_border_bottom = (unequal_bottom_side_of_case_opening>0) ? unequal_bottom_side_of_case_opening : equal_co_border_bottom;
adj_case_border_top = coh-shm-adj_case_border_bottom;	
		
msh = move_screenshot_horizontally/10;
if (msh != 0){
	slide_h = round(equal_co_border_left + msh);
	echo();
	echo(str("Set 'unequal left side of case opening' to ", slide_h, " then set 'move screen horizontally' to 0"));
	echo();
}
msv = move_screenshot_vertically/10;
if (msv != 0){
	slide_v = round(equal_co_border_bottom + msv);
	echo();
	echo(str("Set 'unequal bottom side of case opening' to ", slide_v, " then set 'move screen vertically' to 0"));
	echo();
}

//for calculating split line location from edge of keygaurd with mounting options
horiz_sit = (slide_in_tab_locations=="horizontal only" ||  slide_in_tab_locations=="horizontal and vertical");
vert_sit = (slide_in_tab_locations=="vertical only" ||  slide_in_tab_locations=="horizontal and vertical");
horiz_rt = (raised_tab_locations=="horizontal only" || raised_tab_locations=="horizontal and vertical");
vert_rt  = (raised_tab_locations=="vertical only"   || raised_tab_locations=="horizontal and vertical");

split_add = (mounting_method=="Slide-in Tabs" && horiz_sit && is_landscape)  ? horizontal_slide_in_tab_length :
            (mounting_method=="Slide-in Tabs" && vert_sit  && !is_landscape) ? vertical_slide_in_tab_length :
            (mounting_method=="Raised Tabs"   && horiz_rt  && is_landscape)  ? horizontal_raised_tab_length :
            (mounting_method=="Raised Tabs"   && vert_rt   && !is_landscape) ? vertical_raised_tab_length :
            (mounting_method=="Shelf")   ? shelf_depth :
            (mounting_method=="Posts")   ? post_length :
            0;
				
							
// origin location variables
tablet_x0 = -tablet_width/2;
tablet_y0 = -tablet_height/2;

case_x0 = -cow/2;
case_y0 = -coh/2;

screen_x0 = -swm/2;
screen_y0 = -shm/2;

keyguard_x0 = (!has_case) ? tablet_x0 : -kw/2;
keyguard_y0 = (!has_case) ? tablet_y0 : -kh/2;

generate_keyguard = generate=="keyguard" || generate=="first half of keyguard" || generate=="second half of keyguard" || generate=="first layer for SVG/DXF file";


// origin location abbreviations
tx0 = tablet_x0-unequal_tablet_left_side_offset;
ty0 = tablet_y0-unequal_tablet_bottom_side_offset;

cox0 = case_x0;
coy0 = case_y0;

kx0 = keyguard_x0;
ky0 = keyguard_y0;

// kfx0 = keyguard_frame_x0;
// kfy0 = keyguard_frame_y0;

sx0 = screen_x0;
sy0 = screen_y0;


//** Variables for use in txt files and here
//tablet and case variables
	sxo = (r180=="no") ? 1 : -1; // sign of x offset
	syo = (r180=="no") ? 1 : -1; // sign of y offset
	
	xtls = (r180=="no") ? 0: tablet_width_l; // x location of the left side of the tablet adjusted for swapping camera and home button
	xtrs = (r180=="no") ? tablet_width_l: 0; // x location of the right side of the tablet adjusted for swapping camera and home button
	ytbs = (r180=="no") ? 0: tablet_height_l; // y location of the bottom side of the tablet adjusted for swapping the camera and home button
	ytts = (r180=="no") ? tablet_height_l: 0; // y location of the top side of the tablet adjusted for swapping the camera and home button
	
	xols = (r180=="no") ? 0 : cow+keyguard_horizontal_tightness_of_fit/10-ff; // x location of the left side of the case opening adjusted for swapping camera and home button
	xors = (r180=="no") ? cow+keyguard_horizontal_tightness_of_fit/10-ff : 0; // x location of the right side of the case opening adjusted for swapping camera and home button
	yobs = (r180=="no") ? 0 : coh+keyguard_vertical_tightness_of_fit/10-ff; // y location of the bottom side of the case opening adjusted for swapping the camera and home button
	yots = (r180=="no") ? coh+keyguard_vertical_tightness_of_fit/10-ff : 0; // y location of the top side of the case opening adjusted for swapping the camera and home button
	
	lcow = (cow-swm)/2; // the default width of the left side of case opening when in landscape mode
	bcoh = (coh-shm)/2; // the default height of the bottom side of case opening when in landscape mode

//screen variables
	//test whether the app measurements have been provided in pixels based on a screenshot
	// px_measurements = ((bottom_of_status_bar>0 || bottom_of_upper_message_bar>0 || bottom_of_upper_command_bar>0 || top_of_lower_message_bar>0 ||
		// top_of_lower_command_bar>0) && ((bottom_of_status_bar>=bottom_of_upper_message_bar && bottom_of_upper_message_bar>=bottom_of_upper_command_bar && bottom_of_upper_command_bar>=top_of_lower_message_bar && top_of_lower_message_bar>=top_of_lower_command_bar) || (bottom_of_status_bar<=bottom_of_upper_message_bar && bottom_of_upper_message_bar<=bottom_of_upper_command_bar && bottom_of_upper_command_bar<=top_of_lower_message_bar && top_of_lower_message_bar<=top_of_lower_command_bar))); 
	px_measurements = ((bottom_of_status_bar>0 || bottom_of_upper_message_bar>0 || bottom_of_upper_command_bar>0 || top_of_lower_message_bar>0 || top_of_lower_command_bar>0)); 
	
	//if app measurements been provided in pixels have they been taken from the top or bottom of the screenshot?
	px_measurements_start = (bottom_of_status_bar < top_of_lower_command_bar) ? "top" : "bottom";
	
	nc = number_of_columns;
	nr = number_of_rows;
	
	//the following values depend on the setting in the Freeform and hybrid Openings section
	sh = (using_px) ? shp : shm;
	sw = (using_px) ? swp : swm;
	
// app variables - used in opentings_and_additions.txt file

	sbbp = bottom_of_status_bar; //status bar bottom in pixels
	umbbp = bottom_of_upper_message_bar; //upper message bar bottom in pixels
	ucbbp = bottom_of_upper_command_bar; //upper command bar bottom in pixels
	lmbtp = top_of_lower_message_bar; //top of lower message bar in pixels
	lcbtp = top_of_lower_command_bar; //top of lower command bar in pixels
	// lmbbp = top_of_lower_command_bar; //lower message bar bottom in pixels
	// lcbbp = (px_measurements_start=="top") ?  shp : 0; //lower command bar bottom in pixels
	

	sbhp = (px_measurements_start=="top") ? sbbp : shp - sbbp; // height of status bar in pixels
	umbhp = (px_measurements_start=="top") ? umbbp - sbbp : sbbp - umbbp; // height of upper message bar in pixels
	ucbhp = (px_measurements_start=="top") ? ucbbp - umbbp : umbbp - ucbbp; // height of upper command bar in pixels
	lmbhp = (px_measurements_start=="top") ? lcbtp - lmbtp : lmbtp - lcbtp; // height of lower message bar in pixels
	lcbhp = (px_measurements_start=="top") ? shp - lcbtp : lcbtp; // height of lower command bar in pixelscel
	
// Convert a bar measurement to the working unit (mm or px depending on using_px).
// px_val: the bar height derived from pixel input; mm_val: the bar height parameter in mm.
function bar_height(px_val, mm_val) =
	(px_measurements && using_px)   ? px_val :
	(px_measurements && !using_px)  ? px_val * mpp :
	(!px_measurements && !using_px) ? mm_val :
	mm_val * ppm;

	sbh  = bar_height(sbhp,  status_bar_height);        // status bar height
	umbh = bar_height(umbhp, upper_message_bar_height); // upper message bar height
	ucbh = bar_height(ucbhp, upper_command_bar_height); // upper command bar height
	lmbh = bar_height(lmbhp, lower_message_bar_height); // lower message bar height
	lcbh = bar_height(lcbhp, lower_command_bar_height); // lower command bar height


	sbb = (starting_corner_for_screen_measurements=="upper-left") ? sbh : sh - (sbh); //status bar bottom
	umbb = (starting_corner_for_screen_measurements=="upper-left") ?  sbh + umbh : sh - (sbh + umbh); // upper message bar bottom
	ucbb = (starting_corner_for_screen_measurements=="upper-left") ? sbh + umbh + ucbh : sh - (sbh + umbh + ucbh); // upper command bar bottom
	lmbt = (starting_corner_for_screen_measurements=="upper-left") ? sh - lcbh - lmbh : lcbh + lmbh; // lower message bar top
	lmbb = (starting_corner_for_screen_measurements=="upper-left") ? sh - lcbh : lcbh; // lower message bar bottom
	lcbb = (starting_corner_for_screen_measurements=="upper-left") ? sh : 0; // lower command bar bottom

	hloc = home_loc;  // home button location: 1,2,3,4 (adjusted for orientation)
	hbd = distance_from_screen_to_home_button;
	hbh = home_button_height;
	hbw = home_button_width;
	cloc = cam_loc;  // camera location: 1,2,3,4 (adjusted for orientation)
	cmd = distance_from_screen_to_camera;
	cmh = camera_height;
	cmw = camera_width;
	
// variables for laying out the bars and the grid - all in millimeters
sbhm = (px_measurements) ? sbhp * mpp : status_bar_height; // status bar height
umbhm = (px_measurements) ? umbhp * mpp : upper_message_bar_height; // upper message bar height
ucbhm = (px_measurements) ? ucbhp * mpp : upper_command_bar_height; // upper command bar height
lmbhm = (px_measurements) ? lmbhp * mpp : lower_message_bar_height; /// lower message bar height
lcbhm = (px_measurements) ? lcbhp * mpp : lower_command_bar_height; /// lower command bar height

// if keyguard will go in a case, determine if edge compensation will affect bar width and by how much
adj_lec = (has_case) ? max(lec-adj_case_border_left,0) : 0;  // positive if lec is larger than the left border
adj_rec = (has_case) ? max(rec-adj_case_border_right,0) : 0;  // positive if rec is larger than the right border

bar_width = swm - adj_lec - adj_rec;

// if keyguard will go in a case, determine if edge compensation will affect bar height and by how much
adj_tec =(has_case) ?  max(tec-adj_case_border_top,0) : 0;  // positive if tec is larger than the top border
adj_bec = (has_case) ? max(bec-adj_case_border_bottom,0) : 0;  // positive if tec is larger than the bottom border

sbh_adjust = (adj_tec>0) ? sbhm - adj_tec : sbhm;
umbh_adjust = (adj_tec>sbhm) ? umbhm-(adj_tec-sbhm)  : umbhm;
ucbh_adjust = (adj_tec>sbhm+umbhm) ? ucbhm - (adj_tec - sbhm - umbhm) : ucbhm;
lmbh_adjust = (adj_bec>lcbhm) ? lmbhm - (adj_bec - lcbhm) : lmbhm;
lcbh_adjust = (adj_bec>0) ? lcbhm - adj_bec : lcbhm;

bcr = bar_corner_radius;

//Grid variables in millimeters
grid_width = swm - left_padding - right_padding;
grid_height = shm - sbhm - umbhm - ucbhm - top_padding - bottom_padding - lmbhm - lcbhm;

grid_x0 = screen_x0 + left_padding;
grid_y0 = screen_y0 + bottom_padding + lmbhm + lcbhm;

	gw = (!using_px) ? grid_width : grid_width * ppm;
	gh = (!using_px) ? grid_height : grid_height * ppm;
	gt = ucbb;  // grid top
	gb = lmbt;  // grid bottom
	
	gwm = grid_width;  // grid width in millimeters
	ghm = grid_height;  // grid height in millimeters
	
	tp = (px_measurements) ? top_padding * ppm : top_padding; // top padding for txt files
	bp = (px_measurements) ? bottom_padding * ppm : bottom_padding; // bottom padding for txt files
	lp = (px_measurements) ? left_padding * ppm : left_padding; // left padding for txt files
	rp = (px_measurements) ? right_padding * ppm : right_padding; // right padding for txt files
		
chamfer_angle_stop = 45;

//next instruction doesn't allow for acrylic sheets that are other than 3.15 mm thick - but only impacts display of keyguard since laser cutting uses
//   only the first layer for SVG/DXF file export
kt = (is_laser_cut) ? 3.175: 
     (has_frame && keyguard_thickness > keyguard_frame_thickness) ? keyguard_frame_thickness :
	 keyguard_thickness;
	 
//misc variables
kec = (keyguard_thickness > keyguard_edge_chamfer) ? keyguard_edge_chamfer : keyguard_thickness -.1;
chamfer_slices = keyguard_edge_chamfer/.2;
chamfer_slice_size = .2;

$fn=64;


//handle the instance where a system like an Accent
system_with_no_case = ((tablet_width==0) || (tablet_height == 0)) && (!has_case);

//cell variables
column_count = (system_with_no_case || hide_screen_region == "yes") ? 0 : number_of_columns;
row_count = (system_with_no_case || hide_screen_region == "yes") ? 0 : number_of_rows;

max_cell_width = grid_width/column_count;
max_cell_height = grid_height/row_count;
minimum__acrylic_rail_width = (!lc_best_practices) ?  1 : 2;

cell_w = (cell_width_in_mm==0) ? cell_width_in_px*mpp : cell_width_in_mm;
cell_h = (cell_height_in_mm==0) ? cell_height_in_px*mpp : cell_height_in_mm;
cw = (cell_w*number_of_columns>gwm) ? floor(gwm/number_of_columns)-1 : cell_w;
ch = (cell_h*number_of_rows>ghm) ? floor(ghm/number_of_rows)-1 : cell_h;

if(((cw!=cell_w) || (ch!=cell_h)) && (column_count!=0 && row_count!=0 && cell_shape!="circular")){
	echo();
	if(ch!=cell_h) echo(str("The cell height has been adjusted to ", ch, " mm (or ", round(ch*ppm), " px) in order to fit properly."));
	if(cw!=cell_w) echo(str("The cell width has been adjusted to ", cw, " mm (or ", round(cw*ppm), " px) in order to fit properly."));
	echo();
}

vrw = grid_width/number_of_columns - cw;
hrw = grid_height/number_of_rows - ch;

// // this module should go away after "n" releases or "m" months when people have had a chance to move beyond 66- versions
// echo_upgrade_recommendations(cw,ch,cell_edge_slope,screen_area_thickness);

	ccr = cell_corner_radius;
	
	hor = (using_px) ? height_of_ridge * ppm : height_of_ridge;
	tor = (using_px) ? thickness_of_ridge * ppm : thickness_of_ridge;

min_actual_cell_dim = min(cw,ch);
acrylic_cell_corner_radius = max(min_actual_cell_dim/10,cell_corner_radius);
first_ocr = (is_laser_cut && lc_best_practices) ? acrylic_cell_corner_radius : cell_corner_radius;
ocr = min(first_ocr, min_actual_cell_dim/2);

sata = sat_incl_acrylic;
sat = min(kt,sata); // thiness of the grid and bar region of the keyguard which can't exceed the overall keyguard Thickness

horizontal_slide_in_tab_length_incl_acrylic = (is_3d_printed) ? horizontal_slide_in_tab_length : horizontal_acrylic_slide_in_tab_length;
vertical_slide_in_tab_length_incl_acrylic = (is_3d_printed) ? vertical_slide_in_tab_length : vertical_acrylic_slide_in_tab_length;
slide_in_tab_thickness = (is_3d_printed) ? min(kt-0.65, preferred_slide_in_tab_thickness) : acrylic_slide_in_tab_thickness;

col_first_trim = (lec>left_padding+vrw/2+adj_case_border_left && has_case) ? lec-left_padding-vrw/2-adj_case_border_left : 0;
col_last_trim = (rec>right_padding+vrw/2+adj_case_border_right && has_case) ? rec-right_padding-vrw/2-adj_case_border_right: 0;
row_first_trim = (bec>bottom_padding+lmbhm+lcbhm+hrw/2+adj_case_border_bottom && has_case) ? bec - bottom_padding - lmbhm - lcbhm - hrw/2 -adj_case_border_bottom: 0;
row_last_trim = (tec>top_padding+sbhm+umbhm+ucbhm+hrw/2+adj_case_border_top && has_case) ? tec-top_padding-sbhm-umbhm-ucbhm-hrw/2-adj_case_border_top : 0;


cts = (is_laser_cut) ? 90 :
		(is_3d_printed && cell_top_edge_slope == 90) ? cell_edge_slope : cell_top_edge_slope;  
cbs = (is_laser_cut) ? 90 :
		(is_3d_printed && cell_bottom_edge_slope == 90) ? cell_edge_slope : cell_bottom_edge_slope;  
		
cell_top_offset = screen_area_thickness*cos(cell_edge_slope); //this is actually the maximum value since edge compensation can override
		
cec = cell_edge_chamfer;


//home button and camera location variables
home_x_loc = (home_button_location==1) ? screen_x0+swm/2 
	: (home_button_location==2) ? screen_x0+swm+distance_from_screen_to_home_button 
	: (home_button_location==3) ? screen_x0+swm/2 
	: screen_x0-distance_from_screen_to_home_button;

home_y_loc = (home_button_location==1) ? screen_y0+shm+distance_from_screen_to_home_button 
	: (home_button_location==2) ? screen_y0+shm/2
	: (home_button_location==3) ? screen_y0-distance_from_screen_to_home_button 
	: screen_y0+shm/2 ;
	
cam_x_loc = (camera_location==1) ? screen_x0+swm/2 
	: (camera_location==2) ? screen_x0+swm+distance_from_screen_to_camera 
	: (camera_location==3) ? screen_x0+swm/2 
	: screen_x0-distance_from_screen_to_camera ;
	
cam_y_loc = (camera_location==1) ? screen_y0+shm+distance_from_screen_to_camera 
	: (camera_location==2) ? screen_y0+shm/2 
	: (camera_location==3) ? screen_y0-distance_from_screen_to_camera 
	: screen_y0+shm/2;

//velcro variables
velcro_diameter = 
    (velcro_size==1)? 10
  : (velcro_size==2)? 16
  : (velcro_size==3)? 20
  : (velcro_size==4)? 10
  : (velcro_size==5)? 16
  : 20;
  
strap_cut_to_depth = 9.25 - 3.1 - 3.5; // length of bolt - thickness of acrylic mount - height of nut

//sloped keyguard edge variables
hsew = horizontal_sloped_edge_width;
vsew = vertical_sloped_edge_width;
sew = min(hsew, vsew); // backward-compatible alias used in openings_and_additions.txt


// general case mount veriables
ulos = unequal_left_side_offset;
ulbs = unequal_bottom_side_offset;


//clip-on strap variables
horizontal_pedestal_width = horizontal_clip_width + 10;
vertical_pedestal_width = vertical_clip_width + 10;

horizontal_slot_width = horizontal_clip_width+2;
vertical_slot_width = vertical_clip_width+2;

// Clip-on strap groove cross-section (wedge profile that clip hooks snap into)
groove_depth = 3;          // depth of each wedge groove in mm
groove_slot_width = 3;     // width of groove at base in mm
groove_slant = 1;          // horizontal lean of groove walls over groove_depth in mm
groove_setback = 2;        // distance from case edge to the start of the groove in mm

// Clip-on strap pedestal geometry
pedestal_base_size = 7;    // side length of the pedestal base square in mm
pedestal_taper = 0.8;      // linear_extrude scale: top face shrinks to this fraction of the base
pedestal_edge_inset = 4.3; // distance from case-opening edge to pedestal centre in mm
pedestal_corner_inset = 4; // inward offset from pedestal width boundary toward clip centre in mm

// Manually placed strap pedestal geometry (ped1–ped4 in case_additions)
manual_pedestal_edge_inset = 4.3;   // inset from keyguard-opening edge to pedestal centre in mm (matches pedestal_edge_inset so add_clip_on_strap_pedestals can share the ped1-4 V2 placer)
manual_pedestal_slot_inset = 1.25;  // offset from keyguard edge to groove-slot centre in mm

// Clip viewport layout (positions paired clips side-by-side when rendered individually)
clip_display_separation = 35; // x-offset to visually separate the two clips in mm
clip_display_gap = 10;        // extra y-clearance between paired clips beyond case_thickness/2 in mm

pedestal_height = (!has_case)? 0 :
				  (!has_frame) ? max(case_to_screen_depth - kt,0) :
				  max(case_to_screen_depth - keyguard_frame_thickness,0);
vertical_offset = (!has_frame) ? kt/2 + pedestal_height-groove_depth+ff : // bottom of cut for clip-on strap
												  keyguard_frame_thickness/2 + pedestal_height-groove_depth+ff;
h_clip_reach = (!has_case)? 6 :
			 (add_sloped_keyguard_edge=="no")? (case_width-kw)/2+5 :
			 (extend_lip_to_edge_of_case=="no")? (case_width-cow)/2-hsew+6 :
			 7;
v_clip_reach = (!has_case)? 6 :
			 (add_sloped_keyguard_edge=="no")? (case_height-kh)/2+5 :
			 (extend_lip_to_edge_of_case=="no")? (case_height-coh)/2-vsew+6 :
			 7;
no_clips = (add_sloped_keyguard_edge=="yes" && keyguard_thickness<case_to_screen_depth); //the keyguard has to reach to the top of the case edge if using sloped edges

// slide-in tab variables

// raised-tab variables

//shelf variables
shelf_t = (!has_frame) ? min(shelf_thickness,keyguard_thickness) : min(shelf_thickness,keyguard_frame_thickness);
scr = shelf_corner_radius;


// bar variables

// keyguard frame variables
groove_size = 1.2;
groove_width = 30;
snap_in_size = .8;
snap_in_width = 25;
post_len = post_extension_distance;

//Braille and cell insert variables
bsm = Braille_size_multiplier/10; //Braille size multiplier
braille_a = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
braille_d = [0,32,40,48,52,36,56,60,44,24,28,34,42,50,54,38,58,62,46,26,30,35,43,29,51,55,39,32,40,48,52,36,56,60,44,24,28,34,42,50,54,38,58,62,46,26,30,35,43,29,51,55,39];
insert_thickness = sat-insert_recess;
e_t = engraved_text;

// // // //Blissymbol parameter from customizer
// // // //concept must match STL filename (without the .stl)
// // // Bliss_concept = "";

// // // //Blissymbol variables
// // // apos2 = search("'", Bliss_concept)[0];
// // // bycw = apos2 == undef ? Bliss_concept :
	 // // // apos2 > 0 ?
		// // // strcat(concat(substr(Bliss_concept,0,apos2),substr(Bliss_concept,apos2 + 1))):
		// // // "";
// // // path = (Bliss_concept !="") ? "Bliss concepts/" : "";
// // // filename = (Bliss_concept !="") ? bycw : "";
// // // path_and_filename = (path != "" && filename != "") ? str(path,filename,".stl") : "";

///**** these next two lines should be derivable or replaced by values above
case_thick = (!has_case)? tablet_thickness+kt : case_thickness+max(kt-case_to_screen_depth,0);

//currently only openings for ambient light sensors - may need to become specific to ALS if other types of openings are added - especially if they don't map to tablet models in the same way that ALS openings do
// V2 format: [ID, shape, height, width, corner, x, y, cb, anchor, surface, length, thickness, [es], [sp]]
als_openings=[
	/* iPad 1st generation */
	[[ "1ALS1",         "c",   2.5,   0,   0,   xtls+sxo*10.4,            ytbs+syo*94.9,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad 2nd, 3rd, & 4th generation */
	[[ "23ALS1",        "c",   2.0,   0,   0,   xtls+sxo*6.7,             ytbs+syo*92.9,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad 5th & 6th generation */
	[[ "56ALS1",        "c",   3.5,   0,   0,   xtls+sxo*11.07,           ytbs+syo*80.34,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad 7th & 8th generation */
	[[ "78ALS1",        "c",   3.5,   0,   0,   xtls+sxo*11.03,           ytbs+syo*82.64,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad 9th generation */
	// the first entry copied for consistency with ready-made-designs
	[[ "78ALS1",        "c",   3.5,   0,   0,   xtls+sxo*11.03,           ytbs+syo*82.64,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "9ALS1",         "c",   3.5,   0,   0,   xtls+sxo*11.03,           ytbs+syo*21.83,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "9ALS2",         "c",   3.5,   0,   0,   xtls+sxo*11.03,           ytts-syo*21.53,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad 10th & 11th generation */
	[[ "10ALS1",        "c",   3.5,   0,   0,   xtls+sxo*35.02,           ytts-syo*4.53,    0,   "",   "",   0,   0,   [60],   [] ],
	[  "10ALS2",        "c",   3.5,   0,   0,   xtls+sxo*(tw-111.15),     ytts-syo*5.24,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 9.7-inch */
	[[ "9.7ALS1",       "c",   3.0,   0,   0,   xtls+sxo*13.55,           ytbs+syo*18.86,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "9.7ALS2",       "c",   3.0,   0,   0,   xtls+sxo*13.55,           ytts-syo*18.86,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 10.5-inch */
	[[ "10.5ALS1",      "c",   2.5,   0,   0,   xtls+sxo*9.62,            ytbs+syo*18.72,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "10.5ALS2",      "c",   2.5,   0,   0,   xtls+sxo*9.62,            ytts-syo*18.72,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 11, 1st & 2nd generation  & Via Pro*/
	[[ "11-12ALS1",     "c",   3.5,   0,   0,   xtls+sxo*4.37,            ytbs+syo*30.73,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "11-12ALS2",     "c",   3.5,   0,   0,   xtls+sxo*4.37,            ytts-syo*30.73,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 11, 3rd & 4th generation */
	[[ "11-34ALS1",     "c",   4.0,   0,   0,   xtls+sxo*3.60,            ytbs+syo*43.49,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "11-34ALS2",     "c",   4.0,   0,   0,   xtls+sxo*3.60,            ytts-syo*43.49,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 12.9, 1st generation */
	[[ "12.9-1ALS1",    "c",   2.5,   0,   0,   xtls+sxo*13.41,           ytbs+syo*18.48,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "12.9-1ALS2",    "c",   2.5,   0,   0,   xtls+sxo*13.41,           ytts-syo*18.48,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 12.9, 2nd generation */
	[[ "12.9-2ALS1",    "c",   2.5,   0,   0,   xtls+sxo*11.07,           ytbs+syo*22.38,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "12.9-2ALS2",    "c",   2.5,   0,   0,   xtls+sxo*11.07,           ytts-syo*22.38,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 12.9, 3rd generation */
	[[ "12.9-3ALS1",    "c",   3.8,   0,   0,   xtls+sxo*4.37,            ytbs+syo*30.73,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "12.9-3ALS2",    "c",   3.8,   0,   0,   xtls+sxo*4.37,            ytts-syo*30.73,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 12.9, 4th generation */
	[[ "12.9-4ALS1",    "c",   3.8,   0,   0,   xtls+sxo*3.5,             ytbs+syo*30.72,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "12.9-4ALS2",    "c",   3.8,   0,   0,   xtls+sxo*3.5,             ytts-syo*30.72,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 12.9, 5th & 6th generation */
	[[ "12.9-56ALS1",   "c",   3.8,   0,   0,   xtls+sxo*4.13,            ytbs+syo*43.49,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "12.9-56ALS2",   "c",   3.8,   0,   0,   xtls+sxo*4.13,            ytts-syo*43.49,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Mini */
	[[ "MiniALS1",      "c",   2.0,   0,   0,   xtls+sxo*10.7,            ytts-syo*71.8,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Mini, 2nd & 3rd generation */
	[[ "Mini-23ALS1",   "c",   2.0,   0,   0,   xtls+sxo*10.7,            ytts-syo*71.7,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Mini, 4th generation */
	[[ "Mini-4ALS1",    "c",   4.0,   0,   0,   xtls+sxo*5.14,            ytbs+syo*16.46,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Mini-4ALS2",    "c",   4.0,   0,   0,   xtls+sxo*5.14,            ytts-syo*16.46,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Mini, 5th generation */
	[[ "Mini-5ALS1",    "c",   4.0,   0,   0,   xtls+sxo*13.57,           ytbs+syo*18.60,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Mini-5ALS2",    "c",   4.0,   0,   0,   xtls+sxo*13.57,           ytts-syo*18.60,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Mini, 6th, 7th A17 generation & Via Mini*/
	[[ "Mini-67ALS1",   "c",   3.0,   0,   0,   xtls+sxo*4.38,            ytts-syo*23.99,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Mini-67ALS2",   "c",   3.0,   0,   0,   xtls+sxo*16.61,           ytts-syo*3.34,    0,   "",   "",   0,   0,   [60],   [] ],
	[  "Mini-67ALS3",   "c",   3.0,   0,   0,   xtrs-sxo*40.24,           ytts-syo*3.34,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Air */
	[[ "AirALS1",       "c",   2.0,   0,   0,   xtls+sxo*11.1,            ytts-syo*89.1,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Air, 2nd generation */
	[[ "Air-2ALS1",     "c",   2.5,   0,   0,   xtls+sxo*5.14,            ytbs+syo*16.44,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-2ALS2",     "c",   2.5,   0,   0,   xtls+sxo*5.14,            ytts-syo*16.44,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Air, 3rd generation */
	[[ "Air-3ALS1",     "c",   3.0,   0,   0,   xtls+sxo*9.62,            ytbs+syo*18.72,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-3ALS2",     "c",   3.0,   0,   0,   xtls+sxo*9.62,            ytts-syo*18.72,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Air, 4th & 5th generation */
	[[ "Air-45ALS1",    "c",   3.0,   0,   0,   xtls+sxo*4.62,            ytbs+syo*22.13,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-45ALS2",    "c",   3.0,   0,   0,   xtls+sxo*4.62,            ytbs+syo*51.40,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-45ALS3",    "c",   3.0,   0,   0,   xtls+sxo*4.62,            ytts-syo*26.47,   0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 11-inch M4 & M5*/
	[[ "Pro-11M4ALS1",  "c",   3.0,   0,   0,   xtls+sxo*4.71,            ytbs+syo*88.76,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Pro-11M4ALS2",  "c",   3.0,   0,   0,   xtls+sxo*124.85,          ytts-syo*4.71,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Pro 13-inch M4 *& M5/
	[[ "Pro-13M4ALS1",  "c",   3.0,   0,   0,   xtls+sxo*4.71,            ytbs+syo*107.76,  0,   "",   "",   0,   0,   [60],   [] ],
	[  "Pro-13M4ALS2",  "c",   3.0,   0,   0,   xtls+sxo*140.79,          ytts-syo*4.71,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Air 11-inch M2 & M3 & M4*/
	[[ "Air-11M23ALS1", "c",   3.0,   0,   0,   xtls+sxo*4.62,            ytbs+syo*22.13,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-11M23ALS2", "c",   3.0,   0,   0,   xtls+sxo*4.62,            ytbs+syo*51.40,   0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-11M23ALS3", "c",   3.7,   0,   0,   xtls+sxo*138.92,          ytts-syo*4.49,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* iPad Air 13-inch M2 & M3 & M4*/
	[[ "Air-13M23ALS1", "c",   3.0,   0,   0,   xtls+tw/2-sxo*94.66,      ytts-syo*4.22,    0,   "",   "",   0,   0,   [60],   [] ],
	[  "Air-13M23ALS2", "c",   3.0,   0,   0,   xtls+tw/2+sxo*15.56,      ytts-syo*4.22,    0,   "",   "",   0,   0,   [60],   [] ]],

	/* Tobii I-16 */
	[[ "Tobii-I16ALS1", "c",   5.0,   0,   0,   xtls+sxo*63,              ytts-syo*10.75,   0,   "",   "",   0,   0,   [50],   [] ],
	[  "Tobii-I16ALS2", "c",   3.0,   0,   0,   xtls+sxo*81,              ytts-syo*10.75,   0,   "",   "",   0,   0,   [50],   [] ],
	[  "Tobii-I16ALS3", "c",   3.0,   0,   0,   xtls+sxo*91,              ytts-syo*10.75,   0,   "",   "",   0,   0,   [50],   [] ]],
];

//this tablet's abient light sensor openings
ttao = 
    (type_of_tablet=="iPad")? als_openings[0]
  : (type_of_tablet=="iPad2")? als_openings[1]
  : (type_of_tablet=="iPad 3rd generation")? als_openings[1]
  : (type_of_tablet=="iPad 4th generation")? als_openings[1]
  : (type_of_tablet=="iPad 5th generation")? als_openings[2]  
  : (type_of_tablet=="iPad 6th generation")? als_openings[2]  
  : (type_of_tablet=="iPad 7th generation")? als_openings[3]
  : (type_of_tablet=="iPad 8th generation")? als_openings[3]
  : (type_of_tablet=="iPad 9th generation")? als_openings[4]
  : (type_of_tablet=="iPad 10th generation")? als_openings[5]
  : (type_of_tablet=="iPad 11th generation A16")? als_openings[5]
  : (type_of_tablet=="iPad Pro 9.7-inch")? als_openings[6]
  : (type_of_tablet=="iPad Pro 10.5-inch")? als_openings[7]
  : (type_of_tablet=="iPad Pro 11-inch 1st Generation")? als_openings[8]
  : (type_of_tablet=="iPad Pro 11-inch 2nd Generation")? als_openings[8]
  : (type_of_tablet=="iPad Pro 11-inch 3rd Generation")? als_openings[9]
  : (type_of_tablet=="iPad Pro 11-inch 4th Generation")? als_openings[9]
  : (type_of_tablet=="iPad Pro 12.9-inch 1st Generation")? als_openings[10]
  : (type_of_tablet=="iPad Pro 12.9-inch 2nd Generation")? als_openings[11]
  : (type_of_tablet=="iPad Pro 12.9-inch 3rd Generation")? als_openings[12]
  : (type_of_tablet=="iPad Pro 12.9-inch 4th Generation")? als_openings[13]
  : (type_of_tablet=="iPad Pro 12.9-inch 5th Generation")? als_openings[14]
  : (type_of_tablet=="iPad Pro 12.9-inch 6th Generation")? als_openings[14]
  : (type_of_tablet=="iPad mini")? als_openings[15]
  : (type_of_tablet=="iPad mini 2")? als_openings[16]
  : (type_of_tablet=="iPad mini 3")? als_openings[16]
  : (type_of_tablet=="iPad mini 4")? als_openings[17]
  : (type_of_tablet=="iPad mini 5")? als_openings[18]
  : (type_of_tablet=="iPad mini 6")? als_openings[19]  
  : (type_of_tablet=="iPad mini 7 A17 Pro")? als_openings[19] 
  : (type_of_tablet=="iPad Air")? als_openings[20]
  : (type_of_tablet=="iPad Air 2")? als_openings[21]
  : (type_of_tablet=="iPad Air 3")? als_openings[22]
  : (type_of_tablet=="iPad Air 4")? als_openings[23]
  : (type_of_tablet=="iPad Air 5")? als_openings[23] 
  : (type_of_tablet=="iPad Pro 11-inch M4")? als_openings[24] 
  : (type_of_tablet=="iPad Pro 11-inch M5")? als_openings[24] 
  : (type_of_tablet=="iPad Pro 13-inch M4")? als_openings[25] 
  : (type_of_tablet=="iPad Pro 13-inch M5")? als_openings[25] 
  : (type_of_tablet=="iPad Air 11-inch M2")? als_openings[26] 
  : (type_of_tablet=="iPad Air 11-inch M3")? als_openings[26] 
  : (type_of_tablet=="iPad Air 11-inch M4")? als_openings[26] 
  : (type_of_tablet=="iPad Air 13-inch M2")? als_openings[27] 
  : (type_of_tablet=="iPad Air 13-inch M3")? als_openings[27] 
  : (type_of_tablet=="iPad Air 13-inch M4")? als_openings[27] 
  : (type_of_tablet=="Via Mini")? als_openings[19]  
  : (type_of_tablet=="Via Pro")? als_openings[8]
  : (type_of_tablet=="TobiiDynavox I-16")? als_openings[28] 
  : []; // all other tablets
  
// All variables that can be used in the openings an additions file called out here for Maker World customizer
// Put this *above* where you parse user input.
// Add every variable name you want resolvable.
RESOLVE_NAMES  = ["bcoh","bp","ccr","ch","cloc","cmd","cmh","cmw","cocr","coh","cow","cw","gb","gh","gt","gw","hbd","hbh","hbw","hloc","hor","hrw","kcr","kh","kw","lcbb","lcbh","lcow","lmbb","lmbh","lmbt","lp","mpp","nc","nr","ppm","r180","rp","sbb","sbh","sh","shp","sw","swm","swp","sxo","syo","tcr","th","tor","tp","tw","ucbb","ucbh","umbb","umbh","vrw","xols","xors","yobs","yots"];
RESOLVE_VALUES = [bcoh,bp,ccr,ch,cloc,cmd,cmh,cmw,cocr,coh,cow,cw,gb,gh,gt,gw,hbd,hbh,hbw,hloc,hor,hrw,kcr,kh,kw,lcbb,lcbh,lcow,lmbb,lmbh,lmbt,lp,mpp,nc,nr,ppm,r180,rp,sbb,sbh,sh,shp,sw,swm,swp,sxo,syo,tcr,th,tor,tp,tw,ucbb,ucbh,umbb,umbh,vrw,xols,xors,yobs,yots]; 

m_s_o = parse_user_vector(my_screen_openings, /*strict=*/true);
m_c_o = parse_user_vector(my_case_openings, /*strict=*/true);
m_c_a = parse_user_vector(my_case_additions, /*strict=*/true);
m_t_o = parse_user_vector(my_tablet_openings, /*strict=*/true);


//**********************************************************************

	include <openings_and_additions.txt>

// Format is auto-detected per vector: V2 rows have a string at [1]; V1 rows have a number.
// The O&A and my_* vectors are processed independently — template placeholder rows
// (e.g. "r" with h=0 and w=0) are silently skipped by each shape's own validation code.
function is_v2(v) = len(v) > 0 && is_string(v[0][1]);

//**********************************************************************


// ----------------------Main-----------------------------
$vpd = (keyguard_display_angle>0 && is_landscape) ? 500 : 
	   (keyguard_display_angle>0 && !is_landscape) ? 620 :
	   $vpd;
$vpt = (keyguard_display_angle>0) ? [1,1,1] : 
	   $vpt;
$vpr = (show_back_of_keyguard=="no" && keyguard_display_angle > 0) ? [90-keyguard_display_angle,0,0] :
       (show_back_of_keyguard=="yes") ? [0,180,0] : 
	   $vpr;
	   
echo($vpt);
echo($vpr);
echo($vpd);
	   
	   
if (system_with_no_case){
	echo();
	echo();
	text_string1 = str("The ",type_of_tablet," system requires case-opening measurements.");
	text_string2 = "Set 'have a case' to 'yes' in the Tablet Case section,";
	text_string3 = "and provide measurements for the case-opening.";
	echo("**************************************************************************************************");
	echo(text_string1);
	echo(text_string2);
	echo(text_string3);
	echo("**************************************************************************************************");
	echo();
	echo();
}
else if (type_of_tablet=="other tablet" && (len(o_t_g_s)!=21 || len(o_t_p_s)!=3)){
	echo();
	echo();
	echo("**************************************************************************************************");
	echo("The 'other tablet' option requires:");
	if (len(o_t_g_s)!=21) echo("21 entries in the 'other tablet general sizes' input box");
	if (len(o_t_p_s)!=3) echo("3 entries in the 'other tablet pixel sizes' input box");
	echo("**************************************************************************************************");
	echo();
	echo();
}
else if (add_sloped_keyguard_edge=="yes" && is_laser_cut){
	echo();
	echo();
	echo("************ Laser-cut keyguards cannot have a sloped edge ************");
	echo();
	echo();
}
else if (is_3d_printed && (generate=="keyguard" || generate=="first half of keyguard" || generate=="second half of keyguard")){
	color("Turquoise")
	keyguard("no");
	
	if (include_screenshot=="yes"){
		if (MW_version){
			show_screenshotMW(kt);
		}
		else{
			show_screenshot(kt);
		}
	}
	
	if (show_split_line=="yes"){
		show_line_split_location();
	}
}
else if (is_laser_cut && generate=="keyguard" && !has_frame && (m_m=="No Mount" || m_m=="Slide-in Tabs")){
	color("Khaki")
	keyguard("no");
	issues();

	if (include_screenshot=="yes"){
		if (MW_version){
			show_screenshotMW(acrylic_thickness);
		}
		else{
			show_screenshot(acrylic_thickness);
		}
	}
}
else if (is_laser_cut && generate=="first layer for SVG/DXF file" && !has_frame && (mounting_method=="No Mount" || mounting_method=="Slide-in Tabs")){
	color("DarkSeaGreen")
	render()
	lc_keyguard();
	issues();
	key_settings();

	if (include_screenshot=="yes"){
		if (MW_version){
			show_screenshotMW(acrylic_thickness);
		}
		else{
			show_screenshot(acrylic_thickness);
		}
	}
}
else if (generate=="horizontal clip"){
	color("lime")
	if (unequal_left_side_of_case == 0){
		create_clip(h_clip_reach,horizontal_clip_width);
	}
	else{  //if unequal_left_side_of_case>0 then assume that there is a case
		clip_reach_left = unequal_left_side_of_case + 5;

		clip_reach_right = case_width-kw-unequal_left_side_of_case+5;

		//left side clip
		translate([-clip_display_separation,0,horizontal_clip_width])
		rotate([0,180,0])
		translate([0,case_thickness/2+clip_display_gap,0])
		create_clip(clip_reach_left,horizontal_clip_width);

		//right side clip
		translate([0,-case_thickness/2-clip_display_gap,0])
		create_clip(clip_reach_right,horizontal_clip_width);
	}
}
else if (generate=="vertical clip"){
	color("lime")
	if (unequal_bottom_side_of_case == 0){
		create_clip(v_clip_reach,vertical_clip_width);
	}
	else{  //if unequal_bottom_side_of_case>0 then assume that there is a case
		clip_reach_bottom = unequal_bottom_side_of_case + 5;

		clip_reach_top = case_height-kh-unequal_bottom_side_of_case+5;

		//top side clip
		translate([-clip_display_separation,0,vertical_clip_width])
		rotate([0,180,0])
		translate([0,case_thickness/2+clip_display_gap,0])
		create_clip(clip_reach_bottom,vertical_clip_width);

		//bottom side clip
		translate([0,-case_thickness/2-clip_display_gap,0])
		create_clip(clip_reach_top,vertical_clip_width);
	}
}
else if (generate=="horizontal mini clip"){
	color("lime")
	if (unequal_left_side_of_case == 0){
		create_mini_clip1(h_clip_reach,horizontal_clip_width);
	}
	else{  //if unequal_left_side_of_case>0 then assume that there is a case
		clip_reach_left = unequal_left_side_of_case + 5;

		clip_reach_right = case_width-kw-unequal_left_side_of_case+5;

		//left side clip
		translate([-clip_display_separation,0,horizontal_clip_width])
		rotate([0,180,0])
		translate([0,case_thickness/2+clip_display_gap,0])
		create_mini_clip1(clip_reach_left,horizontal_clip_width);

		//right side clip
		translate([0,-case_thickness/2-clip_display_gap,0])
		create_mini_clip1(clip_reach_right,horizontal_clip_width);
	}
}
else if (generate=="vertical mini clip"){
	color("lime")
	if (unequal_bottom_side_of_case == 0){
		create_mini_clip1(v_clip_reach,vertical_clip_width);
	}
	else{  //if unequal_bottom_side_of_case>0 then assume that there is a case
		clip_reach_bottom = unequal_bottom_side_of_case + 5;

		clip_reach_top = case_height-kh-unequal_bottom_side_of_case+5;

		//left side clip
		translate([-clip_display_separation,0,vertical_clip_width,vertical_clip_width])
		rotate([0,180,0])
		translate([0,case_thickness/2+clip_display_gap,0])
		create_mini_clip1(clip_reach_bottom,vertical_clip_width);

		//right side clip
		translate([0,-case_thickness/2-clip_display_gap,0])
		create_mini_clip1(clip_reach_top,vertical_clip_width);
	}
}
else if (generate=="horizontal micro clip"){
	color("lime")
	if (unequal_left_side_of_case == 0){
		create_mini_clip2(h_clip_reach,horizontal_clip_width);
	}
	else{  //if unequal_left_side_of_case>0 then assume that there is a case
		clip_reach_left = unequal_left_side_of_case + 5;

		clip_reach_right = case_width-kw-unequal_left_side_of_case+5;

		//left side clip
		translate([-clip_display_separation,0,horizontal_clip_width])
		rotate([0,180,0])
		translate([0,case_thickness/2+clip_display_gap,0])
		create_mini_clip2(clip_reach_left,horizontal_clip_width);

		//right side clip
		translate([0,-case_thickness/2-clip_display_gap,0])
		create_mini_clip2(clip_reach_right,horizontal_clip_width);
	}
}
else if (generate=="vertical micro clip"){
	color("lime")
	if (unequal_bottom_side_of_case == 0){
		create_mini_clip2(v_clip_reach,vertical_clip_width);
	}
	else{  //if unequal_bottom_side_of_case>0 then assume that there is a case
		clip_reach_bottom = unequal_bottom_side_of_case + 5;

		clip_reach_top = case_height-kh-unequal_bottom_side_of_case+5;

		//left side clip
		translate([-clip_display_separation,0,vertical_clip_width,vertical_clip_width])
		rotate([0,180,0])
		translate([0,case_thickness/2+clip_display_gap,0])
		create_mini_clip2(clip_reach_bottom,vertical_clip_width);

		//right side clip
		translate([0,-case_thickness/2-clip_display_gap,0])
		create_mini_clip2(clip_reach_top,vertical_clip_width);
	}
}
else if (generate=="keyguard frame" && has_frame && !is_laser_cut){
	color("Turquoise")
	keyguard_frame("no");
	
	if (show_keyguard_with_frame == "yes"){
		translate([0,0,-(keyguard_frame_thickness/2-kt/2)])
		#keyguard("yes");
	}
	
	if (include_screenshot=="yes"){
		if (MW_version){
			show_screenshotMW(keyguard_frame_thickness);
		}
		else{
			show_screenshot(keyguard_frame_thickness);
		}
	}
	
	if (show_split_line=="yes"){
		show_line_split_location();
	}
}
else if (generate=="keyguard frame" && !has_frame){
	echo();
	echo();
	echo("************ 'have a keyguard frame' is set to 'no' ************");
	echo();
	echo();
}
else if (generate=="first half of keyguard frame" && !is_laser_cut){
	color("Turquoise")
	{
		difference(){
			keyguard_frame("no");
			split_keyguard_frame("first");
		}	
	}
	if (show_split_line=="yes"){
		show_line_split_location();
	}
}
else if (generate=="second half of keyguard frame" && !is_laser_cut){
	color("Turquoise")
	{
		difference(){
			keyguard_frame("no");
			split_keyguard_frame("second");
		}
	}
	if (show_split_line=="yes"){
		show_line_split_location();
	}
}
else if ((generate=="first half of keyguard" || generate=="second half of keyguard") && is_laser_cut){
	echo();
	echo();
	echo("************ Laser-cut keyguards cannot be split ************");
	echo();
	echo();
}
else if ((generate=="keyguard frame" || generate=="first half of keyguard frame" || generate=="second half of keyguard frame") && is_laser_cut){
	echo();
	echo();
	echo("************ Laser-cut keyguard frames are not supported ************");
	echo();
	echo();
}
else if (generate=="keyguard" && is_laser_cut && has_frame){
	echo();
	echo();
	echo("************ Laser-cut keyguards, going in a keyguard frame, are not supported ************");
	echo();
	echo();
}
else if (is_3d_printed && generate=="first layer for SVG/DXF file"){
	echo();
	echo();
	echo("************ First layer for SVG/DXF filee is not supported for a 3D-Printed keyguard ************");
	echo();
	echo();
}
else if (generate=="cell insert" && is_laser_cut){
	echo();
	echo();
	echo("************ Cell inserts are not supported for laser-cut keyguards ************");
	echo();
	echo();
}
else if (generate=="cell insert" && !is_laser_cut){ //cell inserts
	rotation = (Braille_text=="") ? -90 : 0;
	color("LawnGreen")
	rotate([rotation,0,0])
	create_cell_insert();
}
else { //Customizer settings
	echo_settings();
}

  

// ---------------------Modules----------------------------

// Generates the complete 3D-printed keyguard solid, including all cutouts, case mounts,
// additions, snap-in tabs, and optional text engraving/embossing.
// @param cheat  Pass "yes" to suppress case additions that conflict with the keyguard frame
module keyguard(cheat){
	unequal_opening = (!has_frame) ? [-unequal_left_side_offset,-unequal_bottom_side_offset,0] : [0,0,0];
	difference(){
		union(){
			difference(){
				union(){
					difference(){
						//slide case opening plastic based on unequal case opening settings
						translate(unequal_opening)
						//base keyguard with  manual  and customizer mounting points and some added plastic in case region, no grid
						difference(){
							union(){
								//base object: tablet body slab or case opening along with case additions if any that can be chamfered
								base_keyguard(kw,kh,kcr,kt,cheat);
													
								//add slide-in & raised tabs
								if (has_case && !has_frame && (m_m=="Slide-in Tabs" || m_m=="Raised Tabs")){
									case_mounts(kt);
								}
								
								//add shelf as a mounting method
								if (has_case && !has_frame && m_m=="Shelf" && cheat=="no") {
									shelf_height = coh+2*shelf_depth;
									shelf_width = cow+2*shelf_depth;
					
									translate([0 ,0,-kt/2])
									linear_extrude(height=shelf_t)
									build_addition(shelf_width, shelf_height, "r", scr);
								}
								
								// adding manual slide-in tabs, other shapes not full keyguard height, and pedestals for clip-on straps
								if(!is_undef(case_additions) && len(case_additions)>0 && has_case && (!has_frame ||
										(has_frame && generate=="keyguard frame" && cheat=="no"))){
									if(is_v2(case_additions)) apply_flex_height_shapes_v2(case_additions, false); else apply_flex_height_shapes(case_additions, false);

									if(!is_laser_cut){
										if(is_v2(case_additions)) add_manual_mount_pedestals_v2(case_additions); else add_manual_mount_pedestals(case_additions);
									}
								}
								if(len(m_c_a)>0 && has_case && (!has_frame ||
										(has_frame && generate=="keyguard frame" && cheat=="no"))){
									if(is_v2(m_c_a)) apply_flex_height_shapes_v2(m_c_a, false); else apply_flex_height_shapes(m_c_a, false);

									if(!is_laser_cut){
										if(is_v2(m_c_a)) add_manual_mount_pedestals_v2(m_c_a); else add_manual_mount_pedestals(m_c_a);
									}
								}

								
								//add embossed text to case region
								if (text!="" && keyguard_region=="case region" && text_depth>0){
									engrave_emboss_instruction();
								}
								
								//add pedestals for clip-on straps and ensure pedestals don't extend into screen area
								if (has_case && m_m=="Clip-on Straps" && 
								    !(generate=="keyguard" && has_frame) &&
									!(generate=="keyguard frame" && has_frame) &&
									!no_clips){
									case_mounts(kt);
								}
							
								// add mounting posts and small tabs
								if(has_case && m_m=="Posts"){
									add_mounting_posts();
								}
							
							}
							
							
							//*** cut away from keyguard blank those things that will be moved when the case opening is unequal
							
							// cut case openings
							if(!is_undef(case_openings) && len(case_openings)>0 && has_case && !(has_frame && generate=="keyguard") && cheat=="no"){
								if(is_v2(case_openings)) cut_case_openings_v2(case_openings,kt); else cut_case_openings(case_openings,kt);
							}
							if(len(m_c_o)>0 && has_case && !(has_frame && generate=="keyguard") && cheat=="no"){
								if(is_v2(m_c_o)) cut_case_openings_v2(m_c_o,kt); else cut_case_openings(m_c_o,kt);
							}
						
							//add engraved text to case region
							if (text!="" && keyguard_region=="case region" && text_depth<0){
								engrave_emboss_instruction();
							}

							//add cuts for suction cups, velcro, clip-on straps and screw-on straps
							if (!has_case && hide_screen_region=="no" && is_3d_printed){
								mounting_points();
							}
									
							//cut out slots for customizer added clip-on straps
							if (has_case && m_m=="Clip-on Straps" && 
								    !(generate=="keyguard" && has_frame) &&
									!(generate=="keyguard frame" && has_frame) &&
									!no_clips){
								clip_on_straps_groove();
							}							

							// "-" shapes not full keyguard height
							if(!is_undef(case_additions) && len(case_additions)>0 && has_case && (!has_frame ||
									(has_frame && generate=="keyguard frame" && cheat=="no"))){
								if(is_v2(case_additions)) apply_flex_height_shapes_v2(case_additions, true); else apply_flex_height_shapes(case_additions, true);
							}
							if(len(m_c_a)>0 && has_case && (!has_frame ||
									(has_frame && generate=="keyguard frame" && cheat=="no"))){
								if(is_v2(m_c_a)) apply_flex_height_shapes_v2(m_c_a, true); else apply_flex_height_shapes(m_c_a, true);
							}

							// add slots to manually added clip-on strap pedestals
							if(!is_undef(case_additions) && len(case_additions)>0 && has_case && !is_laser_cut && cheat=="no"){
								if(is_v2(case_additions)) cut_manual_mount_pedestal_slots_v2(case_additions); else cut_manual_mount_pedestal_slots(case_additions);
							}
							if(len(m_c_a)>0 && has_case && !is_laser_cut && cheat=="no"){
								if(is_v2(m_c_a)) cut_manual_mount_pedestal_slots_v2(m_c_a); else cut_manual_mount_pedestal_slots(m_c_a);
							}
						}
						
						//*** cut things/areas that are part of the screen area and unaffected by unequal case opening
						
						// remove the screen area of the keyguard if it is thinner than the rest of the keyguard
						//    and cut out all things that enter into the screen area - can be overwritten later by things like bumps and ridges
						al = max(adj_lec,0);
						ar = max(adj_rec,0);
						at = max(adj_tec,0);
						ab = max(adj_bec,0);
						translate([al/2-ar/2,ab/2-at/2,kt/2+ff])
						hole_cutter2(screen_width+cec*2-al-ar+cell_top_offset*2, screen_height+cec*2-at-ab+cell_top_offset*2, 90,90,90,90,bcr+cec/2,kt-sat);


						//cut bars and grid cells - which don't move with unequal case opening
						if (column_count>0 && row_count>0){
							bars(sat);
						}
						
						//cut openings for cells
						if (column_count>0 && row_count>0){
							translate([0,0,-ff])
							bounded_cells(sat);
						}
						
						//home button and camera are cut for both case and no_case configurations
						home_camera(kt);
						
						// symmetric openings are not supported for unequal openings or keyguard frames
						if(add_symmetric_openings=="yes" && !has_frame && unequal_left_side_offset==0 && unequal_bottom_side_offset==0){
							rotate([0,0,180])
							home_camera(kt);
							
							if (expose_ambient_light_sensors=="yes" && len(ttao)>0){
								rotate([0,0,180])
								cut_als_openings(ttao,sat);
							}
						}

						// make cuts associated with the tablet like ALS openings and symmetric camera/home button slots that are as deep as the keyguard
						//    - can affect slide-in tabs and raised tabs (in particular)

						// cut tablet openings
						if(!is_undef(tablet_openings) && len(tablet_openings)>0 && tablet_height>0 && tablet_width>0 && cheat=="no"){
							if(is_v2(tablet_openings)) cut_tablet_openings_v2(tablet_openings,kt); else cut_tablet_openings(tablet_openings,kt);
						}
						if(len(m_t_o)>0 && tablet_height>0 && tablet_width>0 && cheat=="no"){
							if(is_v2(m_t_o)) cut_tablet_openings_v2(m_t_o,kt); else cut_tablet_openings(m_t_o,kt);
						}

						// ambient light sensors
						if (expose_ambient_light_sensors=="yes" && len(ttao)>0){
							cut_als_openings(ttao,kt);
						}

						//add embossed text to tablet region
						if (text!="" && keyguard_region=="tablet region" && text_depth<0){
							engrave_emboss_instruction();
						}

						//cut screen openings
						if(!is_undef(screen_openings) && len(screen_openings)>0 && type_of_tablet!="blank"){
							if(is_v2(screen_openings)) cut_screen_openings_v2(screen_openings,sat); else cut_screen_openings(screen_openings,sat);
						}
						if(len(m_s_o)>0 && type_of_tablet!="blank"){
							if(is_v2(m_s_o)) cut_screen_openings_v2(m_s_o,sat); else cut_screen_openings(m_s_o,sat);
						}

						// add engraved text in the screen region
						if (text!="" && keyguard_region=="screen region" && text_depth < 0){
							engrave_emboss_instruction();
						}
						 						
						// add engraved text in the tablet region
						if (text!="" && keyguard_region=="tablet region" && text_depth < 0){
							engrave_emboss_instruction();
						}

						//if the keyguard will be trimmed to a specific pair of x,y locations
						if (len(t_t_r_ll)==2 && len(t_t_r_ur)==2 && hide_screen_region=="no"){
							trim_to_rectangle();
						}
					}

					//*** add items screen elements  and case elements that will override screen cutouts
					
					//add cell ridges	
					if (column_count>0 && row_count>0 && is_3d_printed){
						cell_ridges();
					}

					//add bumps and ridges
					if(!is_undef(screen_openings) && len(screen_openings)>0 && is_3d_printed){
						if(is_v2(screen_openings)) adding_plastic_v2(screen_openings,"screen"); else adding_plastic(screen_openings,"screen");
					}
					if(len(m_s_o)>0 && is_3d_printed){
						if(is_v2(m_s_o)) adding_plastic_v2(m_s_o,"screen"); else adding_plastic(m_s_o,"screen");
					}

					//add bumps and ridges from case_openings file and adjust for unequal case opening
					if(!is_undef(case_openings) && len(case_openings)>0){
						translate(unequal_opening)
						if(is_3d_printed && has_case && !has_frame && cheat=="no"){
							if(is_v2(case_openings)) adding_plastic_v2(case_openings,"case"); else adding_plastic(case_openings,"case");
						}
					}
					if(len(m_c_o)>0){
						translate(unequal_opening)
						if(is_3d_printed && has_case && !has_frame && cheat=="no"){
							if(is_v2(m_c_o)) adding_plastic_v2(m_c_o,"case"); else adding_plastic(m_c_o,"case");
						}
					}

					// add embossed text
					if (text!="" && keyguard_region=="screen region" && text_depth > 0){
						engrave_emboss_instruction();
					}
				}
				
				//*** add cuts that should override anything added to the screen
				
				// remove parts of keyguard frame above posts
				if(has_case && has_frame && mount_keyguard_with=="posts"){
					trim_keyguard_to_bar();
				}
										
				//cut away the screen region
				if (hide_screen_region == "yes"){
					cut_screen();
				}
				//cut away the grid region
				if (hide_grid_region == "yes"){
					cut_grid();
				}
			}
			
			//*** add specialized elements for special configurations - like a snap-in keyguard to a keyguard frame
			
			// add snap-in tabs
			if (has_frame && hide_screen_region == "no"){
				add_snap_ins();
			}
					
			//add the posts themselves
			if(has_case && has_frame && mount_keyguard_with=="posts"){
				add_keyguard_frame_posts();
			}	
		}
		//*** last minute cuts
		
		//splitting the keyguard
		if (generate=="first half of keyguard" || generate=="second half of keyguard"){
			split_keyguard();
		}
		
		//trim down to the first two layers
		if (first_two_layers_only=="yes"){
			translate([0,0,50-kt/2+0.4])
			cube([1000,1000,100],center=true);
		}
	}
}


// Generates the 2D laser-cut keyguard outline including all cutouts and slide-in tabs.
// Produces a flat 2D profile (zero thickness) suitable for laser cutting workflows.
// create 2D image of keyguard for laser cutting
module lc_keyguard(){
	unequal_opening = [-unequal_left_side_offset,-unequal_bottom_side_offset,0];
	difference(){
		union(){
			difference(){
				union(){
					difference(){
						//slide case opening plastic based on unequal case opening settings
						translate(unequal_opening)
						//base keyguard with  manual  and customizer mounting points and some added plastic in case region, no grid
						difference(){ // here only for consistency with keyguard()
							union(){
								//base object: tablet body slab or case opening along with case additions if any that can be chamfered
								base_keyguard(kw,kh,kcr,0,"no");
													
								//add slide-in & raised tabs
								if (has_case && !has_frame && m_m=="Slide-in Tabs"){
									case_mounts(0);
								}
							}
							//*** cut away from keyguard blank those things that will be moved when the case opening is unequal

							// cut case openings
							if(!is_undef(case_openings) && len(case_openings)>0 && has_case && !(has_frame && generate=="keyguard")){
								if(is_v2(case_openings)) cut_case_openings_v2(case_openings,0); else cut_case_openings(case_openings,0);
							}
							if(len(m_c_o)>0 && has_case && !(has_frame && generate=="keyguard")){
								if(is_v2(m_c_o)) cut_case_openings_v2(m_c_o,0); else cut_case_openings(m_c_o,0);
							}

							//*** cut away from keyguard blank those things that will be moved when the case opening is unequal
							
							// nothing of this type to delete for a laser-cut keyguard
							
						} // here only for consistency with keyguard()
						
						//*** cut things/areas that are part of the screen area and unaffected by unequal case opening
						
						//cut bars and grid cells - which doesn't move with unequal case opening
						if (column_count>0 && row_count>0){
							bars(0);
						}
						
						if (column_count>0 && row_count>0){
							translate([0,0,0])
							cells(0);
						}
						
						//home button and camera are cut for both case and no_case configurations
						home_camera(0);
						
						// symmetric openings are not supported for unequal sides
						if(add_symmetric_openings=="yes" && unequal_left_side_offset==0 && unequal_bottom_side_offset==0){
							rotate([0,0,180])
							home_camera(0);
							
							rotate([0,0,180])
							cut_als_openings(ttao,0);
						}
					
						// make cuts associated with the tablet like ALS openings and symmetric camera/home button slots that are as deep as the keyguard - can affect slide-in tabs and raised tabs (in particular)
						
						// ambient light sensors
						if (expose_ambient_light_sensors=="yes" && len(ttao)>0){
							cut_als_openings(ttao,0);
						}
											
						// cut tablet openings
						if(!is_undef(tablet_openings) && len(tablet_openings)>0 && tablet_height>0 && tablet_width>0){
							if(is_v2(tablet_openings)) cut_tablet_openings_v2(tablet_openings,0); else cut_tablet_openings(tablet_openings,0);
						}
						if(len(m_t_o)>0 && tablet_height>0 && tablet_width>0){
							if(is_v2(m_t_o)) cut_tablet_openings_v2(m_t_o,0); else cut_tablet_openings(m_t_o,0);
						}

						//cut screen openings
						if(!is_undef(screen_openings) && len(screen_openings)>0 && type_of_tablet!="blank"){
							if(is_v2(screen_openings)) cut_screen_openings_v2(screen_openings,0); else cut_screen_openings(screen_openings,0);
						}
						if(len(m_s_o)>0 && type_of_tablet!="blank"){
							if(is_v2(m_s_o)) cut_screen_openings_v2(m_s_o,0); else cut_screen_openings(m_s_o,0);
						}

					}
					
					//*** add items screen elements and case elements that will override screen cutouts
					
					// nothing of this type to add for a laser-cut keyguard
					
				}
				//*** add cuts that should override anything added to the screen
				
				// nothing of this type to delete for a laser-cut keyguard
				
			}
			
			//*** add specialized elements for special configurations - like a snap-in keyguard to a keyguard frame
			
			// nothing of this type to add for a laser-cut keyguard

		}
		//*** last minute cuts
		
		// nothing of this type to delete for a laser-cut keyguard

		
	}
}

// Generates the keyguard frame — the outer border piece that a snap-in or posts
// mounted keyguard fits into. Includes case mounts, case additions, and relevant cutouts.
// @param cheat  Pass "yes" to suppress additions that conflict with the inner keyguard
module keyguard_frame(cheat){
	unequal_border = [-unequal_tablet_left_side_offset,-unequal_tablet_bottom_side_offset,0];

	trans = (has_case) ? [-unequal_left_side_offset,-unequal_bottom_side_offset,0] : unequal_border;
	difference(){
		translate(trans)
		difference(){
			union(){
				if (m_m=="Shelf") {
					shelf_height = coh+2*shelf_depth;
					shelf_width = cow+2*shelf_depth;
	
					translate([0 ,0,-keyguard_frame_thickness/2])
					linear_extrude(height=shelf_t)
					build_addition(shelf_width, shelf_height, "r", scr);
				}
				base_keyguard(fw,fh,fcr,keyguard_frame_thickness,"no");

				case_mounts(keyguard_frame_thickness);
											
				//add bumps and ridges from case_openings file
				if(!is_undef(case_openings) && len(case_openings)>0){
					if(is_v2(case_openings)) adding_plastic_v2(case_openings,"case"); else adding_plastic(case_openings,"case");
				}
				if(len(m_c_o)>0){
					if(is_v2(m_c_o)) adding_plastic_v2(m_c_o,"case"); else adding_plastic(m_c_o,"case");
				}

				// adding manual slide-in tabs and pedestals for clip-on straps
				if(!is_undef(case_additions) && len(case_additions)>0 && (!has_frame ||
				   (has_frame && generate=="keyguard frame" && cheat=="no"))){
					if(is_v2(case_additions)) apply_flex_height_shapes_v2(case_additions, false); else apply_flex_height_shapes(case_additions, false);

					if(is_v2(case_additions)) add_manual_mount_pedestals_v2(case_additions, keyguard_frame_thickness); else add_manual_mount_pedestals(case_additions);
				}
				if(len(m_c_a)>0 && (!has_frame ||
				   (has_frame && generate=="keyguard frame" && cheat=="no"))){
					if(is_v2(m_c_a)) apply_flex_height_shapes_v2(m_c_a, false); else apply_flex_height_shapes(m_c_a, false);

					if(is_v2(m_c_a)) add_manual_mount_pedestals_v2(m_c_a, keyguard_frame_thickness); else add_manual_mount_pedestals(m_c_a);
				}

				//add engraved text
				// not supported?? What if I put text in the case region of the openings and additions file?
			}
			
			//cut case openings
			if(!is_undef(case_openings) && len(case_openings)>0){
				if(is_v2(case_openings)) cut_case_openings_v2(case_openings,keyguard_frame_thickness); else cut_case_openings(case_openings,keyguard_frame_thickness);
			}
			if(len(m_c_o)>0){
				if(is_v2(m_c_o)) cut_case_openings_v2(m_c_o,keyguard_frame_thickness); else cut_case_openings(m_c_o,keyguard_frame_thickness);
			}

			if (m_m=="Clip-on Straps" && !no_clips){
				clip_on_straps_groove();
			}

			// add slots to manually added clip-on strap pedestals
			if(!is_undef(case_additions) && len(case_additions)>0 && !is_laser_cut && cheat=="no"){
				if(is_v2(case_additions)) cut_manual_mount_pedestal_slots_v2(case_additions); else cut_manual_mount_pedestal_slots(case_additions);
			}
			if(len(m_c_a)>0 && !is_laser_cut && cheat=="no"){
				if(is_v2(m_c_a)) cut_manual_mount_pedestal_slots_v2(m_c_a); else cut_manual_mount_pedestal_slots(m_c_a);
			}

		}

		// cut_out_opening for keyguard
		hole_cutter(keyguard_width,keyguard_height,90,90,90,90,kcr[0],keyguard_frame_thickness);
		
		//cut clip-on strap pedestals (manual or otherwise) if they extend into the space for the keyguard
		// translate([0,0,keyguard_frame_thickness/2+pedestal_height/2-ff])
		translate([0,0,keyguard_frame_thickness/2])
		linear_extrude(height=pedestal_height+10)
		offset(r=kcr[0])
		square([keyguard_width+cec*2-kcr[0]*2,keyguard_height+cec*2-kcr[0]*2], center=true);

		// cut slots for snap-in tabs on keyguard edges
		snap_in_tab_grooves();
		
		//camera and home button openings
		home_camera(keyguard_frame_thickness);
		
		// cut tablet openings
		if(!is_undef(tablet_openings) && len(tablet_openings)>0 && tablet_height>0 && tablet_width>0 && cheat=="no"){
			if(is_v2(tablet_openings)) cut_tablet_openings_v2(tablet_openings,kt); else cut_tablet_openings(tablet_openings,kt);
		}
		if(len(m_t_o)>0 && tablet_height>0 && tablet_width>0 && cheat=="no"){
			if(is_v2(m_t_o)) cut_tablet_openings_v2(m_t_o,kt); else cut_tablet_openings(m_t_o,kt);
		}

		// remove non-full height "-" shapes
		if(!is_undef(case_additions) && len(case_additions)>0 && (!has_frame ||
		   (has_frame && generate=="keyguard frame" && cheat=="no"))){
			if(is_v2(case_additions)) apply_flex_height_shapes_v2(case_additions, true); else apply_flex_height_shapes(case_additions, true);
		}
		if(len(m_c_a)>0 && (!has_frame ||
		   (has_frame && generate=="keyguard frame" && cheat=="no"))){
			if(is_v2(m_c_a)) apply_flex_height_shapes_v2(m_c_a, true); else apply_flex_height_shapes(m_c_a, true);
		}


		//tablet openings for ALS
		if(expose_ambient_light_sensors=="yes" && len(ttao)>0){
			cut_als_openings(ttao,keyguard_frame_thickness);
		}
			
		// symmetric openings are not supported for keyguard frames
		
		if (mount_keyguard_with=="posts"){
			post_cl = (expose_upper_message_bar == "yes" && expose_upper_command_bar == "yes") ? shm/2-sbhm-umbhm-ucbhm :
					  (expose_upper_message_bar == "yes" && expose_upper_command_bar == "no") ? shm/2-sbhm-umbhm :	
					  shm/2-sbhm;

			translate([keyguard_width/2+post_len/2-5,post_cl,-keyguard_frame_thickness/2-ff])
			add_keyguard_frame_post_slots();

			translate([keyguard_width/2+post_len/2-5,-post_cl,-keyguard_frame_thickness/2-ff])
			add_keyguard_frame_post_slots();
			
			translate([-keyguard_width/2-post_len/2+5,post_cl,-keyguard_frame_thickness/2-ff])
			add_keyguard_frame_post_slots();
			
			translate([-keyguard_width/2-post_len/2+5,-post_cl,-keyguard_frame_thickness/2-ff])
			add_keyguard_frame_post_slots();
		}
	}
}


// Cuts the slot and cylindrical bore that receive a keyguard frame post,
// allowing the inner keyguard to slide onto the frame posts.
module add_keyguard_frame_post_slots(){
	hole_dia = kt - post_tightness_of_fit/10;

	translate([0,0,(hole_dia/2)/2])
	cube([post_len+10,hole_dia,hole_dia/2],center=true);

	translate([0,0,(hole_dia)/2])
	rotate([0,90,0])
	cylinder(d=hole_dia,h=post_len+10,center=true);
}


// Adds the cylindrical posts that protrude from the keyguard frame and insert into
// the corresponding post slots of the inner keyguard.
module add_keyguard_frame_posts(){
	post_dia = kt;
	post_cl = (expose_upper_message_bar == "yes" && expose_upper_command_bar == "yes") ? shm/2-sbhm-umbhm-ucbhm+kt/2 :
              (expose_upper_message_bar == "yes" && expose_upper_command_bar == "no") ? shm/2-sbhm-umbhm+kt/2 :	
			  shm/2-sbhm+kt/2;
	post_l = kw+post_len*2;
	
	translate([0,post_cl-kt/2,0])
	rotate([0,90,0])
	cylinder(d=post_dia,h=post_l,center=true);
}


// Cuts away the top portion of the keyguard above the exposed status/message/command bar,
// so the bar opening is flush with the top edge of the remaining keyguard body.
module trim_keyguard_to_bar(){
	post_cl = (expose_upper_message_bar == "yes" && expose_upper_command_bar == "yes") ? shm/2-sbhm-umbhm-ucbhm :
              (expose_upper_message_bar == "yes" && expose_upper_command_bar == "no") ? shm/2-sbhm-umbhm :	
			  shm/2-sbhm;

	//remove top portion of keyguard
	translate([0,50+post_cl,0])
	cube([keyguard_width+10,100,kt+10],center=true);
}


// Generates the horizontal cylindrical mounting posts (and optional mini tabs) used when
// the mounting method is "Posts". Posts extend out from the sides of the case opening.
module add_mounting_posts(){
	pd = (has_frame) ? kt : post_diameter;
	p_l = (expose_status_bar=="yes" || expose_upper_message_bar=="yes") ? post_length : width_of_opening_in_case+post_length*2;

	bdr = (cow-swm)/2;

	post_height = coh/2 - mount_to_top_of_opening_distance;
	post_len_r = p_l + bdr + rec;
	post_len_l = p_l + bdr + lec;
	
	post_r0 = cow/2 + post_len_r/2 -bdr - rec;
	post_l0 = -cow/2 - post_len_l/2 + bdr + lec;
	
	cut_angle = 17;
	offset_angle = 38;
	ofset = pd/2 * sin(offset_angle);

	difference(){
		if (p_l > 0){
			if (expose_status_bar=="yes" || expose_upper_message_bar=="yes"){
				translate([post_l0,post_height,(pd-kt)/2])
				rotate([-cut_angle,0,0])
				difference(){
					rotate([0,90,0])
					cylinder(d=pd,h=post_len_l,center=true);
				
					if (notch_in_post=="yes"){
						translate([cow/2,10+ofset,0])
						cube([cow+100,20,20],center=true);
					}
				}

				translate([post_r0,post_height,(pd-kt)/2])
				rotate([-cut_angle,0,0])
				difference(){
					rotate([0,90,0])
					cylinder(d=pd,h=post_len_r,center=true);
				
					if (notch_in_post=="yes"){
						translate([cow/2,10+ofset,0])
						cube([cow+100,20,20],center=true);
					}
				}
			}
			else{
				translate([0,post_height,(pd-kt)/2])
				difference(){
					rotate([0,90,0])
					cylinder(d=post_diameter,h=p_l,center=true);

					if (notch_in_post=="yes"){
						rotate([-cut_angle,0,0])
						translate([0,10+ofset,0])
						cube([cow+100,20,20],center=true);
					}
				}
			}
		}
	}
	
	if(add_mini_tabs == "yes"){
		// V2 case_additions row: [ID, shape, height, width, corner, x, y, cb, [trim]]
		// "r3" is V2's rotated-rectangle shape (V1 "rr3" with the corner column carrying the radius).
		tab = [
			[1, "r3", mini_tab_length, mini_tab_width, 1, cow/2, coh/2, 1, [-999, -999, -999, -999]],
		];

		translate([-cow/2+mini_tab_inset_distance+mini_tab_width/2,-coh/2,min(mini_tab_height,keyguard_thickness-2)])
		rotate([0,0,-rotate_mini_tab])
		apply_flex_height_shapes_v2(tab, false);

		translate([cow/2-mini_tab_inset_distance-mini_tab_width/2,-coh/2,min(mini_tab_height,keyguard_thickness-2)])
		rotate([0,0,rotate_mini_tab])
		apply_flex_height_shapes_v2(tab, false);
	}
}

// Produces the cutting tool that splits the keyguard into first and second halves,
// optionally adding dovetail interlocks at the split line.
module split_keyguard(){
	half = (generate == "first half of keyguard") ? "first" : "second";
	
	if (is_landscape){
		maskwidth = (!has_case) ? tablet_width : kw;
		maskheight = (!has_case) ? tablet_height : kh;
		
		if (split_line_location==0 && row_count > 0 && column_count > 0){
			odd_num_columns = column_count/2 - floor(column_count/2) > 0;
			max_cell_w=grid_width/column_count;
			cut_line = (odd_num_columns) ? 
				(column_count/2 + 0.5)*max_cell_w :
				(column_count/2)*max_cell_w;
			split_x0 = (generate=="first half of keyguard")?
				grid_x0+cut_line:
				grid_x0+cut_line-(maskwidth*2);
			if (split_line_type=="flat"){
				translate([maskwidth+split_x0,0,0])
				cube([maskwidth*2,maskheight*2,100],center=true);
			}
			else{
				translate([maskwidth+split_x0-1,slide_dovetails,0])
				difference(){
					union(){
						cube([maskwidth*2,maskheight*2,100],center=true);
						translate([maskwidth+1-ff,0,0])
						rotate([0,0,90])
						dovetails(half);
					}
					translate([-maskwidth+1-ff,0,0])
					rotate([0,0,90])
					dovetails(half);
				}
			}
		}
		else{
			split_x0 = (generate=="first half of keyguard")? (maskwidth*2)/2 + split_line_location : -(maskwidth*2)/2 + split_line_location;
			if (split_line_type=="flat"){
				translate([split_x0,0,0])
				cube([maskwidth*2,maskheight*2,100],center=true);
			}
			else{
				translate([split_x0-1,slide_dovetails,0])
				difference(){
					union(){
						cube([maskwidth*2,maskheight*2,100],center=true);
						translate([maskwidth+1-ff,0,0])
						rotate([0,0,90])
						dovetails(half);
					}
					translate([-maskwidth+1-ff,0,0])
					rotate([0,0,90])
					dovetails(half);
				}
			}
		}
	}
	else{
		maskwidth = (!has_case) ? tablet_width : kw;
		maskheight = (!has_case) ? tablet_height : kh;

		if (split_line_location==0 && row_count > 0 && column_count > 0){
			odd_num_rows = row_count/2 - floor(row_count/2) > 0;
			max_cell_h=grid_height/row_count;
			cut_line = (odd_num_rows) ? 
				(row_count/2 + 0.5)*max_cell_h :
				(row_count/2)*max_cell_h;
				
			split_y0 = (generate=="first half of keyguard")? -maskwidth+grid_y0+cut_line : maskwidth+grid_y0+cut_line;

			if (split_line_type=="flat"){
				translate([0,split_y0,0])
				cube([maskheight*2,maskwidth*2,100],center=true);
			}
			else{
				translate([slide_dovetails,split_y0+0.5,0])
				difference(){
					union(){
						cube([maskheight*2,maskwidth*2,100],center=true);
						translate([0,-maskwidth+ff,0])
						rotate([0,0,0])
						dovetails(half);
					}
					translate([0,maskwidth+ff,0])
					rotate([0,0,0])
					dovetails(half);
				}
			}
		}
		else{
			split_y0 = (generate=="first half of keyguard")? -(maskwidth*2)/2 + split_line_location : (maskwidth*2)/2 + split_line_location;
			if (split_line_type=="flat"){
				translate([0,split_y0,0])
				cube([maskheight*2,maskwidth*2,100],center=true);
			}
			else{
				translate([slide_dovetails,split_y0+1,0])
				difference(){
					union(){
						cube([maskheight*2,maskwidth*2,100],center=true);
						translate([0,-maskwidth-1+ff,0])
						rotate([0,0,0])
						dovetails(half);
					}
					translate([0,maskwidth-1-ff,0])
					rotate([0,0,0])
					dovetails(half);
				}
			}
		}
	}
}

// Renders a highlighted 1 mm slab at the split-line position for visual inspection,
// and echoes the distance from each edge to the console.
module show_line_split_location(){
	if (is_landscape){
		if(generate=="keyguard frame" || generate=="first half of keyguard frame" ||generate=="second half of keyguard frame"){
			translate([split_line_location,0,0])
			#cube([1,coh+10,10],center=true);
			
			echo();
			echo(str("split is located ", cow/2+split_line_location+split_add, " mm from left side of frame and ", cow/2-split_line_location+split_add, " mm from right side of frame"));
			echo();
		}
		else{
			if (split_line_location==0 && row_count > 0 && column_count > 0){
				odd_num_columns = column_count/2 - floor(column_count/2) > 0;
				max_cell_w=grid_width/column_count;
				cut_line = (odd_num_columns) ? 
					(column_count/2 + 0.5)*max_cell_w :
					(column_count/2)*max_cell_w;
				split_x0 = cut_line-grid_width/2;

				translate([split_x0,0,0])
				#cube([1,kh+10,10],center=true);
				
				echo();
				echo(str("split is located ", kw/2+split_x0+split_add, " mm from left side of keyguard and ", kw/2-split_x0+split_add, " mm from right side of keyguard"));
				echo();
			}
			else{
				translate([split_line_location,0,0])
				#cube([1,kh+10,10],center=true);
				
				echo();
				echo(str("split is located ", kw/2+split_line_location+split_add, " mm from left side of keyguard and ", kw/2-split_line_location+split_add, " mm from right side of keyguard"));
				echo();
			}
			
		}
	}
	else{
		if(generate=="keyguard frame" || generate=="first half of keyguard frame" ||generate=="second half of keyguard frame"){
			translate([0,split_line_location,0])
			#cube([cow+10,1,10],center=true);
			
			echo();
			echo(str("split is located ", coh/2-split_line_location+split_add, " mm from top side of frame and ", coh/2+split_line_location, " mm from bottom side of frame"));
			echo();
		}
		else{
			if (split_line_location==0 && row_count > 0 && column_count > 0){
				odd_num_rows = row_count/2 - floor(row_count/2) > 0;
				max_cell_h=grid_height/row_count;
				cut_line = (odd_num_rows) ? 
					(row_count/2 + 0.5)*max_cell_h :
					(row_count/2)*max_cell_h;
					
				split_y0 = cut_line-grid_height/2;

				translate([0,split_y0,0])
				#cube([kw+10,1,10],center=true);
				
				echo();
				echo(str("split is located ", kh/2-split_y0+split_add, " mm from top side of keyguard and ", kh/2+split_y0+split_add, " mm from bottom side of keyguard"));
				echo();
			}
			else{
				translate([0,split_line_location,0])
				#cube([kw+10,1,10],center=true);
				
				echo();
				echo(str("split is located ", kh/2-split_line_location+split_add, " mm from top side of keyguard and ", kh/2+split_line_location+split_add, " mm from bottom side of keyguard"));
				echo();
			}
		}
	}
}



// Produces the cutting tool that splits the keyguard frame into first and second halves,
// with optional dovetail interlocks at the split line.
// @param half  "first" or "second" — selects which half of the frame to keep
module split_keyguard_frame(half){
	maskwidth = fw;
	maskheight = fh;
		
	rot = (is_landscape) ? [0,0,0] : [0,0,-90];
	split_x0 = (half=="first")? maskwidth + split_line_location : -maskwidth + split_line_location;
	
	rotate(rot)
	if (split_line_type=="flat"){
		translate([split_x0,0,0])
		cube([maskwidth*2,maskheight*2,100],center=true);
	}
	else{
		translate([split_x0-1,slide_dovetails,0])
		difference(){
			union(){
				cube([maskwidth*2,maskheight*2,100],center=true);
				translate([maskwidth+1-ff,0,0])
				rotate([0,0,90])
				dovetails(half);
			}
			translate([-maskwidth+1-ff,0,0])
			rotate([0,0,90])
			dovetails(half);
		}
	}
}

// Generates a row of dovetail teeth or sockets along the split line for joining
// the two halves of a split keyguard or frame.
// @param half  "first" produces teeth; "second" produces sockets (with tightness gap)
module dovetails(half){
	cutLen = (!has_case) ? tablet_height*2+ff*2 : kh*2+ff*2 ;
	doveTailWidth=dovetail_width;
	doveTailHeight = 100;
	gap = (half == "second") ? tightness_of_dovetail_joint/2 : 0;
	for (i=[-cutLen/2+doveTailWidth/2-1:doveTailWidth*2-2:cutLen/2]){
		translate([i,-1,-doveTailHeight/2])
		linear_extrude(height=doveTailHeight)
		polygon([[0+gap,0],[doveTailWidth-gap,0],[doveTailWidth-1-gap,2],[1+gap,2]]);
	}
}

// Dispatches to the appropriate mounting geometry (slide-in tabs, raised tabs, or
// clip-on strap pedestals) based on the current mounting method parameter.
// @param depth  Keyguard thickness in mm; pass 0 for laser-cut (2D) output
module case_mounts(depth) {
	//add mounting points for cases
	if (m_m=="Slide-in Tabs"){
		if (depth>0){
			translate([0,0,-depth/2])
			linear_extrude(height = slide_in_tab_thickness)
			add_2d_slide_in_tabs();
		}
		else{
			add_2d_slide_in_tabs();
		}
	}
	else if (m_m=="Raised Tabs" && is_3d_printed && depth > 0){
		add_raised_tabs(depth);
	}
	else if (m_m=="Clip-on Straps" && is_3d_printed && depth > 0 && !no_clips){
		add_clip_on_strap_pedestals(depth);
	}
}

// Places the 2D slide-in tab profiles on the horizontal and/or vertical edges of
// the keyguard outline, ready to be extruded to the slide-in tab thickness.
module add_2d_slide_in_tabs() {
	h_sitlen = horizontal_slide_in_tab_length_incl_acrylic;
	v_sitlen = vertical_slide_in_tab_length_incl_acrylic;
	h_sitwid = horizontal_slide_in_tab_width;
	v_sitwid = vertical_slide_in_tab_width;
	// if the length of tabs = 2 and the distance between them is 0 then the render step fails separateh them by ff
	h_sitdist = (h_sitlen == 2 && distance_between_horizontal_slide_in_tabs == 0) ? distance_between_horizontal_slide_in_tabs + ff : distance_between_horizontal_slide_in_tabs;
	v_sitdist = (v_sitlen == 2 && distance_between_vertical_slide_in_tabs == 0) ? distance_between_vertical_slide_in_tabs + ff : distance_between_vertical_slide_in_tabs;
		
	if(slide_in_tab_locations == "horizontal only" || slide_in_tab_locations == "horizontal and vertical"){
		left_slide_in_tab_offset = -kw/2+ff;
		
		translate([left_slide_in_tab_offset,-h_sitdist/2-h_sitwid/2+ulbs])
		mirror([1,0,0])
		create_2D_slide_in_tab(h_sitlen,h_sitwid);
		
		translate([left_slide_in_tab_offset,h_sitdist/2+h_sitwid/2+ulbs])
		mirror([1,0,0])
		create_2D_slide_in_tab(h_sitlen,h_sitwid);
		
		right_slide_in_tab_offset = kw/2-ff;
		
		translate([right_slide_in_tab_offset,-h_sitdist/2-h_sitwid/2+ulbs])
		create_2D_slide_in_tab(h_sitlen,h_sitwid);

		translate([right_slide_in_tab_offset,h_sitdist/2+h_sitwid/2+ulbs])
		create_2D_slide_in_tab(h_sitlen,h_sitwid);
	}
	if(slide_in_tab_locations == "vertical only" || slide_in_tab_locations == "horizontal and vertical"){
		bottom_slide_in_tab_offset = -kh/2+ff;
		
		translate([-v_sitdist/2-v_sitwid/2+ulos, bottom_slide_in_tab_offset])
		rotate([0,0,-90])
		create_2D_slide_in_tab(v_sitlen,v_sitwid);

		translate([v_sitdist/2+v_sitwid/2+ulos,bottom_slide_in_tab_offset])
		rotate([0,0,-90])
		create_2D_slide_in_tab(v_sitlen,v_sitwid);

		top_slide_in_tab_offset = kh/2-ff;

		translate([-v_sitdist/2-v_sitwid/2+ulos, top_slide_in_tab_offset])
		rotate([0,0,90])
		create_2D_slide_in_tab(v_sitlen,v_sitwid);

		translate([v_sitdist/2+v_sitwid/2+ulos, top_slide_in_tab_offset])
		rotate([0,0,90])
		create_2D_slide_in_tab(v_sitlen,v_sitwid);
	}
}

// Builds the 2D profile for a single slide-in tab, including the rounded hook
// geometry that grips the edge of the tablet case.
// @param tab_length  Length of the tab in mm (parallel to the keyguard edge)
// @param tab_width   Width of the tab in mm (perpendicular to the keyguard edge)
module create_2D_slide_in_tab(tab_length,tab_width){
	x1_offset = -tab_length/2;
	x2_offset = tab_length/2-2;
	
	translate([x2_offset,0,0])
	difference(){
		offset(r=2)
		square([tab_length,tab_width-4],center=true);
		
		translate([x1_offset,0,0])
		square([4,tab_width+2],center=true);
	}
	
	if (tab_length>=3){
		translate([1.5,tab_width/2+1.44,0])
		difference(){
			square(3,center=true);
			circle(d=3);
			
			translate([.75,0,0])
			square([1.51,3.01],center=true);
			
			translate([0,.75,0])
			square([3.01,1.51],center=true);
		}
		
		translate([1.5,-tab_width/2-1.44,0])
		difference(){
			square(3,center=true);
			circle(d=3);
			
			translate([.75,0,0])
			square([1.51,3.01],center=true);
			
			translate([0,-.75,0])
			square([3.01,1.51],center=true);
		}
	}
}

// Places the four (or eight) tapered pedestals on the case-opening border that
// clip-on straps snap onto to secure the keyguard. Routes through the V2
// case_additions placer add_manual_mount_pedestals_v2 with synthetic ped1-4 rows,
// so this built-in feature shares geometry with user-supplied manual mount
// pedestals (their insets were unified). We call the V2 placer directly rather
// than emitting these as real case_additions, so that cut_manual_mount_pedestal_slots_v2
// — which would cut wedge grooves AT each pedestal — does not run on these rows;
// the wedge grooves for the built-in straps are cut separately by clip_on_straps_groove().
// @param depth  Surface-z thickness in mm — forwarded to add_manual_mount_pedestals_v2
//               so pedestals sit on top of the slab at z = depth/2 (kt for the
//               standard keyguard call site, keyguard_frame_thickness for the frame).
module add_clip_on_strap_pedestals(depth){
	// V2 row: [ID, shape, height, width, corner, x, y, cb, [trim]]
	// addition x/y in rows are in CASE-OPENING-RELATIVE coords (0,0 = case bottom-left).
	// The V2 dispatcher uses kx0/ky0 (keyguard origin) when generate_keyguard, but
	// case_x0/case_y0 (case origin) when generating the frame; an outer translate
	// compensates so the rows can be written case-relative regardless of mode.
	shift_x = generate_keyguard ? (kw - cow)/2 : 0;
	shift_y = generate_keyguard ? (kh - coh)/2 : 0;
	hy_lo = coh/2 - distance_between_horizontal_clips/2 - horizontal_pedestal_width/2 + pedestal_corner_inset + ulbs;
	hy_hi = coh/2 + distance_between_horizontal_clips/2 + horizontal_pedestal_width/2 - pedestal_corner_inset + ulbs;
	vx_lo = cow/2 - distance_between_vertical_clips/2 - vertical_pedestal_width/2 + pedestal_corner_inset + ulos;
	vx_hi = cow/2 + distance_between_vertical_clips/2 + vertical_pedestal_width/2 - pedestal_corner_inset + ulos;

	if(clip_locations=="horizontal only" || clip_locations=="horizontal and vertical"){
		// ped4 = left-edge horizontal pedestals (anchor at case left, offset right by inset);
		// ped2 = right-edge pedestals (anchor at case right via addition_x=cow, offset left).
		h_rows = [
			[1, "ped4", 0, 0, 0, 0,   hy_lo, 0, []],
			[2, "ped4", 0, 0, 0, 0,   hy_hi, 0, []],
			[3, "ped2", 0, 0, 0, cow, hy_lo, 0, []],
			[4, "ped2", 0, 0, 0, cow, hy_hi, 0, []],
		];
		translate([shift_x, shift_y, 0])
		add_manual_mount_pedestals_v2(h_rows, depth);
	}
	if(clip_locations=="vertical only" || clip_locations=="horizontal and vertical"){
		// ped3 = bottom-edge vertical pedestals (anchor at case bottom, offset up);
		// ped1 = top-edge pedestals (anchor at case top via addition_y=coh, offset down).
		v_rows = [
			[5, "ped3", 0, 0, 0, vx_lo, 0,   0, []],
			[6, "ped3", 0, 0, 0, vx_hi, 0,   0, []],
			[7, "ped1", 0, 0, 0, vx_lo, coh, 0, []],
			[8, "ped1", 0, 0, 0, vx_hi, coh, 0, []],
		];
		translate([shift_x, shift_y, 0])
		add_manual_mount_pedestals_v2(v_rows, depth);
	}
}



// Places raised tab assemblies on the left/right edges (horizontal), top/bottom
// edges (vertical), or all four edges, according to raised_tab_locations.
// "Horizontal" always means left and right edges; "vertical" always means top
// and bottom edges, regardless of keyguard orientation.
// @param depth  Keyguard thickness in mm; determines the tab starting height and ramp geometry
module add_raised_tabs(depth) {
	s = (raised_tabs_starting_height < depth - 1) ? raised_tabs_starting_height : depth - 1;
	z = -depth/2+s;

	h_w   = horizontal_raised_tab_width;
	h_len = horizontal_raised_tab_length;
	h_d   = distance_between_horizontal_raised_tabs;

	v_w   = vertical_raised_tab_width;
	v_len = vertical_raised_tab_length;
	v_d   = distance_between_vertical_raised_tabs;

	if (horiz_rt) {
		// Left edge — tab extends in -X; width spans along Y
		translate([-cow/2, -h_w-h_d/2+ulbs, z])
		mirror([1,0,0])
		raised_tab(depth, h_w, h_len);

		translate([-cow/2, h_d/2+ulbs, z])
		mirror([1,0,0])
		raised_tab(depth, h_w, h_len);

		// Right edge — tab extends in +X; width spans along Y
		translate([cow/2, -h_w-h_d/2+ulbs, z])
		raised_tab(depth, h_w, h_len);

		translate([cow/2, h_d/2+ulbs, z])
		raised_tab(depth, h_w, h_len);
	}

	if (vert_rt) {
		// Bottom edge — tab extends in -Y; width spans along X
		// rotate([0,0,-90]) maps +X→-Y so the ramp faces outward
		translate([-v_d/2-v_w+ulos, -coh/2, z])
		rotate([0,0,-90])
		raised_tab(depth, v_w, v_len);

		translate([v_d/2+ulos, -coh/2, z])
		rotate([0,0,-90])
		raised_tab(depth, v_w, v_len);

		// Top edge — tab extends in +Y; width spans along X
		// rotate([0,0,90]) maps +X→+Y so the ramp faces outward
		translate([-v_d/2-v_w+ulos, coh/2, z])
		rotate([0,0,90])
		mirror([0,1,0])
		raised_tab(depth, v_w, v_len);

		translate([v_d/2+ulos, coh/2, z])
		rotate([0,0,90])
		mirror([0,1,0])
		raised_tab(depth, v_w, v_len);
	}
}

// Builds a single raised tab with a ramped approach and flat gripping tread that
// hooks over the case edge. Optionally includes a magnet recess.
// @param depth      Keyguard thickness in mm; controls available ramp height
// @param tab_width  Width of the tab in mm (dimension along the case edge)
// @param tab_length Length of the tab in mm (dimension projecting from the case edge)
module raised_tab(depth, tab_width, tab_length){
	a = tab_length;
	b = raised_tab_height;
	s = (raised_tabs_starting_height < depth - 1) ? raised_tabs_starting_height : depth - 1;
	angle = ramp_angle;
	e = min((depth-s+1)*cos(angle),preferred_raised_tab_thickness);
	r_h = a * tan(angle);
		
	// magnet variables
	ml = (magnet_size=="20 x 8 x 1.5") ? 20 : 
		 (magnet_size=="40 x 10 x 2") ? 40 : 
		 0;
		 
	mw = (magnet_size=="20 x 8 x 1.5") ? 8 : 
		 (magnet_size=="40 x 10 x 2") ? 10 : 
		 0;

	mh = (magnet_size=="20 x 8 x 1.5") ? 1.5 : 
		 (magnet_size=="40 x 10 x 2") ? 2 : 
		 0;
		 
	th1 = (embed_magnets=="no") ? e : max(e, mh+1);

	if (r_h > b){  //tread exists
		f = (sin(angle)!=0) ? (b-s)/sin(angle) : a;
		h1 = (b-s)/tan(angle);

		tangle = 90-(180-angle)/2;
		x = sin(tangle)*e;
		g = a - h1 + x;
		r = f + x;
		
		difference(){
			union(){
				difference(){
					rotate([0,-angle,0])
					translate([-2,0,0])
					cube([r+2,tab_width,e]);
				
					translate([-5,-ff,-5])
					cube([5,tab_width+2*ff,5]);
				}
					
				translate([h1-x-50*ff,0,b-s])
				difference(){
					union(){
						cube([g-2.5,tab_width,th1]);
						
						translate([g-2.5,2.5,0])
						cube([2.5,tab_width-5,th1]);
						
						translate([g-2.5,0,0])
						difference(){
							union(){
								translate([0,2.5,0])
								cylinder(h=th1,r=2.5);
								
								translate([0,tab_width-2.5,0])
								cylinder(h=th1,r=2.5);
							}
							translate([-6,-ff,-ff])
							cube([6,tab_width+2*ff,th1+2*ff]);
						}
					}
			
					translate([g+ff,0,th1/2])
					rotate([0,-45,0])
					cube([th1,tab_width,th1]);
				}
			}
			
			if(embed_magnets=="yes"){
				translate([h1-x+2,(tab_width-ml)/2,b-s+.4])
				union(){
					cube([mw,ml+(tab_width-ml)/2+1,mh]);
					#cube([mw,ml,mh]);
				}
			}
			
			translate([-6,-ff,depth-s])
			cube([5,tab_width+2*ff,5]);
			
			translate([0,-ff,e])
			rotate([0,-ramp_angle,0])
			translate([-5,0,0])
			cube([r+10,tab_width+2*ff,3]);
		}
	}
	else{ // tread doesn't exist
		h1 = a;
		f = h1/cos(angle);
		
		difference(){
			rotate([0,-angle,0])
			difference(){
				union(){
					translate([-2,0,0])
					cube([f+2-2.5,tab_width,th1+1]);
					
					translate([f-2.5,2.5,0])
					cube([2.5,tab_width-5,th1+1]);
					
					translate([f-2.5,2.5,0])
					cylinder(h=th1+1,r=2.5);
				
					translate([f-2.5,tab_width-2.5,0])
					cylinder(h=th1+1,r=2.5);
				}
				
				translate([f+ff,0,(th1+1)/2])
				rotate([0,-45,0])
				cube([th1+1,tab_width,th1+1]);

				translate([-th1-1+2-ff,-ff,depth/2])
				rotate([0,-45,0])
				cube([th1+1,tab_width+2*ff,th1+1]);
				

				if(embed_magnets=="yes"){
					translate([2,(tab_width-ml)/2,.6])
					union(){
						cube([mw+.5,ml+(tab_width-ml)/2-.5,mh+.5]);
						#cube([mw+.5,ml,mh+.5]);
						translate([(mw-1)/2,0,0])
						cube([1,ml+(tab_width-ml)/2+1,mh+.5]);
					}
				}
			}
			
			translate([-5,-ff,-5])
			cube([5,tab_width+2*ff,5]);
			
			translate([-5-1.25,-ff,depth/2-.5])
			cube([5,tab_width+2*ff,5]);
		}
	}
}

// Creates a quarter-cylinder wedge used to cut outer-arc (oa) corners in keyguard
// openings, with optional chamfering on the outer edge for 3D-printed keyguards.
// @param rotation     Z-axis rotation in degrees to position the wedge at the correct corner
// @param diameter     Diameter of the arc in mm
// @param thickness    Keyguard thickness in mm
// @param slope        Slope angle in degrees for the chamfer/taper
// @param type         "oa" applies outer-arc chamfer; any other value omits it
// @param edge_chamfer Chamfer depth in mm — pass cec for screen-region arcs,
//                     kec for case-region arcs (default 0.6 preserves legacy behaviour)
module create_cutting_tool(rotation,diameter,thickness,slope,type,edge_chamfer=0.6){
	rotate([0,0,rotation])
	difference(){
		translate([0,0,-thickness/2-ff/2])
		cube(size=[diameter/2+ff*2,diameter/2+ff*2,thickness+ff]);
		intersection(){
			cylinder(h=thickness+ff*4,r1=diameter/2,r2=diameter/2-(thickness/tan(slope)),center=true);
			if (type=="oa" && is_3d_printed){ //outer arcs are chamfered
				chamfer_circle_radius1 = diameter/2+(tan(45)*(thickness-edge_chamfer)); // bottom radius
				chamfer_circle_radius2 = diameter/2 - edge_chamfer;                    // top radius
				cylinder(h=thickness+ff*2,r1=chamfer_circle_radius1,r2=chamfer_circle_radius2,center=true);
			}
		}
	}
}

// Creates the 2D quarter-circle wedge profile used for outer-arc corner cuts in
// laser-cut keyguard outlines.
// @param rotation  Z-axis rotation in degrees to position the wedge at the correct corner
// @param diameter  Diameter of the arc in mm
module create_cutting_tool_2d(rotation,diameter){
	rotate([0,0,rotation])
	difference(){
		translate([0,0])
		square([diameter/2+ff*2,diameter/2+ff*2]);

		circle(r=diameter/2);
	}
}

// Cuts the home button and camera openings from the keyguard at the positions
// defined by the selected tablet's built-in dimension data.
// @param depth  Cutting depth in mm; pass 0 for laser-cut (2D) output
module home_camera(depth){
	// Home button: square -> "c" (circle); rectangular -> "hd" (pill).
	// Anchor "c" centres the shape at the translate origin. Locations 2 and 4 slope
	// the top and bottom edges; locations 1 and 3 slope the left and right edges.
	// type="tablet" selects keyguard_edge_chamfer (kec) at the cut face, matching
	// cut_als_openings and the rest of the tablet-body cuts.
	if (home_button_location!=0 && expose_home_button=="yes" && home_button_height > 0 && home_button_width > 0){
		hb_square = (home_button_height == home_button_width);
		hb_tb = (home_button_location==2 || home_button_location==4) ? hbes : 90;
		hb_lr = (home_button_location==2 || home_button_location==4) ? 90   : hbes;

		translate([home_x_loc, home_y_loc, 0])
		cut_opening_v2(home_button_width, home_button_height,
			hb_square ? "c" : "hd", "c", "T",
			hb_tb, hb_tb, hb_lr, hb_lr, 0, undef, depth, "tablet");
	}
	// Camera: square -> "c" (cut_opening's "c" laser-cut branch already inflates by
	// sat_incl_acrylic/tan(top_slope), which equals camera_offset_acrylic when
	// top_slope==camera_cut_angle). Rectangular -> "hd"; cut_opening's "hd" laser-cut
	// branch does not inflate, so pre-inflate the dimensions here to preserve the
	// original camera_offset_acrylic clearance for the camera lens cone of vision.
	if (camera_location!=0 && expose_camera=="yes" && camera_height > 0 && camera_width > 0){
		cm_square = (camera_height == camera_width);
		coa = camera_offset_acrylic; // 0 in 3D mode; sat_incl_acrylic/tan(camera_cut_angle) for laser-cut
		rect_laser = !is_3d_printed && !cm_square;
		cw = rect_laser ? camera_width  + coa*2 : camera_width;
		ch = rect_laser ? camera_height + coa*2 : camera_height;
		sl = (is_3d_printed) ? camera_cut_angle : 90;

		translate([cam_x_loc, cam_y_loc, 0])
		cut_opening_v2(cw, ch, cm_square ? "c" : "hd", "c", "T",
			camera_cut_angle, sl, sl, sl, 0, undef, depth, "tablet");
	}
}

// Dispatches to the appropriate mounting-point cutting module (suction cups, velcro
// recesses, screw-on strap slots, or clip-on strap grooves) based on the current
// mounting method parameter.
module mounting_points(){
	if (m_m=="Suction Cups"){
		suction_cups();
	}
	else if (m_m=="Velcro"){
		velcro();
	}
	else if (m_m=="Screw-on Straps"){
		screw_on_straps();
	}
	else if (m_m=="Clip-on Straps" && !no_clips){
		clip_on_straps_groove();
	}
	else {
		//No Mount option
	}
}

// Cuts four pairs of suction-cup mounting holes (outer recess and inner bore)
// into the border region of the keyguard, plus four retainer-clip slots cut
// partway into the top surface. Routes through cut_opening_v2 — circles are
// shape "c" anchored at centre; the retainer slots are shape "r" anchored at
// centre with the "other" parameter giving the cut depth from the top face.
// Refactor side-effect: the kec edge chamfer (1mm default) now applies to
// every cut here. Previously these were raw cylinder()/cube() with sharp edges.
module suction_cups(){
	major_dim = max(tablet_width,tablet_height);
	x_l = -major_dim/2 + left_border_width/2;
	x_r =  major_dim/2 - right_border_width/2;
	slot_dep = kt - 2; // retainer slot cuts kt-2 mm from the top face, preserving a 2 mm floor

	for (xp = [x_l, x_r]) {
		// Outer suction-cup recess + inner bore at each of the four border positions.
		for (yc = [40, -40]) {
			translate([xp, yc, 0])
			cut_opening_v2(7.5, 7.5, "c", "c", "t", 90,90,90,90, 0, undef, kt, "keyguard");

			// Inner bore is offset toward the keyguard interior — +5 (toward 0) on the
			// upper position, -5 (toward 0) on the lower one.
			y_inner = (yc > 0) ? yc - 5 : yc + 5;
			translate([xp, y_inner, 0])
			cut_opening_v2(4.5, 4.5, "c", "c", "t", 90,90,90,90, 0, undef, kt, "keyguard");
		}
		// Retainer-clip slots: 10×15 partial-depth pockets straddling each border position.
		// y centres at 38 (upper) and -38 (lower) match the original 30.5+15/2 / -45.5+15/2 math.
		for (yc = [38, -38])
			translate([xp, yc, 0])
			cut_opening_v2(10, 15, "r", "c", "t", 90,90,90,90, 0, slot_dep, kt, "keyguard");
	}
}

// Cuts four shallow recesses on the bottom surface of the keyguard border to
// accept round or square velcro pads for mounting. Routes through cut_opening_v2
// with a negative "other" value (1.75 mm cut from the bottom face — matches the
// original cube/cylinder geometry which extended 0.75 mm below the keyguard but
// only 1.75 mm into the keyguard material).
// Refactor side-effect: adds the kec edge chamfer at the cut face.
module velcro(){
	major_dim = max(tablet_width,tablet_height);
	if (m_m=="Velcro"){
		shape = (velcro_size<=3) ? "c" : "r";
		x_l = -major_dim/2 + velcro_diameter/2 + 2;
		x_r =  major_dim/2 - velcro_diameter/2 - 2;
		for (xp = [x_l, x_r])
			for (yp = [30, -30])
				translate([xp, yp, 0])
				cut_opening_v2(velcro_diameter, velcro_diameter, shape, "c", "t", 90,90,90,90, 0, -1.75, kt, "keyguard");
	}
}

// Cuts the slots and flange bores for Keyguard AT-style screw-on acrylic strap tabs
// into the keyguard border, supporting both full-depth and partial-depth cuts.
// Screw holes and rectangular slots route through cut_opening_v2; the triangular
// flange bores ($fn=3 cylinders) stay as direct primitives — they accommodate
// specific hardware geometry with no V2 shape equivalent.
// Refactor side-effect: kec edge chamfer now applies to the screw holes and slots.
module screw_on_straps(){
	major_dim = max(tablet_width,tablet_height);
	slot_dep = kt - strap_cut_to_depth; // partial-depth slot cut from top

	if (strap_cut_to_depth<kt) {  // slot + flange bores for Keyguard AT's acrylic tabs
		// Slot rectangle centres: x at (major_dim/2 - 5), y at ±40. Slot is 12 wide × 11 tall.
		for (xp = [-major_dim/2 + 5, major_dim/2 - 5])
			for (yp = [40, -40])
				translate([xp, yp, 0])
				cut_opening_v2(12, 11, "r", "c", "t", 90,90,90,90, 0, slot_dep, kt, "keyguard");

		// Triangular flange bores ($fn=3) — kept as raw primitives. Inner-edge cylinders
		// at x = -major_dim/2-1 (left) and x = major_dim/2 (right, rotated 180°);
		// each pair sits 11 mm apart in y, straddling y = ±40.
		for (yp = [34.5, 45.5]) {
			translate([-major_dim/2-1, yp,    -kt/2+strap_cut_to_depth]) cylinder(h=kt, d=7, $fn=3);
			translate([-major_dim/2-1,-yp,    -kt/2+strap_cut_to_depth]) cylinder(h=kt, d=7, $fn=3);
			translate([ major_dim/2,   yp,    -kt/2+strap_cut_to_depth]) rotate([0,0,180]) cylinder(h=kt, d=7, $fn=3);
			translate([ major_dim/2,  -yp,    -kt/2+strap_cut_to_depth]) rotate([0,0,180]) cylinder(h=kt, d=7, $fn=3);
		}
	}
	// Screw through-holes at the four corners of the border.
	for (xp = [-major_dim/2 + 5.5, major_dim/2 - 5.5])
		for (yp = [40, -40])
			translate([xp, yp, 0])
			cut_opening_v2(6, 6, "c", "c", "t", 90,90,90,90, 0, undef, kt, "keyguard");
}

// Cuts the wedge-shaped grooves on the edges of the keyguard that clip-on strap
// clips hook into, for horizontal and/or vertical clip locations.
module clip_on_straps_groove(){
	xloc = (add_sloped_keyguard_edge=="no") ? cow :
	       (extend_lip_to_edge_of_case=="no") ? cow + hsew*2-2 : case_width-2;
	yloc = (add_sloped_keyguard_edge=="no") ? coh :
	       (extend_lip_to_edge_of_case=="no") ? coh + vsew*2-2 : case_height-2;
	
	w1 = (!has_case) ? tablet_width :xloc;
	h1 = (!has_case) ? tablet_height : yloc;
	x0 = -w1/2;
	y0 = -h1/2;
	
	if(clip_locations=="horizontal only" || clip_locations =="horizontal and vertical"){
		translate([x0+groove_setback, -distance_between_horizontal_clips/2+ulbs, vertical_offset])
		rotate([90,0,0])
		linear_extrude(height = horizontal_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);

		translate([x0+groove_setback, distance_between_horizontal_clips/2+horizontal_slot_width+ulbs, vertical_offset])
		rotate([90,0,0])
		linear_extrude(height = horizontal_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);

		translate([-x0-(groove_setback+groove_slot_width), -distance_between_horizontal_clips/2+ulbs, vertical_offset])
		rotate([90,0,0])
		linear_extrude(height = horizontal_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width-groove_slant,groove_depth],[-groove_slant,groove_depth]]);

		translate([-x0-(groove_setback+groove_slot_width), distance_between_horizontal_clips/2+horizontal_slot_width+ulbs, vertical_offset])
		rotate([90,0,0])
		linear_extrude(height = horizontal_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width-groove_slant,groove_depth],[-groove_slant,groove_depth]]);
	}

	if(clip_locations=="vertical only" || clip_locations =="horizontal and vertical"){
		translate([-distance_between_vertical_clips/2-vertical_slot_width+ulos, y0+groove_setback,  vertical_offset])
		rotate([90,0,90])
		linear_extrude(height = vertical_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);

		translate([distance_between_vertical_clips/2+ulos, y0+groove_setback,  vertical_offset])
		rotate([90,0,90])
		linear_extrude(height = vertical_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);

		translate([-distance_between_vertical_clips/2+ulos, -y0-groove_setback,  vertical_offset])
		rotate([90,0,-90])
		linear_extrude(height = vertical_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);

		translate([distance_between_vertical_clips/2 + vertical_slot_width+ulos, -y0-groove_setback,  vertical_offset])
		rotate([90,0,-90])
		linear_extrude(height = vertical_slot_width)
		polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
	}
}

// Cuts the status bar, message bar, and command bar openings (upper and lower) through
// the keyguard at their configured heights and positions. Each bar is a centred
// rounded rectangle ("r" + anchor "c") cut in the screen region; type="screen"
// places the cut at the top of the keyguard (sat/2 - kt/2) and applies cell_edge_chamfer.
// @param depth  Cutting depth in mm; pass 0 for laser-cut (2D) output
module bars(depth){
	if (expose_status_bar=="yes" && expose_upper_message_bar=="no" && expose_upper_command_bar=="no" && sbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm+sbh_adjust/2,0])
		cut_opening_v2(bar_width,sbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}
	if (expose_status_bar=="yes" && expose_upper_message_bar=="yes" && expose_upper_command_bar=="no" && sbh_adjust+umbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm+(max(sbh_adjust,0)+umbh_adjust)/2,0])
		cut_opening_v2(bar_width,max(sbh_adjust,0)+umbh_adjust+ff,"r","c","T",90,bar_edge_slope_inc_acrylic,90,90,bcr,undef,depth,"screen");
	}

	if (expose_status_bar=="no" && expose_upper_message_bar=="yes" && expose_upper_command_bar=="yes" && umbh_adjust+ucbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm-ucbhm+(max(umbh_adjust,0)+ucbh_adjust)/2,0])
		cut_opening_v2(bar_width,max(umbh_adjust+ff,0)+ucbh_adjust,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}

	if (expose_status_bar=="yes" && expose_upper_message_bar=="yes" && expose_upper_command_bar=="yes" && sbh_adjust+umbh_adjust+ucbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm-ucbhm+(max(sbh_adjust,0)+max(umbh_adjust,0)+ucbh_adjust)/2,0])
		cut_opening_v2(bar_width,max(sbh_adjust,0)+max(umbh_adjust,0)+ucbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}

	if (expose_status_bar=="no" && expose_upper_message_bar=="yes" && expose_upper_command_bar=="no" && umbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm+(umbh_adjust)/2,0])
		cut_opening_v2(bar_width,umbh_adjust+ff,"r","c","T",90,bar_edge_slope_inc_acrylic,90,90,bcr,undef,depth,"screen");
	}

	if (expose_status_bar=="no" && expose_upper_message_bar=="no" && expose_upper_command_bar=="yes" && ucbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm-ucbhm+(ucbh_adjust)/2,0])
		cut_opening_v2(bar_width,ucbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}

	if (expose_status_bar=="yes" && expose_upper_message_bar=="no" && umbhm>0 && expose_upper_command_bar=="yes" && sbh_adjust+ucbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm+sbh_adjust/2,0])
		cut_opening_v2(bar_width,sbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");

		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm-ucbhm+(ucbh_adjust)/2,0])
		cut_opening_v2(bar_width,ucbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}

	if (expose_status_bar=="yes" && expose_upper_message_bar=="no" && umbhm==0 && expose_upper_command_bar=="yes" && sbh_adjust+ucbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,shm/2-sbhm+sbh_adjust/2,0])
		cut_opening_v2(bar_width,sbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");

		translate([adj_lec/2-adj_rec/2,shm/2-sbhm-umbhm-ucbhm+(ucbh_adjust)/2+bcr,0])
		cut_opening_v2(bar_width,ucbh_adjust+bcr*2+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}

	if (expose_lower_message_bar=="yes" && expose_lower_command_bar=="no" && lmbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,-shm/2+lmbh_adjust/2+max(lcbh_adjust,0)+adj_bec,0])
		cut_opening_v2(bar_width,lmbh_adjust+ff,"r","c","T",90,bar_edge_slope_inc_acrylic,90,90,bcr,undef,depth,"screen");
	}

	if (expose_lower_message_bar=="no" && expose_lower_command_bar=="yes" && lcbh_adjust>0){
		translate([adj_lec/2-adj_rec/2,-shm/2+lcbhm/2+adj_bec/2,0])
		cut_opening_v2(bar_width,lcbh_adjust+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}

	if (expose_lower_message_bar=="yes" && expose_lower_command_bar=="yes" && (lmbh_adjust+max(lcbh_adjust,0))>0){
		translate([adj_lec/2-adj_rec/2,-shm/2+(lmbh_adjust+max(lcbh_adjust,0))/2+adj_bec,0])
		cut_opening_v2(bar_width,lmbh_adjust+max(lcbh_adjust,0)+ff,"r","c","T",90,90,90,90,bcr,undef,depth,"screen");
	}
}

// Generates grid cell openings clipped to the adjusted grid boundary, trimming
// any cells that extend outside the configured grid area. Cells now produce their
// cuts at the screen-area z via cut_opening_v2(type="screen"); the clipping cube
// is made deliberately tall (kt+100) so the clip is z-invariant, and the
// grid-hole tool routes through cut_opening_v2(type="screen") to match the cell
// frame.
// @param depth  Cutting depth in mm; pass 0 for laser-cut (2D) output
module bounded_cells(depth){
	adj_grid_width = grid_width-col_first_trim-col_last_trim;
	adj_grid_height = grid_height-row_first_trim-row_last_trim;

	difference(){
		cells(depth);
		difference(){
			translate([grid_x0-20,grid_y0-20,-kt/2-50])
			cube([grid_width+40,grid_height+40,kt+100]);

			translate([grid_x0+col_first_trim+adj_grid_width/2, grid_y0+row_first_trim+adj_grid_height/2,0])
			cut_opening_v2(adj_grid_width, adj_grid_height, "r", "c", "t", 90,90,90,90, ocr, undef, depth+4*ff, "screen");
		}
	}
}

// Iterates over every cell in the grid and cuts the appropriate opening, handling
// merged cells (horizontal and vertical), covered cells, and both rectangular and
// circular cell shapes.
// @param depth  Cutting depth in mm; pass 0 for laser-cut (2D) output
module cells(depth){
	d = (depth > 0) ? depth+2*ff : 0;
	grid_part_w = grid_width/number_of_columns;
	grid_part_h = grid_height/number_of_rows;

	cwid = (cell_shape=="rectangular") ? cw : cell_diameter;
	chei = (cell_shape=="rectangular") ? ch : cell_diameter;

	for (i = [0:row_count-1]){
		for (j = [0:column_count-1]){
			current_cell = j+1+i*column_count;
			cell_x = grid_x0 + j*grid_part_w + grid_part_w/2;
			cell_y = grid_y0 + i*grid_part_h + grid_part_h/2;

			c__x = (j==0 && column_count>1) ? cell_x + col_first_trim/2 :
				  (j==column_count-1 && column_count > 1) ? cell_x - col_last_trim/2 :
				  (column_count==1) ? cell_x + col_first_trim/2 - col_last_trim/2 :
				   cell_x;
			c__y = (i==0 && row_count>1) ? cell_y + row_first_trim/2 :
				  (i==row_count-1 && row_count>1) ? cell_y - row_last_trim/2 :
				  (row_count==1) ? cell_y + row_first_trim/2 - row_last_trim/2 :
				   cell_y;
			c__w = (j==0 && column_count>1) ? cwid - col_first_trim :
				  (j==column_count-1 && column_count > 1) ? cwid - col_last_trim :
				  (column_count==1) ? cwid - col_first_trim - col_last_trim :
				  cwid;
			c__h = (i==0 && i!=row_count-1) ? chei - row_first_trim :
				  (i!=0 && i==row_count-1) ? chei - row_last_trim :
				  (i==0 && i==row_count-1) ? chei - row_first_trim - row_last_trim :
				  chei;
			mrr = (cell_shape=="rectangular") ? ocr : cell_diameter/2;

			// ignore if this cell is covered
			if (!search(current_cell,c_t_c)){
				// if cell is merged horizontally and rectangular
				if ((search(current_cell,m_cell_h))&&(j!=column_count-1)){
					translate([c__x+grid_part_w/2,c__y,0])
					cut_opening_v2(grid_part_w, c__h, "r","c","t", cts,cbs,rs_inc_acrylic,rs_inc_acrylic, 0, undef, d, "screen");
				}
				// if cell is merged vertically and rectangular
				if((search(current_cell,m_c_v))&&(i!=row_count-1)){
					translate([c__x, c__y+grid_part_h/2, 0])
					cut_opening_v2(c__w, grid_part_h, "r","c","t", cts,cbs,rs_inc_acrylic,rs_inc_acrylic, 0, undef, d, "screen");
				}

				//clean up center pyramid if a cell is in both horizontal and vertical merge and next cell is also in the vertical merge and the cell above is in the horizontal merge
				if((search(current_cell,m_cell_h))&&(search(current_cell,m_c_v))&&(search(current_cell+1,m_c_v))&&(search(current_cell+number_of_columns,m_cell_h))){
					translate([c__x+grid_part_w/2, c__y+grid_part_h/2, 0])
					cut_opening_v2(grid_part_w, grid_part_h, "r","c","t", cts,cbs,rs_inc_acrylic,rs_inc_acrylic, 0, undef, d, "screen");
				}

				//basic, no-merge cell cut these two statements will have no impact if cell has been merged, cell can be any shape
				translate([c__x,c__y,0])
				if (cell_shape=="rectangular"){
					cut_opening_v2(c__w+ff,c__h+ff, "r","c","t", cts,cbs,rs_inc_acrylic,rs_inc_acrylic, ocr, undef, d, "screen");
				}
				else{
					cut_opening_v2(cell_diameter,cell_diameter, "c","c","t", cts,cbs,rs_inc_acrylic,rs_inc_acrylic, 0, undef, d, "screen");
				}

				// Outer-arc cuts at the inner concave corners produced by L-shaped merges.
				// Routes through cut_opening_v2 so the chamfer matches cell_edge_chamfer
				// automatically. cut_opening's oa1-4 branches apply their own (+/-r, +/-r)
				// internal offset, so the (x,y) here is the cell's geometric corner
				// (not corner + mrr as the previous direct create_cutting_tool calls used).
				if (mrr > 0){
					// Config 1: same cell starts H-right and V-up — corner at top-right -> oa3
					if((search(current_cell,m_cell_h))&&(j!=column_count-1)&&
						(search(current_cell,m_c_v))&&(i!=row_count-1)&&
						!((search(current_cell+1,m_c_v))&&(search(current_cell+number_of_columns,m_cell_h)))){
						translate([c__x+c__w/2, c__y+c__h/2, 0])
						cut_opening_v2(0,0, "oa3", undef,undef, cts,0,0,0, mrr, undef, d, "screen");
					}
					// Config 2: current starts H-right, cell below starts V-up — corner at bottom-right -> oa4
					if((search(current_cell,m_cell_h))&&(j!=column_count-1)&&
						(i!=0)&&(search(current_cell-number_of_columns,m_c_v))&&
						!((search(current_cell-number_of_columns,m_cell_h))&&(search(current_cell+1-number_of_columns,m_c_v)))){
						translate([c__x+c__w/2, c__y-c__h/2, 0])
						cut_opening_v2(0,0, "oa4", undef,undef, cts,0,0,0, mrr, undef, d, "screen");
					}
					// Config 3: left neighbour starts H-right to current; current starts V-up — corner at top-left -> oa2
					if((search(current_cell,m_c_v))&&(i!=row_count-1)&&
						(j!=0)&&(search(current_cell-1,m_cell_h))&&
						!((search(current_cell-1,m_c_v))&&(search(current_cell-1+number_of_columns,m_cell_h)))){
						translate([c__x-c__w/2, c__y+c__h/2, 0])
						cut_opening_v2(0,0, "oa2", undef,undef, cts,0,0,0, mrr, undef, d, "screen");
					}
					// Config 4: left neighbour starts H-right; cell below starts V-up — corner at bottom-left -> oa1
					if((j!=0)&&(search(current_cell-1,m_cell_h))&&
						(i!=0)&&(search(current_cell-number_of_columns,m_c_v))&&
						!((search(current_cell-1-number_of_columns,m_cell_h))&&(search(current_cell-1-number_of_columns,m_c_v)))){
						translate([c__x-c__w/2, c__y-c__h/2, 0])
						cut_opening_v2(0,0, "oa1", undef,undef, cts,0,0,0, mrr, undef, d, "screen");
					}
				}
			}
		}
	}
}

// Adds tactile ridges around the specified grid cells, using either a rounded-rectangle
// wall or a circular wall depending on the cell shape.
module cell_ridges(){
	grid_part_w = grid_width/number_of_columns;
	grid_part_h = grid_height/number_of_rows;
	
	cwid = (cell_shape=="rectangular") ? cw : cell_diameter;
	chei = (cell_shape=="rectangular") ? ch : cell_diameter;

	for (i = [0:row_count-1]){
		for (j = [0:column_count-1]){
			current_cell = j+1+i*column_count;
			cell_x = grid_x0 + j*grid_part_w + grid_part_w/2;
			cell_y = grid_y0 + i*grid_part_h + grid_part_h/2;

			c__x = (j==0 && column_count>1) ? cell_x + col_first_trim/2 : 
				  (j==column_count-1 && column_count > 1) ? cell_x - col_last_trim/2 :
				  (column_count==1) ? cell_x + col_first_trim/2 - col_last_trim/2 :
				   cell_x;
			c__y = (i==0 && row_count>1) ? cell_y + row_first_trim/2 : 
				  (i==row_count-1 && row_count>1) ? cell_y - row_last_trim/2 :
				  (row_count==1) ? cell_y + row_first_trim/2 - row_last_trim/2 :
				   cell_y;
			c__w = (j==0 && column_count>1) ? cwid - col_first_trim :
				  (j==column_count-1 && column_count > 1) ? cwid - col_last_trim :
				  (column_count==1) ? cwid - col_first_trim - col_last_trim :
				  cwid;
			c__h = (i==0 && i!=row_count-1) ? chei - row_first_trim :
				  (i!=0 && i==row_count-1) ? chei - row_last_trim :
				  (i==0 && i==row_count-1) ? chei - row_first_trim - row_last_trim :
				  chei;
		
			if (search(current_cell,a_r_a)){
				slope_adjust = sat/tan(rs_inc_acrylic);
				// Route through place_addition_v2 with rridge/cridge. The shape primitives
				// (rounded_rectangle_wall / circular_wall) have their polygon at z=[0,hgt2]
				// in local frame; place_addition_v2 adds an internal translate of [..., -sata]
				// and uses hgt2 = top_slope_mm + sata. To preserve the original wall extent
				// of z=[-kt/2, -kt/2+height_of_ridge+sat], the call-site translate is
				// [..., -kt/2+sata] and top_slope_mm = height_of_ridge + sat - sata.
				ridge_hgt = height_of_ridge + sat - sata;
				if (cell_shape=="rectangular"){
					rw = c__w + slope_adjust*2 - cell_edge_chamfer;
					rh = c__h + slope_adjust*2 - cell_edge_chamfer;
					translate([c__x - rw/2, c__y - rh/2, -kt/2 + sata])
					place_addition_v2(rw, rh, "rridge", height_of_ridge, ridge_hgt, thickness_of_ridge, thickness_of_ridge, 0, 0, ocr, undef);
				}
				else{
					cd = cell_diameter + slope_adjust*2 - cell_edge_chamfer;
					translate([c__x, c__y, -kt/2 + sata])
					place_addition_v2(0, cd, "cridge", height_of_ridge, ridge_hgt, thickness_of_ridge, thickness_of_ridge, 0, 0, 0, undef);
				}
			}
		}
	}
}

// Creates a hollow circular ring wall (annulus) of the specified inner diameter,
// wall thickness, and height, with a chamfered top edge.
// @param ID         Inner diameter of the ring in mm
// @param thickness  Wall thickness in mm
// @param hgt        Wall height in mm
module circular_wall(ID,thickness,hgt){
	rotate_extrude()
	polygon([[ID/2,0],[ID/2+thickness,0],[ID/2+thickness,hgt-.5],[ID/2+thickness-.5,hgt],[ID/2+.5,hgt],[ID/2,hgt-.5]]);
}

// Creates a hollow rounded-rectangle wall of given outer dimensions, corner radius,
// wall thickness, and height, by combining straight and corner wall segments.
// @param width          Outer width of the rectangle in mm
// @param hgt            Height of the rectangle (Y dimension) in mm
// @param corner_radius  Corner radius in mm
// @param thickness      Wall thickness in mm
// @param hgt2           Wall height (Z dimension) in mm
module rounded_rectangle_wall(width,hgt,corner_radius,thickness,hgt2){
	rr_wall1(width,hgt,corner_radius,thickness,hgt2);
	mirror([0,1,0])
	rr_wall1(width,hgt,corner_radius,thickness,hgt2);
	
	rr_wall2(width,hgt,corner_radius,thickness,hgt2);
	mirror([1,0,0])
	rr_wall2(width,hgt,corner_radius,thickness,hgt2);

	rr_corner_wall(width,hgt,corner_radius,thickness,hgt2);
	mirror([1,0,0])
	rr_corner_wall(width,hgt,corner_radius,thickness,hgt2);
	mirror([0,1,0])
	rr_corner_wall(width,hgt,corner_radius,thickness,hgt2);
	mirror([1,0,0])
	mirror([0,1,0])
	rr_corner_wall(width,hgt,corner_radius,thickness,hgt2);
}

// Generates the top straight segment of a rounded-rectangle wall (used by rounded_rectangle_wall).
// @param width          Outer width of the rectangle in mm
// @param hgt            Height of the rectangle (Y dimension) in mm
// @param corner_radius  Corner radius in mm
// @param thickness      Wall thickness in mm
// @param hgt2           Wall height (Z dimension) in mm
module rr_wall1(width,hgt,corner_radius,thickness,hgt2){
	translate([width/2-corner_radius,-hgt/2,0])
	rotate([0,0,-90])
	rotate([90,0,0])
	linear_extrude(height=width-corner_radius*2)
	polygon([[0,0],[thickness,0],[thickness,hgt2-.5],[thickness-.5,hgt2],[.5,hgt2],[0,hgt2-.5]]);
}

// Generates the left straight segment of a rounded-rectangle wall (used by rounded_rectangle_wall).
// @param width          Outer width of the rectangle in mm
// @param hgt            Height of the rectangle (Y dimension) in mm
// @param corner_radius  Corner radius in mm
// @param thickness      Wall thickness in mm
// @param hgt2           Wall height (Z dimension) in mm
module rr_wall2(width,hgt,corner_radius,thickness,hgt2){
	translate([-width/2-thickness,hgt/2-corner_radius,0])
	rotate([90,0,0])
	linear_extrude(height=hgt-corner_radius*2)
	polygon([[0,0],[thickness,0],[thickness,hgt2-.5],[thickness-.5,hgt2],[.5,hgt2],[0,hgt2-.5]]);
}

// Generates one 90-degree arc corner segment of a rounded-rectangle wall
// (used by rounded_rectangle_wall for the top-right quadrant; mirroring covers the rest).
// @param width          Outer width of the rectangle in mm
// @param hgt            Height of the rectangle (Y dimension) in mm
// @param corner_radius  Corner radius in mm
// @param thickness      Wall thickness in mm
// @param hgt2           Wall height (Z dimension) in mm
module rr_corner_wall(width,hgt,corner_radius,thickness,hgt2){
	translate([width/2-corner_radius,hgt/2-corner_radius,0])
	rotate_extrude(angle=90)
	translate([corner_radius,0,0])
	polygon([[0,0],[thickness,0],[thickness,hgt2-.5],[thickness-.5,hgt2],[.5,hgt2],[0,hgt2-.5]]);
}

// Primary opening cutter: cuts a tapered hole with per-side slope angles and an optional
// corner radius. For 3D-printed keyguards, adds an edge-chamfer layer on top.
// @param hole_width    Opening width in mm
// @param hole_height   Opening height in mm
// @param top_slope     Slope angle on the top edge in degrees (90 = vertical)
// @param bottom_slope  Slope angle on the bottom edge in degrees
// @param left_slope    Slope angle on the left edge in degrees
// @param right_slope   Slope angle on the right edge in degrees
// @param radius        Corner radius in mm (0 = sharp corners)
// @param depth         Cut depth in mm
// @param edge_chamfer  Chamfer depth in mm — pass cec for screen-region cuts,
//                      kec for case-region cuts (defaults to cec for all existing callers)
module hole_cutter(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,radius,depth,edge_chamfer=cec){
	d = (is_3d_printed) ? depth-edge_chamfer : depth;
	z = (is_3d_printed) ? -edge_chamfer/2 : 0;

	rad1=min(hole_width/2,hole_height/2,radius);

	if(depth>0 && edge_chamfer>0){
		translate([0,0,z])
		union(){
			if(d>0) cut(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,rad1,d);

			if (is_3d_printed){  // add edge chamfer to cutting tool
				l_s = (left_slope>=chamfer_angle_stop || left_slope<0) ? 45 : left_slope;
				r_s = (right_slope>=chamfer_angle_stop || right_slope<0) ? 45 : right_slope;
				t_s = (top_slope>=chamfer_angle_stop || top_slope<0) ? 45 : top_slope;
				b_s = (bottom_slope>=chamfer_angle_stop || bottom_slope<0) ? 45 : bottom_slope;

				left = d * tan(90-left_slope);
				right = d * tan(90-right_slope);
				top = d * tan(90-top_slope);
				bottom = d * tan(90-bottom_slope);
				w1 = hole_width+left+right;
				h1 = hole_height+top+bottom;

				m1 = min(hole_width,hole_height);
				m2 = min(w1,h1);

				rad = (radius>m1/2) ? m2/2 :
					((hole_width==hole_height && radius<hole_width/2) || (hole_width!=hole_height) && radius!=m1/2) ? radius : m2/2;

				radius2 = (radius==0) ? 0 : rad;

				translate([(right-left)/2,(top-bottom)/2,d/2+edge_chamfer/2])
				cut(w1,h1,t_s,b_s,l_s,r_s,radius2,edge_chamfer);
			}
		}
	}
	else{
		cut(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,radius,d);
	}
}

// Simplified opening cutter that delegates directly to cut() without adding a
// cell-edge chamfer layer. Used for openings that must not be chamfered (e.g. flipped cuts).
// @param hole_width    Opening width in mm
// @param hole_height   Opening height in mm
// @param top_slope     Slope angle on the top edge in degrees
// @param bottom_slope  Slope angle on the bottom edge in degrees
// @param left_slope    Slope angle on the left edge in degrees
// @param right_slope   Slope angle on the right edge in degrees
// @param radius        Corner radius in mm
// @param depth         Cut depth in mm
module hole_cutter_3(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,radius,depth){
	rad1=min(hole_width/2,hole_height/2,radius);
	cut(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,rad1,depth);
}

// Alternative opening cutter that places the chamfer layer below the main cut and
// adds a flush top cap; used for special opening types that need a different layer order.
// Applies only to 3D-printed keyguards.
// @param hole_width    Opening width in mm
// @param hole_height   Opening height in mm
// @param top_slope     Slope angle on the top edge in degrees
// @param bottom_slope  Slope angle on the bottom edge in degrees
// @param left_slope    Slope angle on the left edge in degrees
// @param right_slope   Slope angle on the right edge in degrees
// @param radius        Corner radius in mm
// @param depth         Cut depth in mm
module hole_cutter2(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,radius,depth){
	//applies only to 3D-printed keyguards
	l_s = (left_slope>=chamfer_angle_stop || left_slope<0) ? 45 : left_slope;
	r_s = (right_slope>=chamfer_angle_stop || right_slope<0) ? 45 : right_slope;
	t_s = (top_slope>=chamfer_angle_stop || top_slope<0) ? 45 : top_slope;
	b_s = (bottom_slope>=chamfer_angle_stop || bottom_slope<0) ? 45 : bottom_slope;
	
	left = depth * tan(90-left_slope);
	right = depth * tan(90-right_slope);
	top = depth * tan(90-top_slope);
	bottom = depth * tan(90-bottom_slope);
	w1 = hole_width+left+right;
	h1 = hole_height+top+bottom;
	
	m1 = min(hole_width,hole_height);
	m2 = min(w1,h1);
	
	rad = (radius>m1/2) ? m2/2 : 
		((hole_width==hole_height && radius<hole_width/2) || (hole_width!=hole_height) && radius!=m1/2) ? radius : m2/2;
	radius2 = (radius==0) ? 0 : rad;

	d = depth-cec;
	cec1 = (depth>cec) ? cec : depth;
	
	if(cec>0 && depth>0){
		translate([(right-left)/2,(top-bottom)/2,-cec1/2])
		cut(w1,h1,t_s,b_s,l_s,r_s,radius2,cec1);
	}
	
	if(d>0){
		translate([0,0,-d/2-cec])
		cut(hole_width,hole_height,top_slope,bottom_slope,left_slope,right_slope,radius,d);
	}
	
	translate([0,0,10-ff])
	cut(w1+cec1*tan(45)*2,h1+cec1*tan(45)*2,90,90,90,90,radius2,20);

}


// 2D opening cutter wrapper — delegates to cut_2d() for laser-cut keyguard profiles.
// @param hole_width   Opening width in mm
// @param hole_height  Opening height in mm
// @param radius       Corner radius in mm (0 = sharp corners)
module hole_cutter_2d(hole_width,hole_height,radius){
	cut_2d(hole_width,hole_height,radius);
}

// Produces a centred 2D rounded-rectangle profile.  When the corner radius is so
// large relative to the bounding box that the inner square would be near-zero
// (≤ 2·ff on a side), substitutes an ellipse to avoid degenerate CGAL geometry.
// @param w  Bounding-box width in mm
// @param h  Bounding-box height in mm
// @param r  Corner radius in mm (0 = sharp corners)
module rounded_rect(w, h, r) {
	sw = w - 2*r;
	sh = h - 2*r;
	if (r <= 0)
		square([w, h], center=true);
	else if (sw <= 2*ff && sh <= 2*ff)
		// Near-circular: substitute an ellipse to avoid a near-degenerate inner square
		scale([w/max(w,h), h/max(w,h)]) circle(r=max(w,h)/2);
	else
		offset(r=r) square([max(sw,ff), max(sh,ff)], center=true);
}

// Core geometry primitive: produces a tapered hull solid (or 2D shape when thick=0)
// centred at the origin, used by all hole_cutter variants.
// The top slab of the hull is centred at ((right-left)/2, (top-bottom)/2), which
// equals the original centre=false + complex-translate formulation.
// @param cut_w         Base width in mm
// @param cut_h         Base height in mm
// @param top_angle     Slope angle on the top face in degrees
// @param bottom_angle  Slope angle on the bottom face in degrees
// @param left_angle    Slope angle on the left face in degrees
// @param right_angle   Slope angle on the right face in degrees
// @param radius        Corner radius in mm
// @param thick         Extrusion thickness in mm (0 produces a 2D shape)
module cut(cut_w, cut_h, top_angle, bottom_angle, left_angle, right_angle, radius, thick){
	th1 = thick + 2*ff;

	radius1 = (radius==0) ? 0 : radius-ff;

	left = th1 * tan(90-left_angle);
	right = th1 * tan(90-right_angle);
	top = th1 * tan(90-top_angle);
	bottom = th1 * tan(90-bottom_angle);
	w1 = cut_w+left+right;
	h1 = cut_h+top+bottom;
	m1 = min(cut_w,cut_h);
	m2 = min(w1,h1);

	rad = (radius>m1/2) ? m2/2 :
		((cut_w==cut_h && radius<cut_w/2) || (cut_w!=cut_h) && radius!=m1/2) ? radius : m2/2;

	radius2 = (radius==0) ? 0 : rad-ff;

	if (thick > 0){
		translate([0,0,-th1/2-ff])
		hull(){
			linear_extrude(ff)
			rounded_rect(cut_w, cut_h, radius1);

			translate([(right-left)/2,(top-bottom)/2,th1])
			linear_extrude(ff)
			rounded_rect(w1, h1, radius2);
		}
	}
	else{
		rounded_rect(cut_w, cut_h, radius1);
	}
}


// Core 2D geometry primitive: produces a centred rounded-rectangle 2D shape used
// by hole_cutter_2d and other laser-cut profiling modules.
// @param cut_w   Width in mm
// @param cut_h   Height in mm
// @param radius  Corner radius in mm (0 = sharp corners)
module cut_2d(cut_w, cut_h, radius){
	radius1 = (radius==0) ? 0 : radius-ff;
	rounded_rect(cut_w, cut_h, radius1);
}


// Generates a standalone cell insert — a small 3D object that fits inside a grid
// cell opening and can carry Braille dots, engraved text, or a plain surface.
module create_cell_insert(){
	chamfer = .5;
	btod = Braille_to_opening_distance+1;
	comma_loc = search(",",Braille_text);
	word_one = (len(comma_loc)==0) ? Braille_text : 
				(Braille_text[0]== ",") ? "" : substr(Braille_text,0,comma_loc[0]);
	word_two = (len(comma_loc)==0) ? "" : substr(Braille_text,comma_loc[0]+1);
	binary_text_one = search(word_one,braille_a);
	binary_text_two = search(word_two,braille_a);

	roo = diameter_of_opening/2+2;

	// above below
	bh = bsm * 6.5; //braille height
	v = ch/2;

	BA = (Braille_location=="above opening" && e_t=="");
	BB = (Braille_location=="below opening" && e_t=="");
	BAB = (Braille_location=="above and below opening");
	BAE = (Braille_location=="above opening" && e_t!="");
	BBE = (Braille_location=="below opening" && e_t!="");

	elements_v = (BAB) ? bh*2+btod*2+roo*2 :
				 (BA || BB) ? bh+btod+roo*2 : 0;
	b_v = v-elements_v/2;

	z1 = (BA || BAB) ? v-bh/2-b_v :
		 (BB) ? -v+bh/2+b_v : 
		 (BBE) ? -v+(v-roo)/2 :
		 (BAE) ? v-(v-roo)/2 : 0;
		 
	z2 = (BAB) ? -v+b_v+bh/2 :
		 (BAE) ? -v+(v-roo)/2 :
		 (BBE) ? v-(v-roo)/2 : 0;
		 
	o_z = (BAB || BAE || BBE) ? 0 : 
		  (BA) ? -v+roo+b_v :
		  (BB) ? v-roo-b_v : 0;

	//left right
	hacw = cw/2;

	BL = (Braille_location=="left of opening" && e_t=="");
	BR = (Braille_location=="right of opening" && e_t=="");
	BLR = (Braille_location=="left and right of opening");
	BLE = (Braille_location=="left of opening" && e_t!="");
	BRE = (Braille_location=="right of opening" && e_t!="");

	braille_letters1 = len(word_one);
	braille_letters2 = len(word_two);
	base_braille_width1 = (braille_letters1 == 1) ? 4 : (braille_letters1-1)*6.1 + 4;
	base_braille_width2 = (braille_letters2 == 1) ? 4 : (braille_letters2-1)*6.1 + 4;
	w1 = bsm * base_braille_width1;
	w2 = bsm * base_braille_width2;

	elements_h = (BL || BR) ? w1+btod+roo*2 : 
				 (BLR) ? w1+w2+btod*2+roo*2 : 0;
				 
	b_h = hacw-elements_h/2;

	x1 = (BL || BLR) ? -hacw+b_h+w1/2 : 
		 (BR) ? hacw-b_h-w1/2 : 
		 (BLE) ? -hacw+(hacw-roo)/2 :
		 (BRE) ? hacw-(hacw-roo)/2 : 0;
				
	x2 = (BLR) ? hacw-b_h-w2/2 :
		 (BLE) ? hacw-(hacw-roo)/2 : 
		 (BRE) ? -hacw+(hacw-roo)/2 : 0;

	o_x = (BLE || BRE) ? 0 :
		  (BL) ? hacw-b_h-roo :
		  (BLR) ? -hacw+b_h+w1+btod+roo :
		  (BR) ? -hacw+b_h+roo : 0;
	
	s_f=insert_tightness_of_fit;
			
	if (BA || BB || BAB || BAE || BBE){
		difference(){
			rotate([90,0,0])
			if (cell_shape=="rectangular"){
				chamfered_shape(cw+s_f/2,insert_thickness,ch+s_f/2,chamfer,cell_corner_radius);
			}
			else{
				chamfered_shape(cw+s_f/2,insert_thickness,ch+s_f/2,chamfer,cell_corner_radius);
			}
			
			if(add_circular_opening=="yes"){
				translate([0,0,o_z])
				rotate([90,0,0])
				cylinder(r1=diameter_of_opening/2,r2=diameter_of_opening/2 + 2,h=insert_thickness+2,center=true);
			}
			
			if (BAE || BBE){
				translate([0,-.1,z2])
				add_engraved_text("center");
			}
		}

		translate([0,0,z1])
		if(word_one !="") add_braille(binary_text_one);
		
		if (BAB){			
			translate([0,0,z2])
			if(word_two !="") add_braille(binary_text_two);
		}
	}
	else {
		difference(){
			rotate([90,0,0])
			chamfered_shape(cw+s_f/2,insert_thickness,ch+s_f/2,chamfer,cell_corner_radius);
			
			if(add_circular_opening=="yes"){
				translate([o_x,0,0])
				rotate([90,0,0])
				cylinder(r1=diameter_of_opening/2,r2=diameter_of_opening/2 + 2,h=insert_thickness+2,center=true);
			}
			
			if (BLE || BRE){
				translate([x2,-.1,0])
				add_engraved_text("center");
			}
		}

		translate([x1,0,0])
		if(word_one !="") add_braille(binary_text_one);
		
		if (BLR){
			translate([x2,0,0])
			if(word_two !="") add_braille(binary_text_two);
		}

	}
	
	// // // if (Bliss_concept!=""){
		// // // Bliss_graphic();
	// // // }
	
}

// Iterates over the screen_openings vector and cuts (or highlights with #) each
// opening at the correct position relative to the screen coordinate origin.
// @param s_o    Screen openings vector (rows of opening definitions)
// @param depth  Cut depth in mm; pass 0 for 2D laser-cut output
module cut_screen_openings(s_o,depth){
	for(i = [0 : len(s_o)-1]){
		opening = s_o[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:top slope, 7:bottom slope, 8:left slope, 9:right slope, 10:corner_radius, 11:other
		opening_ID = opening[0];
		opening_x = opening[1];
		opening_y = opening[2];
		opening_width = (opening[3]==undef) ? 0 : opening[3];
		opening_height = opening[4];
		opening_shape = opening[5];
		opening_top_slope = (is_laser_cut || (opening[6]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[6];
		opening_bottom_slope = (is_laser_cut || (opening[7]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[7];
		opening_left_slope = (is_laser_cut || (opening[8]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[8];
		opening_right_slope = (is_laser_cut || (opening[9]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[9];
		opening_corner_radius = opening[10];
		opening_other = opening[11];
		opening_width_mm = (using_px) ? opening_width * mpp : opening_width;
		opening_height_mm = (using_px) ? opening_height * mpp : opening_height;
		opening_x_mm = (using_px) ? opening_x * mpp : opening_x;

		o_s = opening_shape;
		o_c_r = (o_s=="oa1" || o_s=="oa2" || o_s=="oa3" || o_s=="oa4") ? opening_corner_radius : min(opening_corner_radius,min(opening_width,opening_height)/2);
		opening_corner_radius_mm = (using_px) ? o_c_r * mpp : o_c_r;

		has_invalid_dims = (opening_width_mm < 0 || opening_height_mm < 0)
		                && o_s != "ridge" && o_s != "ttext" && o_s != "btext" && o_s != "svg";
		if (has_invalid_dims) {
			echo(str("WARNING: screen_openings entry '", opening_ID,
			         "' has negative dimensions (width=", opening_width_mm,
			         "mm, height=", opening_height_mm, "mm) — skipping."));
		}
		if (!has_invalid_dims) {
		if(depth>0){
			if(opening_ID!="#"){
				if (starting_corner_for_screen_measurements == "upper-left"){
					opening_y_mm = (using_px) ? (shp - opening_y) * mpp : (shm - opening_y);
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					cut_opening(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, opening_corner_radius_mm, opening_other,depth,"screen");
				}
				else{
					opening_y_mm = (using_px) ? opening_y * mpp : opening_y;
					
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					cut_opening(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, opening_corner_radius_mm, opening_other,depth,"screen");
				}
			}
			else{
				if (starting_corner_for_screen_measurements == "upper-left"){
					opening_y_mm = (using_px) ? (shp - opening_y) * mpp : (shm - opening_y);
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					#cut_opening(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, opening_corner_radius_mm, opening_other,depth,"screen");
				}
				else{
					opening_y_mm = (using_px) ? opening_y * mpp : opening_y;
					
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					#cut_opening(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, opening_corner_radius_mm, opening_other,depth,"screen");
				}
			}
		}
		else{
			if(opening_ID!="#"){
				if (starting_corner_for_screen_measurements == "upper-left"){
					opening_y_mm = (using_px) ? (shp - opening_y) * mpp : (shm - opening_y);
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					cut_opening_2d(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_corner_radius_mm);
				}
				else{
					opening_y_mm = (using_px) ? opening_y * mpp : opening_y;
					
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					cut_opening_2d(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_corner_radius_mm);
				}
			}
			else{
				if (starting_corner_for_screen_measurements == "upper-left"){
					opening_y_mm = (using_px) ? (shp - opening_y) * mpp : (shm - opening_y);
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					#cut_opening_2d(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_corner_radius_mm);
				}
				else{
					opening_y_mm = (using_px) ? opening_y * mpp : opening_y;
					
					translate([sx0+opening_x_mm,sy0+opening_y_mm,0])
					#cut_opening_2d(opening_width_mm, opening_height_mm, opening_shape, opening_top_slope, opening_corner_radius_mm);
				}
			}
		}
		} // end if (!has_invalid_dims)
	}
}

// =============================================================================
// V2 OPENINGS-FILE SUPPORT
//
// These helpers and modules support openings_and_additions.txt files that use
// the v2 data structure (identified by oa_version = 2 at the top of the file).
// V1 and V2 are independent processing paths. V2 modules process rows
// directly and call geometry modules without routing through V1 modules.
//
// V2 column layout — screen_openings / case_openings / tablet_openings:
//   [ID, shape, height, width, corner, x, y, cut/build, anchor, surface,
//    length, thickness, [edge_slopes], [special_parms]]
//    [0]  [1]    [2]    [3]    [4]    [5] [6]   [7]      [8]     [9]
//    [10]     [11]       [12]             [13]
//
// V2 column layout — case_additions:
//   [ID, shape, height, width, corner, x, y, cut/build, [trim]]
//    [0]  [1]    [2]    [3]    [4]    [5] [6]   [7]      [8]
//
// V1 equivalent column layout (for reference):
//   screen/case/tablet openings:
//     [ID, x, y, width, height, shape, top_slope, bottom_slope,
//      left_slope, right_slope, corner_radius, other]
//   case_additions:
//     [ID, x, y, width, height, shape, thickness,
//      trim_above, trim_below, trim_to_right, trim_to_left, corner_radius]
// =============================================================================

// Returns the raw slope value at index idx from a V2 [edge_slopes] array.
// When the array has fewer than 4 entries the first value is reused for all
// missing positions.  A value of 0 is mapped to 90 for ordinary shapes,
// matching the V1 normalisation rule (0 means "vertical / no slope").
// @param slopes  The [edge_slopes] sub-array from a V2 row
// @param idx     0 = top, 1 = bottom, 2 = left, 3 = right
// @param shape   V2 shape name (suppresses 0→90 for special shapes)
function v2_slope(slopes, idx, shape) =
	let(
		n   = (slopes == undef) ? 0 : len(slopes),
		raw = (n == 0)   ? 0 :
		      (n == 1)   ? slopes[0] :
		      (idx < n)  ? slopes[idx] : slopes[0],
		is_special = (shape == "svg"    || shape == "ridge"   || shape == "hridge"  ||
		              shape == "vridge" || shape == "cridge"  || shape == "rridge"  ||
		              shape == "hdridge"|| shape == "aridge1" || shape == "aridge2" ||
		              shape == "aridge3"|| shape == "aridge4" || shape == "text"    ||
		              shape == "bump")
	)
	(raw == 0 && !is_special) ? 90 : raw;

// Converts a V2 font-style string to the V1 numeric code expected by
// cut_opening() and place_addition():  "bold"→1, "italic"→2,
// "bold/italic"→3, anything else→0 (normal).
function v2_font_style_code(s) =
	(s == "bold")        ? 1 :
	(s == "italic")      ? 2 :
	(s == "bold/italic") ? 3 : 0;

// Converts a V2 horizontal-alignment string to the V1 numeric code:
// "left"→1, "center"→2, "right"→3; default→1.
function v2_h_align_code(s) =
	(s == "left")   ? 1 :
	(s == "center") ? 2 :
	(s == "right")  ? 3 : 1;

// Converts a V2 vertical-alignment string to the V1 numeric code:
// "bottom"→1, "baseline"→2, "center"→3, "top"→4; default→1.
function v2_v_align_code(s) =
	(s == "bottom")   ? 1 :
	(s == "baseline") ? 2 :
	(s == "center")   ? 3 :
	(s == "top")      ? 4 : 1;

// ---------------------------------------------------------------------------
// V2 explicit opening row format — 14 fixed columns, all fields mandatory:
//
//   [ID, shape, height, width, corner, x, y, cut | build, anchor, surface, length, thickness, [es], [sp]]
//   [0]  [1]    [2]     [3]    [4]    [5] [6]     [7]     [8]     [9]     [10]    [11]       [12]  [13]
//
//   ID         — string label; "#" enables OpenSCAD debug highlight
//   shape      — shape family name
//   height     — opening height (mm or px); diameter for "bump"; ridge_height for other ridges
//   width      — opening width; 0 for "bump"/"c"/"text"; ridge length for other ridges (use [10])
//   corner     — corner radius (0 = none); z_pos for "text"; rotation for "svg"; 0 for bump/vh/c/hd
//   x          — x position (all shapes use [5])
//   y          — y position (all shapes use [6])
//   cut | build— cb value; negative = cut to depth |cb|; positive = build/extrude solid of height cb; 0 = full depth cut; ridge_height for "vridge"/"hridge"
//   anchor     — "L"/"l" (left, default) or "C"/"c" (centre); supported for "r", "rr", "hd", "c", "cridge"; ignored for "oa1-4"
//   surface    — "T"/"t" (top, default) or "B"/"b" (bottom)
//   length     — ridge length for "vridge","hridge" and other ridges; 0 otherwise
//   thickness  — ridge base thickness for "vridge","hridge" and other ridges; 0 otherwise
//   [es]       — edge slopes [top,bot,left,right]; single value [n] applies to all edges for "oa" shapes
//   [sp]       — special params (text value, SVG filename, ridge direction, etc.)
//
// No parsing function — dispatch modules read columns directly and use
// if/else-if blocks per shape family, matching the V1 dispatch style.
// ---------------------------------------------------------------------------


// Parses a single V2 compact case_additions row.
//
// Supported shapes: r1-4, rr, tab1-4, cm1-4, t1-4, f1-4, oa1-4, ped1-4.
// Subtractive shapes use a negative cb value instead of a "-" shape name prefix.
// "c" and "r" are not supported in V2 case_additions; use r1-4 instead.
//
// Compact format (all fields explicit — no blank entries):
//   without cut | build: [ID, shape, height, width, corner, x, y,      [trim]]
//   with    cut | build: [ID, shape, height, width, corner, x, y, cb,  [trim]]
//
// cb is present when r[7] is a number. [trim] is always the last element.
// [trim] entries: [trim_above, trim_below, trim_to_right, trim_to_left].
// Missing trim entries default to -999 (no clipping on that edge).
//
// cb semantics:
//   cb > 0          add shape, extruded to this depth (mm)
//   cb = 0 or omitted  add shape, full keyguard height (2D outline addition)
//   -8.99 to -0.01  subtract shape, pocket to this depth (mm)
//   cb <= -9        subtract shape, full keyguard height (2D outline subtraction)
//                   (safe threshold: keyguards are never >= 9 mm thick)
//
// Returns: [ID, shape, height, width, corner, x, y, thickness, trim_above, trim_below, trim_right, trim_left, is_sub]
//   [0]     [1]   [2]    [3]    [4]   [5] [6]    [7]      [8]         [9]        [10]       [11]    [12]
//
// @param r  A single compact V2 case_additions row
function v2_parse_addition(r) =
	let(
		has_cb    = (len(r) >= 9 && is_num(r[7])),
		cb_raw    = has_cb ? r[7] : 0,
		is_2d_sub = (cb_raw <= -9),
		is_3d_sub = (cb_raw < 0 && !is_2d_sub),
		is_sub    = is_2d_sub || is_3d_sub,
		thickness = is_2d_sub ? 0 : is_3d_sub ? -cb_raw : cb_raw,
		trim_raw  = has_cb ? ((r[8] == undef) ? [] : r[8]) :
		                     (!is_num(r[7]) && r[7] != undef ? r[7] : []),
		ta = (len(trim_raw) >= 1) ? trim_raw[0] : -999,
		tb = (len(trim_raw) >= 2) ? trim_raw[1] : -999,
		tr = (len(trim_raw) >= 3) ? trim_raw[2] : -999,
		tl = (len(trim_raw) >= 4) ? trim_raw[3] : -999
	)
	let(
		is_oa     = (r[1] == "oa1" || r[1] == "oa2" || r[1] == "oa3" || r[1] == "oa4"),
		fin_thick = is_oa ? 0      : thickness,
		fin_sub   = is_oa ? true   : is_sub
	)
	[r[0], r[1], r[2], r[3], (r[4] == undef ? 0 : r[4]), r[5], r[6], fin_thick, ta, tb, tr, tl, fin_sub];


// ---------------------------------------------------------------------------
// V2 dispatch modules — read fixed columns directly from each row;
// one if/else-if block per shape family, each using only the columns it needs.
// ---------------------------------------------------------------------------

// V2 version of cut_screen_openings.
// Iterates over the screen_openings vector and cuts each opening at the
// correct position relative to the screen coordinate origin.
// @param s_o    Screen openings vector (V2 explicit 14-column format)
// @param depth  Cut depth in mm; pass 0 for 2D laser-cut output
module cut_screen_openings_v2(s_o, depth) {
	for(i = [0 : len(s_o)-1]) {
		r = s_o[i];
		opening_ID = r[0];
		// r[5]=x, r[6]=y — same for all shapes; pixel-convert here once
		x_mm = (using_px) ? r[5] * mpp : r[5];
		y_raw = r[6];

		if (r[1] == "vridge" || r[1] == "hridge") {
			// r[7]=ridge_height(cb), r[10]=length, r[11]=thickness, r[13]=sp
			sp = r[13];
			h = (r[1] == "vridge") ? r[10] : 0;
			w = (r[1] == "hridge") ? r[10] : 0;
			h_mm = (using_px) ? h * mpp : h;
			w_mm = (using_px) ? w * mpp : w;
			top_sl = r[7]; top_sl_mm = (using_px) ? top_sl * mpp : top_sl;
			bot_sl = r[11]; bot_sl_mm = (using_px) ? bot_sl * mpp : bot_sl;
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			if (depth > 0) {
				y_mm = (starting_corner_for_screen_measurements == "upper-left") ?
				       ((using_px) ? (shp - y_raw) * mpp : (shm - y_raw)) :
				       ((using_px) ? y_raw * mpp : y_raw);
				translate([sx0+x_mm, sy0+y_mm, 0])
				if (opening_ID != "#") {
					cut_opening(w_mm, h_mm, r[1], top_sl, bot_sl, lft_sl, 0, 0, undef, depth, "screen");
				} else {
					#cut_opening(w_mm, h_mm, r[1], top_sl, bot_sl, lft_sl, 0, 0, undef, depth, "screen");
				}
			}

		} else if (r[1] == "ridge" || r[1] == "cridge" || r[1] == "rridge" ||
		           r[1] == "aridge1" || r[1] == "aridge2" ||
		           r[1] == "aridge3" || r[1] == "aridge4") {
			// r[2]=ridge_height, r[10]=length (ridge/cridge/aridge), r[3]=width r[4]=corner (rridge), r[11]=thickness, r[13]=sp
			sp = r[13];
			rr = (r[1] == "rridge");
			ridge_h = r[2]; w_mm = (using_px) ? (rr ? r[3] : r[10]) * mpp : (rr ? r[3] : r[10]);
			top_sl = ridge_h; bot_sl = r[11];
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			c_r = rr ? r[4] : r[11];
			if (depth > 0) {
				y_mm = (starting_corner_for_screen_measurements == "upper-left") ?
				       ((using_px) ? (shp - y_raw) * mpp : (shm - y_raw)) :
				       ((using_px) ? y_raw * mpp : y_raw);
				translate([sx0+x_mm, sy0+y_mm, 0])
				if (opening_ID != "#") {
					cut_opening(w_mm, ridge_h, r[1], top_sl, bot_sl, lft_sl, 0, c_r, (r[7]==0 ? undef : r[7]), depth, "screen");
				} else {
					#cut_opening(w_mm, ridge_h, r[1], top_sl, bot_sl, lft_sl, 0, c_r, (r[7]==0 ? undef : r[7]), depth, "screen");
				}
			}

		} else if (r[1] == "text") {
			// r[2]=font_height, r[7]=z_pos, r[9]=surface, r[12]=es, r[13]=sp
			sp = r[13];
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			h_mm = (using_px) ? r[2] * mpp : r[2];
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			bot_sl = v2_font_style_code((len(sp) >= 3) ? sp[2] : "");
			lft_sl = v2_h_align_code((len(sp) >= 4) ? sp[3] : "");
			rgt_sl = v2_v_align_code((len(sp) >= 5) ? sp[4] : "");
			other  = (len(sp) >= 1) ? sp[0] : undef;
			if (depth > 0) {
				y_mm = (starting_corner_for_screen_measurements == "upper-left") ?
				       ((using_px) ? (shp - y_raw) * mpp : (shm - y_raw)) :
				       ((using_px) ? y_raw * mpp : y_raw);
				translate([sx0+x_mm, sy0+y_mm, 0])
				if (opening_ID != "#") {
					cut_opening_v2(0, h_mm, "text", undef, surface, top_sl, bot_sl, lft_sl, rgt_sl, (using_px ? r[7]*mpp : r[7]), other, depth, "screen");
				} else {
					#cut_opening_v2(0, h_mm, "text", undef, surface, top_sl, bot_sl, lft_sl, rgt_sl, (using_px ? r[7]*mpp : r[7]), other, depth, "screen");
				}
			}

		} else if (r[1] == "svg") {
			// r[2]=height, r[3]=width, r[4]=depth (negative=cut, positive=raise), r[13]=sp
			sp = r[13];
			h_mm = (using_px) ? r[2] * mpp : r[2];
			w_mm = (using_px) ? r[3] * mpp : r[3];
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			other  = (len(sp) >= 1) ? sp[0] : undef;
			if (depth > 0) {
				y_mm = (starting_corner_for_screen_measurements == "upper-left") ?
				       ((using_px) ? (shp - y_raw) * mpp : (shm - y_raw)) :
				       ((using_px) ? y_raw * mpp : y_raw);
				translate([sx0+x_mm, sy0+y_mm, 0])
				if (opening_ID != "#") {
					cut_opening(w_mm, h_mm, "svg", top_sl, 0, 0, 0, (using_px ? r[4]*mpp : r[4]), other, depth, "screen");
				} else {
					#cut_opening(w_mm, h_mm, "svg", top_sl, 0, 0, 0, (using_px ? r[4]*mpp : r[4]), other, depth, "screen");
				}
			}

		} else {
			// Standard shapes: r, c, hd, oa1-4, bump (+ r1-4 for case_openings/tablet_openings).
			// Shape passes through to cut_opening_v2 directly — anchor/surface/corner
			// are dispatched there; no V1 shape-code translation needed.
			es = r[12];
			sp = r[13];
			rot = (len(sp) > 0 && is_num(sp[0])) ? sp[0] : 0;
			anchor  = ((r[8] == "C" || r[8] == "c")) ? "c" : undef;
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			h = r[2];
			w = (r[1] == "bump") ? r[2] : (r[1] == "c" ? 0 : r[3]);
			h_mm = (using_px) ? h * mpp : h;
			w_mm = (using_px) ? w * mpp : w;
			c_r  = (r[1] == "oa1" || r[1] == "oa2" || r[1] == "oa3" || r[1] == "oa4") ? r[4] :
			       min(r[4], min(w, h)/2);
			c_r_mm = (using_px) ? c_r * mpp : c_r;
			top_sl = is_laser_cut ? 90 : v2_slope(es, 0, r[1]);
			bot_sl = is_laser_cut ? 90 : v2_slope(es, 1, r[1]);
			lft_sl = is_laser_cut ? 90 : v2_slope(es, 2, r[1]);
			rgt_sl = is_laser_cut ? 90 : v2_slope(es, 3, r[1]);
			has_invalid_dims = (w_mm < 0 || h_mm < 0);
			if (has_invalid_dims) {
				echo(str("WARNING: screen_openings entry '", opening_ID,
				         "' has negative dimensions (w=", w_mm, "mm h=", h_mm, "mm) — skipping."));
			}
			if (!has_invalid_dims) {
				if (depth > 0 && r[7] <= 0) {
					y_mm = (starting_corner_for_screen_measurements == "upper-left") ?
					       ((using_px) ? (shp - y_raw) * mpp : (shm - y_raw)) :
					       ((using_px) ? y_raw * mpp : y_raw);
					translate([sx0+x_mm, sy0+y_mm, 0])
					if (opening_ID != "#") {
						cut_opening_v2(w_mm, h_mm, r[1], anchor, surface, top_sl, bot_sl, lft_sl, rgt_sl, c_r_mm, (r[7]==0 ? undef : (surface=="b") ? r[7] : -r[7]), depth, "screen", rot);
					} else {
						#cut_opening_v2(w_mm, h_mm, r[1], anchor, surface, top_sl, bot_sl, lft_sl, rgt_sl, c_r_mm, (r[7]==0 ? undef : (surface=="b") ? r[7] : -r[7]), depth, "screen", rot);
					}
				} else if (depth <= 0) {
					y_mm = (starting_corner_for_screen_measurements == "upper-left") ?
					       ((using_px) ? (shp - y_raw) * mpp : (shm - y_raw)) :
					       ((using_px) ? y_raw * mpp : y_raw);
					translate([sx0+x_mm, sy0+y_mm, 0])
					if (opening_ID != "#") {
						cut_opening_2d_v2(w_mm, h_mm, r[1], anchor, top_sl, c_r_mm, rot);
					} else {
						#cut_opening_2d_v2(w_mm, h_mm, r[1], anchor, top_sl, c_r_mm, rot);
					}
				}
				// r[7] > 0: build — handled by adding_plastic_v2
			} // end if (!has_invalid_dims)
		}
	}
}

// V2 version of cut_case_openings.
// Iterates over the case_openings vector and cuts each opening at the
// correct position relative to the case-opening coordinate origin.
// @param c_o    Case openings vector (V2 explicit 14-column format)
// @param depth  Cut depth in mm; pass 0 for 2D laser-cut output
module cut_case_openings_v2(c_o, depth) {
	for(i = [0 : len(c_o)-1]) {
		r = c_o[i];
		opening_ID = r[0];

		if (r[1] == "vridge" || r[1] == "hridge") {
			sp = r[13];
			h = (r[1] == "vridge") ? r[10] : 0;
			w = (r[1] == "hridge") ? r[10] : 0;
			top_sl = r[7]; bot_sl = r[11];
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			if (depth > 0) {
				translate([cox0+r[5], coy0+r[6], 0])
				if (opening_ID != "#") {
					cut_opening(w, h, r[1], top_sl, bot_sl, lft_sl, 0, 0, undef, depth, "keyguard");
				} else {
					#cut_opening(w, h, r[1], top_sl, bot_sl, lft_sl, 0, 0, undef, depth, "keyguard");
				}
			}

		} else if (r[1] == "ridge" || r[1] == "cridge" || r[1] == "rridge" ||
		           r[1] == "aridge1" || r[1] == "aridge2" ||
		           r[1] == "aridge3" || r[1] == "aridge4") {
			sp = r[13];
			rr = (r[1] == "rridge");
			top_sl = r[2]; bot_sl = r[11];
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			if (depth > 0) {
				translate([cox0+r[5], coy0+r[6], 0])
				if (opening_ID != "#") {
					cut_opening(rr ? r[3] : r[10], r[2], r[1], top_sl, bot_sl, lft_sl, 0, rr ? r[4] : r[11], (r[7]==0 ? undef : r[7]), depth, "keyguard");
				} else {
					#cut_opening(rr ? r[3] : r[10], r[2], r[1], top_sl, bot_sl, lft_sl, 0, rr ? r[4] : r[11], (r[7]==0 ? undef : r[7]), depth, "keyguard");
				}
			}

		} else if (r[1] == "text") {
			// r[2]=font_height, r[7]=z_pos, r[9]=surface, r[13]=sp
			sp = r[13];
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			bot_sl = v2_font_style_code((len(sp) >= 3) ? sp[2] : "");
			lft_sl = v2_h_align_code((len(sp) >= 4) ? sp[3] : "");
			rgt_sl = v2_v_align_code((len(sp) >= 5) ? sp[4] : "");
			other  = (len(sp) >= 1) ? sp[0] : undef;
			if (depth > 0) {
				translate([cox0+r[5], coy0+r[6], 0])
				if (opening_ID != "#") {
					cut_opening_v2(0, r[2], "text", undef, surface, top_sl, bot_sl, lft_sl, rgt_sl, r[7], other, depth, "keyguard");
				} else {
					#cut_opening_v2(0, r[2], "text", undef, surface, top_sl, bot_sl, lft_sl, rgt_sl, r[7], other, depth, "keyguard");
				}
			}

		} else if (r[1] == "svg") {
			sp = r[13];
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			other  = (len(sp) >= 1) ? sp[0] : undef;
			if (depth > 0) {
				translate([cox0+r[5], coy0+r[6], 0])
				if (opening_ID != "#") {
					cut_opening(r[3], r[2], "svg", top_sl, 0, 0, 0, r[4], other, depth, "keyguard");
				} else {
					#cut_opening(r[3], r[2], "svg", top_sl, 0, 0, 0, r[4], other, depth, "keyguard");
				}
			}

		} else {
			es = r[12];
			sp = r[13];
			rot = (len(sp) > 0 && is_num(sp[0])) ? sp[0] : 0;
			anchor  = ((r[8] == "C" || r[8] == "c")) ? "c" : undef;
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			w = (r[1] == "bump") ? r[2] : (r[1] == "c" ? 0 : r[3]);
			h = r[2];
			c_r = (w > 0 && h > 0) ? min(r[4], min(w, h)/2) : r[4];
			top_sl = is_laser_cut ? 90 : v2_slope(es, 0, r[1]);
			bot_sl = is_laser_cut ? 90 : v2_slope(es, 1, r[1]);
			lft_sl = is_laser_cut ? 90 : v2_slope(es, 2, r[1]);
			rgt_sl = is_laser_cut ? 90 : v2_slope(es, 3, r[1]);
			has_invalid_dims = (w < 0 || h < 0);
			if (has_invalid_dims) {
				echo(str("WARNING: case_openings entry '", opening_ID,
				         "' has negative dimensions (w=", w, "mm h=", h, "mm) — skipping."));
			}
			if (!has_invalid_dims) {
				translate([cox0+r[5], coy0+r[6], 0])
				if (depth > 0 && r[7] <= 0) {
					if (opening_ID != "#") {
						cut_opening_v2(w, h, r[1], anchor, surface, top_sl, bot_sl, lft_sl, rgt_sl, c_r, (r[7]==0 ? undef : (surface=="b") ? r[7] : -r[7]), depth, "keyguard", rot);
					} else {
						#cut_opening_v2(w, h, r[1], anchor, surface, top_sl, bot_sl, lft_sl, rgt_sl, c_r, (r[7]==0 ? undef : (surface=="b") ? r[7] : -r[7]), depth, "keyguard", rot);
					}
				} else if (depth <= 0) {
					if (opening_ID != "#") {
						cut_opening_2d_v2(w, h, r[1], anchor, top_sl, c_r, rot);
					} else {
						#cut_opening_2d_v2(w, h, r[1], anchor, top_sl, c_r, rot);
					}
				}
				// r[7] > 0: build — handled by adding_plastic_v2
			} // end if (!has_invalid_dims)
		}
	}
}

// V2 version of cut_tablet_openings.
// Iterates over the tablet_openings vector and cuts each opening at the
// correct position relative to the tablet coordinate origin.
// @param t_o    Tablet openings vector (V2 explicit 14-column format)
// @param depth  Cut depth in mm
module cut_tablet_openings_v2(t_o, depth) {
	for(i = [0 : len(t_o)-1]) {
		r = t_o[i];
		opening_ID = r[0];

		if (r[1] == "vridge" || r[1] == "hridge") {
			sp = r[13];
			h = (r[1] == "vridge") ? r[10] : 0;
			w = (r[1] == "hridge") ? r[10] : 0;
			top_sl = r[7]; bot_sl = r[11];
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			trans = (is_landscape) ? [tx0+r[5], ty0+r[6], 0] : [tx0+r[6], -ty0-r[5], 0];
			translate(trans)
			if (opening_ID != "#") {
				cut_opening(w, h, r[1], top_sl, bot_sl, lft_sl, 0, 0, undef, depth, "tablet");
			} else {
				#cut_opening(w, h, r[1], top_sl, bot_sl, lft_sl, 0, 0, undef, depth, "tablet");
			}

		} else if (r[1] == "ridge" || r[1] == "cridge" || r[1] == "rridge" ||
		           r[1] == "aridge1" || r[1] == "aridge2" ||
		           r[1] == "aridge3" || r[1] == "aridge4") {
			sp = r[13];
			rr = (r[1] == "rridge");
			top_sl = r[2]; bot_sl = r[11];
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			trans = (is_landscape) ? [tx0+r[5], ty0+r[6], 0] : [tx0+r[6], -ty0-r[5], 0];
			translate(trans)
			if (opening_ID != "#") {
				cut_opening(rr ? r[3] : r[10], r[2], r[1], top_sl, bot_sl, lft_sl, 0, rr ? r[4] : r[11], (r[7]==0 ? undef : r[7]), depth, "tablet");
			} else {
				#cut_opening(rr ? r[3] : r[10], r[2], r[1], top_sl, bot_sl, lft_sl, 0, rr ? r[4] : r[11], (r[7]==0 ? undef : r[7]), depth, "tablet");
			}

		} else if (r[1] == "text") {
			// r[2]=font_height, r[7]=z_pos, r[9]=surface, r[13]=sp
			sp = r[13];
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			bot_sl = v2_font_style_code((len(sp) >= 3) ? sp[2] : "");
			lft_sl = v2_h_align_code((len(sp) >= 4) ? sp[3] : "");
			rgt_sl = v2_v_align_code((len(sp) >= 5) ? sp[4] : "");
			other  = (len(sp) >= 1) ? sp[0] : undef;
			trans = (is_landscape) ? [tx0+r[5], ty0+r[6], 0] : [tx0+r[6], -ty0-r[5], 0];
			translate(trans)
			if (opening_ID != "#") {
				cut_opening_v2(0, r[2], "text", undef, surface, top_sl, bot_sl, lft_sl, rgt_sl, r[7], other, depth, "tablet");
			} else {
				#cut_opening_v2(0, r[2], "text", undef, surface, top_sl, bot_sl, lft_sl, rgt_sl, r[7], other, depth, "tablet");
			}

		} else if (r[1] == "svg") {
			sp = r[13];
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			other  = (len(sp) >= 1) ? sp[0] : undef;
			trans = (is_landscape) ? [tx0+r[5], ty0+r[6], 0] : [tx0+r[6], -ty0-r[5], 0];
			translate(trans)
			if (opening_ID != "#") {
				cut_opening(r[3], r[2], "svg", top_sl, 0, 0, 0, r[4], other, depth, "tablet");
			} else {
				#cut_opening(r[3], r[2], "svg", top_sl, 0, 0, 0, r[4], other, depth, "tablet");
			}

		} else {
			es = r[12];
			sp = r[13];
			rot = (len(sp) > 0 && is_num(sp[0])) ? sp[0] : 0;
			anchor  = ((r[8] == "C" || r[8] == "c")) ? "c" : undef;
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			w = (r[1] == "bump") ? r[2] : (r[1] == "c" ? 0 : r[3]);
			h = r[2];
			c_r = (w > 0 && h > 0) ? min(r[4], min(w, h)/2) : r[4];
			top_sl = is_laser_cut ? 90 : v2_slope(es, 0, r[1]);
			bot_sl = is_laser_cut ? 90 : v2_slope(es, 1, r[1]);
			lft_sl = is_laser_cut ? 90 : v2_slope(es, 2, r[1]);
			rgt_sl = is_laser_cut ? 90 : v2_slope(es, 3, r[1]);
			has_invalid_dims = (w < 0 || h < 0);
			if (has_invalid_dims) {
				echo(str("WARNING: tablet_openings entry '", opening_ID,
				         "' has negative dimensions (w=", w, "mm h=", h, "mm) — skipping."));
			}
			if (!has_invalid_dims) {
				trans = (is_landscape) ? [tx0+r[5], ty0+r[6], 0] : [tx0+r[6], -ty0-r[5], 0];
				if (r[7] <= 0) {
					translate(trans)
					if (opening_ID != "#") {
						cut_opening_v2(w, h, r[1], anchor, surface, top_sl, bot_sl, lft_sl, rgt_sl, c_r, (r[7]==0 ? undef : (surface=="b") ? r[7] : -r[7]), depth, "tablet", rot);
					} else {
						#cut_opening_v2(w, h, r[1], anchor, surface, top_sl, bot_sl, lft_sl, rgt_sl, c_r, (r[7]==0 ? undef : (surface=="b") ? r[7] : -r[7]), depth, "tablet", rot);
					}
				}
				// r[7] > 0: build — handled by adding_plastic_v2 (if tablet openings are used as additions source)
			} // end if (!has_invalid_dims)
		}
	}
}

// Geometry-only helper for the positive-cb (emboss) branch of adding_plastic_v2.
// All translate/rotate/hole_cutter calls are inside this module so that the
// caller can apply the # debug modifier by writing #place_emboss_v2(...).
// V2-native: dispatches on shape + anchor + corner instead of V1 shape codes.
// @param shape     V2 shape: "r", "c", "hd"
// @param anchor    undef/"L"/"l" (L-anchored) or "C"/"c" (centred)
// @param xb, yb    Base XY position (x0+x_mm, y0+y_mm) from the caller
// @param trans     Base Z translation from adding_plastic_v2
// @param rot_b     Z-axis rotation in degrees
// @param w_mm_b, h_mm_b  Shape width and height in mm
// @param dep_b     Full emboss depth in mm
// @param main_dep_b  Depth of the main body (dep_b minus chamfer if any)
// @param top_sl_b, bot_sl_b, lft_sl_b, rgt_sl_b  Edge slopes
// @param c_r_b     Corner radius in mm (used as-is for "r"; computed from dims for "c"/"hd")
// @param has_ch_b  1 if a top chamfer cap should be added, 0 otherwise
// @param ec_b      Edge chamfer size in mm
module place_emboss_v2(shape, anchor, xb, yb, trans, rot_b,
                       w_mm_b, h_mm_b, dep_b, main_dep_b,
                       top_sl_b, bot_sl_b, lft_sl_b, rgt_sl_b,
                       c_r_b, has_ch_b, ec_b) {
	// rotate([180,0,0]) flips the build body so the narrow face (= specified w×h)
	// is at the top (apex) and the wide face is at the keyguard surface — a mountain
	// shape. The flip inverts y, so top_sl and bot_sl are swapped in the call so
	// that top_sl still widens the +y edge and bot_sl widens the -y edge at the base.
	is_c = (anchor == "C" || anchor == "c");

	if (shape == "r") {
		if (w_mm_b > 0) {
			cx = is_c ? xb : xb + w_mm_b/2;
			cy = is_c ? yb : yb + h_mm_b/2;
			translate([cx, cy, trans + main_dep_b/2])
			rotate([0,0,rot_b]) rotate([180,0,0])
			hole_cutter(w_mm_b, h_mm_b, bot_sl_b, top_sl_b, lft_sl_b, rgt_sl_b, c_r_b, main_dep_b, 0);
			if (has_ch_b)
				translate([cx, cy, trans + dep_b - ec_b/2])
				rotate([0,0,rot_b]) rotate([180,0,0])
				cut(max(ff, w_mm_b-2*ec_b), max(ff, h_mm_b-2*ec_b), 45, 45, 45, 45, max(0, c_r_b-ec_b), ec_b);
		}
	} else if (shape == "c") {
		cx = is_c ? xb : xb + h_mm_b/2;
		cy = is_c ? yb : yb + h_mm_b/2;
		translate([cx, cy, trans + main_dep_b/2])
		rotate([0,0,rot_b]) rotate([180,0,0])
		hole_cutter(h_mm_b, h_mm_b, bot_sl_b, top_sl_b, lft_sl_b, rgt_sl_b, h_mm_b/2, main_dep_b, 0);
		if (has_ch_b)
			translate([cx, cy, trans + dep_b - ec_b/2])
			rotate([0,0,rot_b]) rotate([180,0,0])
			cut(max(ff, h_mm_b-2*ec_b), max(ff, h_mm_b-2*ec_b), 45, 45, 45, 45, max(0, h_mm_b/2-ec_b), ec_b);
	} else if (shape == "hd") {
		if (w_mm_b > 0) {
			m_b = min(w_mm_b, h_mm_b);
			cx = is_c ? xb : xb + w_mm_b/2;
			cy = is_c ? yb : yb + h_mm_b/2;
			translate([cx, cy, trans + main_dep_b/2])
			rotate([0,0,rot_b]) rotate([180,0,0])
			hole_cutter(w_mm_b, h_mm_b, bot_sl_b, top_sl_b, lft_sl_b, rgt_sl_b, m_b/2, main_dep_b, 0);
			if (has_ch_b)
				translate([cx, cy, trans + dep_b - ec_b/2])
				rotate([0,0,rot_b]) rotate([180,0,0])
				cut(max(ff, w_mm_b-2*ec_b), max(ff, h_mm_b-2*ec_b), 45, 45, 45, 45, max(0, m_b/2-ec_b), ec_b);
		}
	}
}

// V2 version of adding_plastic.
// Iterates over screen or case openings and builds solid additions (bumps,
// ridges, text, SVG imports) at the correct coordinate-system origin.
// @param additions  Screen or case openings vector (V2 explicit 14-column format)
// @param where      Coordinate context: "screen" or "case"
module adding_plastic_v2(additions, where) {
	x0    = (where == "screen") ? sx0 : cox0;
	y0    = (where == "screen") ? sy0 : coy0;
	trans = (where == "screen") ? -kt/2+sat :
	        (where == "case" && generate == "keyguard") ? kt/2 :
	        keyguard_frame_thickness/2;

	for(i = [0 : len(additions)-1]) {
		r = additions[i];
		addition_ID = r[0];
		px = (using_px && where == "screen");
		x_mm = px ? r[5] * mpp : r[5];
		y_raw = r[6];

		if (r[1] == "bump") {
			// r[2]=diameter; sphere: height=width=diameter
			diam    = r[2];
			diam_mm = px ? diam * mpp : diam;
			top_sl  = v2_slope(r[12], 0, "bump");
			top_sl_mm = px ? top_sl * mpp : top_sl;
			bot_sl  = v2_slope(r[12], 1, "bump");
			bot_sl_mm = px ? bot_sl * mpp : bot_sl;
			lft_sl  = v2_slope(r[12], 2, "bump");
			rgt_sl  = v2_slope(r[12], 3, "bump");
			y_mm = (starting_corner_for_screen_measurements == "upper-left" && where == "screen") ?
			       (px ? (shp - y_raw) * mpp : (shm - y_raw)) :
			       (px ? y_raw * mpp : y_raw);
			translate([x0+x_mm, y0+y_mm, trans-ff])
			if (addition_ID != "#") {
				place_addition_v2(diam_mm, diam_mm, "bump", top_sl, top_sl_mm, bot_sl, bot_sl_mm, lft_sl, rgt_sl, 0, (r[7]==0 ? undef : r[7]));
			} else {
				#place_addition_v2(diam_mm, diam_mm, "bump", top_sl, top_sl_mm, bot_sl, bot_sl_mm, lft_sl, rgt_sl, 0, (r[7]==0 ? undef : r[7]));
			}

		} else if (r[1] == "vridge" || r[1] == "hridge") {
			// r[7]=ridge_height, r[10]=length, r[11]=thickness, r[13]=sp
			sp = r[13];
			h = (r[1] == "vridge") ? r[10] : 0;
			w = (r[1] == "hridge") ? r[10] : 0;
			h_mm = px ? h * mpp : h; w_mm = px ? w * mpp : w;
			top_sl = r[7]; top_sl_mm = px ? top_sl * mpp : top_sl;
			bot_sl = r[11]; bot_sl_mm = px ? bot_sl * mpp : bot_sl;
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			y_mm = (starting_corner_for_screen_measurements == "upper-left" && where == "screen") ?
			       (px ? (shp - y_raw) * mpp : (shm - y_raw)) :
			       (px ? y_raw * mpp : y_raw);
			c_ax = ((r[8] == "C" || r[8] == "c") && r[1] == "hridge") ? -w_mm/2 : 0;
			c_ay = ((r[8] == "C" || r[8] == "c") && r[1] == "vridge") ? -h_mm/2 : 0;
			translate([x0+x_mm+c_ax, y0+y_mm+c_ay, trans-ff])
			if (addition_ID != "#") {
				place_addition_v2(w_mm, h_mm, r[1], top_sl, top_sl_mm, bot_sl, bot_sl_mm, lft_sl, 0, 0, (r[7]==0 ? undef : r[7]));
			} else {
				#place_addition_v2(w_mm, h_mm, r[1], top_sl, top_sl_mm, bot_sl, bot_sl_mm, lft_sl, 0, 0, (r[7]==0 ? undef : r[7]));
			}

		} else if (r[1] == "ridge" || r[1] == "cridge" || r[1] == "rridge" || r[1] == "hdridge" ||
		           r[1] == "aridge1" || r[1] == "aridge2" ||
		           r[1] == "aridge3" || r[1] == "aridge4") {
			// All shapes: r[7]=ridge_height (cb), r[11]=thickness. ridge/cridge/aridge: r[10]=length. rridge/hdridge: r[2]=rect_height, r[3]=width, r[4]=corner (rridge only). cridge: r[2]=circle_size. aridge1-4: r[4]=corner.
			sp = r[13];
			rr = (r[1] == "rridge");
			hdr = (r[1] == "hdridge");
			cr = (r[1] == "cridge");
			ar = (r[1] == "aridge1" || r[1] == "aridge2" || r[1] == "aridge3" || r[1] == "aridge4");
			w_src = (rr || hdr) ? r[3] : r[10];
			w_mm = px ? w_src * mpp : w_src;
			top_sl = r[7]; top_sl_mm = px ? top_sl * mpp : top_sl;
			bot_sl = r[11]; bot_sl_mm = px ? bot_sl * mpp : bot_sl;
			lft_sl = (len(sp) >= 1) ? sp[0] : 0;
			y_mm = (starting_corner_for_screen_measurements == "upper-left" && where == "screen") ?
			       (px ? (shp - y_raw) * mpp : (shm - y_raw)) :
			       (px ? y_raw * mpp : y_raw);
			// cridge: circular_wall is centered at origin so x,y is always the centre unless we
			// apply an offset. For "L" anchor shift by inner_radius so x,y becomes the lower-left
			// corner of the inner bounding box, aligning with a "c" circle of the same diameter.
			inner_r_cr = cr ? (px ? r[2]*mpp : r[2])/2 : 0;
			c_ax = ((r[8] == "C" || r[8] == "c") && r[1] == "ridge") ? -w_mm/2 * cos(lft_sl) :
			       ((r[8] == "C" || r[8] == "c") && (rr || hdr))      ? -w_mm/2 :
			       (!(r[8] == "C" || r[8] == "c") && cr)               ? inner_r_cr : 0;
			c_ay = ((r[8] == "C" || r[8] == "c") && r[1] == "ridge") ? -w_mm/2 * sin(lft_sl) :
			       ((r[8] == "C" || r[8] == "c") && (rr || hdr))      ? -(px ? r[2]*mpp : r[2])/2 :
			       (!(r[8] == "C" || r[8] == "c") && cr)               ? inner_r_cr : 0;
			translate([x0+x_mm+c_ax, y0+y_mm+c_ay, trans-ff])
			if (addition_ID != "#") {
				place_addition_v2(w_mm, r[2], r[1], top_sl, top_sl_mm, bot_sl, bot_sl_mm, lft_sl, 0, (rr || ar) ? r[4] : r[11], (r[7]==0 ? undef : r[7]));
			} else {
				#place_addition_v2(w_mm, r[2], r[1], top_sl, top_sl_mm, bot_sl, bot_sl_mm, lft_sl, 0, (rr || ar) ? r[4] : r[11], (r[7]==0 ? undef : r[7]));
			}

		} else if (r[1] == "text") {
			// r[2]=font_height, r[7]=z_pos, r[9]=surface, r[13]=sp
			sp = r[13];
			surface = (r[9] == "B" || r[9] == "b") ? "b" : undef;
			h_mm = px ? r[2] * mpp : r[2];
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			top_sl_mm = px ? top_sl * mpp : top_sl;
			bot_sl = (len(sp) >= 3) ? sp[2] : "";   // font style string: "bold", "italic", "bold italic", or ""
			lft_sl = (len(sp) >= 4) ? sp[3] : "";   // halign string: "left", "center", "right"
			rgt_sl = (len(sp) >= 5) ? sp[4] : "";   // valign string: "bottom", "baseline", "center", "top"
			other  = (len(sp) >= 1) ? sp[0] : undef;
			y_mm = (starting_corner_for_screen_measurements == "upper-left" && where == "screen") ?
			       (px ? (shp - y_raw) * mpp : (shm - y_raw)) :
			       (px ? y_raw * mpp : y_raw);
			translate([x0+x_mm, y0+y_mm, trans-ff])
			if (addition_ID != "#") {
				place_addition_v2(0, h_mm, "text", top_sl, top_sl_mm, bot_sl, 0, lft_sl, rgt_sl, (px ? r[7]*mpp : r[7]), other, surface);
			} else {
				#place_addition_v2(0, h_mm, "text", top_sl, top_sl_mm, bot_sl, 0, lft_sl, rgt_sl, (px ? r[7]*mpp : r[7]), other, surface);
			}

		} else if (r[1] == "svg") {
			// r[2]=height, r[3]=width, r[4]=depth (negative=cut, positive=raise), r[13]=sp
			sp = r[13];
			h_mm = px ? r[2] * mpp : r[2]; w_mm = px ? r[3] * mpp : r[3];
			top_sl = (len(sp) >= 2) ? sp[1] : 0;
			top_sl_mm = px ? top_sl * mpp : top_sl;
			other  = (len(sp) >= 1) ? sp[0] : undef;
			y_mm = (starting_corner_for_screen_measurements == "upper-left" && where == "screen") ?
			       (px ? (shp - y_raw) * mpp : (shm - y_raw)) :
			       (px ? y_raw * mpp : y_raw);
			translate([x0+x_mm, y0+y_mm, trans-ff])
			if (addition_ID != "#") {
				place_addition_v2(w_mm, h_mm, "svg", top_sl, top_sl_mm, 0, 0, 0, 0, (px ? r[4]*mpp : r[4]), other);
			} else {
				#place_addition_v2(w_mm, h_mm, "svg", top_sl, top_sl_mm, 0, 0, 0, 0, (px ? r[4]*mpp : r[4]), other);
			}
		} else if (r[7] > 0) {
			// Standard opening shape with positive cb — extrude solid upward from surface.
			// Geometry: main body (full width, no chamfer) + inward-chamfer cap at top edge.
			// cut() narrows from bottom to top, so rotate([180,0,0]) gives wide-at-base,
			// narrow-at-top — the inward bevel shape we need.
			es = r[12];
			sp_b = r[13];
			rot_b = (len(sp_b) > 0 && is_num(sp_b[0])) ? sp_b[0] : 0;
			anchor   = ((r[8] == "C" || r[8] == "c")) ? "c" : undef;
			h_mm_b   = px ? r[2] * mpp : r[2];
			w_mm_b   = px ? (r[1] == "c" ? 0 : r[3]) * mpp : (r[1] == "c" ? 0 : r[3]);
			dep_b    = px ? r[7] * mpp : r[7];
			c_r_b    = (w_mm_b > 0 && h_mm_b > 0) ? min(r[4], min(w_mm_b, h_mm_b)/2) : r[4];
			top_sl_b = is_laser_cut ? 90 : v2_slope(es, 0, r[1]);
			bot_sl_b = is_laser_cut ? 90 : v2_slope(es, 1, r[1]);
			lft_sl_b = is_laser_cut ? 90 : v2_slope(es, 2, r[1]);
			rgt_sl_b = is_laser_cut ? 90 : v2_slope(es, 3, r[1]);
			ec_b     = (where == "screen") ? cec : kec;
			has_ch_b = ec_b > 0 && dep_b > ec_b;
			main_dep_b = has_ch_b ? dep_b - ec_b : dep_b;
			y_mm = (starting_corner_for_screen_measurements == "upper-left" && where == "screen") ?
			       (px ? (shp - y_raw) * mpp : (shm - y_raw)) :
			       (px ? y_raw * mpp : y_raw);
			if (is_3d_printed && h_mm_b > 0) {
				if (addition_ID != "#") {
					place_emboss_v2(r[1], anchor, x0+x_mm, y0+y_mm, trans, rot_b,
					                w_mm_b, h_mm_b, dep_b, main_dep_b,
					                top_sl_b, bot_sl_b, lft_sl_b, rgt_sl_b,
					                c_r_b, has_ch_b, ec_b);
				} else {
					#place_emboss_v2(r[1], anchor, x0+x_mm, y0+y_mm, trans, rot_b,
					                 w_mm_b, h_mm_b, dep_b, main_dep_b,
					                 top_sl_b, bot_sl_b, lft_sl_b, rgt_sl_b,
					                 c_r_b, has_ch_b, ec_b);
				}
			}
		}
	}
}

// V2 version of apply_flex_height_shapes.
// Iterates over the case_additions vector and applies (or subtracts) shapes
// that have an explicit thickness (flex-height shapes).
// @param c_a     Case additions vector (V2 format)
// @param is_sub  false = add positive shapes; true = subtract negative shapes
module apply_flex_height_shapes_v2(c_a, is_sub) {
	if (len(c_a) > 0) {
		for(i = [0 : len(c_a)-1]) {
			p = v2_parse_addition(c_a[i]);
			addition_ID            = p[0];
			addition_shape         = p[1];
			addition_height        = is_sub ? p[2]+ff : p[2];
			addition_width         = is_sub ? p[3]+ff : p[3];
			addition_corner_radius = p[4];
			addition_x             = p[5];
			addition_y             = p[6];
			addition_thickness     = (is_laser_cut && generate=="first layer for SVG/DXF file") ? 0
			                       : is_sub ? p[7]+ff : p[7];
			addition_trim_above    = p[8];
			addition_trim_below    = p[9];
			addition_trim_to_right = p[10];
			addition_trim_to_left  = p[11];

			is_sub_shape   = p[12];
			is_unsupported = addition_shape == "rr" || addition_shape == "crr";
			if (is_unsupported) {
				echo(str("WARNING: V2 case_additions shape '", addition_shape, "' not supported; use r1-4 instead (ID=", addition_ID, ")"));
			} else if (addition_thickness > 0 && is_sub == is_sub_shape) {
				translate([0, 0, is_sub ? -kt/2-ff : -kt/2])
				if (addition_ID == "#") {
					#linear_extrude(height=addition_thickness)
					build_trimmed_addition(addition_x, addition_y, addition_width, addition_height, addition_shape, addition_trim_above, addition_trim_below, addition_trim_to_right, addition_trim_to_left, addition_corner_radius);
				} else {
					linear_extrude(height=addition_thickness)
					build_trimmed_addition(addition_x, addition_y, addition_width, addition_height, addition_shape, addition_trim_above, addition_trim_below, addition_trim_to_right, addition_trim_to_left, addition_corner_radius);
				}
			}
		}
	}
}

// V2 version of add_case_full_height_shapes.
// Iterates over the case_additions vector and adds (or subtracts) full-height
// 2D shapes extruded through the entire keyguard thickness.
// @param c_a   Case additions vector (V2 format)
// @param type  "add" or "sub"
module add_case_full_height_shapes_v2(c_a, type) {
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;

	for(i = [0 : len(c_a)-1]) {
		p = v2_parse_addition(c_a[i]);
		addition_ID            = p[0];
		addition_shape         = p[1];
		addition_height        = p[2];
		addition_width         = p[3];
		addition_corner_radius = p[4];
		addition_x             = p[5];
		addition_y             = p[6];
		addition_thickness     = p[7];
		addition_trim_above    = p[8];
		addition_trim_below    = p[9];
		addition_trim_to_right = p[10];
		addition_trim_to_left  = p[11];
		is_sub_shape           = p[12];

		is_unsupported = addition_shape == "rr" || addition_shape == "crr";
		if (is_unsupported) {
			echo(str("WARNING: V2 case_additions shape '", addition_shape, "' not supported; use r1-4 instead (ID=", addition_ID, ")"));
		} else if (addition_thickness == 0 && addition_shape != undef) {
			if (addition_ID == "#") {
				if (type == "add" && !is_sub_shape) {
					difference() {
						translate([x0+addition_x, y0+addition_y])
						#build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);
						if (addition_trim_below > -999) { translate([0,-kh+addition_trim_below]) square([kw*2,kh*2],center=true); }
						if (addition_trim_above > -999) { translate([0, kh+addition_trim_above]) square([kw*2,kh*2],center=true); }
						if (addition_trim_to_right > -999) { translate([addition_trim_to_right,0]) square([kw*2,kh*2],center=true); }
						if (addition_trim_to_left  > -999) { translate([-kw+addition_trim_to_left,0]) square([kw*2,kh*2],center=true); }
					}
				}
				if (type == "sub" && is_sub_shape) {
					translate([x0+addition_x, y0+addition_y])
					#build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);
				}
			} else {
				if (type == "add" && !is_sub_shape) {
					if (addition_thickness == 0) {
						difference() {
							translate([x0+addition_x, y0+addition_y])
							build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);
							if (addition_trim_below > -999) { translate([0,-kh+addition_trim_below]) square([kw*2,kh*2],center=true); }
							if (addition_trim_above > -999) { translate([0, kh+addition_trim_above]) square([kw*2,kh*2],center=true); }
							if (addition_trim_to_right > -999) { translate([addition_trim_to_right,0]) square([kw*2,kh*2],center=true); }
							if (addition_trim_to_left  > -999) { translate([-kw+addition_trim_to_left,0]) square([kw*2,kh*2],center=true); }
						}
					}
				}
				if (type == "sub" && is_sub_shape) {
					translate([x0+addition_x, y0+addition_y])
					build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);
				}
			}
		}
	}
}

// V2 version of add_manual_mount_pedestals.
// Iterates over the case_additions vector and places ped1-4 mount pedestals.
// @param c_a    Case additions vector (V2 format)
// @param depth  Surface-z thickness in mm: pedestals sit on top of the slab at z = depth/2.
//               Defaults to kt for the standard keyguard call site. When called from
//               keyguard_frame(), pass keyguard_frame_thickness so pedestals sit on the
//               frame surface rather than at kt/2 (which is below the frame top when
//               kt != keyguard_frame_thickness).
module add_manual_mount_pedestals_v2(c_a, depth=kt) {
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	pz = depth/2;

	for(i = [0 : len(c_a)-1]) {
		p = v2_parse_addition(c_a[i]);
		addition_ID    = p[0];
		addition_shape = p[1];
		addition_x     = p[5];
		addition_y     = p[6];
		addition_corner_radius = p[4];
		s = addition_shape;
		shape = ((s=="rr1" || s=="rr2" || s=="rr3" || s=="rr4") && addition_corner_radius==0) ? "r" : s;

		translate([addition_x, addition_y])
		if (addition_ID != "#") {
			if (shape == "ped1") {
				translate([x0, y0-manual_pedestal_edge_inset, pz]) rotate([0,0,-90])
				linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, vertical_pedestal_width], center=true);
			} else if (shape == "ped2") {
				translate([x0-manual_pedestal_edge_inset, y0, pz]) rotate([0,0,0])
				linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, horizontal_pedestal_width], center=true);
			} else if (shape == "ped3") {
				translate([x0, y0+manual_pedestal_edge_inset, pz]) rotate([0,0,-90])
				linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, vertical_pedestal_width], center=true);
			} else if (shape == "ped4") {
				translate([x0+manual_pedestal_edge_inset, y0, pz]) rotate([0,0,0])
				linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, horizontal_pedestal_width], center=true);
			}
		} else {
			if (shape == "ped1") {
				translate([x0, y0-manual_pedestal_edge_inset, pz]) rotate([0,0,-90])
				#linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, vertical_pedestal_width], center=true);
			} else if (shape == "ped2") {
				translate([x0-manual_pedestal_edge_inset, y0, pz]) rotate([0,0,0])
				#linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, horizontal_pedestal_width], center=true);
			} else if (shape == "ped3") {
				translate([x0, y0+manual_pedestal_edge_inset, pz]) rotate([0,0,-90])
				#linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, vertical_pedestal_width], center=true);
			} else if (shape == "ped4") {
				translate([x0+manual_pedestal_edge_inset, y0, pz]) rotate([0,0,0])
				#linear_extrude(height=pedestal_height, scale=pedestal_taper) square([pedestal_base_size, horizontal_pedestal_width], center=true);
			}
		}
	}
}

// V2 version of cut_manual_mount_pedestal_slots.
// Iterates over the case_additions vector and cuts wedge grooves for ped1-4.
// @param c_a  Case additions vector (V2 format)
module cut_manual_mount_pedestal_slots_v2(c_a) {
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;

	for(i = [0 : len(c_a)-1]) {
		p = v2_parse_addition(c_a[i]);
		addition_ID    = p[0];
		addition_shape = p[1];
		addition_x     = p[5];
		addition_y     = p[6];
		addition_corner_radius = p[4];
		s = addition_shape;
		shape = ((s=="rr1" || s=="rr2" || s=="rr3" || s=="rr4") && addition_corner_radius==0) ? "r" : s;

		translate([x0+addition_x, y0+addition_y])
		if (addition_ID != "#") {
			if (shape == "ped1") {
				translate([vertical_slot_width/2, -manual_pedestal_slot_inset-kec, vertical_offset]) rotate([90,0,-90])
				linear_extrude(height=vertical_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			} else if (shape == "ped3") {
				translate([-vertical_slot_width/2, manual_pedestal_slot_inset+kec, vertical_offset]) rotate([90,0,90])
				linear_extrude(height=vertical_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			} else if (shape == "ped2") {
				translate([-kec-manual_pedestal_slot_inset, -horizontal_slot_width/2, vertical_offset]) rotate([90,0,180])
				linear_extrude(height=horizontal_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			} else if (shape == "ped4") {
				translate([kec+manual_pedestal_slot_inset, horizontal_slot_width/2, vertical_offset]) rotate([90,0,0])
				linear_extrude(height=horizontal_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
		} else {
			if (shape == "ped1") {
				translate([vertical_slot_width/2, -manual_pedestal_slot_inset-kec, vertical_offset]) rotate([90,0,-90])
				#linear_extrude(height=vertical_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			} else if (shape == "ped3") {
				translate([-vertical_slot_width/2, manual_pedestal_slot_inset+kec, vertical_offset]) rotate([90,0,90])
				#linear_extrude(height=vertical_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			} else if (shape == "ped2") {
				translate([-kec-manual_pedestal_slot_inset, -horizontal_slot_width/2, vertical_offset]) rotate([90,0,180])
				#linear_extrude(height=horizontal_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			} else if (shape == "ped4") {
				translate([kec+manual_pedestal_slot_inset, horizontal_slot_width/2, vertical_offset]) rotate([90,0,0])
				#linear_extrude(height=horizontal_slot_width) polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
		}
	}
}

// =============================================================================
// END V2 OPENINGS-FILE SUPPORT
// =============================================================================

// Iterates over the case_openings vector and cuts (or highlights with #) each
// opening at the correct position relative to the case-opening coordinate origin.
// @param c_o    Case openings vector (rows of opening definitions)
// @param depth  Cut depth in mm; pass 0 for 2D laser-cut output
module cut_case_openings(c_o,depth){

	for(i = [0 : len(c_o)-1]){
		opening = c_o[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:top slope, 7:bottom slope, 8:left slope, 9:right slope, 10:corner_radius, 11:other
		opening_ID = opening[0];
		opening_x = opening[1];
		opening_y = opening[2];
		opening_width = opening[3];
		opening_height = opening[4];
		opening_shape = opening[5];
		opening_top_slope = (is_laser_cut || (opening[6]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[6];
		opening_bottom_slope = (is_laser_cut || (opening[7]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[7];
		opening_left_slope = (is_laser_cut || (opening[8]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[8];
		opening_right_slope = (is_laser_cut || (opening[9]==0 && opening_shape!="svg" && opening_shape!="ridge" && opening_shape!="ttext" && opening_shape!="btext")) ? 90 : opening[9];
		opening_corner_radius = opening[10];
		opening_other = opening[11];

		o_c_r = (opening_width>0 && opening_height>0) ? min(opening_corner_radius,min(opening_width,opening_height)/2) : opening_corner_radius;

		has_invalid_dims = (opening_width < 0 || opening_height < 0)
		                && opening_shape != "ridge" && opening_shape != "ttext"
		                && opening_shape != "btext" && opening_shape != "svg";
		if (has_invalid_dims) {
			echo(str("WARNING: case_openings entry '", opening_ID,
			         "' has negative dimensions (width=", opening_width,
			         "mm, height=", opening_height, "mm) — skipping."));
		}
		if (!has_invalid_dims) {
			translate([cox0+opening_x,coy0+opening_y,0])
			if(depth>0){
				if(opening_ID!="#"){
					cut_opening(opening_width, opening_height, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, o_c_r, opening_other,depth, "keyguard");
				}
				else{
					#cut_opening(opening_width, opening_height, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, o_c_r, opening_other,depth, "keyguard");
				}
			}
			else{
				if(opening_ID!="#"){
					cut_opening_2d(opening_width, opening_height, opening_shape, opening_top_slope,  o_c_r);
				}
				else{
					#cut_opening_2d(opening_width, opening_height, opening_shape, opening_top_slope,  o_c_r);
				}
			}
		} // end if (!has_invalid_dims)
	}

}

// Iterates over the tablet_openings vector and cuts (or highlights with #) each
// opening at the correct position relative to the tablet coordinate origin, applying
// the current orientation rotation.
// @param t_o    Tablet openings vector (rows of opening definitions)
// @param depth  Cut depth in mm
module cut_tablet_openings(t_o,depth){

	for(i = [0 : len(t_o)-1]){
		opening = t_o[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:top slope, 7:bottom slope, 8:left slope, 9:right slope, 10:corner_radius, 11:other
		
		opening_ID = opening[0];
		opening_x = opening[1];
		opening_y = opening[2];
		opening_width = opening[3];
		opening_height = opening[4];
		opening_shape = opening[5];
		opening_top_slope = (opening[6]==0 || is_laser_cut) ? 90 : opening[6];
		opening_bottom_slope = (opening[7]==0 || is_laser_cut) ? 90 : opening[7];
		opening_left_slope = (opening[8]==0 || is_laser_cut) ? 90 : opening[8];
		opening_right_slope = (opening[9]==0 || is_laser_cut) ? 90 : opening[9];
		opening_corner_radius = opening[10];
		opening_other = opening[11];
		
		o_c_r = (opening_width>0 && opening_height>0) ? min(opening_corner_radius,min(opening_width,opening_height)/2) : opening_corner_radius;

		has_invalid_dims = (opening_width < 0 || opening_height < 0)
		                && opening_shape != "ridge" && opening_shape != "ttext"
		                && opening_shape != "btext" && opening_shape != "svg";
		if (has_invalid_dims) {
			echo(str("WARNING: tablet_openings entry '", opening_ID,
			         "' has negative dimensions (width=", opening_width,
			         "mm, height=", opening_height, "mm) — skipping."));
		}
		if (!has_invalid_dims) {
			trans = (is_landscape) ? [tx0+opening_x,ty0+opening_y,0] : [tx0+opening_y,-ty0-opening_x,0];
			translate(trans)
			if(opening_ID!="#"){
				cut_opening(opening_width, opening_height, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, o_c_r, opening_other,depth, "tablet");
			}
			else{
				#cut_opening(opening_width, opening_height, opening_shape, opening_top_slope, opening_bottom_slope, opening_left_slope, opening_right_slope, o_c_r, opening_other,depth, "tablet");
			}
		} // end if (!has_invalid_dims)
	}
}
// Iterates over the ambient-light-sensor openings vector and cuts each opening at
// the correct tablet-relative position, respecting the current orientation.
// @param a_o    ALS openings vector (V2 14-column format rows)
// @param depth  Cut depth in mm
module cut_als_openings(a_o,depth){

	for(i = [0 : len(a_o)-1]){
		r = a_o[i]; // V2: 0:ID, 1:shape, 2:height, 3:width, 4:corner, 5:x, 6:y, 7:cb, 8:anchor, 9:surface, 10:length, 11:thickness, 12:[es], 13:[sp]

		opening_ID     = r[0];
		opening_shape  = r[1];
		opening_height = r[2];
		opening_width  = r[3];
		opening_corner = r[4];
		opening_x      = r[5];
		opening_y      = r[6];
		es             = r[12];

		top_sl = v2_slope(es, 0, opening_shape);
		bot_sl = v2_slope(es, 1, opening_shape);
		lft_sl = v2_slope(es, 2, opening_shape);
		rgt_sl = v2_slope(es, 3, opening_shape);

		trans = (is_landscape) ? [tx0+opening_x, ty0+opening_y, 0] : [tx0+opening_y, -ty0-opening_x, 0];
		translate(trans)
		if(opening_ID != "#"){
			cut_opening(opening_width, opening_height, opening_shape, top_sl, bot_sl, lft_sl, rgt_sl, opening_corner, undef, depth, "tablet");
		}
		else{
			#cut_opening(opening_width, opening_height, opening_shape, top_sl, bot_sl, lft_sl, rgt_sl, opening_corner, undef, depth, "tablet");
		}
	}
}

// Translates to position then cuts with hole_cutter (normal) or hole_cutter_3 +
// 180° rotation (flipped), depending on the flip flag. Centralises the
// flip/non-flip branch that would otherwise be repeated for every shape in
// cut_opening.
// @param tx           X translation
// @param ty           Y translation
// @param tz           Z translation
// @param w            Cut width in mm
// @param h            Cut height in mm
// @param ts           Top-edge slope angle in degrees
// @param bs           Bottom-edge slope angle in degrees
// @param ls           Left-edge slope angle in degrees
// @param rs           Right-edge slope angle in degrees
// @param cr           Corner radius in mm
// @param dep          Cut depth in mm
// @param flip         true = rotate 180° and cut from bottom surface (chamfer lands at cut face); false = cut from top
// @param edge_chamfer Chamfer depth forwarded to hole_cutter (defaults to cec)
module cut_hole(tx, ty, tz, w, h, ts, bs, ls, rs, cr, dep, flip, edge_chamfer=cec, rotation=0){
	translate([tx, ty, tz]){
		if (flip){
			rotate([0,180,0])
			rotate([0,0,rotation])
			hole_cutter(w, h, ts, bs, ls, rs, cr, dep, edge_chamfer);
		}
		else{
			rotate([0,0,rotation])
			hole_cutter(w, h, ts, bs, ls, rs, cr, dep, edge_chamfer);
		}
	}
}

// Dispatches to the correct 3D cutting geometry for a single opening based on its
// shape code, slope parameters, and depth offset. Handles all built-in shape types
// (r, cr, c, lc, hd, lhd, rr, crr, oa1-4, svg, ttext/btext, ridges, etc.).
// @param cut_width     Opening width in mm
// @param cut_height    Opening height in mm
// @param shape         Shape code string (e.g. "r", "c", "rr", "oa1", "svg")
// @param top_slope     Top-edge slope angle in degrees
// @param bottom_slope  Bottom-edge slope angle in degrees
// @param left_slope    Left-edge slope angle in degrees
// @param right_slope   Right-edge slope angle in degrees
// @param corner_radius Corner radius in mm
// @param other         Numeric depth override or text string (shape-dependent)
// @param depth         Full cut depth in mm
// @param type          Coordinate context: "screen", "keyguard", or "tablet"
// V1-shape-code adapter for cut_opening_v2. Translates a V1 shape string
// (r/rr/cr/crr/c/lc/hd/lhd/oa1-4/ttext/btext/svg) into the V2 form
// (shape + anchor + surface + corner) and forwards to the V2-native
// cut_opening_v2 dispatcher. Called from V1 row dispatchers
// (cut_screen_openings, cut_case_openings, cut_tablet_openings,
// cut_als_openings) and by legacy code paths. When V1 O&A support is
// dropped this adapter is one of the few modules that can be deleted
// outright.
module cut_opening(cut_width, cut_height, shape, top_slope, bottom_slope, left_slope, right_slope, corner_radius, other, depth, type, rotation=0){
	anchor  = (shape=="cr" || shape=="crr" || shape=="c" || shape=="hd") ? "c" : undef;
	surface = (shape=="btext") ? "b" : undef;
	v2_shape =
		(shape=="r" || shape=="rr" || shape=="cr" || shape=="crr") ? "r" :
		(shape=="c" || shape=="lc")                                 ? "c" :
		(shape=="hd" || shape=="lhd")                               ? "hd" :
		(shape=="ttext" || shape=="btext")                          ? "text" :
		shape; // oa1-4, svg pass through
	cut_opening_v2(cut_width, cut_height, v2_shape, anchor, surface, top_slope, bottom_slope, left_slope, right_slope, corner_radius, other, depth, type, rotation);
}


// V2-native opening cutter. Dispatches on the V2 shape vocabulary plus anchor,
// surface, and corner parameters carried as their own arguments rather than
// encoded into the shape string. The single "r" branch covers V1 r/cr/rr/crr;
// the "c" branch covers V1 c/lc; "hd" covers hd/lhd; "text" carries surface
// to choose top-face vs bottom-face engraving. Every built-in feature that
// has been migrated calls this module directly; the V1 cut_opening above is
// a thin V1→V2 adapter retained for V1 O&A row dispatchers.
// @param cut_width     Opening width in mm
// @param cut_height    Opening height in mm
// @param shape         V2 shape name: "r", "c", "hd", "oa1-4", "text", "svg"
// @param anchor        undef/"L"/"l" (anchored at left, default) or "C"/"c" (centred)
// @param surface       "T"/"t" (top, default) or "B"/"b" (bottom; "text" only)
// @param top_slope     Top-edge slope angle in degrees
// @param bottom_slope  Bottom-edge slope angle in degrees
// @param left_slope    Left-edge slope angle in degrees
// @param right_slope   Right-edge slope angle in degrees
// @param corner        Corner radius in mm (also outer-arc radius for "oa1-4")
// @param other         Special parameter (text string, SVG filename, depth offset…)
// @param depth         Cut depth in mm; 0 selects laser-cut 2D output
// @param type          Region: "screen", "case", "keyguard", or "tablet"
// @param rotation      Z-rotation of the cut in degrees (default 0)
module cut_opening_v2(cut_width, cut_height, shape, anchor, surface, top_slope, bottom_slope, left_slope, right_slope, corner, other, depth, type, rotation=0){

	other_number = is_num(other);
	other_pos = other_number && other>=0;
	other_neg = other_number && other<0;

	// Region chamfer: screen area uses cell_edge_chamfer (cec), case/keyguard
	// and tablet regions use keyguard_edge_chamfer (kec).
	region_chamfer = (type=="screen") ? cec : kec;

	offset = (is_3d_printed && other_number && other_pos && type=="screen")   ? depth - other :
	         (is_3d_printed && other_number && other_pos && type=="keyguard") ? (depth - other)/2 :
	         (is_3d_printed && other_number && other_neg && type=="screen")   ? -depth-other :
	         (is_3d_printed && other_number && other_neg && type=="keyguard") ? -(depth+other)/2 :
	         0;
	dep  = (is_3d_printed && other_number && other_pos) ? other :
	       (is_3d_printed && other_number && other_neg) ? -other :
	       depth;
	flip = (other_number && other_neg) ? true : false;
	trans = (type=="screen") ? -sat/2 - kt/2 + sat + offset/2 : offset;

	// Centred-vs-L-anchor offset to feed to cut_hole. "C"/"c" anchors at the
	// translate origin; anything else (undef/"L"/"l") anchors at the lower-left
	// corner — the V1 rr/cr distinction is now just (anchor != "c").
	is_c = (anchor == "C" || anchor == "c");

	if (shape == "r"){
		if (cut_width > 0 && cut_height > 0){
			tx = is_c ? 0 : cut_width/2;
			ty = is_c ? 0 : cut_height/2;
			cut_hole(tx, ty, trans, cut_width, cut_height, top_slope, bottom_slope, left_slope, right_slope, corner, dep, flip, region_chamfer, rotation);
		}
	}
	else if (shape == "c"){
		if (cut_height > 0){
			tx = is_c ? 0 : cut_height/2;
			ty = tx;
			if (is_3d_printed){
				cut_hole(tx, ty, trans, cut_height, cut_height, top_slope, bottom_slope, left_slope, right_slope, cut_height/2, dep, flip, region_chamfer, rotation);
			}
			else{
				// Laser-cut path: inflate diameter to clear acrylic for sloped sensor wells.
				aoa = sat_incl_acrylic/tan(top_slope);
				translate([tx, ty, 0])
				hole_cutter(cut_height+aoa*2, cut_height+aoa*2, 90,90,90,90, (cut_height+aoa*2)/2, dep);
			}
		}
	}
	else if (shape == "hd"){
		if (cut_width > 0 && cut_height > 0){
			tx = is_c ? 0 : cut_width/2;
			ty = is_c ? 0 : cut_height/2;
			m  = min(cut_width, cut_height);
			cut_hole(tx, ty, trans, cut_width, cut_height, top_slope, bottom_slope, left_slope, right_slope, m/2, dep, flip, region_chamfer, rotation);
		}
	}
	else if (shape == "oa1"){
		if (corner > 0){
			translate([-corner, -corner, trans])
			create_cutting_tool(0, corner*2, dep+0.05, top_slope, "oa", region_chamfer);
		}
	}
	else if (shape == "oa2"){
		if (corner > 0){
			translate([-corner, corner, trans])
			create_cutting_tool(-90, corner*2, dep+0.05, top_slope, "oa", region_chamfer);
		}
	}
	else if (shape == "oa3"){
		if (corner > 0){
			translate([corner, corner, trans])
			create_cutting_tool(180, corner*2, dep+0.05, top_slope, "oa", region_chamfer);
		}
	}
	else if (shape == "oa4"){
		if (corner > 0){
			translate([corner, -corner, trans])
			create_cutting_tool(90, corner*2, dep+0.05, top_slope, "oa", region_chamfer);
		}
	}
	else if (shape == "text"){
		// Font style, halign, valign carry as numeric codes in the slope columns —
		// matches the existing cut_opening conventions. v2 surface "b" engraves
		// the bottom face (flipped via rotate 180°); anything else engraves the top.
		f_s   = (bottom_slope==1) ? "Liberation Sans:style=Bold" :
		        (bottom_slope==2) ? "Liberation Sans:style=Italic" :
		        (bottom_slope==3) ? "Liberation Sans:style=Bold Italic" :
		                            "Liberation Sans";
		horiz = (left_slope==1) ? "left" :
		        (left_slope==2) ? "center" :
		        (left_slope==3) ? "right" : "left";
		vert  = (right_slope==1) ? "bottom" :
		        (right_slope==2) ? "baseline" :
		        (right_slope==3) ? "center" :
		        (right_slope==4) ? "top" : "bottom";
		is_btext = (surface == "B" || surface == "b");
		if (cut_height > 0 && corner < 0){
			if (is_btext){
				if (is_3d_printed){
					ttrans = (type=="screen") ? -corner-kt/2-ff : -corner-kt/2;
					translate([0,0,ttrans])
					rotate([0,180,0])
					rotate([0,0,top_slope])
					linear_extrude(height = -corner+ff*2)
					text(str(other), font=f_s, size=cut_height, valign=vert, halign=horiz);
				}
			}
			else{
				ttrans = (type=="screen") ? corner-kt/2+sat-.005 : kt/2+corner;
				translate([0,0,ttrans])
				rotate([0,0,top_slope])
				linear_extrude(height = -corner+.01)
				text(str(other), font=f_s, size=cut_height, valign=vert, halign=horiz);
			}
		}
	}
	else if (shape == "svg" && is_3d_printed){
		if (cut_width > 0 && cut_height > 0 && corner < 0){
			strans = (type=="screen") ? corner-kt/2+sat-ff : kt/2+corner;
			translate([0,0,strans])
			rotate([0,0,-top_slope])
			resize([cut_width, cut_height, -corner+ff*2])
			linear_extrude(height=1)
			offset(delta = .005)
			import(file = other, center=true);
		}
	}
}


// V1-shape-code adapter for cut_opening_2d_v2. Translates a V1 shape string
// into V2 form (shape + anchor + corner) and forwards to the V2-native
// cut_opening_2d_v2 dispatcher. Called from V1 row dispatchers and legacy
// engrave_emboss_instruction code paths.
module cut_opening_2d(cut_width, cut_height, shape, top_slope=0, corner_radius=0, rotation=0){
	anchor = (shape=="cr" || shape=="crr" || shape=="c" || shape=="hd") ? "c" : undef;
	v2_shape =
		(shape=="r" || shape=="rr" || shape=="cr" || shape=="crr") ? "r" :
		(shape=="c" || shape=="lc")                                 ? "c" :
		(shape=="hd" || shape=="lhd")                               ? "hd" :
		shape; // oa1-4 pass through
	cut_opening_2d_v2(cut_width, cut_height, v2_shape, anchor, top_slope, corner_radius, rotation);
}


// V2-native 2D opening cutter for laser-cut keyguard outlines. Dispatches on
// V2 shape + anchor + corner. Counterpart to cut_opening_v2 — V1 cut_opening_2d
// above is a thin adapter retained for V1 O&A row dispatchers.
// @param cut_width     Opening width in mm
// @param cut_height    Opening height in mm
// @param shape         V2 shape: "r", "c", "hd", or "oa1-4"
// @param anchor        undef/"L"/"l" (L-anchored) or "C"/"c" (centred)
// @param top_slope     Top-edge slope angle in degrees (controls acrylic inflation for "c")
// @param corner        Corner radius in mm (also outer-arc radius for "oa1-4")
// @param rotation      Z-rotation of the cut in degrees (default 0)
module cut_opening_2d_v2(cut_width, cut_height, shape, anchor, top_slope=0, corner=0, rotation=0){
	is_c = (anchor == "C" || anchor == "c");

	if (shape == "r"){
		if (cut_width > 0 && cut_height > 0){
			tx = is_c ? 0 : cut_width/2;
			ty = is_c ? 0 : cut_height/2;
			translate([tx, ty])
			rotate([0,0,rotation])
			hole_cutter_2d(cut_width, cut_height, corner);
		}
	}
	else if (shape == "c"){
		if (cut_height > 0){
			// Laser-cut circles inflate by sat_incl_acrylic/tan(top_slope) to clear
			// the acrylic for sloped sensor wells.
			aoa = sat_incl_acrylic/tan(top_slope);
			tx = is_c ? 0 : cut_height/2;
			ty = tx;
			translate([tx, ty])
			rotate([0,0,rotation])
			hole_cutter_2d(cut_height+aoa*2, cut_height+aoa*2, (cut_height+aoa*2)/2);
		}
	}
	else if (shape == "hd"){
		if (cut_width > 0 && cut_height > 0){
			m  = min(cut_width, cut_height);
			tx = is_c ? 0 : cut_width/2;
			ty = is_c ? 0 : cut_height/2;
			translate([tx, ty])
			rotate([0,0,rotation])
			hole_cutter_2d(cut_width, cut_height, m/2);
		}
	}
	else if (shape == "oa1"){
		if (corner > 0){
			translate([-corner, -corner])
			create_cutting_tool_2d(0, corner*2);
		}
	}
	else if (shape == "oa2"){
		if (corner > 0){
			translate([-corner, corner])
			create_cutting_tool_2d(-90, corner*2);
		}
	}
	else if (shape == "oa3"){
		if (corner > 0){
			translate([corner, corner])
			create_cutting_tool_2d(180, corner*2);
		}
	}
	else if (shape == "oa4"){
		if (corner > 0){
			translate([corner, -corner])
			create_cutting_tool_2d(90, corner*2);
		}
	}
}

// Iterates over an additions vector and places bump, ridge, SVG, and text additions
// on the keyguard surface at positions relative to the screen or case coordinate origin.
// @param additions  Vector of addition definitions from screen_openings or case_openings
// @param where      Coordinate context: "screen" or "case"
module adding_plastic(additions,where){
	for(i = [0 : len(additions)-1]){
		addition = additions[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:top slope, 7:bottom slope, 8:left slope, 9:right slope, 10:corner_radius, 11:other
		
		addition_ID = addition[0];
		addition_x = addition[1];
		addition_y = addition[2];
		addition_width = addition[3];
		addition_height = addition[4];
		addition_shape = addition[5];
		addition_top_slope = addition[6];
		addition_bottom_slope = addition[7];
		addition_left_slope = addition[8];
		addition_right_slope = addition[9];
		addition_corner_radius = addition[10];
		addition_other = addition[11];
		
		x0 = (where=="screen") ? sx0 : cox0;
		y0 = (where=="screen") ? sy0 : coy0;
		
		trans = (where=="screen") ? -kt/2+sat : 
		        (where=="case" && generate=="keyguard") ? kt/2 :
				keyguard_frame_thickness/2;
		
		if (addition_shape == "bump" || addition_shape == "hridge" || addition_shape == "vridge" || addition_shape == "cridge" || addition_shape == "rridge" || addition_shape == "crridge" || addition_shape == "hdridge" || addition_shape == "ridge" || addition_shape == "aridge1" || addition_shape == "aridge2" || addition_shape == "aridge3" || addition_shape == "aridge4" || addition_shape == "svg" || addition_shape == "ttext") {
	
			addition_width_mm = (using_px && where=="screen") ? addition_width * mpp : addition_width;
			addition_height_mm = (using_px && where=="screen") ? addition_height * mpp : addition_height;
			addition_x_mm = (using_px && where=="screen") ? addition_x * mpp : addition_x;
			addition_corner_radius_mm = (using_px && where=="screen") ? addition_corner_radius * mpp : addition_corner_radius;
			addition_top_slope_mm = (using_px && where=="screen") ? addition_top_slope * mpp : addition_top_slope;
			addition_bottom_slope_mm = (using_px && where=="screen") ? addition_bottom_slope * mpp : addition_bottom_slope;

			if(addition_ID!="#"){
				if (starting_corner_for_screen_measurements == "upper-left" && where=="screen"){
					addition_y_mm = (using_px) ? (shp - addition_y) * mpp : (shm - addition_y);
					translate([x0+addition_x_mm,y0+addition_y_mm,trans-ff])
					place_addition(addition_width_mm, addition_height_mm, addition_shape, addition_top_slope, addition_top_slope_mm, addition_bottom_slope, addition_bottom_slope_mm, addition_left_slope, addition_right_slope, addition_corner_radius_mm, addition_other);
				}
				else{
					addition_y_mm = (using_px && where=="screen") ? addition_y * mpp : addition_y;
					
					translate([x0+addition_x_mm,y0+addition_y_mm,trans-ff])
					place_addition(addition_width_mm, addition_height_mm, addition_shape, addition_top_slope, addition_top_slope_mm, addition_bottom_slope, addition_bottom_slope_mm, addition_left_slope, addition_right_slope, addition_corner_radius_mm, addition_other);
				}
			}
			else{
				if (starting_corner_for_screen_measurements == "upper-left" && where=="screen"){
					addition_y_mm = (using_px) ? (shp - addition_y) * mpp : (shm - addition_y);
					translate([x0+addition_x_mm,y0+addition_y_mm,trans-ff])
					#place_addition(addition_width_mm, addition_height_mm, addition_shape, addition_top_slope, addition_top_slope_mm, addition_bottom_slope, addition_bottom_slope_mm, addition_left_slope, addition_right_slope, addition_corner_radius_mm, addition_other);
				}
				else{
					addition_y_mm = (using_px && where=="screen") ? addition_y * mpp : addition_y;
					
					translate([x0+addition_x_mm,y0+addition_y_mm,trans-ff])
					#place_addition(addition_width_mm, addition_height_mm, addition_shape, addition_top_slope, addition_top_slope_mm, addition_bottom_slope, addition_bottom_slope_mm, addition_left_slope, addition_right_slope, addition_corner_radius_mm, addition_other);
				}
			}
		}
	}
}

// Builds the 3D solid for a single bump, ridge (hridge/vridge/ridge/aridge/cridge/rridge),
// SVG import, or engraved/embossed text addition.
// @param addition_width    Width of the addition in mm
// @param addition_height   Height of the addition in mm
// @param shape             Shape code string (e.g. "bump", "hridge", "svg", "ttext")
// @param top_slope         Slope angle for the addition top in degrees
// @param top_slope_mm      Ridge height in mm (used by ridge-type shapes)
// @param bottom_slope      Slope angle for the addition bottom in degrees
// @param bottom_slope_mm   Ridge base thickness in mm (used by ridge-type shapes)
// @param left_slope        Left-slope / rotation angle in degrees
// @param right_slope       Right-slope angle in degrees
// @param corner_radius     Corner radius or arc radius in mm
// @param other             Text string or secondary numeric value (shape-dependent)
module place_addition(addition_width, addition_height, shape, top_slope, top_slope_mm, bottom_slope, bottom_slope_mm, left_slope, right_slope, corner_radius, other){
	if (shape=="bump"){
		if(addition_width>0){
			difference(){
				sphere(d=addition_width,$fn=40);
				translate([0,0,-addition_width])
				cube([addition_width*2, addition_width*2,addition_width*2],center=true);
			}
		}
	}
	else if (shape=="hridge"){
		if(addition_width>=1 && bottom_slope_mm>=.1 && top_slope_mm>=.1){
			ridge(addition_width, bottom_slope_mm, top_slope_mm,0);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="vridge"){
		if(addition_height>=1 && bottom_slope_mm>=.1 && top_slope_mm>=.1){
			ridge(addition_height, bottom_slope_mm, top_slope_mm,90);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="ridge"){
		if(addition_width>=1 && bottom_slope_mm>=.1 && top_slope_mm>=.1){
			ridge(addition_width, bottom_slope_mm, top_slope_mm,left_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge1"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([-adj,-adj,0])
			rotate([0,0,0])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge2"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([-adj,adj,0])
			rotate([0,0,-90])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge3"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([adj,adj,0])
			rotate([0,0,180])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge4"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([adj,-adj,0])
			rotate([0,0,90])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="cridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([0,0,-sata])
			rotate([0,0,left_slope])
			circular_wall(addition_height,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="rridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([addition_width/2,addition_height/2,-sata])
			rotate([0,0,left_slope])
			rounded_rectangle_wall(addition_width,addition_height,corner_radius,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="crridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([0,0,-sata])
			rotate([0,0,left_slope])
			rounded_rectangle_wall(addition_width,addition_height,corner_radius,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="hdridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([addition_width/2,addition_height/2,-sata])
			rotate([0,0,left_slope])
			rounded_rectangle_wall(addition_width,addition_height,min(addition_width,addition_height)/2,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="svg"){
		if(addition_height>0 && addition_width>0 && corner_radius>0){
			rotate([0,0,-top_slope])
			resize([addition_width,addition_height,corner_radius])
			linear_extrude(height=corner_radius)
			offset(delta = .005)
			import(file = other,center=true);
		}
	}
	else if (shape=="ttext"){
		f_s =
			(bottom_slope==1)? "Liberation Sans:style=Bold"
		  : (bottom_slope==2)? "Liberation Sans:style=Italic"
		  : (bottom_slope==3)? "Liberation Sans:style=Bold Italic"
		  : "Liberation Sans";

		// "left", "center" and "right"
		horiz =
			(left_slope==1)? "left"
		  : (left_slope==2)? "center"
		  : (left_slope==3)? "right"
		  : "left";

		// "top", "center", "baseline" and "bottom"
		vert =
			(right_slope==1)? "bottom"
		  : (right_slope==2)? "baseline"
		  : (right_slope==3)? "center"
		  : (right_slope==4)? "top"
		  : "bottom";

		if(addition_height>0 && corner_radius>0){
			rotate([0,0,top_slope])
			linear_extrude(height=corner_radius)
			text(str(other),font = f_s, size=addition_height,valign=vert,halign=horiz);
		}
	}
}

// V2-independent variant of place_addition(). All parameters identical except for
// the ttext shape, where bottom_slope, left_slope, and right_slope accept V2 schema
// strings directly instead of V1 integer codes:
//   bottom_slope  font style: "bold", "italic", "bold italic", or "" (normal)
//   left_slope    halign:     "left", "center", "right"
//   right_slope   valign:     "bottom", "baseline", "center", "top"
// @param addition_width    Width of the addition in mm
// @param addition_height   Height of the addition in mm
// @param shape             Shape code string (e.g. "bump", "hridge", "svg", "ttext")
// @param top_slope         Slope angle for the addition top in degrees
// @param top_slope_mm      Ridge height in mm (used by ridge-type shapes)
// @param bottom_slope      Ridge base thickness in mm, or font-style string for text
// @param bottom_slope_mm   Ridge base thickness in mm (used by ridge-type shapes)
// @param left_slope        Left-slope / rotation angle in degrees, or halign string for text
// @param right_slope       Right-slope angle in degrees, or valign string for text
// @param corner_radius     Corner radius or arc radius in mm, or text depth in mm
// @param other             Text string or secondary numeric value (shape-dependent)
module place_addition_v2(addition_width, addition_height, shape, top_slope, top_slope_mm, bottom_slope, bottom_slope_mm, left_slope, right_slope, corner_radius, other, surface=undef){
	if (shape=="bump"){
		if(addition_width>0){
			difference(){
				sphere(d=addition_width,$fn=40);
				translate([0,0,-addition_width])
				cube([addition_width*2, addition_width*2,addition_width*2],center=true);
			}
		}
	}
	else if (shape=="hridge"){
		if(addition_width>=1 && bottom_slope_mm>=.1 && top_slope_mm>=.1){
			ridge(addition_width, bottom_slope_mm, top_slope_mm,0);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="vridge"){
		if(addition_height>=1 && bottom_slope_mm>=.1 && top_slope_mm>=.1){
			ridge(addition_height, bottom_slope_mm, top_slope_mm,90);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="ridge"){
		if(addition_width>=1 && bottom_slope_mm>=.1 && top_slope_mm>=.1){
			ridge(addition_width, bottom_slope_mm, top_slope_mm,left_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge1"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([-adj,-adj,0])
			rotate([0,0,0])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge2"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([-adj,adj,0])
			rotate([0,0,-90])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge3"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([adj,adj,0])
			rotate([0,0,180])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="aridge4"){
		if(corner_radius>=1 && bottom_slope>=.1 && top_slope>=.1){
			adj = corner_radius;
			translate([adj,-adj,0])
			rotate([0,0,90])
			aridge(corner_radius, bottom_slope, top_slope);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="cridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([0,0,-sata])
			rotate([0,0,left_slope])
			circular_wall(addition_height,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="rridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([addition_width/2,addition_height/2,-sata])
			rotate([0,0,left_slope])
			rounded_rectangle_wall(addition_width,addition_height,corner_radius,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="hdridge"){
		if(addition_height>=1 && bottom_slope>=.1 && top_slope>=.1){
			translate([addition_width/2,addition_height/2,-sata])
			rotate([0,0,left_slope])
			rounded_rectangle_wall(addition_width,addition_height,min(addition_width,addition_height)/2,bottom_slope_mm,top_slope_mm+sata);
		}
		else{ echo(str("WARNING: screen_openings/case_openings shape '", shape, "' has invalid dimensions or slopes — skipping.")); }
	}
	else if (shape=="svg"){
		if(addition_height>0 && addition_width>0 && corner_radius>0){
			rotate([0,0,-top_slope])
			resize([addition_width,addition_height,corner_radius])
			linear_extrude(height=corner_radius)
			offset(delta = .005)
			import(file = other,center=true);
		}
	}
	else if (shape=="text"){
		// V2 form: shape="text" + surface "t"/"b". Currently only top-face emboss
		// (surface != "b") is implemented; bottom-face emboss falls through silently,
		// matching the pre-V2-native behaviour where place_addition_v2 had no "btext"
		// branch.
		is_btext = (surface == "B" || surface == "b");
		f_s =
			(bottom_slope=="bold")        ? "Liberation Sans:style=Bold"
		  : (bottom_slope=="italic")      ? "Liberation Sans:style=Italic"
		  : (bottom_slope=="bold italic") ? "Liberation Sans:style=Bold Italic"
		  : "Liberation Sans";

		horiz =
			(left_slope=="left")   ? "left"
		  : (left_slope=="center") ? "center"
		  : (left_slope=="right")  ? "right"
		  : "left";

		vert =
			(right_slope=="bottom")   ? "bottom"
		  : (right_slope=="baseline") ? "baseline"
		  : (right_slope=="center")   ? "center"
		  : (right_slope=="top")      ? "top"
		  : "bottom";

		if(!is_btext && addition_height>0 && corner_radius>0){
			rotate([0,0,top_slope])
			linear_extrude(height=corner_radius)
			text(str(other),font = f_s, size=addition_height,valign=vert,halign=horiz);
		}
	}
}

// Creates a horizontal raised ridge with a trapezoidal cross-section and chamfered
// end caps, rotated by the specified angle.
// @param length     Length of the ridge in mm
// @param thickness  Base width (thickness) of the ridge in mm
// @param hi         Ridge height above the surface in mm
// @param rot        Z-axis rotation in degrees (0 = horizontal ridge along X axis)
module hridge(length, thickness, hi,rot){
	hite = hi + sata;
	rotate([0,0,rot])
	translate([0,-thickness/2,-sata])
	difference(){
		translate([0,0,0])
		rotate([90,0,0])
		rotate([0,90,0])
		linear_extrude(height=length)
		polygon([[0,0],[thickness,0],[thickness,hite-.5],[thickness-.5,hite],[.5,hite],[0,hite-.5]]);
		
		translate([0-ff,thickness,hite-.5+ff])
		rotate([90,0,0])
		linear_extrude(height=thickness)
		polygon([[0,0],[.5,.5],[0,.5]]);
	
		translate([length+ff,thickness,hite-.5+ff])
		rotate([90,0,0])
		linear_extrude(height=thickness)
		polygon([[0,0],[-.5,.5],[0,.5]]);
	}
}

// Creates a vertical raised ridge with a trapezoidal cross-section and chamfered
// end caps, oriented along the Y axis.
// @param length     Length of the ridge in mm
// @param thickness  Base width (thickness) of the ridge in mm
// @param hi         Ridge height above the surface in mm
module vridge(length, thickness, hi){
	hite = hi + sata;
	translate([thickness/2,0,-sata])
	difference(){
		rotate([0,0,180])
		rotate([90,0,0])
		linear_extrude(height=length)
		polygon([[0,0],[thickness,0],[thickness,hite-.5],[thickness-.5,hite],[.5,hite],[0,hite-.5]]);
		
		translate([0,length+ff,hite-.5+ff])
		rotate([0,0,-90])
		rotate([90,0,0])
		linear_extrude(height=thickness)
		polygon([[0,0],[.5,.5],[0,.5]]);
	
		translate([0,0-ff,hite-.5+ff])
		rotate([0,0,-90])
		rotate([90,0,0])
		linear_extrude(height=thickness)
		polygon([[0,0],[-.5,.5],[0,.5]]);
	}
}

// Creates a raised ridge with a trapezoidal cross-section, chamfered end caps, and
// an arbitrary rotation angle. Functionally identical to hridge but exposed as a
// general-purpose ridge primitive.
// @param length     Length of the ridge in mm
// @param thickness  Base width (thickness) of the ridge in mm
// @param hi         Ridge height above the surface in mm
// @param rot        Z-axis rotation in degrees
module ridge(length, thickness, hi,rot){
	hite = hi + sata;
	rotate([0,0,rot])
	translate([0,-thickness/2,-sata])
	difference(){
		translate([0,0,0])
		rotate([90,0,0])
		rotate([0,90,0])
		linear_extrude(height=length)
		polygon([[0,0],[thickness,0],[thickness,hite-.5],[thickness-.5,hite],[.5,hite],[0,hite-.5]]);
		
		translate([0-ff,thickness,hite-.5+ff])
		rotate([90,0,0])
		linear_extrude(height=thickness)
		polygon([[0,0],[.5,.5],[0,.5]]);
	
		translate([length+ff,thickness,hite-.5+ff])
		rotate([90,0,0])
		linear_extrude(height=thickness)
		polygon([[0,0],[-.5,.5],[0,.5]]);
	}
}

// Creates a quarter-arc ridge segment (one corner of a rounded-rectangle ridge),
// used by the aridge1-4 addition shapes.
// @param radius     Arc radius in mm
// @param thickness  Ridge base width in mm
// @param hi         Ridge height above the surface in mm
module aridge(radius, thickness, hi){
	hite = hi + sata;
	translate([-1,-1,-sata])
	difference(){
		translate([-thickness+1,-thickness+1,0])
		rounded_rectangle_wall((radius+thickness)*2,(radius+thickness)*2,radius,thickness,hite);
	
		translate([0,-(radius+thickness)*2,hite/2])
		cube([(radius+thickness)*8,(radius+thickness)*4,hite+2],center=true);
		
		translate([-(radius+thickness)*2,0,hite/2])
		cube([(radius+thickness)*4,(radius+thickness)*8,hite+2],center=true);
	}
}

// Builds the full clip-on strap clip body including the base leg, vertical leg,
// reach leg, spur, chamfers, optional bumper recess, and strap slots.
// @param clip_reach  How far the reach leg extends over the case edge in mm
// @param clip_width  Width of the clip in mm (parallel to the case edge)
module create_clip(clip_reach,clip_width){
	base_thickness = 4;
	clip_thickness = 3;
	strap_cut = clip_width-4;

	difference(){
		union(){
			//base leg
			translate([-clip_bottom_length,-base_thickness,0])
			cube([clip_bottom_length+clip_thickness,base_thickness,clip_width]);

			//vertical leg
			translate([0,0,0])
			cube([clip_thickness,case_thick,clip_width]);

			//reach leg
			translate([-clip_reach,case_thick,0])
			cube([clip_reach+clip_thickness,clip_thickness,clip_width]);

			//spur
			translate([-clip_reach,case_thick,0])
			linear_extrude(height = clip_width)
			polygon(points=[[0,0],[1,-3],[3,-3],[2,0]]);
		}

		//chamfers for short edges of reach leg
		translate([clip_thickness-2,case_thick+clip_thickness-2,-ff])
		linear_extrude(height = clip_width + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([-clip_reach-ff,case_thick+clip_thickness-2,-ff])
		linear_extrude(height = clip_width + ff*2)
		polygon(points=[[0,0],[0,2.1],[2.1,2.1]]);

		//chamfers for vertical leg
		translate([1,-base_thickness-ff,2])
		rotate([-90,0,0])
		linear_extrude(height = base_thickness+case_thick+clip_thickness + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([1,-base_thickness-ff,clip_width+ff])
		rotate([-90,0,0])
		linear_extrude(height = base_thickness+case_thick+clip_thickness + ff*2)
		polygon(points=[[0,0],[2.1,0],[2.1,2.1]]);

		//chamfers for long edges of reach leg
		translate([-clip_reach,case_thick+clip_thickness-2,2-ff])
		rotate([0,90,0])
		linear_extrude(height = clip_reach+clip_thickness + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([clip_thickness,case_thick+clip_thickness+ff,clip_width-2])
		rotate([0,-90,0])
		linear_extrude(height = clip_reach+clip_thickness + ff*2)
		polygon(points=[[0,0],[2.1,0],[2.1,-2.1]]);
		
		//recess for bumper
		if (clip_bottom_length>=30){
			translate([-8+clip_thickness,-base_thickness+1,clip_width/2])
			rotate([90,0,0])
			cylinder(d=11,h=1.05);
		}

		//slots for strap
		translate([-clip_bottom_length+7.5-ff,0,clip_width/2])
		union(){
			translate([0,-5,0])
			cube([15,2,strap_cut],center=true);
			
			translate([0,0,0])
			cube([15,2,strap_cut],center=true);
			
			translate([-2.5,-3,0])
			cube([5,6,strap_cut],center=true);
			
			translate([5,-3,0])
			cube([5,6,strap_cut],center=true);
		}
	}
}

// Builds the mini clip-on strap clip variant 1: vertical leg + reach leg + spur,
// without a base leg. Used for thinner case edges.
// @param clip_reach  How far the reach leg extends over the case edge in mm
// @param clip_width  Width of the clip in mm
module create_mini_clip1(clip_reach,clip_width){
	base_thickness = 4;
	clip_thickness = 5;
	strap_cut = clip_width-4;

	difference(){
		union(){
			//vertical leg
			translate([0,0,0])
			cube([clip_thickness,case_thick,clip_width]);

			//reach leg
			translate([-clip_reach,case_thick,0])
			cube([clip_reach+clip_thickness,clip_thickness,clip_width]);

			//spur
			translate([-clip_reach,case_thick,0])
			linear_extrude(height = clip_width)
			polygon(points=[[0,0],[1,-3],[3,-3],[2,0]]);
		}

		//chamfers for short edges of reach leg
		translate([clip_thickness-2,case_thick+clip_thickness-2,-ff])
		linear_extrude(height = clip_width + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([-clip_reach-ff,case_thick+clip_thickness-2,-ff])
		linear_extrude(height = clip_width + ff*2)
		polygon(points=[[0,0],[0,2.1],[2.1,2.1]]);

		//chamfers for vertical leg
		translate([3,-base_thickness-ff,2])
		rotate([-90,0,0])
		linear_extrude(height = base_thickness+case_thick+clip_thickness + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([3,-base_thickness-ff,clip_width+ff])
		rotate([-90,0,0])
		linear_extrude(height = base_thickness+case_thick+clip_thickness + ff*2)
		polygon(points=[[0,0],[2.1,0],[2.1,2.1]]);

		//chamfers for long edges of reach leg
		translate([-clip_reach,case_thick+clip_thickness-2,2-ff])
		rotate([0,90,0])
		linear_extrude(height = clip_reach+clip_thickness + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([clip_thickness,case_thick+clip_thickness+ff,clip_width-2])
		rotate([0,-90,0])
		linear_extrude(height = clip_reach+clip_thickness + ff*2)
		polygon(points=[[0,0],[2.1,0],[2.1,-2.1]]);
		
		//slots for strap
		translate([-1+ff,7.5-ff,clip_width/2])
		rotate([0,0,90])
		union(){
			translate([0,-1,0])
			cube([15,2,strap_cut],center=true);
			
			translate([-2.5,-3,0])
			cube([5,6,strap_cut],center=true);
			
			translate([5,-3,0])
			cube([5,6,strap_cut],center=true);
		}
	}
}

// Builds the mini clip-on strap clip variant 2: reach leg + spur only (no base or
// vertical leg). Used for the thinnest case edges.
// @param clip_reach  How far the reach leg extends over the case edge in mm
// @param clip_width  Width of the clip in mm
module create_mini_clip2(clip_reach,clip_width){
	base_thickness = 4;
	clip_thickness = 5;
	strap_cut = clip_width-4;

	difference(){
		union(){
			//reach leg
			translate([-clip_reach,case_thick,0])
			cube([clip_reach+clip_thickness,clip_thickness,clip_width]);

			//spur
			translate([-clip_reach,case_thick,0])
			linear_extrude(height = clip_width)
			polygon(points=[[0,0],[1,-3],[3,-3],[2,0]]);
		}

		//chamfers for short edges of reach leg
		translate([clip_thickness-2,case_thick+clip_thickness-2,-ff])
		linear_extrude(height = clip_width + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([-clip_reach-ff,case_thick+clip_thickness-2,-ff])
		linear_extrude(height = clip_width + ff*2)
		polygon(points=[[0,0],[0,2.1],[2.1,2.1]]);

		//chamfers for vertical leg
		translate([3,-base_thickness-ff,2])
		rotate([-90,0,0])
		linear_extrude(height = base_thickness+case_thick+clip_thickness + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([3,-base_thickness-ff,clip_width+ff])
		rotate([-90,0,0])
		linear_extrude(height = base_thickness+case_thick+clip_thickness + ff*2)
		polygon(points=[[0,0],[2.1,0],[2.1,2.1]]);

		//chamfers for long edges of reach leg
		translate([-clip_reach,case_thick+clip_thickness-2,2-ff])
		rotate([0,90,0])
		linear_extrude(height = clip_reach+clip_thickness + ff*2)
		polygon(points=[[0,2.1],[2.1,2.1],[2.1,0]]);
		translate([clip_thickness,case_thick+clip_thickness+ff,clip_width-2])
		rotate([0,-90,0])
		linear_extrude(height = clip_reach+clip_thickness + ff*2)
		polygon(points=[[0,0],[2.1,0],[2.1,-2.1]]);
		
		//slots for strap
		translate([-2.4,case_thickness-1+ff,clip_width/2])
		rotate([180,180,0])
		union(){
			translate([0,-1,0])
			cube([15,2,strap_cut],center=true);
			
			translate([-2.5,-5,0])
			cube([5,6,strap_cut],center=true);
			
			translate([5,-5,0])
			cube([5,6,strap_cut],center=true);
		}
	}
}

// Builds the base keyguard blank (extruded case-opening shape) with optional
// sloped edge, shelf lip, and per-edge chamfer slices. Used by both keyguard()
// and keyguard_frame() as their starting solid.
// @param wid        Width of the blank in mm
// @param hei        Height of the blank in mm
// @param crad       Corner radius (scalar or 4-element vector) in mm
// @param thickness  Thickness of the blank in mm (0 = 2D for laser cutting)
// @param cheat      "yes" suppresses case additions that conflict with the frame geometry
module base_keyguard(wid,hei,crad,thickness,cheat){
	//consider moving this logic to global scope
	widt = (add_sloped_keyguard_edge=="no") ? wid :
			(extend_lip_to_edge_of_case=="no") ? cow + hsew*2: case_width;
	heig = (add_sloped_keyguard_edge=="no") ? hei :
			(extend_lip_to_edge_of_case=="no") ? coh + vsew*2: case_height;
	radi = (add_sloped_keyguard_edge=="no") ? crad :
			(extend_lip_to_edge_of_case=="no") ? [cocr+sew,cocr+sew,cocr+sew,cocr+sew] : 
											  [case_corner_radius,case_corner_radius,case_corner_radius,case_corner_radius];
											  
	translate([0,0,-thickness/2])
	difference(){
		case_opening_blank(widt,heig,radi,thickness,cheat);
		
		if (is_3d_printed && add_sloped_keyguard_edge=="yes"){
			difference(){
				translate([0,0,-fudge])
				case_opening_blank(widt+5,heig+5,radi,case_to_screen_depth+fudge*2,cheat);
				
				union(){
					hull(){
						translate([0,0,case_to_screen_depth+fudge])
						linear_extrude(height=ff)
						offset(r=cocr+sew)
						square([cow-cocr*2 + 2*(hsew-sew), coh-cocr*2 + 2*(vsew-sew)],true);

						translate([0,0,sloped_edge_starting_height])
						linear_extrude(height=ff)
						offset(r=cocr)
						square([cow-cocr*2,coh-cocr*2],true);
					}
								
					linear_extrude(height=sloped_edge_starting_height)
					offset(r=cocr)
					square([cow-cocr*2,coh-cocr*2],true);
				}
				
				translate([0,0,-5])
				case_opening_blank(wid,hei,crad,thickness+10,cheat);
			}
		}
		
		if(case_to_slope_depth>0){
			translate([0,0,case_to_screen_depth-fudge])
			difference(){
				case_opening_blank(widt+fudge,heig+fudge,radi,case_to_slope_depth,cheat);

				translate([0,0,-fudge])
				case_opening_blank((cow + hsew*2),(coh + vsew*2),[cocr+sew,cocr+sew,cocr+sew,cocr+sew],case_to_slope_depth+2*fudge,cheat);

			}
		}

		if (is_3d_printed){  //add chamfer
			for (i = [1:1:chamfer_slices]) { 
				chamfer_slice(i,widt,heig,radi,thickness,cheat);
			}
		}
	}
}

// Generates a single chamfer step (a thin ring that is slightly wider at its layer
// position) used to approximate a chamfered edge around the keyguard perimeter.
// @param layer          Step index (1 = outermost, chamfer_slices = innermost)
// @param width          Overall blank width in mm
// @param height         Overall blank height in mm
// @param corner_radius  Corner radius of the blank in mm
// @param thickness      Keyguard thickness in mm
// @param cheat          Passed through to case_opening_blank_2d
module chamfer_slice(layer,width,height,corner_radius,thickness, cheat){
	slice_width = chamfer_slice_size*(chamfer_slices-layer+1);
	slice_height = thickness-chamfer_slice_size*layer;
	
	translate([0,0,slice_height])
	linear_extrude(height=chamfer_slice_size+ff)
	difference(){
		offset(delta=ff)
		case_opening_blank_2d(width,height,corner_radius,cheat);

		offset(delta=-slice_width)
		case_opening_blank_2d(width,height,corner_radius,cheat);
	}
}

// Extrudes the 2D case-opening profile to the specified thickness, or returns the
// 2D profile directly when thickness is 0 (laser-cut mode).
// @param width          Shape width in mm
// @param heigt          Shape height in mm
// @param corner_radius  Corner radius (scalar or 4-element vector) in mm
// @param thickness      Extrusion height in mm (0 = 2D output)
// @param cheat          Passed through to case_opening_blank_2d
module case_opening_blank(width,heigt,corner_radius,thickness,cheat){
	if (thickness > 0){
		linear_extrude(height=thickness)
		case_opening_blank_2d(width,heigt,corner_radius,cheat);
	}
	else{ //to be laser cut
		case_opening_blank_2d(width,heigt,corner_radius,cheat);
	}
}

// Generates the 2D footprint of the keyguard blank — a rounded rectangle that may
// have per-corner radii — including any full-height case addition shapes added to or
// subtracted from the outline.
// @param shape_x  Width of the blank in mm
// @param shape_y  Height of the blank in mm
// @param c_r      Corner radius: scalar (uniform) or 4-element vector [TL,TR,BL,BR] in mm
// @param cheat    "yes" suppresses case addition shapes in the outline
module case_opening_blank_2d(shape_x,shape_y,c_r,cheat){
	same_radii = (c_r[0]==c_r[1] && c_r[0]==c_r[2] && c_r[0]==c_r[3]); // test to see if all radii are the same
	difference(){
		if (same_radii){
			union(){
				// Core keyguard outline — built via the V2 case_additions per-shape
				// dispatcher so the keyguard footprint is conceptually a "seed"
				// case_addition that user-supplied case_additions union with below.
				build_addition(shape_x, shape_y, "r", c_r[0]);

				if(!is_undef(case_additions) && len(case_additions)>0 && add_symmetric_openings=="no" && !(generate=="keyguard" && has_frame) && has_case && cheat=="no"){
					if(is_v2(case_additions)) add_case_full_height_shapes_v2(case_additions,"add"); else add_case_full_height_shapes(case_additions,"add");
				}
				if(len(m_c_a)>0 && add_symmetric_openings=="no" && !(generate=="keyguard" && has_frame) && has_case && cheat=="no"){
					if(is_v2(m_c_a)) add_case_full_height_shapes_v2(m_c_a,"add"); else add_case_full_height_shapes(m_c_a,"add");
				}
			}
		}
		else{
			difference(){
				square([shape_x,shape_y],center=true);
			
				translate([-shape_x/2+c_r[0],shape_y/2-c_r[0]])
				create_cutting_tool_2d(90,c_r[0]*2);
			
				translate([shape_x/2-c_r[1],shape_y/2-c_r[1]])
				create_cutting_tool_2d(0,c_r[1]*2);
			
				translate([-shape_x/2+c_r[2],-shape_y/2+c_r[2]])
				create_cutting_tool_2d(180,c_r[2]*2);
			
				translate([shape_x/2-c_r[3],-shape_y/2+c_r[3]])
				create_cutting_tool_2d(-90,c_r[3]*2);
			}
		}

		if(!is_undef(case_additions) && len(case_additions)>0 && add_symmetric_openings=="no" && !(generate=="keyguard" && has_frame) && has_case && cheat=="no"){
			if(is_v2(case_additions)) add_case_full_height_shapes_v2(case_additions,"sub"); else add_case_full_height_shapes(case_additions,"sub");
		}
		if(len(m_c_a)>0 && add_symmetric_openings=="no" && !(generate=="keyguard" && has_frame) && has_case && cheat=="no"){
			if(is_v2(m_c_a)) add_case_full_height_shapes_v2(m_c_a,"sub"); else add_case_full_height_shapes(m_c_a,"sub");
		}

		if(has_case && m_m=="Posts"){
			translate([0,coh/2+25-mount_to_top_of_opening_distance,0])
			square([cow+1,50],center=true);
		}
	}
}

// Processes the case additions vector in 2D, either adding shapes (type="add") or
// subtracting shapes whose name starts with "-" (type="sub") from the keyguard outline.
// @param c_a   Case additions vector (rows of addition definitions)
// @param type  "add" to union shapes into the outline; "sub" to cut them out
module add_case_full_height_shapes(c_a,type){
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	
	for(i = [0 : len(c_a)-1]){
		addition = c_a[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:thickness, 7:trim_above, 8:trim_below, 9:trim_to_right, 10:trim_to_left, 11:corner_radius, 12:other
			
		addition_ID = addition[0];		
		addition_x = addition[1];
		addition_y = addition[2];
		addition_width = addition[3];
		addition_height = addition[4];
		addition_shape = addition[5];
		addition_thickness = addition[6];
		addition_trim_above = addition[7];
		addition_trim_below = addition[8];
		addition_trim_to_right = addition[9];
		addition_trim_to_left = addition[10];
		addition_corner_radius = addition[11];
			
		if(addition_thickness==0 && addition_shape != undef){
			if(addition_ID=="#"){
				if(type=="add" && search("-",addition_shape)==[]){
					difference(){
						translate([x0+addition_x ,y0+addition_y])
						#build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);

						if (addition_trim_below > -999){
							translate([0,-kh+addition_trim_below])
							square([kw*2,kh*2],center=true);
						}
						if (addition_trim_above > -999){
							translate([0,kh+addition_trim_above])
							square([kw*2,kh*2],center=true);
						}
						if (addition_trim_to_right > -999){
							translate([addition_trim_to_right,0])
							square([kw*2,kh*2],center=true);
						}
						if (addition_trim_to_left > -999){
							translate([-kw+addition_trim_to_left,0])
							square([kw*2,kh*2],center=true);
						}
					}
				}
				
				if(type=="sub" && search("-",addition_shape)!=[]){
					translate([x0+addition_x ,y0+addition_y])
					#build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);
				}
			}
			else{
				if(type=="add" && search("-",addition_shape)==[]){
					if(addition_thickness==0){
						difference(){
							translate([x0+addition_x ,y0+addition_y])
							build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);

							if (addition_trim_below > -999){
								translate([0,-kh+addition_trim_below])
								square([kw*2,kh*2],center=true);
							}
							if (addition_trim_above > -999){
								translate([0,kh+addition_trim_above])
								square([kw*2,kh*2],center=true);
							}
							if (addition_trim_to_right > -999){
								translate([addition_trim_to_right,0])
								square([kw*2,kh*2],center=true);
							}
							if (addition_trim_to_left > -999){
								translate([-kw+addition_trim_to_left,0])
								square([kw*2,kh*2],center=true);
							}
						}
					}
				}

				if(type=="sub" && search("-",addition_shape)!=[]){
					translate([x0+addition_x ,y0+addition_y])
					build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);
				}
			}
		}
	}
}

// Generates the 2D footprint for a single case addition or subtraction shape
// (rectangle, circle, triangle, fillet, crescent, outer-arc corner, etc.) centred
// or anchored according to the shape code convention.
// @param addition_width          Width of the shape in mm
// @param addition_height         Height of the shape in mm
// @param addition_shape          Shape code string (e.g. "r", "cr", "c", "rr", "oa1")
// @param addition_corner_radius  Corner radius in mm (used by rr/crr/oa shapes)
module build_addition(addition_width, addition_height, addition_shape, addition_corner_radius){
	if (addition_shape=="r" || addition_shape=="-r"){
		// V2: "r" in case_additions is always centre-anchored; corner radius optional
		if (addition_width > 0 && addition_height > 0){
			if (addition_corner_radius > 0) {
				rounded_rect(addition_width, addition_height, min(addition_corner_radius, min(addition_width, addition_height)/2));
			} else {
				square([addition_width,addition_height],center=true);
			}
		}
	}
	else if (addition_shape=="cr" || addition_shape=="-cr"){
		if (addition_width > 0 && addition_height > 0){
			square([addition_width,addition_height],center=true);
		}
	}
	else if (addition_shape=="r1" || addition_shape=="-r1"){
		if (addition_width > 0 && addition_height > 0){
			if (addition_corner_radius > 0) {
				translate([0,-ff])
				half_rounded_rectangle(addition_height, addition_width, addition_corner_radius);
			} else {
				translate([0,addition_height/2-ff])
				square([addition_width,addition_height],center=true);
			}
		}
	}
	else if (addition_shape=="r2" || addition_shape=="-r2"){
		if (addition_width > 0 && addition_height > 0){
			if (addition_corner_radius > 0) {
				translate([-ff,0])
				rotate([0,0,-90])
				half_rounded_rectangle(addition_width, addition_height, addition_corner_radius);
			} else {
				translate([addition_width/2-ff,0])
				square([addition_width,addition_height],center=true);
			}
		}
	}
	else if (addition_shape=="r3" || addition_shape=="-r3"){
		if (addition_width > 0 && addition_height > 0){
			if (addition_corner_radius > 0) {
				translate([0,ff])
				rotate([0,0,180])
				half_rounded_rectangle(addition_height, addition_width, addition_corner_radius);
			} else {
				translate([0,-addition_height/2+ff])
				square([addition_width,addition_height],center=true);
			}
		}
	}
	else if (addition_shape=="r4" || addition_shape=="-r4"){
		if (addition_width > 0 && addition_height > 0){
			if (addition_corner_radius > 0) {
				translate([ff,0])
				rotate([0,0,90])
				half_rounded_rectangle(addition_width, addition_height, addition_corner_radius);
			} else {
				translate([-addition_width/2+ff,0])
				square([addition_width,addition_height],center=true);
			}
		}
	}
	else if (addition_shape=="c" || addition_shape=="-c"){
		if (addition_height > 0){
			circle(d=addition_height);
		}
	}
	else if (addition_shape=="t1" || addition_shape=="-t1"){
		translate([-ff,-ff])
		if (addition_width > 0 && addition_height > 0){
			polygon([[0,0],[addition_width,0],[0,addition_height]]);
		}
	}
	else if (addition_shape=="t2" || addition_shape=="-t2"){
		translate([-ff,ff])
		if (addition_width > 0 && addition_height > 0){
			polygon([[0,0],[addition_width,0],[0,-addition_height]]);
		}
	}
	else if (addition_shape=="t4" || addition_shape=="-t4"){
		translate([ff,-ff])
		if (addition_width > 0 && addition_height > 0){
			polygon([[0,0],[-addition_width,0],[0,addition_height]]);
		}
	}
	else if (addition_shape=="t3" || addition_shape=="-t3"){
		translate([ff,ff])
		if (addition_width > 0 && addition_height > 0){
			polygon([[0,0],[-addition_width,0],[0,-addition_height]]);
		}
	}
	else if (addition_shape=="f1" || addition_shape=="-f1"){
		translate([-ff,-ff])
		if (addition_width > 0){
			difference(){
				translate([0,0])
				square([addition_width,addition_width]);
				translate([addition_width,addition_width])
				circle(r=addition_width);
			}
		}
	}
	else if (addition_shape=="f2" || addition_shape=="-f2"){
		translate([-ff,ff])
		if (addition_width > 0){
			difference(){
				translate([0,-addition_width])
				square([addition_width,addition_width]);
				translate([addition_width,-addition_width])
				circle(r=addition_width);
			}
		}
	}
	else if (addition_shape=="f3" || addition_shape=="-f3"){
		translate([ff,ff])
		if (addition_width > 0){
			difference(){
				translate([-addition_width,-addition_width])
				square([addition_width,addition_width]);
				translate([-addition_width,-addition_width])
				circle(r=addition_width);
			}
		}
	}
	else if (addition_shape=="f4" || addition_shape=="-f4"){
		translate([ff,-ff])
		if (addition_width > 0){
			difference(){
				translate([-addition_width,0])
				square([addition_width,addition_width]);
				translate([-addition_width,addition_width])
				circle(r=addition_width);
			}
		}
	}
	else if (addition_shape=="cm1" || addition_shape=="-cm1"){
		if (addition_width > 0 && addition_height > 0){
			$fn=360;

			d1 = addition_height;
			d2 = addition_width/2;
			Cx = (d2*d2)/(2*d1) - d1/2;
			radius = Cx + d1;

			translate([0,-ff])
			rotate([0,0,90])
			difference(){
				translate([-Cx,0])
				circle(r=radius);

				translate([-radius*2-10,-radius-5-ff])
				square([radius*2+10,radius*2+10]);

			}
		}
		else{
			echo(str("WARNING: case_additions shape '", addition_shape, "' has zero or negative dimensions (width=", addition_width, ", height=", addition_height, ") — skipping."));
		}
	}
	else if (addition_shape=="cm2" || addition_shape=="-cm2"){
		if (addition_width > 0 && addition_height > 0){
			$fn=360;

			d1 = addition_width;
			d2 = addition_height/2;
			Cx = (d2*d2)/(2*d1) - d1/2;
			radius = Cx + d1;

			translate([-ff,0])
			difference(){
				translate([-Cx,0])
				circle(r=radius);

				translate([-radius*2-10-ff,-radius-5])
				square([radius*2+10,radius*2+10]);
			}
		}
		else{
			echo(str("WARNING: case_additions shape '", addition_shape, "' has zero or negative dimensions (width=", addition_width, ", height=", addition_height, ") — skipping."));
		}
	}
	else if (addition_shape=="cm3" || addition_shape=="-cm3"){
		if (addition_width > 0 && addition_height > 0){
			$fn=360;

			d1 = addition_height;
			d2 = addition_width/2;
			Cx = (d2*d2)/(2*d1) - d1/2;
			radius = Cx + d1;

			translate([0,ff])
			rotate([0,0,-90])
			difference(){
				translate([-Cx,0])
				circle(r=radius);

				translate([-radius*2-10,-radius-5+ff])
				square([radius*2+10,radius*2+10]);

			}
		}
		else{
			echo(str("WARNING: case_additions shape '", addition_shape, "' has zero or negative dimensions (width=", addition_width, ", height=", addition_height, ") — skipping."));
		}
	}
	else if (addition_shape=="cm4" || addition_shape=="-cm4"){
		if (addition_width > 0 && addition_height > 0){
			$fn=360;

			d1 = addition_width;
			d2 = addition_height/2;
			Cx = (d2*d2)/(2*d1) - d1/2;
			radius = Cx + d1;

			translate([ff,0])
			difference(){
				translate([Cx,0])
				circle(r=radius);

				translate([0+ff,-radius-5])
				square([radius*2+10,radius*2+10]);
			}
		}
		else{
			echo(str("WARNING: case_additions shape '", addition_shape, "' has zero or negative dimensions (width=", addition_width, ", height=", addition_height, ") — skipping."));
		}
	}
	else if (addition_shape=="rr" || addition_shape=="-rr"){
		if (addition_width > 0 && addition_height > 0){
			translate([addition_corner_radius,addition_corner_radius])
			offset(r=addition_corner_radius)
			square([addition_width-addition_corner_radius*2,addition_height-addition_corner_radius*2]);
		}
	}
	else if (addition_shape=="crr" || addition_shape=="-crr"){
		if (addition_width > 0 && addition_height > 0){
			offset(r=addition_corner_radius)
			square([addition_width-addition_corner_radius*2,addition_height-addition_corner_radius*2],center=true);
		}
	}
	else if (addition_shape=="rr1" || addition_shape=="-rr1"){
		rotate([0,0,0])
		translate([0,-ff])
		if (addition_width > 0 && addition_height > 0){
			half_rounded_rectangle(addition_height,addition_width,addition_corner_radius);
		}
	}
	else if (addition_shape=="rr2" || addition_shape=="-rr2"){
		translate([-ff,0])
		rotate([0,0,-90])
		if (addition_width > 0 && addition_height > 0){
			half_rounded_rectangle(addition_width,addition_height,addition_corner_radius);
		}
	}
	else if (addition_shape=="rr3" || addition_shape=="-rr3"){
		translate([0,ff])
		rotate([0,0,180])
		if (addition_width > 0 && addition_height > 0){
			half_rounded_rectangle(addition_height,addition_width,addition_corner_radius);
		}
	}		
	else if (addition_shape=="rr4" || addition_shape=="-rr4"){
		translate([ff,0])
		rotate([0,0,90])
		if (addition_width > 0 && addition_height > 0){
			half_rounded_rectangle(addition_width,addition_height,addition_corner_radius);
		}
	}
	else if (addition_shape=="oa1" || addition_shape=="-oa1"){
		translate([-ff,-ff])
		if (addition_corner_radius > 0){
			translate([-addition_corner_radius,-addition_corner_radius])
			create_cutting_tool_2d(0, addition_corner_radius*2);
		}
	}
	else if (addition_shape=="oa2" || addition_shape=="-oa2"){
		translate([-ff,ff])
		if (addition_corner_radius > 0){
			translate([-addition_corner_radius,addition_corner_radius])
			create_cutting_tool_2d(-90, addition_corner_radius*2);
		}
	}
	else if (addition_shape=="oa3" || addition_shape=="-oa3"){
		translate([ff,ff])
		if (addition_corner_radius > 0){
			translate([addition_corner_radius,addition_corner_radius])
			create_cutting_tool_2d(180, addition_corner_radius*2);
		}
	}
	else if (addition_shape=="oa4" || addition_shape=="-oa4"){
		translate([ff,-ff])
		if (addition_corner_radius > 0){
			translate([addition_corner_radius,-addition_corner_radius])
			create_cutting_tool_2d(90, addition_corner_radius*2);
		}
	}
}

// Iterates the case additions vector and linear-extrudes each addition that has a
// positive thickness (non-zero height shapes like slide-in tabs or pedestals).
// Negative-shape entries are ignored here when is_sub=false.
// @param c_a  Case additions vector (rows of addition definitions)
// Iterates the case additions vector and linear-extrudes each entry whose shape
// matches the requested mode: pass is_sub=false to process positive additions
// (shapes without a leading "-"), or is_sub=true to process subtractions
// (shapes with a leading "-", extruded slightly oversized to ensure clean cuts).
// @param c_a     Case additions vector (rows of addition definitions)
// @param is_sub  false = add positive shapes; true = subtract negative shapes
module apply_flex_height_shapes(c_a, is_sub){
	if (len(c_a)>0){
		for(i = [0 : len(c_a)-1]){
			addition = c_a[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:thickness, 7:trim_above, 8:trim_below, 9:trim_to_right, 10:trim_to_left, 11:corner_radius, 12:other

			addition_ID = addition[0];
			addition_x = addition[1];
			addition_y = addition[2];
			addition_width     = is_sub ? addition[3]+ff : addition[3];
			addition_height    = is_sub ? addition[4]+ff : addition[4];
			addition_thickness = (is_laser_cut && generate=="first layer for SVG/DXF file") ? 0
			                   : is_sub ? addition[6]+ff : addition[6];
			addition_shape = addition[5];
			addition_trim_above = addition[7];
			addition_trim_below = addition[8];
			addition_trim_to_right = addition[9];
			addition_trim_to_left = addition[10];
			addition_corner_radius = addition[11];

			is_negative = search("-", addition_shape) != [];
			if(addition_thickness>0 && is_sub==is_negative){
				translate([0, 0, is_sub ? -kt/2-ff : -kt/2])
				if(addition_ID=="#"){
					#linear_extrude(height=addition_thickness)
					build_trimmed_addition(addition_x,addition_y,addition_width, addition_height, addition_shape, addition_trim_above, addition_trim_below, addition_trim_to_right, addition_trim_to_left,addition_corner_radius);
				}
				else{
					linear_extrude(height=addition_thickness)
					build_trimmed_addition(addition_x,addition_y,addition_width, addition_height, addition_shape, addition_trim_above, addition_trim_below, addition_trim_to_right, addition_trim_to_left,addition_corner_radius);
				}
			}
		}
	}
}

// Builds a 2D addition shape and applies optional clipping on each side using the
// trim_above/below/left/right values from the case additions vector.
// @param addition_x             X offset from the coordinate origin in mm
// @param addition_y             Y offset from the coordinate origin in mm
// @param addition_width         Shape width in mm
// @param addition_height        Shape height in mm
// @param addition_shape         Shape code string
// @param addition_trim_above    Y coordinate above which to clip (−999 = no clip)
// @param addition_trim_below    Y coordinate below which to clip (−999 = no clip)
// @param addition_trim_to_right X coordinate to the right of which to clip (−999 = no clip)
// @param addition_trim_to_left  X coordinate to the left of which to clip (−999 = no clip)
// @param addition_corner_radius Corner radius in mm
module build_trimmed_addition(addition_x,addition_y,addition_width, addition_height, addition_shape, addition_trim_above, addition_trim_below, addition_trim_to_right, addition_trim_to_left,addition_corner_radius){
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	
	difference(){
		translate([x0+addition_x ,y0+addition_y])
		build_addition(addition_width, addition_height, addition_shape, addition_corner_radius);

		if (addition_trim_below > -999){
			translate([0,-kh+addition_trim_below])
			square([kw*2,kh*2],center=true);
		}
		if (addition_trim_above > -999){
			translate([0,kh+addition_trim_above])
			square([kw*2,kh*2],center=true);
		}
		if (addition_trim_to_right > -999){
			translate([addition_trim_to_right,0])
			square([kw*2,kh*2],center=true);
		}
		if (addition_trim_to_left > -999){
			translate([-kw+addition_trim_to_left,0])
			square([kw*2,kh*2],center=true);
		}
	}
}


// Places horizontal cylinder additions (cyl1-4) from the case additions vector,
// used to add bar-shaped protrusions on the top, right, bottom, or left edges.
// @param case_posts  Case additions vector containing cyl1/cyl2/cyl3/cyl4 entries
module add_case_cylinders(case_posts){
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	
	for(i = [0 : len(case_posts)-1]){
		addition = case_posts[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:thickness, 7:trim_above, 8:trim_below, 9:trim_to_right, 10:trim_to_left, 11:corner_radius, 12:other
		
		addition_x = addition[1];
		addition_y = addition[2];
		addition_width = addition[3];
		addition_height = addition[4];
		s = addition[5];
		addition_shape = ((s=="rr1" || s=="rr2" || s=="rr3" || s=="rr4")  && addition[11]==0) ? "r" : s;
		addition_thickness = addition[6];
			
		translate([addition_x,addition_y])
		if (addition_shape=="cyl1"){
			if (addition_width > 0){
				translate([x0,y0+addition_width/2-ff,-kt/2+addition_thickness/2+addition_height])
				rotate([0,0,90])
				rotate([0,90,0])
				cylinder(d=addition_thickness,h=addition_width,center=true);
			}
		}
		else if (addition_shape=="cyl2"){
			if (addition_width > 0){
				translate([x0+addition_width/2-ff,y0,-kt/2+addition_thickness/2+addition_height])
				rotate([0,90,0])
				cylinder(d=addition_thickness,h=addition_width,center=true);
			}
		}
		else if (addition_shape=="cyl3"){
			if (addition_width > 0){
				translate([x0,y0-addition_width/2+ff,-kt/2+addition_thickness/2+addition_height])
				rotate([0,0,90])
				rotate([0,90,0])
				cylinder(d=addition_thickness,h=addition_width,center=true);
			}
		}
		else if (addition_shape=="cyl4"){
			if (addition_width > 0){
				translate([x0-addition_width/2+ff,y0,-kt/2+addition_thickness/2+addition_height])
				rotate([0,90,0])
				cylinder(d=addition_thickness,h=addition_width,center=true);
			}
		}
	}
}
// Generates a 2D rectangle with two rounded corners on one end (a half-rounded
// rectangle), used as the profile for snap-in tab shapes.
// @param h1  Height of the shape in mm
// @param w1  Width of the shape in mm
// @param cr  Corner radius applied to the two rounded corners in mm
module half_rounded_rectangle(h1,w1,cr){
	difference(){
        translate([-w1/2,0,0])
        square([w1,h1]);
        
        translate([-w1/2+cr-ff,h1-cr+ff,0])
        difference(){
			square(size=cr*2,center=true);
            circle(cr);
            translate([0,-cr/2-ff,0])
            square([(cr+ff)*2,cr+ff],center=true);
            
            translate([cr/2+ff,0,0])
            square([cr+ff,(cr+ff)*2],center=true);
		}

        translate([w1/2-cr+ff,h1-cr+ff,0])
        difference(){
			square(size=cr*2,center=true);
            circle(cr);
            translate([0,-cr/2-ff,0])
            square([(cr+ff)*2,cr+ff],center=true);
            
            translate([-cr/2-ff,0,0])
            square([cr+ff,(cr+ff)*2],center=true);
		}
    }
}

// Iterates the case additions vector and adds clip-on strap pedestals for ped1-4
// entries (manually placed pedestals on the top, left, bottom, or right edge).
// @param c_a  Case additions vector containing ped1/ped2/ped3/ped4 entries
module add_manual_mount_pedestals(c_a){
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	
	for(i = [0 : len(c_a)-1]){
		addition = c_a[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:thickness, 7:trim_above, 8:trim_below, 9:trim_to_right, 10:trim_to_left, 11:corner_radius, 12:other
		
		addition_ID = addition[0];
		addition_x = addition[1];
		addition_y = addition[2];
		s = addition[5];
		addition_shape = ((s=="rr1" || s=="rr2" || s=="rr3" || s=="rr4")  && addition[11]==0) ? "r" : s;
			
		translate([addition_x,addition_y])
		if(addition_ID!="#"){
			if(addition_shape=="ped1"){
				translate([x0,y0-manual_pedestal_edge_inset,kt/2])
				rotate([0,0,-90])
				linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,vertical_pedestal_width],center=true);
			}
			else if(addition_shape=="ped2"){
				translate([x0-manual_pedestal_edge_inset,y0,kt/2])
				rotate([0,0,0])
				linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,horizontal_pedestal_width],center=true);
			}
			else if(addition_shape=="ped3"){
				translate([x0,y0+manual_pedestal_edge_inset,kt/2])
				rotate([0,0,-90])
				linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,vertical_pedestal_width],center=true);
			}
			else if(addition_shape=="ped4"){
				translate([x0+manual_pedestal_edge_inset,y0,kt/2])
				rotate([0,0,0])
				linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,horizontal_pedestal_width],center=true);
			}
		}
		else{
			if(addition_shape=="ped1"){
				translate([x0,y0-manual_pedestal_edge_inset,kt/2])
				rotate([0,0,-90])
				#linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,vertical_pedestal_width],center=true);
			}
			else if(addition_shape=="ped2"){
				translate([x0-manual_pedestal_edge_inset,y0,kt/2])
				rotate([0,0,0])
				#linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,horizontal_pedestal_width],center=true);
			}
			else if(addition_shape=="ped3"){
				translate([x0,y0+manual_pedestal_edge_inset,kt/2])
				rotate([0,0,-90])
				#linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,vertical_pedestal_width],center=true);
			}
			else if(addition_shape=="ped4"){
				translate([x0+manual_pedestal_edge_inset,y0,kt/2])
				rotate([0,0,0])
				#linear_extrude(height=pedestal_height,scale=pedestal_taper)
				square([pedestal_base_size,horizontal_pedestal_width],center=true);
			}
		}
	}
}

// Iterates the case additions vector and cuts the wedge-shaped grooves that
// correspond to manually placed ped1-4 pedestals, for clip-on strap attachment.
// @param c_a  Case additions vector containing ped1/ped2/ped3/ped4 entries
module cut_manual_mount_pedestal_slots(c_a){
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	
	for(i = [0 : len(c_a)-1]){
		addition = c_a[i]; //0:ID, 1:x, 2:y, 3:width,  4:height, 5:shape, 6:thickness, 7:trim_above, 8:trim_below, 9:trim_to_right, 10:trim_to_left, 11:corner_radius, 12:other
		
		addition_ID = addition[0];
		addition_x = addition[1];
		addition_y = addition[2];
		s = addition[5];
		addition_shape = ((s=="rr1" || s=="rr2" || s=="rr3" || s=="rr4")  && addition[11]==0) ? "r" : s;
			
		translate([x0+addition_x,y0+addition_y])
		if(addition_ID!="#"){
			if(addition_shape=="ped1"){
				translate([vertical_slot_width/2,-manual_pedestal_slot_inset-kec,vertical_offset])
				rotate([90,0,-90])
				linear_extrude(height = vertical_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
			else if(addition_shape=="ped3"){
				translate([-vertical_slot_width/2,manual_pedestal_slot_inset+kec,vertical_offset])
				rotate([90,0,90])
				linear_extrude(height = vertical_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
			else if(addition_shape=="ped2"){
				translate([-kec-manual_pedestal_slot_inset,-horizontal_slot_width/2,vertical_offset])
				rotate([90,0,180])
				linear_extrude(height = horizontal_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
			else if(addition_shape=="ped4"){
				translate([kec+manual_pedestal_slot_inset,horizontal_slot_width/2,vertical_offset])
				rotate([90,0,0])
				linear_extrude(height = horizontal_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
		}
		else{
			if(addition_shape=="ped1"){
				translate([vertical_slot_width/2,-manual_pedestal_slot_inset-kec,vertical_offset])
				rotate([90,0,-90])
				#linear_extrude(height = vertical_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
			else if(addition_shape=="ped3"){
				translate([-vertical_slot_width/2,manual_pedestal_slot_inset+kec,vertical_offset])
				rotate([90,0,90])
				#linear_extrude(height = vertical_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
			else if(addition_shape=="ped2"){
				translate([-kec-manual_pedestal_slot_inset,-horizontal_slot_width/2,vertical_offset])
				rotate([90,0,180])
				#linear_extrude(height = horizontal_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
			else if(addition_shape=="ped4"){
				translate([kec+manual_pedestal_slot_inset,horizontal_slot_width/2,vertical_offset])
				rotate([90,0,0])
				#linear_extrude(height = horizontal_slot_width)
				polygon(points=[[0,0],[groove_slot_width,0],[groove_slot_width+groove_slant,groove_depth],[groove_slant,groove_depth]]);
			}
		}
	}
}
 

// Produces a cutting solid that trims the keyguard down to exactly the screen area
// (swm × shm), removing everything outside the screen boundary.
module trim_to_the_screen(){
	difference(){
		cube([1000,1000,100],true);
		cube([swm-2*ff,shm-2*ff,100+ff*4],true);
	}
}

// Produces a cutting solid that trims the keyguard to the user-defined rectangular
// region (trim_to_rectangle_lower_left / upper_right parameters).
module trim_to_rectangle(){
	x0 = (generate_keyguard) ? kx0 : case_x0;
	y0 = (generate_keyguard) ? ky0 : case_y0;
	
	major_dim = (!has_case) ? max(tablet_width,tablet_height) : max(kw,kh);
	minor_dim = (!has_case) ? min(tablet_width,tablet_height): min(kw,kh);
	
	x1 = t_t_r_ll[0];
	y1 = t_t_r_ll[1];
	x2 = t_t_r_ur[0];
	y2 = t_t_r_ur[1];
	
	w1=x2-x1;
	h1=y2-y1;
	
	translate([x0+w1/2+x1,y0+h1/2+y1,0])
	difference(){
		final_rotation = (is_landscape) ? [0,0,0] : [0,0,-90];
		
		rotate(final_rotation)
		cube([major_dim*3,minor_dim*3,kt+ff*2],true);
		
		cube([w1-ff,h1-ff,kt+ff*4],true);
	}
}

// Produces a tall rectangular cutting solid that removes the entire screen area
// from the bottom of the keyguard (used as a helper for SVG layer output).
module cut_screen(){
	translate([screen_x0,screen_y0,-kt/2-ff-50])
	cube([swm,shm,100]);
}

// Produces a tall rectangular cutting solid that removes the entire grid area from
// the keyguard (used as a helper for SVG layer output).
module cut_grid(){
	translate([grid_x0,grid_y0,-kt/2-ff])
	cube([gwm,ghm,100]);
}

// Cuts the triangular snap-in grooves into the keyguard frame at the positions
// where the inner keyguard's snap-in tabs will engage.
// Grooves are centred on the screen area thickness (sat) so that they align with
// the tabs when sat < kt (screen area thinner than the full keyguard body).
module snap_in_tab_grooves(){
	if (mount_keyguard_with=="snap-in tabs"){
		translate([keyguard_width/2-ff,0,-keyguard_frame_thickness/2+sat/2])
		make_snap_ins(groove_size,groove_width);

		translate([-keyguard_width/2+ff,0,-keyguard_frame_thickness/2+sat/2])
		rotate([0,0,180])
		make_snap_ins(groove_size,groove_width);

		translate([keyguard_width/2+.6,0,-keyguard_frame_thickness/2+sat/2-.05-ff])
		cube([snap_in_size+.5,2,sat-.5],center=true);

		translate([-keyguard_width/2-.6,0,-keyguard_frame_thickness/2+sat/2-.05-ff])
		cube([snap_in_size+.5,2,sat-.5],center=true);
	}

	translate([0,keyguard_height/2-ff,-keyguard_frame_thickness/2+sat/2])
	rotate([0,0,90])
	make_snap_ins(groove_size,groove_width);

	translate([0,keyguard_height/2+.6,-keyguard_frame_thickness/2+sat/2-.05-ff])
	cube([2,snap_in_size+.5,sat-.5],center=true);

	translate([0,-keyguard_height/2+ff,-keyguard_frame_thickness/2+sat/2])
	rotate([0,0,-90])
	make_snap_ins(groove_size,groove_width);

	translate([0,-keyguard_height/2-.6,-keyguard_frame_thickness/2+sat/2-.05-ff])
	cube([2,snap_in_size+.5,sat-.5],center=true);
}


// Adds the triangular snap-in tab protrusions to the edges of the inner keyguard
// that click into the corresponding grooves in the keyguard frame.
// Tabs are centred on the screen area thickness (sat) so that when sat < kt the tab
// sits at the screen-area midpoint rather than the overall keyguard midpoint.
module add_snap_ins(){
	tab_z = sat/2 - kt/2; // Z offset: 0 when sat==kt, shifts toward screen face when sat<kt
	if (snap_in_tabs_on_left_and_right_edges_of_keyguard=="yes" && mount_keyguard_with=="snap-in tabs"){
		translate([kw/2,0,tab_z])
		make_snap_ins(snap_in_size,snap_in_width);
		translate([kw/2+.4,0,tab_z-.5])
		cube([snap_in_size,1.5,sat-1],center=true);

		translate([-kw/2,0,tab_z])
		rotate([0,0,180])
		make_snap_ins(snap_in_size,snap_in_width);
		translate([-kw/2-.4,0,tab_z-.5])
		cube([snap_in_size,1.5,sat-1],center=true);
	}

	if(snap_in_tab_on_bottom_edge_of_keyguard=="yes"){
		translate([0,-kh/2,tab_z])
		rotate([0,0,-90])
		make_snap_ins(snap_in_size,snap_in_width);

		if(mount_keyguard_with=="snap-in tabs"){
			translate([0,-kh/2-.4,tab_z-.5])
			cube([1.5,snap_in_size,sat-1],center=true);
		}
	}

	if(snap_in_tab_on_top_edge_of_keyguard=="yes" && mount_keyguard_with=="snap-in tabs"){
		translate([0,kh/2,tab_z])
		rotate([0,0,90])
		make_snap_ins(snap_in_size,snap_in_width);
		translate([0,kh/2+.4,tab_z-.5])
		cube([1.5,snap_in_size,sat-1],center=true);
	}
}

// Extrudes a single triangular snap-in tab (or groove tooth) perpendicular to the
// keyguard edge.
// @param size   Height of the triangle in mm (how far the tab protrudes)
// @param width  Width of the tab along the edge in mm
module make_snap_ins(size,width){
	rotate([-90,0,0])
	translate([0,0,-width/2])
	linear_extrude(height=width)
	polygon([[0,-size],[size,0],[0,size]]);
}

// Imports and displays the screenshot SVG file as a semi-transparent colour overlay
// scaled to fit the screen area, for visual alignment of openings.
// @param thickness  Keyguard thickness in mm; used to position the overlay just below the top face
module show_screenshot(thickness){
	color(screenshotcolor,.5)
	translate([msh,msv,-thickness/2-0.5])
	resize([swm,shm,0])
	offset(delta = .005)
	import(file=screenshot_file,center=true);
}

// Imports and displays the screenshot SVG as a linearly extruded (solid) overlay
// scaled to fit the screen area. Used on Maker World where pure 2D imports are invisible.
// @param thickness  Keyguard thickness in mm; positions the overlay just below the top face
module show_screenshotMW(thickness){
	color(screenshotcolor,.5)
	translate([msh,msv,-thickness/2-0.5])
	linear_extrude(height=.5)   // necessary to make screenshot visible on Maker World
	resize([swm,shm,0])
	offset(delta = .005)
	import(file=screenshot_file,center=true);
}

// Places engraved or embossed text on the keyguard by delegating to cut_opening()
// or place_addition(), positioning the text according to the region, alignment,
// angle, depth, and slide parameters.
module engrave_emboss_instruction(){
	x_start = (keyguard_region=="screen region") ? slide_horizontally/100 * swm : 
	          (keyguard_region=="case region") ? slide_horizontally/100 * cow :
			  slide_horizontally/100 * tw;
	x = (keyguard_location == "top surface") ? x_start : -x_start;
	y = (keyguard_region=="screen region") ? slide_vertically/100 * shm :
		(keyguard_region=="case region") ? slide_vertically/100 * coh :
		slide_vertically/100 * th;
	
	x0 = (keyguard_region=="screen region" && keyguard_location == "top surface") ? sx0 :
	     (keyguard_region=="screen region" && keyguard_location == "bottom surface") ? -sx0 :
		 (keyguard_region=="case region" && keyguard_location == "top surface") ? cox0 :
		 (keyguard_region=="case region" && keyguard_location == "bottom surface") ? -cox0 :
		 (keyguard_location == "top surface") ? tx0 : -tx0;
		 
	t_height = text_height;
	// V2 form: shape="text" + surface "t"/"b". cut_opening_v2, place_addition_v2,
	// and cut_opening_2d_v2 dispatch on the V2 form natively — no V1 ttext/btext
	// codes referenced here.
	surface = (keyguard_location == "top surface") ? "t" : "b";
	direction = (text_angle=="vertical downward") ? -90 :
	              (text_angle=="horizontal") ? 0 :
	              (text_angle=="vertical upward") ? 90 :
	              180;
	font_s  = font_style;                  // V2 string: "normal", "bold", "italic", "bold italic"
	h_align = text_horizontal_alignment;   // V2 string: "left", "center", "right"
	v_align = text_vertical_alignment;     // V2 string: "bottom", "baseline", "center", "top"
	cb = (is_laser_cut) ? -0.1 : text_depth;
	text_string = text;
	depth = sat;

	if(generate=="keyguard" || generate=="first half of keyguard" || generate=="second half of keyguard"){
		if (keyguard_region=="screen region"){
			if (cb > 0){
				translate([x0+x,sy0+y,sat-kt/2-ff])
				#place_addition_v2(10, t_height, "text", direction, direction, font_s, 0, h_align, v_align, cb, text_string, surface);
			}
			else{
				translate([x0+x,sy0+y,ff])
				#cut_opening_v2(0, t_height, "text", undef, surface, direction, v2_font_style_code(font_s), v2_h_align_code(h_align), v2_v_align_code(v_align), cb, text_string, depth*2,"screen");
			}
		}
		else{
			yb = (keyguard_region=="case region") ? coy0 : ty0;
			if (cb > 0){
				translate([x0+x,yb+y,kt/2-ff])
				#place_addition_v2(0, t_height, "text", direction, direction, font_s, 0, h_align, v_align, cb, text_string, surface);
			}
			else{
				translate([x0+x,yb+y,0])
				#cut_opening_v2(0, t_height, "text", undef, surface, direction, v2_font_style_code(font_s), v2_h_align_code(h_align), v2_v_align_code(v_align), cb, text_string, depth,"case");
			}
		}
	}
	else{ // first layer for SVG/DXF file
		if (keyguard_region=="screen region"){
			translate([x0+x,sy0+y,ff])
			#cut_opening_2d_v2(0, t_height, "text", undef, direction, cb);
		}
		else{
			yb = (keyguard_region=="case region") ? coy0 : ty0;
			translate([x0+x,yb+y,-ff])
			#cut_opening_2d_v2(0, t_height, "text", undef, direction, cb);
		}
	}
}

// Echoes all non-default Customizer parameter values to the OpenSCAD console,
// grouped by category, to help users record their configuration.
module echo_settings(){
	echo();
	echo(keyguard_designer_version=keyguard_designer_version);
	echo();
	echo();
	echo("Customizer Settings");
	echo();
	echo();

	echo("---- Keyguard Basics ----");
		if (!is_3d_printed) echo(type_of_keyguard = type_of_keyguard);
		if (keyguard_thickness != 4) echo(keyguard_thickness = keyguard_thickness);
		if (screen_area_thickness != 4) echo(screen_area_thickness = screen_area_thickness);
		echo();
		echo();

	echo("---- Tablet ----");
		if (type_of_tablet != "iPad 9th generation") echo(type_of_tablet = type_of_tablet);
		if (!is_landscape) echo(orientation = orientation);
		if (expose_home_button != "yes") echo(expose_home_button = expose_home_button);
		if (home_button_edge_slope!= 30) echo(home_button_edge_slope = home_button_edge_slope);
		if (expose_camera != "yes") echo(expose_camera = expose_camera);
		if (rotate_tablet_180_degrees != "no") echo(rotate_tablet_180_degrees = rotate_tablet_180_degrees);
		if (add_symmetric_openings != "no") echo(add_symmetric_openings = add_symmetric_openings);
		if (expose_ambient_light_sensors != "yes") echo(expose_ambient_light_sensors = expose_ambient_light_sensors);
		echo();
		echo();

	echo("---- Tablet Case ----");
		if (!has_case) echo(have_a_case = have_a_case);
		if (height_of_opening_in_case != 170) echo(height_of_opening_in_case = height_of_opening_in_case);
		if (width_of_opening_in_case != 245) echo(width_of_opening_in_case = width_of_opening_in_case);
		if (case_opening_corner_radius != 5) echo(case_opening_corner_radius = case_opening_corner_radius);
		if (case_height != 220) echo(case_height = case_height);
		if (case_width != 275) echo(case_width = case_width);
		if (case_thickness != 15) echo(case_thickness = case_thickness);
		if (case_corner_radius != 20) echo(case_corner_radius = case_corner_radius);
		if (case_to_screen_depth != 5) echo(case_to_screen_depth = case_to_screen_depth);
		if (top_edge_compensation_for_tight_cases != 0) echo(top_edge_compensation_for_tight_cases = top_edge_compensation_for_tight_cases);
		if (bottom_edge_compensation_for_tight_cases != 0) echo(bottom_edge_compensation_for_tight_cases = bottom_edge_compensation_for_tight_cases);
		if (left_edge_compensation_for_tight_cases != 0) echo(left_edge_compensation_for_tight_cases = left_edge_compensation_for_tight_cases);
		if (right_edge_compensation_for_tight_cases != 0) echo(right_edge_compensation_for_tight_cases = right_edge_compensation_for_tight_cases);
		echo();
		echo();
		
	echo("---- App Layout in px ----");
		if (bottom_of_status_bar != 0) echo(bottom_of_status_bar = bottom_of_status_bar);
		if (bottom_of_upper_message_bar != 0) echo(bottom_of_upper_message_bar = bottom_of_upper_message_bar);
		if (bottom_of_upper_command_bar != 0) echo(bottom_of_upper_command_bar = bottom_of_upper_command_bar);
		if (top_of_lower_message_bar != 0) echo(top_of_lower_message_bar = top_of_lower_message_bar);
		if (top_of_lower_command_bar != 0) echo(top_of_lower_command_bar = top_of_lower_command_bar);
		echo();
		echo();

	echo("---- App Layout in mm ----");
		if (status_bar_height != 0) echo(status_bar_height = status_bar_height);
		if (upper_message_bar_height != 0) echo(upper_message_bar_height = upper_message_bar_height);
		if (upper_command_bar_height != 0) echo(upper_command_bar_height = upper_command_bar_height);
		if (lower_message_bar_height != 0) echo(lower_message_bar_height = lower_message_bar_height);
		if (lower_command_bar_height != 0) echo(lower_command_bar_height = lower_command_bar_height);
		echo();
		echo();

	echo("---- Bar Info ----");
		if (expose_status_bar != "no") echo(expose_status_bar = expose_status_bar);
		if (expose_upper_message_bar != "no") echo(expose_upper_message_bar = expose_upper_message_bar);
		if (expose_upper_command_bar != "no") echo(expose_upper_command_bar = expose_upper_command_bar);
		if (expose_lower_message_bar != "no") echo(expose_lower_message_bar = expose_lower_message_bar);
		if (expose_lower_command_bar != "no") echo(expose_lower_command_bar = expose_lower_command_bar);
		if (bar_edge_slope != 90) echo(bar_edge_slope = bar_edge_slope);
		if (bar_corner_radius != 2) echo(bar_corner_radius = bar_corner_radius);
		echo();
		echo();

	echo("---- Grid Info ----");
		if (number_of_rows != 3) echo(number_of_rows = number_of_rows);
		if (number_of_columns != 4) echo(number_of_columns = number_of_columns);
		if (cell_shape != "rectangular") echo(cell_shape = cell_shape);
		if (cell_height_in_px != 0) echo(cell_height_in_px = cell_height_in_px);
		if (cell_width_in_px != 0) echo(cell_width_in_px = cell_width_in_px);
		if (cell_height_in_mm != 25) echo(cell_height_in_mm = cell_height_in_mm);
		if (cell_width_in_mm != 25) echo(cell_width_in_mm = cell_width_in_mm);
		if (cell_corner_radius != 3) echo(cell_corner_radius = cell_corner_radius);
		if (cell_diameter != 15) echo(cell_diameter = cell_diameter);
		echo();
		echo();
	
	echo("---- Grid Special Settings ----");
		if (cell_edge_slope != 90) echo(cell_edge_slope = cell_edge_slope);
		if (cover_these_cells != "" && cover_these_cells != "[]") echo(cover_these_cells = cover_these_cells);
		if (merge_cells_horizontally_starting_at != "" && merge_cells_horizontally_starting_at != "[]") echo(merge_cells_horizontally_starting_at = merge_cells_horizontally_starting_at);
		if (merge_cells_vertically_starting_at != "" && merge_cells_vertically_starting_at != "[]") echo(merge_cells_vertically_starting_at = merge_cells_vertically_starting_at);
		if (add_a_ridge_around_these_cells != "" && add_a_ridge_around_these_cells != "[]") echo(add_a_ridge_around_these_cells = add_a_ridge_around_these_cells);
		if (height_of_ridge != 2) echo(height_of_ridge = height_of_ridge);
		if (thickness_of_ridge != 2) echo(thickness_of_ridge = thickness_of_ridge);
		if (cell_top_edge_slope != 90) echo(cell_top_edge_slope = cell_top_edge_slope);
		if (cell_bottom_edge_slope != 90) echo(cell_bottom_edge_slope = cell_bottom_edge_slope);
		if (top_padding != 0) echo(top_padding = top_padding);
		if (bottom_padding != 0) echo(bottom_padding = bottom_padding);
		if (left_padding != 0) echo(left_padding = left_padding);
		if (right_padding != 0) echo(right_padding = right_padding);
		if (hide_grid_region != "no") echo(hide_grid_region = hide_grid_region);
		echo();
		echo();

	echo("---- Mounting Method ----");
		if (mounting_method != "No Mount") echo(mounting_method = mounting_method);
		echo();
		echo();

	echo("---- Velcro Info ----");
		if (velcro_size != 1) echo(velcro_size = velcro_size);
		echo();
		echo();

	echo("---- Clip-on Straps Info ----");
		if (clip_locations != "horizontal only") echo(clip_locations= clip_locations);
		if (horizontal_clip_width != 20) echo(horizontal_clip_width= horizontal_clip_width);
		if (vertical_clip_width != 20) echo(vertical_clip_width= vertical_clip_width);
		if (distance_between_horizontal_clips != 60) echo(distance_between_horizontal_clips= distance_between_horizontal_clips);
		if (distance_between_vertical_clips != 40) echo(distance_between_vertical_clips= distance_between_vertical_clips);
		if (clip_bottom_length != 35) echo(clip_bottom_length = clip_bottom_length);
		echo();
		echo();

	echo("---- Posts Info ----");
		if (post_diameter != 4) echo(post_diameter= post_diameter);
		if (post_length != 5) echo(post_length= post_length);
		if (mount_to_top_of_opening_distance != 5) echo(mount_to_top_of_opening_distance= mount_to_top_of_opening_distance);
		if (notch_in_post != "yes") echo(notch_in_post= notch_in_post);
		if (add_mini_tabs != "no") echo(add_mini_tabs= add_mini_tabs);
		if (mini_tab_width != 10) echo(mini_tab_width= mini_tab_width);
		if (mini_tab_length != 2) echo(mini_tab_length= mini_tab_length);
		if (mini_tab_inset_distance != 20) echo(mini_tab_inset_distance= mini_tab_inset_distance);
		if (mini_tab_height != 1) echo(mini_tab_height= mini_tab_height);
		if (rotate_mini_tab != 0) echo(rotate_mini_tab= rotate_mini_tab);
		echo();
		echo();

	echo("---- Shelf Info ----");
		if (shelf_thickness != 2) echo(shelf_thickness = shelf_thickness);
		if (shelf_depth != 3) echo(shelf_depth = shelf_depth);
		if (shelf_corner_radius != 5) echo(shelf_corner_radius = shelf_corner_radius);
		echo();
		echo();

	echo("---- Slide-in Tabs Info ----");
		if (slide_in_tab_locations != "horizontal only") echo(slide_in_tab_locations= slide_in_tab_locations);
		if (preferred_slide_in_tab_thickness != 2) echo(preferred_slide_in_tab_thickness = preferred_slide_in_tab_thickness);
		if (horizontal_slide_in_tab_length != 4) echo(horizontal_slide_in_tab_length = horizontal_slide_in_tab_length);
		if (vertical_slide_in_tab_length != 4) echo(vertical_slide_in_tab_length = vertical_slide_in_tab_length);
		if (horizontal_slide_in_tab_width != 20) echo(horizontal_slide_in_tab_width= horizontal_slide_in_tab_width);
		if (vertical_slide_in_tab_width != 20) echo(vertical_slide_in_tab_width= vertical_slide_in_tab_width);
		if (distance_between_horizontal_slide_in_tabs != 60) echo(distance_between_horizontal_slide_in_tabs= distance_between_horizontal_slide_in_tabs);
		if (distance_between_vertical_slide_in_tabs != 60) echo(distance_between_vertical_slide_in_tabs= distance_between_vertical_slide_in_tabs);
		echo();
		echo();

	echo("---- Raised Tabs Info ----");
		if (raised_tab_locations != "horizontal only") echo(raised_tab_locations = raised_tab_locations);
		if (raised_tab_height != 6) echo(raised_tab_height= raised_tab_height);
		if (horizontal_raised_tab_length != 8) echo(horizontal_raised_tab_length= horizontal_raised_tab_length);
		if (horizontal_raised_tab_width != 20) echo(horizontal_raised_tab_width= horizontal_raised_tab_width);
		if (distance_between_horizontal_raised_tabs != 60) echo(distance_between_horizontal_raised_tabs= distance_between_horizontal_raised_tabs);
		if (vertical_raised_tab_length != 8) echo(vertical_raised_tab_length= vertical_raised_tab_length);
		if (vertical_raised_tab_width != 20) echo(vertical_raised_tab_width= vertical_raised_tab_width);
		if (distance_between_vertical_raised_tabs != 60) echo(distance_between_vertical_raised_tabs= distance_between_vertical_raised_tabs);
		if (preferred_raised_tab_thickness != 2) echo(preferred_raised_tab_thickness= preferred_raised_tab_thickness);
		if (raised_tabs_starting_height != 0) echo(raised_tabs_starting_height = raised_tabs_starting_height);
		if (ramp_angle != 30) echo(ramp_angle = ramp_angle);
		if (embed_magnets != "no") echo(embed_magnets = embed_magnets);
		if (magnet_size != "20 x 8 x 1.5") echo(magnet_size = magnet_size);
		echo();
		echo();

	echo("---- Keyguard Frame Info ----");
		if (has_frame) echo(have_a_keyguard_frame = have_a_keyguard_frame);
		if (keyguard_frame_thickness != 5) echo(keyguard_frame_thickness = keyguard_frame_thickness);
		if (keyguard_height != 160) echo(keyguard_height = keyguard_height);
		if (keyguard_width != 210) echo(keyguard_width = keyguard_width);
		if (keyguard_corner_radius != 2) echo(keyguard_corner_radius = keyguard_corner_radius);
		if (mount_keyguard_with != "snap-in tabs") echo(mount_keyguard_with = mount_keyguard_with);
		if (snap_in_tab_on_top_edge_of_keyguard != "yes") echo(snap_in_tab_on_top_edge_of_keyguard = snap_in_tab_on_top_edge_of_keyguard);
		if (snap_in_tab_on_bottom_edge_of_keyguard != "yes") echo(snap_in_tab_on_bottom_edge_of_keyguard = snap_in_tab_on_bottom_edge_of_keyguard);
		if (snap_in_tabs_on_left_and_right_edges_of_keyguard != "yes") echo(snap_in_tabs_on_left_and_right_edges_of_keyguard = snap_in_tabs_on_left_and_right_edges_of_keyguard);
		if (post_tightness_of_fit != 0) echo(post_tightness_of_fit = post_tightness_of_fit);
		if (keyguard_vertical_tightness_of_fit != 0) echo(keyguard_vertical_tightness_of_fit = keyguard_vertical_tightness_of_fit);
		if (keyguard_horizontal_tightness_of_fit != 0) echo(keyguard_horizontal_tightness_of_fit = keyguard_horizontal_tightness_of_fit);
		echo();
		echo();

	echo("---- Split Keyguard Info ----");
		if (split_line_location != 0) echo(split_line_location = split_line_location);
		if (split_line_type != "flat") echo(split_line_type = split_line_type);
		if (dovetail_width != 4.0) echo(dovetail_width = dovetail_width);
		if (slide_dovetails != 0) echo(slide_dovetails = slide_dovetails);
		if (tightness_of_dovetail_joint != 0) echo(tightness_of_dovetail_joint = tightness_of_dovetail_joint);
		echo();
		echo();
	
	echo("---- Sloped Keyguard Edge Info ----");
		if (add_sloped_keyguard_edge != "no") echo(add_sloped_keyguard_edge = add_sloped_keyguard_edge);
		if (sloped_edge_starting_height != 1) echo(sloped_edge_starting_height = sloped_edge_starting_height);
		if (horizontal_sloped_edge_width != 10) echo(horizontal_sloped_edge_width = horizontal_sloped_edge_width);
		if (vertical_sloped_edge_width != 10) echo(vertical_sloped_edge_width = vertical_sloped_edge_width);
		if (case_to_slope_depth != 0) echo(case_to_slope_depth = case_to_slope_depth);
		if (extend_lip_to_edge_of_case != "no") echo(extend_lip_to_edge_of_case = extend_lip_to_edge_of_case);
		echo();
		echo();

	echo("---- Engraved/Embossed Text ----");
		if (text != "") echo(text = text);
		if (text_height != 5) echo(text_height = text_height);
		if (font_style != "normal") echo(font_style = font_style);
		if (keyguard_location != "top surface") echo(keyguard_location = keyguard_location);
		if (show_back_of_keyguard != "no") echo(show_back_of_keyguard = show_back_of_keyguard);
		if (keyguard_region != "screen region") echo(keyguard_region = keyguard_region);
		if (text_depth != -2) echo(text_depth = text_depth);
		if (text_horizontal_alignment != "center") echo(text_horizontal_alignment = text_horizontal_alignment);
		if (text_vertical_alignment != "center") echo(text_vertical_alignment = text_vertical_alignment);
		if (text_angle != "horizontal") echo(text_angle = text_angle);
		if (slide_horizontally != 0) echo(slide_horizontally = slide_horizontally);
		if (slide_vertically != 0) echo(slide_vertically = slide_vertically);
		echo();
		echo();

	echo("---- Cell Inserts ----");
		if (Braille_location != "above opening") echo(Braille_location = Braille_location);
		if (Braille_text != "") echo(Braille_text = Braille_text);
		if (Braille_size_multiplier != 10) echo(Braille_size_multiplier = Braille_size_multiplier);
		if (add_circular_opening != "yes") echo(add_circular_opening = add_circular_opening);
		if (diameter_of_opening != 10) echo(diameter_of_opening = diameter_of_opening);
		if (Braille_to_opening_distance != 5) echo(Braille_to_opening_distance = Braille_to_opening_distance);
		if (engraved_text != "") echo(engraved_text = engraved_text);
		if (insert_tightness_of_fit != 0) echo(insert_tightness_of_fit = insert_tightness_of_fit);
		if (insert_recess != 0) echo(insert_recess = insert_recess);
		echo();
		echo();

	echo("---- Free-form and Hybrid Keyguard Openings ----");
		if (!using_px) echo(unit_of_measure_for_screen = unit_of_measure_for_screen);
		if (starting_corner_for_screen_measurements != "upper-left") echo(starting_corner_for_screen_measurements = starting_corner_for_screen_measurements);
		echo();
		echo();

	echo("---- Special Actions and Settings ----");
		if (include_screenshot != "no") echo(include_screenshot = include_screenshot);
		if (keyguard_display_angle != 0) echo(keyguard_display_angle = keyguard_display_angle);
		if (unequal_left_side_of_case_opening != 0) echo(unequal_left_side_of_case_opening = unequal_left_side_of_case_opening);
		if (unequal_bottom_side_of_case_opening != 0) echo(unequal_bottom_side_of_case_opening = unequal_bottom_side_of_case_opening);
		if (unequal_left_side_of_case != 0) echo(unequal_left_side_of_case = unequal_left_side_of_case);
		if (unequal_bottom_side_of_case != 0) echo(unequal_bottom_side_of_case = unequal_bottom_side_of_case);
		if (move_screenshot_horizontally != 0) echo(move_screenshot_horizontally = move_screenshot_horizontally);
		if (move_screenshot_vertically != 0) echo(move_screenshot_vertically = move_screenshot_vertically);
		if (keyguard_edge_chamfer != 1) echo(keyguard_edge_chamfer = keyguard_edge_chamfer);
		if (cell_edge_chamfer != 1) echo(cell_edge_chamfer = cell_edge_chamfer);
		if (hide_screen_region != "no") echo(hide_screen_region = hide_screen_region);
		if (first_two_layers_only != "no") echo(first_two_layers_only = first_two_layers_only);
		if (trim_to_rectangle_lower_left != "" && trim_to_rectangle_lower_left != "[]") echo(trim_to_rectangle_lower_left = trim_to_rectangle_lower_left);
		if (trim_to_rectangle_upper_right != "" && trim_to_rectangle_upper_right != "[]") echo(trim_to_rectangle_upper_right = trim_to_rectangle_upper_right);
		if (!lc_best_practices) echo(use_Laser_Cutting_best_practices = use_Laser_Cutting_best_practices);
		if (other_tablet_general_sizes != "" && other_tablet_general_sizes != "[]") echo(other_tablet_general_sizes = other_tablet_general_sizes);
		if (other_tablet_pixel_sizes != "" && other_tablet_pixel_sizes != "[]") echo(other_tablet_pixel_sizes = other_tablet_pixel_sizes);
		if (my_screen_openings != "") echo(my_screen_openings = my_screen_openings);
		if (my_case_openings != "") echo(my_case_openings = my_case_openings);
		if (my_case_additions != "") echo(my_case_additions = my_case_additions);
		if (my_tablet_openings != "") echo(my_tablet_openings = my_tablet_openings);
		echo();
		echo();
}

// Computes the perimeter rail widths on each side of the keyguard and echoes a
// warning to the console for any rail that is narrower than the minimum acrylic width.
module issues(){
		echo();
		perimeter1 = (kh - shm)/2;
		perimeter1_offset = (expose_status_bar=="yes" && sbhm>0) ? 0 :
							(expose_upper_message_bar=="yes" && umbhm>0) ? sbhm :
							(expose_upper_command_bar=="yes" && ucbhm>0) ? sbhm + umbhm :
							sbhm + umbhm+ucbhm+hrw/2+top_padding-unequal_bottom_side_offset;
		top_perimeter = max(perimeter1+perimeter1_offset,top_edge_compensation_for_tight_cases);
		
		perimeter3 = (kh - shm)/2;
		perimeter3_offset = (expose_lower_command_bar=="yes" && lcbhm>0) ? 0 :
							(expose_lower_message_bar=="yes" && lmbhm>0) ? lcbhm :
							lcbhm+lmbhm+hrw/2+bottom_padding+unequal_bottom_side_offset;
		bottom_perimeter = max(perimeter3+perimeter3_offset,bottom_edge_compensation_for_tight_cases);
		
		perimeter2 = (kw - swm)/2;
		perimeter2_offset = (expose_status_bar=="yes" && sbhm>0) ? 0 :
							(expose_upper_message_bar=="yes" && umbhm>0) ? 0 :
							(expose_upper_command_bar=="yes" && ucbhm>0) ? 0 :
							(expose_lower_command_bar=="yes" && lcbhm>0) ? 0 :
							(expose_lower_message_bar=="yes" && lmbhm>0) ? 0 :
							vrw/2+right_padding-unequal_left_side_offset;
		right_perimeter = max(perimeter2+perimeter2_offset,right_edge_compensation_for_tight_cases);
		
		perimeter4 = (kw - swm)/2;
		perimeter4_offset = (expose_status_bar=="yes" && sbhm>0) ? 0 :
							(expose_upper_message_bar=="yes" && umbhm>0) ? 0 :
							(expose_upper_command_bar=="yes" && ucbhm>0) ? 0 :
							(expose_lower_command_bar=="yes" && lcbhm>0) ? 0 :
							(expose_lower_message_bar=="yes" && lmbhm>0) ? 0 :
							vrw/2+left_padding+unequal_left_side_offset;
		left_perimeter = max(perimeter4+perimeter4_offset,left_edge_compensation_for_tight_cases);
		

		if(top_perimeter<minimum__acrylic_rail_width) echo(str("!!!!!!! ISSUE !!!!!!! -- The top perimeter rail is: ", top_perimeter, " mm wide."));
		if(bottom_perimeter<minimum__acrylic_rail_width) echo(str("!!!!!!! ISSUE !!!!!!! -- The bottom perimeter rail is: ", bottom_perimeter, " mm wide."));
		if(right_perimeter<minimum__acrylic_rail_width) echo(str("!!!!!!! ISSUE !!!!!!! -- The right side perimeter rail is: ", right_perimeter, " mm wide."));
		if(left_perimeter<minimum__acrylic_rail_width) echo(str("!!!!!!! ISSUE !!!!!!! -- The left side perimeter rail is: ", left_perimeter, " mm wide."));
		echo();
}

// Echoes the most important design dimensions and settings to the console
// (tablet, case opening, grid, mounting method, text) for a quick sanity check.
module key_settings(){
	echo(str("type of tablet: ", type_of_tablet));
	echo(str("use Laser Cutting best practices: ", use_Laser_Cutting_best_practices));
	echo(str("orientation: ", orientation));
	echo(str("have a case? ", have_a_case));
	if(has_case){
		echo(str("height of opening in case: ", kh, " mm."));
		echo(str("width of opening in case: ", kw, " mm."));
		echo(str("case opening corner radius: ", ccr, " mm."));
	}
	else{
		tl = st_tablet_tl_corner_radius;
		tr = st_tablet_tr_corner_radius;
		bl = st_tablet_bl_corner_radius;
		br = st_tablet_br_corner_radius;
		echo(str("height of tablet: ", th, " mm."));
		echo(str("width of tablet: ", tw, " mm."));
		echo(str("tablet corner radii: ", tl, ", ",tr, ", ",bl, ", ",br, ", ", " mm."));
	}
	echo(str("number of columns: ", number_of_columns));
	echo(str("number of rows: ", number_of_rows));
	echo(str("vertical rail width: ", vrw, " mm."));
	echo(str("horizontal rail width: ", hrw, " mm."));
	echo(str("mounting method: ", m_m));
	if(m_m=="Slide-in Tabs"){
		echo(str("slide-in tab thickness: ", acrylic_slide_in_tab_thickness, " mm."));
	}
	
	if(text!=""){	
		// account for horizontal and vertical slide
		ssh = swm*slide_horizontally/100;
		ssv = shm*slide_vertically/100;
		csh = cow*slide_horizontally/100;
		csv = coh*slide_vertically/100;
		tsh = tw*slide_horizontally/100;
		tsv = th*slide_vertically/100;
	
		// horizontal location
		x_loc = (keyguard_region=="screen region" && has_case) ? adj_case_border_left + ssh :
				(keyguard_region=="screen region" && !has_case) ? left_border_width + ssh :
				(keyguard_region=="case region" && has_case) ? csh :
				(keyguard_region=="tablet region" && !has_case) ? tsh :
				(keyguard_region=="tablet region" && has_case) ? 0 :
				0;
		// vertical location
		y_loc = (keyguard_region=="screen region" && has_case) ? adj_case_border_bottom + ssv :
				(keyguard_region=="screen region" && !has_case) ? bottom_border_height + ssv :
				(keyguard_region=="case region" && has_case) ? csv :
				(keyguard_region=="tablet region" && !has_case) ? tsv :
				(keyguard_region=="tablet region" && has_case) ? 0 :
				0;
		
		echo();
		echo();
		echo(str("Engraved Text: ", text));
		echo("Font: Liberation Sans");
		echo(str("Font Style: ", font_style));
		echo(str("Text Height: ", text_height," mm"));
		echo(str("Horizontal Alignment: ", text_horizontal_alignment));
		echo(str("Vertical Alignment: ", text_vertical_alignment));
		echo(str("Text Angle: ", text_angle));
		echo(str("Distance from Left Side of Keyguard: ", x_loc," mm"));
		echo(str("Distance from Bottom Side of Keyguard: ", y_loc," mm"));
		echo();
		echo();
	}
}

// Creates a rectangular cuboid with all twelve edges chamfered by the specified amount,
// using an intersection of three chamfered extrusions.
// @param x  Width in mm
// @param y  Height in mm
// @param z  Depth in mm
// @param c  Chamfer size in mm
module chamfered_cuboid (x, y, z, c){
	intersection(){	
		translate([0,0,-z/2])
		linear_extrude(height=z)
		offset(delta=c, chamfer=true)
		square([x-2*c,y-2*c],center=true);

		rotate([0,90,0])
		translate([0,0,-x/2])
		linear_extrude(height=x)
		offset(delta=c, chamfer=true)
		square([z-2*c,y-2*c],center=true);

		rotate([90,0,0])
		translate([0,0,-y/2])
		linear_extrude(height=y)
		offset(delta=c, chamfer=true)
		square([x-2*c,z-2*c],center=true);
	}
}

// Creates a chamfered cell-insert solid with rounded or circular cross-section.
// The chamfer shrinks the top and bottom faces inward by c mm relative to the
// mid-section, producing bevelled top and bottom edges.
// @param x   Width (or diameter for circular cells) in mm
// @param y   Height of the solid in mm
// @param z   Depth (or diameter for circular cells) in mm
// @param c   Chamfer size in mm
// @param cr  Corner radius of the cross-section in mm (ignored for circular cells)
module chamfered_shape(x, y, z, c, cr){
	if (cell_shape=="rectangular"){
		hull(){
			translate([0,0,(y-c*2)/2+c])
			linear_extrude(height=ff)
			offset(r=cr-c)
			square([x-2*(cr),z-2*(cr)],center=true);

			translate([0,0,-(y-c*2)/2])
			linear_extrude(height=y-c*2)
			offset(r=cr)
			square([x-2*cr,z-2*cr],center=true);
			
			translate([0,0,-(y-c*2)/2-c])
			linear_extrude(height=ff)
			offset(r=cr-c)
			square([x-2*(cr),z-2*(cr)],center=true);
		}
	}
	else{
			hull(){
			translate([0,0,(y-c*2)/2+c])
			linear_extrude(height=ff)
			offset(r=-c)
			circle(d=x);

			translate([0,0,-(y-c*2)/2])
			linear_extrude(height=y-c*2)
			circle(d=x);
			
			translate([0,0,-(y-c*2)/2-c])
			linear_extrude(height=ff)
			offset(r=-c)
			circle(d=x);
		}
	}
}

// Positions and rotates a word of Braille dots so they sit on the top surface of
// the cell insert, facing the reader.
// @param word  String to render in Braille (looked up in the braille_d dictionary)
module add_braille(word){
	translate([0,-sat/2,0])
	rotate([90,0,0])
	word_flat(word);
}

// Renders a complete word as a horizontal row of Braille characters by iterating
// over each character and calling braille_by_row.
// @param word  String to render in Braille
module word_flat(word){
	translate([(-6.1*(len(word)-1)/2)*bsm,0,0])
	for(i=[0:len(word)-1]){
	   translate([6.1*i*bsm,0,0])
	   braille_by_row(braille_d[word[i]]);
	}
}
// Decodes a decimal Braille dot pattern into a 6-bit boolean array and calls
// dots_letter to place the corresponding raised dots.
// @param decimal  Integer encoding of the Braille cell dot pattern (bits 1-6)
module braille_by_row(decimal){
	b1 = decimal%2;
	b1a = floor(decimal/2);
	b2 = b1a%2;
	b2a = floor(b1a/2);
	b3 = b2a%2;
	b3a = floor(b2a/2);
	b4 = b3a%2;
	b4a = floor(b3a/2);
	b5 = b4a%2;
	b5a = floor(b4a/2);
	b6 = b5a%2;
	b=[b6,b5,b4,b3,b2,b1];

	dots_letter(b);
}

// Places up to six spherical Braille dots at the standard dot positions for a
// single Braille cell, based on the 6-element boolean array b.
// @param b  6-element array [dot1..dot6]; 1 = place dot, 0 = omit
module dots_letter(b){
	$fn=20;

	if (b[0]==1){
		translate([-1.25*bsm,2.5*bsm,0])
		sphere(d=1.5*bsm);
	}
	if (b[1]==1){
		translate([1.25*bsm,2.5*bsm,0])
		sphere(d=1.5*bsm);
	}
	if (b[2]==1){
		translate([-1.25*bsm,0,0])
		sphere(d=1.5*bsm);
	}
	if (b[3]==1){
		translate([1.25*bsm,0,0])
		sphere(d=1.5*bsm);
	}
	if (b[4]==1){
		translate([-1.25*bsm,-2.5*bsm,0])
		sphere(d=1.5*bsm);
	}
	if (b[5]==1){
		translate([1.25*bsm,-2.5*bsm,0])
		sphere(d=1.5*bsm);
	}
}

// Engraves a text string into the face of a cell insert using the Liberation Sans Bold
// font, scaled by the Braille scale multiplier.
// @param alignment  Horizontal text alignment: "left", "center", or "right"
module add_engraved_text(alignment){
	fs = "Liberation Sans:style=Bold";
	t_h = 8*bsm;
	translate([0,-insert_thickness/2++1-ff,0])
	rotate([90,0,0])
	linear_extrude(height=1)
	text(str(e_t),font=fs,size=t_h,valign="center",halign=alignment);
}


// // // module Bliss_graphic(){
	// // // chamfer = .5;
	// // // s_f=insert_tightness_of_fit/10;
	
	// // // if (path_and_filename != ""){		
		// // // difference(){
			// // // translate([0,2+insert_recess/2,0])
			// // // rotate([90,0,0])
			// // // import(file = path_and_filename,center=true);
			
			// // // translate([0,insert_thickness,0])
			// // // rotate([90,0,0])
			// // // chamfered_shape(cw+s_f/2,insert_thickness,ch+s_f/2,chamfer,cell_corner_radius);
		// // // }
	// // // }
// // // }



// Uncomment this bloc to see how to use this library.
/*
// strToInt(string [,base])

// Resume : Converts a number in string.
// string : The string you wants to converts.
// base (optional) : The base conversion of the number : 2 for binay, 10 for decimal (default), 16 for hexadecimal.
echo("*** strToInt() ***");
echo(strToInt("491585"));
echo(strToInt("01110", 2));
echo(strToInt("D5A4", 16));
echo(strToInt("-15"));
echo(strToInt("-5") + strToInt("10") + 5);

// strcat(vector [,insert])

// Resume : Concatenates a vector of words into a string.
// vector : A vector of string.
// insert (optional) : A string which will added between each words.
echo("*** strcat() ***");
v_data = ["OpenScad", "is", "a", "free", "CAD", "software."];
echo(strcat(v_data)); // ECHO: "OpenScadisafreeCADsoftware."
echo(strcat(v_data, " ")); // ECHO: "OpenScad is a free CAD software."

// substr(str, pos [,length])

// Resume : Substract a substring from a bigger string.
// str : The original string
// pos : The index of the position where the substring will begin.
// length (optional) : The length of the substring. If not specified, the substring will continue until the end of the string.
echo("*** substr() ***");
str = "OpenScad is a free CAD software.";
echo(str); // ECHO: "OpenScad is a free CAD software."
echo(substr(str, 0, 11)); // ECHO: "OpenScad is"
echo(substr(str, 12)); // ECHO: "a free CAD software."
echo(substr(str, 12, 10)); // ECHO: "a free CAD"

// fill(string, occurrences)

// Resume : Fill a string with several characters (or strings).
// string : the character or string which will be copied.
// occurrences : The number of occurences of the string.
echo("*** Fill() ***");
echo(fill("0", 4)); // ECHO: "0000"
echo(fill("hey", 3)); // ECHO: "heyheyhey"

// getsplit(string, index [,separator])

// Resume : Split a string in several words.
// string : The original string.
// index : The index of the word to get.
// separator : The separator which cut the string (default is " ").
// Note : Nowadays it's impossible to get a vector of words because we can't append data in a vector.
echo("*** getsplit() ***");
echo(getsplit(str)); // ECHO: "OpenScad"
echo(getsplit(str, 3)); // ECHO: "free"
echo(getsplit("123, 456, 789", 1, ", ")); // ECHO: "456"
*/


// function strToInt(str, base=10, i=0, nb=0) = (str[0] == "-") ? -1*_strToInt(str, base, 1) : _strToInt(str, base);
// function _strToInt(str, base, i=0, nb=0) = (i == len(str)) ? nb : nb+_strToInt(str, base, i+1, search(str[i],"0123456789ABCDEF")[0]*pow(base,len(str)-i-1));

// function strcat(v, car="") = _strcat(v, len(v)-1, car, 0);
// function _strcat(v, i, car, s) = (i==s ? v[i] : str(_strcat(v, i-1, car, s), str(car,v[i]) ));

function substr(data, i, length=0) = (length == 0) ? _substr(data, i, len(data)) : _substr(data, i, length+i);
function _substr(str, i, j, out="") = (i==j) ? out : str(str[i], _substr(str, i+1, j, out));

// function fill(car, nb_occ, out="") = (nb_occ == 0) ? out : str(fill(car, nb_occ-1, out), car);

// function getsplit(str, index=0, char=" ") = (index==0) ? substr(str, 0, search(char, str)[0]) : getsplit(   substr(str, search(char, str)[0]+1)   , index-1, char);


//************* The following code was written by ChatGPT to support Maker World customization ********************
// =========================
// 1) Whitespace / indexing (robust)
// =========================
function ord_safe(c) = (is_string(c) && len(c) > 0) ? ord(c[0]) : -1;

// ASCII control/space (<=32) + NBSP(160) + ZWSP(8203) + BOM(65279)
function is_ws_any(c) =
    is_undef(c) ? true :
    (is_string(c) && len(c) > 0 ?
        let(o = ord(c[0])) (o <= 32) || (o == 160) || (o == 8203) || (o == 65279)
        : false);

function first_non_ws_any(s, i=0) =
    (i >= len(s) || !is_ws_any(s[i])) ? i : first_non_ws_any(s, i+1);

function last_non_ws_any(s, i=-1) =
    let(idx = (i == -1) ? len(s)-1 : i)
    (idx < 0 || !is_ws_any(s[idx])) ? idx : last_non_ws_any(s, idx-1);

// Inclusive slice s[a..b], bounds-safe
function slice_inclusive(s, a, b) =
    (!is_string(s) || len(s) == 0) ? "" :
    let(
        aa0 = is_undef(a) ? 0        : a,
        bb0 = is_undef(b) ? len(s)-1 : b,
        aa  = max(0, min(aa0, len(s)-1)),
        bb  = max(0, min(bb0, len(s)-1))
    )
    (aa > bb) ? "" : _slice_inc_core(s, aa, bb, aa, "");
function _slice_inc_core(s, aa, bb, k, out) =
    (k > bb) ? out : _slice_inc_core(s, aa, bb, k+1, str(out, s[k]));

// First index of ch in [start..stop]; if stop<0 → len(s)-1
function first_index_of(s, ch, start=0, stop=-1) =
    let(st = (stop < 0) ? (len(s)-1) : stop)
    (start > st) ? -1 : _fio(s, ch, start, st, start);
function _fio(s, ch, start, stop, k) =
    (k > stop) ? -1 :
    (s[k] == ch ? k : _fio(s, ch, start, stop, k+1));

function _is_empty(t) =
    let(i = first_non_ws_any(t), j = last_non_ws_any(t)) (i > j);

// =========================
// 2) Comment stripping (respects quotes)
// =========================
function strip_comments(s) = _strip_comments_core(s, 0, false, "");
function _strip_comments_core(s, i, in_str, out) =
    (i >= len(s)) ? out :
    let(
        c        = s[i],
        quote    = (c == "\""),
        in_str2  = in_str ? (!quote) : quote,
        is_line  = (!in_str && c == "/" && i+1 < len(s) && s[i+1] == "/"),
        is_block = (!in_str && c == "/" && i+1 < len(s) && s[i+1] == "*")
    )
    is_line  ? _strip_comments_core(s, _find_eol(s, i+2), in_str, out) :
    is_block ? _strip_comments_core(s, _find_block_end(s, i+2), in_str, out) :
               _strip_comments_core(s, i+1, in_str2, str(out, c));
function _find_eol(s, k) =
    (k >= len(s)) ? k :
    ((s[k] == "\n" || s[k] == "\r") ? (k+1) : _find_eol(s, k+1));
function _find_block_end(s, k) =
    (k+1 >= len(s)) ? len(s) :
    ((s[k] == "*" && s[k+1] == "/") ? (k+2) : _find_block_end(s, k+1));

// =========================
// 3) Balanced outer [ ... ] detection (don’t strip for CSV-of-rows)
// =========================
function _find_matching_close(s, open_idx) =
    _find_matching_close_core(s, open_idx+1, 1, false);
function _find_matching_close_core(s, k, depth, in_str) =
    (k >= len(s)) ? -1 :
    let(c = s[k],
        quote = (c == "\""),
        in_str2 = in_str ? (!quote) : quote,
        depth2  = in_str ? depth
                         : depth + ((c == "[") ? 1 : 0) - ((c == "]") ? 1 : 0))
    (depth2 == 0) ? k : _find_matching_close_core(s, k+1, depth2, in_str2);

function _is_fully_wrapped(s, i, j) =
    (i < j && s[i] == "[" && s[j] == "]" && _find_matching_close(s, i) == j);

// =========================
/* 4) Number detection / conversion (ints + simple floats) */
// =========================
function _is_digit(c) = !is_undef(c) && (c >= "0" && c <= "9");

function is_num_like(t) =
    let(i = first_non_ws_any(t), j = last_non_ws_any(t))
    (i <= j) && _num_like_worker(t, i, j, i, false, false);
function _num_like_worker(t, i, j, start, seen_dot, seen_digit) =
    (i > j) ? seen_digit :
    let(c = t[i])
        ((c == "-" || c == "+") && i == start) ? _num_like_worker(t, i+1, j, start, seen_dot, seen_digit) :
        ( c == "." && !seen_dot )              ? _num_like_worker(t, i+1, j, start, true, seen_digit) :
        ( _is_digit(c) )                       ? _num_like_worker(t, i+1, j, start, seen_dot, true) :
                                                 false;

function _str_to_num(t) =
    let(i = first_non_ws_any(t), j = last_non_ws_any(t),
        neg   = (i <= j && t[i] == "-"),
        start = (neg || (i <= j && t[i] == "+")) ? i+1 : i,
        dot   = first_index_of(t, ".", start, j))
    (dot == -1)
        ? _parse_int(t, start, j, 0) * (neg ? -1 : 1)
        : (neg ? -1 : 1) * (_parse_int(t, start, dot-1, 0) + _parse_frac(t, dot+1, j, 1, 0));
function _parse_int(t, a, b, acc) =
    (a > b) ? acc : _parse_int(t, a+1, b, acc*10 + _digit_safe(t[a]));
function _parse_frac(t, a, b, place, acc) =
    (a > b) ? acc : _parse_frac(t, a+1, b, place+1, acc + _digit_safe(t[a]) * pow(10, -place));
function _digit_safe(c) = (is_undef(c) || !_is_digit(c)) ? 0 : (ord(c) - ord("0"));

// =========================
// 5) Identifier helpers + substitution (robust)
// =========================
function is_ident_start(c) =
    (!is_undef(c) && ((c >= "A" && c <= "Z") || (c >= "a" && c <= "z") || (c == "_")));
function is_ident_rest(c) =
    is_ident_start(c) || (!is_undef(c) && (c >= "0" && c <= "9"));

// Robust: no default-arg tricks
function ident_end_index(s, start) =
    (!is_string(s) || start < 0 || start >= len(s) || !is_ident_start(s[start]))
        ? (start - 1)
        : _ident_end_index_core(s, start, start);
function _ident_end_index_core(s, start, k) =
    (k + 1 >= len(s) || !is_ident_rest(s[k + 1])) ? k : _ident_end_index_core(s, start, k + 1);

function _find_name_idx(name, names, i=0) =
    (i >= len(names)) ? -1 :
    (names[i] == name ? i : _find_name_idx(name, names, i+1));

// Substitute all identifiers *inside* token string `t` with their values (as text).
function substitute_idents_in_token(t, names, values, strict, i=0, out="") =
    (i >= len(t)) ? out :
    let(c = t[i])
    (is_ident_start(c)
        ? let(
              e    = ident_end_index(t, i),
              name = (e >= i) ? slice_inclusive(t, i, e) : "",
              idx  = (e >= i) ? _find_name_idx(name, names) : -1,
              rep  = (idx >= 0 && idx < len(values))
                        ? str(values[idx])
                        : (strict && (e >= i)) ? assert(false, str("Unknown identifier: ", name))
                                               : name
          )
          substitute_idents_in_token(
              t, names, values, strict,
              (e >= i) ? (e + 1) : (i + 1),
              str(out, (e >= i) ? rep : c)
          )
        : substitute_idents_in_token(t, names, values, strict, i + 1, str(out, c))
    );

// Extract identifiers from tokens like "swm-10/2" → ["swm"]
function idents_in_token(t, i=0, acc=[]) =
    (i >= len(t)) ? acc :
    let(c = t[i])
    (is_ident_start(c)
        ? let(
              e    = ident_end_index(t, i),
              name = (e >= i) ? slice_inclusive(t, i, e) : ""
          )
          idents_in_token(
              t,
              (e >= i) ? (e + 1) : (i + 1),
              (e >= i) ? concat(acc, [name]) : acc
          )
        : idents_in_token(t, i + 1, acc)
    );

// =========================
// 6) Expression evaluator (+ - * /, parentheses, unary ±)
// =========================
function skip_ws(s, i) = (i < len(s) && is_ws_any(s[i])) ? skip_ws(s, i+1) : i;
function is_num_start_char(c) = _is_digit(c) || (c == ".");

// scan number end (digits + optional single dot)
function scan_number_end(s, i, seen_dot=false) =
    (i >= len(s)) ? (i-1) :
    let(c = s[i])
    (_is_digit(c) ? scan_number_end(s, i+1, seen_dot) :
     (c == "." && !seen_dot) ? scan_number_end(s, i+1, true) :
     (i-1));

function parse_number_at(s, i) =
    let(i1 = skip_ws(s, i))
    (i1 >= len(s) || !is_num_start_char(s[i1]))
        ? [false, 0, i]
        : let(j = scan_number_end(s, i1),
              num = _str_to_num(slice_inclusive(s, i1, j)))
          [true, num, j+1];

function parse_factor(s, i) =
    let(i1 = skip_ws(s, i))
    (i1 < len(s) && s[i1] == "(")
        ? let(r = parse_expr(s, i1+1),
              ok = r[0], val = r[1], k = r[2],
              k1 = skip_ws(s, k))
          (ok && k1 < len(s) && s[k1] == ")"
              ? [true, val, k1+1]
              : [false, 0, i])
    : (i1 < len(s) && (s[i1] == "-" || s[i1] == "+"))
        ? let(r = parse_factor(s, i1+1))
          (r[0] ? [true, (s[i1] == "-" ? -r[1] : r[1]), r[2]] : [false, 0, i])
    : parse_number_at(s, i1);

function parse_term_loop(s, acc, i) =
    let(i1 = skip_ws(s, i))
    (i1 < len(s) && (s[i1] == "*" || s[i1] == "/"))
        ? let(rf = parse_factor(s, i1+1))
          (rf[0]
              ? parse_term_loop(s, (s[i1] == "*" ? acc*rf[1] : acc/rf[1]), rf[2])
              : [false, 0, i])
        : [true, acc, i1];

function parse_term(s, i) =
    let(r = parse_factor(s, i))
    (r[0] ? parse_term_loop(s, r[1], r[2]) : r);

function parse_expr_loop(s, acc, i) =
    let(i1 = skip_ws(s, i))
    (i1 < len(s) && (s[i1] == "+" || s[i1] == "-"))
        ? let(rt = parse_term(s, i1+1))
          (rt[0]
              ? parse_expr_loop(s, (s[i1] == "+" ? acc+rt[1] : acc-rt[1]), rt[2])
              : [false, 0, i])
        : [true, acc, i1];

function parse_expr(s, i) =
    let(r = parse_term(s, i))
    (r[0] ? parse_expr_loop(s, r[1], r[2]) : r);

// Try to fully evaluate `t` → [ok, value]
function eval_expr_full(t) =
    let(r = parse_expr(t, 0), ok = r[0], i2 = skip_ws(t, r[2]))
    (ok && i2 == len(t)) ? [true, r[1]] : [false, 0];

// =========================
// 7) Base mixed parser (numbers, quoted strings, identifiers, nesting)
// =========================
function parse_csv_mixed(s) = _csv_loop_mixed(s, 0, 0, "", [], false);

function _csv_loop_mixed(s, i, depth, tok, acc, in_str) =
    (i >= len(s))
        ? _append_token_mixed(acc, tok)
        : let(
              c        = s[i],
              quote    = (c == "\""),
              in_str2  = in_str ? (!quote) : quote,   // toggle on "
              open     = (!in_str && c == "["),
              close    = (!in_str && c == "]"),
              comma0   = (!in_str && c == "," && depth == 0),
              depth2   = depth + (open ? 1 : 0) - (close ? 1 : 0),
              tok2     = (is_ws_any(c) && !in_str) ? tok : str(tok, c),
              acc2     = comma0 ? _append_token_mixed(acc, tok) : acc,
              tok3     = comma0 ? "" : tok2
          )
          _csv_loop_mixed(s, i+1, depth2, tok3, acc2, in_str2);

function _append_token_mixed(acc, tok) =
    _is_empty(tok) ? acc : concat(acc, [ _parse_element(tok) ]);

function _parse_element(tok) =
    let(i = first_non_ws_any(tok), j = last_non_ws_any(tok))
    (i > j) ? "" :
    let(a = tok[i], b = tok[j], t = slice_inclusive(tok, i, j))
        (a == "[" && b == "]") ? parse_csv_mixed(slice_inclusive(tok, i+1, j-1)) :
        (a == "\"" && b == "\"") ? slice_inclusive(tok, i+1, j-1) :
        (is_num_like(t) ? _str_to_num(t) : t);     // unquoted → raw token text

// =========================
// 8) Tagged parser (to discover IDs from the string)
// =========================
function parse_csv_mixed_tagged(s) = _csv_loop_mixed_tagged(s, 0, 0, "", [], false);

function _csv_loop_mixed_tagged(s, i, depth, tok, acc, in_str) =
    (i >= len(s))
        ? _append_token_mixed_tagged(acc, tok)
        : let(
              c        = s[i],
              quote    = (c == "\""),
              in_str2  = in_str ? (!quote) : quote,
              open     = (!in_str && c == "["),
              close    = (!in_str && c == "]"),
              comma0   = (!in_str && c == "," && depth == 0),
              depth2   = depth + (open ? 1 : 0) - (close ? 1 : 0),
              tok2     = (is_ws_any(c) && !in_str) ? tok : str(tok, c),
              acc2     = comma0 ? _append_token_mixed_tagged(acc, tok) : acc,
              tok3     = comma0 ? "" : tok2
          )
          _csv_loop_mixed_tagged(s, i+1, depth2, tok3, acc2, in_str2);

function _append_token_mixed_tagged(acc, tok) =
    _is_empty(tok) ? acc : concat(acc, [ _parse_element_tagged(tok) ]);

function _parse_element_tagged(tok) =
    let(i = first_non_ws_any(tok), j = last_non_ws_any(tok))
    (i > j) ? ["EMPTY"] :
    let(a = tok[i], b = tok[j], t = slice_inclusive(tok, i, j))
        (a == "[" && b == "]") ? parse_csv_mixed_tagged(slice_inclusive(tok, i+1, j-1)) :
        (a == "\"" && b == "\"") ? ["STR", slice_inclusive(tok, i+1, j-1)] :
        (is_num_like(t) ? ["NUM", _str_to_num(t)] : ["ID", t]);

// flat collector (also digs IDs out of expression tokens)
function collect_identifiers_from_tagged(v) =
    is_list(v)
        ? (len(v) > 0 && is_string(v[0]) && v[0] == "ID"
            ? idents_in_token(v[1])
            : [ for (e = v) each collect_identifiers_from_tagged(e) ])
        : [];

function uniq(xs, i=0, acc=[]) =
    (i >= len(xs)) ? acc :
    uniq(xs, i+1, contains(acc, xs[i]) ? acc : concat(acc, [xs[i]]));
function contains(xs, x, i=0) =
    (i >= len(xs)) ? false :
    (xs[i] == x ? true : contains(xs, x, i+1));

// =========================
// 9) Top-level parsers with comment stripping + correct wrapper detection
// =========================
function parse_csv_mixed_top(s) =
    let(
        s0 = strip_comments(s),
        i  = first_non_ws_any(s0), j = last_non_ws_any(s0)
    )
    (_is_fully_wrapped(s0, i, j)
        ? parse_csv_mixed(slice_inclusive(s0, i+1, j-1))
        : parse_csv_mixed(slice_inclusive(s0, i,   j  )));

function parse_csv_mixed_tagged_top(s) =
    let(
        s0 = strip_comments(s),
        i  = first_non_ws_any(s0), j = last_non_ws_any(s0)
    )
    (_is_fully_wrapped(s0, i, j)
        ? parse_csv_mixed_tagged(slice_inclusive(s0, i+1, j-1))
        : parse_csv_mixed_tagged(slice_inclusive(s0, i,   j  )));

// =========================
// 10) Per-input packaging using GLOBAL registry (optional)
// =========================
function vector_variable_parser(s, strict=true) =
    let(
        s0     = strip_comments(s),
        i      = first_non_ws_any(s0), j = last_non_ws_any(s0),
        s_trim = (i > j) ? "" : slice_inclusive(s0, i, j),
        tagged = parse_csv_mixed_tagged_top(s_trim),
        namesU = uniq(collect_identifiers_from_tagged(tagged)),
        valsU  = [ for (nm = namesU)
                    let(idx = _find_name_idx(nm, RESOLVE_NAMES))
                      (idx >= 0 && idx < len(RESOLVE_VALUES))
                        ? RESOLVE_VALUES[idx]
                        : (strict ? assert(false, str("Unknown identifier: ", nm)) : nm) ]
    )
    [ s_trim, namesU, valsU, strict ];

// =========================
// 11) Resolvers (with substitution + evaluation)
// =========================
function parse_csv_mixed_top_resolve(pkg_or_s, names=undef, values=undef, strict=false) =
    is_list(pkg_or_s) && is_undef(names)
        ? _parse_csv_mixed_top_resolve_core(pkg_or_s[0], pkg_or_s[1], pkg_or_s[2],
                                            (len(pkg_or_s) > 3) ? pkg_or_s[3] : false)
        : _parse_csv_mixed_top_resolve_core(pkg_or_s, names, values, strict);

function _parse_csv_mixed_top_resolve_core(s, names, values, strict=false) =
    let(
        s0 = strip_comments(s),
        i  = first_non_ws_any(s0), j = last_non_ws_any(s0)
    )
    parse_csv_mixed_resolve(
        _is_fully_wrapped(s0, i, j) ? slice_inclusive(s0, i+1, j-1) : slice_inclusive(s0, i, j),
        names, values, strict);

function parse_csv_mixed_resolve(s, names, values, strict) =
    _csv_loop_mixed_resolve(s, 0, 0, "", [], false, names, values, strict);

function _csv_loop_mixed_resolve(s, i, depth, tok, acc, in_str, names, values, strict) =
    (i >= len(s))
        ? _append_token_mixed_resolve(acc, tok, names, values, strict)
        : let(
              c        = s[i],
              quote    = (c == "\""),
              in_str2  = in_str ? (!quote) : quote,
              open     = (!in_str && c == "["),
              close    = (!in_str && c == "]"),
              comma0   = (!in_str && c == "," && depth == 0),
              depth2   = depth + (open ? 1 : 0) - (close ? 1 : 0),
              tok2     = (is_ws_any(c) && !in_str) ? tok : str(tok, c),
              acc2     = comma0 ? _append_token_mixed_resolve(acc, tok, names, values, strict) : acc,
              tok3     = comma0 ? "" : tok2
          )
          _csv_loop_mixed_resolve(s, i+1, depth2, tok3, acc2, in_str2, names, values, strict);

function _append_token_mixed_resolve(acc, tok, names, values, strict) =
    _is_empty(tok) ? acc : concat(acc, [ _parse_element_resolve(tok, names, values, strict) ]);

function _parse_element_resolve(tok, names, values, strict) =
    let(i = first_non_ws_any(tok), j = last_non_ws_any(tok))
    (i > j) ? "" :
    let(a = tok[i], b = tok[j], t0 = slice_inclusive(tok, i, j))
        (a == "[" && b == "]")
            ? parse_csv_mixed_resolve(slice_inclusive(tok, i+1, j-1), names, values, strict)
        : (a == "\"" && b == "\"")
            ? slice_inclusive(tok, i+1, j-1) // quoted string
        : let(tSub = substitute_idents_in_token(t0, names, values, strict),
              ev  = eval_expr_full(tSub))
            (ev[0] ? ev[1] : (is_num_like(tSub) ? _str_to_num(tSub) : tSub));  // number if evaluable

// =========================
// 12) Convenience: always return 2D rows
// =========================
function _ensure_2d_rows(v) = (len(v) == 0) ? [] : (is_list(v[0]) ? v : [v]);

function parse_csv_mixed_top_resolve_auto(s, strict=false) =
    _parse_csv_mixed_top_resolve_core(s, RESOLVE_NAMES, RESOLVE_VALUES, strict);

// One-liner for Customizer strings (always returns 2D)
function parse_user_vector(s, strict=false) =
    _ensure_2d_rows( parse_csv_mixed_top_resolve_auto(s, strict) );

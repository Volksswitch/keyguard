# Keyguard Designer — Changelog

## Version 79
- Removed all MakerWorld-specific support — the `MW_version` global and the `show_screenshotMW` code path are gone; locally rendered designs no longer need a "Maker World" flag
- Added support for the Samsung Galaxy Tab Pro 12.2
- Added a `slope_gap` parameter to the sloped keyguard edge for finer fit control on screen-protector mounting
- Renamed the `screenshot_file` parameter to `screenshot_filename`
- Renamed the `mounting_method` value "No Mount" to "- none -" for clearer presentation in the Customizer dropdown
- Added clear error messages when a laser-cut keyguard is paired with Raised Tabs or Clip-on Straps, instead of the previous silent fall-through to "Customizer settings"
- Reworked sizing of the closed-ridge family (`rridge`, `crridge`, `hdridge`) and the cell-ridge wall — ridge dimensions are now inner-based, slope and chamfer no longer bloat the inner dimension, and the ridge wall extends through the full keyguard depth
- Reworked ridges around merged cell groups (L-shaped and cross-shaped merges): per-end convex/concave corner classification, inner rounding driven by the cell corner radius, chamfered top edges, full-length sides, and enlarged concave corners

## Version 78
- This release is all about supporting the new Volksswitch Keyguard Designer Web App — you no longer need to install OpenSCAD to do keyguard design
- The web app will very likely be acceptable to the individuals who manage your company- or district-managed computer

## Version 77
- Added the ability to put raised tabs on the top and bottom edges of a keyguard or keyguard frame
- Snap-in tabs for keyguards in frames are now a function of the screen area thickness rather than the keyguard thickness
- Outer arcs placed in the screen region are now sensitive to cell chamfer values, and those in the case region are sensitive to keyguard chamfer
- Outer arcs can be applied to a depth less than the full depth of the keyguard
- Introduced a new design for the `openings_and_additions.txt` file to reduce confusion and add new capabilities; the keyguard designer supports both the new and the original versions of the O&A file

## Version 76
- Changed the color used to display a keyguard along with its frame from red to transparent pink
- Added support for displaying where the frame will be split without first generating frame halves
- Added reporting in the console for how far in mm the split will occur from the left and top side of the keyguard/frame
- Moved horizontal and vertical "tightness of fit" options from the Special Actions and Settings section to the Keyguard Frame section — they now only affect the keyguard when it is mounted in a frame
- Changed the horizontal and vertical "tightness of fit" options to run from -1.0 to 1.0
- Changed the "insert tightness of fit" option to run from -1.0 to 1.0
- Changed the "tightness of dovetail joint" option to affect the second half of keyguard rather than the first
- Changed the "tightness of dovetail joint" option to run from -0.5 to 0.5

## Version 75
- Added support for additional case variables to the openings_and_additions.txt file
- Added support for the Tobii-Dynavox I-13 system
- Fixed bug that prevented outer arc cuts from appearing in the case and tablet regions
- Added support for outer arcs to the case_additions section as "-" shapes
- Added support for the Samsung Galaxy Tab S3 and the Tobii-Dynavox T15+
- Changed the keyguard horizontal and vertical tightness of fit options to run from -10 to 10
- Updated measurement data for the GridPad 12 and the Tobii-Dynavox I-110
- Added support for displaying where the keyguard will be split without first generating keyguard halves
- Fixed bug when upper message bar was 0 height but both the upper status bar and upper command bars were > 0 height
- Adjusted the logic to ignore "App Layout in mm" values if any "App Layout in px" value is > 0
- Moved "split keyguard" options from Special Actions and Settings to its own section
- Added the ability to simultaneously display the keyguard with the frame, removed support for 999 "cheat code"

## Version 74
- Fixed bug that prevented engraved/embossed text from working with split keyguards
- Moved case measurements from Clip-on Straps Info section to the Case Info section
- Moved "unequal side" case measurements from Clip-on Straps Info section to the Special Actions and Settings section
- Changed name of "starting height" in Raised Tabs Info section to "raised tabs starting height"
- Added the ability to add a sloped edge to the keyguard as an option for mounting in a typical screen protector with sloped edges
- Changed the names of "mini clip 1" to "mini clip" and "mini clip 2" to "micro clip"

## Version 73
- Reworked the case_addition shapes so that "-" shapes are focused entirely on removing plastic
- Removed the Accent 800 tablet and replaced it with the Accent 800-30 and Accent 800-40
- Fixed bug where older Profiles reported untouched vector input as changes to the default profile
- Added flag to indicate whether the designer is to be run locally or on Maker World
- Maker World flag allows for 2-dimensional screenshots when run locally to prevent CGAL error

## Version 72
- Added support for laser-cut text on laser-cut keyguards
- Fixed bug associated with engraving/embossing text in the case region
- Fixed bug that ignored case additions when the screen region was hidden
- Modified the program so it would be usable on the Maker World website — in "lite" form
- Inputs no longer have to be enclosed in square brackets
- A screenshot file must now be named "default.svg" in order to import into the designer
- Fixed a bug that allowed tablet openings to appear sloped when the type of keyguard is Laser-Cut

## Version 71
- Improved the dimensional information for the Grid Pad 13
- Added support for an OPTIONAL "tablet_openings" vector to the openings_and_additions.txt file
- Added an option to manually set the length of the posts in a post-mounted keyguard/frame system
- Added basic support for the Smartbox Grid Pad 10s, 15, and Touch Pad
- Fixed bug associated with sliding dovetails vertically
- Added basic support for the Surface Go 2, 3, and 4
- Fixed bug that caused render step to fail if slide-in tabs were 2 mm in length and had 0 distance between them

## Version 70
- Removed the swap camera and home button option in the Tablet section and replaced it with a rotate tablet 180 degrees option; this allows for tablets with unequal borders to be rotated without changing the standard tablet data
- Updated all tablet data to generate screen sizes based on pixel counts and pixel sizes
- Fixed a bug in setting screen area thickness smaller than keyguard thickness that produced non-manifold STL files
- Added support for keyguards without cases that need to have different corner radii in different corners
- Modified the definition of dovetails for split keyguards to support choosing a specific dovetail size and adjusting their location
- Added support for keyguard frames that go directly on a tablet without a case
- Changed the way that split keyguard frames are generated — now each half is generated independently
- Added support for setting the corner radii of a shelf independent of the corner radii of the keyguard or frame
- Removed support for recommending pre-version 66 Customizer changes in the Console pane
- Changed the behavior of setting cell heights and widths such that the value can't cause cells to overlap — a message is shown in the Console pane describing the mm and px values actually used by the designer
- Added an error message to the Console when someone uses the "other tablet" but doesn't provide sufficient data
- Fixed bug associated with splitting a keyguard frame for a portrait-oriented keyguard

## Version 69
- Fixed bug that prevented outer arcs in case_openings from properly displaying in the first layer of a Laser-Cut keyguard
- Corrected mislabeling of the keyguard thickness parameter
- Fixed bug that forced ambient light sensors to be exposed if you also select symmetric openings
- Fixed bug that caused the grid to not respond properly to edge compensation settings
- Added support for "engraving" any of the basic shapes into the underside of a keyguard to support the NovaChat 5.3
- Added support for the NovaChat 10.7 which uses a Samsung Galaxy Tab S7
- Added logic to limit the bar corner radius for thin bars
- Made some small adjustments to the dimensions of the Accent 800
- Added support for the Via Pro, Via Nano, and Via Mini
- Added ability to hide the grid area to help with setting padding values based on a screenshot
- Added support for the iPad Air M3 11 & 13 inch and for the iPad 11 (A16)
- Added support for the NovaChat 5.3
- Modified the behavior of the rridge shape so that it is anchored in the lower-left corner and introduced the crridge shape that is anchored at its center
- Modified the tor and hor variables so that they behave independently of the unit_of_measure_for_screen value
- Added support for tenths of a mm to the "mount to top of opening distance" option in the Posts section
- Added support for the TobiiDynavox I-16
- Modified the behavior of edge compensation to be measured from the edge of the keyguard rather than the edge of the screen
- Added more options to hide snap-ins for in-frame mounting of the keyguard
- Added support for tenths of a millimeter and a slider when setting the split line for split keyguards
- Fixed a bug where unequal border sizes weren't reflected in keyguards without a case

## Version 68
- Added support for rotating mini tabs and manually added slide-in tabs
- Added better handling of designs where the screen area is thinner than the keyguard
- Made the trimming of clip-on strap pedestals sensitive to edge compensation adjustments
- Added support for specifying cell height and width in pixels
- Changed the names of cell width and cell height to xx in mm; the original values are retained in Special Actions and Settings
- Fixed ridges around cells to account for cell edge slope
- When a keyguard is changed from 3D-Printed to Laser-cut the mounting method is set to No Mount if not already set to Slide-in Tabs
- Fixed bug that trimmed bumps and ridges specified in case_openings if they extended into the screen area
- Changed code so that small items like ridges in screen_openings are more likely to be seen if px is used as unit when values are mm
- Removed the "h" and "w" variables in openings_and_additions.txt because they're confusing
- Fixed bug that prevented camera and home button openings as well as ALS openings from being cut in keyguards with frames and in the keyguard frames themselves
- Updated code to enforce that keyguard frames and their keyguards are incompatible with unequal openings as well as symmetric openings
- Added greater precision (0.1 mm) to millimeter measurements that might require extra precision
- Added support for a manual circular ridge (cridge)
- Added support for a manual rectangular ridge (rridge) that is anchored in the center
- Fixed bug that prevented ALSs to be exposed if the keyguard was thicker than the screen area
- Fixed bug preventing "-" shapes from removing plastic when used with laser-cut designs

## Version 67
- Circular cuts in the openings_and_additions.txt file get their diameter from the "height" column, not the "width" column
- Fixed a bug in the generation of the first layer of a laser-cut design that made circles too large
- The user interface for grid design has changed to set the height and width of rectangular openings directly rather than indirectly via the widths of the horizontal and vertical rails; this resulted in changing the names of several options: rail slope → cell edge slope, preferred rail height → screen area thickness, and split_line → split_line_location
- Fixed a bug that had slide-in tab thickness depending on the thickness of the rails
- Changed the name of the Grid Layout section to Grid Info for consistency with other sections
- Added grid width in millimeters (gwm), grid height in millimeters (ghm), and keyguard thickness (kt) to the variables available for use in the openings_and_additions.txt file
- Fixed bug where edge compensation failed to take the cell edge slope into account when determining how much to reduce cell size
- Replaced the "add rounded corners for strength" option with a "bar corner radius option" for simplicity
- Fixed bug involving one slot for a snap-in tab responding to changes in unequal bottom of case opening

## Version 66
- Changed the default value of case_width = 220 in Clip-on Strap Info to 275 so a generated horizontal clip would look realistic
- Added support for directly choosing circular openings and moved several of the grid layout options to grid special settings
- Fixed bug that allowed the keyguard thickness of an acrylic keyguard to be other than 3.175 mm thick
- Added support for rectangular and rounded rectangular shapes that are anchored in the center
- Changed section name from "Type of Keyguard" to "Keyguard Basics" to reinforce that this is the section to start with
- Removed some unused modules to clean up the code
- Refactored the creation of a 2D image from a 3D design to avoid arbitrary lines in the SVG file that mess up the laser cut
- Fixed bug in handling svg, ridge, ttext, and btext rotation and other options in the openings_and_additions.txt file
- Added support for the iPad Mini 7 (A17 Pro)
- Fixed bug where echoes of case additions leaked through to keyguards in keyguard frames
- Fixed bug involving keyguard frames and keyguards where the preferred rail height is less than the keyguard thickness
- Moved the generate instruction out of Special Actions and Settings and into Keyguard Basics
- Added support for manual slide-in tab and clip-on strap mounts to keyguard frames

## Version 65
- Updated Accent 1400-30a data based on pixel count information from PRC
- Added support for the Accent 1000-20
- Fixed bug when there's an uneven case opening and the keyguard thickness exceeds the rail height
- Fixed bug associated with ALS locations when tablet is oriented in portrait mode
- Added support for engraving/embossing text from within the Customizer
- Exposed the default left and bottom case opening values to make it easier to determine the unequal left/bottom of case value
- Added support for a ridge that can be rotated at any angle, not just horizontal and vertical
- Added support for customization of the slope (chamfer) around the edge of the keyguard
- Added support for customization of the slope (chamfer) at the top edge of a cell (also affects the chamfer on bars)
- Added support for r/rr/c/hd cuts that don't go all the way through the keyguard by putting a number in the "other" column
- Fixed bug that prevented using home button edge slope with keyguard frames

## Version 64
- Distinguished between two different Accent 1400-30 tablets that impacts their pixel count differences

## Version 63
- Cleaned up some artifacts that appear with manual ridge arcs when the ridge thickness is set to larger than 7 mm
- Added minimal support for all 23 Samsung tablets introduced since 2020 (support doesn't include openings for cameras or buttons on the face of the tablet)
- Changed naming of Accent tablets to match what appears on the PRC website
- Added an entry for Grid Pad 11
- Fixed bugs when adding symmetric home button and camera openings
- Corrected the data for the Accent 1400-30
- Fixed bug that allowed laser-cut keyguards to have cells with non-90 degree top and bottom slopes
- Fixed bug that allowed the keyguard shelf to be thicker than the keyguard itself
- Fixed bug that allowed cell inserts to be created via laser-cutting
- Fixed bug that allowed the mini tabs for post mounting to be higher than the thickness of the keyguard

## Version 62
- Fixed how "preferred rail height" is reported when generating Customizer Settings
- Fixed bug with recurved edges of slide-in tabs with a length value less than 3 mm
- Rested horizontal and vertical ridges on the bottom of the keyguard and adjust the total height to match
- Added a ridge arc to support manual ridges around merged cells
- Added cell_width (cw), cell_height (ch), and cell corner radius (ccr) to the variables that can be used in the openings_and_additions.txt file
- Added height_of_ridge (hor) and thickness_of_ridge (tor) for use in the openings_and_additions.txt file
- Fixed the double-entry of NovaChat 8.5 in the "type of tablet" pull-down list in the Customizer
- Fixed the values for the Posts Info section when generating Customizer Settings
- Added support for the iPad Pro 11-inch (M4), iPad Pro 13-inch (M4), iPad Air 11-inch (M2), and iPad Air 13-inch (M2)
- Fixed a bug where a groove appeared in the bar region even if the associated bar was of zero height
- Fixed some bugs with the creation of posts
- Fixed the camera location on the earlier iPad Pros

## Version 61
- Belatedly added keyguard_thickness to the settings displayed when choosing to generate Customizer Settings
- Added support for horizontal and vertical alignment of ttext and btext
- Set the default preferred rail height to 4 mm to match the default keyguard thickness

## Version 60
- Added the ability to set the height of the grid region of the keyguard to one height (preferred rail height) and the rest of the keyguard to a greater height (keyguard height)
- Fixed bug in the emboss/engrave feature

## Version 59
- Added support for horizontal and vertical rail widths, compensation for tight cases to the txt files
- Added support for top/bottom/left/right padding, compensation for tight cases to the txt files
- Added support for angling the display of the keyguard at fixed angles for evaluating keyguard thickness along with screenshot
- Added support for NovaChat 8.5
- Added support for NovaChat 5.3 and 5.4
- Modified the "posts" mounting method to utilize a round post all the way across the top of the keyguard if both the status bar and the upper message bar are hidden
- Made a similar modification to the posts mounting option for a keyguard frame
- Added support for subtracting plastic from the outer edge of a keyguard like the ability to add plastic
- Fixed bug that swapped the t3 and t4 triangles
- Putting a "#" in the ID column for a screen opening, case opening, or case addition will highlight it in red in the display

## Version 58
- Fixed bug that prevented generating "first layer for SVG/DXF files" when "type of keyguard" is set to "3D-Printed"
- Ignoring the home button edge slope if add symmetric openings is set to yes
- Added support for the Amazon Fire Max 11
- Prevented symmetric camera/home button openings when using a keyguard frame

## Version 57
- Changed the default value of the mini tab height from 2 mm to 1 mm
- Fixed bug in the creation of cell inserts
- Fixed several bugs in the creation of keyguards mounted to a keyguard frame with posts
- Added support for zero-width rails
- Fixed a minor bug in the creation of posts as a mounting method

## Version 56
- Added support for adding a sloped edge to the sides of the Home Button opening to provide easier manual access and made it the default
- Cleaned up extraneous ALS instruction for iPad 10
- Added support for the TobiiDynavox I-110 (thanks Tee Jay!)
- Fixed bug associated with the size of the camera opening with laser-cut designs
- Added support for mounting posts for systems like the PRC Via Pro
- Moved edge compensation options from Grid Special Settings to Tablet Case section
- Added support for post-based mounting of the keyguard in a keyguard frame
- Added designer version number to Customizer Settings
- Added ability to expose Ambient Light Sensors (or not), exposed by default
- For visualization of the keyguard and frame together, put [999] in the "other tablet pixel sizes box and generate the keyguard frame
- Made "Shelf" an official keyguard mounting method rather than allowing it only for keyguard frames
- Added the ability to split a keyguard frame

## Version 55
- Bug fix in the generation of DXF/SVG models

## Version 54
- Added limits for the value of the app layout pixel values because it is the only way to enter values larger than 999

## Version 53
- Made the dimensions of the bars independent of any settings in the Free-form and Hybrid Keyguard Settings section
- Changed the color associated with SVG/DXF generated images so they didn't look as much like every rendered keyguard
- Widened the camera-related cuts associated with a laser-cut keyguard to account for the fact that they can't be sloped; Home Button, ALS, and cuts created in the TXT file remain unchanged
- Added logic to provide an error message if trying to create a laser-cut keyguard frame or a laser-cut keyguard that goes in a keyguard frame
- Removed the guardrails from almost all numeric inputs — gets rid of the sliders which are very difficult to use and creates a more compact UI
- Added additional checks to ensure that App Layout measurements using pixels are internally consistent

## Version 52
- Updated generate > Customizer settings to properly report on Grid Settings
- Updated variables exposed in openings_and_additions.txt to be independent of the settings in the Free-form and Hybrid Keyguard Settings section
- Removed all code associated with a "Lite" version
- Fixed bug with opening corner radius shapes
- Fixed bugs when slide in tabs and raised tabs are used along with negative tightness of fit values
- Fixed bug when clip-on straps require no pedestal

## Version 51
- Combined the screen_openings.txt, case_openings.txt, and case_additions.txt files into a single file called openings_and_additions.txt
- Eliminated the need for the als_openings.txt file by moving that information into the program
- Added ALS openings for the iPad 1, 2, 3, 5, 6 and the iPad Mini 6
- Eliminated the need for the other_tablet.txt file by adding a pair of options in the Special Actions and Settings section

## Version 50
- Sent error message to the console if a cut is invalid (e.g., rounded rectangle with oversized corner radius)
- Refactored the approach to the compensation for tight cases
- Refactored the approach to portrait orientation
- Added support for these Microsoft Surface tablets: Pro 8, Pro 9 and Go 3
- Added support for the Amazon Fire HD 10 Plus tablet
- Eliminated the "shape of opening" option and now treat all shapes as variants of a rounded-rectangle
- Reorganized the Grid Layout section into two sections to simplify access to the most common options
- Made bar corner radii dependent on whether contiguous bars are exposed
- Increased the top-end number of pixels for setting the app layout from 2000 to 3000 to support very large tablets in portrait orientation

## Version 49
- Fixed bug when generating first layer of a keyguard with slide-in tabs
- Added support for variable sloped opening edges for rounded rectangles, hotdogs and circles
- Added ability to change the slopes of the top and bottom edges of cell openings to provide added visibility into cell openings when looking at tablet at small or very large angle
- Added support for selecting rounded rectangle corners for bars for greater strength
- Small clean-up on trim to screen function
- Cleaned up implementation of edge compensation for tight cases
- Added support for iPad 10, iPad Pro 11 - 4th gen, and iPad Pro 12.9 - 6th gen

## Version 48
- Fixed bug associated with setting the slope of the bottom edge of a rectangular opening
- Added support for iPad Air 5
- Added support for non-rectangular cell inserts
- Fixed bug in specification of cell insert recess
- Added support for an externally defined new tablet

## Version 47
- Changed the default size of the case opening and the keyguard in a keyguard frame to better match an iPad 9 and make more sense when exploring the features of a keyguard frame
- Added support for rectangular magnets in raised tabs
- Fixed bug in some renderings of slide-in tabs that were weakly attached to the rest of the keyguard
- Fixed bug with slide-in tabs that may result in non-manifold renderings
- Added support for symmetrical camera and home button openings so the keyguard can easily be rotated if the tablet is rotated

## Version 46
- Added support for changing the angle of the bottom edge of rectangular cell openings to provide better visual and manual access to small cell openings
- Removed reference to "wall" in .txt files because it is no longer supported
- Moved most variable calculations from the .txt files to the designer

## Version 45
- Added support to allow horizontal tabs to be different in length from vertical tabs
- Fixed bug to make the tablet coordinate system sensitive to the unequal case opening settings
- Fixed bug in "cut_case_openings" subroutine that was missing a second argument
- Refactored design to make screen elements and tablet elements insensitive to changes in unequal case opening settings
- Removed protection if manually placed clip-on strap pedestals extend into the screen
- Now able to add raised tabs and clip-on strap mounts to a keyguard frame
- The keyguard frame customization UI has been redesigned
- Reduced the lower limit for the length of slide-in tabs and shelf depth
- Keyguard tightness of fit is now a general value and not just tied to keyguard frame systems
- Refactored the edge compensation code
- Changed the extension of .info files to .txt for compatibility with Printables.com

## Version 44
- Added support for tablet openings (at this time just ASL sensor openings) by introducing a new .info file
- Expanded the camera opening 2.5 mm wider for iPad 7/8/9 to accommodate the ASL sensor in gen 7 and 8
- Reduced camera angle by 5 degrees
- Widened option for raised-tabs to 60 mm
- Modified raised tabs code to better support tabs with only a ramp portion and no flat portion
- Added support for controlling the angle of the ramp portion of the raised tab
- Replaced the two GridPad Fujitsu tablet types with a single GridPad 12
- Added support for snap-in attachments to keyguard frames

## Version 43
- Fixed bug that didn't show slide in tabs when keyguard was split
- Added pixel and millimeter measures directly to info files for use in placing openings and additions
- Added support for inputting app layout measurements directly in pixels for greater accuracy
- Removed bar size measurements from the padding_and_bar_size.xlsx file and changed its name to padding_size.xlsx

## Version 42
- Fixed and modified the behavior of the slide-in tab case additions to disconnect them from the Customizer pane
- Fixed a problem with manually located clip-on strap pedestals
- Fixed a problem with crescent moon case additions
- Generalized the concept of a "Braille insert" to be a generic "cell insert" — just no Braille text and no opening to create a "cell cover"
- Added support to cut out case-opening region of the keyguard to print case-additions separately
- Added support for a DIY "screen protector" or a keyguard "frame" that allows for "friction-fitting" the keyguard
- Widened all camera opening diameters by at least 1.5 mm to make keyguard placement easier

## Version 41
- screen_openings.info is now ignored if the tablet type is "blank"; extended functionality associated with "Braille inserts"
- Added "trim_to_rectangle_lower_left" and "trim_to_rectangle_upper_right" back to "Special Actions and Settings" section
- Setting rows and/or columns to 0 will fill in all grid cuts/openings in a grid-based keyguard
- Added support for the Grid Pad 13
- Added the ability to engrave or emboss text and control the depth of the engraving/embossing using the "corner radius" field
- Added the ability to put slide-in tabs along the long edge of the keyguard

## Version 40
- Removed "trim_to_rectangle_lower_left" and "trim_to_rectangle_upper_right" from "Special Actions and Settings" section because they weren't working predictably (code was kept in place and commented out in case it becomes useful again)
- Added support for "Braille inserts"

## Version 39
- Added support for the iPad Pro 12.9-inch 5th Generation, iPad Mini 6th Generation, iPad 9th Generation, iPad Pro 11-inch 2nd Generation and iPad Pro 11-inch 3rd Generation

## Version 38
- Added support for the Accent 800
- Fixed options to add compensation for tight cases to use case opening size rather than screen size

## Version 37
- Moved the home button location further from the edge of the screen and increased the height and width of the home button for the Accent 1000
- Fixed a bug associated with circular openings and cell ridges when changing rail widths
- Added support for the Fujitsu Stylistic 616 which is exactly like the Fujitsu Stylistic 665 and associated both with the GridPad
- Fixed bug that prevented height/width compensation from working with unequal left/bottom case openings
- Added support for adding height/width compensation to one side of the keyguard at a time
- Added a virtual tablet called "blank" that can be used to specify an arbitrary-sized keyguard — largely for laser-cutting
- Changed labels for "unit of measure" and "starting corner for measurements" to reinforce that they only apply to screen openings
- Added option to ignore Laser-Cutting best practices when creating a laser-cut keyguard
- Added ability to trim keyguard to an arbitrary rectangle by specifying the lower left and upper right coordinates relative to the lower left corner of the case opening
- Added the ability to use a large rectangle or rounded rectangle as an overall case addition
- Added temporary support for the Chat Fusion 10 from PRC/Saltillo, need verification of screen dimensions and camera/home button data
- Changed the x,y anchor point location for manual clip-on strap pedestals
- Fixed bug where engraved SVG images wouldn't rotate
- Added the ability to control the depth of an engraved svg image

## Version 36
- Fixed bug that allowed you to choose a mounting method other than slide-in tabs and no mount for laser-cut keyguards
- Fixed bug that put a chamfer on outer arcs when type of keyguard is Laser-Cut
- Added support for displaying an SVG version of a screenshot below the keyguard
- Changed rules for shape of opening in laser cut keyguards to allow for circles and rounded rectangles with larger corner radii
- Changed rules to allow for SVG generation of first layer of 3D-Printed type of keyguard — used when testing fit of keyguard to screenshot

## Version 35
- Enlarged the opening for the home button in the Accent 1000 to make it easier to reach
- Added support for generating SVG/DXF files for laser-cutting a keyguard
- Limited slide-in tab length to 10 mm rather than 20 mm and set the minimum to 4 mm (exactly 3.175 mm for a laser-cut keyguard)

## Version 34
- Fixed bug in vridgef and hridge features
- Added support for ridges around cells
- Removed support for walls in screen/case openings.info files

## Version 33
- Added support for Apple iPad models: iPad 8th generation, iPad Pro 12.9-inch 4th Generation, and iPad Air 4
- Fixed home button location and widened the camera opening for the iPad Pro 12.9-inch 3rd Generation
- Fixed bug in "swap camera and home button" when home button is not located on the face of the tablet
- Turned off creation of camera opening and home button opening if tablet is a system that requires a case

## Version 32
- Added support for Dynavox Indi
- Added support for engraved and embossed SVG images

## Version 31
- Added support for Amazon Fire HD 8 (10th generation)
- Added support for the Accent 1000, the Dynavox 1-12+, and updated camera/home button info for NovaChat 8
- Changed camera and home button locations to be measured from the edge of the screen rather than the edge of the tablet
- Added support for cutting out the entire screen area — primarily to support validating dimensions for new tablets
- Fixed bug that improperly calculated trimming of towers for clips
- Refactored code associated with unequal case opening dimensions
- Added support for tablets where the screen doesn't sit exactly in the middle of the glass

## Version 30
- Added clip-on strap mounting pedestals and slide-in tabs to list of items that can be added to a keyguard in the case_additions.info file — to make it possible to have pedestals and tabs outside of the normal keyguard region and into the case_additions regions
- Added support for two different "mini" clips — clips that don't wrap around to the underside of the tablet/case so that the clip won't interfere with the tablet mount
- Extended the spur of the clip an additional mm to better engage the slot in the pedestal
- Changed the width of the slots in clips to be a function of the clip width
- Added support for independently setting the widths of horizontal and vertical clips
- Fixed a bug with rounded-rectangle case additions when the corner radius is 0
- Fixed several bugs associated with creating cell covers

## Version 29
- Extended tablet data to support non-iPad-style tablets by allowing for cameras and home buttons to be located on the long edge of the tablet and to have non-circular shapes
- Added support for clip-on straps to attach to long edge of keyguard, short edge, or both

## Version 28
- Added support for independent widths for horizontal and vertical rails
- Added support for the Accent 1400 (AC14-20 & AC14-30) system
- Added support for systems (like the Accent) for which there is no tablet sizing information
- Added support for non-rectangular perimeters
- Added support for creating both loose and tight dovetail joints

## Version 27
- Added support for Surface Pro 7 and Surface Pro X
- Added support for negative padding values
- Added support for dovetail joints, for a more reliable joint, when splitting a keyguard to print on a smaller printer

## Version 26
- Changed name of Surface Pro 2017 to Surface Pro 5
- Added support for the Fujitsu Stylistic Q665 (used in the Grid Pad 11 system)
- Added check for a zero mm/px corner radius used with a cut for a rounded rectangle and changes shape to a rectangle
- Fixed bugs associated with adding height and width compensation for tight cases
- Fixed bugs associated with trimming the keyguard to the size of the screen
- Fixed code so a zero width wall wouldn't appear between the message and command bar if both are exposed
- Modified outer arcs so that their chamfers would match the chamfers of other shapes in size
- Changed option for "slide_in_tab_thickness" to "preferred_slide_in_tab_thickness" and set actual thickness of tab to depend on rail height minus outer chamfer

## Version 25
- Added support for NovaChat 5 and 8
- Changed dimensions for NovaChat 10 based on feedback from Saltillo
- Added support for all Microsoft Surface tablets
- Fixed bugs with trim to screen and height and width compensation for tight cases

## Version 24
- Added support for the iPad 7th generation and iPad Mini 5
- Changed all iPad data to use calculated screen size measurements rather than values of Active Area from Apple
- Added support for bold, italic, and bold-italic font styles to top and bottom text

## Version 23
- Allowed raised tabs as thin as 1 mm
- Accounted for thin walls when using clip-on straps
- Added support for the NOVAchat 12

## Version 22
- Added number of horizontal pixels to the data for each tablet to properly support portrait mode for free-form and hybrid tablets
- Fixed several bugs associated with creating portrait free-form and hybrid tablets

## Version 21
- Fixed bug involving clip-on straps and split keyguards
- Fixed bug where cut for vertical clip-on strap (no case) was a different depth than the horizontal strap cuts
- Updated pixel sizes of 0.960 mm/pixel to a more accurate value of 0.962 mm/pixel
- Extended the upper bound for added thickness for tight cases from 15 mm to 20 mm

## Version 20
- Added support for the iPad Air 3 and the Surface Pro 4

## Version 19
- Changed upper limits on command and message bars from 25 mm to 40 mm to support large tablets
- Fixed bug that was exposed when adding height and width compensation to the keyguard for tight fitting cases with very large corner radii
- Made all radii, including those on the outer corners of the keyguard sensitive to the value of "smoothness_of_circles_and_arcs"
- Fixed a bug that clipped the underside of a clip-on pedestal when it is adjacent to a bar

## Version 18
- Added support for splitting the keyguard into two halves for printing on smaller 3D printers
- Put small chamfer at the top edge of all openings including the home button opening (only visible with large edge slopes like 90 degrees)
- Separated circle from hotdog when specifying screen and case openings
- Added minimal error checking for data in screen_openings.info and case_openings.info
- Fixed bug when placing additions from case_openings.info
- Moved pedestals for clip-on straps inward slightly to account for chamfer on the outside edge of keyguard
- Fixed bug that produced a static width for the vertical clip-on strap slots

## Version 17
- Changed code that creates rounded corner slide-in tabs to use the offset() command because original code was confusing the Thingiverse Customizer
- Fixed bug that prevented adding bumps, ridges and walls in the case_openings.info file
- Added acknowledgements for all those who helped bring keyguard.scad to life

## Version 16
- Changed code to use offset() command to create rounded corners rather than cutting the corners
- Added a small chamfer to the top edge of the keyguard to reduce the chance of injury
- Changed code to add case and screen cuts "after" adding compensation for tight cases
- Added support for the NOVAchat 10.5 (does not support exposing the camera)
- Changed filename extension of case_cuts and screen_cuts files from .scad to .info to reduce confusion about what is the main OpenSCAD program

## Version 15
- Added support for Nova Chat 10 (does not support exposing the camera)
- Cleaned up the logic around when to cut for home and camera to account for lack of a home button or camera on the face of the tablet
- Added support for additive features like bumps, walls and ridges
- Fixed bug with height and width compensation for tight cases
- Added support for using clip-on straps with cases
- Added support for printing clips
- Added support for hiding and exposing the status bar at the top of the screen

## Version 14
- Added option to control the number of facets used in circles and arcs (original value was 360; default is now 40, which should greatly improve rendering times and eliminate issues for laptops with limited memory)
- Separated the tablet data from the statement that selects the data to use with the intent of making it easier to update and change the data in Excel
- Migrated from using Apple's statement of "active area" dimension to calculating the size of the screen based on number of pixels and pixel size — active area dimensions seemed to overestimate the size of the screen
- Added the ability to engrave text on the bottom of the keyguard
- Added support for a separate data file to hold cut information that sits outside of the screen area, will always be measured in millimeters and will always be measured from the lower left corner of the case opening

## Version 13
- Added support for text engraving

## Version 12
- Extended the upper end of the padding options to 100 mm after seeing a GoTalk Now 2-button layout
- Minor corrections to a couple of iPad Air 2 measurements
- Added support for swapping the camera/home button sides
- Added support for sloped sides on outer arcs

## Version 11
- Added support for iPad 6th Generation, iPad Pro 11-inch, and iPad Pro 12.9 inch 3rd Generation
- Added ability to offset the screen from one side of the case toward the other
- Fixed bug that caused rounded case corners not to appear in portrait mode
- Added ability to create outside corners on hybrid and freeform keyguards
- Added ability to change the width of slide-in and raised tabs and their relative location (changed the meaning of "width" as well)

## Version 10
- Reduced some code complexity by using the hull() command on hot dogs and rounded rectangles
- Removed options to compensate for height and width shrinkage, upon testing they are too simplistic and keyguards don't do well with annealing anyway
- Changed "raised tab thickness" to "preferred raised tab thickness" because the raised tab can't be thicker than the keyguard or it won't slice properly

## Version 9
- Added support for rounding the corners of the keyguards, when they are placed in a case, to accommodate cases that have rounded corners on their openings
- Combined functionality for both grid-based and free-form keyguards into a single designer
- Can now create cell openings that are rounded-rectangles
- Can limit the borders of a keyguard to the size of the screen for testing layouts

## Version 8
- Reduced the maximum slide-in tab width from 30 mm to 10 mm
- Added the ability to merge circular cells horizontally and to merge both rectangular and circular cells vertically

## Version 7
- Moved padding options to Grid Layout section of the user interface to clarify that these affect only the grid region of the screen
- Changed the width of the right border of the iPad 5th generation tablet to match width of the left border
- Made some variable value changes so that it is easier to see the choices selected in the Thingiverse Customizer
- Changed cover_home_button and cover_camera to expose_home_button and expose_camera because the original options were confusing

## Version 6
- Added control over the slope of the edges of a message/command bar

## Version 5
- Can print out a plug for one of the cells in the keyguard by choosing "cell cover" in the Special Actions and Settings > generate pull-down
- Can add a fudge factor to the height and width of the tablet to accommodate filaments that shrink slightly when printing
- Can add padding around the screen to make the keyguard stronger without affecting the grid and bars to account for cases that go right up to the edge of the screen

## Version 4
- Added support for circular cut-outs and the option to specify the shape of the cut-outs
- Added support for covering one or more cells
- Added support for merging a cell cut-out and the next cell cut-out

## Version 3
- Rewritten to better support portrait mode and to use cuts to create openings to the screen surface rather than defining rails
- Fixed bug in where padding appeared — put it around the grid rather than around the screen
- Increased the depth of Velcro cut-outs to 3 mm, which roughly translates to 2 mm when printed
- Cut for home button is now made at 90 degrees to not encroach on the grid on tablets with narrow borders

## Version 2
- Added support for clip-on straps as a mounting method

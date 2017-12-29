# Updates

### [eeDAP5.0 (Windows)](https://github.com/DIDSR/eeDAP/releases/tag/5.0)
*10/10/17*

Add dynamic start and stop feature to all tasks.

Add new tasks to communicate with ImageScope (collect annotations).

Debug desktop shortcut and random order problems in compiled version.


### [eeDAP4.2 (Windows)](https://github.com/DIDSR/eeDAP/releases/tag/4.2)
*8/18/17*

Add a new task to create and save imagescope annotation for FOV and eyepiece field.

Set scan scale for each image.

In global registration, provide image name and thumbnail of the slide being registered.

Add "restart registration" button to restart low resolution registration.

Temporary disable auto registration.  


### [eeDAP4.1 (Windows)](https://github.com/DIDSR/eeDAP/releases/tag/4.1)
*5/11/17*

Add option to use imagescope to open WSI ROI.

Create sample input files for public available WSIs.


### [eeDAP4.0 (Windows)](https://github.com/DIDSR/eeDAP/releases/tag/4.0)
*5/11/16*

New hardware supported:
  * Prior Stage (ProScan III)
  * USB 3.0 camera
  * Klarman Rulings reticle (KR-871)

User manual overhaul.

New workflow updates:
  * "Use offset button" is added during registration to avoid camera and eyepiece registration.
  * "Hide reticle" and "Show reticle" buttons are added to the task collection gui.

Improve "Best Registration" button performance.

Improve Camera_stage_review utility application interface and "take image" button.

### [eeDAP3p1](https://github.com/DIDSR/eeDAP/releases/tag/v3.1)
*7/16/15*

Add Camera_stage_review APP is for test and review camera and stage

Add Best Registration button

There are two versions for windows and linux system in the zip file. Please choose base on your system


### [eeDAP3p0](https://github.com/DIDSR/eeDAP/releases/tag/3.0)
*6/4/15*

Auto-registration of every ROI (speeds up the study)

Add option to not save MicroRT ROIs and WSI-extracted ROIs

Add a back button

Allow rotated slides, or equivalently, allow stages with different orientations

Use “BioFormats” procedures to eliminate proprietary routine for reading proprietary WSI images to simplify installation and allow functionality in Linux and 64-bit windows

Migrate documentation to DrExplain which outputs html and pdf versions


### eeDAP2p0 and Previous Versions
*2/14/14*

This project was originally hosted on googlecode, which shut down. There is an archive of that work at
http://archive.is/eedap.googlecode.com

Make sure to refer to the user manual for instructions on software install. 

Feel free to download the sample WSI to test the application. The software is a little sensitive to long file names (including the directory). It is recommended that you create a directory at the root, for example c:\000_whole_slides\100113_ThorLabs_20x.ndpi



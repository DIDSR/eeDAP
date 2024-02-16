## eeDAP Work Log

### Work List
REMINDER: 
   * Stage-Driver Connection issue
   * Documentation: DIDSR/eeDAPAnalysis
   * Documentation: eeDAP-Wiki
       

Registration Accuracy Study: Need to complete documentation on sarahndudgeon/eeDAP

### Complete List

1. Complete: Run eeDAP in Digital Mode - Works as expected
2. Complete: Install all software into new eeDAP computer
3. Complete: Run Prior Stage in MicroRT
4. In-Progress: Documentation of eeDAP operation from technician viewpoint + minor troubleshooting
5. Complete: Documentation of Java-Bioformats Version Matching
6. Create running log of common problems and solutions (see end of document)
7. Complete: New Bioformats (BF) update
8. Complete: Create new matlab script for task_HTT_Pivotal_20x.m
9.  Complete: Shipped Thorlabs stage to Yale 6/1/23; received by Yale 6/8/23; received by Kim Fall 2023(?)
10. Complete: Create inputfiles for Pivotal Study Batches 1-5
11. Complete: Error in image_load_halfscale
12. In-Progress: Run through eedap Pivotal study with Emma G.
13. In-Progress: Stage driver issue - com not recognized by device manager

---
## 1. Complete: Run eeDAP in Digital Mode

eeDAP performs in digital mode without error following the same procedures as shown by Qi Gong in Youtube Screen-Recording.

--- 
## 2. Complete: Install all software into new eeDAP computer

A list of all installed Software:
 * Matlab 2021a - version 9.10.01649659
   * License: 659504
   * OS Windows 10 Pro Version 10.0
   * Java Version: Java 1.8.0-202-b08 (SDK)
   * **Image Acquisition Toolbox** -> Operating on TRIAL License
      * Point Grey Camera Support from Image Acquisition Toolbox
   * Image Processing Toolbox: 11.3
   * Matlab Compiler: 11.3
   * Matlab Compiler SDK: 8.2
   * Signal Processing Toolbox: 8.6
   * Statistics and Machine Learning Toolbox 12.1
 * Matlab Bioformats 6.3.1 - Requires Java 8 (or higher) SDK from Open Microscopy Environment (OME)
 * Camera Drivers (1394camera646.exe DCAM Driver & Fly Capture 2.11 for USB for Camera: PointGrey Color USB3)
   * http://www.cs.cmu.edu/~iwan/1394/downloads/index.html
   * https://flir.app.boxcn.net/v/Flycapture2SDK 
 * Microsoft Office
 * Smartgit
 * Leica Aperio Imagescope
 * Team Viewer
 * Process Explorer
 * Zoom 
 * Fiji (FIJI is just ImageJ)
 * Prior Scientific (Pior III USB Driver for Prior Stage)
 
 ---
## 3. Run Prior Stage in MicroRT Mode

#### Complete:
1) Resolved Bioformats-Java Issue
2) Identified Image Acquisition Toolbox Required for eeDAP functionality
3) Stage-Com: resolved COM# issue where COMPORT does not wait for user input. 

#### Need: 
Currently the "Camera Preview" is so washed out (completely white) that the section cannot be viewed. Need to either adjust camera settings or other settings to verify MicroRT is correctly registering exact points.

1) Resolve Camera Setting Issues
2) Fully run MicroRT on Low-Res and High-Res Mode
3) Time full run of MicroRT with Prior stage
-Conclusion of Prior stage and eeDAP current form troubleshooting

---
## 4. In-Progress: Documentation of eeDAP operation from technician viewpoint + minor troubleshooting

Adding to the current Development/User Guide: https://github.com/kate-elfer/Notebook/blob/main/K-B%20Meetings/eeDAP_Hardware-Software.md 

Editing and Adding any feedback from Yale;Emma G.

---

 ## 5.Complete: Documentation of Bioformats Issue Resolution
 
 https://github.com/kate-elfer/Notebook/blob/main/K-B%20Meetings/eeDAP_MATLAB-Bioformats.md

---

 ## 7. New Biomformats Update

 If #5 does not resolve the BF issue, double check that the image is readalbe by bioformats by opening it in ImageJ/Fiji. If the image cannot be read by ImageJ/Fiji, it cannot be read by Matlab. Recommendation: download new WSI from source and delete previous image (no other steps have been needed to resolve this issue).

---

## 8. Create new matlab script for task_HTT_Pivotal_20x.m

Using the Pilot study task as a template, a new task for the Pivotal study has been created for eeDAP-Develop.

---

## 10. Error in image_load_halfscale

As of August 2023: the function "image_load_halfscale" has thrown an error in both digital and micrort mode for all tasks, both in eeDAP-Develop and the 2019 eeDAP (thus error with matlab and not with new programming).

__Knowns:__ taskimage_load.m is a function file that Qi grabbed from the "Imageviewer" app of the Image Processing Toolbox. the '_halfscale' addition seems to be the primary issue.

Try 1: Activate Imageviewer by typing "**Use the imageViewer function**" in the command prompt then running the task. Result: Same error.

Solution 1: In the code for the eeDAP Task, activate image viewer by calling the app with the function:
"Imageviewer(image_load_halfscale(hjob))" - this appears to work but may not be giving the intended result (the image looks off but unsure if function issue or operator issue).

Solution 2: 
---

### Common Errors:

1. "Not in Working Path"/Active folders: Kate's folders are eeDAP-Develop; Qi's - which haven't been modified since 2019 is eeDAP.
     * If launching pivotal study, registration study, etc. make sure Kate's folers (eeDAP-Develop) are in the working path of matlab. Also make sure that all WSI's are in the working path.

2. Com-port connections. Double check that all devices are connected to the computer (camera, stage controller) via the computer's "Device Manager". Use the device manager to verify the com port connections in the Admin Input Screen.

3. Global Registration Screen - Camera Failure. You will get an error "Camera not connected" on the first part of the Global Registration Screen if the camera is not receiving enough light. Make sure that there is no obstruction of the camera's light path by the stage or opaque parts of the slide at the start of registration. You will need to terminate and re-start the program if you receive this error.

4. 

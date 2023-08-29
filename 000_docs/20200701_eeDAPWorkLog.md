## eeDAP Work Log

### Work List
REMINDER: PUSH COMMITS
   * Technial: Coding Updates 
     * Task: Update Tasks for the HTT TILs Study: add Stroma Density Estimate; Remove ROI type, keep evaluable and non-evaluable
        * To-Do: Send updated tasks to Kim, walk through to ensure working 
     * Set-up: Update eeDAP Input File to allow skipping high magnification registration
       * To-Do: Should be incorporated already, need to verify.  
     * Study:  Button to re-do offset at any point in the study 
     * Study: Automatic Focus "best register" for HTT study
     * Operational: Automatic Registration "load slides and walk away at start of global registration"
     * Study: Button to re-do global registration within study (student task)
     * Operational: Save registration images to output fodler as well as temporary registration
     * Operational: Disable white-balance button -> disable the feature that prevents auto-w/b correction by camera
     * Task: Stage integration, debugging, --> pull to main
   
   * Documentation
     * Need: Improve error documentation

Registration Accuracy Study: Need to complete documentation on sarahndudgeon/eeDAP

### Current Activities
  * 9/15-ongoing: taking screenshots of each stage of multiple task types for documentation
  * 9/22: Identifying location of specific technical needs within the code (button creation for study changes)
  * 9/22-9/27: Map out code, priortize to-do list, test changes to tasks & button creation for skipping registration


### Complete List

1. Complete: Run eeDAP in Digital Mode - Works as expected
2. Complete: Install all software into new eeDAP computer
3. Complete: Run Prior Stage in MicroRT
4. In-Progress: Documentation of eeDAP operation from technician viewpoint + minor troubleshooting
5. Complete: Documentation of Java-Bioformats Version Matching
6. Complete: Test eeDAP with Sarah
7. Complete: Obtain Shipping Label, Prepare all Components for 1st Shipment: Packing List https://github.com/kate-elfer/Notebook/blob/main/K-B%20Meetings/eeDAP_Logs/PackingLIst.md#packing-list 
8. Complete: Ship to Yale

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

Editing and Adding to Word Document brought to Feb 2020 Conference 

---

 ## 5.Complete: Documentation of Bioformats Issue Resolution
 
 https://github.com/kate-elfer/Notebook/blob/main/K-B%20Meetings/eeDAP_MATLAB-Bioformats.md
 ---


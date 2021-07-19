## Required Hardware & Software - 2021-07-15

### eeDAP Development Computer

* Matlab 2021a - version 9.10.01649659
   * License: 659504
   * OS Windows 10 Pro Version 10.0
   * Java Version: Java 1.8.0-202-b08 (SDK)
   * **Image Acquisition Toolbox**
      * Point Grey Camera Support from Image Acquisition Toolbox
   * Image Processing Toolbox: 11.3
   * Matlab Compiler: 11.3
   * Matlab Compiler SDK: 8.2
   * Signal Processing Toolbox: 8.6
   * Statistics and Machine Learning Toolbox 12.1
 * Matlab Bioformats 6.3.1 - Requires Java 8 (or higher) SDK from Open Microscopy Environment (OME)
 * Camera Drivers (DCAM Driver & Fly Capture 2.11 for USB for Camera: PointGrey Color USB3)
 * Microsoft Office
 * Smartgit
 * Leica Aperio Imagescope
 * Team Viewer
 * Process Explorer
 * Zoom 
 * Fiji (FIJI is just ImageJ)
 * Prior Scientific (Pior III USB Driver for Prior Stage)

## Research Laptop Contents - 2021-07-15

 * Compiled eeDAP Software: HTTStudy
 * Matlab Runtime (compatible with Matlab Compiler of eeDAP)
 * Camera Drivers (DCAM Driver & Fly Capture 2.11 for USB for Camera: PointGrey Color USB3)
 * Stage Driver for motorized XYZ stage
 * Leica Aperio Image Scope
 * R & RStudio
 * Zoom

## Quick Start Guide - 2021-07-15

 * Assemble Microscope Hardware
   * Packing/Unpacking List for 2021 Shipment: https://github.com/kate-elfer/eeDAP/blob/master/000_docs/eeDAPContents_20210715.pdf
   * eeDAP Manual Unpacking Guide: http://didsr.github.io/eeDAP/000_EEDAP/manualHTML/package_and_unpackage.htm?ms=AAA%3D&st=MA%3D%3D&sct=ODM3&mw=MjQw 
 * Connect Stage and Camera to laptop via docking station
 * Connect Laptop, Microscope, and Stage Controller to power source.
 * Start eeDAP Software - Located in C-Drive ( C:\ )
    * Test Run Software through Digital Mode
    * Test Run Software through MicroRT Mode

## Troubleshooting Guide - 2021-07-15

 * Error at "Select RT Mode" - "Start Test" will not click
    * Make sure stage is connected and powered on (stage + controller)
    * Verify the correct COM port is selected (COM# is listed under Device Manager -> Ports) *    
 * Error immediately after "Start Test" during Camera Preview and Adjusting Color (after stage moves)
    * Make sure the illumination path to the camera is not blocked by stage or slide
    * Confirm Camera is connected and receiving input, restart the program
 

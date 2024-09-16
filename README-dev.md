# Cleanup Notes

## thorlabs stage doesn't work

Download and install Kinesis software

* Kinesis 64-Bit Software for 64-Bit Windows
* <https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0>



After installing Kinesis software, you can find documentation for .Net programming the stage here:

* C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DotNet_API.chm
* Chapter, "Benchtop Brushless Motor (BBD1xx BBD2xx BBD3xx)"
  * Example shows how to create and setup an instance of a BenchtopBrushlessMotor class, and perform 'homing' and 'move' operations on one channel. Homing moves a device to its datum position.

* Examples link to corresponding "Namespaces"
* "Namespaces" provide the methods to interact with the stage
* BenchtopBrushlessMotor is the primary device class with key methods:
  * .Connect and .Disconnect
  * .GetChannel
* 


Also useful but limited is the example for the BBD303 using the DDR100 stage

* <https://github.com/Thorlabs/Motion_Control_Examples>
* License is MIT



I tried and failed to program the stage using the legacy Matlab serial port connection. The corresponding user manual can be downloaded from the same page as the Kinesis software.

* Original: APT_Communications_Protocol_v38.pdf



Update hardware firmware:

* "C:\Program Files\Thorlabs\Kinesis\Firmware Update Utility\FirmwareUpdateUtility.exe"



Run thorlabs SDK and determine serial number:

* "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Kinesis.TestClient.exe"
* The SDK starts up and the command log shows the following actions:
  * Settings searched, not found, general settings used
  * Loading / storing device settings for these serial numbers (not in order)
  * 103205074
  * 103205074-0
  * 103205074-1 (appears to be x-channel)
  * 103205074-2 (appears to be y-channel)
  * 103205074-3
  * Reading Settings (Device - BBD30XMotherboard)



Code development is facilitated with the thorlabs simulator:

* "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KinesisSimulator.exe"



## Early Notes

Had to change the serialNumber to 103205075 in stage_open_thorlabs

<https://www.mathworks.com/matlabcentral/fileexchange/102234-driver-for-thorlabs-bbd302-prm1z8-k10cr1-motorized-stages>

When developing a custom application using the Kinesis API, there are help files and example applications that can be
referenced. Some stand-alone help files
C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.C_API.chm
C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DotNet_API.chm

This document <https://www.thorlabs.com/Software/Motion%20Control/APT_Communications_Protocol_v38.pdf>
says this on page 31
The electrical interface within the Thorlabs controllers uses a Future Technology Devices
International (FTDI), type FT232BM USB peripheral chip to communicate with the host PC.
This is a USB2.0 compliant USB1.1 device. This USB interfacing chip provides a serial port
interface to the embedded system (i.e., Thorlabs controller) and USB interface to the host
control PC. While the overall communications protocol is independent of the transport layer
(for example, Ethernet or serial communications could also be used to carry commands from
the host to the controller), the initial enumeration scheme described below is specific to the
USB environment.
FTDI supply device drivers and interfacing libraries (for Windows, Linux, and other platforms)
used to access the USB chip. Before any PC USB communication can be established with an
Thorlabs controller, the client program is required to set up the necessary FTDI chip serial
port settings used to communicate to the Thorlabs controller embedded system. Within the
Thorlabs software itself the following FTDI library calls are made to set up the USB chip serial
port for each Thorlabs USB device enumerated on the bus.

<https://ftdichip.com/drivers/vcp-drivers/>

I don't know if I needed the vcp-drivers from ftdi, but I was reading the related installation guide. It told me to look in the "Universal Serial Bus controllers" for a "USB Serial Converter". I didn't find that, but I did find "APT USB Device"! I right-clicked the entry to look at the properties. Under Advanced, there was a check box to "Load VCP"! When I did that, the device showed up in the Device Manager under "Ports (COM & LPT)" with the "COM6" port.

* <https://ftdichip.com/wp-content/uploads/2023/11/AN_396_FTDI_Drivers_Installation_Guide_for_Windows_10_11.pdf>



## stage_open

Move stage speed and other parameters to stage-specific stage_open functions



## stage serial port settings

chatGPT recommended this code
% Create a serial port object
serialObj = serial('COMx'); % Replace 'COMx' with the actual COM port number

% Set the baud rate and other communication parameters
set(serialObj, 'BaudRate', 9600); % Set the baud rate to match the device's settings
set(serialObj, 'DataBits', 8); % Number of data bits
set(serialObj, 'Parity', 'none'); % Parity bit setting
set(serialObj, 'StopBits', 1); % Number of stop bits
set(serialObj, 'Terminator', 'LF'); % Terminator character (line feed)



## update stage labels

Rename stage labels to this format
MFR_stageMODEL_controllerMODEL

## thorlabs install/init

Possible notes for first time use or power up:

Enable each channel

* press channel button on controller to select channel
* press top-left button on controller to enable channel
* press second-to-top-left button on controller to home channel



## Quickly run the GUI GUI

load('GUI.mat');
GUI(handles);

## Quickly run the Stage_Allighment GUI

load('Stage_Allighment.mat');
Stage_Allighment(handles);



## handles

  struct with fields:

    Administrator_Input_Screen: [1×1 Figure]
                      uipanel1: [1×1 Panel]
                 configure_COM: [1×1 UIControl]
              configure_camera: [1×1 UIControl]
             ExtractROIsButton: [1×1 UIControl]
                         text5: [1×1 UIControl]
                FileHeaderInfo: [1×1 UIControl]
            StartTheTestButton: [1×1 UIControl]
                         text1: [1×1 UIControl]
        ModeSelectionPopUpMenu: [1×1 UIControl]
                  FullPathInfo: [1×1 UIControl]
                  BrowseButton: [1×1 UIControl]
                        output: [1×1 UIControl]
                        myData: [1×1 struct]



## handles.output

  UIControl (BrowseButton) with properties:

              Style: 'pushbutton'
             String: 'Click to browse for .dapsi input file.'
             ...



## handles.myData

  struct with fields:

                   settings: [1×1 struct]
                  stagedata: [1×1 struct]
                   tasks_in: {[1×1 struct]  [1×1 struct]  [1×1 struct]}
                  tasks_out: {[1×1 struct]  [1×1 struct]  [1×1 struct]  [1×1 struct]  [1×1 struct]}
                  wsi_files: {[1×1 struct]}
                   graphics: [1×1 struct]
                  sourcedir: 'C:\Users\eeDAP\Repositories\eeDAP\src\'
                yesno_micro: 1
                  inputfile: 'HTT_TILS_pivotal_20x-8B-ludl.dapsi'
                    workdir: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\'
          workdir_inputfile: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\HTT_TILS_pivotal_20x-8B-ludl.dapsi'
    registration_images_dir: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\Temporary_Registration_Images\'
            task_images_dir: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\Temporary_Task_Images\'
           output_files_dir: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\Output_Files\'
            InputFileHeader: {48×1 cell}
                      stage: [1×1 struct]
                finshedTask: 0
                ScreenWidth: 2560
               ScreenHeight: 1600
                     ntasks: 3
                 ntasks_out: 5
                       iter: 1
                 task_start: [1×1 struct]
                task_finish: [1×1 struct]
                  mode_desc: 'MicroRT'
         refineRegistration: 0


### handles.myData.tasks_in

  1×3 cell array

    {1×1 struct}    {1×1 struct}    {1×1 struct}

#### handles.myData.tasks_in{1}

  struct with fields:

                desc: {9×1 cell}
                task: 'HTT_TILS_pivotal_20x'
         task_handle: @task_HTT_TILS_pivotal_20x
    calling_function: 'Load_Input_File'
                  id: '1st0001'
               order: 1
                slot: 1
               roi_x: 38459
               roi_y: 16192
               roi_w: 1980
               roi_h: 1980
                text: 'HTT Pivotal Study'
               img_w: 990
               img_h: 990
          rotateback: 0
          showingROI: 1
            duration: 0



##### handles.myData.tasks_in{1}.desc

  9×1 cell array

    {'HTT_TILS_pivotal_20x'}
    {'1st0001'             }
    {'-1'                  }
    {'1'                   }
    {'038459'              }
    {'16192'               }
    {'1980'                }
    {'1980'                }
    {'HTT Pivotal Study'   }


### handles.myData.tasks_out

  1×5 cell array

    {1×1 struct}    {1×1 struct}    {1×1 struct}    {1×1 struct}    {1×1 struct}


### handles.myData.tasks_out{2}

                  id: '1st0001'
               order: 1
                slot: 1
               roi_x: 38459
               roi_y: 16192
               roi_w: 1980
               roi_h: 1980
                text: 'HTT Pivotal Study'
               img_w: 990
               img_h: 990
          rotateback: 0
          showingROI: 1
            duration: 0
             ROIname: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\Temporary_Task_Images\1st0001.tif'
        durationMove: 5.0620
     durationAutoReg: 0
             stage_x: 119693
             stage_y: 427784




### handles.myData.taskinfo


  struct with fields:

                desc: {9×1 cell}
                task: 'HTT_TILS_pivotal_20x'
         task_handle: @task_HTT_TILS_pivotal_20x
    calling_function: 'Update_GUI_Elements'
                  id: '1st0001'
               order: 1
                slot: 1
               roi_x: 38459
               roi_y: 16192
               roi_w: 1980
               roi_h: 1980
                text: 'HTT Pivotal Study'
               img_w: 990
               img_h: 990
          rotateback: 0
          showingROI: 1
          scan_scale: 0.2279
             roi2img: 0.5000
             img2roi: 2
            duration: 0
             ROIname: 'C:\Users\eeDAP\Repositories\eeDAP\src\inputfilesDevelopment\Temporary_Task_Images\1st0001.tif'
        durationMove: 4.9370
     durationAutoReg: 0
             stage_x: 119693
             stage_y: 427784



### handles.myData.stage

  struct with fields:

     label: 'BioPrecision2-LE2_Ludl6000'
      port: 'COM5'
    handle: [1×1 internal.Serialport]
     speed: 150000
     accel: 1
     scale: 0.0500
    status: 1
       Pos: [50000 50001]



### handles.myData.stagedata

  struct with fields:

    stage_positions: [3x2 double]
      wsi_positions: [3x2 double]
    thumb_positions: [3x2 double]
     stagedata_file: 'C:\000_whole_slides\tissue40x-8B.mat'



### handles.myData.settings

                n_wsi: 1
            label_pos: '12'
            RotateWSI: 90
            reticleID: 'KR-871'
             cam_kind: 'USB'
           cam_format: 'F7_RGB_1224x1024_Mode1'
       cam_pixel_size: 6.9000
              mag_cam: 0.5000
             mag_lres: 10
             mag_hres: 20
            scan_mask: {[3122×3122 uint8]}
             BG_color: [0.5500 0.5500 0.5500]
             FG_color: [0 0 0]
              Axes_BG: [0.1000 0.2000 0.1000]
             FontSize: 13
              autoreg: 0
           saveimages: 1
            taskorder: 1
             defaultR: 648
             defaultB: 911
            cam_roi_h: 300
            cam_roi_w: 300
         offset_stage: [743 -194]
           offset_cam: [54 -14]
                cam_w: 1224
                cam_h: 1024
       cam_scale_lres: 1.3800
       cam_scale_hres: 0.6900
       cam_lres2stage: 27.6000
       cam_hres2stage: 13.8000
       stage2cam_lres: 0.0362
       stage2cam_hres: 0.0725
        cam_lres2scan: 6.0553
        cam_hres2scan: 3.0276
        scan2cam_lres: 0.1651
        scan2cam_hres: 0.3303
           scan2stage: 4.5580
           stage2scan: 0.2194
             cam_mask: [1142×1142 uint8]
    offset_reg_refine: {[0 0]}



### handles.myData.wsi_files

  1×1 cell array

    {1×1 struct}



#### handles.myData.wsi_files{1}

  struct with fields:

           WSI_data: [1×1 loci.formats.ChannelSeparator]
           fullname: 'C:\000_whole_slides\tissue40x-8B.ndpi'
              wsi_w: [123008 30752 7688 1922 480]
              wsi_h: [93184 23296 5824 1456 364]
    rgb_lutfilename: 'icc_profiles\rgb_lut_gamma_inv1p8.txt'
            rgb_lut: [256×3 uint8]
         scan_scale: 0.2279



## handles.reticle

Very strange place for this variable



## Notes on error with stage_get_pos_Ludl

In stage_get_pos_Ludl (line 57)
In stage_get_pos (line 29)
In Administrator_Input_Screen>ModeSelectionPopUpMenu_Callback (line 602)
In gui_mainfcn (line 95)
In Administrator_Input_Screen (line 28)
In matlab.graphics.internal.figfile.FigFile/read>@(hObject,eventdata)Administrator_Input_Screen('ModeSelectionPopUpMenu_Callback',hObject,eventdata,guidata(hObject))



## Stages

* case 'H101-Prior'
* case 'SCAN8Praparate_Ludl5000'
* case 'SCAN8Praparate_Ludl6000'
* case 'BioPrecision2-LE2_Ludl5000'
* case 'BioPrecision2-LE2_Ludl6000'
* case 'MLS203-ThorLabs'

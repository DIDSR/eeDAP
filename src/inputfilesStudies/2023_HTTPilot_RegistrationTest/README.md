## Registration Test Documents for 2024 HTT Pilot Study 
**Objective:**  Our objectives were to measure and compare the registration accuracy of the eeDAP system with two stages (Prior H101 and Thorlabs MLS203). The reader uses a rotatable eyepiece reticle to measure the distance from target to center of the eyepiece field of view. Reticle ruler length is 10mm with 100 small ticks. Under 40X, the length of one small tick is 2.5um on the glass (5um at 20X).

-----

### Research Materials

**Input Files:** 
 * RegAcc_HTT-7a_Prior.dapsi
 * RegAcc_HTT-7b_Prior.dapsi
 * RegAcc_HTT-7a_Thorlabs.dapsi
 * RegAcc_HTT-7b_Thorlabs.dapsi
   
**Camera:** Point Grey Grashopper Color (GS3-U3-51S5C-C)
**Stage:** Prior H101 and Thorlabs MLS203

**Matlab Task:** [globalAndBestReg.m](https://github.com/kate-elfer/eeDAP/blob/master/src/tasks/task_globalAndBestReg.m)

**task input column:**
 * globalAndBestReg,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H

**task output column:** 
 * globalAndBestReg,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H
 * stage moving duration,auto registration duration, study duration,
 * global registration distance, global registration stage x position,global registration stage y
 * best registration distance, best registration stage x position,best registration stage y

**Readers:** Needed - Reader information for this study

**Slides:** HTT Pilot Study Batch 7a and 7b slides. 8 slides total with 10 ROIs per slide.

-----

### Terminology Notes

We are examining the registration accuracy of two different modes of registration, Global and Best. Global registration happens once, at the beginning of the experiment. Global may also be referred to as the “uncorrected” registration as it applies to all ROIs without any adjustments. Best registration is a local ROI-specific correction.

* FOV - field of view in the microscope is the area that can be seen through the microscope eyepiece.
* ROI - region of interest is a square outline that can be seen on the computer screen.
* Registration accuracy - the distance from target to the center of the field of view. The target for each field of view can be seen at the center of the digital image.
* Global Registration – the initial 3-point registration sequence. During the study, you measure registration accuracy after the stage navigates to the new location and you focus the microscope. Do not apply any local registration or correction.
* Best Registration – after measuring the global registration accuracy and the microscope is in focus, press the "Best Registration" button to performan a local registration, a fine-tune correction. Then measure the registration accuracy.

Global registration data is saved in a ".mat" file next to and with the same name as the corresponding whole slide image. The Global registration data are stage dependent. As such, some manual management of these files is expected and encouraged to save time with Global registration. Without existing Global registration data, Global registration takes significantly longer. With Global registration data, you can skip the low-magnification registration process (Step 1 of Global registration) and just do the high-magnificiation registration process (Step 2 of Global registration).

-----

### Protocol  

Please report any issues to Brandon.Gallas@fda.hhs.gov and kate.elfer@gmail.com

**Phase 1 - Prior Stage**

**Objective:** Test the globalAndBestReg.m task and the eedapreganalysisis.R file with known working components (Prior Stage, PointGrey Camera). This will be the first time using the Matlab Task with the HTT Pilot Study files.

1. Place HTT Pilot Study Slides 7a on stage. Four slides correspond to the 4 slots right to left; position 1 = slide 72b, position 2 = slide 73b, position 3 = 75b, and position 4 = 76b. Make sure the label is facing away from the reader towards the microscope and coverslip side is closest to objectives.

2. Launch eeDAP software. Select input file RegAcc_HTT-7a_Prior.dapsi and load ROIs. Select MicroRT mode.

3. The eeDAP program will load existing Global registration data if it exists and is next to the whole slide image. In this case, you can skip the low-magnification registration process (Step 1 of Global registration). Otherwise, the Reader will need to complete the low-magnification registration process before the high-magnification process (Step 2 of Global Registration).

4. The globalAndBestReg.m task will show the reader ROIs in random order of this 1/2 batch.
   
5. The first image and count box in the eeDAP GUI will corresond to global (uncorrected) registration.

6. Identify the target: The Reader will note a target at the exact center of the computer screen ROI.

7. Find the target: The Reader will then search for the target in the microscope FOV.

8. Measure: On the microscope, the Reader will measure the distance between the FOV center and the target (the number of ruler tick marks). Note that the ruler reticle can be rotated to facilitate the measurement. If the target is not in the microscope FOV, enter "-1" in the next step.

9. Record: Enter the number of ruler tick marks between the FOV center and the target into the eeDAP GUI. The expected range is 0 to over 40. Click the "Submit" button and proceed to Best registration.

10. Focus the microscope and click the "Best Registration" button. This will perform a local registration, correction.

12. Identify the target at the exact center of the computer screen ROI, find the target in the microscope FOV, measure the distance between the FOV center and the target, and record the measurement (steps 6-9 above).

13. Continue this process through all 40 ROIs of the half batch. Save and end the program.

Repeat the steps above for HTT Pilot Study Slides 7b: Slides 77B, 78B, 79B, and 80B and input file RegAcc_HTT-7b_Prior.dapsi 


**Phase 2 - Thorlabs Stage**

1. The HTT Pilot Study has NOT been registered with the Thorlabs MLS203 stage. Global registration data (results from low-magnification registration) can be created ahead of time. Remember Global registration data (.mat files) are stage dependent. As such, some manual management of these files is expected and encouraged to save time with Global registration.

2. There is the possiblity of an error with the Stage Com on the Administrator Input Screen - using device manager on your computer please verify that Thorlabs is connected to the expected Stage Com in the Admin Input Screen.

3. Repeat all steps of Phase 1 with the exception of selecting the Thorlabs' input files.


   

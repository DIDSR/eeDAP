## Registration Test Documents for 2023 HTT Pilot Study Registration Materials
**Objective:**  Our objectives were to measure and compare the registration accuracy of the eeDAP system with two stages (Prior H101 and Thorlabs MLS203). The reader uses rotatable eyepiece reticle to measure the distance from target to center of the eyepiece field of view. Reticle ruler length is 10mm with 100 small ticks. Under 40X, the length of one small tick is 2.5um (5um on the glass at 20X).

-----

### Research Materials

**Input Files:** 
 * RegAcc_HTT-7a_Prior.dapsi
 * RegAcc_HTT-7b_Prior.dapsi
 * RegAcc_HTT-7a_Thorlabs.dapsi
 * RegAcc_HTT-7b_Thorlabs.dapsi
   
**Camera:** Point Grey Grashopper Color (GS3-U3-51S5C-C)
**Stage:** Prior H101 and Thorlabs MLS203

**Matlab Task:** globalAndBestReg

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

### Protocol  

Please report any issues to Brandon.Gallas@fda.hhs.gov and kate.elfer@gmail.com

**Phase 1 - Prior Stage**

**Objective:** Test the globalAndBestReg.m task and the eedapreganalysisis.R file with known working components (Prior Stage, PointGrey Camera). This will be the first time using the Matlab Task with the HTT Pilot Study files.

1. Place HTT Pilot Study Slides 7a on stage. Four slides correspond to the 4 slots right to left; position 1 = slide 72b, position 2 = slide 73b, position 3 = 75b, and position 4 = 76b. Make sure the label is facing away from the reader towards the microscope and coverslip side is closest to objectives.

2. Launch eeDAP software. Select input file RegAcc_HTT-7a_Prior.dapsi and load ROIs. Select MicroRT mode.

3. The eeDAP program *should* take in the pre-registered Global registration files from other studies. If not, then make sure the input files were saved to the same folder as previous registraiton studies. If Global Registration is still not loading, the Reader will need to complete a Global Registration run on these slides.

4. The globalAndBestReg.m task will show the reader ROIs in random order of this 1/2 batch.
   
5. The first image and count box will be with global (uncorrected) registration. The Reader will note the center of the ROI on the computer screen and then examine the center feature in the microscope's FOV. Using the ruler-reticle, the Reader will count the number of notches from center that the center feature of the ROI differs from the center of the FOV.

6. Input the number of counts/notches between the center feature of the ROI and the center of the FOV. These may range from 0 to over 40.

7. Submit the count number and proceed to "Best Registration".

8. Complete Best Registration by manually correcting where the center of the FOV is on the ROI by clicking the FOV center on the eeDAP program. Save Best Registration.

9. Repeat step 6 by inputting the reticle notch count difference between the *corrected* center of the ROI and the center of the FOV.

10. Continue this process through all 40 ROIs of the half batch. Save and end the program.

11. Repeat steps 1-11 with modifications for the second half of Batch 7: Slides 77B, 78B, 79B, and 80B and input file RegAcc_HTT-7b_Prior.dapsi 


**Phase 2 - Thorlabs Stage**

1. The HTT Pilot Study has NOT been registered with the Thorlabs MLS203 stage and you will need to complete full registration of all study slides prior to starting Phase 2. There is the possiblity of an error with the Stage Com on the Administrator Input Screen - using device manager on your computer please verify that Thorlabs is connected to the expected Stage Com in the Admin Input Screen.

2. Repeat all steps of Phase 1 with the exception of selecting the Thorlabs' input files.


   

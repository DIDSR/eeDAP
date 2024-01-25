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

**Phase 1 - Prior Stage**

**Objective:** Test the globalAndBestReg.m task and the eedapreganalysisis.R file with known working components (Prior Stage, PointGrey Camera). This will be the first time using the Matlab Task with the HTT Pilot Study files.

1. Place



clc
clear all
close all
load('C:\000_GITHUB\eeDAP\master\src\inputfilesStudies\CSHLstudy\newStudyTest\trackView.QiTest.20180615T171120.Breast_ADH_DCIS_ICAtestInput\ID-2nd0001_iter-2.mat');
[stagePosition,txt,raw] = xlsread('C:\000_GITHUB\eeDAP\master\src\inputfilesStudies\CSHLstudy\newStudyTest\trackView.QiTest.20180615T171120.Breast_ADH_DCIS_ICAtestInput\ID-2nd0001_iter-2_recordStage.csv');

% process transformation format     
Calib_Point_WSI_A=transpose(stagedata.wsi_positions(1,:));
Calib_Point_WSI_B=transpose(stagedata.wsi_positions(2,:));
Calib_Point_WSI_C=transpose(stagedata.wsi_positions(3,:));
Calib_Point_stage_A=transpose(stagedata.stage_positions(1,:));
Calib_Point_stage_B=transpose(stagedata.stage_positions(2,:));
Calib_Point_stage_C=transpose(stagedata.stage_positions(3,:));
        
wsi_v1=Calib_Point_WSI_B-Calib_Point_WSI_A;
wsi_v2=Calib_Point_WSI_C-Calib_Point_WSI_A;
stage_v1=Calib_Point_stage_B-Calib_Point_stage_A;
stage_v2=Calib_Point_stage_C-Calib_Point_stage_A;

wsi_M = [wsi_v1, wsi_v2];
temp = [wsi_M, transpose([1,0]), transpose([0,1])];
temp=rref(temp);
wsi_Minv = temp(:,3:4);
stage_M = [stage_v1,stage_v2];
temp = [stage_M, transpose([1,0]), transpose([0,1])];
temp=rref(temp);
stage_Minv = temp(:,3:4);

transformedPosition = [];
for i = 1:size(stagePosition,1)
    stage_new = double(transpose([stagePosition(i,1),stagePosition(i,2)]));
    wsi_0 = transpose(stagedata.wsi_positions(1,:));                
    stage_0 = transpose(stagedata.stage_positions(1,:));
    temp = stage_new - stage_0;
    temp = inv(stage_M) * temp;
    temp = wsi_M * temp;
    wsi_new = int64(temp + wsi_0);
    stagePositionX(i) = stagePosition(i,1);
    stagePositionY(i) = stagePosition(i,2);
    wsiPositionX(i) = wsi_new(1);
    wsiPositionY(i) = wsi_new(2);   
end

SystemTime = txt(2:end,1);

positionFileName ='C:\000_GITHUB\eeDAP\master\src\inputfilesStudies\CSHLstudy\newStudyTest\trackView.QiTest.20180615T171120.Breast_ADH_DCIS_ICAtestInput\ID-2nd0001_iter-2_positions.csv';   
positionTable = table(SystemTime,stagePositionX',stagePositionY',wsiPositionX',wsiPositionY');
writetable(positionTable,positionFileName);
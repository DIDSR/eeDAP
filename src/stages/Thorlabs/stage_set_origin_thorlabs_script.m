
% stage_set_origin_thorlabs_script opens a connection to a thorlabs stage.
%   This script is meant to be run in the base environment.
disp("Is savedStage busy?")
disp(savedStage.device.IsDeviceBusy)

fprintf("Homing x channel ...\n")
savedStage.xChannel.Home(savedStage.timeout);
fprintf("Homed\n")

fprintf("Homing y channel ...\n")
savedStage.yChannel.Home(savedStage.timeout);
fprintf("Homed\n")

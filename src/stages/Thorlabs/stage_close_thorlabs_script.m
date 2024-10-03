
% stage_close_thorlabs_script opens a connection to a thorlabs stage.
%   This script is meant to be run in the base environment.

% If stage.device exists, check if it is connected.
disp("Check if stage object is saved in the base environment.")
if(exist("savedStage", "var"))

    disp("Stage object exists in the base environment. Disconnect.")

    % Disconnect device
    savedStage.xChannel.StopPolling();
    savedStage.yChannel.StopPolling();
    savedStage.xChannel.DisableDevice();
    savedStage.yChannel.DisableDevice();
    savedStage.xChannel.Disconnect();
    savedStage.yChannel.Disconnect();

    savedStage.device.Disconnect();

    clear savedStage

end

disp("Stage object is disconnected and removed from the base environment.")
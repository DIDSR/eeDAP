
% stage_move_thorlabs_script opens a connection to a thorlabs stage.
%   This script is meant to be run in the base environment.

disp(["Moving to" + ...
    " x=" + ...
    num2str(targetPosition(1)) + ...
    " y=" + ...
    num2str(targetPosition(2))])

% Working settings for development
% targetPosition = [750000, 750000]

% The input to the functions below is expected to be double
targetPosition = double(targetPosition);

% Move to target position.
% Functions will wait until the move completes or the timeout elapses,
% whichever comes first.
savedStage.xChannel.MoveTo_DeviceUnit(targetPosition(1), savedStage.timeout)
savedStage.yChannel.MoveTo_DeviceUnit(targetPosition(2), savedStage.timeout)

disp("Done moving.")

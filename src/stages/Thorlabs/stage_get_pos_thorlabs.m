
% stage_get_pos_thorlabs_script opens a connection to a thorlabs stage.
%   This script is meant to be run in the base environment.
savedStage.Pos = int64([
    savedStage.xChannel.GetPositionCounter
    savedStage.yChannel.GetPositionCounter ...
    ]);

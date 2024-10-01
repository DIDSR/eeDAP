
function stage=stage_get_pos_thorlabs(stage)
    try

        stage.Pos = int64([
            stage.xChannel.GetPositionCounter
            stage.yChannel.GetPositionCounter ...
            ]);


    catch ME
        error_show(ME)
    end
end
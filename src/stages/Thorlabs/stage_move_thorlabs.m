
function stage=stage_move_thorlabs(stage, target_pos)
    try

        % Move to target position
        disp(['Moving to x=', ...
            num2str(target_pos(1)), ...
            ' y=', num2str(target_pos(2))])

        stage.xChannel.MoveTo_DeviceUnit(target_pos(1), stage.timeout)
        stage.yChannel.MoveTo_DeviceUnit(target_pos(2), stage.timeout)

        disp('Done moving.')

        % Record current position
        stage.Pos = int64([
            stage.xChannel.GetPositionCounter
            stage.yChannel.GetPositionCounter ...
            ]);

        % Get current position
        stage.xChannel.MoveTo_DeviceUnit(target_pos(1), stage.timeout)
        stage.yChannel.MoveTo_DeviceUnit(target_pos(2), stage.timeout)

        disp(['Current position is x=', ...
            num2str(target_pos(1)), ...
            ' y=', num2str(target_pos(2))])

    catch ME
        error_show(ME)
    end
end
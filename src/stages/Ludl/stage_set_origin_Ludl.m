%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
% Refer to the manual ludl_mac5000_stage_commands.pdf
% "where" command - page 41
% "accel" command - page 40
% error codes - page 9
function stage = stage_set_origin_Ludl(stage)
try
    
    % Speed to stage limits
    success = stage_send_com_Ludl (stage.handle, 'SPEED X=2000000 Y=2000000'); %#ok<*NASGU>
    success = stage_send_com_Ludl (stage.handle, 'ACCEL X=1 Y=1');
    success = stage_send_com_Ludl(stage.handle, 'HOME X Y');

    % Wait til the stage gets to the top-left corner
    while stage_check_busy_Ludl(stage.handle)
        pause(.1)
    end    

    % Set the the origin
    success = stage_send_com_Ludl(stage.handle, 'HERE X=0 Y=0');

    % For better precision, 
    % slow it down, move it away, and go to stage limits
    success = stage_send_com_Ludl(stage.handle, 'SPEED X=100 Y=100');
    success = stage_send_com_Ludl(stage.handle, 'ACCEL X=255 Y=255');
    success = stage_send_com_Ludl(stage.handle, 'MOVE X=100 Y=100');
    success = stage_send_com_Ludl(stage.handle, 'HOME X Y');
    while stage_check_busy_Ludl(stage.handle)
        pause(.5)
    end

    % Reset the origin
    success = stage_send_com_Ludl (stage.handle, 'HERE X=0 Y=0');

    % Back off the origin a little bit
    stage=stage_move_Ludl(stage, [50000,50000]);

catch ME
    error_show(ME);
end

end


%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage=stage_move_Ludl(stage, target_pos)
%--------------------------------------------------------------------------
% Move_Stage_Seq starts a []sequence that moves the stage from position A
% to position B. THe function displays a waitbar and also adjusts
% the acceleration and the speed of the stage. Target position is
% specified as a horizontal vector of size 2.
%--------------------------------------------------------------------------

try
    
    % Target position needs to be a 64 bit integer
    target_pos = int64(target_pos);
    
    % Get current poistion
    stage=stage_get_pos_Ludl(stage);
    Initial_Pos = stage.Pos;

    % Set the speed and acceleration
    command_str_speed = ['SPEED',...
        ' x=', num2str(stage.speed),...
        ' y=',num2str(stage.speed)];
    stage_send_com_Ludl (stage.handle, command_str_speed);
    command_str_accel = ['ACCEL',...
        ' x=', num2str(stage.accel),...
        ' y=',num2str(stage.accel)];
    stage_send_com_Ludl (stage.handle, command_str_accel);           
    
    % Read the speed and acceleration
    speed = stage_send_com_Ludl (stage.handle, 'SPEED X Y'); %#ok<NASGU>
    accel = stage_send_com_Ludl (stage.handle, 'ACCEL X Y'); %#ok<NASGU>

        % Start moving to the desired position  
    command_str = ['move',...
        ' x=', num2str(target_pos(1)),...
        ' y=',num2str(target_pos(2))];
    stage_send_com_Ludl (stage.handle, command_str);
    
    % Display the waitbar
    wtb=waitbar(0,'Moving the stage...', 'WindowStyle', 'modal');
    % Keep updating the waitbar
    while stage_check_busy_Ludl(stage.handle)
        stage=stage_get_pos_Ludl(stage) ;
        current_pos=stage.Pos;
        pause(.5)
        distance_traveled = sqrt( ...
            (double(Initial_Pos(1))-double(current_pos(1)))^2 + ...
            (double(Initial_Pos(2))-double(current_pos(2)))^2);
        distance_total = sqrt( ...
            (double(Initial_Pos(1))-double(target_pos(1)))^2 + ...
            (double(Initial_Pos(2))-double(target_pos(2)))^2);
        waitbar(distance_traveled / distance_total);
        drawnow;
    end    
    % Close the waitbar
    close(wtb);
    
catch ME
    error_show(ME)
end

end
%  ##########################################################################
%% ################# MOVE STAGE SEQUENCE FOR PRIOR ##########################
%  ##########################################################################
function stage=stage_move_prior(stage, target_pos)
%--------------------------------------------------------------------------
% Move_Stage_Seq starts a sequence that moves the stage from position A
% to position B. THe function displays a waitbar and also adjusts
% the acceleration and the speed of the stage. Target position is
% specified as a horizontal vector of size 2.
%--------------------------------------------------------------------------
    try
        
        % Target position needs to be a 64 bit integer
        target_pos = int64(target_pos);
        
        % Get current position
        stage=stage_get_pos_prior(stage);
        Initial_Pos = stage.Pos;

        % Set the speed and acceleration (?)
        stage_send_com_prior (stage.handle, 'SMS 50');
        stage_send_com_prior (stage.handle, 'SAS 50');

        % Start moving to the desired position
        command_str = ['G ',...
            num2str(target_pos(1)),...
            ',',num2str(target_pos(2))];
        stage_send_com_prior (stage.handle, command_str);
        
        % Display the waitbar
        wtb=waitbar(0,'Moving the stage...', 'WindowStyle', 'modal');
        % Keep updating the waitbar
        while stage_check_busy_prior(stage.handle)
            stage=stage_get_pos_prior(stage) ;
            current_pos=stage.Pos;
            pause(.5)

            distance_traveled = sqrt((double(Initial_Pos(1))-double(current_pos(1)))^2 + (double(Initial_Pos(2))-double(current_pos(2)))^2);
            distance_total = sqrt((double(Initial_Pos(1))-double(target_pos(1)))^2 + (double(Initial_Pos(2))-double(target_pos(2)))^2);
            
            waitbar(distance_traveled / distance_total);
            drawnow;
        end    
        % Close the waitbar
        close(wtb);
        
    catch ME
        error_show(ME)
    end

end
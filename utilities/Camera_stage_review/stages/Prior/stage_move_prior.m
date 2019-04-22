%  ##########################################################################
%% ################# MOVE STAGE SEQUENCE FOR PRIOR ##########################
%  ##########################################################################
function stage=stage_move_prior(stage, target_pos, h_stage)
%--------------------------------------------------------------------------
% Move_Stage_Seq starts a []sequence that moves the stage from position A
% to position B. THe function displays a waitbar and also adjusts
% the acceleration and the speed of the stage. Target position is
% specified as a horizontal vector of size 2.
%--------------------------------------------------------------------------
% instrfind returns the instrument object array
% objects = instrfind
% each entry includes the type, status, and name as follows
% Index:    Type:     Status:   Name:
% 1         serial    closed    Serial-COM4
%
% objects can be cleared from memory with
% delete(objects)
try
    
    % If communications to stage is not open to start, then open.
    % Also prepare to close
    h_stage_close = 0;
    if exist('h_stage', 'var') == 0
        h_stage_close = 1;
        [stage] = stage_open_prior(stage.label);
        % If communications with the stage cannot be established,
        % eeDAP is closing.
        if stage.status == 0
            desc = ['Communications with the stage is not established.',...
                'eeDAP is closing.'] %#ok<NOPRT>
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            close all force;
            return
        end
    end

    % Target position needs to be a 64 bit integer
    target_pos = int64(target_pos);
    
    % Get current poistion
    stage=stage_get_pos_prior(stage,stage.handle);
    Initial_Pos = stage.Pos;
    % Start moving to the desired position  
%     command_str_speed = ['SPEED',...
%         ' x=', num2str(stage.speed),...
%         ' y=',num2str(stage.speed)];
%     send_com (stage.handle, command_str_speed);
%     command_str_accel = ['ACCEL',...
%         ' x=', num2str(stage.accel),...
%         ' y=',num2str(stage.accel)];
%     send_com (stage.handle, command_str_accel);           
%     send_com (stage.handle, 'SPEED X Y');   
%     send_com (stage.handle, 'ACCEL X Y');
    stage_send_com_prior (stage.handle, 'SMS 50');
    stage_send_com_prior (stage.handle, 'SAS 50');
    command_str = ['G ',...
        num2str(target_pos(1)),...
        ',',num2str(target_pos(2))];
    stage_send_com_prior (stage.handle, command_str);
    
    % Display the waitbar
    wtb=waitbar(0,'Moving the stage...', 'WindowStyle', 'modal');
    % Keep updating the waitbar
    while stage_check_busy_prior(stage.handle)
        stage=stage_get_pos_prior(stage,stage.handle) ;
        current_pos=stage.Pos;
        pause(.5)
%        test for delete stat toolbox
%         distance_traveled = pdist2(...
%              double(Initial_Pos),...
%              double(current_pos),'euclidean');
%          distance_total = pdist2(...
%              double(Initial_Pos),...
%              double(target_pos),'euclidean');
        distance_traveled = sqrt((double(Initial_Pos(1))-double(current_pos(1)))^2 + (double(Initial_Pos(2))-double(current_pos(2)))^2);
        distance_total = sqrt((double(Initial_Pos(1))-double(target_pos(1)))^2 + (double(Initial_Pos(2))-double(target_pos(2)))^2);
%         distance_traveled2 = pdist2new(...
%              double(Initial_Pos),...
%              double(current_pos));
%          distance_total2 = pdist2new(...
%             double(Initial_Pos),...
%              double(target_pos));
        
        waitbar(distance_traveled / distance_total);
        drawnow;
    end    
    % Close the waitbar
    close(wtb);
    
    % If communications to stage was not open to start, then close.
    if h_stage_close == 1
        stage.status = stage_close(stage.handle);
    end
    
catch ME
    error_show(ME)
end

end
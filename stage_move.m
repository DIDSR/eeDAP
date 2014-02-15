%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage_move(target_pos, h_stage)
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
        [h_stage, success] = stage_open();
        % If communications with the stage cannot be established,
        % eeDAP is closing.
        if success == 0
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
    Initial_Pos=stage_get_pos(h_stage);
    
    % Start moving to the desired position
    send_com (h_stage, 'SPEED X=50000 Y=50000');
    send_com (h_stage, 'SPEED X Y');
    send_com (h_stage, 'ACCEL X=100 Y=100');
    send_com (h_stage, 'ACCEL X Y');
    command_str = ['move',...
        ' x=', num2str(target_pos(1)),...
        ' y=',num2str(target_pos(2))];
    send_com (h_stage, command_str);
    
    % Display the waitbar
    wtb=waitbar(0,'Moving the stage...', 'WindowStyle', 'modal');
    % Keep updating the waitbar
    while stage_check_busy(h_stage)
        current_pos=stage_get_pos(h_stage) ;
        pause(.5)
        distance_traveled = pdist2(...
            double(Initial_Pos),...
            double(current_pos),'euclidean');
        distance_total = pdist2(...
            double(Initial_Pos),...
            double(target_pos),'euclidean');
        
        waitbar(distance_traveled / distance_total);
        drawnow;
    end    
    % Close the waitbar
    close(wtb);
    
    % If communications to stage was not open to start, then close.
    if h_stage_close == 1
        stage_close(h_stage);
    end
    
catch ME
    error_show(ME)
end

end
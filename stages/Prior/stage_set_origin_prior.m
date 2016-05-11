%  ##########################################################################
%% ################# MOVE STAGE SEQUENCE FOR PORIOR##########################
%  ##########################################################################
function stage = stage_set_origin_prior(stage,h_stage)
try
    
    % If communications to stage is not open to start, then open.
    % Also prepare to close
    h_stage_close = 0;
    if exist('h_stage', 'var') == 0
        h_stage_close = 1;
        [stage] =  stage_open_prior(stage.label);
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
    
    % Speed to the top-left corner
    success = stage_send_com_prior(stage.handle, 'G -100000,-100000');
    % Wait til the stage gets to the top-left corner
    while stage_check_busy_prior(stage.handle)
        pause(.5)
    end
    % Set the top-left corner to be the origin
    success = stage_send_com_prior(stage.handle, 'Z');
    success = stage_send_com_prior(stage.handle, 'G 50,50');
    success = stage_send_com_prior(stage.handle, 'G -50,-50');
    % For better precision, slow it down, move it away, and go back home
  %  success = stage_send_com_prior(stage.handle, 'G 25,25');
    while stage_check_busy_prior(stage.handle)
        pause(.5)
    end

    % Reset the top-left corner to be the origin
    success = stage_send_com_prior (stage.handle, 'Z');

    % If communications to stage was not open to start, then close.
    if h_stage_close == 1
        stage.status=stage_close(stage.handle);
    end
    stage=stage_move_prior(stage,[5000,5000]);  
        
%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
%     success=send_com (S, 'SPEED X=50000 Y=50000');
%     success=send_com (S, 'SPEED X Y');
%     success=send_com (S, 'ACCEL X=100 Y=100');
%     success=send_com (S, 'ACCEL X Y');
%     command_str=char(strcat('move',' x=',num2str(Pos(1)),...
%         ' y=',num2str(Pos(2))));
%     success=send_com (S, command_str);

catch ME
    error_show(ME);
end

end


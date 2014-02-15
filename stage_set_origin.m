%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage_set_origin(h_stage)
try
    
    % If communications to stage is not open to start, then open.
    % Also prepare to close
    h_stage_close = 0;
    if exist('h_stage', 'var') == 0
        h_stage_close = 1;
        [h_stage, success] =  stage_open();
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
    
    % Speed to the top-left corner
    success = send_com (h_stage, 'SPEED X=200000 Y=200000'); %#ok<*NASGU>
    success = send_com (h_stage, 'ACCEL X=1 Y=1');
    success = send_com(h_stage, 'HOME X Y');
    % Wait til the stage gets to the top-left corner
    while stage_check_busy(h_stage)
        pause(.5)
    end
    % Set the top-left corner to be the origin
    success = send_com(h_stage, 'HERE X=0 Y=0');

    % For better precision, slow it down, move it away, and go back home
    success = send_com (h_stage, 'SPEED X=100 Y=100');
    success = send_com (h_stage, 'ACCEL X=255 Y=255');
    success = send_com (h_stage, 'MOVE X=100 Y=100');
    success = send_com(h_stage, 'MOVE X=-25 Y=-25');
    while stage_check_busy(h_stage)
        pause(.5)
    end

    % Reset the top-left corner to be the origin
    success = send_com (h_stage, 'HERE X=0 Y=0');

    % If communications to stage was not open to start, then close.
    if h_stage_close == 1
        stage_close(h_stage);
    end
        
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


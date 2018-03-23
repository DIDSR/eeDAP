function stage=stage_get_pos_Ludl(stage,target_speed,h_stage)
% instrfind returns the instrument object array
% objects = instrfind
% each entry includes the type, status, and name as follows
% Index:    Type:     Status:   Name:
% 1         serial    closed    Serial-COM4
%
% objects can be cleared from memory with
% delete(objects)
try
    
    stage.Pos = 0;
    % If communications to stage is not open to start, then open.
    % Also prepare to close
    h_stage_close = 0;
    if exist('h_stage', 'var') == 0
        h_stage_close = 1;
        [stage] =  stage_open_Ludl(stage.label);
        % If communications with the stage cannot be established,
        % eeDAP is closing.
        if stage.status == 0
            desc = ['Communications with the stage is not established.',...
                ' eeDAP is closing.'] %#ok<NOPRT>
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            close all force;
            return
        end
    end
    
    command_str = ['CAN 1 83 18 ',num2str(target_speed),' CR'];
    stage_send_com_Ludl (stage.handle, command_str);
    
    command_str = ['CAN 2 83 18 ',num2str(target_speed),' CR'];
    stage_send_com_Ludl (stage.handle, command_str);

    
    % If communications to stage was not open to start, then close.
    if h_stage_close == 1
        stage.status = stage_close(stage.handle);
    end
    
catch ME
    error_show(ME)
end
end
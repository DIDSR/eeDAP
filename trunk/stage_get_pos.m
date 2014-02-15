function Pos=stage_get_pos(h_stage)
% instrfind returns the instrument object array
% objects = instrfind
% each entry includes the type, status, and name as follows
% Index:    Type:     Status:   Name:
% 1         serial    closed    Serial-COM4
%
% objects can be cleared from memory with
% delete(objects)
try
    
    Pos = 0;
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
                ' eeDAP is closing.'] %#ok<NOPRT>
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            close all force;
            return
        end
    end
    
    % Get the x,y position
    % command_str = 'where x y';
    command_str = sprintf('where x y \n');
    str_current = send_com (h_stage, command_str);
    i=1;
    while numel(str_current) == 0 && i<100
        pause(.1)
        str_current = send_com (h_stage, command_str);
        i=i+1;
    end
    if i==100
        i/0; %#ok<VUNUS>
    end
    if str_current(2) ~='A'
        'A'/0; %#ok<VUNUS>
    end
    
    temp = textscan(str_current, '%s %d %d');
    Pos = int64([temp{2}, temp{3}]);
    
    % If communications to stage was not open to start, then close.
    if h_stage_close == 1
        stage_close(h_stage);
    end
    
catch ME
    error_show(ME)
end
end
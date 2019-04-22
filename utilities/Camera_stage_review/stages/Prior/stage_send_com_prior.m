%  ##########################################################################
%% ########################## SEND COMMAND ##################################
%  ##########################################################################
function ST_answer=stage_send_com_prior (S, CommandStr)
    %--------------------------------------------------------------------------
    % This function sends commands to the stage. THe opened serial port S
    % is passed as the first argument. The secong argument is the string of
    % the command
    %--------------------------------------------------------------------------
    try
        
    %Get the lenght of the command
    for i=1:size(CommandStr,2)
        fwrite(S,CommandStr(i));
    end
    % send the termination char
    fwrite(S,13);
    
    ST_answer=fgetl(S);

    
    % These are the error messages that can come from the stage
    if strcmp('E,1',ST_answer) 
        disp('NO STAGE');
        errordlg('NO STAGE!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('E,2',ST_answer) 
        disp('Stage not idle');
        errordlg('Stage not idle!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('E,3',ST_answer) 
        disp('No drive');
        errordlg('No drive for stage!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('E,4',ST_answer) 
        disp('String Parse');
        errordlg('String Parse!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('E,5',ST_answer) 
        disp('Command Not Found');
        ST_answer=-1;
    end
    if strcmp('E,8',ST_answer) 
        disp('Value out of range');
        errordlg('Value out of range!','Stage Error');
        ST_answer=-1;
    end
    catch
        disp('Error in stage_send_com_prior (S, CommandStr)');
        errordlg('Unable to send a command to the stage!','Stage Error');
        ST_answer=-1;
    end
end
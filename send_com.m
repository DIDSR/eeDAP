%  ##########################################################################
%% ########################## SEND COMMAND ##################################
%  ##########################################################################
function ST_answer=send_com (S, CommandStr)
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
    
    % The response of the stage to 'STATUS' doesn't have the terminator.
    % THerefore if the command it 'STATUS' the code only reads one command
    if strcmp(CommandStr,'STATUS')
        ST_answer=fscanf(S,'%s',1);
    else
        ST_answer=fgetl(S);
    end
    
    % These are the error messages that can come from the stage
    if strcmp('N: -1',ST_answer) 
        disp('Unknown command');
        ST_answer=-1;
    end
    if strcmp('N: -2',ST_answer) 
        disp('Illegal point type or axis, or module not installed');
        errordlg('Illegal point type or axis, or module not installed!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('N: -3',ST_answer) 
        disp('Not enough parameters (e.g. move r=)');
        errordlg('Not enough parameters (e.g. move r=)!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('N: -4',ST_answer) 
        disp('Parameter out of range');
        errordlg('Parameter out of range!','Stage Error');
        ST_answer=-1;
    end
    if strcmp('N: -21',ST_answer) 
        disp('Process aborted by HALT command');
        errordlg('Process aborted by HALT command!','Stage Error');
        ST_answer=-1;
    end
    catch
        disp('Error in send_com (S, CommandStr)');
        errordlg('Unable to send a command to the stage!','Stage Error');
        ST_answer=-1;
    end
end
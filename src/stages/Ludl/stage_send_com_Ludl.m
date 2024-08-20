%  ##########################################################################
%% ########################## SEND COMMAND ##################################
%  ##########################################################################
function ST_answer=stage_send_com_Ludl (S, CommandStr)
    %--------------------------------------------------------------------------
    % This function sends commands to the stage. THe opened serial port S
    % is passed as the first argument. The secong argument is the string of
    % the command.
    % Refer to the manual ludl_mac5000_stage_commands.pdf
    % string termination character - page 8
    % error codes - page 9
    % STATUS command - page 60
    %--------------------------------------------------------------------------
    try

        % Write the command to the stage controller one character at a time
        % for i=1:size(CommandStr,2)
        %     fwrite(S,CommandStr(i));
        % end
        fwrite(S, CommandStr);
        % Send the termination char to the stage controller
        fwrite(S,13);

        % Read the response from the stage controller
        % The response of the stage to 'STATUS' doesn't have a terminator
        % and must be read as a single character (and return immediately).
        if strcmp(CommandStr,'STATUS')

            ST_answer=fscanf(S,'%s',1);
            return

        else

            ST_answer=fgetl(S);
            % Return if the response from the stage is positive ':A'
            if strncmp(ST_answer, ':A', 2)
                return
            end

        end

    catch

        % Unable to communicate with the stage
        desc = 'Unable to communicate with the stage!';
        error(desc)

    end



    % The response from the stage is negative = error
    % Get the description of the error given the code
    switch ST_answer
        case ':N -1'
            desc = 'Unknown stage command';
        case ':N -2'
            desc = 'Illegal point type or axis, or module not installed';
        case ':N -3'
            desc = 'Not enough parameters (e.g. move r=)';
        case ':N -4'
            desc = 'Parameter out of range';
        case ':N -21'
            desc = 'Process aborted by HALT command';
        otherwise
            desc = 'Error unknown';
    end



    % Open a popup with the error and report error
    h_errordlg = errordlg(desc, 'Stage Error', 'modal');
    uiwait(h_errordlg)
    error(desc)


end
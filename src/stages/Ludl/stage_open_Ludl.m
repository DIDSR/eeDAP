%% stage_open_Ludl
%
%     Attempt to initialize and test the connection to a stage device
%     via a specified COM port. If the connection is not properly
%     established, it displays an error message and handles the issue
%     gracefully.
%
% Syntax:
%     stage = stage_open_Ludl(stage)
%
% Inputs:
%     stage - A structure containing information about the stage. It
%             must have the following fields:
%             .handle - The handle to the COM port associated with the
%                       stage. This should be a valid COM port object.
%
% Outputs:
%     stage - The updated input structure with potentially modified
%             fields. Specifically:
%             .handle - The COM port handle. If the stage is not
%                       properly connected, this will be reset to an
%                       empty string ('').
%             .status - Set to 1 if the stage is successfully connected.
%                       This indicates that the connection test passed.
%
function stage = stage_open_Ludl(stage)

    % Initialize stage.status to 0 = fail
    stage.status = 0;

    % Ask for status from the stage
    desc_status = stage_send_com_Ludl(stage.handle, 'STATUS');

    % If status of stage is acceptable, return.
    if strcmp(desc_status, 'N') || strcmp(desc_status, 'B')
        stage.status = 1;
        return
    else
        % Status of the stage is not acceptable
        desc = 'Unable to communicate with the stage!';
        error(desc)
    end

end
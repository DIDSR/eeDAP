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

    % Delete existing serial ports connections to the stage
    handle = serialportfind(Tag='Stage');
    delete(handle)

    % Test whether COM port is set in the file PortNames.mat
    % If not, set it with the SerialPortSetUp function
    try
        % PortNames.mat contains SerialPortStage,
        %   the last port used and saved
        load('PortNames.mat', 'SerialPortStage');
    catch ME
        % If the last port used is unknown, set it
        stage.status = SerialPortSetUp();
        load('PortNames.mat', 'SerialPortStage');
    end

    % Add SerialPortStage to the stage object
    stage.port = SerialPortStage;


    % stage.handle = serial(SerialPortStage,...
    %     'RequestToSend','off',...
    %     'Timeout',3,...
    %     'Baudrate',9600,...
    %     'Parity', 'none',...
    %     'Stopbits', 2);

    % Connect to the serialport device
    try
        stage.handle = serialport(SerialPortStage, 9600,...
            'Timeout',3,...
            'Parity', 'none',...
            'Stopbits', 2,...
            'Tag','Stage');
    catch ME

        % Select the first line of the error message
        desc = "The stage failed to connect. Try turing the stage off and on.";
        % Create an error dialogboxto display the error message
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        stage = stage_open(stage);

    end

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
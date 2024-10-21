
function stage = stage_open_prior(label)
try
    
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

    stage.handle = serial(SerialPortStage,...
          'RequestToSend','off',...
          'Timeout',3,...
          'Baudrate',9600,...
          'Parity', 'none',...
          'Stopbits', 1,...
          'Flowcontrol','none',...
          'Terminator','CR');

    % Test to see if the COM port is a legitimate COM port
    try
        fopen(stage.handle);
        stage_send_com_prior (stage.handle, 'COMP 0');
    catch ME

        delete(stage.handle);
        stage.handle = '';

        error("Failed to connect stage.")
    end

    % Test to see if the COM port is attached to the stage
    desc_status = stage_send_com_prior (stage.handle, '#');
    if  strcmp(desc_status, '-1')
        
        delete(stage.handle);
        stage.handle = '';

        error("Failed to connect stage.")
    end

    stage.status = 1;
    
catch ME
    error_show(ME)
end
end
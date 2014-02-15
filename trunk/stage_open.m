
function [h_stage, success] = stage_open()
try
    
    % instrfind returns the instrument object array
    % objects = instrfind
    % each entry includes the type, status, and name as follows
    % Index:    Type:     Status:   Name:
    % 1         serial    closed    Serial-COM4
    % 
    % objects can be cleared from memory with
    % delete(objects)

    objects = instrfind;
    delete(objects);

    % Return value if unable to open stage
    h_stage = '';
    
    % Test to see if the COM port is set in the file PortNames.mat
    try
        load('PortNames.mat');
    catch ME
        success = SerialPortSetUp();
        if success == 1
            [h_stage, success] = stage_open();
        end
        return
    end
    
    h_stage = serial(SerialPortStage,...
        'RequestToSend','off',...
        'Timeout',3,...
        'Baudrate',9600,...
        'Parity', 'none',...
        'Stopbits', 2);

    % Test to see if the COM port is a legitimate COM port
    try
        fopen(h_stage);
    catch ME

        delete(h_stage);
        h_stage = '';
        desc = textscan(ME.message,'%s','delimiter','\n');
        desc = desc{1};
        desc = desc(1,:)
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        success = SerialPortSetUp();
        if success == 1 
            [h_stage, success] =  stage_open();
        end
        return
    end

    % Test to see if the COM port is attached to the stage
    desc_status = send_com (h_stage, 'STATUS');
    if ~strcmp(desc_status, 'N') && ~strcmp(desc_status, 'B')
        
        delete(h_stage);
        h_stage = '';
        desc = 'The selected COM port is not connected to the stage.'
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        success = SerialPortSetUp();
        if success == 1 
            [h_stage, success] =  stage_open();
        end
        return
    end

    success = 1;
    
catch ME
    error_show(ME)
end
end
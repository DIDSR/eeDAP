
function stage = stage_open_prior(label)
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

    
    % Test to see if the COM port is set in the file PortNames.mat
    try
        % PortNames.mat contains SerialPortStage, the last port used and
        % saved
        load('PortNames.mat');
    catch ME
        stage.status = SerialPortSetUp();
        if stage.status == 1
            stage = stage_open_prior(label);
        end
        return
    end
    stage.scale=1;
    stage.label=label;
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
        desc = textscan(ME.message,'%s','delimiter','\n');
        desc = desc{1};
        desc = desc(1,:)
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        stage.status = SerialPortSetUp();
        if stage.status == 1 
            stage = stage_open_prior(label);
        end
        return
    end

    % Test to see if the COM port is attached to the stage
    desc_status = stage_send_com_prior (stage.handle, '#');
    if  strcmp(desc_status, '-1')
        
        delete(stage.handle);
        stage.handle = '';
        desc = 'The selected COM port is not connected to the stage.'
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        stage.status = SerialPortSetUp();
        if stage.status == 1 
            stage = stage_open_prior(label);
        end
        return
    end

    stage.status = 1;
    
catch ME
    error_show(ME)
end
end
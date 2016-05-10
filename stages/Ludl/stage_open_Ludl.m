
function stage = stage_open_Ludl(label)
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
    stage.handle='';
    stage.label=label;
    
   switch label
        case 'SCAN8Praparate_Ludl5000'            
            stage.speed=50000;
            stage.accel=100;
            stage.scale=0.1;
        case 'SCAN8Praparate_Ludl6000'         
            stage.speed=200000;
            stage.accel=1;
            stage.scale=0.025;
        case 'BioPrecision2-LE2_Ludl5000'            
            stage.speed=40000;
            stage.accel=100; 
            stage.scale=0.2;
        case 'BioPrecision2-LE2_Ludl6000'           
            stage.speed=150000;
            stage.accel=1;   
            stage.scale=0.05;
       otherwise
            stage.speed=50000;
            stage.accel=100;      
            stage.scale=0.1;
    end  
    
    
    % Test to see if the COM port is set in the file PortNames.mat
    try
        % PortNames.mat contains SerialPortStage, the last port used and
        % saved
        load('PortNames.mat');
    catch ME
        stage.status = SerialPortSetUp();
        if stage.status == 1
            stage = stage_open_Ludl(stage.label);
        end
        return
    end
    
    stage.handle = serial(SerialPortStage,...
        'RequestToSend','off',...
        'Timeout',3,...
        'Baudrate',9600,...
        'Parity', 'none',...
        'Stopbits', 2);

    % Test to see if the COM port is a legitimate COM port
    try
        fopen(stage.handle);
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
            stage = stage_open_Ludl(stage.label);
        end
        return
    end

    % Test to see if the COM port is attached to the stage
    desc_status = stage_send_com_Ludl(stage.handle, 'STATUS');
    if ~strcmp(desc_status, 'N') && ~strcmp(desc_status, 'B')
        
        delete(stage.handle);
        stage.handle = '';
        desc = 'The selected COM port is not connected to the stage.'
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        stage.status = SerialPortSetUp();
        if stage.status == 1 
            stage = stage_open_Ludl(stage.label);
        end
        return
    end

    stage.status = 1;
    
catch ME
    error_show(ME)
end
end

function stage = stage_open_thorlabs(stage)
    % stage_open_thorlabs opens a connection to a thorlabs stage.
    %   stage.status = 1 if the stage is opened successfully and 0 if not
    %
    %   Commands to manage the thorlabs stage depend on Thorlabs Kenesis
    %   software. The software can be downloaded here:
    %   https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0
    %   Version 1.14.49 (64-bit for 64-bit Windows)
    %
    %   The function is based on an exmaple provided by Thorlabs here:
    %   https://github.com/Thorlabs/Motion_Control_Examples/blob/main/Matlab/Benchtop/BBD30X/BBD30X.m
    %
    %   You can also refer to the script stage_thorlabs_dev.m
    %   for more information on the thorlabs objects and methods
    %
    % Inputs:
    %
    % Outputs:
    %
    % Example:

    %% Initialize

    % If stage.device exists, check if it is connected.
    disp('Check if stage object is saved in the base environment.')
    if(evalin('base', 'exist(''savedStage'', ''var'')'))

        disp('Stage object exists in the base environment.')
        savedStage = evalin('base', 'savedStage');

        disp('Check if stage.device exists.')
        if(isfield(savedStage ,"device"))

            disp("stage.device exists. Check if it is connected.")
            if(savedStage.device.IsConnected)
                disp('stage.device is already connected. Return.')
                return;
            end

            disp("stage.device is not connected. Remove and continue.")
            savedStage = rmfield(savedStage, "device");

        end

        clear stage

    else
        disp('Stage object is not saved in the base environment. Continue.')
    end


    % Initialize stage.status to 0 = fail
    stage.status = 0;



    % Add Assemblies
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');

    % Import Assemblies
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*



    %% Connect to device
    % Build Device list
    DeviceManagerCLI.BuildDeviceList();
    nDevices = DeviceManagerCLI.GetDeviceListSize();
    deviceList = DeviceManagerCLI.GetDeviceList();



    % How many devices are in the deviceList
    if nDevices == 0
        error('There are no Thorlabs stages in the deviceList.')
    elseif nDevices == 1
        disp('Connect to the Thorlabs stage in the deviceList.');
        deviceSN = deviceList.Item(0);
        disp(['The serial number of the Thorlabs stage is ', char(deviceSN.ToString)])

    else
        error('There is more than one Thorlabs stage in the deviceList. Continue.')
    end



    % Find the stage
    device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(deviceSN);

    % Connect stage
    disp('Connecting ...')
    device.Connect(deviceSN)
    disp('Stage connected!')

    % timeout = 30000 msec = 30 seconds
    timeout= 30000;



    try

        %% Connect channels 1 and 2 (x and y)
        disp('Connect x and y channels')
        xChannel = device.GetChannel(1);
        yChannel = device.GetChannel(2);

        xChannel.WaitForSettingsInitialized(timeout);
        yChannel.WaitForSettingsInitialized(timeout);

        disp('Start polling x and y channels')
        xChannel.StartPolling(250);
        yChannel.StartPolling(250);

        % Give stage time to initialize
        elapsed = 0;
        while device.IsDeviceBusy
            pause(0.25)
            elapsed = elapsed + .25;

            if elapsed > timeout
                break;
            end
        end

        % Enable channels
        disp('Enable x and y channels')
        xChannel.EnableDevice();
        yChannel.EnableDevice();

        % Give stage time to initialize
        elapsed = 0;
        while device.IsDeviceBusy
            pause(0.25)
            elapsed = elapsed + .25;

            if elapsed > timeout
                break;
            end
        end



    catch ME

        % Disconnect device
        xChannel.StopPolling();
        yChannel.StopPolling();
        xChannel.DisableDevice();
        yChannel.DisableDevice();

        device.Disconnect();

        error_show(ME)
    end



    %% Wrap up and return
    disp('Stage is ready.')
    stage.deviceSN = deviceSN;
    stage.device = device;
    stage.xChannel = xChannel;
    stage.yChannel = yChannel;
    stage.timeout = timeout;
    stage.status = 1;

    % % Save stage information in base environment for error recovery
    assignin('base', 'savedStage', stage)



end
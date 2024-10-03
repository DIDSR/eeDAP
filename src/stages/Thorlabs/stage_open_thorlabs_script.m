
% stage_open_thorlabs_script opens a connection to a thorlabs stage.
%   This script is meant to be run in the base environment.
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

% Include subdirectories
addpath(genpath(pwd))

% If stage.device exists, check if it is connected.
disp("Check if stage object is saved in the base environment.")
if(exist("savedStage", "var"))

    disp("Stage object exists in the base environment.")
    disp("Check if savedStage.device exists.")
    if(isfield(savedStage ,"device"))

        disp("savedStage.device exists. Check if it is connected.")
        if(savedStage.device.IsConnected)
            disp("savedStage.device is already connected. Return.")
            return;
        end

    end
    disp("savedStage.device  does not exist. Continue.")
else
    disp("Stage object is not saved in the base environment. Continue.")
end


% Initialize savedStage.status to 0 = fail
savedStage.status = 0;



% Add Assemblies
NET.addAssembly("C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll");
NET.addAssembly("C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll");
NET.addAssembly("C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll");

% Import Assemblies
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*



%% Connect to device
% Build Device list
DeviceManagerCLI.BuildDeviceList();
savedStage.nDevices = DeviceManagerCLI.GetDeviceListSize();
savedStage.deviceList = DeviceManagerCLI.GetDeviceList();



% How many devices are in the deviceList
if savedStage.nDevices == 0

    error("There are no Thorlabs stages in the deviceList.")

elseif savedStage.nDevices == 1

    disp("Connect to the Thorlabs stage in the deviceList.");
    savedStage.deviceSN = savedStage.deviceList.Item(0);
    disp("The serial number of the Thorlabs stage is " + string(char(savedStage.deviceSN.ToString)))

else
    error("There is more than one Thorlabs stage in the deviceList. Continue.")
end



% Find the stage
disp("Create the stage device object")
savedStage.device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(savedStage.deviceSN);

% Connect stage
disp("Connect to the stage ...")
savedStage.device.Connect(savedStage.deviceSN)
disp("Stage connected!")

% timeout = 30000 msec = 30 seconds
savedStage.timeout= 30000;



try

    %% Connect channels 1 and 2 (x and y)
    disp("Connect x and y channels")
    savedStage.xChannel = savedStage.device.GetChannel(1);
    savedStage.yChannel = savedStage.device.GetChannel(2);

    savedStage.xChannel.WaitForSettingsInitialized(savedStage.timeout);
    savedStage.yChannel.WaitForSettingsInitialized(savedStage.timeout);

    disp("Start polling x and y channels")
    savedStage.xChannel.StartPolling(250);
    savedStage.yChannel.StartPolling(250);

    % Give stage time to initialize
    elapsed = 0;
    while savedStage.device.IsDeviceBusy
        pause(0.25)
        elapsed = elapsed + .25;

        if elapsed > savedStage.timeout
            break;
        end
    end

    % Enable channels
    disp("Enable x and y channels")
    savedStage.xChannel.EnableDevice();
    savedStage.yChannel.EnableDevice();

    % Give stage time to initialize
    elapsed = 0;
    while savedStage.device.IsDeviceBusy
        pause(0.25)
        elapsed = elapsed + .25;

        if elapsed > savedStage.timeout
            break;
        end
    end



catch ME

    % Disconnect device
    stage_close_thorlabs_script;
    % savedStage.xChannel.StopPolling();
    % savedStage.yChannel.StopPolling();
    % savedStage.xChannel.DisableDevice();
    % savedStage.yChannel.DisableDevice();
    % 
    % savedStage.device.Disconnect();
    % 
    % clear savedStage

    error_show(ME)
end



disp("Stage is ready.")

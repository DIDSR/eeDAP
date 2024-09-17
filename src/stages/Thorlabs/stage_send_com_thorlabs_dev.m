
% From SDK: "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Kinesis.TestClient.exe"
% The SDK starts up and the command log shows the following actions:
%    Settings searched, not found, general settings used
%    Loading / storing device settings for these serial numbers
%    (not in order)
%    103205074
%    103205074-0
%    103205074-1 (appears to be x-channel)
%    103205074-2 (appears to be y-channel)
%    103205074-3
% Reading Settings (Device - BBD30XMotherboard)

%% Commands to control the stage
%
% Derived from example for the BBD303 using the DDR100 stage
% https://github.com/Thorlabs/Motion_Control_Examples
%
% Also refer to the Kinesis documentation (and "Namespaces")
% C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Thorlabs\Kinesis\.Net API Help.lnk
%
%
% Kinesis software
% https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0
%
% BBD30X.m
% Created Date: 2024-01-23
% Last modified date: 2024-07-02
% Matlab Version: R2023b
% Thorlabs DLL version: Kinesis 1.14.44
%
% Notes
%
%


% Clear environment
clear all; close all; clc

%% Add and Import Assemblies
devCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
genCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
motCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');
NET.addAssembly('System.Collections')

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*
import System.Collections.Generic.*

% Create Simulation (Comment out for real device)
SimulationManager.Instance.InitializeSimulations();



%% Discover devices
% Build Device list must create some kind of internal list of devices
DeviceManagerCLI.BuildDeviceList();
% How many devices were detected
nDevices = DeviceManagerCLI.GetDeviceListSize();
% This list can be used to check that a BBD30X stage controller exists
% 103 is the prefix for the controller serial number
deviceList = DeviceManagerCLI.GetDeviceList(103);

% What methods are available for deviceList
methods(deviceList)

% How many devices are in the deviceList
if nDevices == 0
    error('There are no Thorlabs stages in the deviceList.')
elseif nDevices == 1
    disp('There is one Thorlabs stage in the deviceList.');
else
    error('There is more than one Thorlabs stage in the deviceList.')
end

% What is the stage serial number found in deviceList (index starts at 0)
% serialNumber = '103205074'; % BBD302 controller serial number
% serialNumber = '103000001'; % Simulated BBD30X controller serial number
deviceSN = deviceList.Item(0);
disp(deviceSN)



% Input Parameters
timeout= 60000; % 6000 msec = 60 seconds
position = 10; % mm

% Connect to device
% The output of this line must be suppressed
device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(deviceSN);
device.Connect(deviceSN)



try
    % Try/Catch statement used to disconnect correctly after an error

    % Connect to channels 1 and 2 (x and y)
    xChannel = device.GetChannel(1);
    yChannel = device.GetChannel(2);
    xChannel.WaitForSettingsInitialized(10000);
    yChannel.WaitForSettingsInitialized(10000);
    xChannel.StartPolling(250);
    yChannel.StartPolling(250);

    % Give stage time to initialize
    % 40 * 0.25 msec == 10 sec
    i = 1;
    while device.IsDeviceBusy
        pause(0.25)
        i = i + 1;

        if i > 40
            break;
        end
    end

    % Enable channels
    xChannel.EnableDevice();
    yChannel.EnableDevice();

    % The return variable tells us about the channel config
    motorSettings = xChannel.LoadMotorConfiguration(xChannel.DeviceID);

    % Display info about the channel
    xChannel.GetDeviceInfo()

    % From .NET API documentation
    % There are 3 ways of executing Move / Home methods using the Kinesis .NET API
    %   1. Wait for completion with timeout.
    %       Use device.Home(60000) or device.Move(position, 60000).
    %       These functions will execute the command and will wait for completion.
    %       The function will fail if the command is not completed before the defined timeout (in ms).
    %   2. Wait for completition with callback.
    %       Use device.Home(callback) or device.Move(position, callback).
    %       These functions will execute the command and continue.
    %       The callback function will be called when the Home / Move has completed.
    %       This allows the program to process status etc. whilst waiting for completion.
    % 3. Fire and forget. Use device.Home() or device.Move(position).
    %       These functions will execute the command but will not wait for completion.

    % Home Motor - channel 1
    fprintf("Homing...\n")
    xChannel.Home(timeout);
    fprintf("Homed\n")

    % Move to position - channel 1
    fprintf("Moving...\n")
    xChannel.MoveTo(position, timeout);
    fprintf("Moved\n")

    % Get position
    xChannel.GetPositionCounter

    % Move to a stage coordinate
    xChannel.MoveTo_DeviceUnit(20000, timeout)

    % Create x and y MultiChannelMoveTarget objects
    xDestination = MultiChannelMoveTarget;
    xDestination.ChannelNumber = 1;
    xDestination.TargetPosition = 30000;
    yDestination = MultiChannelMoveTarget;
    yDestination.ChannelNumber = 2;
    yDestination.TargetPosition = 30000;

    destination = NET.createGeneric('Collections.Generic.IEnumerable', )
    listType = {'MotionControl.DeviceManagerCLI.MultiChannelMoveTarget'};
    channelTargets = NET.createGeneric('System.Collections.Generic.IEnumerable', listType);

    temp = NET.createGeneric('System.Collections.Generic.List',{'System.String'},2);
    temp = NET.createGeneric('System.Collections.Generic.IEnumerable',{'System.String'},2);
    temp = NET.createGeneric('System.Collections.Generic.IEnumerable',{'MultiDeviceChannel'});

    IEnumerable = NET.explicitCast(temp,'System.Collections.Generic.IEnumerable');

    destination = NET.createGeneric('System.Collections.Generic.List',{'System.String'},2);

    device.MoveTo_DeviceUnits(xDestination, timeout);

    temp = Thorlabs.MotionControl.GenericMotorCLI.

    %
    % % Combine x and y destinations
    % targetsList = Collections.Generic.IEnumerable.MuliChannelMoveTarget
    %
    % destination(1) = xDestination;
    % destination(2) = yDestination;
    %
    %
    % myList = System.Collections.Generic.List<MultiChannelMoveTarget>();
    %
    %
    % % Move to x,y stage coordinates
    % fprintf("Moving...\n")
    % device.MoveTo_DeviceUnits(xDestination, timeout);
    % fprintf("Moved\n")
    % pause(1);

catch e
    fprintf("Error has caused the program to stop, disconnecting..\n")

    % Disconnect
    xChannel.StopPolling();
    yChannel.StopPolling();
    xChannel.DisableDevice();
    yChannel.DisableDevice();

    device.Disconnect();

    fprintf(e.identifier);
    fprintf("\n");
    fprintf(e.message);
end

% Close simulation
SimulationManager.Instance.UninitializeSimulations();

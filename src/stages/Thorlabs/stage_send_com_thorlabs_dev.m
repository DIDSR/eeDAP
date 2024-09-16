
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
% Kinesis software
% https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control&viewtab=0
%
% BBD30X.m
% Created Date: 2024-01-23
% Last modified date: 2024-07-02
% Matlab Version: R2023b
% Thorlabs DLL version: Kinesis 1.14.44
%
%% Notes
%
%%
%% Start of code
clear all; close all; clc

%% Add and Import Assemblies
devCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
genCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
motCLI = NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');

import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*

%% Create Simulation (Comment out for real device)
SimulationManager.Instance.InitializeSimulations(); 

% Input Parameters
% serialNumber = '103205074'; % BBD302 controller serial number
serialNumber = '103000001'; % BBD30X controller serial number
timeout= 60000;
position = 10; % mm

%% Connect to device
% Build Device list must create some kind of internal list of devices
DeviceManagerCLI.BuildDeviceList();
% How many devices were detected
nDevices = DeviceManagerCLI.GetDeviceListSize();
% This list can be used to check that a BBD30X stage controller exists
% 103 is the prefix for the controller
deviceList = DeviceManagerCLI.GetDeviceList(103);

% Is a real or simulated stage connected?
if nDevices > 0
    disp("There is at least one thorlabs device.");
end

% Is our serial number in the list of devices
if deviceList.Contains(serialNumber) == 1
    disp("Our device appears in the device list.")
end



% Connect to device
device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(serialNumber); %;The output of this line must be suppressed
device.Connect(serialNumber)
try
    % Try/Catch statement used to disconnect correctly after an error

    % Channels are connected using the same serial number
    % Connect to the channel
    channel = device.GetChannel(1); % Get Channel 1
    channel.WaitForSettingsInitialized(10000);
    channel.StartPolling(250);
    
    % Enable device on channel 1
    channel.EnableDevice();
    pause(3);
    
    % The return variable tells us about the channel config
    motorSettings = channel.LoadMotorConfiguration(channel.DeviceID);

    % Display info about the channel
    channel.GetDeviceInfo()


    pause(1);
    % Home Motor
    fprintf("Homing...\n")
    channel.Home(timeout);
    fprintf("Homed\n")
    pause(2);
    
    %% Move to position
    fprintf("Moving...\n")
    channel.MoveTo(position, timeout);
    fprintf("Moved\n")
    pause(1);

    %% Get position
    channel.GetPositionCounter

    %% Move in a specific direction
    channel.MoveRelative_DeviceUnit(MotorDirection.Forward, 20000/2, 6000)
    channel.MoveTo_DeviceUnit(20000, 6000)
    
    temp struct MotorDirection

catch e
    fprintf("Error has caused the program to stop, disconnecting..\n")
    fprintf(e.identifier);
    fprintf("\n");
    fprintf(e.message);
end

% %% Disconnect
% channel.StopPolling();
% channel.DisableDevice();
% device.Disconnect();

%% Close Simulations (Comment out if using a real device)
SimulationManager.Instance.UninitializeSimulations(); %Close Simulations

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
    %   
    %
    % Inputs:
    %
    % Outputs:
    %
    % Example:

    %% Import Assemblies
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*

    try

        %% Import Assemblies
        % Notice that original code return the assembly into variables
        % named for the assembly

        % devCLI =
        NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
        % genCLI =
        NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
        % motCLI =
        NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');

        % Initialize stage.status to 0 = fail
        stage.status = 0;

        %% Connect to device
        % Build Device list
        DeviceManagerCLI.BuildDeviceList();
        DeviceManagerCLI.GetDeviceListSize();
        DeviceManagerCLI.GetDeviceList();

        % Input Parameters
        % BBD302 controller serial number (or Kinesis Simulator)
        % This needs to be an input variable,
        % maybe it should be encoded into the stage name
        serialNumber = '103205074'; % Device
        serialNumber = '103000001'; % Simulator

        % Connect to device
        % The output of this line must be suppressed. Not sure why?
        device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(serialNumber);
        device.Connect(serialNumber)

        % Enable device on channel 1
        channel.EnableDevice();
        pause(3);

        stage.status = 1;

    catch ME
        error_show(ME)
    end
end
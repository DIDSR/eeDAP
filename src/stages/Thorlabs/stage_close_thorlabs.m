
function stage_close_thorlabs(stage)
    % stage_close_thorlabs closes a connection to a thorlabs stage.
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
    % Import Assemblies
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*




        % Disconnect device
        
        xChannel.StopPolling();
        yChannel.StopPolling();
        xChannel.DisableDevice();
        yChannel.DisableDevice();

        device.Disconnect();

        evalin('base', ['clear ', 'savedStage']);


end
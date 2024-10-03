
function stage = stage_set_origin_thorlabs(stage)
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

    try

        disp('Is stage busy?')
        disp(stage.device.IsDeviceBusy)

        fprintf("Homing x channel ...\n")
        stage.xChannel.Home(stage.timeout);
        fprintf("Homed\n")

        fprintf("Homing y channel ...\n")
        stage.yChannel.Home(stage.timeout);
        fprintf("Homed\n")

    catch ME
        error_show(ME);
    end

end


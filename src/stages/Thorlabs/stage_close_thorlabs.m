
function stage = stage_close_thorlabs(stage)
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

    % If stage.device exists in current environment, remove it.
    disp('Check if stage.device object exists and is connected.')
    if(exist('stage', 'var') && isfield(stage, 'device'))

        % If stage.device is already connected, return.
        if(stage.device.IsConnected)
            disp('Stage is already connected. Disconnect.')
            stage.xChannel.StopPolling();
            stage.yChannel.StopPolling();
            stage.xChannel.DisableDevice();
            stage.yChannel.DisableDevice();
            stage.device.Disconnect;
        end

        % Clear stage.device from the current environment.
        disp('stage.device is not connected, remove the field and continue.')
        stage = rmfield(stage, {'device', 'xChannel', 'yChannel'});
        evalin('base', ['clear ', 'savedStage']);

    end


    % If savedStage exists in the base environment, remove it.
    disp('Check if stage object exists in base environment.')
    if(evalin('base', 'exist(''savedStage'', ''var'')'))
        stage = evalin('base', 'savedStage');
        disp('Stage recovered from base environment.')

        % If stage is already connected, return.
        if(stage.device.IsConnected)
            disp('Stage is already connected. Disconnect.')
            stage.xChannel.StopPolling();
            stage.yChannel.StopPolling();
            stage.xChannel.DisableDevice();
            stage.yChannel.DisableDevice();
            stage.device.Disconnect;
        end

        % Clear stage from the base environment.
        disp('Stage is not connected, clear it from the base environment.')
        evalin('base', ['clear ', 'savedStage']);

    end

end
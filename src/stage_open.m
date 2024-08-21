
function stage = stage_open(stage)
    try

        % Delete existing serial ports connections to the stage
        handle = serialportfind(Tag='Stage');
        delete(handle)

        % Test whether COM port is set in the file PortNames.mat
        % If not, set it with the SerialPortSetUp function
        try
            % PortNames.mat contains SerialPortStage,
            %   the last port used and saved
            load('PortNames.mat', 'SerialPortStage');
        catch ME
            % If the last port used is unknown, set it
            stage.status = SerialPortSetUp();
        end



        % stage.handle = serial(SerialPortStage,...
        %     'RequestToSend','off',...
        %     'Timeout',3,...
        %     'Baudrate',9600,...
        %     'Parity', 'none',...
        %     'Stopbits', 2);

        % Connect to the serialport device
        try
            stage.handle = serialport(SerialPortStage, 9600,...
                'Timeout',3,...
                'Parity', 'none',...
                'Stopbits', 2,...
                'Tag','Stage');
        catch ME

            % Select the first line of the error message
            desc = "The stage failed to connect. Try turing the stage off and on.";
            % Create an error dialogboxto display the error message
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)

        end



        % Initialize properties of the stage and open the stage
        switch stage.label

            case 'H101-Prior'
                stage.speed = 50000;
                stage.accel=100;
                stage.scale=0.1;
                stage = stage_open_prior(stage);

            case 'SCAN8Praparate_Ludl5000'
                stage.speed=50000;
                stage.accel=100;
                stage.scale=0.1;
                stage = stage_open_Ludl(stage);

            case 'SCAN8Praparate_Ludl6000'
                stage.speed=200000;
                stage.accel=1;
                stage.scale=0.025;
                stage = stage_open_Ludl(stage);

            case 'BioPrecision2-LE2_Ludl5000'
                stage.speed=40000;
                stage.accel=100;
                stage.scale=0.2;
                stage = stage_open_Ludl(stage);

            case 'BioPrecision2-LE2_Ludl6000'
                stage.speed=150000;
                stage.accel=1;
                stage.scale=0.05;
                stage = stage_open_Ludl(stage);

            case 'MLS203-ThorLabs'
                stage.speed=50000;
                stage.accel=100;
                stage.scale=0.1;
                stage = stage_open_thorlabs(stage);

            otherwise
                error('The stage label is not recognized')
        end

    catch ME
        error_show(ME)
    end
end
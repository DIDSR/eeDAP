
function stage = stage_open(stage)
    try



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

            case 'thorlabs_MLS203_BBD302'
                stage.speed=250000; % um/sec
                stage.accel=2000000; % um/sec
                stage.scale=0.05; % um/device unit
                % stage = stage_open_thorlabs(stage);
                evalin("base", "stage_open_thorlabs_script")

            otherwise
                error('The stage label is not recognized')
        end

    catch ME
        error_show(ME)
    end
end
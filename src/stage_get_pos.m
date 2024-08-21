function stage=stage_get_pos(stage)

    try

        % If stage is not open, open it
        if (~strcmp(stage.handle.Status, 'open'))
            stage = stage_open(stage);
        end

        % Get position
        switch stage.label

            case 'H101-Prior'
                stage = stage_get_pos_prior(stage);

            case 'SCAN8Praparate_Ludl5000'
                stage = stage_get_pos_Ludl(stage);

            case 'SCAN8Praparate_Ludl6000'
                stage = stage_get_pos_Ludl(stage);

            case 'BioPrecision2-LE2_Ludl5000'
                stage = stage_get_pos_Ludl(stage);

            case 'BioPrecision2-LE2_Ludl6000'
                stage = stage_get_pos_Ludl(stage);
                
            case 'MLS203-ThorLabs'
                stage = stage_get_pos_thorlabs(stage);

            otherwise
                error('The stage label is not recognized')
        end

    catch ME
        error_show(ME)
    end
end
function stage=stage_get_pos(stage)
    % instrfind returns the instrument object array
    % objects = instrfind
    % each entry includes the type, status, and name as follows
    % Index:    Type:     Status:   Name:
    % 1         serial    closed    Serial-COM4
    %
    % objects can be cleared from memory with
    % delete(objects)

    try

        % If stage is not open, open it
        if (~strcmp(stage.handle.Status, 'open'))
            stage = stage_open(stage);
        end

        % Initialize properties of the stage and open the stage
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
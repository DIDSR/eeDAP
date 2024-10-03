%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage = stage_set_origin(stage)
try

            % Set origin
        switch stage.label

            case 'H101-Prior'
                stage = stage_set_origin_prior(stage);

            case 'SCAN8Praparate_Ludl5000'
                stage = stage_set_origin_Ludl(stage);

            case 'SCAN8Praparate_Ludl6000'
                stage = stage_set_origin_Ludl(stage);

            case 'BioPrecision2-LE2_Ludl5000'
                stage = stage_set_origin_Ludl(stage);

            case 'BioPrecision2-LE2_Ludl6000'
                stage = stage_set_origin_Ludl(stage);
                
            case 'thorlabs_MLS203_BBD302'
                % stage = stage_set_origin_thorlabs(stage);
                evalin("base", "stage_set_origin_thorlabs_script")

            otherwise
                error('The stage label is not recognized')
        end

catch ME
    error_show(ME);
end

end


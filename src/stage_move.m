%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage=stage_move(stage, target_pos)
    %--------------------------------------------------------------------------
    % Move_Stage_Seq starts a []sequence that moves the stage from position A
    % to position B. THe function displays a waitbar and also adjusts
    % the acceleration and the speed of the stage. Target position is
    % specified as a horizontal vector of size 2.
    %--------------------------------------------------------------------------

    try

        % % If stage is not open, open it
        % if (~strcmp(stage.handle.Status, 'open'))
        %     stage = stage_open(stage);
        % end

        % Move stage
        switch stage.label

            case 'H101-Prior'
                stage = stage_move_prior(stage, target_pos);

            case 'SCAN8Praparate_Ludl5000'
                stage = stage_move_Ludl(stage, target_pos);

            case 'SCAN8Praparate_Ludl6000'
                stage = stage_move_Ludl(stage, target_pos);

            case 'BioPrecision2-LE2_Ludl5000'
                stage = stage_move_Ludl(stage, target_pos);

            case 'BioPrecision2-LE2_Ludl6000'
                stage = stage_move_Ludl(stage, target_pos);

            case 'thorlabs_MLS203_BBD302'
                % stage = stage_move_thorlabs(stage, target_pos);
                evalin("base", "whos")
                evalin("base", "savedStage")
                assignin("base", "targetPosition", target_pos)
                evalin("base", "targetPosition")
                evalin("base", "stage_move_thorlabs_script")

            otherwise
                error('The stage label is not recognized')
        end

    catch ME
        error_show(ME)
    end

end
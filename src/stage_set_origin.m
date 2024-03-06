%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage = stage_set_origin(stage,h_stage)
try
    stage_label = stage.label;
    if strcmp(stage_label(end-4:end),'Prior')
        if exist('h_stage', 'var') == 0
            stage = stage_set_origin_prior(stage);
        else
            stage = stage_set_origin_prior(stage,h_stage);
        end
    elseif strcmp(stage_label(end-4:end),'Ludl')
        if exist('h_stage', 'var') == 0
            stage = stage_set_origin_Ludl(stage);
        else
            stage = stage_set_origin_Ludl(stage,h_stage);
        end
    else
        if exist('h_stage', 'var') == 0
            stage = stage_set_origin_thorlabs(stage);
        else
            stage = stage_set_origin_thorlabs(stage,h_stage);
        end    
    end

catch ME
    error_show(ME);
end

end


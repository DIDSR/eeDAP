%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage = stage_set_origin(stage,h_stage)
try
    stage_label = stage.label;
    if strcmp(stage_label,'H101-Prior')
        if exist('h_stage', 'var') == 0
            stage = stage_set_origin_prior(stage);
        else
            stage = stage_set_origin_prior(stage,h_stage);
        end
        
    elseif strcmp(stage_label,'SCAN8Praparate_Ludl5000')
        if exist('h_stage', 'var') == 0
            stage = stage_set_origin_Ludl(stage);
        else
            stage = stage_set_origin_Ludl(stage,h_stage);
        end
        
    elseif strcmp(stage_label,'BioPrecision2-LE2_Ludl6000')
        if exist('h_stage', 'var') == 0
            stage = stage_set_origin_Ludl(stage);
        else
            stage = stage_set_origin_Ludl(stage,h_stage);
        end
        
    elseif strcmp(stage_label,'MLS203-ThorLabs')
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


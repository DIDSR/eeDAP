function stage=stage_get_pos(stage,h_stage)
% instrfind returns the instrument object array
% objects = instrfind
% each entry includes the type, status, and name as follows
% Index:    Type:     Status:   Name:
% 1         serial    closed    Serial-COM4
%
% objects can be cleared from memory with
% delete(objects)
try
    stage_label = stage.label;
    if strcmp(stage_label(end-4:end),'Prior')
        if exist('h_stage', 'var') == 0
            stage = stage_get_pos_prior(stage);
        else
            stage = stage_get_pos_prior(stage,h_stage);
        end        
    elseif
        if exist('h_stage', 'var') == 0
            stage = stage_get_pos_Ludl(stage);
        else
            stage = stage_get_pos_Ludl(stage,h_stage);
        end
    elseif
        if exist('h_stage', 'var') == 0
            stage = stage_get_pos_thorlabs(stage);
        else
            stage = stage_get_pos_thorlabs(stage,h_stage);
        end
    end
    
catch ME
    error_show(ME)
end
end
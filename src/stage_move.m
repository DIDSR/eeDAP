%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage=stage_move(stage, target_pos, h_stage)
%--------------------------------------------------------------------------
% Move_Stage_Seq starts a []sequence that moves the stage from position A
% to position B. THe function displays a waitbar and also adjusts
% the acceleration and the speed of the stage. Target position is
% specified as a horizontal vector of size 2.
%--------------------------------------------------------------------------
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
            stage = stage_move_prior(stage, target_pos);
        else
            stage = stage_move_prior(stage, target_pos,h_stage);
        end
    else
        if exist('h_stage', 'var') == 0
            stage = stage_move_Ludl(stage, target_pos);
        else
            stage = stage_move_Ludl(stage, target_pos,h_stage);
        end
    end
catch ME
    error_show(ME)
end

end
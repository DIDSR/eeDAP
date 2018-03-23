%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage = stage_get_joy_speed(stage,h_stage)
try
    stage_label = stage.label;
    if ~strcmp(stage_label(end-4:end),'Prior')
        if exist('h_stage', 'var') == 0
            stage = stage_get_joy_speed_Ludl(stage);
        else
            stage = stage_get_joy_speed_Ludl(stage,h_stage);
        end
        
    end

catch ME
    error_show(ME);
end

end


%  ##########################################################################
%% ###################### MOVE STAGE SEQUENCE ###############################
%  ##########################################################################
function stage = stage_set_joy_speed(stage,target_speed,h_stage)
try
    stage_label = stage.label;
    if ~strcmp(stage_label(end-4:end),'Prior')
        if exist('h_stage', 'var') == 0
            stage = stage_set_joy_speed_Ludl(stage,target_speed); %note 6/01/2021: function directs to Ludl settings under prior
        elseif ~strcmp(stage_label(end-4:end),'Ldul')
            stage = stage_set_joy_speed_Ludl(stage,target_speed,h_stage);
        else 
            stage = stage_set_joy_speed_Ludl(stage,target_speed); 
        end
        
    end

catch ME
    error_show(ME);
end

end



function stage = stage_open(label)
try
    
    
    if strcmp(label(end-4:end),'Prior')
        stage = stage_open_prior(label);
    elseif strcmp(label(end-4:end),'Ludl')
        stage = stage_open_Ludl(label);
    else
        stage = stage_open_thorlabs(label);
    end
    
catch ME
    error_show(ME)
end
end

function stage = stage_open(label)
try
    
    
    if strcmp(label(end-4:end),'Prior')
        stage = stage_open_prior(label);
    else
        stage = stage_open_Ludl(label);
    end
    
catch ME
    error_show(ME)
end
end
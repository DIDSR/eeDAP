
%% ################# CHECK STAGE STATUS FOR PRIOR ##########################
function busy = stage_check_busy_prior(S)
try
    
    status=stage_send_com_prior (S, '#');
    if isempty(status)
        busy = 1;
        return
    end
    busy = str2num(status);
    
catch ME
    error_show(ME)
end

end
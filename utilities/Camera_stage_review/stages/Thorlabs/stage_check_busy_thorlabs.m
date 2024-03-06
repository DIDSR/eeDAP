
%% ################# CHECK STAGE STATUS FOR THORLABS ##########################
function busy = stage_check_busy_thorlabs(S)
try
    
    status=stage_send_com_thorlabs (S, '#');
    if isempty(status)
        busy = 1;
        return
    end
    busy = str2num(status);
    
catch ME
    error_show(ME)
end

end
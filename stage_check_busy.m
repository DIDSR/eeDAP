function busy = stage_check_busy(S)
try
    
    success=send_com (S, 'STATUS');
    if isempty(success)
        busy = 1;
        return
    end
    
    if success=='B'
        busy=1;
    else
        busy=0;
    end
    
catch ME
    error_show(ME)
end

end
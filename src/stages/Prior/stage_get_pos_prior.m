
%% ################# GET STAGE POSITION SEQUENCE FOR PRIOR ##########################
function stage=stage_get_pos_prior(stage)
    try
        
        % If stage is not open, error
        if (~strcmp(stage.handle.Status, 'open'))
            error('Stage is not connected')
        end

        % Initialize stage position
        stage.Pos = 0;

        % Get the x,y position
        % command_str = 'where x y';
        command_str = sprintf('PS');
        str_current = stage_send_com_prior (stage.handle, command_str);

        % Keep checking the stage for a response, it isn't immediate
        i=1;
        while numel(str_current) == 0 && i<100
            pause(.1)
            str_current = stage_send_com_prior (stage.handle, command_str);
            i=i+1;
        end

        % If we never get a response or the response is not positive, error
        if i==100 || str_current(2) ~='A'
            error("Stage failed to respond.")
        end

        % Parse the stage response for return
        temp = textscan(str_current, '%d %d','Delimiter',',');
        stage.Pos = int64([temp{1}, temp{2}]);
        
    catch ME
        error_show(ME)
    end
end
%  ##########################################################################
%% ################# MOVE STAGE SEQUENCE FOR PORIOR##########################
%  ##########################################################################
function stage = stage_set_origin_prior(stage)
    try
        
        % Speed to the top-left corner
        success = stage_send_com_prior(stage.handle, 'G -100000,-100000');

        % Wait til the stage gets to the top-left corner
        while stage_check_busy_prior(stage.handle)
            pause(.5)
        end

        % Set the top-left corner to be the origin
        success = stage_send_com_prior(stage.handle, 'Z');

        % For better precision, slow it down, move it away, and go back home
        success = stage_send_com_prior(stage.handle, 'G 50,50');
        success = stage_send_com_prior(stage.handle, 'G -50,-50');
        while stage_check_busy_prior(stage.handle)
            pause(.5)
        end

        % Reset the top-left corner to be the origin
        success = stage_send_com_prior (stage.handle, 'Z');

        % Back off the oritin a little bit
        stage=stage_move_prior(stage,[5000,5000]);  

    catch ME
        error_show(ME);
    end

end


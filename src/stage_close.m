%  ##########################################################################
%% ######################## CLOSE SERIAL PORT ###############################
%  ##########################################################################
function status=stage_close(stage)

    %--------------------------------------------------------------------------
    % This function closes the serial port of the stage. Reference to the serial
    % port is passed to it as the argument S.
    %--------------------------------------------------------------------------

    try



        % Initialize properties of the stage and open the stage
        switch stage.label

            case 'H101-Prior'
                delete(stage.handle)
                status=0;


            case 'SCAN8Praparate_Ludl5000'
                delete(stage.handle)
                status=0;

            case 'SCAN8Praparate_Ludl6000'
                delete(stage.handle)
                status=0;

            case 'BioPrecision2-LE2_Ludl5000'
                delete(stage.handle)
                status=0;

            case 'BioPrecision2-LE2_Ludl6000'
                delete(stage.handle)
                status=0;

            case 'thorlabs_MLS203_BBD302'
                % Don't bother deleting the stage. Can't get it to work.
                % The application should find the stage already connected
                % in the base environment.

            otherwise
                error('The stage label is not recognized')
        end



    end
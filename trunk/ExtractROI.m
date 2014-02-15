
%  ##########################################################################
%% ########################## EXTRACT ROI ###################################
%  ##########################################################################
function success = ExtractROI(...
    AX1,...                 % ActiveX component
    InputFile,...           % WSI file name full and absolute path
    OutputFile, ...         % Output file name with full and absolute path
    Left,...                % Left coordinate of region to extract
    Top, ...                % Right coordinate of region to extract
    InputWidth,...          % Width of region to extract
    InputHeight, ...        % Height of region to extract
    OutputWidth,...         % Width to rescale extracted region
    OutputHeight,...        % Height to rescale extracted region
    rgb_lut)                % The rgb look up table is 3x256 uint8
                            % Maps r to new r, g to new g, b to new b
try
    %--------------------------------------------------------------------------
    % This procedure extracts an ROI from the InputFile (WSI), rescales it,
    % rotates it, and writes it to the OutputFile (tif).
    %
    % If InputWidth=0, then extract whole width.
    %
    % If InputHeight=0, then extract whole height.
    %
    % TIFFComp object property FixAspect is set so that the aspect ratio of the
    % output image is the same as that of the input image (approximately)
    %
    % If OutputWidth=0 and OutputHeight=0, then OutputWidth and OutputHeight
    % are set to InputWidth and InputHeight
    %
    % Note: If aspect ratio of OutputWidth and OutputHeight does not
    % exactly match aspect ratio of the extraction region, TIFFComp
    % will automatically set OutputHeight so that aspect ratios are
    % approximately equal
    %
    % When eeDAP OutputHeight=0, we only set eeDAP OutputWidth.
    % TIFFComp will automatically set eeDAP OutputHeight so that aspect ratios
    % are approximately equal
    %
    % When eeDAP OutputWidth=0, we only set eeDAP OutputHeight.
    % TIFFComp will automatically set eeDAP OutputWidth to maintain equivalent
    % aspect ratio with the extraction region.
    %--------------------------------------------------------------------------
    
    % If this function completes successfully, it will return 1.
    % Otherwise it will return 0.
    success = 0;
    
    % Check inputs: Origin, Height, and Width
    if ...
            (Left<=0) || (Top<=0) ||...
            (InputWidth<0) || (InputHeight<0) ||...
            (OutputWidth<0) || (OutputHeight<0)
        
        desc = char(['Error in ExtractROI: ',...
            'Illegal Extraction Origin Left or Top, ',...
            'ExtractHeight or ExtractWidth'],...
            ['Origin Left = ', num2str(Left)],...
            ['Origin Top = ', num2str(Top)],...
            ['InputWidth = ', num2str(InputWidth)],...
            ['InputHeight = ', num2str(InputHeight)],...
            ['OutputWidth = ', num2str(OutputWidth)],...
            ['OutputHeight = ', num2str(OutputHeight)]);
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    try
        AX1.OpenInput(InputFile);
    catch
        delete(AX1);
        desc = ['TIFFComp Error: Whole slide file cannot be opened.',...
            ' Filename = ',InputFile];
        display(desc);
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    % ExtractROI is only being used to link to get WSI information
    if strcmp(OutputFile,'none')
        return
    end
    
    if ~AX1.OpenOutput(OutputFile)
        desc = 'TIFFComp Error: Output image cannot be created.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
    end
    
    if ~set(AX1,'Compression',0);
        desc = 'TIFFComp Error: Compression cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    if ~set(AX1,'Rotate',1);
        desc = 'TIFFComp Error: Rotation cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    if ~set(AX1,'FixAspect',1);
        desc = 'TIFFComp Error: Aspect ratio cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    % Apply the color profile to the pixel intensities
    if ~set(AX1,'WrtProfileApply',1)
        desc = 'TIFFComp Error: Color profile cannot be applied.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    % Embed the color profile to the pixel intensities
    if ~set(AX1,'WrtProfileEmbed',1)
        desc = 'TIFFComp Error: Color profile cannot be applied.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end

    if ~set(AX1,'InputLeft',Left);
        desc = 'TIFFComp Error: InputLeft cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    if ~set(AX1,'InputTop',Top);
        desc = 'TIFFComp Error: InputTop cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    % Get WSI information
    WSIdata = get(AX1);
    
    % If InputWidth=0, then extract the whole width.
    if InputWidth==0
        InputWidth = WSIdata.InputWidth;
    end
    % If InputHeight=0, then extract the whole height.
    if InputHeight==0
        InputHeight = WSIdata.InputHeight;
    end
    
    if ~set(AX1,'InputHeight',InputHeight);
        desc = 'TIFFComp Error: InputHeight cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    if ~set(AX1,'InputWidth',InputWidth);
        desc = 'TIFFComp Error: InputWidth cannot be assigned.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end

    if OutputWidth~=0 && OutputHeight~=0
        % eeDAP considers the rescaling to occur before rotation.
        % TIFFComp considers the rescaling to occur after rotation.
        % Consequently, we set TIFFComp OutputWidth to eeDAP OutputHeight
        if ~set(AX1,'OutputWidth',OutputHeight)
            desc = 'TIFFComp Error: OutputWidth cannot be assigned.';
            disp(desc)
            dbstack()
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            keyboard
            return
        end
        
        % eeDAP considers the rescaling to occur before rotation.
        % TIFFComp considers the rescaling to occur after rotation.
        % Consequently, we set TIFFComp OutputHeight to eeDAP OutputWidth
        if ~set(AX1,'OutputHeight',OutputWidth)
            desc = 'TIFFComp Error: OutputHeight cannot be assigned.';
            disp(desc)
            dbstack()
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            keyboard
            return
        end
        
        % Note: If aspect ratio of OutputWidth and OutputHeight does not
        % exactly match aspect ratio of the extraction region, TIFFComp
        % will automatically set OutputHeight so that the aspect ratios are
        % approximately equal
        % Note: Because TIFFComp object property FixAspect=1
    end
    
    % If OutputWidth=0 and OutputHeight=0, then TIFFComp sets
    % OutputWidth and OutputHeight to InputWidth and InputHeight by default
    if OutputWidth==0 && OutputHeight==0
        % The OutputWidth and OutputHeight are set below to avoid
        % entering if statements that follow.
        OutputWidth = InputWidth;
        OutputHeight = InputHeight;
    end
    
    if OutputWidth==0
        % When eeDAP OutputWidth=0, we only set eeDAP OutputHeight.
        % TIFFComp will automatically set eeDAP OutputWidth so that the
        % aspect ratios are approximately equal.
        
        % eeDAP considers the rescaling to occur before rotation.
        % TIFFComp considers the rescaling to occur after rotation.
        % Consequently, we set TIFFComp OutputWidth to eeDAP OutputHeight
        if ~set(AX1,'OutputWidth',OutputHeight)
            desc = 'TIFFComp Error: OutputWidth cannot be assigned.';
            disp(desc)
            dbstack()
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            keyboard
            return
        end
        WSIdata = get(AX1);
        OutputWidth = WSIdata.OutputHeight;
    end
    
    if OutputHeight==0
        % When eeDAP OutputHeight=0, we only set eeDAP OutputWidth.
        % TIFFComp will automatically set eeDAP OutputHeight so that the
        % aspect ratios are approximately equal.
        
        % eeDAP considers the rescaling to occur before rotation.
        % TIFFComp considers the rescaling to occur after rotation.
        % Consequently, we set TIFFComp OutputHeight to eeDAP OutputWidth
        if ~set(AX1,'OutputHeight',OutputWidth)
            desc = 'TIFFComp Error: OutputHeight cannot be assigned.';
            disp(desc)
            dbstack()
            h_errordlg = errordlg(desc,'Application error','modal');
            uiwait(h_errordlg)
            keyboard
            return
        end
        WSIdata = get(AX1);
        OutputHeight = WSIdata.OutputWidth;
    end

    %temp = 1.0;
    %temp = [0:255];
    %temp = [0:255]/255;
    %temp = uint8([0:255]);
    %temp = int16([0:255]);
    %temp = int64([0:255]);
    %temp = uint8(gamma*255)
    %temp = uint8(gamma);
    
    %gamma_char = '0.1';
    %gamma_char = char(temp);
    %gamma_char = num2str(temp);
    
    %AX1.SetGamma(gamma_char, gamma_char, gamma_char)

    % Start the extraction process
    if ~AX1.Start();
        desc = 'TIFFComp Error: Image extraction did not start.';
        disp(desc)
        dbstack()
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    % Periodically check whether the extraction finished or not
    while AX1.Active==1
        drawnow;
    end

    % Close the input file
    AX1.CloseInput();
    
    %Close the output file
    AX1.CloseOutput();
    
    % Change the colors using the rgb lut one channel at a time
    %
    x = imread(OutputFile);
    x(x<=0) = 1;
    rgb_lut_channel = rgb_lut(:,1);
    x(:,:,1) = rgb_lut_channel(x(:,:,1));
    rgb_lut_channel = rgb_lut(:,2);
    x(:,:,2) = rgb_lut_channel(x(:,:,2));
    rgb_lut_channel = rgb_lut(:,3);
    x(:,:,3) = rgb_lut_channel(x(:,:,3));
    imwrite(x, OutputFile, 'tif');
    
    %The following are used to create the rgb_lut files (by hand)
    %list_output = imadjust(uint8(0:255), [0;1], [], 1.0/1.8);
    %list_output = uint8(0:255); identity
    
    success = 1;
    
catch ME
    error_show(ME)
end
end
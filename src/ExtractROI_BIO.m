
%  ##########################################################################
%% ########################## EXTRACT ROI ###################################
%  ##########################################################################
function success = ExtractROI_BIO(...
    wsi_info,...                 % WSI information
    InputFile,...           % WSI file name full and absolute path
    OutputFile, ...         % Output file name with full and absolute path
    Left,...                % Left coordinate of region to extract
    Top, ...                % Right coordinate of region to extract
    InputWidth,...          % Width of region to extract
    InputHeight, ...        % Height of region to extract
    OutputWidth,...         % Width to rescale extracted region
    OutputHeight,...        % Height to rescale extracted region
    RotateWSI,...           % Slide label position relative to the microscope user (hours on a clock, 3,6,9,12)
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
    % the aspect ratio of the
    % output image is the same as that of the input image (approximately)
    %
    % If OutputWidth=0 and OutputHeight=0, then OutputWidth and OutputHeight
    % are set to InputWidth and InputHeight
    %
    % Note: If aspect ratio of OutputWidth and OutputHeight does not
    % exactly match aspect ratio of the extraction region, it
    % will automatically set OutputHeight so that aspect ratios are
    % approximately equal
    %
    % When eeDAP OutputHeight=0, we only set eeDAP OutputWidth.
    % ot will automatically set eeDAP OutputHeight so that aspect ratios
    % are approximately equal
    %
    % When eeDAP OutputWidth=0, we only set eeDAP OutputHeight.
    % it will automatically set eeDAP OutputWidth to maintain equivalent
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

    if (~isdeployed)
        addpath('bfmatlab');
    end
    
    % ExtractROI is only being used to link to get WSI information
    if strcmp(OutputFile,'none')
        return
    end
    


    % Get WSI information
    WSI_data = wsi_info.WSI_data;
    
    % If InputWidth=0, then extract the whole width.
    if InputWidth==0
        InputWidth = WSI_data.InputWidth;
    end
    % If InputHeight=0, then extract the whole height.
    if InputHeight==0
        InputHeight = WSI_data.InputHeight;
    end  
    % If OutputWidth=0 and OutputHeight=0, then sets
    % OutputWidth and OutputHeight to InputWidth and InputHeight by default
    if OutputWidth==0 && OutputHeight==0
        % The OutputWidth and OutputHeight are set below to avoid
        % entering if statements that follow.
        OutputWidth = InputWidth;
        OutputHeight = InputHeight;
    end
    
    if OutputWidth==0
        % When eeDAP OutputWidth=0, we only set eeDAP OutputHeight.
        % Automatically set eeDAP OutputWidth so that the
        % aspect ratios are approximately equal.
        OutputWidth = InputWidth*OutputHeight/InputHeight;
    end
    
    if OutputHeight==0
        % When eeDAP OutputHeight=0, we only set eeDAP OutputWidth.
        % Automatically set eeDAP OutputHeight so that the
        % aspect ratios are approximately equal.
        OutputHeight = InputHeight*OutputWidth/InputWidth;
    end
        
    WSI_data = wsi_info.WSI_data;
    full_wsi_w = wsi_info.wsi_w(1);
    full_wsi_h = wsi_info.wsi_h(1);
    if Left<=0    
        desc = ['Error in ExtractROI: ',...
            'Left side goes outside of the WSI '];
        display(desc);
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    if Top<=0
        desc = ['Error in ExtractROI: ',...
            'Top side goes outside of the WSI '];
        display(desc);
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
   
    
    if Left+InputWidth-1> full_wsi_w
        desc = ['Error in ExtractROI: ',...
            'Right side goes outside of the WSI '];
        display(desc);
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
    
    if Top+InputHeight-1> full_wsi_h
        desc = ['Error in ExtractROI: ',...
            'Bottom side goes outside of the WSI '];
        display(desc);
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)
        keyboard
        return
    end
     
    full_output_w = full_wsi_w * OutputWidth / InputWidth;
    width_different = wsi_info.wsi_w - full_output_w;
    [closest_num,closest_level] = min(abs(width_different));
    WSI_data.setSeries(closest_level-1);
    use_wsi_w = wsi_info.wsi_w(closest_level);
 %   use_wsi_h = wsi_h(closest_level);
    New_Top = ceil(Top * use_wsi_w / full_wsi_w);
    New_Left = ceil(Left * use_wsi_w / full_wsi_w);    
    New_InputWidth = floor(InputWidth * use_wsi_w / full_wsi_w);
    New_InputHeight = floor(InputHeight * use_wsi_w / full_wsi_w);
    temp_output(:,:,1) = bfGetPlane(WSI_data,1,New_Left,New_Top,New_InputWidth,New_InputHeight);
    temp_output(:,:,2) = bfGetPlane(WSI_data,2,New_Left,New_Top,New_InputWidth,New_InputHeight);
    temp_output(:,:,3) = bfGetPlane(WSI_data,3,New_Left,New_Top,New_InputWidth,New_InputHeight);
    
    output = imrotate(temp_output,RotateWSI);
    
    if RotateWSI == 0 || RotateWSI== 180       
        output = imresize(output,floor([OutputHeight,OutputWidth]));
    else
        output = imresize(output,floor([OutputWidth,OutputHeight]));
    end
   

    
    % Change the colors using the rgb lut one channel at a time
    %
    output(output<=0) = 1;
    rgb_lut_channel = rgb_lut(:,1);
    output(:,:,1) = rgb_lut_channel(output(:,:,1));
    rgb_lut_channel = rgb_lut(:,2);
    output(:,:,2) = rgb_lut_channel(output(:,:,2));
    rgb_lut_channel = rgb_lut(:,3);
    output(:,:,3) = rgb_lut_channel(output(:,:,3));
    
%     % get icc file
%     iccFile = iccread(InputFile);
%     outprof = iccread('sRGB.icm');
%     C = makecform('icc', iccFile, outprof);
%     output = applycform(output, C);
    
    
    imwrite(output, OutputFile, 'tif');
    
    %The following are used to create the rgb_lut files (by hand)
    %list_output = imadjust(uint8(0:255), [0;1], [], 1.0/1.8);
    %list_output = uint8(0:255); identity
    
    success = 1;
    
catch ME
    error_show(ME)
end
end
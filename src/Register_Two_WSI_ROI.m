%  ##########################################################################
%% ############################ REGISTER ROI ################################
%  ##########################################################################
function Register_Two_WSI_ROI(handles)
try
    %--------------------------------------------------------------------------
    % This function registers the stage and the WSI during Stage_Allighment
    %--------------------------------------------------------------------------
    % WSI A
    WSI_A = handles.WSI_A;
    % Extract ROI and write to disk
    ExtractROI_BIO(WSI_A,...
        WSI_A.fullname,...
        WSI_A.roi_file,...
        WSI_A.roi_left,...
        WSI_A.roi_top,...
        WSI_A.roi_extract_w,...
        WSI_A.roi_extract_h,...
        WSI_A.roi_h,...
        WSI_A.roi_w,...
        WSI_A.RotateWSI,...
        WSI_A.rgb_lut);
    if  WSI_A.RotateWSI == 0 || WSI_A.RotateWSI== 180       
        WSI_A.roi_w = floor(WSI_A.roi_w);           %3,9 o'clock
        WSI_A.roi_h = floor(WSI_A.roi_h);
    else
        temp = WSI_A.roi_w;
        WSI_A.roi_w = floor(WSI_A.roi_h);           %6,12 o'clock
        WSI_A.roi_h = floor(temp);
    end
    % Prepare to perform normalized cross correlation
    
    
    
    % WSI B
    WSI_B = handles.WSI_B;
    % Extract ROI and write to disk
    ExtractROI_BIO(WSI_B,...
        WSI_B.fullname,...
        WSI_B.roi_file,...
        WSI_B.roi_left,...
        WSI_B.roi_top,...
        WSI_B.roi_extract_w,...
        WSI_B.roi_extract_h,...
        WSI_B.roi_h,...
        WSI_B.roi_w,...
        WSI_B.RotateWSI,...
        WSI_B.rgb_lut);
    if  WSI_B.RotateWSI == 0 || WSI_B.RotateWSI== 180       
        WSI_B.roi_w = floor(WSI_B.roi_w);           %3,9 o'clock
        WSI_B.roi_h = floor(WSI_B.roi_h);
    else
        temp = WSI_B.roi_w;
        WSI_B.roi_w = floor(WSI_B.roi_h);           %6,12 o'clock
        WSI_B.roi_h = floor(temp);
    end
    
    
    
    
    
    % Prepare to perform normalized cross correlation
    roi_A_image = imread(WSI_A.roi_file);
    roi_B_image = imread(WSI_B.roi_file);
    [roi_A_h, roi_A_w] = size(roi_A_image(:,:,1));
    [roi_B_h, roi_B_w] = size(roi_B_image(:,:,1));
    
  

    % Cross correlate the stage and wsi images
    channel=2;
    CXC=normxcorr2(roi_A_image(:,:,channel),roi_B_image(:,:,channel));
    
    % CXC is padded by t_size(1)/2
    % (half the template width) on the left and right
    % CXC is padded by t_size(2)/2
    % (half the template height) on top and bottom
    [~, imax] = max(abs(CXC(:)));
    [ypeak, xpeak] = ind2sub(size(CXC),imax(1));
    xoffset = ceil(roi_B_w /2 + roi_A_w/2 - xpeak);
    yoffset = ceil(roi_B_h /2 + roi_A_h/2 - ypeak);
    
    % Convert from roi,cam cordinates to WSI coordinates
    % Notes:
    % eeDAP images are WSI images rotated 90 degree clockwise
    % Rotate = Transpose then reverse YDir
    switch WSI_B.RotateWSI
        case 270          % 6 o'clock
    X1_offset = yoffset*handles.WSIA_2_WSIB;
    Y1_offset = -xoffset*handles.WSIA_2_WSIB;
        case 90          % 12 o'clock
    X1_offset = -yoffset*handles.WSIA_2_WSIB;
    Y1_offset = xoffset*handles.WSIA_2_WSIB;
        case 0          % 3 o'clock
    X1_offset = xoffset*handles.WSIA_2_WSIB;
    Y1_offset = yoffset*handles.WSIA_2_WSIB;
        case 180         % 9 o'clock
    X1_offset = -xoffset*handles.WSIA_2_WSIB;
    Y1_offset = -yoffset*handles.WSIA_2_WSIB;
    end
            
    % Add the offset to the roi_position
%    roi_x0 =  current.wsi_positions(1) - X1_offset;
%    roi_y0 =  current.wsi_positions(2) - Y1_offset;
    WSI_B.roi_x0 = WSI_B.roi_x0 - X1_offset;
    WSI_B.roi_y0 = WSI_B.roi_y0 - Y1_offset;
    WSI_B.roi_w = roi_A_w;
    WSI_B.roi_h = roi_A_h;
    WSI_B.roi_extract_w = WSI_B.roi_h*handles.WSIA_2_WSIB;
    WSI_B.roi_extract_h = WSI_B.roi_w*handles.WSIA_2_WSIB;
    % Convert from center of patch to the top left corner (origin)
    WSI_B.roi_left = WSI_B.roi_x0 - WSI_B.roi_extract_w/2;
    WSI_B.roi_top = WSI_B.roi_y0 - WSI_B.roi_extract_h/2;
    
    % Extraction of the low-resolution WSI Patch 1
    ExtractROI_BIO(WSI_B,...
        WSI_B.fullname,...
        WSI_B.roi_file,...
        WSI_B.roi_left,...
        WSI_B.roi_top,...
        WSI_B.roi_extract_w,...
        WSI_B.roi_extract_h,...
        WSI_B.roi_h,...
        WSI_B.roi_w,...
        WSI_B.RotateWSI,...
        WSI_B.rgb_lut);
    
    % Save ROI properties in current structure
    if WSI_B.RotateWSI == 0 || WSI_B.RotateWSI== 180       
        WSI_B.roi_w = floor(WSI_B.roi_w);           %3,9 o'clock
        WSI_B.roi_h = floor(WSI_B.roi_h);
    else
        temp = WSI_B.roi_w;
        WSI_B.roi_w = floor(WSI_B.roi_h);           %6,12 o'clock
        WSI_B.roi_h = floor(temp);
    end
    handles.registration_good = 0;
    handles.WSI_A = WSI_A;
    handles.WSI_B = WSI_B;
    
    guidata(handles.WSIregistration, handles);
    
    % Read the two ROIs into memory
    roi_A_image = imread(WSI_A.roi_file);
    WSI_A.roi_image = roi_A_image;
    roi_B_image = imread(WSI_B.roi_file);
    WSI_B.roi_image = roi_B_image;  
    
    % Show the camera image and the corresponding ROI from registration
    position = get(0,'ScreenSize');
    position = [position(3)*.25, position(4)*.5, position(3)*.5, position(4)*.25];
%     figure(...
%         'NumberTitle','off',...
%         'Name',['Registration Position ',num2str(position_i)],...
%         'MenuBar','none',...
%         'Position',position)
    figure(...
        'NumberTitle','off',...
        'Name','Registration',...
        'MenuBar','none',...
        'Position',position)
    imshow([roi_A_image, roi_B_image]);

    % Check if user likes the registration result
    set(0,'Units','characters')
    position = get(0,'ScreenSize');
    set(0,'Units','pixels');
    
    position = [position(3)*.5-25, position(4)*.5, 60, 4];
    handles.h_registration_check = figure(...
        'NumberTitle','off',...
        'Name','Check Registration',...
        'MenuBar','none',...
        'Units','characters',...
        'Position',position);

    uicontrol(...
        'Style','pushbutton',...
        'String', 'Registration is Good!',...
        'Units', 'characters',...
        'Position', [position(3)/2-25,1,25,2],...
        'Callback', {@registration_good, handles});
    uicontrol(...
        'Style','pushbutton',...
        'String', 'Repeat the registration!',...
        'Units', 'characters',...
        'Position', [position(3)/2,1,25,2],...
        'Callback', {@registration_bad, handles});

    % Wait until the registration check figure is closed
    uiwait(handles.h_registration_check)

catch ME
    error_show(ME)
end

end

function registration_good(hObject, eventdata, handles)

    handles = guidata(handles.WSIregistration);
    handles.registration_good = 1;
    guidata(handles.WSIregistration, handles);

    close gcf

end

function registration_bad(hObject, eventdata, handles)
    delete(handles.h_registration_check);

    close gcf

end


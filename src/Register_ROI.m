%  ##########################################################################
%% ############################ REGISTER ROI ################################
%  ##########################################################################
function Register_ROI(handles)
try
    %--------------------------------------------------------------------------
    % This function registers the stage and the WSI during Stage_Allighment
    %--------------------------------------------------------------------------

    current = handles.current;
    position_i = current.position_i;
    settings=handles.myData.settings;
    % Extract ROI and write to disk
    ExtractROI_BIO(current.wsi_info,...
        current.wsi_info.fullname,...
        current.roi_file,...
        current.roi_left,...
        current.roi_top,...
        current.roi_extract_w,...
        current.roi_extract_h,...
        current.roi_h,...
        current.roi_w,...
        handles.myData.settings.RotateWSI,...
        current.wsi_info.rgb_lut);
    if settings.RotateWSI == 0 || settings.RotateWSI== 180       
        current.roi_w = floor(current.roi_w);           %3,9 o'clock
        current.roi_h = floor(current.roi_h);
    else
        temp = current.roi_w;
        current.roi_w = floor(current.roi_h);           %6,12 o'clock
        current.roi_h = floor(temp);
    end
    % Prepare to perform normalized cross correlation
    roi_image = imread(current.roi_file);
    cam_image = current.cam_image;
    [roi_h, roi_w] = size(roi_image(:,:,1));
    [cam_h, cam_w] = size(cam_image(:,:,1));
    
    % sample code for treating coordinates of normxcorr2 result
%     if 0
%         onion = imread('onion.png');
%         peppers = imread('peppers.png');
%         figure('Name','onion'), imshow(onion)
%         figure('Name','peppers'), imshow(peppers)
%         c = normxcorr2(onion(:,:,1),peppers(:,:,1));
%         
%         % offset found by correlation
%         [max_c, imax] = max(abs(c(:)));
%         [ypeak, xpeak] = ind2sub(size(c),imax(1));
%         % extract the highest correlation patch
%         % we subtract size(onion)/2 to account for padding from normxcorr2
%         % and another size(onion)/2 to account for the patch (center -> corner)
%         xbegin = xpeak-size(onion,2) + 1;
%         ybegin = ypeak-size(onion,1) + 1;
%         xend   = xpeak;
%         yend   = ypeak;
%         extracted_onion = peppers(ybegin:yend, xbegin:xend, :);
%         figure('Name','extracted_onion'), imshow(extracted_onion);
%         
%         % extract region from peppers and compare to onion
%         extracted_onion = peppers(ybegin:yend,xbegin:xend,:);
%         if isequal(onion,extracted_onion)
%             disp('onion.png was extracted from peppers.png')
%         end
%     end

    % Cross correlate the stage and wsi images
    channel=2;
    CXC=normxcorr2(cam_image(:,:,channel),roi_image(:,:,channel));
    
    % CXC is padded by t_size(1)/2
    % (half the template width) on the left and right
    % CXC is padded by t_size(2)/2
    % (half the template height) on top and bottom
    [~, imax] = max(abs(CXC(:)));
    [ypeak, xpeak] = ind2sub(size(CXC),imax(1));
    xoffset = ceil(roi_w/2 + cam_w/2 - xpeak);
    yoffset = ceil(roi_h/2 + cam_h/2 - ypeak);
    
    % Convert from roi,cam cordinates to WSI coordinates
    % Notes:
    % eeDAP images are WSI images rotated 90 degree clockwise
    % Rotate = Transpose then reverse YDir
    RotateWSI = settings.RotateWSI;
    switch RotateWSI
        case 270          % 6 o'clock
    X1_offset = yoffset*current.cam2scan;
    Y1_offset = -xoffset*current.cam2scan;
        case 90          % 12 o'clock
    X1_offset = -yoffset*current.cam2scan;
    Y1_offset = xoffset*current.cam2scan;
        case 0          % 3 o'clock
    X1_offset = xoffset*current.cam2scan;
    Y1_offset = yoffset*current.cam2scan;
        case 180         % 9 o'clock
    X1_offset = -xoffset*current.cam2scan;
    Y1_offset = -yoffset*current.cam2scan;
    end
            
    % Add the offset to the roi_position
%    roi_x0 =  current.wsi_positions(1) - X1_offset;
%    roi_y0 =  current.wsi_positions(2) - Y1_offset;
    current.roi_x0 = current.roi_x0 - X1_offset;
    current.roi_y0 = current.roi_y0 - Y1_offset;
    current.roi_w = cam_w;
    current.roi_h = cam_h;
    current.roi_extract_w = current.roi_h*current.cam2scan;
    current.roi_extract_h = current.roi_w*current.cam2scan;
    % Convert from center of patch to the top left corner (origin)
    current.roi_left = current.roi_x0 - current.roi_extract_w/2;
    current.roi_top = current.roi_y0 - current.roi_extract_h/2;
    
    % Extraction of the low-resolution WSI Patch 1
    ExtractROI_BIO(current.wsi_info,...
        current.wsi_info.fullname,...
        current.roi_file,...
        current.roi_left,...
        current.roi_top,...
        current.roi_extract_w,...
        current.roi_extract_h,...
        current.roi_h,...
        current.roi_w,...
        handles.myData.settings.RotateWSI,...
        current.wsi_info.rgb_lut);
    
    % Save ROI properties in current structure
    if settings.RotateWSI == 0 || settings.RotateWSI== 180       
        current.roi_w = floor(current.roi_w);           %3,9 o'clock
        current.roi_h = floor(current.roi_h);
    else
        temp = current.roi_w;
        current.roi_w = floor(current.roi_h);           %6,12 o'clock
        current.roi_h = floor(temp);
    end
    current.registration_good = 0;
    handles.current = current;
    if isfield(handles,'Stage_Allighment')
        guidata(handles.Stage_Allighment,handles);
    end
    
    if isfield(handles,'Registration_after_work')
        guidata(handles.Registration_after_work,handles);
    end
    
    % Read the ROI into memory
    roi_image = imread(current.roi_file);
    current.roi_image = roi_image;

    % Show the camera image and the corresponding ROI from registration
    position = get(0,'ScreenSize');
    position = [position(3)*.25, position(4)*.5, position(3)*.5, position(4)*.25];
    figure(...
        'NumberTitle','off',...
        'Name',['Registration Position ',num2str(position_i)],...
        'MenuBar','none',...
        'Position',position)
    imshow([cam_image, roi_image]);

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
    if isfield(handles,'Stage_Allighment')
        handles = guidata(handles.Stage_Allighment);
        handles.current.registration_good = 1;
        guidata(handles.Stage_Allighment, handles);
    end
    
    if isfield(handles,'Registration_after_work')
        handles = guidata(handles.Registration_after_work);
        handles.current.registration_good = 1;
        guidata(handles.Registration_after_work, handles);
    end


close gcf

end

function registration_bad(hObject, eventdata, handles)
    delete(handles.h_registration_check);

    close gcf

end


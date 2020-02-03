function task_refine_registration(hObj)
%description
%This task is used to refine global registration during study.
%It cannot be called in input file. 
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        case {'Refine_Register_Button_Callback', ...
                'ResumeButtonPressed'} % Initialize task elements
                
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
            
            set(handles.Fast_Register_Button, 'Enable', 'off');
            set(handles.Best_Register_Button, 'Enable', 'off');
            set(handles.Refine_Register_Button, 'Enable', 'off');
            % Guide text 
            handles.guideText = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [0.3,0.55,0.4,0.1], ...
                'Style', 'Text', ...
                'Tag', 'guideText', ...
                'String', 'Use high magnification lens, and joystick to move the center of WSI to the center of eyepiece (camera) and click Refine Registration button', ...
                'Tag', 'textY');
            
            
            % Refine registration button. 
            handles.refineReg = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', 16, ...
                    'Units', 'normalized', ...
                    'ForegroundColor',  handles.myData.settings.FG_color, ...
                    'BackgroundColor',  handles.myData.settings.BG_color, ...
                    'Position',[0.4,0.3,0.2,0.2], ...
                    'Style', 'pushbutton', ...
                    'Tag', 'refineReg', ...
                    'enable','on',...
                    'String', 'Refine Registation',...
                    'Callback',@refineReg_Callback);

            
            % Button to swtich between high and low magnificantion WSI 
            handles.switchWSI = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', 16, ...
                    'Units', 'normalized', ...
                    'ForegroundColor',  handles.myData.settings.FG_color, ...
                    'BackgroundColor',  handles.myData.settings.BG_color, ...
                    'Position',[0.8,0.8,0.2,0.2], ...
                    'Style', 'pushbutton', ...
                    'Tag', 'switchWSI', ...
                    'enable','on',...
                    'String', 'switch to low magnification WSI',...
                    'Callback',@switchWSI_Callback);   
            

        case {'NextButtonPressed',...
                'PauseButtonPressed'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.refineReg);
            delete(handles.switchWSI);
            delete(handles.guideText);            
            handles = rmfield(handles, 'refineReg');
            handles = rmfield(handles, 'switchWSI');
            handles = rmfield(handles, 'guideText');
            handles.myData.iter = handles.myData.iter-1;    %go back to previous task
            set(handles.Fast_Register_Button, 'Enable', 'on');
            set(handles.Best_Register_Button, 'Enable', 'on');
            set(handles.Refine_Register_Button, 'Enable', 'on');
            guidata(handles.GUI, handles); 

    end
% 
%     % Update handles.myData.taskinfo and pack
%     myData.taskinfo = taskinfo;
%     handles.myData = myData;
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

function refineReg_Callback (hObj, eventdata)
    handles = guidata(hObj);
    myData = handles.myData;

    % snap a picture: cam_image
    cam_image = camera_take_image(handles.cam);
    cam_w = myData.settings.cam_w;
    cam_h = myData.settings.cam_h;
    cam_roi_w = 300;
    cam_roi_h = 300;
    % Extract a central ROI of the camera image and map to gray levels
    x = cam_w/2 - ceil(cam_roi_w/2-1) : cam_w/2 + floor(cam_roi_w/2);
    y = cam_h/2 - ceil(cam_roi_h/2-1):cam_h/2 + floor(cam_roi_h/2);
    cam_image = rgb2gray(cam_image(y,x,:));
    
    % Map roi_image into gray values
    roi_image = rgb2gray(handles.ImX);
    [temp_h,temp_w] = size(roi_image);
    if temp_h>temp_w
        square_h = ceil(temp_h/2)-ceil(temp_w/2-1):ceil(temp_h/2)+floor(temp_w/2-1);
        roi_image = roi_image(square_h,:);
    elseif temp_h<temp_w
        square_w = ceil(temp_w/2)-ceil(temp_h/2-1):ceil(temp_w/2)+floor(temp_h/2-1);
        roi_image = roi_image(:,square_w);
    else 
        roi_image = roi_image;
    end
    % Rescale roi_image to cam_image
    cam2scan = handles.myData.settings.cam_hres2scan(myData.taskinfo.slot);
    scan2cam = 1.0/cam2scan;
    roi_image = imresize(roi_image, scan2cam);
    [roi_h, roi_w] = size(roi_image);    

    % Registration: Cross correlate the stage and wsi images
    if cam_roi_w > roi_w && cam_roi_h > roi_h
        CXC=normxcorr2(roi_image,cam_image);
        order = -1;
    elseif cam_roi_w <= roi_w && cam_roi_h <= roi_h
        CXC=normxcorr2(cam_image,roi_image);
        order = 1;
    else
        display('FIX THIS ALTERNATIVE')
        keyboard
    end
    % apply pixel difference
    cam2stage = handles.myData.settings.cam_hres2stage;
    [~, imax] = max(abs(CXC(:)));
    [ypeak, xpeak] = ind2sub(size(CXC),imax(1));
    xoffset = cam2stage*(roi_w/2 + cam_roi_w/2 - xpeak);
    yoffset = cam2stage*(roi_h/2 + cam_roi_h/2 - ypeak);
    offset_roi = order*int64([xoffset, yoffset]);
    %get current stage position
    handles.myData.stage = stage_get_pos(handles.myData.stage,myData.stage.handle); 
    stage_current = int64(handles.myData.stage.Pos);
    stage_current = stage_current + offset_roi;
    % move stage to registed position
    offset_stage = int64(myData.settings.offset_stage);
    stage_new = stage_current - offset_stage;
    handles.myData.stage = stage_move(handles.myData.stage,stage_new, handles.myData.stage.handle);
    % calculate stage offset vs the stage position of the first anchor from
    % global positionm and save the offset in myData.settings.offset_reg_refine
    slot = myData.taskinfo.slot;
    myData.settings.offset_reg_refine{slot} = stage_current - int64(myData.taskinfo.Stageanchor1);
    handles.myData = myData;
    set(handles.NextButton,'Enable','on');
    guidata(hObj, handles);
end


function switchWSI_Callback(hObj, eventdata)
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;

    if taskinfo.highMag == 1 
       taskinfo.ROIname = taskinfo.lowMagName;
       set(handles.switchWSI,'String','switch to high magnification WSI');
       set(handles.guideText,'String','Please switch to high magnification WSI and lens to do registration');
       taskinfo.highMag = 0;
       set(handles.refineReg,'Enable','off');
    else
       taskinfo.ROIname = taskinfo.highMagName;
       set(handles.switchWSI,'String','switch to low magnification WSI');
       set(handles.guideText,'String','Use joystick to move the center of WSI to the center of eyepiece (camera) and click Refine Registration button');
       taskinfo.highMag = 1;
       set(handles.refineReg,'Enable','on');
    end
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);
    taskimage_load(hObj);
end


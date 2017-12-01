function task_get_WSI_position(hObj)
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            handles = guidata(hObj);            
            desc = taskinfo.desc;          
            taskinfo.task  = char(desc{1});
            taskinfo.id = char(desc{2});
            taskinfo.order = str2double(desc{3});
            taskinfo.slot = str2double(desc{4});
            taskinfo.roi_w = str2double(desc{5});
            taskinfo.roi_h = str2double(desc{6});
            taskinfo.img_w = str2double(desc{7});
            taskinfo.img_h = str2double(desc{8});
            taskinfo.text  = char(desc{9});
            taskinfo.description = char(desc{10});
            taskinfo.dontextract = 1;
            taskinfo.rotateback = 0;
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            % Load the image
           % taskimage_load(hObj);
            if strcmp(myData.mode_desc,'Digital')
                billboard(handles, {'\bfThis task only work'; 'in MicroRT mode'});
                set(handles.NextButton, 'Enable', 'on');
            else
                billboard(handles, {'\bfClick "Get WSI ROI Position"'; 'Button To Show Images'});
                

                

                  % Static text question for count task
                 handles.getPosition = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', 16, ...
                    'Units', 'normalized', ...
                    'ForegroundColor',  handles.myData.settings.FG_color, ...
                    'BackgroundColor',  handles.myData.settings.BG_color, ...
                    'Position',[0.4, 0.4, .2, .2], ...
                    'Style', 'pushbutton', ...
                    'Tag', 'editvalue', ...
                    'enable','on',...
                    'String', 'Get WSI ROI Position',...
                    'Callback',@WSI_Position_Callback);  

                  handles.registerAndReextract = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', 16, ...
                    'Units', 'normalized', ...
                    'ForegroundColor',  handles.myData.settings.FG_color, ...
                    'BackgroundColor',  handles.myData.settings.BG_color, ...
                    'Position',[0.8,0.8,0.2,0.2], ...
                    'Style', 'pushbutton', ...
                    'Tag', 'editvalue', ...
                    'enable','off',...
                    'String', 'Refine Registation',...
                    'Callback',@RegisterAndReextract_Callback);


                handles.textWSI = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', handles.myData.settings.FontSize, ...
                    'Units', 'normalized', ...
                    'HorizontalAlignment', 'left', ...
                    'ForegroundColor', handles.myData.settings.FG_color, ...
                    'BackgroundColor', handles.myData.settings.BG_color, ...
                    'Position', [0.4,0.25,0.1,0.1], ...
                    'Style', 'Text', ...
                    'String', 'WSI:', ...
                    'Tag', 'textWSI');

                handles.textWSIX = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', handles.myData.settings.FontSize, ...
                    'Units', 'normalized', ...
                    'HorizontalAlignment', 'left', ...
                    'ForegroundColor', handles.myData.settings.FG_color, ...
                    'BackgroundColor', handles.myData.settings.BG_color, ...
                    'Position', [0.45,0.25,0.1,0.1], ...
                    'Style', 'Text', ...
                    'String', 'not set', ...
                    'Tag', 'textWSIX');

                handles.textWSIY = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', handles.myData.settings.FontSize, ...
                    'Units', 'normalized', ...
                    'HorizontalAlignment', 'left', ...
                    'ForegroundColor', handles.myData.settings.FG_color, ...
                    'BackgroundColor', handles.myData.settings.BG_color, ...
                    'Position', [0.5,0.25,0.1,0.1], ...
                    'Style', 'Text', ...
                    'String', 'not set', ...
                    'Tag', 'textWSIY');
            
            end 
        case {'NextButtonPressed', ...
                'PauseButtonPressed'} % Clean up the task elements

            % Hide image and management buttons
            if strcmp(myData.mode_desc,'Digital')
                taskmgt_default(handles, 'off');
            else
                taskmgt_default(handles, 'off');
                handles = guidata(hObj);
                set(handles.iH,'visible','off');
                set(handles.ImageAxes,'visible','off');
                delete(handles.getPosition);
                delete(handles.registerAndReextract);
                delete(handles.textWSI);
                delete(handles.textWSIX);
                delete(handles.textWSIY);
                handles = rmfield(handles, 'getPosition');
                handles = rmfield(handles, 'registerAndReextract');
                handles = rmfield(handles, 'textWSI');
                handles = rmfield(handles, 'textWSIX');
                handles = rmfield(handles, 'textWSIY');
            end
         case 'Backbutton_Callback' % Clean up the task elements

            % Hide image and management buttons
            if strcmp(myData.mode_desc,'Digital')
                taskmgt_default(handles, 'off');
            else
                taskmgt_default(handles, 'off');
                handles = guidata(hObj);
                delete(handles.getPosition);
                delete(handles.registerAndReextract);
                delete(handles.textWSI);
                delete(handles.textWSIX);
                delete(handles.textWSIY);
                handles = rmfield(handles, 'getPosition');
                handles = rmfield(handles, 'registerAndReextract');
                handles = rmfield(handles, 'textWSI');
                handles = rmfield(handles, 'textWSIX');
                handles = rmfield(handles, 'textWSIY');
            end
        %    taskimage_archive(handles);
        case 'exportOutput' % export current task information and reuslt
            if taskinfo.currentWorking ==1&strcmp(myData.mode_desc,'MicroRT') % write finish task in current study
                fprintf(myData.fid, [...
                    taskinfo.task, ',', ...
                    taskinfo.id, ',', ...
                    num2str(taskinfo.order), ',', ...
                    num2str(taskinfo.slot), ',',...
                    num2str(taskinfo.roi_w), ',', ...
                    num2str(taskinfo.roi_h), ',', ...
                    num2str(taskinfo.img_w), ',', ...
                    num2str(taskinfo.img_h), ',', ...
                    taskinfo.text, ',', ...
                    num2str(taskinfo.duration), ',', ...
                    num2str(taskinfo.wsi_roi_position(1)), ',', ...
                    num2str(taskinfo.wsi_roi_position(2))]);
            elseif taskinfo.currentWorking ==0 % write undone task
                fprintf(myData.fid, [...
                    taskinfo.task, ',', ...
                    taskinfo.id, ',', ...
                    num2str(taskinfo.order), ',', ...
                    num2str(taskinfo.slot), ',', ...
                    num2str(taskinfo.roi_w), ',', ...
                    num2str(taskinfo.roi_h), ',', ...
                    num2str(taskinfo.img_w), ',', ...
                    num2str(taskinfo.img_h), ',', ...
                    taskinfo.text]);
            else                               % write done task from previous study
                desc = taskinfo.desc;
                for i = 1 : length(desc)-1
                    fprintf(myData.fid,[desc{i},',']);
                end
                fprintf(myData.fid,[desc{length(desc)}]);
            end            
            fprintf(myData.fid,'\r\n');
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI, handles);           
            
    end

    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

function WSI_Position_Callback (hObj, eventdata)
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    handles.myData.stage = stage_get_pos(handles.myData.stage,myData.stage.handle); 
    temp = handles.myData.stage.Pos;
    stage_x0 = temp(1);
    stage_y0 = temp(2);
    stagedata = myData.stagedata{taskinfo.slot};

    slot = taskinfo.slot;
    wsi_info = handles.myData.wsi_files{slot};
    WSIfile=wsi_info.fullname;
    offset = int64(myData.settings.offset_stage);
    stage_new = double(transpose([stage_x0, stage_y0]+offset));
    wsi_0 = transpose(stagedata.wsi_positions(1,:));                
    stage_M = stagedata.stage_M;
    wsi_M = stagedata.wsi_M;
    stage_0 = transpose(stagedata.stage_positions(1,:));
    temp = stage_new - stage_0;
    % Map to standard coordinate plane
    temp = inv(stage_M) * temp;
    % Map to WSI coordinates
    temp = wsi_M * temp;
    % Shift to unset stage reference as origin
    wsi_new = int64(temp + wsi_0);
    % offset_stage was determined during stage allignment
    % it compensates for any misalignment between the eyepiece
    % cener and the reticle center in stage coordinates

    ROIname = [handles.myData.task_images_dir, taskinfo.id, '.tif'];
    taskinfo.ROIname = ROIname;
    
    Left = double(wsi_new(1) - (taskinfo.roi_w/2));
    Top = double(wsi_new(2) - (taskinfo.roi_h/2));
    success = ExtractROI_BIO(wsi_info, WSIfile, ROIname,...
                Left, Top, taskinfo.roi_w, taskinfo.roi_h,...
                taskinfo.img_w, taskinfo.img_h,...
                handles.myData.settings.RotateWSI,...
                wsi_info.rgb_lut);
    set(handles.textWSIX,'String',num2str(wsi_new(1)));
    set(handles.textWSIY,'String',num2str(wsi_new(2)));
    taskinfo.wsi_roi_position = wsi_new;
    myData.taskinfo = taskinfo;
    myData.tasks_out{myData.iter} = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);
    taskimage_load(hObj);
    handles = guidata(hObj);
    set(handles.registerAndReextract,'Enable', 'on');
    set(handles.NextButton, 'Enable', 'on');
    guidata(hObj, handles);
end

function RegisterAndReextract_Callback (hObj, eventdata)
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    wsi_current = taskinfo.wsi_roi_position;
    settings = myData.settings;
    cam_w = myData.settings.cam_w;
    cam_h = myData.settings.cam_h;
%     cam_roi_w = 300 + max(abs(offset_cam));
%     cam_roi_h = 300 + max(abs(offset_cam));    
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
    
%     % Get the stage position and snap a picture: cam_image
%     handles.myData.stage = stage_get_pos(handles.myData.stage,handles.myData.stage.handle); 
%     stage_current = int64(handles.myData.stage.Pos);
%     offset_stage = int64(myData.settings.offset_stage);
%     stage_new = stage_current + offset_stage;
%     handles.myData.stage = stage_move(handles.myData.stage,stage_new,handles.myData.stage.handle);
%     handles.myData.stage = stage_get_pos(handles.myData.stage,handles.myData.stage.handle); 
%     stage_current = int64(handles.myData.stage.Pos);
    cam_image = camera_take_image(handles.cam);
    

    
    %    'GET THE ROI SIZE FROM SETTINGS cam_roi_w, cam_roi_h'
    %    keyboard
    
    % Cross correlate the stage and wsi images
    if min(roi_w,roi_h)<600
            % Extract a central ROI of the camera image and map to gray levels
        cam_roi_w = cam_w;
        cam_roi_h = cam_h;
        wsi_roi_w = min(roi_w,300);
        wsi_roi_h = min(roi_h,300);
        x_wsi = ceil(roi_w/2) - ceil(wsi_roi_w/2-1) : floor(roi_w/2) + floor(wsi_roi_w/2);
        y_wsi = ceil(roi_h/2) - ceil(wsi_roi_h/2-1) : floor(roi_h/2) + floor(wsi_roi_h/2);
        cam_image = rgb2gray(cam_image);
        roi_image = roi_image(y_wsi,x_wsi);
        CXC=normxcorr2(roi_image,cam_image);
        search_w = cam_roi_w-wsi_roi_w;
        search_h = cam_roi_h-wsi_roi_h;
        order = -1;
    else 
        cam_roi_w = 300;
        cam_roi_h = 300;    
        x = cam_w/2 - ceil(cam_roi_w/2-1) : cam_w/2 + floor(cam_roi_w/2);
        y = cam_h/2 - ceil(cam_roi_h/2-1):cam_h/2 + floor(cam_roi_h/2);
        cam_image = rgb2gray(cam_image(y,x,:));
        CXC=normxcorr2(cam_image,roi_image);
        search_w = roi_w-cam_roi_w;
        search_h = roi_h-cam_roi_h;
        order = 1;
    end
    
    % Find the offset and move the stage
    % CXC is padded by t_size(1)/2
    % (half the template width) on the left and right
    % CXC is padded by t_size(2)/2
    % (half the template height) on top and bottom
    cam2scan = handles.myData.settings.cam_hres2scan(taskinfo.slot);
    [CXC_y,CXC_x]=size(CXC);
    CXC_x_use = round(CXC_x/2) - ceil(search_w/2-1) : round(CXC_x/2) + ceil(search_w/2);
    CXC_y_use = round(CXC_y/2) - ceil(search_h/2-1) : round(CXC_y/2) + ceil(search_h/2);
    CXC=CXC(CXC_y_use,CXC_x_use);
    [~, imax] = max(CXC(:));
    [ypeak,xpeak] = ind2sub(size(CXC),imax(1));
    xoffset = cam2scan*(search_w/2 - xpeak);
    yoffset = cam2scan*(search_h/2 - ypeak);
    RotateWSI = settings.RotateWSI;
    switch RotateWSI
        case 270          % 6 o'clock
            direction = int64([1;-1]);
        case 90          % 12 o'clock
            direction = int64([-1;1]);
        case 0          % 3 o'clock
            direction = int64([-1;-1]);
        case 180         % 9 o'clock
            direction = int64([1;1]);
    end
%     offset_roi = order*int64([yoffset,-xoffset]);
%     wsi_new = wsi_current + offset_roi';
    offset_roi = order*int64([yoffset,xoffset]);
    wsi_new = wsi_current - direction.* offset_roi';
    offset_wsi = settings.cam_hres2scan(taskinfo.slot)*settings.offset_cam;
%    wsi_new = wsi_new + [-offset_wsi(2);offset_wsi(1)];
    wsi_new = wsi_new + direction.* [offset_wsi(2);offset_wsi(1)];
    
    ROIname = [handles.myData.task_images_dir, taskinfo.id, '.tif'];
    taskinfo.ROIname = ROIname;
    wsi_info = handles.myData.wsi_files{taskinfo.slot};
    WSIfile=wsi_info.fullname;
    Left = double(wsi_new(1) - (taskinfo.roi_w/2));
    Top = double(wsi_new(2) - (taskinfo.roi_h/2));
    success = ExtractROI_BIO(wsi_info, WSIfile, ROIname,...
                Left, Top, taskinfo.roi_w, taskinfo.roi_h,...
                taskinfo.img_w, taskinfo.img_h,...
                handles.myData.settings.RotateWSI,...
                wsi_info.rgb_lut);
    set(handles.textWSIX,'String',num2str(wsi_new(1)));
    set(handles.textWSIY,'String',num2str(wsi_new(2)));
    taskinfo.wsi_roi_position = wsi_new;
    myData.taskinfo = taskinfo;
    myData.tasks_out{myData.iter} = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);
    taskimage_load(hObj);
end


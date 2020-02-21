%% ############# Align the eyepiece and the camera #################
function align_eye_cam(handles) %#ok<*INUSD>
try
    st = dbstack;
    settings = handles.myData.settings;
    handles.cam = camera_open(settings.cam_kind,settings.cam_format,settings.defaultR,settings.defaultB);
    handles.cam_figure = camera_preview(handles.cam, settings);
    pos_eye = [0,0];
    pos_cam = [0,0];
    choose_skip = 0;
    % define joystickInfo
    % first: what normal using (0: default speed. 1: normal speed)
    % second: default speed
    joystickInfo = [0,0];
    set(handles.cam_figure,....
        'NumberTitle', 'off',...
        'Name', 'Register eyepiece and camera',...
        'Units', 'characters');
    position = get(handles.cam_figure, 'Position');
    position(1) = position(3)/2-32-16;
    position(2) = 2;
    position(3) = 32;
    position(4) = 2;
    position_eye = uicontrol(...
        'Parent', handles.cam_figure,...
        'Style', 'pushbutton',...
        'Units', 'characters',...
        'Position', position,...
        'String', 'Feature Centered in Eyepiece',...
        'Callback', @position_eye_callback,...
        'UserData', pos_eye...
        );
    position(1) = position(1)+32;
    position_cam = uicontrol(...
        'Parent', handles.cam_figure,...
        'Style', 'pushbutton',...
        'Units', 'characters',...
        'Position', position,...
        'String', 'Feature Centered in Camera',...
        'Callback', @position_cam_callback,...
        'UserData', pos_cam...
        );
    position(1) = position(1)+32;
    skip = uicontrol(...
        'Parent', handles.cam_figure,...
        'Style', 'pushbutton',...
        'Units', 'characters',...
        'Position', position,...
        'String', 'Use last offset',...
        'Enable', 'off',...
        'Callback', @position_skip_callback,...
        'UserData', choose_skip...
        );    
    position(1) = position(1)+50;
    joystick = uicontrol(...
        'Parent', handles.cam_figure,...
        'Style', 'pushbutton',...
        'Units', 'characters',...
        'Position', position,...
        'String', 'Slow Down Joystick',...
        'Enable', 'on',...
        'Callback', @joystick_speed_callback,...
        'UserData', joystickInfo);
    set(handles.cam_figure, 'WindowStyle', 'modal');
    if exist('offset_stage.mat')
        set(skip,'Enable','on');
    end
        while(choose_skip == 0 && (pos_eye(1) == 0 || pos_eye(2) == 0 || ...
               pos_cam(1) == 0 || pos_cam(2) == 0))
            pause(.2);
            pos_eye = get(position_cam, 'UserData');
            pos_cam = get(position_eye, 'UserData');
            choose_skip = get(skip,'UserData');
        end
    
    
    if choose_skip==1
        stage_information = load('offset_stage');
        offset_stage = getfield(stage_information,'offset_stage');
    else
        offset_stage = pos_eye - pos_cam;
    end
    save('offset_stage.mat','offset_stage');
    offset_cam = offset_stage * settings.stage2cam_hres;
    settings.offset_stage = offset_stage;
    settings.offset_cam = offset_cam;
    
    % recover joystick to default speed
    joystickInfo = get(joystick,'UserData');
    if joystickInfo(1) == 1
        handles.myData.stage = stage_set_joy_speed(handles.myData.stage,joystickInfo(2));
    end
    % Recalculate the mask
    % adjusting for the offset between camera and eyepiece
    settings.cam_mask = reticle_make_mask(...
        settings.reticleID,...
        settings.cam_pixel_size/settings.mag_cam,...
        settings.offset_cam);
    
    %     % Recalculate the mask
    %     % adjusting for the offset between camera and eyepiece
    %     settings.cam_mask = reticle_make_mask(...
    %         settings.reticleID,...
    %         settings.cam_pixel_size/settings.mag_cam,...
    %         [0,0]);
    
    %     % Recalculate the mask
    %     % adjusting for the offset between camera and eyepiece
    %     settings.cam_mask = reticle_make_mask(...
    %         settings.reticleID,...
    %         settings.cam_pixel_size/settings.mag_cam,...
    %         -settings.offset_cam);
    
    handles.myData.settings = settings;
    
    if strcmp(st(2).name, 'StartTheTestButtonPressed')
        guidata(handles.Administrator_Input_Screen, handles);
    else
        guidata(handles.GUI, handles);
    end
    
    
    % Close the camera preview window
    if handles.myData.yesno_micro==1
        close(handles.cam_figure)
        delete(handles.cam)
        clear handles.cam
        clear handles.cam_figure
    end
    
catch ME
    error_show(ME)
end

end

function position_eye_callback(hObject, eventdata) %#ok<*INUSD>
    st = dbstack;
    if strcmp(st(3).name, 'StartTheTestButtonPressed')
        handles = guidata(findobj('Tag','Administrator_Input_Screen'));
    else
        handles = guidata(findobj('Tag','GUI'));        
    end
    handles.myData.stage=stage_get_pos(handles.myData.stage);
    Pos=handles.myData.stage.Pos;
    set(hObject, 'UserData', Pos);
    
    
end

function position_cam_callback(hObject, eventdata)
    st = dbstack;
    if strcmp(st(3).name, 'StartTheTestButtonPressed')
        handles = guidata(findobj('Tag','Administrator_Input_Screen'));
    else
        handles = guidata(findobj('Tag','GUI'));
    end
    handles.myData.stage=stage_get_pos(handles.myData.stage);
    Pos=handles.myData.stage.Pos;
    set(hObject, 'UserData', Pos);
end
function position_skip_callback(hObject, eventdata)
     st = dbstack;
     if strcmp(st(3).name, 'StartTheTestButtonPressed')
        handles = guidata(findobj('Tag','Administrator_Input_Screen'));
     else
        handles = guidata(findobj('Tag','GUI'));
     end
     set(hObject, 'UserData', 1);

end

function joystick_speed_callback(hObject, eventdata)
    st = dbstack;
    if strcmp(st(3).name, 'StartTheTestButtonPressed')
        handles = guidata(findobj('Tag','Administrator_Input_Screen'));
    else
        handles = guidata(findobj('Tag','GUI'));
    end
     joystickInfo = get(hObject,'UserData');
     if joystickInfo(1) == 0
         handles.myData.stage = stage_get_joy_speed(handles.myData.stage);
         joystickInfo(2) = handles.myData.stage.default_joy_speed;
         handles.myData.stage = stage_set_joy_speed(handles.myData.stage,'20000');
         joystickInfo(1) = 1;
         set(hObject,'String','Recover Joystick Speed');
     else
         handles.myData.stage = stage_set_joy_speed(handles.myData.stage,joystickInfo(2));
         joystickInfo(1) = 0;
         set(hObject,'String','Slow Down Joystick');
     end

     set(hObject, 'UserData', joystickInfo);
end

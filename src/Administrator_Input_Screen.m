% Author: BSc Adam Ivansky
% Supervisors: Brandon D. Gallas PhD, Wei-Chung Cheng PhD
% Date: 24/08/2012
%
%--------------------------------------------------------------------------

%% ############# ADMINISTRATOR INPUT SCREEN ########################
function varargout = Administrator_Input_Screen(varargin)
try
    
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @Administrator_Input_Screen_OpeningFcn, ...
        'gui_OutputFcn',  @Administrator_Input_Screen_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    
catch ME
    error_show(ME)
end

end

%% ############# ADMINISTRATOR INPUT SCREEN OPENING FUNCTION #######
function Administrator_Input_Screen_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
try
    %--------------------------------------------------------------------------
    % This function executes before the GUI is displayed. It makes sure
    % that the window of this GUI is positioned to the exact center of the
    % screen regardsless of the screen size of aspect ratio.
    %--------------------------------------------------------------------------
    ExecutableFolder = GetExecutableFolder();
    cd(ExecutableFolder);
    handles.output = hObject;
    modes=get(handles.ModeSelectionPopUpMenu,'String'); %#ok<NASGU>
    
    handles.myData = struct;
    handles.myData.settings = struct;
    handles.myData.stagedata = struct;
    handles.myData.tasks_in = [];
    handles.myData.tasks_out = [];
    handles.myData.wsi_files = [];
    handles.myData.graphics = struct;

    %addpath('gui_graphics', 'icc_profiles', 'tasks','stages/Prior','stages/Ludl');
    if (~isdeployed)
        addpath('icc_profiles', 'tasks','stages/Prior','stages/Ludl');
    end
    handles.myData.sourcedir = [cd, '\'];

    % Create this variable to identify whether microscope and video is
    % available. It allows programming MicroRT mode without the microscope.
    handles.myData.yesno_micro = 1;
    
    
    % Position the window to the exact center of the screen
    scrsz = get(0, 'ScreenSize');
    figuresz=getpixelposition(gcf);
    setpixelposition(gcf,[scrsz(3)/2-figuresz(3)/2 ...
        scrsz(4)/2-figuresz(4)/2 figuresz(3) figuresz(4)]);
    
    guidata(handles.Administrator_Input_Screen, handles);
    
catch ME
    error_show(ME)
end

end

%% ############# ADMINISTRATOR INPUT SCREEN OUTPUT FUNCTION ########
function varargout = Administrator_Input_Screen_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

end




%% ############# BROWSE BUTTON PRESSED #############################
function BrowseButtonPressed(hObject, eventdata, handles) %#ok<DEFNU>
try
    %--------------------------------------------------------------------------
    % This function is called when the the administrator presses the button
    % 'browse'. The function shows a dialog allowing the administrator to
    % select the desired set of evaluation tasks and present him with the
    % header of the file so that she/can read the header and decide if that
    % is the desired file.
    %--------------------------------------------------------------------------
    
    handles.output = hObject;
    set(handles.BrowseButton, 'Enable', 'off');
    set(handles.ExtractROIsButton, 'Enable', 'off');
    set(handles.StartTheTestButton, 'Enable', 'off');    
    set(handles.ModeSelectionPopUpMenu, ...
        'Enable', 'off', ...
        'Value', 1);

    % Show the 'select file' dialogue and record the filename of the
    % selected file and the path
    [inputfile, workdir] = ...
        uigetfile('*.dapsi', 'Select a question set file');
    workdir_inputfile = [workdir, inputfile];
    
    % Verify that the user didn't press cancel in the file selection dialog
    if ~(isequal(workdir, 0))
        
        % The full path to the input file is shown in the FullPathInfo textbox
        set(handles.FullPathInfo, 'String', workdir_inputfile);
        
        % Open the selected input file
        fid = fopen(workdir_inputfile);
        
        % Find the line containing the string 'SETTINGS'
        % All the preceeding text makes up the header
        % The header text is free format and unused by eeDAP
        index = 0;
        tline = fgets(fid);
        desc_SETTINGS = 'SETTINGS';
        found=strfind(tline,desc_SETTINGS);
        while (~feof(fid)) && isempty(found)
            tline = fgets(fid);
            index=index+1;
            temp_string{index} = tline; %#ok<AGROW>
            found = strfind(tline,desc_SETTINGS);
        end
        fclose(fid);
        % Display the header of the file into the textbox handles.FileHeaderInfo
        
        set(handles.FileHeaderInfo, 'String', temp_string);
        set(handles.StartTheTestButton, 'Enable', 'off');
        set(handles.ExtractROIsButton, 'Enable', 'on');
        
        % If the user pressed cancel disable the 'Extract ROIs' and 'Start the test'
        % buttons.
    else
        
        set(handles.FullPathInfo, 'String', '<No file selected>');
        set(handles.FileHeaderInfo, 'String', '<No file selected>');
        set(handles.StartTheTestButton, 'Enable', 'off');
        set(handles.ExtractROIsButton, 'Enable', 'off');
    end
    
    % Save all the key directories in myData
    % Directories end with a slash
    handles.myData.inputfile = inputfile;
    handles.myData.workdir = workdir;
    handles.myData.workdir_inputfile = workdir_inputfile;
    handles.myData.registration_images_dir = ...
        [handles.myData.workdir, 'Temporary_Registration_Images\'];
    handles.myData.task_images_dir = ...
        [handles.myData.workdir, 'Temporary_Task_Images\'];
    handles.myData.output_files_dir = ...
        [handles.myData.workdir, 'Output_Files\'];

    guidata(handles.Administrator_Input_Screen, handles);
    set(handles.BrowseButton, 'Enable', 'on');
    
catch ME
    error_show(ME)
end

end

%% ############# EXTRACT ROIS BUTTON PRESSED #######################
function ExtractROIsButtonPressed(hObject, eventdata, handles) %#ok<DEFNU>
try
    %--------------------------------------------------------------------------
    % This function is executed after the user presses the extract ROIs
    % button.
    %--------------------------------------------------------------------------
    
    set(handles.ExtractROIsButton, 'Enable', 'off');
%     Load_Input_File(handles);
%     handles = guidata(handles.Administrator_Input_Screen);
    
    Purge_Temporary_Images(handles);
    succeedLoad = Load_Input_File(handles);
    if ~succeedLoad
        return;
    end    
    handles = guidata(handles.Administrator_Input_Screen);
    
    wtb=waitbar(0,'Extracting ROIs....', 'WindowStyle', 'modal');
    %wsi_scan_scale = handles.myData.settings.scan_scale;
    for i=2:handles.myData.ntasks+1
        
        taskinfo = handles.myData.tasks_out{i};
        if  ~isfield(taskinfo,'dontextract')
            slot = taskinfo.slot;
            wsi_info = handles.myData.wsi_files{slot};

            WSIfile=wsi_info.fullname;
            ROIname = [handles.myData.task_images_dir, taskinfo.id, '.tif'];
            taskinfo.ROIname = ROIname;

            Left = taskinfo.roi_x-(taskinfo.roi_w/2);
            Top  = taskinfo.roi_y-(taskinfo.roi_h/2);

            success = ExtractROI_BIO(wsi_info, WSIfile, ROIname,...
                Left, Top, taskinfo.roi_w, taskinfo.roi_h,...
                taskinfo.img_w, taskinfo.img_h,...
                handles.myData.settings.RotateWSI,...
                wsi_info.rgb_lut);

            if ~success
                close(wtb);
                return
            end
            % generage XML file
         %   success = exportXML(wsi_info.fullname,wsi_scan_scale, taskinfo.id,handles.myData.workdir,...
          %      Left, Top, taskinfo.roi_w, taskinfo.roi_h);        

            % Move the waitbar by 1 step
        end
            waitbar(i / handles.myData.ntasks);

            handles.myData.tasks_out{i} = taskinfo;
        
    end
    guidata(handles.Administrator_Input_Screen, handles);
    close(wtb);
    
    handles = guidata(handles.Administrator_Input_Screen);
    
    set(handles.ModeSelectionPopUpMenu, 'Enable', 'on');
    
    
catch ME
    error_show(ME)
end

end

%% ############# PURGE OLD TEMPORARY FILES #########################
function Purge_Temporary_Images(handles)
%--------------------------------------------------------------------------
% If they do not exist, this function is used to create the following
% directories:
%     Output_Files
%     Temporary_Registration_Images
%     Temporary_Task_Images
% If the directories do exist, this function deletes the tif files from the
% temporary directories.
%--------------------------------------------------------------------------
try
    
    dirname = handles.myData.task_images_dir;
    files = [dirname, '*.tif'];
    
    if isdir(dirname)
        delete(files);
    else
        mkdir(dirname);
    end
    
    dirname = handles.myData.registration_images_dir;
    files = [dirname, '*.tif'];
    if isdir(dirname)
        delete(files);
    else
        mkdir(dirname);
    end
    
    dirname = handles.myData.output_files_dir;
    if ~isdir(dirname)
        mkdir(dirname);
    end
    
catch ME
    error_show(ME)
end

end

%% ############# START THE TEST BUTTON PRESSED #####################
function StartTheTestButtonPressed(hObject, eventdata, handles) %#ok<DEFNU>
try
    %--------------------------------------------------------------------------
    % This function executed when the administrator chooses to start the
    % test. The current GUI is closed and a new GUI with the test is
    % opened. The GUI with the test takes the path to the evaluation set
    % file and the mode of testing as inputs.
    %--------------------------------------------------------------------------
    
    handles = guidata(handles.Administrator_Input_Screen);
    settings = handles.myData.settings;
    
    set(handles.StartTheTestButton, 'Enable', 'off');
    hObject_modes = findobj('Tag','ModeSelectionPopUpMenu');
    handles.ModeSelectionPopUpMenu = hObject_modes;
    
    handles.current = struct;
    handles.current.success = zeros(1,settings.n_wsi);
    
    % The GUI objects are initiated
    switch handles.myData.mode_desc
        case 'Digital'
            guidata(handles.Administrator_Input_Screen, handles);
        case 'MicroRT'
            % set default white balance
            % based on study experience: 587 and 710 are good white balance  
             handles.myData.settings.defaultR = 587;
             handles.myData.settings.defaultB = 710;
            for slot_i=1:settings.n_wsi
                handles.current.reg_flag = 0;
                handles.current.slot_i = slot_i;
                guidata(handles.Administrator_Input_Screen, handles);
                save('Stage_Allighment.mat','handles');
                % stagedata structure is packed into into handles.myData
                handle_Stage_Allighment = Stage_Allighment(handles);
                uiwait(handle_Stage_Allighment);
                handles = guidata(handles.Administrator_Input_Screen);
                if handles.current.success(slot_i)==0
                    close all force
%                    keyboard
%                    close(handles.Administrator_Input_Screen)
                    return
                end
            end
            
            align_eye_cam(handles)
            handles = guidata(handles.Administrator_Input_Screen);
         case 'TrackingView'
             guidata(handles.Administrator_Input_Screen, handles);
    end
    save('GUI.mat','handles');
    handles_GUI=  GUI(handles);

    uiwait(handles_GUI);
    %close(handles.Administrator_Input_Screen);

    
catch ME
    error_show(ME)
end

end

%% ############# Align the eyepiece and the camera #################
function align_eye_cam(handles) %#ok<*INUSD>
try
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
    guidata(handles.Administrator_Input_Screen, handles);
    
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
handles = guidata(findobj('Tag','Administrator_Input_Screen'));
stage=stage_get_pos(handles.myData.stage);
Pos=stage.Pos;
set(hObject, 'UserData', Pos);

end

function position_cam_callback(hObject, eventdata)
handles = guidata(findobj('Tag','Administrator_Input_Screen'));
stage=stage_get_pos(handles.myData.stage);
Pos=stage.Pos;
set(hObject, 'UserData', Pos);

end
function position_skip_callback(hObject, eventdata)
     handles = guidata(findobj('Tag','Administrator_Input_Screen'));
     set(hObject, 'UserData', 1);

end

function joystick_speed_callback(hObject, eventdata)
     handles = guidata(findobj('Tag','Administrator_Input_Screen'));
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


%% ############# Executes on button press in configure_camera.
function configure_camera_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to configure_camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    
    objects = imaqfind;
    delete(objects);
    
    % Create the video object to communicate with the camera
    %vid = videoinput('dcam',1); %#ok<NASGU>
    settings = handles.myData.settings;
    if strcmp( settings.cam_kind,'USB')
       cam_adaptor = 'pointgrey';
    elseif strcmp( settings.cam_kind,'Firewire')
       cam_adaptor = 'dcam';
    end
    % Create the video object to communicate with the camera 
    vid = videoinput(cam_adaptor,1) %#ok<NOPRT>

    
    imaqtool
    
catch ME
    error_show(ME)
end
end

%% ############# Executes on button press in configure_COM.
function configure_COM_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    % hObject    handle to configure_COM (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    SerialPortSetUp();
    return
    
catch ME
    error_show(ME)
end

end

%% ############# ModeSelectionPopUpMenu_Callback
function ModeSelectionPopUpMenu_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    
    handles = guidata(hObject);
    settings = handles.myData.settings;
    
    hObject_configure_COM = findobj('Tag','configure_COM');
    hObject_configure_camera = findobj('Tag','configure_camera');
    
    % Get the selected mode
    modes=get(handles.ModeSelectionPopUpMenu,'String');
    mode_index = get(handles.ModeSelectionPopUpMenu, 'Value');
    mode_desc = deblank(modes{mode_index});
    handles.myData.mode_desc = mode_desc;

    switch mode_desc
        case 'Digital'
            set(hObject_configure_COM, 'Enable', 'off');
            set(hObject_configure_camera, 'Enable', 'off');
            
            set(handles.StartTheTestButton, 'Enable', 'on');
            handles.myData.refineRegistration = 0;
        case 'MicroRT'
            % set default white balance
            % based on study experience: 587 and 710 are good white balance
            settings.defaultR = 587;
            settings.defaultB = 710;
            set(hObject_configure_COM,...
                'Enable', 'on',...
                'String', 'Change Working Stage COM');
            set(hObject_configure_camera, ...
                'Enable', 'on', ...
                'String', 'Configure Camera');
            handles.myData.refineRegistration = 0;
            handles.myData.stage = stage_get_pos(handles.myData.stage); %#ok<NASGU>
            if handles.myData.stage.Pos == 0
                return
            end
            
            % Set the size of the camera patch to be used for registration
            settings.cam_roi_h = 300;
            settings.cam_roi_w = 300;
            
            % Set the alignment offsets to [0,0] between the eye and the camera
            % in stage coordinates and in camera coordinates
            settings.offset_stage = [0, 0];
            settings.offset_cam = [0, 0];
            
            % Determine and derive additional camera settings
            if handles.myData.yesno_micro==1
                cam=camera_open(settings.cam_kind,settings.cam_format,settings.defaultR,settings.defaultB);
                if cam == 0
                    return
                end
                dim = cam.VideoResolution;
                settings.cam_w = dim(1);
                settings.cam_h = dim(2);
                delete(cam);
                clear cam;
            end

%             settings.cam_scale_lres = ...
%                 settings.cam_pixel_size / settings.mag_cam / settings.mag_lres;
%             settings.cam_scale_hres = ...
%                 settings.cam_pixel_size / settings.mag_cam / settings.mag_hres;
%             
%             % cam pixels to scan pixels
%             settings.cam_lres2scan = ...
%                 settings.cam_scale_lres/settings.scan_scale;
%             settings.cam_hres2scan = ...
%                 settings.cam_scale_hres/settings.scan_scale;
%             
%             % cam pixels to stage pixels
%             settings.cam_lres2stage = ...
%                 settings.cam_scale_lres/handles.myData.stage.scale;
%             settings.cam_hres2stage = ...
%                 settings.cam_scale_hres/handles.myData.stage.scale;
%             
%             % scan pixels to cam pixels
%             settings.scan2cam_lres = 1.0/settings.cam_lres2scan;
%             settings.scan2cam_hres = 1.0/settings.cam_hres2scan;
%             
%             % stage pixels to cam pixels
%             settings.stage2cam_lres = 1.0/settings.cam_lres2stage;
%             settings.stage2cam_hres = 1.0/settings.cam_hres2stage;
%             
%             % scan pixels to stage pixels
%             settings.scan2stage = settings.scan_scale/handles.myData.stage.scale;
%             
%             % stage pixels to scan pixels
%             settings.stage2scan = 1.0/settings.scan2stage;
            

            settings.cam_scale_lres = ...
                  settings.cam_pixel_size / settings.mag_cam / settings.mag_lres;
            settings.cam_scale_hres = ...
                  settings.cam_pixel_size / settings.mag_cam / settings.mag_hres;
              
            % cam pixels to stage pixels
            settings.cam_lres2stage = ...
                  settings.cam_scale_lres/handles.myData.stage.scale;
            settings.cam_hres2stage = ...
                  settings.cam_scale_hres/handles.myData.stage.scale;              
            
            % stage pixels to cam pixels
            settings.stage2cam_lres = 1.0/settings.cam_lres2stage;
            settings.stage2cam_hres = 1.0/settings.cam_hres2stage;              
         
            
            for slot_i=1:settings.n_wsi            
                
                 wsi_info = handles.myData.wsi_files{slot_i};
                  % cam pixels to scan pixels
                  settings.cam_lres2scan(slot_i) = ...
                        settings.cam_scale_lres/wsi_info.scan_scale;
                  settings.cam_hres2scan(slot_i) = ...
                        settings.cam_scale_hres/wsi_info.scan_scale;
                                            
                  % scan pixels to cam pixels
                  settings.scan2cam_lres(slot_i) = 1.0/settings.cam_lres2scan(slot_i);
                  settings.scan2cam_hres(slot_i) = 1.0/settings.cam_hres2scan(slot_i);
                                               
                  % scan pixels to stage pixels
                  settings.scan2stage(slot_i) = wsi_info.scan_scale/handles.myData.stage.scale;
                        
                  % stage pixels to scan pixels
                  settings.stage2scan(slot_i) = 1.0/settings.scan2stage(slot_i);
            end



            % Create reticle mask for the camera image
            settings.cam_mask = reticle_make_mask(...
                settings.reticleID,...
                settings.cam_pixel_size/settings.mag_cam,...
                -settings.offset_cam);

            set(handles.StartTheTestButton, 'Enable', 'on');
        case 'TrackingView'
            set(hObject_configure_COM, 'Enable', 'off');
            set(hObject_configure_camera, 'Enable', 'off');     
            set(handles.StartTheTestButton, 'Enable', 'on');
            
            settings.cam_mask = reticle_make_mask(...
                settings.reticleID,...
                settings.cam_pixel_size/settings.mag_cam,...
                [0,0]);
            handles.myData.refineRegistration = 0;
        otherwise
            
            set(hObject_configure_COM,'Enable', 'off');
            set(hObject_configure_camera,'Enable', 'off');
            set(handles.StartTheTestButton, 'Enable', 'off');

    end
    
    handles.myData.settings = settings;
    guidata(hObject, handles);
    
catch ME
    error_show(ME)
end

end



%% ############# FUNCTIONS LAUNCHED AFTER CREATION OF GUI OBJECTS ##
function FileHeaderInfo_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function FullPathInfo_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function ModeSelectionPopUpMenu_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
    
end
end

function FullPathInfo_Callback(hObject, eventdata, handles) %#ok<DEFNU>

end


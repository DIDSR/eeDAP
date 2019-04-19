function varargout = Registration_after_work(varargin)

    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @Registration_after_work_OpeningFcn, ...
                       'gui_OutputFcn',  @Registration_after_work_OutputFcn, ...
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
% End initialization code - DO NOT EDIT
end

% --- Executes just before Registration_after_work is made visible.
function Registration_after_work_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Registration_after_work (see VARARGIN)
    ExecutableFolder = GetExecutableFolder();
    cd(ExecutableFolder);
    handles.output = hObject;
    
    handles.myData = struct;
    handles.myData.settings = struct;
    handles.myData.stagedata = struct;
    handles.myData.tasks_in = [];
    handles.myData.tasks_out = [];
    handles.myData.wsi_files = [];
    handles.myData.graphics = struct;

    %addpath('gui_graphics', 'icc_profiles', 'tasks','stages/Prior','stages/Ludl');
    addpath('icc_profiles', 'tasks','stages/Prior','stages/Ludl');

    handles.myData.sourcedir = [cd, '\'];

    % Create this variable to identify whether microscope and video is
    % available. It allows programming MicroRT mode without the microscope.
    handles.myData.yesno_micro = 1;
    
    
    % Position the window to the exact center of the screen
    scrsz = get(0, 'ScreenSize');
    figuresz=getpixelposition(gcf);
    setpixelposition(gcf,[scrsz(3)/2-figuresz(3)/2 ...
        scrsz(4)/2-figuresz(4)/2 figuresz(3) figuresz(4)]);
    
    set(handles.nextWSI,'Enable','off');
    set(handles.upLeft,'Enable','off');
    set(handles.bottomRight,'Enable','off');
    set(handles.bottomLeft,'Enable','off');
    set(handles.upLeftReg,'Enable','off');
    set(handles.bottomLeftReg,'Enable','off');
    set(handles.bottomRightReg,'Enable','off');
    set(handles.transfer_stage_position,'Enable','off');
    
% Update handles structure
 guidata(handles.Registration_after_work, handles);

% UIWAIT makes Registration_after_work wait for user response (see UIRESUME)
% uiwait(handles.Registration_after_work);
end

% --- Outputs from this function are returned to the command line.
function varargout = Registration_after_work_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in browserOutput.
function browserOutput_Callback(hObject, eventdata, handles)
% hObject    handle to browserOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [eeDAPoutputFile, workdir] = ...
        uigetfile('*.dapso', 'Select a question set file');
    workdir_eeDAPoutputFile = [workdir, eeDAPoutputFile];   
    dotindex = find(workdir_eeDAPoutputFile=='.');
    workdir_eeDAPoutputFolder = workdir_eeDAPoutputFile(1:dotindex(end)-1);
    handles.myData.workdir_eeDAPoutputFolder=workdir_eeDAPoutputFolder;
    handles.myData.workdir_eeDAPoutputFile=workdir_eeDAPoutputFile;
    handles.myData.eeDAPoutputFile = eeDAPoutputFile;
    
    handles.myData.workdir = workdir;
    guidata(handles.Registration_after_work, handles);
    succeedLoad = Load_Output_File(handles);
    if ~succeedLoad
        return;
    end  
    handles = guidata(handles.Registration_after_work);
    handles.myData.registration_images_dir = ...
        [handles.myData.workdir, 'Temporary_Registration_Images\'];
    dirname = handles.myData.registration_images_dir;
    handles.myData.currentslot=0; 
    files = [dirname, '*.tif'];
    if isdir(dirname)
        delete(files);
    else
        mkdir(dirname);
    end
    
    switch handles.myData.stage.label
        case 'SCAN8Praparate_Ludl5000'            
            handles.myData.stage.scale=0.1;
        case 'SCAN8Praparate_Ludl6000'         
            handles.myData.stage.scale=0.025;
        case 'BioPrecision2-LE2_Ludl5000'             
            handles.myData.stage.scale=0.2;
        case 'BioPrecision2-LE2_Ludl6000'            
            handles.myData.stage.scale=0.05;
        case 'H101-Prior' 
            handles.myData.stage.scale=1;
        otherwise     
            handles.myData.stage.scale=0.1;
    end  
    
    
    settings = handles.myData.settings;
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
    settings.cam_roi_w = 1224;
    settings.cam_roi_h = 1024;
    handles.myData.settings = settings;
    set(handles.fileNameText,'String',eeDAPoutputFile);
    set(handles.nextWSI,'Enable','on');
    guidata(handles.Registration_after_work, handles);
end

function nextWSI_Callback(hObject, eventdata, handles)
% hObject    handle to nextWSI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.Registration_after_work);
    settings = handles.myData.settings;
    myData= handles.myData;
    handles.current = struct;
    handles.current.success = zeros(1,settings.n_wsi);
    handles.myData.currentslot = handles.myData.currentslot +1;
    if handles.myData.currentslot <= settings.n_wsi
        slot_i=handles.myData.currentslot;
        % Initialize the thumbnail settings
        current.thumb_file = [myData.registration_images_dir,...
            'lres_s', num2str(slot_i), '_thumb.tif'];
        wsi_info = myData.wsi_files{slot_i};
        wsi_name = wsi_info.fullname;
        tempIndex = find(wsi_name=='\');
        wsi_name = wsi_name(tempIndex(end)+1:end);
        current.wsi_info = wsi_info;
        current.thumb_image = 0;
        current.thumb_left = 1;
        current.thumb_top = 1;
        current.thumb_w = 0;
        current.thumb_h = 1000;
        current.thumb_x0 = 0;
        current.thumb_y0 = 0;
        current.thumb_extract_w = wsi_info.wsi_w(1);
        current.thumb_extract_h = wsi_info.wsi_h(1);
        if current.thumb_extract_w > current.thumb_extract_h
            current.thumb_w = 1000;
            current.thumb_h = 0;
        end
        current.thumb_image_handle = 0;
        handles.current = current;
        currentslot = handles.myData.currentslot;
        taskinfo = handles.myData.eedapOutFileInfo{currentslot}; 
        workdir_eeDAPoutputFolder = handles.myData.workdir_eeDAPoutputFolder;
        handles.myData.stagedata.stagedata_file = [workdir_eeDAPoutputFolder,'\ID-',taskinfo.id,'_iter-',num2str(taskinfo.order),'.mat'];
        guidata(handles.Registration_after_work, handles);
        display_thumb(handles.Registration_after_work);
       % set(handles.current.thumb_image_handle,'visible','on');       
        
       % run registration video
        videoName = [workdir_eeDAPoutputFolder,'\ID-',taskinfo.id,'_iter-',num2str(taskinfo.order),'_registrationVideo.avi'];
        system(videoName);
        
        set(handles.WSIname,'String',wsi_name);
        set(handles.nextWSI,'Enable','off');
        set(handles.upLeft,'Enable','on');
        set(handles.transformation_equation,'String','Transformation Equation')
    else
        close all;
    end
    
end

%% -------- Display the thumbnail image
function display_thumb(Registration_after_work_handle)
try
    
    handles = guidata(Registration_after_work_handle);
    myData = handles.myData;
    current = handles.current;
    settings = myData.settings;
%     wsi_w = current.wsi_info.wsi_w(1);
%     wsi_h = current.wsi_info.wsi_h(1);
%     stagedata = handles.myData.stagedata;    
%     % High-power magnification registration
%     if current.reg_flag==1
%         cam_h = myData.settings.cam_h;
%         cam_w = myData.settings.cam_w;
%         
%         slot_i = current.slot_i;
%         position_i = current.position_i;
%         
%         pos = stagedata.wsi_positions(position_i,:);
%         current.scan2cam = myData.settings.scan2cam_hres(slot_i);
%         
%         current.thumb_file = [myData.registration_images_dir,...
%             'hres_s', num2str(slot_i), 'p',num2str(position_i),'_thumb.tif'];
%         
%         % Set the extract region width to be equivalent to the low-res
%         % camera image at the positions collected at low-res registration
%         current.thumb_extract_w = cam_h*myData.settings.cam_lres2scan(slot_i);
%         current.thumb_extract_h = cam_w*myData.settings.cam_lres2scan(slot_i);
%         current.thumb_left = pos(1) - current.thumb_extract_w/2;
%         current.thumb_top = pos(2) - current.thumb_extract_h/2;
%         thumb_right = pos(1) + current.thumb_extract_w/2;
%         thumb_bottom = pos(2) + current.thumb_extract_h/2;
%         if current.thumb_left<1
%             current.thumb_left=1;
%         end
%         if current.thumb_top<1
%             current.thumb_top=1;
%         end
%         if thumb_right>wsi_w
%            current.thumb_left = current.thumb_left - thumb_right + wsi_w;
%         end
%         if thumb_bottom>wsi_h
%            current.thumb_top = current.thumb_top - thumb_bottom + wsi_h;
%         end
%     end
    current.cam2scan = myData.settings.cam_hres2scan(myData.currentslot);
    current.thumb_w = 0;
    current.thumb_h = 1000;
    if current.thumb_extract_w > current.thumb_extract_h
        current.thumb_w = 1000;
        current.thumb_h = 0;
        current.thumb_scale = 1000.0/current.thumb_extract_w;
    else
        current.thumb_scale = 1000.0/current.thumb_extract_h;
    end
    
    if settings.RotateWSI == 0 || settings.RotateWSI== 180
        current.thumb_h = current.thumb_scale*current.thumb_extract_h;           %3,9 o'clock
        current.thumb_w = current.thumb_scale*current.thumb_extract_w;
    else
        current.thumb_w = current.thumb_scale*current.thumb_extract_w;           %6,12 o'clock
        current.thumb_h = current.thumb_scale*current.thumb_extract_h;
    end

    
    ExtractROI_BIO(current.wsi_info,...
        current.wsi_info.fullname,...
        current.thumb_file,...
        current.thumb_left,...
        current.thumb_top,...
        current.thumb_extract_w,...
        current.thumb_extract_h,...
        current.thumb_w,...
        current.thumb_h,...
        handles.myData.settings.RotateWSI,...
        current.wsi_info.rgb_lut);
    
    if settings.RotateWSI == 0 || settings.RotateWSI== 180       
        temp = current.thumb_w;
        current.thumb_w = floor(current.thumb_w);           %3,9 o'clock
        current.thumb_h = floor(current.thumb_h);
    else
        temp = current.thumb_w;
        current.thumb_w = floor(current.thumb_h);           %6,12 o'clock
        current.thumb_h = floor(temp);
    end

    
    current.thumb_image = imread(current.thumb_file);
    current.thumb_image_handle = image(current.thumb_image, 'Parent', handles.thumb_axes);
    
    axis(handles.thumb_axes,'image');
    handles.current = current;
    guidata(handles.Registration_after_work, handles);
    
catch ME
    error_show(ME)
end

end

%  upLeft.
function upLeft_Callback(hObject, eventdata, handles)
% hObject    handle to upLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.Registration_after_work);
    current = handles.current;
    workdir_eeDAPoutputFolder = handles.myData.workdir_eeDAPoutputFolder;
    currentslot = handles.myData.currentslot;
    taskinfo = handles.myData.eedapOutFileInfo{currentslot}; 
    imageName = [workdir_eeDAPoutputFolder,'\ID',taskinfo.id,'_Slot',num2str(taskinfo.slot),'_Order',num2str(taskinfo.order),'_x',num2str(taskinfo.upleftX),'_y',num2str(taskinfo.upleftY),'_1upleft.tif'];    
    regIM = imread(imageName);    
    cam_file = [handles.myData.registration_images_dir,...
            num2str(taskinfo.slot), 'p', num2str(1), '_cam.tif'];
    %handles.current.cam_file = cam_file;
    imwrite(regIM, cam_file, 'tif');
    handles.current.cam_file = cam_file;
    imageSize = size(regIM);
    handles.myData.settings.cam_w = imageSize(2);
    handles.myData.settings.cam_h = imageSize(1);
    current.cam_image = regIM;
    current.cam_w = imageSize(2);
    current.cam_h = imageSize(1);
    current.position_i = 1;
    handles.regIM_handle = image(regIM, 'Parent', handles.regImage);
    set(handles.regIM_handle,'visible','on');
    handles.current = current;    
    handles.myData.stagedata.stage_positions(current.position_i,:) = [taskinfo.upleftX ,taskinfo.upleftY];
    
    guidata(handles.Registration_after_work, handles);
    set(handles.upLeft,'Enable','off');
    set(handles.upLeftReg,'Enable','on');
    set(handles.current.thumb_image_handle,...
        'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
end


function upLeftReg_Callback(hObject, eventdata, handles)
% hObject    handle to upLeftReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.take_wsi_flag==0
        desc = 'Please click on the WSI at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'upLeftReg','modal'); %#ok<NASGU>
        return;
    end
    
    set(handles.upLeftReg,'Enable','off');
    set(handles.current.thumb_image_handle,'HitTest','off');
    Register_ROI(handles);
    handles = guidata(handles.Registration_after_work);
    
    if handles.current.registration_good==0
        % Refresh the image
        handles.current.thumb_image_handle = ...
            image(handles.current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(handles.current.thumb_image_handle,'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
        
        % Reset state to repeat registration
        handles.take_wsi_flag = 0;
        set(handles.upLeftReg,'Enable','on');
        
        guidata(handles.Registration_after_work, handles);
        return;
    end
    handles.myData.stagedata.wsi_positions(1,1) = handles.current.roi_x0;
    handles.myData.stagedata.wsi_positions(1,2) = handles.current.roi_y0;
    guidata(handles.Registration_after_work, handles);
    
    display_thumb(handles.Registration_after_work);
       
    % Prepare for the next step
    
    set(handles.bottomLeft,'Enable','on');
end

% bottomLeft.
function bottomLeft_Callback(hObject, eventdata, handles)
% hObject    handle to bottomLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.Registration_after_work);
    current = handles.current;
    workdir_eeDAPoutputFolder = handles.myData.workdir_eeDAPoutputFolder;
    currentslot = handles.myData.currentslot;
    taskinfo = handles.myData.eedapOutFileInfo{currentslot}; 
    imageName = [workdir_eeDAPoutputFolder,'\ID',taskinfo.id,'_Slot',num2str(taskinfo.slot),'_Order',num2str(taskinfo.order),'_x',num2str(taskinfo.bottomleftX),'_y',num2str(taskinfo.bottomleftY),'_2bottomLeft.tif'];
    regIM = imread(imageName);
    cam_file = [handles.myData.registration_images_dir,...
            num2str(taskinfo.slot), 'p', num2str(2), '_cam.tif'];
    imwrite(regIM, cam_file, 'tif');
    handles.current.cam_file = cam_file;
    imageSize = size(regIM);
    handles.myData.settings.cam_w = imageSize(2);
    handles.myData.settings.cam_h = imageSize(1);
    current.cam_image = regIM;
    current.cam_w = imageSize(2);
    current.cam_h = imageSize(1);
    current.position_i = 2;
    handles.regIM_handle = image(regIM, 'Parent', handles.regImage);
    handles.current = current;
    handles.myData.stagedata.stage_positions(current.position_i,:) = [taskinfo.bottomleftX  ,taskinfo.bottomleftY];
    guidata(handles.Registration_after_work, handles);
    set(handles.bottomLeft,'Enable','off');
    set(handles.bottomLeftReg,'Enable','on');
    set(handles.current.thumb_image_handle,...
        'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
end

function bottomLeftReg_Callback(hObject, eventdata, handles)
% hObject    handle to bottomLeftReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.take_wsi_flag==0
        desc = 'Please click on the WSI at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'bottomLeftReg','modal'); %#ok<NASGU>
        return;
    end
    set(handles.bottomLeftReg,'Enable','off');
    
    set(handles.current.thumb_image_handle,'HitTest','off');
    Register_ROI(handles);
    handles = guidata(handles.Registration_after_work);
    
    if handles.current.registration_good==0
        % Refresh the image
        handles.current.thumb_image_handle = ...
            image(handles.current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(handles.current.thumb_image_handle,'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
        
        % Reset state to repeat registration
        handles.take_wsi_flag = 0;
        set(handles.bottomLeftReg,'Enable','on');
        
        guidata(handles.Registration_after_work, handles);
        return;
    end
    handles.myData.stagedata.wsi_positions(2,1) = handles.current.roi_x0;
    handles.myData.stagedata.wsi_positions(2,2) = handles.current.roi_y0;
    
    guidata(handles.Registration_after_work, handles);
    
    display_thumb(handles.Registration_after_work);
       
    % Prepare for the next step
    
    set(handles.bottomRight,'Enable','on');
end


% bottomRight.
function bottomRight_Callback(hObject, eventdata, handles)
% hObject    handle to bottomRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.Registration_after_work);
    current = handles.current;
    workdir_eeDAPoutputFolder = handles.myData.workdir_eeDAPoutputFolder;
    currentslot = handles.myData.currentslot;
    taskinfo = handles.myData.eedapOutFileInfo{currentslot}; 
    imageName = [workdir_eeDAPoutputFolder,'\ID',taskinfo.id,'_Slot',num2str(taskinfo.slot),'_Order',num2str(taskinfo.order),'_x',num2str(taskinfo.bottomrightX),'_y',num2str(taskinfo.bottomrightY),'_3bottomRight.tif'];
    regIM = imread(imageName);
    cam_file = [handles.myData.registration_images_dir,...
            num2str(taskinfo.slot), 'p', num2str(3), '_cam.tif'];
    imwrite(regIM, cam_file, 'tif');
    imageSize = size(regIM);
    handles.myData.settings.cam_w = imageSize(2);
    handles.myData.settings.cam_h = imageSize(1);
    current.cam_image = regIM;
    current.cam_w = imageSize(2);
    current.cam_h = imageSize(1);
    current.position_i = 3;
    handles.regIM_handle = image(regIM, 'Parent', handles.regImage);
    handles.current = current;
    handles.myData.stagedata.stage_positions(current.position_i,:) = [taskinfo.bottomrightX,taskinfo.bottomrightY];
    guidata(handles.Registration_after_work, handles);
    set(handles.bottomRight,'Enable','off');
    set(handles.bottomRightReg,'Enable','on');
    set(handles.current.thumb_image_handle,...
        'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
end
function bottomRightReg_Callback(hObject, eventdata, handles)
% hObject    handle to bottomRightReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.take_wsi_flag==0
        desc = 'Please click on the WSI at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'bottomRightReg','modal'); %#ok<NASGU>
        return;
    end
    
    set(handles.bottomRightReg,'Enable','off');
    set(handles.current.thumb_image_handle,'HitTest','off');
    Register_ROI(handles);
    handles = guidata(handles.Registration_after_work);
    
    if handles.current.registration_good==0
        % Refresh the image
        handles.current.thumb_image_handle = ...
            image(handles.current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(handles.current.thumb_image_handle,'HitTest','on');
        
        % Reset state to repeat registration
        handles.take_wsi_flag = 0;
        set(handles.current.thumb_image_handle,'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
        
        guidata(handles.Registration_after_work, handles);
        return;
    end
    handles.myData.stagedata.wsi_positions(3,1) = handles.current.roi_x0;
    handles.myData.stagedata.wsi_positions(3,2) = handles.current.roi_y0;
    stagedata =  handles.myData.stagedata;
    save(handles.myData.stagedata.stagedata_file,'stagedata');
    set(handles.transfer_stage_position,'Enable','on');
    guidata(handles.Registration_after_work, handles);
    % Save the current stagedata
    
    
    
    % Prepare for the next step        
%    set(handles.current.thumb_image_handle,'visible','off');
    set(handles.regIM_handle,'visible','off');    
    set(handles.nextWSI,'Enable','on');
end

%% -------- For slot i take WSI position i with mouse click
function thumb_image_ButtonDownFcn(hObject, eventdata, handles) %#ok<INUSL>
try
    
    handles = guidata(handles.Registration_after_work);
    myData = handles.myData;
    current = handles.current;
    stagedata = handles.myData.stagedata;
    settings = myData.settings;
    
    slot_i = handles.myData.currentslot;
    position_i = handles.current.position_i;
    
    %wsi_file = current.wsi_info.fullname; %#ok<NASGU>
    wsi_w = current.wsi_info.wsi_w(1);
    wsi_h = current.wsi_info.wsi_h(1);
    cam_w = current.cam_w; %#ok<NASGU>
    cam_h = current.cam_h; %#ok<NASGU>
    thumb_w = current.thumb_w;
    thumb_h = current.thumb_h;
    thumb_left = current.thumb_left;
    thumb_top = current.thumb_top;
    
    cam_hres2scan = settings.cam_hres2scan(slot_i);
    scan2cam_hres = settings.scan2cam_hres(slot_i); %#ok<NASGU>
%     cam_hres2scan = settings.cam_hres2scan(slot_i);
%     scan2cam_hres = settings.scan2cam_hres(slot_i); %#ok<NASGU>
    
    % Get mouse click position. Thumb_axes origin is at the top left
    % Units are in terms of the pix_image
    temp = get(gca,'CurrentPoint');
    x_center = temp(1,1);
    y_center = temp(1,2);
    
    thumb_extract_w = current.thumb_extract_w;
    thumb_extract_h = current.thumb_extract_h;
    
    
    roi_file = [myData.registration_images_dir,'temp_roi.tif'];
    roi_w = 2.0*settings.cam_roi_w;
    roi_h = 2.0*settings.cam_roi_h;
    roi_extract_h = roi_w*cam_hres2scan;
    roi_extract_w = roi_h*cam_hres2scan;
    RotateWSI = settings.RotateWSI;
    switch RotateWSI
    % Notes:
    % eeDAP images are WSI images rotated 90 degree clockwise
    % Rotate = Transpose then reverse YDir
        case 180        % 9 o'clock
            roi_x0 = (thumb_w - x_center)*thumb_extract_w/thumb_w;
            roi_y0  = (thumb_h - y_center)*thumb_extract_h/thumb_h;         
        case 270      % 6 o'clock
            roi_x0 = y_center*thumb_extract_w/thumb_h;
            roi_y0  = (thumb_w - x_center)*thumb_extract_h/thumb_w;
        case 90       % 12 o'clock
            roi_x0 = (thumb_h - y_center)*thumb_extract_w/thumb_h;
            roi_y0  = x_center*thumb_extract_h/thumb_w;
        case 0      % 3 o'clock
            roi_x0 = x_center*thumb_extract_w/thumb_w;
            roi_y0 = y_center*thumb_extract_h/thumb_h;
    end
    % The coordinates are relative to the thumbnail, map to wsi coordinates
    roi_x0 = roi_x0 + thumb_left - 1;
    roi_y0 = roi_y0 + thumb_top - 1;
    roi_left = roi_x0 - roi_extract_w/2;
    roi_top  = roi_y0 - roi_extract_h/2;
    
%     % Must test that the WSI patch is completely within the WSI
%     if ...
%             roi_left - roi_extract_w/2< 1 ||...
%             roi_top - roi_extract_h/2< 1 ||...
%             roi_left + roi_extract_w + roi_extract_w/2> wsi_w ||...
%             roi_top + roi_extract_h + roi_extract_h/2> wsi_h
%         desc = 'ERROR: The region selected plus padding might not be completely inside the image. Please choose a location not so close to the boundary.';
%         h_errordlg = errordlg(desc,'Take WSI Position Error','modal'); %#ok<NASGU>
%         handles.take_wsi_flag = 0;
%         %refresh the image
%         current.thumb_image_handle = ...
%         image(current.thumb_image,'Parent',handles.thumb_axes);
%         axis(handles.thumb_axes,'image');
%         set(current.thumb_image_handle,...
%             'HitTest','on',...
%             'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
%         handles.current = current;
%         guidata(handles.Stage_Allighment, handles);
%         return;
%     end
    
    % Save ROI properties in current structure
    current.roi_file = roi_file;
    current.roi_x0 = roi_x0;
    current.roi_y0 = roi_y0;
    current.roi_left = roi_left;
    current.roi_top = roi_top;
    current.roi_extract_w = roi_extract_w;
    current.roi_extract_h = roi_extract_h;
    current.roi_w = roi_w;
    current.roi_h = roi_h;
    
    % Store the WSI position_i locally and globally and WSI patch
    current.wsi_positions = [roi_x0, roi_y0];
    current.thumb_positions = [x_center, y_center];
    stagedata.wsi_positions(position_i,:) = current.wsi_positions;
    stagedata.thumb_positions(position_i,:) = current.thumb_positions;
    
    handles.take_wsi_flag = 0;
    % The following will refresh the image
    if handles.take_wsi_flag==1
        current.thumb_image_handle = ...
            image(current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(current.thumb_image_handle,...
            'HitTest','on',...
            'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
    end
    handles.take_wsi_flag = 1;
    
    handles.current = current;
    myData.stagedata = stagedata;
    handles.myData = myData;
    guidata(handles.Registration_after_work, handles);
    
    % Annotate the image with boxes marking the registration ROIs
    annotate_image(handles,slot_i)
    
catch ME
    error_show(ME)
end

end

%% -------- Annotate the thumbnail image
function annotate_image(handles,slot_i)
try
    % Place a rectangle on thumb_axes centered on mouse click
    % Blue box is camera roi for extraction
    % Red box is WSI roi for extraction (twice blue box)
    % Green box is the camera view
    
    % position_i indicates one of the three registration locations
    current = handles.current;
    settings = handles.myData.settings;
    position_i = current.position_i;

    % The center of the rectangles in thumbnail pixels
    stagedata = handles.myData.stagedata;
    x_center = stagedata.thumb_positions(position_i,1) %#ok<NOPRT>
    y_center = stagedata.thumb_positions(position_i,2) %#ok<NOPRT>

    cam2scan = settings.cam_hres2scan(slot_i);
    
    % Scale factor to convert scanner pixels to thumbnail pixels
    % Remember that there is a rotation
     if settings.RotateWSI == 0 || settings.RotateWSI== 180
        scan2thumb_w = current.thumb_w/current.thumb_extract_w;
        scan2thumb_h = current.thumb_h/current.thumb_extract_h;
     else
        scan2thumb_w = current.thumb_w/current.thumb_extract_h;
        scan2thumb_h = current.thumb_h/current.thumb_extract_w;
     end
    % Size of blue rectangle in thumbnail pixels
    desc = 'blue';
    rect_w = settings.cam_roi_w*cam2scan*scan2thumb_w;
    rect_h = settings.cam_roi_h*cam2scan*scan2thumb_h;
    rect_left = x_center - rect_w/2;
    rect_top = y_center - rect_h/2;
    rectangle(...
        'Parent', handles.thumb_axes,...
        'Position'  ,[rect_left, rect_top, rect_w, rect_h],...
        'Curvature' ,[0,0],...
        'LineWidth' ,2,...
        'LineStyle' ,'--',...
        'EdgeColor' ,desc,...
        'Tag'       ,'mark',...
        'HitTest'   ,'off');

    % Draw the red rectangle in thumbnail pixels
    desc = 'red';
    rect_w = current.roi_extract_h*scan2thumb_w;
    rect_h = current.roi_extract_w*scan2thumb_h;
    rect_left = x_center - rect_w/2;
    rect_top = y_center - rect_h/2;
    rectangle(...
        'Parent', handles.thumb_axes,...
        'Position'  ,[rect_left, rect_top, rect_w, rect_h],...
        'Curvature' ,[0,0],...
        'LineWidth' ,2,...
        'LineStyle' ,'--',...
        'EdgeColor' ,desc,...
        'Tag'       ,'mark',...
        'HitTest'   ,'off');
    
%     % Draw the green rectangle in thumbnail pixels
%     desc = 'green';
%     rect_w = settings.cam_w*cam2scan*scan2thumb_w;
%     rect_h = settings.cam_h*cam2scan*scan2thumb_h;
%     rect_left = x_center - rect_w/2;
%     rect_top = y_center - rect_h/2;
%     rectangle(...
%         'Parent', handles.thumb_axes,...
%         'Position'  ,[rect_left, rect_top, rect_w, rect_h],...
%         'Curvature' ,[0,0],...
%         'LineWidth' ,2,...
%         'LineStyle' ,'--',...
%         'EdgeColor' ,desc,...
%         'Tag'       ,'mark',...
%         'HitTest'   ,'off');
% 
%     % Label the green box
%     text(...
%         'Parent', handles.thumb_axes,...
%         'Units'             ,'data',...
%         'Position'           ,[rect_left-rect_w/4, rect_top-rect_h/4],...
%         'FontUnits'          ,'pixels',...
%         'FontSize'           ,rect_h/4,...
%         'FontWeight'         ,'bold',...
%         'Color'              ,desc,...
%         'String'             ,'camera',...
%         'HitTest'   ,'off');

        % Label the blue box
    text(...
        'Parent', handles.thumb_axes,...
        'Units'             ,'data',...
        'Position'           ,[rect_left-rect_w/4, rect_top+rect_h+rect_h/4],...
        'FontUnits'          ,'pixels',...
        'FontSize'           ,rect_h/4,...
        'FontWeight'         ,'bold',...
        'Color'              ,'blue',...
        'String'             ,'camera ROI',...
        'HitTest'   ,'off');
    a=1;

catch ME
    error_show(ME)
end

end


% --- Executes on button press in transfer_stage_position.
function transfer_stage_position_Callback(hObject, eventdata, handles)
% hObject    handle to transfer_stage_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    stagedata = handles.myData.stagedata;
    workdir_eeDAPoutputFolder = handles.myData.workdir_eeDAPoutputFolder;
    currentslot = handles.myData.currentslot;
    taskinfo = handles.myData.eedapOutFileInfo{currentslot}; 
    stagePositionFileName = [workdir_eeDAPoutputFolder,'\ID-',taskinfo.id,'_iter-',num2str(taskinfo.order),'_recordStage.csv'];
    [stagePosition,txt,raw] = xlsread(stagePositionFileName);
    
    
    % process transformation format     
    Calib_Point_WSI_A=transpose(stagedata.wsi_positions(1,:));
    Calib_Point_WSI_B=transpose(stagedata.wsi_positions(2,:));
    Calib_Point_WSI_C=transpose(stagedata.wsi_positions(3,:));
    Calib_Point_stage_A=transpose(stagedata.stage_positions(1,:));
    Calib_Point_stage_B=transpose(stagedata.stage_positions(2,:));
    Calib_Point_stage_C=transpose(stagedata.stage_positions(3,:));

    wsi_v1=Calib_Point_WSI_B-Calib_Point_WSI_A;
    wsi_v2=Calib_Point_WSI_C-Calib_Point_WSI_A;
    stage_v1=Calib_Point_stage_B-Calib_Point_stage_A;
    stage_v2=Calib_Point_stage_C-Calib_Point_stage_A;

    wsi_M = [wsi_v1, wsi_v2];
    temp = [wsi_M, transpose([1,0]), transpose([0,1])];
    temp=rref(temp);
    wsi_Minv = temp(:,3:4);
    stage_M = [stage_v1,stage_v2];
    temp = [stage_M, transpose([1,0]), transpose([0,1])];
    temp=rref(temp);
    stage_Minv = temp(:,3:4);

    transformedPosition = [];
    for i = 1:size(stagePosition,1)
        stage_new = double(transpose([stagePosition(i,1),stagePosition(i,2)]));
        wsi_0 = transpose(stagedata.wsi_positions(1,:));                
        stage_0 = transpose(stagedata.stage_positions(1,:));
        temp = stage_new - stage_0;
        temp = inv(stage_M) * temp;
        temp = wsi_M * temp;
        wsi_new = int64(temp + wsi_0);
        stagePositionX(i) = stagePosition(i,1);
        stagePositionY(i) = stagePosition(i,2);
        wsiPositionX(i) = wsi_new(1);
        wsiPositionY(i) = wsi_new(2);
    end

    SystemTime = txt(2:end,1);

    positionFileName =[workdir_eeDAPoutputFolder,'\ID-',taskinfo.id,'_iter-',num2str(taskinfo.order),'_stageAndWSIpositions.csv'];   
    positionTable = table(SystemTime,stagePositionX',stagePositionY',wsiPositionX',wsiPositionY');
    writetable(positionTable,positionFileName);
    set(handles.transfer_stage_position,'Enable','off');
    
    % update Transformation Equation
    transfer_table = wsi_M*inv(stage_M);
    m11 = transfer_table(1,1);
    m12 = transfer_table(1,2);
    m21 = transfer_table(2,1);
    m22 = transfer_table(2,2);
    
    wsix_ax = m11;
    wsix_ay = m12;
    wsix_b = -m11*stagedata.stage_positions(1,1)-m12*stagedata.stage_positions(1,2)+stagedata.wsi_positions(1,1);
       
    wsiy_ax = m21;
    wsiy_ay = m22;
    wsiy_b = -m21*stagedata.stage_positions(1,1)-m22*stagedata.stage_positions(1,2)+stagedata.wsi_positions(1,2);
    
    wsix_function = ['WSI_X = (',num2str(wsix_ax,6),') x Stage_X + (',num2str(wsix_ay,6),') x Stage_Y + (',num2str(round(wsix_b)),')'];
    wsiy_function = ['WSI_Y = (',num2str(wsiy_ax,6),') x Stage_X + (',num2str(wsiy_ay,6),') x Stage_Y + (',num2str(round(wsiy_b)),')'];
    set(handles.transformation_equation,'String',{'Transformation Equation';wsix_function;wsiy_function});
    guidata(handles.Registration_after_work, handles);
end

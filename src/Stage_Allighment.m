function varargout = Stage_Allighment(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Stage_Allighment_OpeningFcn, ...
    'gui_OutputFcn',  @Stage_Allighment_OutputFcn, ...
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

end

%% -------- STAGE ALLIGHMENT OPENING FUNCTION
function Stage_Allighment_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
try
    %--------------------------------------------------------------------------
    % This function executes before the GUI is displayed. It initializes all
    % the key variables in the structure Abort and stagedata. It also
    % extracts and displays the thumbnail image that is used to select the
    % registration ROIs
    %--------------------------------------------------------------------------
    
    % Read input arguments
    handles_old = varargin{1};
    handles.Administrator_Input_Screen = handles_old.Administrator_Input_Screen;
    myData = handles_old.myData;
    handles.myData = myData;
    settings = myData.settings;
    current = handles_old.current;
    reg_flag = current.reg_flag; %#ok<NASGU>
    slot_i = current.slot_i;
    wsi_info = myData.wsi_files{slot_i};
    addpath('stages/Prior','stages/Ludl');
    % Initiate the camera preview window
    % handles.cam = camera object
    if myData.yesno_micro==1
        handles.cam = camera_open(settings.cam_kind,settings.cam_format);
        handles.cam_figure = camera_preview(handles.cam, settings);
        myData.stage = stage_set_origin(myData.stage);       
    end

    % Set the default size of the window and the axes
    set(handles.Stage_Allighment,'Position', [0, 0, 1, 1]);
    sz = get(0,'ScreenSize'); %#ok<NASGU>
    
   
    
    % Initialze the state of the GUI
    set(handles.take_stage1,'Enable','on');
    set(handles.take_stage2,'Enable','off');
    set(handles.take_stage3,'Enable','off');
    set(handles.take_wsi1,'Enable','off');
    set(handles.take_wsi2,'Enable','off');
    set(handles.take_wsi3,'Enable','off');
    set(handles.Abort,'Enable','on');
    set(handles.Video,'Enable','on');
    %set(handles.refine_registration,'Enable','off');
    set(handles.load_last_calibration,'Enable','on');
    set(handles.Done,'Enable','off');
    % Initialize registration parameters corresponding to slot_i
    current.position_i = 1;
    current.wsi_info = wsi_info;
%     current.wsi_file = wsi_info.fullname;
%     current.wsi_w = wsi_info.wsi_w;
%     current.wsi_h = wsi_info.wsi_h;
    
    current.thumb_positions = [0, 0];
    current.stage_positions = [0, 0];
    current.wsi_positions = [0, 0];
    
    % Initialize stagedata
    % The three pairs of stage and wsi positions [x,y] will be recorded
    stagedata = struct;
    stagedata.stage_positions = zeros(3,2);
    stagedata.wsi_positions = zeros(3,2);
    stagedata.thumb_positions = zeros(3,2);
    
    temp = textscan(wsi_info.fullname, '%s %s', 'delimiter', '.');
    stagedata.stagedata_file = [char(temp{1}),'.mat'];
    
    % Initialize the low-resolution conversions between scanner and camera
%     current.scan2cam = myData.settings.scan2cam_lres;
%     current.cam2scan = myData.settings.cam_lres2scan;
    current.scan2cam = myData.settings.scan2cam_lres(slot_i);
    current.cam2scan = myData.settings.cam_lres2scan(slot_i);
    
    % Initialize the thumbnail settings
    current.thumb_file = [myData.registration_images_dir,...
        'lres_s', num2str(slot_i), '_thumb.tif'];
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
    
    % Initialize the ROI settings
    current.roi_file = '';
    current.roi_image = 0;
    current.roi_left = 0;
    current.roi_top = 0;
    current.roi_w = 0;
    current.roi_h = 0;
    current.roi_x0 = 0;
    current.roi_y0 = 0;
    current.roi_extract_w = 0;
    current.roi_extract_h = 0;
    
    % Initialize the camera settings
    current.cam_file = '';
    current.cam_image = 0;
    current.cam_left = 0;
    current.cam_top = 0;
    current.cam_w = 0;
    current.cam_h = 0;
    current.cam_x0 = 0;
    current.cam_y0 = 0;
    current.cam_extract_w = 0;
    current.cam_extract_h = 0;
    
    handles.output = hObject;
    current.load_stage_data = zeros(1,3);
    handles.current = current;
    myData.stagedata = stagedata;
    myData.settings = settings;
    handles.myData = myData;
    guidata(handles.Stage_Allighment, handles);
    
    display_thumb(handles.Stage_Allighment);
    wsi_info = current.wsi_info;
    slideID = strfind(wsi_info.fullname, '\');
    filename = wsi_info.fullname(slideID(end)+1:end);
    set(handles.text710,'String',filename,'FontSize',20);
catch ME
    error_show(ME)
end

end

%% -------- Stage_Allighment_OutputFcn
function varargout = Stage_Allighment_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;
end





%% -------- Display the thumbnail image
function display_thumb(Stage_Allighment_handle)
try
    
    handles = guidata(Stage_Allighment_handle);
    myData = handles.myData;
    current = handles.current;
    wsi_w = current.wsi_info.wsi_w(1);
    wsi_h = current.wsi_info.wsi_h(1);
    stagedata = handles.myData.stagedata;
    settings = myData.settings;
    % High-power magnification registration
    if current.reg_flag==1
        cam_h = myData.settings.cam_h;
        cam_w = myData.settings.cam_w;
        
        slot_i = current.slot_i;
        position_i = current.position_i;
        
        pos = stagedata.wsi_positions(position_i,:);
        current.scan2cam = myData.settings.scan2cam_hres(slot_i);
        current.cam2scan = myData.settings.cam_hres2scan(slot_i);
        current.thumb_file = [myData.registration_images_dir,...
            'hres_s', num2str(slot_i), 'p',num2str(position_i),'_thumb.tif'];
        
        % Set the extract region width to be equivalent to the low-res
        % camera image at the positions collected at low-res registration
        current.thumb_extract_w = cam_h*myData.settings.cam_lres2scan(slot_i);
        current.thumb_extract_h = cam_w*myData.settings.cam_lres2scan(slot_i);
        current.thumb_left = pos(1) - current.thumb_extract_w/2;
        current.thumb_top = pos(2) - current.thumb_extract_h/2;
        thumb_right = pos(1) + current.thumb_extract_w/2;
        thumb_bottom = pos(2) + current.thumb_extract_h/2;
        if current.thumb_left<1
            current.thumb_left=1;
        end
        if current.thumb_top<1
            current.thumb_top=1;
        end
        if thumb_right>wsi_w
           current.thumb_left = current.thumb_left - thumb_right + wsi_w;
        end
        if thumb_bottom>wsi_h
           current.thumb_top = current.thumb_top - thumb_bottom + wsi_h;
        end
    end
    
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
        current.thumb_w = current.thumb_scale*current.thumb_extract_h;           %3,9 o'clock
        current.thumb_h = current.thumb_scale*current.thumb_extract_w;
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
    smallThumb_file = [myData.registration_images_dir,...
        'lres_s', num2str(current.slot_i), '_thumb.tif'];
    smallThumb_image = imread(smallThumb_file);
    current.smallThumb_image_handle = image(smallThumb_image, 'Parent', handles.smallThumb_axes);
    axis(handles.smallThumb_axes,'image');
    set(handles.smallThumb_axes, ...
            'box', 'off', ...
            'xtick', [], ...
            'ytick', [], ...
            'Color', handles.myData.settings.Axes_BG, ...
            'interruptible', 'off', ...
            'busyaction', 'queue');
    handles.current = current;
    guidata(Stage_Allighment_handle, handles);
    
catch ME
    error_show(ME)
end

end

%% -------- For slot i take stage position i from camera
function take_stage(hObject, eventdata, handles)
try
    
    handles = guidata(handles.Stage_Allighment);
    myData = handles.myData;
    current = handles.current;
    stagedata = handles.myData.stagedata;
    settings = handles.myData.settings;
    
    slot_i = handles.current.slot_i;
    position_i = handles.current.position_i;
    
    % Initialize camera image settings
    current.cam_file = '';
    current.cam_image = 0;
    current.cam_left = 0;
    current.cam_top = 0;
    current.cam_x0 = 0;
    current.cam_y0 = 0;
    current.cam_extract_w = 0;
    current.cam_extract_h = 0;
    current.cam_w = myData.settings.cam_w;
    current.cam_h = myData.settings.cam_h;
    cam_w = current.cam_w;
    cam_h = current.cam_h;
    
    % Get stage position_i and camera image
    if handles.myData.yesno_micro==1
        myData.stage = stage_get_pos(myData.stage);
        temp = myData.stage.Pos;
        current.cam_x0 = temp(1);
        current.cam_y0 = temp(2);
        cam_image = camera_take_image(handles.cam);
        cam_w = settings.cam_w;
        cam_roi_w = settings.cam_roi_w;
        bot_w = cam_w/2 - cam_roi_w/2 + 1;
        top_w = bot_w + cam_roi_w - 1;
        cam_h = settings.cam_h;
        cam_roi_h = settings.cam_roi_h;
        bot_h = cam_h/2 - cam_roi_h/2 + 1;
        top_h = bot_h + cam_roi_h - 1;
        cam_image = cam_image(bot_h:top_h, bot_w:top_w, :);
    end
    
    % Set the low-res camera image filename and the current.cam2scan
    if current.reg_flag==0
        cam_file = [myData.registration_images_dir,...
            'lres_s', num2str(slot_i), 'p', num2str(position_i), '_cam.tif'];
        handles.current.cam_file = cam_file;
        handles.current.cam2scan = settings.cam_lres2scan(slot_i);
        cam2scan = settings.cam_lres2scan(slot_i);
    end
    
    % Set the high-res camera image filename and the current.cam2scan
    if current.reg_flag==1
        cam_file = [myData.registration_images_dir,...
            'hres_s', num2str(slot_i), 'p', num2str(position_i), '_cam.tif'];
        handles.current.cam_file = cam_file;
        handles.current.cam2scan = settings.cam_hres2scan(slot_i);
        cam2scan = settings.cam_hres2scan(slot_i);
    end
    
    if handles.myData.yesno_micro==0
        % When there is no microscope, stage, and camera, extract an
        % image from the WSI at the resolution of the camera and then
        % extract a sub-image that is the same size as a camera image.
        % This "fake-out" is to be able to develop "eeDAP" without
        % being conntected to the hardware. Numbers are specific to the
        % ThorLabs slide.
        wsi_file = current.wsi_file;
        
        % The coordinates below locate the crevice in the "R"
        % corresponding to "50UM GRID", "100UM GRID", and "500UM GRID"
        X0 = [18700, 36300, 44500, 50555];
        Y0 = [27100, 21600, 17300, 15888];
        current.cam_x0 = X0(position_i+1);
        current.cam_y0 = Y0(position_i+1);
        %            X1 = X0(position_i);
        %            Y1 = Y0(position_i);
        %            x_center = ceil(double(Y1)*double(thumb_w)/double(wsi_h));
        %            y_center = ceil(double(X1)*double(thumb_h)/double(wsi_w));
        
        % Extract an ROI with the same FOV as the camera
        % Notes:
        % eeDAP images are WSI images rotated 90 degree clockwise
        % Rotate = Transpose then reverse YDir
        extract_h = ceil(cam_w*cam2scan);
        extract_w = ceil(cam_h*cam2scan);
        extract_left = current.cam_x0-extract_w/2;
        extract_top  = current.cam_y0-extract_h/2;
        
        % Extraction of the low-resolution WSI Patch 1
        ExtractROI_BIO(current.wsi_info,...
            wsi_file,...
            cam_file,...
            extract_left,...
            extract_top,...
            extract_w,...
            extract_h,...
            cam_h,...
            cam_w,...
            handles.myData.settings.RotateWSI);
        
        % Read the fake camera image
        cam_image = imread(cam_file);
        
    end
    
    % Store the stage position_i locally and camera snapshot
    current.stage_positions = [current.cam_x0, current.cam_y0];
    current.cam_image = cam_image;
    imwrite(cam_image, cam_file, 'tif');
    
    % Store the stage position_i globally
    stagedata.stage_positions(position_i,:) = current.stage_positions;
    
    handles.current = current;
    myData.stagedata = stagedata;
    handles.myData = myData;
    guidata(handles.Stage_Allighment, handles);
    
catch ME
    error_show(ME)
end

end

%% -------- For slot i take WSI position i with mouse click
function thumb_image_ButtonDownFcn(hObject, eventdata, handles) %#ok<INUSL>
try
    
    handles = guidata(handles.Stage_Allighment);
    myData = handles.myData;
    current = handles.current;
    stagedata = handles.myData.stagedata;
    settings = myData.settings;
    
    slot_i = handles.current.slot_i;
    position_i = handles.current.position_i;
    
    wsi_file = current.wsi_info.fullname; %#ok<NASGU>
    wsi_w = current.wsi_info.wsi_w(1);
    wsi_h = current.wsi_info.wsi_h(1);
    cam_w = current.cam_w; %#ok<NASGU>
    cam_h = current.cam_h; %#ok<NASGU>
    thumb_w = current.thumb_w;
    thumb_h = current.thumb_h;
    thumb_left = current.thumb_left;
    thumb_top = current.thumb_top;
    
    cam_lres2scan = settings.cam_lres2scan(slot_i);
    scan2cam_lres = settings.scan2cam_lres(slot_i); %#ok<NASGU>
    cam_hres2scan = settings.cam_hres2scan(slot_i);
    scan2cam_hres = settings.scan2cam_hres(slot_i); %#ok<NASGU>
    
    % Get mouse click position. Thumb_axes origin is at the top left
    % Units are in terms of the pix_image
    temp = get(gca,'CurrentPoint');
    x_center = temp(1,1);
    y_center = temp(1,2);
    
    thumb_extract_w = current.thumb_extract_w;
    thumb_extract_h = current.thumb_extract_h;
    
    % Set the low-res WSI file name, extraction width and height
    if handles.current.reg_flag==0
        
        roi_file = [myData.registration_images_dir,...
            'lres_s',num2str(slot_i),'p',num2str(position_i),'_roi.tif'];
        roi_w = 2.0*settings.cam_roi_w;
        roi_h = 2.0*settings.cam_roi_h;
        roi_extract_h = roi_w*cam_lres2scan;
        roi_extract_w = roi_h*cam_lres2scan;
    end
    
    % Set the high-res WSI file name, extraction width and height
    if handles.current.reg_flag==1
        
        roi_file = [myData.registration_images_dir,...
            'hres_s',num2str(slot_i),'p',num2str(position_i),'_roi.tif'];
        roi_w = 2.0*settings.cam_roi_w;
        roi_h = 2.0*settings.cam_roi_h;
        roi_extract_h = roi_w*cam_hres2scan;
        roi_extract_w = roi_h*cam_hres2scan;
    end
    RotateWSI = settings.RotateWSI;
    switch RotateWSI
    % Notes:
    % eeDAP images are WSI images rotated 90 degree clockwise
    % Rotate = Transpose then reverse YDir
        case 270        % 6 o'clock
            roi_x0 = y_center*thumb_extract_w/thumb_h;
            roi_y0  = (thumb_w - x_center)*thumb_extract_h/thumb_w;
        case 90        % 12 o'clock
            roi_x0 = (thumb_h - y_center)*thumb_extract_w/thumb_h;
            roi_y0  = x_center*thumb_extract_h/thumb_w;
    end
    % The coordinates are relative to the thumbnail, map to wsi coordinates
    roi_x0 = roi_x0 + thumb_left - 1;
    roi_y0 = roi_y0 + thumb_top - 1;
    roi_left = roi_x0 - roi_extract_w/2;
    roi_top  = roi_y0 - roi_extract_h/2;
    
    % Must test that the WSI patch is completely within the WSI
    if ...
            roi_left - roi_extract_w/2< 1 ||...
            roi_top - roi_extract_h/2< 1 ||...
            roi_left + roi_extract_w + roi_extract_w/2> wsi_w ||...
            roi_top + roi_extract_h + roi_extract_h/2> wsi_h
        desc = 'ERROR: The region selected plus padding might not be completely inside the image. Please choose a location not so close to the boundary.';
        h_errordlg = errordlg(desc,'Take WSI Position Error','modal'); %#ok<NASGU>
        handles.take_wsi_flag = 0;
        %refresh the image
        current.thumb_image_handle = ...
        image(current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(current.thumb_image_handle,...
            'HitTest','on',...
            'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
        guidata(handles.Stage_Allighment, handles);
        return;
    end
    
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
    guidata(handles.Stage_Allighment, handles);
    
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

    % cam2scan for lres
    if handles.current.reg_flag==0
        cam2scan = settings.cam_lres2scan(slot_i);
    end
    % cam2scan for hres
    if handles.current.reg_flag==1
        cam2scan = settings.cam_hres2scan(slot_i);
    end
    
    % Scale factor to convert scanner pixels to thumbnail pixels
    % Remember that there is a rotation
    scan2thumb_w = current.thumb_w/current.thumb_extract_h;
    scan2thumb_h = current.thumb_h/current.thumb_extract_w;

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
    
    % Draw the green rectangle in thumbnail pixels
    desc = 'green';
    rect_w = settings.cam_w*cam2scan*scan2thumb_w;
    rect_h = settings.cam_h*cam2scan*scan2thumb_h;
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

    % Label the green box
    text(...
        'Parent', handles.thumb_axes,...
        'Units'             ,'data',...
        'Position'           ,[rect_left-rect_w/4, rect_top-rect_h/4],...
        'FontUnits'          ,'pixels',...
        'FontSize'           ,rect_h/4,...
        'FontWeight'         ,'bold',...
        'Color'              ,desc,...
        'String'             ,'camera',...
        'HitTest'   ,'off');

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

catch ME
    error_show(ME)
end

end

%% -------- refine_registration button
% function refine_registration_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% try
%     
%     % Prepare for the next step
%     set(handles.take_stage1, 'Enable', 'on');
%     set(handles.refine_registration, 'Enable', 'off');
%     
%     handles.current.reg_flag = 1;
%     handles.current.position_i = 1;
%     guidata(handles.Stage_Allighment, handles);
%     display_thumb(handles.Stage_Allighment)
%     load_last_calibration_Callback(hObject, eventdata, handles)
% catch ME
%     error_show(ME)
% end
% 
% end

%% --- Executes on button press in restart_registration.
function restart_registration_Callback(hObject, eventdata, handles)
% hObject    handle to restart_registration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    myData = handles.myData;
    settings = myData.settings;
    current = handles.current;
    current.reg_flag = 0; %#ok<NASGU>
    slot_i = current.slot_i;
    wsi_info = current.wsi_info;
     % Initialze the state of the GUI
    set(handles.take_stage1,...
       'Enable','on',...
       'String','Take Stage Position 1');
    set(handles.take_stage2,...
       'Enable','off',...
       'String','Take Stage Position 2');
    set(handles.take_stage3,...
       'Enable','off',...
       'String','Take Stage Position 3');
    set(handles.take_wsi1,'Enable','off');
    set(handles.take_wsi2,'Enable','off');
    set(handles.take_wsi3,'Enable','off');

    % Initialize registration parameters corresponding to slot_i
 
    current.position_i = 1;
    current.thumb_positions = [0, 0];
    current.stage_positions = [0, 0];
    current.wsi_positions = [0, 0];
    
    % Initialize stagedata
    % The three pairs of stage and wsi positions [x,y] will be recorded
    stagedata = struct;
    stagedata.stage_positions = zeros(3,2);
    stagedata.wsi_positions = zeros(3,2);
    stagedata.thumb_positions = zeros(3,2);
    
    temp = textscan(wsi_info.fullname, '%s %s', 'delimiter', '.');
    stagedata.stagedata_file = [char(temp{1}),'.mat'];
    
    % Initialize the low-resolution conversions between scanner and camera
    current.scan2cam = myData.settings.scan2cam_lres;
    current.cam2scan = myData.settings.cam_lres2scan;
    
    % Initialize the thumbnail settings
    current.thumb_file = [myData.registration_images_dir,...
        'lres_s', num2str(slot_i), '_thumb.tif'];
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
    
    % Initialize the ROI settings
    current.roi_file = '';
    current.roi_image = 0;
    current.roi_left = 0;
    current.roi_top = 0;
    current.roi_w = 0;
    current.roi_h = 0;
    current.roi_x0 = 0;
    current.roi_y0 = 0;
    current.roi_extract_w = 0;
    current.roi_extract_h = 0;
    
    handles.output = hObject;
    current.load_stage_data = zeros(1,3);
    handles.current = current;
    myData.stagedata = stagedata;
    myData.settings = settings;
    handles.myData = myData;
    guidata(handles.Stage_Allighment, handles);
    
    display_thumb(handles.Stage_Allighment);
catch ME
    error_show(ME)
end
end




%% -------- take_stage*** buttons' callbacks
function take_stage1_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    
    handles = guidata(handles.Stage_Allighment);
    
    handles.current.position_i = 1;
    
    if handles.current.load_stage_data(1) == 1
        display('automatically navigate to position 1')
        handles.myData.stage=stage_move(handles.myData.stage,handles.myData.stagedata.stage_positions(1,:));       
        set(handles.take_stage1,'String','Take Stage Position 1');
        handles.current.load_stage_data(1) = 2;       
        guidata(handles.Stage_Allighment,handles);
        return
    end
    
    set(handles.take_stage1,'Enable','off');
    take_stage(hObject, eventdata, handles);
    handles = guidata(handles.Stage_Allighment);
    x = handles.myData.stagedata.stage_positions(1,1);
    y = handles.myData.stagedata.stage_positions(1,2);
    set(handles.stage_1x,'String',x);
    set(handles.stage_1y,'String',y);
    
    % Prepare for the next step
    handles.take_wsi_flag = 0;
    
    set(handles.take_wsi1,'Enable','on');
    set(handles.current.thumb_image_handle,...
        'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
    
    guidata(handles.Stage_Allighment,handles);
    
catch ME
    error_show(ME)
end

end

% --- Executes on button press in take_stage2.
function take_stage2_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    
    handles = guidata(handles.Stage_Allighment);
    
    handles.current.position_i = 2;
    
    if handles.current.load_stage_data(2) == 1
        display('automatically navigate to position 2')
        handles.myData.stage=stage_move(handles.myData.stage,handles.myData.stagedata.stage_positions(2,:));           
        set(handles.take_stage2,'String','Take Stage Position 2');
        handles.current.load_stage_data(2) = 2;        
        guidata(handles.Stage_Allighment,handles);
        return
    end
    
    set(handles.take_stage2,'Enable','off');
    take_stage(hObject, eventdata, handles);
    handles = guidata(handles.Stage_Allighment);
    x = handles.myData.stagedata.stage_positions(2,1);
    y = handles.myData.stagedata.stage_positions(2,2);
    set(handles.stage_2x,'String',x);
    set(handles.stage_2y,'String',y);
    
    % Prepare for the next step
    handles.take_wsi_flag = 0;
    
    set(handles.take_wsi2,'Enable','on');
    set(handles.current.thumb_image_handle,...
        'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
    
    guidata(handles.Stage_Allighment,handles);
    
catch ME
    error_show(ME)
end

end

% --- Executes on button press in take_stage3.
function take_stage3_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    
    handles.current.position_i = 3;
    
    if handles.current.load_stage_data(3) == 1
        display('automatically navigate to position 3')
        handles.myData.stage=stage_move(handles.myData.stage,handles.myData.stagedata.stage_positions(3,:));     
        set(handles.take_stage3,'String','Take Stage Position 3');
        handles.current.load_stage_data(3) = 2;
        guidata(handles.Stage_Allighment,handles);
        return
    end
    
    set(handles.take_stage3,'Enable','off');
    take_stage(hObject, eventdata, handles);
    handles = guidata(handles.Stage_Allighment);
    x = handles.myData.stagedata.stage_positions(3,1);
    y = handles.myData.stagedata.stage_positions(3,2);
    set(handles.stage_3x,'String',x);
    set(handles.stage_3y,'String',y);
    
    % Prepare for the next step
    handles.take_wsi_flag = 0;
    
    set(handles.take_wsi3,'Enable','on');
    set(handles.current.thumb_image_handle,...
        'HitTest','on',...
        'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
    
    guidata(handles.Stage_Allighment,handles);
    
catch ME
    error_show(ME)
end

end





%% -------- take_wsi*** buttons' callbacks
function take_wsi1_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    
    if handles.take_wsi_flag==0
        desc = 'Please click on the WSI at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    
    set(handles.take_wsi1,'Enable','off');
    set(handles.current.thumb_image_handle,'HitTest','off');
    Register_ROI(handles);
    handles = guidata(handles.Stage_Allighment);
    
    if handles.current.registration_good==0
        % Refresh the image
        handles.current.thumb_image_handle = ...
            image(handles.current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(handles.current.thumb_image_handle,'HitTest','off');
        
        % Reset state to repeat registration
        handles.take_wsi_flag = 0;
        set(handles.take_stage1,'Enable','on');
        
        guidata(handles.Stage_Allighment,handles);
        return;
    end
    
    handles.myData.stagedata.wsi_positions(1,1) = handles.current.roi_x0;
    handles.myData.stagedata.wsi_positions(1,2) = handles.current.roi_y0;
    set(handles.wsi_1x,'String',handles.current.roi_x0);
    set(handles.wsi_1y,'String',handles.current.roi_y0);
    
    
    % Prepare for the next step
    set(handles.take_stage2,'Enable','on');
    
    handles.current.position_i = 2;
    guidata(handles.Stage_Allighment,handles);
    
    display_thumb(handles.Stage_Allighment)
    
catch ME
    error_show(ME)
end

end

% --- Executes on button press in take_wsi2.
function take_wsi2_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    if handles.take_wsi_flag==0
        desc = 'Please click on the WSI at the location corresponding to the stage position.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    
    set(handles.take_wsi2,'Enable','off');
    set(handles.current.thumb_image_handle,'HitTest','off');
    Register_ROI(handles);
    handles = guidata(handles.Stage_Allighment);
    
    if handles.current.registration_good==0
        % Refresh the image
        handles.current.thumb_image_handle = ...
            image(handles.current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(handles.current.thumb_image_handle,'HitTest','off');
        
        %        set(handles.current.thumb_image_handle,...
        %            'HitTest','off',...
        %            'ButtonDownFcn', {@thumb_image_ButtonDownFcn,handles});
        
        % Reset state to repeat registration
        handles.take_wsi_flag = 0;
        set(handles.take_stage2,'Enable','on');
        set(handles.take_wsi2,'Enable','off');
        
        guidata(handles.Stage_Allighment,handles);
        return;
    end
    
    handles.myData.stagedata.wsi_positions(2,1) = handles.current.roi_x0;
    handles.myData.stagedata.wsi_positions(2,2) = handles.current.roi_y0;
    set(handles.wsi_2x,'String',handles.current.roi_x0);
    set(handles.wsi_2y,'String',handles.current.roi_y0);
    
    % Prepare for the next step
    set(handles.take_stage3,'Enable','on');
    
    handles.current.position_i = 3;
    guidata(handles.Stage_Allighment,handles);
    
    display_thumb(handles.Stage_Allighment)
    
catch ME
    error_show(ME)
end

end

% --- Executes on button press in take_wsi3.
function take_wsi3_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    if handles.take_wsi_flag==0
        desc = 'Please click on the WSI at the location corresponding to the stage position.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    
    stagedata = handles.myData.stagedata; %#ok<NASGU>
    
    set(handles.take_wsi3,'Enable','off');
    set(handles.current.thumb_image_handle,'HitTest','off');
    Register_ROI(handles);
    handles = guidata(handles.Stage_Allighment);
    
    if handles.current.registration_good==0
        % Refresh the image
        handles.current.thumb_image_handle = ...
            image(handles.current.thumb_image,'Parent',handles.thumb_axes);
        axis(handles.thumb_axes,'image');
        set(handles.current.thumb_image_handle,'HitTest','off');
        
        % Reset state to repeat registration
        handles.take_wsi_flag = 0;
        set(handles.take_stage3,'Enable','on');
        set(handles.take_wsi3,'Enable','off');
        
        guidata(handles.Stage_Allighment,handles);
        return;
    end
    
    handles.myData.stagedata.wsi_positions(3,1) = handles.current.roi_x0;
    handles.myData.stagedata.wsi_positions(3,2) = handles.current.roi_y0;
    set(handles.wsi_3x,'String',handles.current.roi_x0);
    set(handles.wsi_3y,'String',handles.current.roi_y0);
    
    % Save the current stagedata
    save(handles.myData.stagedata.stagedata_file,'stagedata');
    
    % Prepare for the next step
   % set(handles.refine_registration,'Enable','on');
    
    switch handles.current.reg_flag
        case 0
            handles.current.position_i = 0;
            guidata(handles.Stage_Allighment,handles);
            display_thumb(handles.Stage_Allighment)
        case 1
            % Report success to Admin_Input
            handles_old = guidata(handles.Administrator_Input_Screen);
            handles_old.current.success(handles.current.slot_i) = 1;
            handles_old.myData = handles.myData;
            guidata(handles.Administrator_Input_Screen,handles_old);
            % Close the image preview figure
            close(handles.cam_figure)
            delete(handles.cam)
            
            close(handles.Stage_Allighment);
            return
    end
    
catch ME
    error_show(ME)
end

end





%% -------- Abort button callback
function Abort_Callback(hObject, eventdata, handles) %#ok<*INUSD,DEFNU>
try
    
    close(handles.Stage_Allighment);
    
catch ME
    error_show(ME)
end

end

%% -------- Load_last_calibration button callback
function load_last_calibration_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    % hObject    handle to load_last_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    stagedata_file = handles.myData.stagedata.stagedata_file;
    if exist(stagedata_file, 'file')
        load(stagedata_file)
        stagedata.stagedata_file = stagedata_file;

        set(handles.take_stage1,...
            'Enable','on',...
            'String','GOTO position 1');
        set(handles.take_stage2,...
            'Enable','off',...
            'String','GOTO position 2');
        set(handles.take_stage3,...
            'Enable','off',...
            'String','GOTO position 3');

        x = stagedata.stage_positions(1,1);
        y = stagedata.stage_positions(1,2);
        set(handles.stage_1x,'String',x);
        set(handles.stage_1y,'String',y);

        x = stagedata.stage_positions(2,1);
        y = stagedata.stage_positions(2,2);
        set(handles.stage_2x,'String',x);
        set(handles.stage_2y,'String',y);

        x = stagedata.stage_positions(3,1);
        y = stagedata.stage_positions(3,2);
        set(handles.stage_3x,'String',x);
        set(handles.stage_3y,'String',y);

        set(handles.take_wsi1,'Enable','off');
        set(handles.take_wsi2,'Enable','off');
        set(handles.take_wsi3,'Enable','off');

        x = stagedata.wsi_positions(1,1);
        y = stagedata.wsi_positions(1,2);
        set(handles.wsi_1x,'String',x);
        set(handles.wsi_1y,'String',y);

        x = stagedata.wsi_positions(2,1);
        y = stagedata.wsi_positions(2,2);
        set(handles.wsi_2x,'String',x);
        set(handles.wsi_2y,'String',y);

        x = stagedata.wsi_positions(3,1);
        y = stagedata.wsi_positions(3,2);
        set(handles.wsi_3x,'String',x);
        set(handles.wsi_3y,'String',y);

        handles.current.reg_flag = 1;
        handles.current.position_i = 1;

        handles.myData.stagedata = stagedata;
        handles.current.load_stage_data = ones(1,3);
        guidata(handles.Stage_Allighment,handles);
        set(handles.Done,'Enable','on');
        display_thumb(handles.Stage_Allighment)
    else
        desc = ['Unable to read file ',stagedata_file, '. Please do low resolution registration.'];    
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg);
    end
    
catch ME
    error_show(ME)
end

end

%% -------- Show the camera image.
function Video_Callback(hObject, eventdata, handles) %#ok<DEFNU>
try
    % hObject    handle to Video (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    figure(handles.cam_figure)
    
catch ME
    error_show(ME)
end

end





%% -------- x,y text boxes' CreateFcn's
% --- Executes during object creation, after setting all properties.
function wsi_1x_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to wsi_1x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function wsi_1y_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to wsi_1y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function stage_1x_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stage_1x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function stage_1y_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stage_1y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function wsi_2x_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to wsi_2x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function wsi_2y_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to wsi_2y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function stage_2x_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stage_2x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function stage_2y_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stage_2y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function wsi_3x_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to wsi_3x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function wsi_3y_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to wsi_3y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function stage_3x_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stage_3x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes during object creation, after setting all properties.
function stage_3y_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to stage_3y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in Done.
function Done_Callback(hObject, eventdata, handles)
% hObject    handle to Done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
            handles_old = guidata(handles.Administrator_Input_Screen);
            handles_old.current.success(handles.current.slot_i) = 1;
            handles_old.myData = handles.myData;
            guidata(handles.Administrator_Input_Screen,handles_old);
            % Close the image preview figure
            close(handles.cam_figure)
            delete(handles.cam)
            
            close(handles.Stage_Allighment);
end

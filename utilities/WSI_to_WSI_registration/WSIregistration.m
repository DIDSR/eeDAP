function varargout = WSIregistration(varargin)
% WSIREGISTRATION MATLAB code for WSIregistration.fig
%      WSIREGISTRATION, by itself, creates a new WSIREGISTRATION or raises the existing
%      singleton*.
%
%      H = WSIREGISTRATION returns the handle to a new WSIREGISTRATION or the handle to
%      the existing singleton*.
%
%      WSIREGISTRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WSIREGISTRATION.M with the given input arguments.
%
%      WSIREGISTRATION('Property','Value',...) creates a new WSIREGISTRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WSIregistration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WSIregistration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WSIregistration

% Last Modified by GUIDE v2.5 12-Mar-2019 15:21:38

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @WSIregistration_OpeningFcn, ...
                       'gui_OutputFcn',  @WSIregistration_OutputFcn, ...
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

% --- Executes just before WSIregistration is made visible.
function WSIregistration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WSIregistration (see VARARGIN)

% Choose default command line output for WSIregistration
    addpath('bfmatlab');   
    handles.output = hObject;
    scrsz = get(0, 'ScreenSize');
    figuresz=getpixelposition(gcf);
    setpixelposition(gcf,[scrsz(3)/2-figuresz(3)/2 ...
        scrsz(4)/2-figuresz(4)/2 figuresz(3) figuresz(4)]);
    handles.finished_onepoint = [0,0];
    % Update handles structure
    set(handles.load_WSI_A,'Enable','on');
    set(handles.load_WSI_B,'Enable','off');
    set(handles.start_registration,'Enable','off');
    set(handles.position_1,'Enable','off');
    set(handles.position_2,'Enable','off');
    set(handles.position_3,'Enable','off');
    set(handles.loadBasedPosition,'Enable','off');
    set(handles.getNewPositions,'Enable','off');
    guidata(handles.WSIregistration,handles);
end
% UIWAIT makes WSIregistration wait for user response (see UIRESUME)
% uiwait(handles.WSIregistration);


% --- Outputs from this function are returned to the command line.
function varargout = WSIregistration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in start_registration.
function start_registration_Callback(hObject, eventdata, handles)
% hObject    handle to start_registration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.working_dir = ...
        [pwd, '\Register_Two_WSI\'];
         
    if ~isdir(handles.working_dir)
        mkdir(handles.working_dir);
    end
    handles.registration_images_dir = ...
        [pwd, '\Register_Two_WSI\Temporary_Registration_Images\'];
    files = [handles.registration_images_dir, '*.tif'];    
    if isdir(handles.registration_images_dir)
        delete(files);
    else
        mkdir(handles.registration_images_dir);
    end
    handles.registration_result = ...
        [pwd, '\Register_Two_WSI\translation',handles.WSI_A.name,'_To_',handles.WSI_B.name,'.mat'];
    set(handles.start_registration,'Enable','off');
    set(handles.position_1,'Enable','on');
    guidata(handles.WSIregistration,handles);
end


%% WSI A.
% load WSI A
function load_WSI_A_Callback(hObject, eventdata, handles)
% hObject    handle to load_WSI_A (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % load WSI A
    [WSI_A_file, workdir] = uigetfile('*.*', 'Select a WSI file');
    workdir_WSI_A_file = [workdir, WSI_A_file];   
    WSI_data = bfGetReader(workdir_WSI_A_file);
        % get size of each resolution, Ignore the last two because there
        % are image with label
    WSI_data.setSeries(0);
    wsi_w(1)= WSI_data.getSizeX();
    wsi_h(1)= WSI_data.getSizeY();
    numberOfImages = WSI_data.getSeriesCount();

    for j = 1 : numberOfImages - 3
        WSI_data.setSeries(j);
        wsi_w(j+1)= WSI_data.getSizeX();
        wsi_h(j+1)= WSI_data.getSizeY();
    end
    dotindex = find(WSI_A_file=='.');
    WSI_A_file = WSI_A_file(1:dotindex(end)-1);
    omeMeta = WSI_data.getMetadataStore();
    WSI_A.MPP = double(omeMeta.getPixelsPhysicalSizeX(0).value());
    WSI_A.name = WSI_A_file;
    WSI_A.WSI_data = WSI_data;
    WSI_A.fullname=workdir_WSI_A_file;
    WSI_A.wsi_w = wsi_w;
    WSI_A.wsi_h = wsi_h;
    handles.WSI_A=WSI_A;
    % color look up table, we may avoid it.
    fid2 = fopen([pwd,'/icc_profiles/rgb_lut_gamma_inv1p8.txt']);
    rgb_lut = uint8(zeros(256,3));
    for channel=1:3
        for level=1:256
            tline2 = fgets(fid2);
            rgb_lut(level,channel) = uint8(str2double(tline2));
        end
    end
    WSI_A.rgb_lut = rgb_lut;
    WSI_A.RotateWSI = 90;
    guidata(handles.WSIregistration,handles);
    
    
    % set WSI A thumbnail
     WSI_A.thumb_file = [pwd,'/WSI_A_thumb.tif'];
     WSI_A.thumb_image = 0;
     WSI_A.thumb_left = 1;
     WSI_A.thumb_top = 1;
     WSI_A.thumb_w = 0;
     WSI_A.thumb_h = 1000;
     WSI_A.thumb_x0 = 0;
     WSI_A.thumb_y0 = 0;
     WSI_A.thumb_extract_w = WSI_A.wsi_w(1);
     WSI_A.thumb_extract_h = WSI_A.wsi_h(1);
     if WSI_A.thumb_extract_w > WSI_A.thumb_extract_h
            WSI_A.thumb_w = 1000;
            WSI_A.thumb_h = 0;
     end
     WSI_A.thumb_image_handle = 0;
     handles.WSI_A = WSI_A;
    
    
    set(handles.load_WSI_B,'Enable','on');
    guidata(handles.WSIregistration, handles);
    display_thumb_A(handles.WSIregistration);
    
    
end

% Display the WSI A thumbnail 
function display_thumb_A(WSIregistration_handle)
    
    handles = guidata(WSIregistration_handle);
    WSI_A = handles.WSI_A;
  %%%%%  current.cam2scan = myData.settings.cam_hres2scan(myData.currentslot);
    WSI_A.thumb_w = 0;
    WSI_A.thumb_h = 1000;
    if WSI_A.thumb_extract_w > WSI_A.thumb_extract_h
        WSI_A.thumb_w = 1000;
        WSI_A.thumb_h = 0;
        WSI_A.thumb_scale = 1000.0/WSI_A.thumb_extract_w;
    else
        WSI_A.thumb_scale = 1000.0/WSI_A.thumb_extract_h;
    end
    
    if WSI_A.RotateWSI == 0 || WSI_A.RotateWSI== 180
        WSI_A.thumb_h = WSI_A.thumb_scale*WSI_A.thumb_extract_h;           %3,9 o'clock
        WSI_A.thumb_w = WSI_A.thumb_scale*WSI_A.thumb_extract_w;
    else
        WSI_A.thumb_w = WSI_A.thumb_scale*WSI_A.thumb_extract_w;           %6,12 o'clock
        WSI_A.thumb_h = WSI_A.thumb_scale*WSI_A.thumb_extract_h;
    end
    
    ExtractROI_BIO(WSI_A,...
        WSI_A.fullname,...
        WSI_A.thumb_file,...
        WSI_A.thumb_left,...
        WSI_A.thumb_top,...
        WSI_A.thumb_extract_w,...
        WSI_A.thumb_extract_h,...
        WSI_A.thumb_w,...
        WSI_A.thumb_h,...
        90,...
        WSI_A.rgb_lut);
    
    if WSI_A.RotateWSI == 0 || WSI_A.RotateWSI== 180       
        temp = WSI_A.thumb_w;
        WSI_A.thumb_w = floor(WSI_A.thumb_w);           %3,9 o'clock
        WSI_A.thumb_h = floor(WSI_A.thumb_h);
    else
        temp = WSI_A.thumb_w;
        WSI_A.thumb_w = floor(WSI_A.thumb_h);           %6,12 o'clock
        WSI_A.thumb_h = floor(temp);
    end
    
    WSI_A.thumb_image = imread(WSI_A.thumb_file);
    WSI_A.thumb_image_handle = image(WSI_A.thumb_image, 'Parent', handles.axes_WSIA);
    
    axis(handles.axes_WSIA,'image');
   
    % add label 
   
    yMax = WSI_A.wsi_w(1);
    yLabel = handles.axes_WSIA.YTickLabel;
    for i = 1:length(yLabel)
        yLabel{i} = num2str(round(yMax/length(yLabel)*i));
    end
    handles.axes_WSIA.YTickLabel = yLabel;
    handles.axes_WSIA.YLabel.String = 'X';
    
    
    xMax = WSI_A.wsi_h(1);    

    xLabel = handles.axes_WSIA.XTickLabel;
    for i = 1:length(xLabel) 
        xLabel{i} = num2str(round(xMax/length(xLabel)*i));
    end
    handles.axes_WSIA.XTickLabel = xLabel;
    handles.axes_WSIA.YLabel.String = 'Y';
    
    
   
   
   
   
   set(WSI_A.thumb_image_handle,...
            'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_A_ButtonDownFcn,handles});
   handles.WSI_A = WSI_A;
   handles.take_wsi_A_flag = 0;
    guidata(handles.WSIregistration, handles);

end

function thumb_WSI_A_ButtonDownFcn(hObject, eventdata, handles) %#ok<INUSL>
  
    handles = guidata(handles.WSIregistration);
    WSI_A = handles.WSI_A;
    
    wsi_w = WSI_A.wsi_w(1);
    wsi_h = WSI_A.wsi_h(1);
    thumb_w = WSI_A.thumb_w;
    thumb_h = WSI_A.thumb_h;
    thumb_left = WSI_A.thumb_left;
    thumb_top = WSI_A.thumb_top;
    
%     cam_hres2scan = settings.cam_hres2scan(slot_i);
%     scan2cam_hres = settings.scan2cam_hres(slot_i); %#ok<NASGU>
    
    % Get mouse click position. Thumb_axes origin is at the top left
    % Units are in terms of the pix_image
    temp = get(gca,'CurrentPoint');
    x_center = temp(1,1);
    y_center = temp(1,2);
    
    thumb_extract_w = WSI_A.thumb_extract_w;
    thumb_extract_h = WSI_A.thumb_extract_h;
    
    
    roi_file = [handles.registration_images_dir,'temp_roiA.tif'];
    roi_w = 1000;
    roi_h = 1000;
    roi_extract_h = roi_w;
    roi_extract_w = roi_h;  
    
   
    switch WSI_A.RotateWSI
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
    WSI_A.roi_file = roi_file;
    WSI_A.roi_x0 = roi_x0;
    WSI_A.roi_y0 = roi_y0;
    WSI_A.roi_left = roi_left;
    WSI_A.roi_top = roi_top;
    WSI_A.roi_extract_w = roi_extract_w;
    WSI_A.roi_extract_h = roi_extract_h;
    WSI_A.roi_w = roi_w;
    WSI_A.roi_h = roi_h;
    
    % Store the WSI position_i locally and globally and WSI patch
    WSI_A.wsi_positions = [roi_x0, roi_y0];
    WSI_A.thumb_positions = [x_center, y_center];
    
    
    % The following will refresh the image
    if handles.take_wsi_A_flag==1
        WSI_A.thumb_image_handle = ...
            image(WSI_A.thumb_image,'Parent',handles.axes_WSIA);
        axis(handles.axes_WSIA,'image');
        set(WSI_A.thumb_image_handle,...
            'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_A_ButtonDownFcn,handles});
    end
    handles.take_wsi_A_flag = 1;
    
    handles.WSI_A = WSI_A;
    guidata(handles.WSIregistration, handles);
    
    % Annotate the image with boxes marking the registration ROIs
    annotate_WSI_A(handles)

end

%% -------- Annotate the thumbnail image
function annotate_WSI_A(handles)
    % Place a rectangle on thumb_axes centered on mouse click
    % Blue box is camera roi for extraction
    % Red box is WSI roi for extraction (twice blue box)
    % Green box is the camera view
    
    % position_i indicates one of the three registration locations
    WSI_A = handles.WSI_A;

    x_center = WSI_A.thumb_positions(1);
    y_center = WSI_A.thumb_positions(2);
    
    % Scale factor to convert scanner pixels to thumbnail pixels
    % Remember that there is a rotation
     if WSI_A.RotateWSI == 0 || WSI_A.RotateWSI== 180
        scan2thumb_w = WSI_A.thumb_w/WSI_A.thumb_extract_w;
        scan2thumb_h = WSI_A.thumb_h/WSI_A.thumb_extract_h;
     else
        scan2thumb_w = WSI_A.thumb_w/WSI_A.thumb_extract_h;
        scan2thumb_h = WSI_A.thumb_h/WSI_A.thumb_extract_w;
     end
    % Size of blue rectangle in thumbnail pixels
    desc = 'blue';
    rect_w = WSI_A.roi_w*scan2thumb_w;
    rect_h = WSI_A.roi_h*scan2thumb_h;
    rect_left = x_center - rect_w/2;
    rect_top = y_center - rect_h/2;
    rectangle(...
        'Parent', handles.axes_WSIA,...
        'Position'  ,[rect_left, rect_top, rect_w, rect_h],...
        'Curvature' ,[0,0],...
        'LineWidth' ,2,...
        'LineStyle' ,'--',...
        'EdgeColor' ,desc,...
        'Tag'       ,'mark',...
        'HitTest'   ,'off');

% 
%         % Label the blue box
%     text(...
%         'Parent', handles.axes_WSIA,...
%         'Units'             ,'data',...
%         'Position'           ,[rect_left-rect_w/4, rect_top+rect_h+rect_h/4],...
%         'FontUnits'          ,'pixels',...
%         'FontSize'           ,rect_h/4,...
%         'FontWeight'         ,'bold',...
%         'Color'              ,'blue',...
%         'String'             ,'WSI A ROI',...
%         'HitTest'   ,'off');
%     a=1;


end


%% load and display WSI B.
function load_WSI_B_Callback(hObject, eventdata, handles)
% hObject    handle to load_WSI_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
          % load WSI A
    [WSI_B_file, workdir] = uigetfile('*.*', 'Select a WSI file');
    workdir_WSI_B_file = [workdir, WSI_B_file];   
    WSI_data = bfGetReader(workdir_WSI_B_file);
        % get size of each resolution, Ignore the last two because there
        % are image with label
    WSI_data.setSeries(0);
    wsi_w(1)= WSI_data.getSizeX();
    wsi_h(1)= WSI_data.getSizeY();
    numberOfImages = WSI_data.getSeriesCount();
    for j = 1 : numberOfImages - 3
        WSI_data.setSeries(j);
        wsi_w(j+1)= WSI_data.getSizeX();
        wsi_h(j+1)= WSI_data.getSizeY();
    end
    dotindex = find(WSI_B_file=='.');
    WSI_B_file = WSI_B_file(1:dotindex(end)-1);
    omeMeta = WSI_data.getMetadataStore();
    WSI_B.name = WSI_B_file;
    WSI_B.MPP = double(omeMeta.getPixelsPhysicalSizeX(0).value());
    WSI_B.WSI_data = WSI_data;
    WSI_B.fullname=workdir_WSI_B_file;
    WSI_B.wsi_w = wsi_w;
    WSI_B.wsi_h = wsi_h;
    WSI_B.rgb_lut = [pwd,'/icc_profiles/rgb_lut_gamma_inv1p8.txt'];
    handles.WSI_B=WSI_B;
    
    % color look up table, we may avoid it.
    fid2 = fopen([pwd,'/icc_profiles/rgb_lut_gamma_inv1p8.txt']);
    rgb_lut = uint8(zeros(256,3));
    for channel=1:3
        for level=1:256
            tline2 = fgets(fid2);
            rgb_lut(level,channel) = uint8(str2double(tline2));
        end
    end
    WSI_B.rgb_lut = rgb_lut;
    WSI_B.RotateWSI = 90;
    guidata(handles.WSIregistration,handles);
    
    % set WSI A thumbnail
     WSI_B.thumb_file = [pwd,'/WSI_B_thumb.tif'];
     WSI_B.thumb_image = 0;
     WSI_B.thumb_left = 1;
     WSI_B.thumb_top = 1;
     WSI_B.thumb_w = 0;
     WSI_B.thumb_h = 1000;
     WSI_B.thumb_x0 = 0;
     WSI_B.thumb_y0 = 0;
     WSI_B.thumb_extract_w = WSI_B.wsi_w(1);
     WSI_B.thumb_extract_h = WSI_B.wsi_h(1);
     if WSI_B.thumb_extract_w > WSI_B.thumb_extract_h
            WSI_B.thumb_w = 1000;
            WSI_B.thumb_h = 0;
     end
     WSI_B.thumb_image_handle = 0;
     handles.WSI_B = WSI_B;
    
    handles.WSIA_2_WSIB = handles.WSI_A.MPP/WSI_B.MPP;
    set(handles.start_registration,'Enable','on');
    guidata(handles.WSIregistration, handles);
    display_thumb_B(handles.WSIregistration);
end
% -------- Display the WSI B thumbnail 
function display_thumb_B(WSIregistration_handle)
   
    handles = guidata(WSIregistration_handle);
    WSI_B = handles.WSI_B;
  %%%%%  current.cam2scan = myData.settings.cam_hres2scan(myData.currentslot);
    WSI_B.thumb_w = 0;
    WSI_B.thumb_h = 1000;
    if WSI_B.thumb_extract_w > WSI_B.thumb_extract_h
        WSI_B.thumb_w = 1000;
        WSI_B.thumb_h = 0;
        WSI_B.thumb_scale = 1000.0/WSI_B.thumb_extract_w;
    else
        WSI_B.thumb_scale = 1000.0/WSI_B.thumb_extract_h;
    end
    
    if WSI_B.RotateWSI == 0 || WSI_B.RotateWSI== 180
        WSI_B.thumb_h = WSI_B.thumb_scale*WSI_B.thumb_extract_h;           %3,9 o'clock
        WSI_B.thumb_w = WSI_B.thumb_scale*WSI_B.thumb_extract_w;
    else
        WSI_B.thumb_w = WSI_B.thumb_scale*WSI_B.thumb_extract_w;           %6,12 o'clock
        WSI_B.thumb_h = WSI_B.thumb_scale*WSI_B.thumb_extract_h;
    end
    
    
    ExtractROI_BIO(WSI_B,...
        WSI_B.fullname,...
        WSI_B.thumb_file,...
        WSI_B.thumb_left,...
        WSI_B.thumb_top,...
        WSI_B.thumb_extract_w,...
        WSI_B.thumb_extract_h,...
        WSI_B.thumb_w,...
        WSI_B.thumb_h,...
        90,...
        WSI_B.rgb_lut);
    
    if WSI_B.RotateWSI == 0 || WSI_B.RotateWSI== 180       
        temp = WSI_B.thumb_w;
        WSI_B.thumb_w = floor(WSI_B.thumb_w);           %3,9 o'clock
        WSI_B.thumb_h = floor(WSI_B.thumb_h);
    else
        temp = WSI_B.thumb_w;
        WSI_B.thumb_w = floor(WSI_B.thumb_h);           %6,12 o'clock
        WSI_B.thumb_h = floor(temp);
    end
    
    WSI_B.thumb_image = imread(WSI_B.thumb_file);
    WSI_B.thumb_image_handle = image(WSI_B.thumb_image, 'Parent', handles.axes_WSIB);
    
    
    yMax = WSI_B.wsi_w(1);
    yLabel = handles.axes_WSIB.YTickLabel;
    for i = 1:length(yLabel)
        yLabel{i} = num2str(round(yMax/length(yLabel)*i));
    end
    handles.axes_WSIB.YTickLabel = yLabel;
    handles.axes_WSIB.YLabel.String = 'X';
    
    
    xMax = WSI_B.wsi_h(1);    

    xLabel = handles.axes_WSIB.XTickLabel;
    for i = 1:length(xLabel) 
        xLabel{i} = num2str(round(xMax/length(xLabel)*i));
    end
    handles.axes_WSIB.XTickLabel = xLabel;
    handles.axes_WSIB.YLabel.String = 'Y';
    
    
    axis(handles.axes_WSIB,'image');
    set(WSI_B.thumb_image_handle,...
            'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_B_ButtonDownFcn,handles});
    handles.WSI_B = WSI_B;
    handles.take_wsi_B_flag = 0;
    guidata(handles.WSIregistration, handles);

end

function thumb_WSI_B_ButtonDownFcn(hObject, eventdata, handles) %#ok<INUSL>
  
    handles = guidata(handles.WSIregistration);
    WSI_B = handles.WSI_B;
    
    wsi_w = WSI_B.wsi_w(1);
    wsi_h = WSI_B.wsi_h(1);
    thumb_w = WSI_B.thumb_w;
    thumb_h = WSI_B.thumb_h;
    thumb_left = WSI_B.thumb_left;
    thumb_top = WSI_B.thumb_top;
    
    
%     cam_hres2scan = settings.cam_hres2scan(slot_i);
%     scan2cam_hres = settings.scan2cam_hres(slot_i); %#ok<NASGU>
    
    % Get mouse click position. Thumb_axes origin is at the top left
    % Units are in terms of the pix_image
    temp = get(gca,'CurrentPoint');
    x_center = temp(1,1);
    y_center = temp(1,2);
    
    thumb_extract_w = WSI_B.thumb_extract_w;
    thumb_extract_h = WSI_B.thumb_extract_h;
    
    
    roi_file = [handles.registration_images_dir,'temp_roiB.tif'];
    roi_w = 2*handles.WSI_A.roi_w;
    roi_h = 2*handles.WSI_A.roi_h;
    roi_extract_h = roi_w * handles.WSIA_2_WSIB;
    roi_extract_w = roi_h * handles.WSIA_2_WSIB;  
    
   
    switch WSI_B.RotateWSI
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
    WSI_B.roi_file = roi_file;
    WSI_B.roi_x0 = roi_x0;
    WSI_B.roi_y0 = roi_y0;
    WSI_B.roi_left = roi_left;
    WSI_B.roi_top = roi_top;
    WSI_B.roi_extract_w = roi_extract_w;
    WSI_B.roi_extract_h = roi_extract_h;
    WSI_B.roi_w = roi_w;
    WSI_B.roi_h = roi_h;
    
    % Store the WSI position_i locally and globally and WSI patch
    WSI_B.wsi_positions = [roi_x0, roi_y0];
    WSI_B.thumb_positions = [x_center, y_center];
    
    
    % The following will refresh the image
    if handles.take_wsi_B_flag==1
        WSI_B.thumb_image_handle = ...
            image(WSI_B.thumb_image,'Parent',handles.axes_WSIB);
        axis(handles.axes_WSIB,'image');
        set(WSI_B.thumb_image_handle,...
            'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_B_ButtonDownFcn,handles});
    end
    handles.take_wsi_B_flag = 1;
    
    handles.WSI_B = WSI_B;
    guidata(handles.WSIregistration, handles);
    
    % Annotate the image with boxes marking the registration ROIs
    annotate_WSI_B(handles)

end

%% -------- Annotate the WSI B
function annotate_WSI_B(handles)
    % Place a rectangle on thumb_axes centered on mouse click
    % Blue box is camera roi for extraction
    % Red box is WSI roi for extraction (twice blue box)
    % Green box is the camera view
    
    % position_i indicates one of the three registration locations
    WSI_B = handles.WSI_B;

    x_center = WSI_B.thumb_positions(1);
    y_center = WSI_B.thumb_positions(2);
    
    % Scale factor to convert scanner pixels to thumbnail pixels
    % Remember that there is a rotation
     if WSI_B.RotateWSI == 0 || WSI_B.RotateWSI== 180
        scan2thumb_w = WSI_B.thumb_w/WSI_B.thumb_extract_w;
        scan2thumb_h = WSI_B.thumb_h/WSI_B.thumb_extract_h;
     else
        scan2thumb_w = WSI_B.thumb_w/WSI_B.thumb_extract_h;
        scan2thumb_h = WSI_B.thumb_h/WSI_B.thumb_extract_w;
     end
    % Size of blue rectangle in thumbnail pixels
    desc = 'blue';
    rect_w = WSI_B.roi_w*scan2thumb_w;
    rect_h = WSI_B.roi_h*scan2thumb_h;
    rect_left = x_center - rect_w/2;
    rect_top = y_center - rect_h/2;
    rectangle(...
        'Parent', handles.axes_WSIB,...
        'Position'  ,[rect_left, rect_top, rect_w, rect_h],...
        'Curvature' ,[0,0],...
        'LineWidth' ,2,...
        'LineStyle' ,'--',...
        'EdgeColor' ,desc,...
        'Tag'       ,'mark',...
        'HitTest'   ,'off');

% 
%         % Label the blue box
%     text(...
%         'Parent', handles.axes_WSIA,...
%         'Units'             ,'data',...
%         'Position'           ,[rect_left-rect_w/4, rect_top+rect_h+rect_h/4],...
%         'FontUnits'          ,'pixels',...
%         'FontSize'           ,rect_h/4,...
%         'FontWeight'         ,'bold',...
%         'Color'              ,'blue',...
%         'String'             ,'WSI A ROI',...
%         'HitTest'   ,'off');
%     a=1;


end



%% 3 registration buttons
% --- Executes on button press in position_1.
function position_1_Callback(hObject, eventdata, handles)
% hObject    handle to position_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    if handles.take_wsi_A_flag==0
        desc = 'Please click on the WSI A at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    if handles.take_wsi_B_flag==0
        desc = 'Please click on the WSI B at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    
    set(handles.position_1,'Enable','off');
    set(handles.WSI_A.thumb_image_handle,'HitTest','off');
    set(handles.WSI_B.thumb_image_handle,'HitTest','off');
    Register_Two_WSI_ROI(handles);
    handles = guidata(handles.WSIregistration);
    
    if handles.registration_good==0
        % Refresh WSI A
        handles.WSI_A.thumb_image_handle = ...
            image(handles.WSI_A.thumb_image,'Parent',handles.axes_WSIA);
        axis(handles.axes_WSIA,'image');
        set(handles.WSI_A.thumb_image_handle,'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_A_ButtonDownFcn,handles});
        
        % Refresh WSI B
        handles.WSI_B.thumb_image_handle = ...
            image(handles.WSI_B.thumb_image,'Parent',handles.axes_WSIB);
        axis(handles.axes_WSIB,'image');
        set(handles.WSI_B.thumb_image_handle,'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_B_ButtonDownFcn,handles});
        
        % Reset state to repeat registration
        handles.take_wsi_A_flag = 0;
        handles.take_wsi_B_flag = 0;
        set(handles.position_1,'Enable','on');
        
        guidata(handles.WSIregistration,handles);
        return;
    end
    
    handles.result.wsi_A_positions(1,1) = handles.WSI_A.roi_x0;
    handles.result.wsi_A_positions(1,2) = handles.WSI_A.roi_y0;
    handles.result.wsi_B_positions(1,1) = handles.WSI_B.roi_x0;
    handles.result.wsi_B_positions(1,2) = handles.WSI_B.roi_y0;
    
    
    % Prepare for the next step
    set(handles.position_2,'Enable','on');
    %handles.current.position_i = 2;
    guidata(handles.WSIregistration,handles);
    
    
    display_thumb_A(handles.WSIregistration)
    display_thumb_B(handles.WSIregistration)
    
end

% --- Executes on button press in position_2.
function position_2_Callback(hObject, eventdata, handles)
% hObject    handle to position_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    if handles.take_wsi_A_flag==0
        desc = 'Please click on the WSI A at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    if handles.take_wsi_B_flag==0
        desc = 'Please click on the WSI B at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    set(handles.position_2,'Enable','off');
    set(handles.WSI_A.thumb_image_handle,'HitTest','off');
    set(handles.WSI_B.thumb_image_handle,'HitTest','off');
    Register_Two_WSI_ROI(handles);
    handles = guidata(handles.WSIregistration);
    
    if handles.registration_good==0
        % Refresh WSI A
        handles.WSI_A.thumb_image_handle = ...
            image(handles.WSI_A.thumb_image,'Parent',handles.axes_WSIA);
        axis(handles.axes_WSIA,'image');
        set(handles.WSI_A.thumb_image_handle,'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_A_ButtonDownFcn,handles});
        
        % Refresh WSI B
        handles.WSI_B.thumb_image_handle = ...
            image(handles.WSI_B.thumb_image,'Parent',handles.axes_WSIB);
        axis(handles.axes_WSIB,'image');
        set(handles.WSI_B.thumb_image_handle,'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_B_ButtonDownFcn,handles});
        
        % Reset state to repeat registration
        handles.take_wsi_A_flag = 0;
        handles.take_wsi_B_flag = 0;
        set(handles.position_2,'Enable','on');
        
        guidata(handles.WSIregistration,handles);
        return;
    end
    
    handles.result.wsi_A_positions(2,1) = handles.WSI_A.roi_x0;
    handles.result.wsi_A_positions(2,2) = handles.WSI_A.roi_y0;
    handles.result.wsi_B_positions(2,1) = handles.WSI_B.roi_x0;
    handles.result.wsi_B_positions(2,2) = handles.WSI_B.roi_y0;
    
    % Prepare for the next step
    set(handles.position_3,'Enable','on');
    
    %handles.current.position_i = 2;
    guidata(handles.WSIregistration,handles);
    
    
    display_thumb_A(handles.WSIregistration)
    display_thumb_B(handles.WSIregistration)
    
end

% --- Executes on button press in position_3.
function position_3_Callback(hObject, eventdata, handles)
% hObject    handle to position_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.take_wsi_A_flag==0
        desc = 'Please click on the WSI A at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    if handles.take_wsi_B_flag==0
        desc = 'Please click on the WSI B at the location corresponding to the camera preview.';
        h_errordlg = errordlg(desc,'Take WSI Position 1','modal'); %#ok<NASGU>
        return;
    end
    set(handles.position_3,'Enable','off');
    set(handles.WSI_A.thumb_image_handle,'HitTest','off');
    set(handles.WSI_B.thumb_image_handle,'HitTest','off');
    Register_Two_WSI_ROI(handles);
    handles = guidata(handles.WSIregistration);
    
    if handles.registration_good==0
        % Refresh WSI A
        handles.WSI_A.thumb_image_handle = ...
            image(handles.WSI_A.thumb_image,'Parent',handles.axes_WSIA);
        axis(handles.axes_WSIA,'image');
        set(handles.WSI_A.thumb_image_handle,'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_A_ButtonDownFcn,handles});
        
        % Refresh WSI B
        handles.WSI_B.thumb_image_handle = ...
            image(handles.WSI_B.thumb_image,'Parent',handles.axes_WSIB);
        axis(handles.axes_WSIB,'image');
        set(handles.WSI_B.thumb_image_handle,'HitTest','on',...
            'ButtonDownFcn', {@thumb_WSI_B_ButtonDownFcn,handles});
        
        % Reset state to repeat registration
        handles.take_wsi_A_flag = 0;
        handles.take_wsi_B_flag = 0;
        set(handles.position_3,'Enable','on');
        
        guidata(handles.WSIregistration,handles);
        return;
    end
    
    handles.result.wsi_A_positions(3,1) = handles.WSI_A.roi_x0;
    handles.result.wsi_A_positions(3,2) = handles.WSI_A.roi_y0;
    handles.result.wsi_B_positions(3,1) = handles.WSI_B.roi_x0;
    handles.result.wsi_B_positions(3,2) = handles.WSI_B.roi_y0;
    WSI_registration_result = handles.result;
    % Prepare for the next step
    save( handles.registration_result,'WSI_registration_result');
    
    guidata(handles.WSIregistration,handles);
    Generate_Transformation_Matrix(handles);
    
    % show transformation equation 
    handles = guidata(handles.WSIregistration);
    result = handles.result;
    wsi_A_Minv = result.wsi_A_Minv;
    wsi_B_M = result.wsi_B_M;
    transfer_table = wsi_B_M*wsi_A_Minv;
    m11 = transfer_table(1,1);
    m12 = transfer_table(1,2);
    m21 = transfer_table(2,1);
    m22 = transfer_table(2,2);
    
    wsix_ax = m11;
    wsix_ay = m12;
    wsix_b = -m11*result.wsi_A_positions(1,1)-m12*result.wsi_A_positions(1,2)+result.wsi_B_positions(1,1);
       
    wsiy_ax = m21;
    wsiy_ay = m22;
    wsiy_b = -m21*result.wsi_A_positions(1,1)-m22*result.wsi_A_positions(1,2)+result.wsi_B_positions(1,2);
    
    wsix_function = ['WSI_B_X = (',num2str(wsix_ax,6),') x WSI_A_X + (',num2str(wsix_ay,6),') x WSI_A_Y + (',num2str(round(wsix_b)),')'];
    wsiy_function = ['WSI_B_Y = (',num2str(wsiy_ax,6),') x WSI_A_X + (',num2str(wsiy_ay,6),') x WSI_A_Y + (',num2str(round(wsiy_b)),')'];
    
    
    set(handles.transformationEquationText,'String',{'Transformation Equation';wsix_function;wsiy_function});
    set(handles.loadBasedPosition,'Enable','on');
    set(handles.WSIA_X_Input,'Enable','on');
    set(handles.WSIA_Y_Input,'Enable','on');
       
    display_thumb_A(handles.WSIregistration)
    display_thumb_B(handles.WSIregistration)
end

%% Transfer WSI positions.
% --- Executes on button press in loadBasedPosition.
function loadBasedPosition_Callback(hObject, eventdata, handles)
% hObject    handle to loadBasedPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.WSIregistration);
    [WSI_A_position_file, workdir] = uigetfile('*.csv', 'Select based WSI file position');
    WSI_A_position_pathFile = [workdir, WSI_A_position_file];   
    WSI_A_position = xlsread(WSI_A_position_pathFile);
    handles.WSI_A_position = WSI_A_position;
    set(handles.loadBasedPosition,'Enable','off');
    set(handles.getNewPositions,'Enable','on');
    guidata(handles.WSIregistration,handles);
end

% --- Executes on button press in getNewPositions.
function getNewPositions_Callback(hObject, eventdata, handles)
% hObject    handle to getNewPositions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.WSIregistration);
    result = handles.result;
    WSI_A_position = handles.WSI_A_position;
    
    for i = 1:size(WSI_A_position,1)
           temp_A_position = double(transpose([WSI_A_position(i,1), WSI_A_position(i,2)]));
           wsi_A_Minv = result.wsi_A_Minv;
           wsi_A_p1 = transpose(result.wsi_A_positions(1,:));
           % stage_M maps standard coordinate plane to stage coordinates
           % given reference point stage_0 = [stage_x0, stage_y0]
           wsi_B_M = result.wsi_B_M;
           wsi_B_p1 = transpose(result.wsi_B_positions(1,:));
                    
           % Shift to set wsi reference as origin
           temp = temp_A_position - wsi_A_p1;
           % Map to standard coordinate plane
           temp = wsi_A_Minv * temp;
           % Map to stage coordinates
           temp = wsi_B_M * temp;
           % Shift to unset stage reference as origin
           temp_B_position(i,:) = int64(temp + wsi_B_p1);
    end
    xPos = temp_B_position(:,1);
    yPos = temp_B_position(:,2);
    WSI_B_position = table(xPos,yPos);
    writetable(WSI_B_position,[pwd, '\Register_Two_WSI\',handles.WSI_A.name,'_to_',handles.WSI_B.name,'_positions.csv']);
    set(handles.getNewPositions,'Enable','off');
    set(handles.loadBasedPosition,'Enable','on');
end

function Generate_Transformation_Matrix(handles)
    %----------------------------------------------------------------------
    % Generate_Transformation_Matrix calculates the matrix used for
    % transformation of coordinates between the stage and the glass slide
    %----------------------------------------------------------------------
    
    handles = guidata(handles.WSIregistration);        
    result = handles.result;     
    Calib_Point_WSI_A_1=transpose(handles.result.wsi_A_positions(1,:));
    Calib_Point_WSI_A_2=transpose(handles.result.wsi_A_positions(2,:));
    Calib_Point_WSI_A_3=transpose(handles.result.wsi_A_positions(3,:));
    Calib_Point_WSI_B_1=transpose(handles.result.wsi_B_positions(1,:));
    Calib_Point_WSI_B_2=transpose(handles.result.wsi_B_positions(2,:));
    Calib_Point_WSI_B_3=transpose(handles.result.wsi_B_positions(3,:));
        
    wsi_A_v1=Calib_Point_WSI_A_2-Calib_Point_WSI_A_1;
    wsi_A_v2=Calib_Point_WSI_A_3-Calib_Point_WSI_A_1;
        
    wsi_B_v1=Calib_Point_WSI_B_2-Calib_Point_WSI_B_1;
    wsi_B_v2=Calib_Point_WSI_B_3-Calib_Point_WSI_B_1;
        
    % wsi_A_Minv and wsi_A map wsi coordinates
    % to and from the standard coordinate plane
    result.wsi_A_M = [wsi_A_v1,wsi_A_v2];
    temp = [result.wsi_A_M, transpose([1,0]), transpose([0,1])];
    temp=rref(temp);
    result.wsi_A_Minv = temp(:,3:4);
        
    % wis_B_Minv and wsi_B map stage coordinates
    % to and from the standard coordinate plane
    result.wsi_B_M = [wsi_B_v1, wsi_B_v2];
    temp = [result.wsi_B_M, transpose([1,0]), transpose([0,1])];
    temp=rref(temp);
    result.wsi_B_Minv = temp(:,3:4);
    handles.result = result;
    guidata(handles.WSIregistration, handles);
    

end


% --- Executes on button press in TransformOnePoint.
function TransformOnePoint_Callback(hObject, eventdata, handles)
% hObject    handle to TransformOnePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.WSIregistration);
    result = handles.result;
    WSI_A_onepoint = handles.WSI_A_onepoint;
    
    temp_A_position = double(transpose([WSI_A_onepoint(1), WSI_A_onepoint(2)]));
    wsi_A_Minv = result.wsi_A_Minv;
    wsi_A_p1 = transpose(result.wsi_A_positions(1,:));
    % stage_M maps standard coordinate plane to stage coordinates
    % given reference point stage_0 = [stage_x0, stage_y0]
    wsi_B_M = result.wsi_B_M;
    wsi_B_p1 = transpose(result.wsi_B_positions(1,:));
                    
    % Shift to set wsi reference as origin
    temp = temp_A_position - wsi_A_p1;
    % Map to standard coordinate plane
    temp = wsi_A_Minv * temp;
    % Map to stage coordinates
    temp = wsi_B_M * temp;
    % Shift to unset stage reference as origin
    temp_B_position = int64(temp + wsi_B_p1);
    
    xPos = temp_B_position(1);
    yPos = temp_B_position(2);
    set(handles.WSIB_X_transformed,'String',['X: ',num2str(xPos)]);
    set(handles.WSIB_Y_transformed,'String',['Y: ',num2str(yPos)]);
    handles.finished_onepoint = [0,0];
    set(handles.ExportOnePointResult,'Enable','on');
    set(handles.TransformOnePoint,'Enable','off');
    handles.B_position_onepint = temp_B_position;
    guidata(handles.WSIregistration,handles);
end

% --- Executes on button press in ExportOnePointResult.
function ExportOnePointResult_Callback(hObject, eventdata, handles)
% hObject    handle to ExportOnePointResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(handles.WSIregistration);
    B_position_onepint = handles.B_position_onepint;
    xPos = B_position_onepint(1);
    yPos = B_position_onepint(2);
    WSI_B_position = table(xPos,yPos);
    writetable(WSI_B_position,[pwd, '\Register_Two_WSI\',handles.WSI_B.name,'_onePoint_positions.csv']);
    set(handles.ExportOnePointResult,'Enable','off');
    guidata(handles.WSIregistration,handles);
end


function WSIA_X_Input_Callback(hObject, eventdata, handles)
% hObject    handle to WSIA_X_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WSIA_X_Input as text
%        str2double(get(hObject,'String')) returns contents of WSIA_X_Input as a double
    handles = guidata(handles.WSIregistration);
    %[WSI_A_position_file, workdir] = uigetfile('*.csv', 'Select based WSI file position');  
    tempX= str2num(get(handles.WSIA_X_Input, 'String'));
    set(handles.WSIB_X_transformed,'String','X:');
    set(handles.WSIB_Y_transformed,'String','Y:');
    handles.WSI_A_onepoint(1) = tempX;
    handles.finished_onepoint(1) = 1; 
    if (sum(handles.finished_onepoint)==2)
        set(handles.TransformOnePoint,'Enable','on');
    
    end
    guidata(handles.WSIregistration,handles);
end

% --- Executes during object creation, after setting all properties.
function WSIA_X_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WSIA_X_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function WSIA_Y_Input_Callback(hObject, eventdata, handles)
% hObject    handle to WSIA_Y_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WSIA_Y_Input as text
%        str2double(get(hObject,'String')) returns contents of WSIA_Y_Input as a double
    handles = guidata(handles.WSIregistration);
    %[WSI_A_position_file, workdir] = uigetfile('*.csv', 'Select based WSI file position');  
    tempY = str2num(get(handles.WSIA_Y_Input, 'String'));
    set(handles.WSIB_X_transformed,'String','X:');
    set(handles.WSIB_Y_transformed,'String','Y:');
    handles.WSI_A_onepoint(2) = tempY;
    handles.finished_onepoint(2) = 1; 
    if (sum(handles.finished_onepoint)==2)
        set(handles.TransformOnePoint,'Enable','on');
    
    end
    guidata(handles.WSIregistration,handles);
end

% --- Executes during object creation, after setting all properties.
function WSIA_Y_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WSIA_Y_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function varargout = Camera_stage_review(varargin)
% CAMERA_STAGE_REVIEW MATLAB code for Camera_stage_review.fig
%      CAMERA_STAGE_REVIEW, by itself, creates a new CAMERA_STAGE_REVIEW or raises the existing
%      singleton*.
%
%      H = CAMERA_STAGE_REVIEW returns the handle to a new CAMERA_STAGE_REVIEW or the handle to
%      the existing singleton*.
%
%      CAMERA_STAGE_REVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAMERA_STAGE_REVIEW.M with the given input arguments.
%
%      CAMERA_STAGE_REVIEW('Property','Value',...) creates a new CAMERA_STAGE_REVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Camera_stage_review_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop_video.  All inputs are passed to Camera_stage_review_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Camera_stage_reviewa

% Last Modified by GUIDE v2.5 08-Mar-2018 16:22:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Camera_stage_review_OpeningFcn, ...
                   'gui_OutputFcn',  @Camera_stage_review_OutputFcn, ...
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


% --- Executes just before Camera_stage_review is made visible.
function Camera_stage_review_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Camera_stage_review (see VARARGIN)

% Choose default command line output for Camera_stage_review
    ExecutableFolder = GetExecutableFolder();
    cd(ExecutableFolder);
    desc = {'\bfWelcome'...
    ,'Please choose the camera format'};
    welcome_page(handles,desc );
    set(handles.Take_image,'Enable','off');
    set(handles.Recode_video,'Enable','off');
    set(handles.Stop_video,'Enable','off');
    handles.imagenumber = 1;
    handles.position_flag_y=0;
    handles.position_flag_x=0;
    handles.stageflag=0;
    handles.cameraflag = 0;
    handles.firsttime = 1;
    handles.output=hObject;
    % Update handles structure
    guidata(hObject, handles);
end

% UIWAIT makes Camera_stage_review wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Camera_stage_review_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in Take_image.
function Take_image_Callback(hObject, eventdata, handles)
try

% hObject    handle to Take_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
   img=camera_take_image(handles.cam);
   if handles.stageflag==1
       handles.stage = stage_get_pos(handles.stage);
       x = handles.stage.Pos(1);
       y = handles.stage.Pos(2);
       set(handles.current_position_x,'String',x);
       set(handles.current_position_y,'String',y);
       defaultimagename= [ 'X_',num2str(x),'_Y_',num2str(y),'.jpg'];
   else
       defaultimagename =  [num2str(handles.imagenumber),'_cam.jpg'];
   end
   
   if handles.firsttime==1
       [saveimagename,savepathname]=uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'}, 'Save image',defaultimagename);
   else
       [saveimagename,savepathname]=uiputfile({'*.jpg;*.tif;*.png;*.gif','All Image Files'}, 'Save image',[handles.lastdirectory,defaultimagename]);
   end
   
   if saveimagename~=0
       imwrite(img,[savepathname,saveimagename]);
   else
       return;
   end
   
   if strcmp( saveimagename,defaultimagename ) & handles.stageflag==0
      handles.imagenumber = handles.imagenumber+1;
   end
   
   handles.firsttime=0;
   handles.lastdirectory = savepathname;
   guidata(hObject, handles);
catch ME
    error_show(ME)
end  

end


% --- Executes on button press in Move_stage.
function Move_stage_Callback(hObject, eventdata, handles)
% hObject    handle to Move_stage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage_new = [str2num(handles.target_position_x),str2num(handles.target_position_y)];
handles.stage = stage_move(handles.stage,stage_new);
set(handles.current_position_x,'String',handles.target_position_x);
set(handles.current_position_y,'String',handles.target_position_y);
handles.position_flag_y=0;
handles.position_flag_x=0;
set(handles.Move_stage,'Enable','off');
guidata(hObject, handles);
end


function target_position_x_Callback(hObject, eventdata, handles)
% hObject    handle to target_position_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_position_x as text
%        str2double(get(hObject,'String')) returns contents of target_position_x as a double
handles.target_position_x = get(hObject,'String');
if handles.position_flag_y==1
    set(handles.Move_stage,'Enable','on');
end
handles.position_flag_x=1;
guidata(hObject, handles);   

end

% --- Executes during object creation, after setting all properties.
function target_position_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_position_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.



function target_position_y_Callback(hObject, eventdata, handles)
% hObject    handle to target_position_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_position_y as text
%        str2double(get(hObject,'String')) returns contents of target_position_y as a double
handles.target_position_y = get(hObject,'String');
if handles.position_flag_x==1
    set(handles.Move_stage,'Enable','on');
end
handles.position_flag_y=1;
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function target_position_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_position_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


% --- Executes on button press in Get_position.
function Get_position_Callback(hObject, eventdata, handles)
% hObject    handle to Get_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stage = stage_get_pos(handles.stage);
x = handles.stage.Pos(1);
y = handles.stage.Pos(2);
set(handles.current_position_x,'String',x);
set(handles.current_position_y,'String',y);
guidata(hObject, handles);
end


function current_position_x_Callback(hObject, eventdata, handles)
% hObject    handle to current_position_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
% Hints: get(hObject,'String') returns contents of current_position_x as text
%        str2double(get(hObject,'String')) returns contents of current_position_x as a double


% --- Executes during object creation, after setting all properties.
function current_position_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_position_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


function current_position_y_Callback(hObject, eventdata, handles)
% hObject    handle to current_position_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end
% Hints: get(hObject,'String') returns contents of current_position_y as text
%        str2double(get(hObject,'String')) returns contents of current_position_y as a double


% --- Executes during object creation, after setting all properties.
function current_position_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_position_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.


% --- Executes on selection change in Choose_System.
function Choose_System_Callback(hObject, eventdata, handles)
% hObject    handle to Choose_System (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
modes=get(handles.Choose_System,'String');
mode_index = get(handles.Choose_System, 'Value');
mode_desc = deblank(modes{mode_index});
handles.mode_desc = mode_desc;
if mode_index ~= 1  
    addpath('stages/Prior','stages/Ludl');
    handles.stage=stage_open(mode_desc);
    handles.stage = stage_set_origin(handles.stage);
    set(handles.Get_position,'Enable','on');
    set(handles.current_position_x,'Enable','on');
    set(handles.current_position_y,'Enable','on');
    set(handles.target_position_x,'Enable','on');
    set(handles.target_position_y,'Enable','on');
    handles.stageflag=1;
    if handles.cameraflag == 1
       set(handles.Recode_video,'Enable','on')
    end
end
guidata(hObject, handles);   
end


% --- Executes during object creation, after setting all properties.
function Choose_System_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Choose_System (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

end




function camera_image_display(handles,vid, settings)
try
    
    % Get properties of the camera image
    nBands = get(vid, 'NumberOfBands');
    vidRes = get(vid, 'VideoResolution');
    imWidth = vidRes(1);
    imHeight = vidRes(2);
    set(handles.ImageAxes,'Units', 'pixels')
    startWidth = floor((1252-imWidth)/2);
    startHeight = floor((1051-imHeight)/2);
    set(handles.ImageAxes,'Position', [startWidth, startHeight, imWidth, imHeight]);
    hImage = image( uint8(zeros(imHeight, imWidth, nBands) ),'parent', handles.ImageAxes);
    set(hImage, 'UserData', settings)
    setappdata(hImage,'UpdatePreviewWindowFcn',@preview_image_with_cross); 
    preview(vid, hImage);
    
catch ME
    error_show(ME)
end

end

function preview_image_with_cross(obj, event, himage)
try
    % Example update preview window function.
    
    % obj = Handle to the video input object being previewed
    % event = A data structure containing the following fields:
    %    Data = Current image frame specified as an H-by-W-by-B array,
    %           where H is the image height and W is the image width, as
    %           specified in the ROIPosition property, and B is the number
    %           of color bands, as specified in the NumberOfBands property
    %    Resolution = Text string specifying the current image width and
    %           height, as defined by the ROIPosition property
    %    Status = String describing the status of the video input object
    %    Timestamp = String specifying the time associated with the current
    %           image frame, in the format hh:mm:ss:ms
    % himage = Handle to the image object in which the data is to be displayed

    % The image is stored in event.Data
    temp_image = event.Data;
    % myData.settings is stored in himage property UserData
    settings = get(himage, 'UserData');
    % The camera mask is stored in settings.cam_mask
    temp_image = reticle_apply_mask(temp_image, settings.cam_mask);
    
    % Display image data.
    set(himage, 'CDataMapping','direct');
    set(himage, 'CData', temp_image);
    
catch ME
    error_show(ME)
end


end


% --- Choose camera format
function Choose_Camera_Callback(hObject, eventdata, handles)
try
    settings.mag_cam=1;
    settings.cam_pixel_size=6.9;
    modes=get(handles.Choose_Camera,'String');
    mode_index = get(handles.Choose_Camera, 'Value');
    cam_mode = deblank(modes{mode_index});
    if mode_index ~= 1  
        handles.cam_mode = cam_mode;
        if strcmp(handles.cam_mode(1:3),'USB')
            settings.cam_kind = char('USB');
            settings.cam_format=char('F7_RGB_1224x1024_Mode1');
        else
             settings.cam_kind = char('Firewire');
             settings.cam_format=char('RGB24_1024x768');
        end
        settings.reticleID=char('KR-871');
        settings.cam_mask = reticle_make_mask(...
                settings.reticleID,...
                settings.cam_pixel_size/settings.mag_cam,...
                [0,0]);
        handles.cam=camera_open(settings.cam_kind,settings.cam_format);
        camera_image_display(handles,handles.cam,settings);
        set(handles.Take_image,'Enable','on');
        handles.cameraflag = 1;
        if handles.stageflag == 1
            set(handles.Recode_video,'Enable','on')
        end
    else
        desc = {'\bfWelcome'...
            ,'Please choose the camera format'};
        welcome_page(handles, desc);
        set(handles.Take_image,'Enable','off');
    end
    guidata(hObject, handles);
catch ME
    error_show(ME)
end

end

% --- Executes during object creation, after setting all properties.
function Choose_Camera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Choose_Camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function  welcome_page(handles, desc)
try
   % This function creates an image with text to be displayed to the user
     set(handles.ImageAxes,...
         'Units', 'pixels',...
         'Position', [1, 1, 1252, 1051],...
         'Visible', 'off');
    position = int64(get(handles.ImageAxes, 'Position'));
    temp_image = ones([position(4), position(3), 3])-.5;
    i=(1:double(position(3)))/double(position(3));
    for j=1:position(4)
        temp_image(j,:,1) = i;
    end
    img_object = image(temp_image, 'Parent', handles.ImageAxes); %#ok<NASGU>
    axis image
    set(handles.ImageAxes, 'Visible', 'off');
    fontsize=0.05;
    text('Parent', handles.ImageAxes,...
        'FontName', 'Times',...
        'FontUnits', 'normalized',...
        'FontSize', fontsize,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'Position', [position(3)/2, position(4)/2],...
        'String', desc);
   
catch ME
    error_show(ME)
end
end


% --- Executes on button press in Recode_video.
function Recode_video_Callback(hObject, eventdata, handles)
% hObject    handle to Recode_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    % record audio
    wavObject = audiorecorder;
    record(wavObject);
    handles.audio = wavObject;
%    guidata(hObject, handles);
    % manage buttons
    set(handles.Recode_video,'Enable','off')
    set(handles.Stop_video,'Enable','on')
    set(handles.text24,'String','Recording!');
    % record video
    aviObject = VideoWriter('myVideo.avi'); 
    handles.cam.DiskLogger = aviObject;
    handles.cam.LoggingMode = 'disk';
    handles.cam.TriggerRepeat = Inf;
    handles.cam.FramesPerTrigger = Inf;
    start(handles.cam);
    % record stage position
    handles.recordStagePosition=[];
    guidata(hObject, handles);
    handles.stageTimer = timer('ExecutionMode','fixedrate','Period',2,...
    'TimerFcn',{@executeStageTimer,handles.output});
    start(handles.stageTimer);
%     for i=1:10
%         tic;
%         handles.stage = stage_get_pos(handles.stage);
%         recordPositions=[recordPositions;[handles.stage.Pos(1),handles.stage.Pos(2)]];
%         elapsedTime = toc 
%     end

%    wait(handles.cam,10000,'Logging');
%      handles.cam.Running;
%      handles.cam.Logging;
%     handles.cam.DiskLoggerFrameCount;
%    close(aviObject);
    
     guidata(hObject, handles);

catch ME
    error_show(ME)
end
end


% --- Executes on button press in Stop_video.
function Stop_video_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % video
    video= handles.cam;
    stop(video);
    close(handles.cam.DiskLogger);

    % audio
    wavObject = handles.audio;
    stop(wavObject);
    audioData = getaudiodata(wavObject);
    audiowrite('myAudio.wav',audioData,wavObject.SampleRate)
    
    % stage 
    stop(handles.stageTimer);
    delete(timerfindall);
    
    csvwrite('myStagePostion.csv',handles.recordStagePosition)
    % manage buttons
    set(handles.text24,'String',{'Click Start Video button';'to record'});
    set(handles.Recode_video,'Enable','on')
    set(handles.Stop_video,'Enable','off')
    guidata(hObject, handles);
end


%This function keep saving stage position every 'Period'
%duration of the timer
function executeStageTimer(hObject, eventdata, hFigure)
    handles = guidata(hFigure);
     handles.stage = stage_get_pos(handles.stage);
     handles.recordStagePosition = [handles.recordStagePosition;[handles.stage.Pos(1),handles.stage.Pos(2)]];
%    handles.recordStagePosition =  [handles.recordStagePosition;[10,10]];
    %disp(currentTimeInfo);
    guidata(hFigure, handles);
end
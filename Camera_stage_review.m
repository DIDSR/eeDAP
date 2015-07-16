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
%      stop.  All inputs are passed to Camera_stage_review_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Camera_stage_review

% Last Modified by GUIDE v2.5 29-Jun-2015 15:59:11

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
settings.mag_cam=1;
settings.cam_pixel_size=6.9;
settings.cam_format=char('RGB24_1024x768');
settings.reticleID=char('KR-32536');
settings.cam_mask = reticle_make_mask(...
        settings.reticleID,...
        settings.cam_pixel_size/settings.mag_cam,...
        [0,0]);
handles.cam=camera_open(settings.cam_format);
camera_image_display(handles,handles.cam,settings);
handles.imagenumber = 1;
handles.position_flag_y=0;
handles.position_flag_x=0;
handles.stageflag=0;

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
   FolderName = 'camera_images';
   if ~exist(FolderName,'file')
            mkdir(FolderName);
   end   
   img=camera_take_image(handles.cam);
   if handles.stageflag==1
   handles.stage = stage_get_pos(handles.stage);
   x = handles.stage.Pos(1);
   y = handles.stage.Pos(2);
   set(handles.current_position_x,'String',x);
   set(handles.current_position_y,'String',y);
   imwrite(img,strcat(FolderName,'\',...
                 'X_',num2str(x),...
                 '_Y_',num2str(y),...
                 '_cam.tif'));
   else
   imwrite(img,strcat(FolderName,'\',...
                 num2str(handles.imagenumber),...
                 '_cam.tif'));
   handles.imagenumber = handles.imagenumber+1;
   end
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
handles.stage=stage_open(mode_desc);
handles.stage = stage_set_origin(handles.stage);
handles.stage=stage_move(handles.stage,[50000,50000]);
set(handles.Get_position,'Enable','on');
set(handles.current_position_x,'Enable','on');
set(handles.current_position_y,'Enable','on');
set(handles.target_position_x,'Enable','on');
set(handles.target_position_y,'Enable','on');
handles.stageflag=1;
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
    set(handles.ImageAxes,'Position', [5, 5, imWidth, imHeight]);
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





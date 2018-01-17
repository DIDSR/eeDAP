function varargout = Image_Information(varargin)
% IMAGE_INFORMATION MATLAB code for Image_Information.fig
%      IMAGE_INFORMATION, by itself, creates a new IMAGE_INFORMATION or raises the existing
%      singleton*.
%
%      H = IMAGE_INFORMATION returns the handle to a new IMAGE_INFORMATION or the handle to
%      the existing singleton*.
%
%      IMAGE_INFORMATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_INFORMATION.M with the given input arguments.
%
%      IMAGE_INFORMATION('Property','Value',...) creates a new IMAGE_INFORMATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Image_Information_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Image_Information_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Image_Information

% Last Modified by GUIDE v2.5 05-Dec-2017 15:21:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_Information_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_Information_OutputFcn, ...
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


% --- Executes just before Image_Information is made visible.
function Image_Information_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Image_Information (see VARARGIN)
    addpath('bfmatlab');   
    handles_old = varargin{1};
    handles.myData.BrowseImagePath = handles_old.myData.BrowseImagePath;
    handles.output = hObject;
    guidata(handles.Image_Information, handles);
    display_thumbnail_and_info(handles.Image_Information);
    % UIWAIT makes Image_Information wait for user response (see UIRESUME)
    % uiwait(handles.Image_Information);
end

% --- Outputs from this function are returned to the command line.
function varargout = Image_Information_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end



% --- Executes during object creation, after setting all properties.
function imageInfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function display_thumbnail_and_info(Stage_Image_Information)
try
    handles = guidata(Stage_Image_Information);
    BrowseImagePath = handles.myData.BrowseImagePath;
    %% display info
     WSI_data = bfGetReader(BrowseImagePath);
    % TileHeight=WSI_data.getOptimalTileHeight();
    % TileWidth=WSI_data.getOptimalTileWidth();
    %CoreMetadata=WSI_data.getCoreMetadataList();
    index = 1;
    tline = ['File path and name = ', BrowseImagePath]; 
    temp_string{index} = tline;
    index = index + 1;
    % layer number
    numberOfImages = WSI_data.getSeriesCount();
    tline = ['Pyramid layers = ', num2str(numberOfImages-2)];
    temp_string{index} = tline;
    index = index + 1;
    % each layer size
    for i = 0 : numberOfImages - 3
        WSI_data.setSeries(i);
        wsi_ws= WSI_data.getSizeX();
        wsi_hs= WSI_data.getSizeY();
        tline = ['Layer ',num2str(i+1),' w = ', num2str(wsi_ws),  ', h = ', num2str(wsi_hs),];
        temp_string{index} = tline;
        index = index + 1;
    end
    GlobalMetadata=WSI_data.getGlobalMetadata();
    GlobalMetadataKeyList = arrayfun(@char, GlobalMetadata.keySet.toArray, 'UniformOutput', false);
    for i = 1:length(GlobalMetadataKeyList)
        tkey = GlobalMetadataKeyList(i);
        tvalue = GlobalMetadata.get(tkey{1});
        tline = [tkey{1},' = ',num2str(tvalue)];
        temp_string{index} = tline;
        index = index + 1;
    end
    set(handles.imageInfo, 'String', temp_string);
    
    %% display thumbnail
    dotIndex = strfind(BrowseImagePath,'.');
    path = BrowseImagePath(1:(dotIndex(end)-1));
    thumb_file = [path,'_thumb.tif'];
    wsi_info.WSI_data = WSI_data;
    WSI_data.setSeries(0);
    wsi_w(1)= WSI_data.getSizeX();
    wsi_h(1)= WSI_data.getSizeY();
    numberOfImages = WSI_data.getSeriesCount();
    for j = 1 : numberOfImages - 3
        WSI_data.setSeries(j);
        wsi_w(j+1)= WSI_data.getSizeX();
        wsi_h(j+1)= WSI_data.getSizeY();
    end
    wsi_info.wsi_w = wsi_w;
    wsi_info.wsi_h = wsi_h;
    thumb_w = 0;
    thumb_h = 1000;
    thumb_left = 1;
    thumb_top = 1;    
    thumb_extract_w = wsi_info.wsi_w(1);
    thumb_extract_h = wsi_info.wsi_h(1);
    if thumb_extract_w > thumb_extract_h
        thumb_w = 1000;
        thumb_h = 0;
        thumb_scale = 1000.0/thumb_extract_w;
    else
        thumb_scale = 1000.0/thumb_extract_h;
    end
    % apple icc
    fid2 = fopen('icc_profiles\rgb_lut_gamma_inv1p8.txt');
    rgb_lut = uint8(zeros(256,3));
    for channel=1:3
        for level=1:256
            tline2 = fgets(fid2);
            rgb_lut(level,channel) = uint8(str2double(tline2));
        end
    end
    fclose(fid2);
    ExtractROI_BIO(wsi_info,...
        BrowseImagePath,...
        thumb_file,...
        thumb_left,...
        thumb_top,...
        thumb_extract_w,...
        thumb_extract_h,...
        thumb_w,...
        thumb_h,...
        270,...
        rgb_lut);
    
    thumb_image = imread(thumb_file);
    thumb_image_handle = image(thumb_image, 'Parent', handles.thumb);
    axis(handles.thumb,'image');
    delete(thumb_file)
catch ME
    error_show(ME)
end
end

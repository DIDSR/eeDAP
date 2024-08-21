% eeDAP data collection GUI
% Original Author: BSc Adam Ivansky
% Supervisors: Brandon D. Gallas PhD, Wei-Chung Cheng PhD
% Date: 24/08/2012
%
% Digital & Analog Pathology Simulator
%--------------------------------------------------------------------------
% These is a simple description used for storing the data related to the
% evaluation tasks.
%
% handles {
%
%   myData{
%       mode_desc -- data collection mode (Digital, MicroRT, TrackingView)
%
%       iter --used to indicate the task being executed iter=1,...,ntasks
%
%       index[] --indicates the number of the evaluation task to be
%       presentated in each step of the test
%
%       ntasks --indicates the overall number of tasks in the input file
%
%       ID[] --an array storing the IDs of the evaluation tasks
%
%       Question_text[] --an array storing the text rescribing the
%       evaluation tasks to the user
%
%       Slide_ID[] --an array indication the Slide ID for each evaluation
%       task
%
%       X_Position[] and Y_Position[] --arrays containing the coordinates of
%       the ROI in the whole slide image file. THe values are in pixels.
%
%       Pic_filename[] --an array that stores the paths to each ROI
%       image
%
%       MovingAllowed[] and ZoomingAllowed[] --arrays storing boolean values
%       indicating whether panning or zooming is allowed
%
%       Question_type[] --an array indicating the type of the evaluation
%       task.
%
%       q_op1,q_op2,q_op3,q_op4 --text that is to
%       be shown next to each checkbox or radiobox. They determine the
%       possible answer options the user has.
%
%       duration[] --Array containing the time difference in seconds between
%       the start of the test and the omment when given evaluation task was
%       completed
%
%       ans_slider[] --Array containing the values selected by the user
%       in the evaluation tasks of the 'Slider' type
%
%       ans_op1,ans_op2,ans_op3,ans_op4 --Arrays containing the values selected by the user
%       in the evaluation tasks of the 'SingleChoiceQuestion' or 'MultipleChoiceQuestion' type
%
%       username --Stores the full name of the user
%
%       graphics.scorebar,graphics.scorebar1,graphics.scorebar2,graphics.scorebar3 --store
%       the images of the score bars
%
%       graphics.zooming_allowed --stores the image that appears when the
%       presented ROI stimulus image is allowed to be zoomed
%
%       graphics.zooming_not_allowed --stores the image that appears when the
%       presented ROI stimulus image is NOT allowed to be zoomed
%
%       graphics.moving_allowed --stores the image that appears when the
%       presented ROI stimulus image is allowed to be panned
%
%       graphics.moving_not_allowed --stores the image that appears when the
%       presented ROI stimulus image is NOT allowed to be panned
%
%       StartTime --Stores the time when the 'Next' button was pressed for
%       the first time
%
%       InputFileHeader --Stores the header part of the input file
%
%       path_to_scanned_slides --Stores the directory of the whole slide
%       image files that are referenced in the input file
%
%       BG_color[] --is an array of 3 elements that define the red,
%       green and blue component of the backgroud of all GUI objects on
%       GUI
%
%       Axes_BG[] --is an array of 3 elements that define the red,
%       green and blue component of the ImageAxes background color
%
%       FG_color[]] --is an array of 3 elements that define the red,
%       green and blue component of the foreground of all GUI objects on
%       GUI
%
%       FontSize --specifies the font size property that is applied to all
%       GUI object on GUI
%
%       Extraction_Region_Width[] --Defines the width of the region extracted
%       from the whole slide image file before it is scaled
%
%       Extraction_Region_Height[] --Defines the height of the region extracted
%       from the whole slide image file before it is scaled
%   }
%
%   panning_Zooming_Tool {
%
%       figPos[] --Stores the position of the main window of the application. The
%       units are pixesl
%
%       axPos[] --stores the position of the axes object ImageAxes that is a parent of the
%       stimulus ROI image
%
%       pbar[] --stores the aspect ratio of ImageAxes
%
%       closedHandPointer --stores the image of the hand that appears as cursor
%       when the user panns the RIO stimulus image
%
%       zoomInOutPointer --stores the image of the +- sign that appears as
%       cursor when the user zooms the ROI stimulus image
%
%       iminfo --the description of the type and properties of RIO stimulus
%       image
%
%       xlim100[], ylim100[] --store the limits of the axes when the ROI
%       stimulus image is shown at 100% zoom
%
%       xlimFull[], panning_Zooming_Tool.ylimFull[]] --store the limits of the axes when the ROI
%       stimulus image is shown so that it stretches over the whole area of the
%       axes object
%
%       curPt[] --stores the coordinates of the mouse cursor in the moment when
%       the user clicked on the ImageAxes for the last time. The coordinates are
%       measured in the coordinate system of ImageAxes.
%
%       curPt2[] --stores the distance between th position of the last mouse
%       click and the center of the ROI stimulus image in axes.The coordinates are
%       measured in the coordinate system of ImageAxes.
%
%       xy[] --another variable used for storing the coordinates of the mouse
%       click. The coordinates are measured in the coordinate system of ImageAxes.
%
%       initPt[] --another variable used for storing the coordinates of the mouse
%       click.The coordinates are measured in the coordinate system of GUI.
%   }
%}
%--------------------------------------------------------------------------

%% GUI, GUI.OpeningFcn, GUI_OutputFcn

function varargout = GUI(varargin)

    % We save the input parameters in GUI.mat
    % We can read this file to run GUI with these commands
    %     load('GUI.mat');
    %     GUI(handles);

    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @GUI_OpeningFcn, ...
        'gui_OutputFcn',  @GUI_OutputFcn, ...
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
function GUI_OpeningFcn(hObj, eventdata, handles, varargin)
    try
        %--------------------------------------------------------------------------
        % This function launches before the GUI is loaded.
        % The two command line input arguments of this program are saved into
        % two separate variables.
        %--------------------------------------------------------------------------


        % Make sure path is set
        path_set()

        % Get myData from previous input arguments
        handles_old = varargin{1};
        myData = handles_old.myData;
        settings = myData.settings;

        % Initialize elements of handles and save to handles.GUI
        % handles.current as a structure
        % handles.current will hold info related to the current task and ROI
        handles.Administrator_Input_Screen = handles_old.Administrator_Input_Screen;
        handles.current = struct;
        handles.reticle = 1;
        handles.myData = myData;
        handles.output = hObj;
        guidata(handles.GUI, handles)

        % Open communications to camera and begin preview
        % Open communications to stage
        switch myData.mode_desc
            case 'MicroRT'
                if myData.yesno_micro==1

                    % Open communications to camera and begin preview
                    % Why is handles.cam not in myData?
                    handles.cam=camera_open(settings.cam_kind,settings.cam_format,settings.defaultR,settings.defaultB);
                    handles.cam_figure = ...
                        camera_preview(handles.cam, settings);
                    % To close:
                    % delete handles.cam
                    % close(cam_figure)

                    % Open communications to stage
                    handles.myData.stage = stage_open(handles.myData.stage);
                    % To close:
                    % delete(handles.stage)
                end

                % Generate transformation matrix
                % Apparently, we need to save handles before and retrieve after
                guidata(handles.GUI, handles);
                Generate_Transformation_Matrix(handles);
                handles = guidata(handles.GUI);

            case 'TrackingView'

                handles.cam=camera_open(settings.cam_kind,settings.cam_format,settings.defaultR,settings.defaultB);
                handles.cam_figure = camera_preview(handles.cam, settings);
                handles.myData.stage = stage_set_origin(handles.myData.stage);
                guidata(handles.GUI, handles);

        end


        % Initiate GUI object
        Initiate_GUI_Elements(handles);

        handles = guidata(handles.GUI);
        guidata(hObj, handles);

    catch ME
        error_show(ME)
    end

end
function Initiate_GUI_Elements(handles)
    try
        %--------------------------------------------------------------------------
        % This function makes sure that all the GUI elements are created and
        % properly positioned. The input on this function is the original
        % handles structure and the structure myData used for storing the
        % non-GUI data. The output then is the modified handles structure with
        % all the GUI objects moved to the right positions
        %--------------------------------------------------------------------------
        myData = handles.myData;

        % The following 4 lines ensure initiating the variables used for
        % zooming and panning
        handles.ImX=[];
        handles.panning_Zooming_Tool.figPos = get(handles.GUI, 'position');
        handles.panning_Zooming_Tool.axPos = get(handles.ImageAxes, 'position');
        handles.panning_Zooming_Tool.pbar = get(handles.ImageAxes, 'plotboxaspectratio');

        % The closed hand and zoom icons are initiated
        handles.panning_Zooming_Tool.closedHandPointer = [
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,2  ,2  ,NaN,2  ,2  ,NaN,2  ,2  ,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,2  ,1  ,1  ,2  ,1  ,1  ,2  ,1  ,1  ,2  ,2  ,NaN,NaN
            NaN,NaN,2  ,1  ,2  ,2  ,1  ,2  ,2  ,1  ,2  ,2  ,1  ,1  ,2  ,NaN
            NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,1  ,2
            NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,NaN,2  ,1  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2
            NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN
            NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN
            NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN,NaN
            NaN,NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN,NaN
            NaN,NaN,NaN,NaN,2  ,1  ,2  ,2  ,2  ,2  ,2  ,2  ,1  ,2  ,NaN,NaN
            ];

        handles.panning_Zooming_Tool.zoomInOutPointer = [
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN
            NaN,2  ,1  ,1  ,1  ,1  ,2  ,NaN,NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN
            2  ,1  ,1  ,1  ,1  ,1  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            2  ,1  ,2  ,1  ,1  ,2  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN,NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,2  ,2  ,1  ,1  ,2  ,2  ,NaN,NaN,2  ,2  ,2  ,2  ,2  ,2  ,NaN
            2  ,1  ,2  ,1  ,1  ,2  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            2  ,1  ,1  ,1  ,1  ,1  ,1  ,2  ,2  ,1  ,1  ,1  ,1  ,1  ,1  ,2
            NaN,2  ,1  ,1  ,1  ,1  ,2  ,NaN,NaN,2  ,2  ,2  ,2  ,2  ,2  ,NaN
            NaN,NaN,2  ,1  ,1  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,2  ,2  ,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            ];

        % for drawing the zoom line
        axH = axes(...
            'units'                     , 'normalized', ...
            'position'                  , [0 0 1 1], ...
            'box'                       , 'on', ...
            'hittest'                   , 'off', ...
            'xlim'                      , [0 1], ...
            'xtick'                     , [], ...
            'ylim'                      , [0 1], ...
            'ytick'                     , [], ...
            'handlevisibility'          , 'callback', ...
            'visible'                   , 'off', ...
            'parent'                    , handles.GUI, ...
            'tag'                       , 'InvisibleAxes');

        handles.ZoomLine=line(NaN, NaN, ...
            'linestyle'                 , '-', ...
            'linewidth'                 , 3, ...
            'color'                     , 'w', ...
            'parent'                    , axH, ...
            'tag'                       , 'ZoomLine');
        handles.ZoomLine=line(NaN, NaN, ...
            'linestyle'                 , '--', ...
            'linewidth'                 , 2, ...
            'color'                     , 'r', ...
            'parent'                    , axH, ...
            'tag'                       , 'ZoomLine');
        set(handles.GUI, ...
            'units', 'normalized', ...
            'outerPosition', [0 0 1 1], ...
            'Color', myData.settings.BG_color, ...
            'busyaction', 'queue', ...
            'doublebuffer', 'on', ...
            'handlevisibility', 'callback', ...
            'interruptible', 'on', ...
            'menubar', 'none', ...
            'numbertitle', 'off', ...
            'toolbar', 'none', ...
            'defaultaxesunits', 'pixels', ...
            'defaulttextfontunits', 'pixels', ...
            'defaulttextfontname', 'Verdana', ...
            'defaulttextfontsize', 12, ...
            'defaultuicontrolunits', 'pixels', ...
            'defaultuicontrolfontunits', 'pixels', ...
            'defaultuicontrolfontsize', 10, ...
            'defaultuicontrolfontname', 'Verdana', ...
            'defaultuicontrolinterruptible', 'off',...
            'visible','off');


        % The initial properties of the axis obejct for plotting the stimuli
        % images are set
        set(handles.ImageAxes, 'Visible', 'off', ...
            'Units', 'Pixels',...
            'xtick', [], ...
            'ytick', [], ...
            'interruptible', 'off', ...
            'busyaction', 'queue', ...
            'Color', myData.settings.Axes_BG);

        % The image objects for the indicators for panning and zooming are
        % created
        %     handles.zooming_indication=...
        %         image(myData.graphics.zooming_not_allowed,'Parent',handles.ZoomingInfoImage);
        %     set(handles.zooming_indication,'visible','off');
        %     handles.moving_indication=...
        %         image(myData.graphics.moving_not_allowed,'Parent',handles.PanningInfoImage);
        %     set(handles.moving_indication,'visible','off');
        %
        %     set(handles.ZoomingInfoImage, ...
        %         'xtick', [], ...
        %         'ytick', [], ...
        %         'Visible','off');
        %     set(handles.PanningInfoImage, ...
        %         'xtick', [], ...
        %         'ytick', [], ...
        %         'Visible','off');

        % Foreground color, background color and the background color of the
        % axes is adjusted in accordance with the settings acquired from the
        % input file
        set(handles.main_panel,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ShadowColor',myData.settings.BG_color,...
            'HighlightColor',myData.settings.FG_color,...
            'ForegroundColor',myData.settings.FG_color);
        set(handles.task_panel,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ShadowColor',myData.settings.BG_color,...
            'HighlightColor',myData.settings.FG_color,...
            'ForegroundColor',myData.settings.FG_color);
        set(handles.NextButton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color);
        set(handles.PauseButton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.ResumeButton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.ResetViewButton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.Fast_Register_Button,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.Best_Register_Button,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.Refine_Register_Button,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.videobutton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set(handles.Backbutton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');
        set (handles.Reticlebutton,...
            'FontSize', myData.settings.FontSize,...
            'BackgroundColor',myData.settings.BG_color,...
            'ForegroundColor',myData.settings.FG_color,...
            'Visible', 'off');

        % Update handles.GUI
        guidata(handles.GUI, handles);
        % Initiate the first task
        Update_GUI_Elements(handles);

    catch ME
        error_show(ME)
    end
end

function varargout = GUI_OutputFcn(hObj, eventdata, handles)
    varargout{1} = handles.output;
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    guiFrame = get(handles.GUI,'javaFrame');
    set(guiFrame,'Maximized',1);
    set(handles.GUI,'visible','on')
end



%% NextButtonPressed, Update_GUI_Elements

function NextButtonPressed(hObj, eventdata, handles) %#ok<DEFNU>
    try
        %--------------------------------------------------------------------------
        % This callback function executes when the 'Next' button is pressed.
        % The function reads the input from the GUI objects, updates the
        % captions on the GUI objects, ereses the values of the GUE elements
        % and saves the input from the GUI objects.
        % myData structure is read from the handles structure - handles
        % structure is used as a tool for accessing the data by multiple GUI
        % objects
        %--------------------------------------------------------------------------

        myData=handles.myData;
        set(handles.NextButton, 'Enable', 'off');
        set(handles.Backbutton, 'Enable', 'on');
        st = dbstack;

        % Close out current task and record duration for all task except refine
        % reigstration
        if  myData.refineRegistration == 0
            taskinfo = myData.tasks_out{myData.iter};
            handles.myData.EndTime = clock;
            taskinfo.duration = etime(handles.myData.EndTime, handles.myData.StartTime)+taskinfo.duration;
            handles.myData.tasks_out{handles.myData.iter} = taskinfo;
            guidata(handles.GUI, handles);
            % exort output file
            if ~strcmp(st(2).name,'Backbutton_Callback')

                taskinfo.calling_function = st(1).name;
                handles.myData.taskinfo = taskinfo;
                guidata(handles.GUI, handles);
                taskinfo.task_handle(handles.GUI);
                handles = guidata(handles.GUI);
                exportOutput(handles.GUI);
                handles = guidata(handles.GUI);

            end
            % If the completed task was a 'finish' task, then return
            switch taskinfo.id
                case 'finish'

                    close all force
                    return

            end

        else
            handles.myData.refineRegistration = 0;
            taskinfo = myData.taskinfo;
            taskinfo.calling_function = st(1).name;
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI, handles);
            taskinfo.task_handle(handles.GUI);
            handles = guidata(handles.GUI);
        end

        % Begin the next task
        handles.myData.iter = handles.myData.iter+1;
        guidata(handles.GUI, handles);

        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        handles.myData.taskinfo = taskinfo;
        % temp comment out
        %handles.myData.StartTime = clock;
        guidata(handles.GUI,handles);
        handles = guidata(handles.GUI);
        myData = handles.myData;
        taskinfo.durationMove = 0;
        taskinfo.durationAutoReg = 0;
        % If the current task is 'finish' task, then return
        switch taskinfo.id
            case 'finish'
                Update_GUI_Elements(handles);
                return

        end

        % Move stage and show image
        switch myData.mode_desc
            case 'MicroRT'
                if handles.myData.yesno_micro == 1 & ~isfield(taskinfo,'dontextract')
                    stagedata = myData.stagedata{taskinfo.slot};
                    moveStartTime = clock;
                    % map wsi_new to stage_new
                    if 1
                        % wsi_new holds current ROI coordinates
                        wsi_new = double(transpose([taskinfo.roi_x, taskinfo.roi_y]));

                        % wsi_Minv maps wsi coordinates to standard coordinate plane
                        % given reference point wsi_0 = [wsi_x0, wsi_y0]
                        wsi_Minv = stagedata.wsi_Minv;
                        wsi_0 = transpose(stagedata.wsi_positions(1,:));
                        % stage_M maps standard coordinate plane to stage coordinates
                        % given reference point stage_0 = [stage_x0, stage_y0]
                        stage_M = stagedata.stage_M;
                        stage_0 = transpose(stagedata.stage_positions(1,:));

                        % Shift to set wsi reference as origin
                        temp = wsi_new - wsi_0;
                        % Map to standard coordinate plane
                        temp = wsi_Minv * temp;
                        % Map to stage coordinates
                        temp = stage_M * temp;
                        % Shift to unset stage reference as origin
                        stage_new = int64(temp + stage_0);

                        % offset_stage was determined during stage allignment
                        % it compensates for any misalignment between the eyepiece
                        % cener and the reticle center in stage coordinates

                        % eyepiece offset
                        offset_stage = int64(myData.settings.offset_stage);
                        % registration refine offset
                        offset_reg_refine = int64(myData.settings.offset_reg_refine{taskinfo.slot});
                        stage_new = stage_new' - offset_stage + offset_reg_refine;
                    end
                    taskinfo.stage_x = stage_new(1);
                    taskinfo.stage_y = stage_new(2);
                    myData.stage = stage_move(myData.stage,stage_new);
                    taskimage_load(hObj);
                    handles = guidata(handles.GUI);
                    set(handles.iH,'visible','off');
                    set(handles.ImageAxes,'visible','off')
                    moveEndTime = clock;
                    taskinfo.durationMove = etime(moveEndTime, moveStartTime);
                    %auto fast register
                    if myData.settings.autoreg == 1
                        autoRegStartTime = clock;
                        Fast_Register_Button_Callback(hObj, eventdata, handles);
                        autoRegEndTime = clock;
                        taskinfo.durationAutoReg = etime(autoRegEndTime,autoRegStartTime);
                    end

                end
        end
        % Save taskinfo, which contains new stage location

        myData.tasks_out{myData.iter} = taskinfo;
        handles.myData = myData;
        handles.myData.StartTime = clock;
        guidata(handles.GUI, handles);
        Update_GUI_Elements(handles);
        handles = guidata(handles.GUI);
        myData = handles.myData;
        taskinfo = myData.taskinfo;
        myData.tasks_out{myData.iter} = taskinfo;
        handles.myData = myData;
        guidata(handles.GUI, handles);
    catch ME
        error_show(ME)
    end

end

function Update_GUI_Elements(handles)
    try
        %--------------------------------------------------------------------------
        % This function gets the current task (taskinfo), saves it in handles.myData
        % This function ensures that only the GUI objects required for the
        % current evaluation task are visible. This function is execute every time
        % after the user presses 'Next' button
        %--------------------------------------------------------------------------

        % Task to be updated
        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        % New GUI design.
        % taskinfo.calling_function is Update_GUI_Elements
        % taskinfo.task_handle will initialize the GUI for the new task.
        st = dbstack;
        taskinfo.calling_function = st(1).name;
        handles.myData.taskinfo = taskinfo;
        guidata(handles.GUI, handles);
        taskinfo.task_handle(handles.GUI);


        % Treat two special cases
        handles = guidata(handles.GUI);
        taskinfo = handles.myData.taskinfo;
        switch taskinfo.id
            case {'start', 'finish'}
                return
        end

        % This shows the progress in the overall test
        display(['task.id     = ', taskinfo.id])
        display(['task.order  = ', num2str(taskinfo.order)])
        guidata(handles.GUI,handles);

    catch ME
        error_show(ME)
    end
end



%% Callbacks for GUI management buttons

function abortbutton_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    try
        % hObject    handle to abortbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        % Save and export current task information
        %     myData=handles.myData;
        %     taskinfo = myData.tasks_out{myData.iter};
        %     guidata(handles.GUI, handles);
        %     switch taskinfo.id
        %         case 'finish'
        %
        %             close all force
        %             return
        %
        %     end
        %     st = dbstack;
        %     taskinfo.calling_function = st(1).name;
        %     handles.myData.taskinfo = taskinfo;
        %     guidata(handles.GUI, handles);
        %     taskinfo.task_handle(handles.GUI);
        %     handles = guidata(handles.GUI);
        %
        %     % Save and export rest task information
        %     while(handles.myData.iter<=handles.myData.ntasks)
        %         handles.myData.iter = handles.myData.iter+1;
        %         guidata(handles.GUI, handles);
        %         taskinfo = handles.myData.tasks_out{handles.myData.iter};
        %         taskinfo.calling_function = st(1).name;
        %         handles.myData.taskinfo = taskinfo;
        %         guidata(handles.GUI,handles);
        %         taskinfo.task_handle(handles.GUI);
        %         handles = guidata(handles.GUI);
        %         % If the current task is 'finish' task, then return
        %         switch taskinfo.id
        %             case 'finish'
        %                 Update_GUI_Elements(handles);
        %                 return
        %
        %         end
        %     end
        %     fclose(handles.myData.fid);
        close all force

    catch ME
        error_show(ME)
    end

end

function videobutton_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    try
        % hObject    handle to videobutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        if ~isvalid(handles.cam_figure)
            handles.cam_figure = camera_preview(handles.cam, handles.myData.settings);
            guidata(handles.GUI, handles);
        end
        figure(handles.cam_figure)

    catch ME
        error_show(ME)
    end
end

function PauseButtonPressed(hObj, eventdata, handles) %#ok<DEFNU>
    try

        % This function creates an image with text to be displayed to the user

        % Task being paused
        % Close task being paused
        taskinfo = handles.myData.tasks_out{handles.myData.iter};
        handles.myData.EndTime=clock;
        taskinfo.duration = etime(handles.myData.EndTime, handles.myData.StartTime)+taskinfo.duration;
        handles.myData.tasks_out{handles.myData.iter} = taskinfo;
        st = dbstack;
        taskinfo.calling_function = st(1).name;
        handles.myData.taskinfo = taskinfo;
        guidata(handles.GUI, handles);
        taskinfo.task_handle(handles.GUI);

        % Enable the button to resume the study
        set(handles.ResumeButton, ...
            'Visible', 'on', ...
            'Enable','on');
        billboard(handles, '\bfPause')

    catch ME
        error_show(ME)
    end
end

function ResumeButtonPressed(hObj, eventdata, handles) %#ok<DEFNU>
    try

        % Task being paused
        taskinfo = handles.myData.tasks_out{handles.myData.iter};
        handles.myData.StartTime = clock;
        % Start task being paused
        st = dbstack;
        taskinfo.calling_function = st(1).name;
        handles.myData.taskinfo = taskinfo;
        guidata(handles.GUI, handles);
        taskinfo.task_handle(handles.GUI);
        handles = guidata(handles.GUI);

    catch ME
        error_show(ME)
    end
end

function ResetViewButtonPressed(hObj, eventdata, handles) %#ok<DEFNU>
    try
        %----------------------------------------------------------------------
        % This function is executed after the button 'Reset view' is pressed.
        % THe function ensures that the image is reloaded and shown in original
        % size and on [0,0] position.
        %----------------------------------------------------------------------

        myData = handles.myData;
        taskinfo = myData.tasks_out{myData.iter};
        % Redraw the Image from the Temporary Image Folder
        %taskimage_load(hObj);
        handles = guidata(hObj);

        switch myData.mode_desc
            case 'MicroRT'

                target_pos = [taskinfo.stage_x, taskinfo.stage_y];
                currentNextStatus = get(handles.NextButton,'enable');
                set(handles.NextButton,'enable','off');
                set(handles.Fast_Register_Button,'enable','off');
                set(handles.Best_Register_Button,'enable','off');
                set(handles.Refine_Register_Button,'enable','off');
                handles.myData.stage = stage_move(handles.myData.stage,target_pos);
                set(handles.NextButton,'enable',currentNextStatus);
                set(handles.Fast_Register_Button,'enable','on');
                set(handles.Best_Register_Button,'enable','on');
                set(handles.Refine_Register_Button,'enable','on');

        end

        %    myData.tasks_out{myData.iter} = taskinfo;
        %    handles.myData=myData;
        guidata(hObj, handles);

    catch ME
        error_show(ME)
    end
end


function Fast_Register_Button_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    try
        % hObject    handle to Fast_Register_Button (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)

        myData = handles.myData;
        settings = myData.settings;

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

        % Get the stage position
        handles.myData.stage = stage_get_pos(handles.myData.stage);
        stage_current = int64(handles.myData.stage.Pos);

        % Cross correlate the stage and wsi images
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

        % Find the offset and move the stage
        % CXC is padded by t_size(1)/2
        % (half the template width) on the left and right
        % CXC is padded by t_size(2)/2
        % (half the template height) on top and bottom
        cam2stage = handles.myData.settings.cam_hres2stage;
        [~, imax] = max(abs(CXC(:)));
        [ypeak, xpeak] = ind2sub(size(CXC),imax(1));
        xoffset = cam2stage*(roi_w/2 + cam_roi_w/2 - xpeak);
        yoffset = cam2stage*(roi_h/2 + cam_roi_h/2 - ypeak);
        offset_roi = order*int64([xoffset, yoffset]);
        stage_new = stage_current + offset_roi;
        offset_stage = int64(myData.settings.offset_stage);
        stage_new = stage_new - offset_stage;
        handles.myData.stage = stage_move(handles.myData.stage,stage_new);
    catch ME
        error_show(ME)
    end
end

%% General functions

% --- Executes on mouse motion over figure - except title and menu.
% --- NOT SURE WHAT IT IS USED FOR, MAYBE ZOOM AND DRAG
function GUI_WindowButtonMotionFcn(hObject, eventdata, handles)
    % hObject    handle to GUI (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% function winBtnMotionFcn(hObj,eventdata,handles) %#ok<DEFNU>
% try
%     %----------------------------------------------------------------------
%     % winBtnMotionFcn (nested under winBtnDownFcn)
%     %   This function is called when click-n-drag (panning) is happening
%     %----------------------------------------------------------------------
%     pt = get(handles.ImageAxes, 'currentpoint');
%
%     % Update axes limits and automatically set ticks
%     % Set aspect ratios
%     set(handles.ImageAxes, ...
%         'xlim', get(handles.ImageAxes, 'xlim') + ...
%         (handles.panning_Zooming_Tool.xy(1,1)-(pt(1,1)+pt(2,1))/2), ...
%         'ylim', get(handles.ImageAxes, 'ylim') + ...
%         (handles.panning_Zooming_Tool.xy(1,2)-(pt(1,2)+pt(2,2))/2), ...
%         'cameraviewanglemode', 'auto', ...
%         'plotboxaspectratio', handles.panning_Zooming_Tool.pbar);
%
%     guidata(hObj, handles);
% catch ME
%     error_show(ME)
% end
% end

% function zoomMotionFcn(hObj,eventdata,handles) %#ok<DEFNU>
% try
%     %----------------------------------------------------------------------
%     % zoomMotionFcn (nested under winBtnDownFcn)
%     %   This performs the click-n-drag zooming function. The pointer
%     %   location relative to the initial point determines the amount of
%     %   zoom (in or out).
%     %----------------------------------------------------------------------
%     C = 50;
%     pt = get(handles.GUI, 'currentpoint');
%     r = C ^ (10*(handles.panning_Zooming_Tool.initPt(2) ...
%         - pt(2)) / handles.panning_Zooming_Tool.figPos(4));
%     newLimSpan = r * handles.panning_Zooming_Tool.curPt2;
%     dTemp = diff(newLimSpan); %#ok<NASGU>
%     pt(1) = handles.panning_Zooming_Tool.initPt(1);
%
%     % Determine new limits based on r
%     lims = handles.panning_Zooming_Tool.curPt + newLimSpan;
%
%     % Update axes limits and automatically set ticks
%     % Set aspect ratios
%     set(handles.ImageAxes, ...
%         'xlim', lims(:,1), ...
%         'ylim', lims(:,2), ...
%         'cameraviewanglemode', 'auto', ...
%         'plotboxaspectratio', handles.panning_Zooming_Tool.pbar);
%
%     % Update zoom indicator line
%     set(handles.ZoomLine, ...
%         'xdata', [handles.panning_Zooming_Tool.initPt(1), ...
%         pt(1)]/handles.panning_Zooming_Tool.figPos(3), ...
%         'ydata', [handles.panning_Zooming_Tool.initPt(2), ...
%         pt(2)]/handles.panning_Zooming_Tool.figPos(4));
%
%     guidata(hObj, handles);
%
% catch ME
%     error_show(ME)
% end
% end

function GUI_WindowButtonUpFcn(hObj, eventdata, handles) %#ok<DEFNU>
    try
        %--------------------------------------------------------------------------
        % winBtnUpFcn
        %   This is called when the mouse is released
        % This function is the part of the imageviewer Matlab
        % application and was not written by me. It is under BSD licence.
        %--------------------------------------------------------------------------

        set(handles.GUI, ...
            'pointer', 'arrow', ...
            'windowbuttonmotionfcn' , '');

        set(handles.ZoomLine, 'xdata', NaN, 'ydata', NaN);
        set(handles.GUI, 'windowbuttonupfcn', '');

        guidata(hObj, handles);

    catch ME
        error_show(ME)
    end
end

function Generate_Transformation_Matrix(handles)
    try
        %----------------------------------------------------------------------
        % Generate_Transformation_Matrix calculates the matrix used for
        % transformation of coordinates between the stage and the glass slide
        %----------------------------------------------------------------------

        myData = handles.myData;
        n_wsi = myData.settings.n_wsi;
        stagedata_cell_array = cell(1,n_wsi);

        for slot_i=1:n_wsi

            wsi_info = myData.wsi_files{slot_i};

            temp = textscan(wsi_info.fullname, '%s %s', 'delimiter', '.');
            stagedata_file = [char(temp{1}),'.mat'];
            load(stagedata_file)

            Calib_Point_WSI_A=transpose(stagedata.wsi_positions(1,:));
            Calib_Point_WSI_B=transpose(stagedata.wsi_positions(2,:));
            Calib_Point_WSI_C=transpose(stagedata.wsi_positions(3,:));
            Calib_Point_stage_A=transpose(stagedata.stage_positions(1,:));
            Calib_Point_stage_B=transpose(stagedata.stage_positions(2,:));
            Calib_Point_stage_C=transpose(stagedata.stage_positions(3,:));

            stagedata.wsi_v1=Calib_Point_WSI_B-Calib_Point_WSI_A;
            stagedata.wsi_v2=Calib_Point_WSI_C-Calib_Point_WSI_A;

            stagedata.stage_v1=Calib_Point_stage_B-Calib_Point_stage_A;
            stagedata.stage_v2=Calib_Point_stage_C-Calib_Point_stage_A;

            % wsi_Minv and wsi_M map wsi coordinates
            % to and from the standard coordinate plane
            stagedata.wsi_M = [stagedata.wsi_v1, stagedata.wsi_v2];
            temp = [stagedata.wsi_M, transpose([1,0]), transpose([0,1])];
            temp=rref(temp);
            stagedata.wsi_Minv = temp(:,3:4);

            % stage_Minv and stage_M map stage coordinates
            % to and from the standard coordinate plane
            stagedata.stage_M = [stagedata.stage_v1, stagedata.stage_v2];
            temp = [stagedata.stage_M, transpose([1,0]), transpose([0,1])];
            temp=rref(temp);
            stagedata.stage_Minv = temp(:,3:4);

            save(stagedata_file,'stagedata');
            stagedata_cell_array{slot_i} = stagedata;

        end

        handles.myData.stagedata = stagedata_cell_array;
        guidata(handles.GUI, handles);

    catch ME
        error_show(ME)
    end

end

%% Obsolete functions

function pos_stage=wsi2stage_old(handles) %#ok<DEFNU>
    try
        %----------------------------------------------------------------------
        % Transform_WSI_to_Stage_coords transforms the coordinates from the whole
        % slide image (in pixels) into glass slide coordinates (in the units of the stage)
        %----------------------------------------------------------------------

        v1_stage=transpose(stagedata.v1_stage(Slot,:));
        v2_stage=transpose(stagedata.v2_stage(Slot,:));
        v1_WSI=transpose(stagedata.v1_WSI(Slot,:));
        v2_WSI=transpose(stagedata.v2_WSI(Slot,:));

        Calib_Point_stage_A=transpose(stagedata.Calib_Point_stage_A(Slot,:));
        Calib_Point_WSI_A=transpose(stagedata.Calib_Point_WSI_A(Slot,:));

        M=[v1_WSI v2_WSI];

        % Calib_Point_WSI is from the registeration process
        % pos_WSI is the desired position selected by the the administrator

        w_WSI=transpose(pos_WSI)-Calib_Point_WSI_A;

        M_solved=rref([M w_WSI]);
        w_stage=M_solved(1,3).*v1_stage+M_solved(2,3).*v2_stage;
        pos_stage=int64(transpose(w_stage+Calib_Point_stage_A));

    catch ME
        error_show(ME)
    end
end


% --- Executes on button press in Backbutton.
function Backbutton_Callback(hObj, eventdata, handles)
    % hObject    handle to Backbutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    try
        myData=handles.myData;
        taskinfo = myData.tasks_out{myData.iter};
        handles.myData.EndTime = clock;
        taskinfo.duration = etime(handles.myData.EndTime, handles.myData.StartTime)+taskinfo.duration;
        handles.myData.StartTime = clock;
        handles.myData.tasks_out{handles.myData.iter} = taskinfo;

        st = dbstack;
        taskinfo.calling_function = st(1).name;
        handles.myData.taskinfo = taskinfo;
        guidata(handles.GUI, handles);
        taskinfo.task_handle(handles.GUI);
        handles = guidata(handles.GUI);
        handles.myData.iter = handles.myData.iter-2;
        guidata(handles.GUI, handles);

        NextButtonPressed(hObj, eventdata, handles);
        set(handles.Backbutton, 'Enable', 'off');

    catch ME
        error_show(ME)
    end
end


% --- Executes on button press in Best_Register_Button.
function Best_Register_Button_Callback(hObject, eventdata, handles)
    % hObject    handle to Best_Register_Button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    try
        % hObject    handle to registerbutton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)

        myData = handles.myData;
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

        % Get the stage position and snap a picture: cam_image
        handles.myData.stage = stage_get_pos(handles.myData.stage);
        stage_current = int64(handles.myData.stage.Pos);
        offset_stage = int64(myData.settings.offset_stage);
        stage_new = stage_current + offset_stage;
        handles.myData.stage = stage_move(handles.myData.stage,stage_new);
        handles.myData.stage = stage_get_pos(handles.myData.stage);
        stage_current = int64(handles.myData.stage.Pos);
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
        cam2stage = handles.myData.settings.cam_hres2stage;
        [CXC_y,CXC_x]=size(CXC);
        CXC_x_use = round(CXC_x/2) - ceil(search_w/2-1) : round(CXC_x/2) + ceil(search_w/2);
        CXC_y_use = round(CXC_y/2) - ceil(search_h/2-1) : round(CXC_y/2) + ceil(search_h/2);
        CXC=CXC(CXC_y_use,CXC_x_use);
        [~, imax] = max(CXC(:));
        [ypeak, xpeak] = ind2sub(size(CXC),imax(1));
        xoffset = cam2stage*(search_w/2 - xpeak);
        yoffset = cam2stage*(search_h/2 - ypeak);
        offset_roi = order*int64([xoffset, yoffset]);
        stage_new = stage_current + offset_roi;
        offset_stage = int64(myData.settings.offset_stage);
        stage_new = stage_new - offset_stage;
        handles.myData.stage = stage_move(handles.myData.stage,stage_new);
    catch ME
        error_show(ME)
    end
end




% --- Executes on button press in Reticlebutton.
function Reticlebutton_Callback(hObject, eventdata, handles)
    % hObject    handle to Reticlebutton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if handles.reticle == 1
        handles.reticle = 0;
        set(handles.Reticlebutton,'String','Show reticle');
    else
        handles.reticle = 1;
        set(handles.Reticlebutton,'String','Hide reticle');
    end
    guidata(handles.GUI, handles);
    taskimage_load(hObject);
    handles = guidata(hObject);
    st = dbstack;
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.calling_function = st(1).name;
    handles.myData.taskinfo = taskinfo;
    guidata(handles.GUI, handles);
    taskinfo.task_handle(handles.GUI);
    %set(handles.NextButton,'Enable', 'off');

end


function exportOutput(hObj)
    try
        handles = guidata(hObj);
        st = dbstack;
        myData = handles.myData;
        exportIter = 1;
        while exportIter <= myData.finshedTask+1

            taskinfo = myData.tasks_out{exportIter};
            taskinfo.currentWorking = -1;
            % handles.myData.tasks_out{handles.myData.iter} = taskinfo;
            taskinfo.calling_function = st(1).name;
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI, handles);
            taskinfo.task_handle(handles.GUI);
            handles = guidata(handles.GUI);
            exportIter = exportIter +1;
        end


        while(exportIter<=handles.myData.ntasks+1)

            taskinfo = handles.myData.tasks_out{exportIter};
            if exportIter <= handles.myData.iter
                taskinfo.currentWorking = 1;
            else
                taskinfo.currentWorking = 0;
            end
            taskinfo.calling_function = st(1).name;
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI,handles);
            taskinfo.task_handle(handles.GUI);
            handles = guidata(handles.GUI);
            exportIter = exportIter+1;
            % If the current task is 'finish' task, then return
            switch taskinfo.id
                case 'finish'
                    Update_GUI_Elements(handles);
                    return
            end
        end
        fclose(handles.myData.fid);
    catch ME
        error_show(ME)
    end
end


% --- Executes on button press in Refine_Register_Button.
function Refine_Register_Button_Callback(hObject, eventdata, handles)
    % hObject    handle to Refine_Register_Button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    myData=handles.myData;
    % clean current task elements
    taskinfo = myData.taskinfo;
    st = dbstack;
    taskinfo.calling_function = st(1).name;
    handles.myData.taskinfo = taskinfo;
    guidata(handles.GUI, handles);
    taskinfo.task_handle(handles.GUI);
    handles = guidata(handles.GUI);
    myData=handles.myData;

    % only keep slot ID and create new taskinfo
    taskinfo = myData.tasks_out{myData.iter};
    slot = taskinfo.slot;
    taskinfo = struct;
    taskinfo.slot = slot;
    taskinfo.calling_function = st(1).name;
    taskinfo.rotateback = 0;
    taskinfo.task = 'refine registration';
    taskinfo.task_handle = str2func('@task_refine_registration');
    taskinfo.text = 'Refine registration for this slide';
    taskinfo.highMag = 1;
    myData.taskinfo = taskinfo;
    myData.refineRegistration = 1;
    handles.myData = myData;
    guidata(handles.GUI, handles);

    % load stage data for this slide
    wsi_info = myData.wsi_files{taskinfo.slot};
    WSIfile=wsi_info.fullname;
    temp = textscan(wsi_info.fullname, '%s %s', 'delimiter', '.');
    stagedata_file = [char(temp{1}),'.mat'];
    load(stagedata_file)
    % get WSI and stage position for the first anchor
    WSIanchor1 = stagedata.wsi_positions(1,:);
    Stageanchor1 = stagedata.stage_positions(1,:);

    % extract high resolution WSI anchor
    highMagName = [myData.registration_images_dir, num2str(taskinfo.slot), 'HighRes.tif'];
    Left = WSIanchor1(1)-400;
    Top  = WSIanchor1(2)-400;
    success = ExtractROI_BIO(wsi_info, WSIfile, highMagName,...
        Left, Top, 800, 800,...
        800, 800,...
        handles.myData.settings.RotateWSI,...
        wsi_info.rgb_lut);
    taskinfo.highMagName = highMagName;
    taskinfo.ROIname = highMagName;            % default is high Mag image
    taskinfo.Stageanchor1 = Stageanchor1;

    % use golbal registration first achor high resolution image as low resolution anchor
    lowMagName = [myData.registration_images_dir,'hres_s', num2str(taskinfo.slot), 'p1_thumb.tif'];
    taskinfo.lowMagName = lowMagName;

    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(handles.GUI, handles);

    % move stage to the anchor
    myData.stage = stage_move(myData.stage,Stageanchor1);

    % get into refine registration task
    taskinfo.task_handle(handles.GUI);
    handles = guidata(handles.GUI);
end

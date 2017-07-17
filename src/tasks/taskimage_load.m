function taskimage_load(hObj)
try
    %--------------------------------------------------------------------------
    % This function loads the stimulus image and displayes it on the
    % ImageAxes. It also modifies the axes properties so that the stimulus
    % image fits.
    % This function is the part of the imageviewer Matlab
    % application and was not written by me.
    %--------------------------------------------------------------------------
    
    handles = guidata(hObj);
    panning_Zooming_Tool=handles.panning_Zooming_Tool;
    myData=handles.myData;
    settings = myData.settings;
    taskinfo = myData.taskinfo;

    % Read the image
    [handles.ImX, map] = imread(taskinfo.ROIname);
    % [handles.ImX, panning_Zooming_Tool.iminfo] = readImageFileFcn(filename);
    if myData.taskinfo.rotateback==1
        handles.ImX = imrotate(handles.ImX, -handles.myData.settings.RotateWSI);
    end
    if ~isnan(handles.ImX)

        % Apply reticle mask
        if handles.reticle == 1
            handles.ImX = reticle_apply_mask(...
                handles.ImX,...
                settings.scan_mask{taskinfo.slot});
        end
        temp=size(handles.ImX);
        imageydim=temp(1);
        imagexdim=temp(2);
        set(handles.ImageAxes,'Units', 'pixels')
        set(handles.task_panel, 'Units','pixels');
        position1 = int64(get(handles.task_panel, 'Position'));
        set(handles.task_panel, 'Units','normalized');
        set(handles.ImageAxes,'Position', [5, position1(4)+5, imagexdim, imageydim]);
        % Clear the axes and display the image
        cla(handles.ImageAxes);
        iH = image(handles.ImX,'parent', handles.ImageAxes);
        set(iH, 'hittest', 'off');
        axis(handles.ImageAxes, 'image');
        set(handles.ImageAxes, ...
            'box', 'off', ...
            'ButtonDownFcn', {@ImageAxes_ButtonDownFcn, handles},...
            'xtick', [], ...
            'ytick', [], ...
            'Color', handles.myData.settings.Axes_BG, ...
            'interruptible', 'off', ...
            'busyaction', 'queue', ...
            'handlevisibility', 'callback');
        
        % Set panning_Zooming_Tool parameters
        sz = size(handles.ImX);
        panning_Zooming_Tool.xlim100 = sz(2)/2 + [-1, 1] * panning_Zooming_Tool.axPos(3)/2;
        panning_Zooming_Tool.ylim100 = sz(1)/2 + [-1, 1] * panning_Zooming_Tool.axPos(4)/2;
        panning_Zooming_Tool.xlimFull = get(handles.ImageAxes, 'xlim');
        panning_Zooming_Tool.ylimFull = get(handles.ImageAxes, 'ylim');
        
        if all(panning_Zooming_Tool.axPos(3:4) > sz([2 1]))
            set(handles.ImageAxes, ...
                'xlim', panning_Zooming_Tool.xlimFull, ...
                'ylim', panning_Zooming_Tool.ylimFull, ...
                'cameraviewanglemode', 'auto', ...
                'plotboxaspectratio', panning_Zooming_Tool.pbar);
        end
    end

    handles.iH=iH;
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    handles.panning_Zooming_Tool = panning_Zooming_Tool;
    guidata(hObj, handles);
catch ME
    error_show(ME)
end
end

function ImageAxes_ButtonDownFcn(hObj, eventdata, handles) %#ok<*INUSD>
try
    %--------------------------------------------------------------------------
    %   This is called when the mouse is clicked in one the ImageAxes
    %   NORMAL clicks will launch the functiong taskinfo.task_handle
    %   ALT clicks will start zooming mode.
    %   EXTEND clicks will move the image.
    %   OPEN clicks will center the view.
    %--------------------------------------------------------------------------
    
    %%%%% If counter variable not 1 then look for a variable that is
    %%%%% initialized at the end of this code to ensure the entire code has
    %%%%% sucessfully run through
    
    handles = guidata(hObj); %#ok<UNRCH>
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    
    switch get(handles.GUI, 'SelectionType')
        case 'normal' % Execute the task specific response
                        
            st = dbstack;
            taskinfo.calling_function = st(1).name;
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI, handles);
            taskinfo.task_handle(hObj);           
            
        case 'alt'
        case 'open'
    end
    
catch ME
    error_show(ME)
end
end

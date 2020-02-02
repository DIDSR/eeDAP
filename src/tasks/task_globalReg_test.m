function task_globalReg_test(hObj)
%description
%collect global registration distance and task camera picture

%task input column
%globalReg_test,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H

%task output column
%globalReg_test,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,
%global registration distance,
%global registration stage x position,global registration stage y
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            handles = guidata(hObj);            
            desc = taskinfo.desc;          
            taskinfo.task  = char(desc{1});
            taskinfo.id = char(desc{2});
            taskinfo.order = str2double(desc{3});
            taskinfo.slot = str2double(desc{4});
            taskinfo.roi_x  = str2double(desc{5});
            taskinfo.roi_y = str2double(desc{6});
            taskinfo.roi_w = str2double(desc{7});
            taskinfo.roi_h = str2double(desc{8});
            taskinfo.img_w = taskinfo.roi_w;
            taskinfo.img_h = taskinfo.roi_h;
            taskinfo.text  = 'Measure registration distance';
            taskinfo.rotateback = 0;
            taskinfo.done(1) = 0;
            taskinfo.done(2) = 0;
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
            % Count task response box
            handles.editCount = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [.45, .2, .1, .2], ...
                'Style', 'edit', ...
                'Tag', 'editCount', ...
                'Callback', @editCount_Callback);
            
            % Automatic registration before focus photo button
            handles.takePhoto = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position',[.2, .2, .2, .2], ...
                'Style', 'pushbutton', ...
                'Tag', 'takePhoto', ...
                'enable','on',...
                'String', 'Take Photo',...
                'Callback',@takePhoto_Callback);

            % Make count task response box active
            uicontrol(handles.editCount);
           
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback',...
                'Refine_Register_Button_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.takePhoto);
            delete(handles.editCount);
            handles = rmfield(handles, 'takePhoto');
            handles = rmfield(handles, 'editCount');

                    
        case 'exportOutput' % export current task information and reuslt
            if taskinfo.currentWorking ==1 % write finish task in current study
            fprintf(myData.fid, [...
                taskinfo.task, ',', ...
                taskinfo.id, ',', ...
                num2str(taskinfo.order), ',', ...
                num2str(taskinfo.slot), ',',...
                num2str(taskinfo.roi_x), ',',...
                num2str(taskinfo.roi_y), ',', ...
                num2str(taskinfo.roi_w), ',', ...
                num2str(taskinfo.roi_h), ',', ...
                num2str(taskinfo.score), ',', ...
                taskinfo.stagePosition]);
            elseif taskinfo.currentWorking ==0 % write undone task
                fprintf(myData.fid, [...
                    taskinfo.task, ',', ...
                    taskinfo.id, ',', ...
                    num2str(taskinfo.order), ',', ...
                    num2str(taskinfo.slot), ',',...
                    num2str(taskinfo.roi_x), ',',...
                    num2str(taskinfo.roi_y), ',', ...
                    num2str(taskinfo.roi_w), ',', ...
                    num2str(taskinfo.roi_h)]);
            else                               % write done task from previous study
                desc = taskinfo.desc;
                for i = 1 : length(desc)-1
                    fprintf(myData.fid,[desc{i},',']);
                end
                fprintf(myData.fid,[desc{length(desc)}]);
            end            
            fprintf(myData.fid,'\r\n');
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI, handles);    
            
    end

    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

function editCount_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.done(1)=1;
    if  taskinfo.done(1)*taskinfo.done(2)==1
        set(handles.NextButton,'Enable','on');
    end
    % Pack the results
    taskinfo.score = get(handles.editCount, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end

% --- Executes on button press in bestPhoto.
function takePhoto_Callback(hObject, eventdata)
% hObject    handle to bestPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(findobj('Tag','GUI'));
   % take picture and remember stage position
    myData=handles.myData;    
    cam_image = camera_take_image(handles.cam);
    taskinfo = myData.tasks_out{myData.iter};

    FolderName=[myData.output_files_dir,...
               strrep(myData.outputfile,'.dapso','GlobalRegPhoto')];
    if ~exist(FolderName,'file')
        mkdir(FolderName);
    end
    imwrite(cam_image,strcat(FolderName,'\',...
                'ID',taskinfo.id,...
                '_Slot',num2str(taskinfo.slot),...
                '_Order',num2str(taskinfo.order),...
                '_FOV.tif'));
    stage = stage_get_pos(myData.stage,myData.stage.handle);
    x = stage.Pos(1);
    y = stage.Pos(2);
    taskinfo.stagePosition = [int2str(x),',',int2str(y)];
    taskinfo.done(2)=1;
    if  taskinfo.done(1)*taskinfo.done(2)==1
        set(handles.NextButton,'Enable','on');
    end
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
end


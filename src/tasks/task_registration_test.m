function task_registration_test(hObj)
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
            taskinfo.img_w = str2double(desc{9});
            taskinfo.img_h = str2double(desc{10});
            taskinfo.text  = char(desc{11});
            taskinfo.moveflag = str2double(desc{12});
            taskinfo.zoomflag = str2double(desc{13});
            taskinfo.description = char(desc{14});
            taskinfo.rotateback = 0;
            taskinfo.done(1)=0;
            taskinfo.done(2)=0;
            taskinfo.done(3)=0;
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
            % Automatic registration text 
            handles.textCount1 = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.2, .4, .1, .2], ...
                'Style', 'text', ...
                'Tag', 'textCount1', ...
                'String', 'Auto');

            
            % Automatic registration
            handles.autoReg = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [.2, .3, .1, .2], ...
                'Style', 'edit', ...
                'Tag', 'autoReg', ...
                'Callback', @autoReg_Callback);
            
            % Fast registration text 
            handles.textCount2 = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.45, .4, .1, .2], ...
                'Style', 'text', ...
                'Tag', 'textCount2', ...
                'String', 'Fast');
            
            % Fast registration
            handles.fastReg = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [.45, .3, .1, .2], ...
                'Style', 'edit', ...
                'Tag', 'fastReg', ...
                'Callback', @fastReg_Callback);

            % Best registration text 
            handles.textCount3 = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.7, .4, .1, .2], ...
                'Style', 'text', ...
                'Tag', 'textCount3', ...
                'String', 'Best');
            
            % Best registration
            handles.bestReg = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [.7, .3, .1, .2], ...
                'Style', 'edit', ...
                'Tag', 'bestReg', ...
                'Callback', @bestReg_Callback);
            
            % Automatic registration before focus photo button
            handles.autoUnfocusPhoto = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position',[ .05, .1, .1, .2], ...
                'Style', 'pushbutton', ...
                'Tag', 'autoUnfocusPhoto', ...
                'enable','on',...
                'String', 'Unfocus Photo',...
                'Callback',@autoUnfocusPhoto_Callback);
            
            %  Automatic registration after focus photo button
            handles.autoFocusPhoto = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position',[.2, .1 , .1, .2], ...
                'Style', 'pushbutton', ...
                'Tag', 'autoFocusPhoto', ...
                'enable','on',...
                'String', 'Focus Photo',...
                'Callback',@autoFocusPhoto_Callback);
            
            %  Fast registration focus hoto button
            handles.fastPhoto = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position',[.45, .1, .1, .2], ...
                'Style', 'pushbutton', ...
                'Tag', 'fastPhoto', ...
                'enable','on',...
                'String', 'Fast Photo',...
                'Callback',@fastPhoto_Callback);
            
            %  Best registration focus hoto button
            handles.bestPhoto = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position', [.7, .1, .1, .2], ...
                'Style', 'pushbutton', ...
                'Tag', 'bestPhoto', ...
                'enable','on',...
                'String', 'Best Photo',...
                'Callback',@bestPhoto_Callback);           
            
            
            % Make count task response box active
            uicontrol(handles.autoReg);
           
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.textCount1);
            delete(handles.textCount2);
            delete(handles.textCount3);
            delete(handles.autoReg);
            delete(handles.fastReg);
            delete(handles.bestReg);
            delete(handles.autoUnfocusPhoto);
            delete(handles.autoFocusPhoto);
            delete(handles.fastPhoto);
            delete(handles.bestPhoto);
            handles = rmfield(handles, 'textCount1');
            handles = rmfield(handles, 'textCount2');
            handles = rmfield(handles, 'textCount3');
            handles = rmfield(handles, 'autoReg');
            handles = rmfield(handles, 'fastReg');
            handles = rmfield(handles, 'bestReg');
            handles = rmfield(handles, 'autoUnfocusPhoto');
            handles = rmfield(handles, 'autoFocusPhoto');
            handles = rmfield(handles, 'fastPhoto');
            handles = rmfield(handles, 'bestPhoto');

           % taskimage_archive(handles);

        case 'Save_Results' % Save the results for this task
            
            fprintf(taskinfo.fid, [...
                taskinfo.task, ',', ...
                taskinfo.id, ',', ...
                num2str(taskinfo.order), ',', ...
                num2str(taskinfo.slot), ',',...
                num2str(taskinfo.roi_x), ',',...
                num2str(taskinfo.roi_y), ',', ...
                num2str(taskinfo.roi_w), ',', ...
                num2str(taskinfo.roi_h), ',', ...
                num2str(taskinfo.img_w), ',', ...
                num2str(taskinfo.img_h), ',', ...
                taskinfo.text, ',', ...
                num2str(taskinfo.moveflag), ',', ...
                num2str(taskinfo.zoomflag), ',', ...
                taskinfo.description, ',', ...
                num2str(taskinfo.durationMove), ',', ...
                num2str(taskinfo.durationAutoReg), ',', ...
                num2str(taskinfo.duration), ',', ...
                taskinfo.regResult{1}, ',', ...
                taskinfo.stagePosition{1},',',...
                taskinfo.regResult{2}, ',', ...
                taskinfo.stagePosition{2},',',...
                taskinfo.regResult{3},',',...
                taskinfo.stagePosition{3}]);
            fprintf(taskinfo.fid,'\r\n');
            
    end

    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

function autoReg_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.done(1)=1;
    if  taskinfo.done(1)* taskinfo.done(2)*taskinfo.done(3)==1
        set(handles.NextButton,'Enable','on');
    end
    % Pack the results
    taskinfo.regResult{1} = get(handles.autoReg, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end

function fastReg_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.done(2)=1;
    if  taskinfo.done(1)* taskinfo.done(2)*taskinfo.done(3)==1
        set(handles.NextButton,'Enable','on');
    end
    % Pack the results
    taskinfo.regResult{2} = get(handles.fastReg, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end


function bestReg_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.done(3)=1;
    if  taskinfo.done(1)* taskinfo.done(2)*taskinfo.done(3)==1
        set(handles.NextButton,'Enable','on');
    end
    % Pack the results
    taskinfo.regResult{3} = get(handles.bestReg, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end


% --- Executes on button press in autoUnfocusPhoto.
function autoUnfocusPhoto_Callback(hObject, eventdata)
% hObject    handle to autoUnfocusPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
    handles = guidata(findobj('Tag','GUI'));
    myData=handles.myData;    
    cam_image = camera_take_image(handles.cam);
    taskinfo = myData.tasks_out{myData.iter};
    FolderName=[myData.output_files_dir,...
            strrep(myData.outputfile,'.dapso','RegPhoto')];
    if ~exist(FolderName,'file')
       mkdir(FolderName);
    end
    imwrite(cam_image,strcat(FolderName,'\',...
        'ID',taskinfo.id,...
        '_Slot',num2str(taskinfo.slot),...
        '_Order',num2str(taskinfo.order),...
        '_1autoUnfocus.tif'));
end


% --- Executes on button press in autoFocusPhoto.
function autoFocusPhoto_Callback(hObject, eventdata)
% hObject    handle to autoFocusPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(findobj('Tag','GUI'));
    myData=handles.myData;    
    cam_image = camera_take_image(handles.cam);
    taskinfo = myData.tasks_out{myData.iter};
    
    FolderName=[myData.output_files_dir,...
            strrep(myData.outputfile,'.dapso','RegPhoto')];
    if ~exist(FolderName,'file')
       mkdir(FolderName);
    end
    imwrite(cam_image,strcat(FolderName,'\',...
        'ID',taskinfo.id,...
        '_Slot',num2str(taskinfo.slot),...
        '_Order',num2str(taskinfo.order),...
        '_2autoFocus.tif'));
    stage = stage_get_pos(myData.stage,myData.stage.handle);
    x = stage.Pos(1);
    y = stage.Pos(2);
    taskinfo.stagePosition{1} = [int2str(x),',',int2str(y)];
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
end


% --- Executes on button press in fastPhoto.
function fastPhoto_Callback(hObject, eventdata)
% hObject    handle to fastPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(findobj('Tag','GUI'));
    myData=handles.myData;    
    cam_image = camera_take_image(handles.cam);
    taskinfo = myData.tasks_out{myData.iter};
    FolderName=[myData.output_files_dir,...
            strrep(myData.outputfile,'.dapso','RegPhoto')];
    if ~exist(FolderName,'file')
       mkdir(FolderName);
    end
    imwrite(cam_image,strcat(FolderName,'\',...
        'ID',taskinfo.id,...
        '_Slot',num2str(taskinfo.slot),...
        '_Order',num2str(taskinfo.order),...
        '_3fast.tif'));    
    stage = stage_get_pos(myData.stage,myData.stage.handle);
    x = stage.Pos(1);
    y = stage.Pos(2);
    taskinfo.stagePosition{2} = [int2str(x),',',int2str(y)];
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
end


% --- Executes on button press in bestPhoto.
function bestPhoto_Callback(hObject, eventdata)
% hObject    handle to bestPhoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(findobj('Tag','GUI'));
    myData=handles.myData;    
    cam_image = camera_take_image(handles.cam);
    taskinfo = myData.tasks_out{myData.iter};
    FolderName=[myData.output_files_dir,...
            strrep(myData.outputfile,'.dapso','RegPhoto')];
    if ~exist(FolderName,'file')
       mkdir(FolderName);
    end
    imwrite(cam_image,strcat(FolderName,'\',...
        'ID',taskinfo.id,...
        '_Slot',num2str(taskinfo.slot),...
        '_Order',num2str(taskinfo.order),...
        '_4best.tif'));
    
    stage = stage_get_pos(myData.stage,myData.stage.handle);
    x = stage.Pos(1);
    y = stage.Pos(2);
    taskinfo.stagePosition{3} = [int2str(x),',',int2str(y)];
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
end





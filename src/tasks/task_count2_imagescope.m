function task_count2_imagescope(hObj)
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
            
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
           
           %generate WSI file and openimage scope 
            %generate WSI file and openimage scope
            wsi_info = handles.myData.wsi_files{taskinfo.slot};
            wsi_scan_scale = wsi_info.scan_scale;
            Left = taskinfo.roi_x-(taskinfo.roi_w/2);
            Top  = taskinfo.roi_y-(taskinfo.roi_h/2);
            exportXML_ROIandCircle(wsi_info.fullname,wsi_scan_scale, taskinfo.id,handles.myData.workdir,...
            Left, Top, taskinfo.roi_w, taskinfo.roi_h);
            if strcmp(handles.myData.mode_desc,'Digital')
               taskinfo.rotateback = 1;
               myData.taskinfo = taskinfo;
               handles.myData = myData;               
            else
                taskinfo.rotateback = 0;
                position = [0.0, 0.8, .2, .2];
                 handles.RotateImage = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', 16, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position',position, ...
                'Style', 'pushbutton', ...
                'Tag', 'editvalue', ...
                'enable','on',...
                'String', 'Rotate to ImageScope direction',...
                'Callback',@RotateImage_Callback);
            end
            guidata(hObj, handles);
                
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
            % Static text question for count task
            handles.textCount = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.2, .2, .2, .2], ...
                'Style', 'text', ...
                'Tag', 'textCount', ...
                'String', taskinfo.description);

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
            
            
            % Make count task response box active
            uicontrol(handles.editCount);
        case {'NextButtonPressed',...
                'PauseButtonPressed',...
                'Backbutton_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.textCount);
            delete(handles.editCount);
            if ~strcmp(handles.myData.mode_desc,'Digital')
                delete(handles.RotateImage);
            end
            handles = rmfield(handles, 'textCount');
            handles = rmfield(handles, 'editCount');
            FolderName=[myData.output_files_dir,...
            strrep(myData.outputfile,'.dapso','xmlAnnotation')];
                if ~exist(FolderName,'file')
                   mkdir(FolderName);
                end
            fullOutputxml = [FolderName,'/',taskinfo.id,'.xml'];
            fullInputimage = myData.wsi_files{taskinfo.slot}.fullname;
            dotIndex = strfind(fullInputimage,'.');
            fullInputimage = fullInputimage(1:dotIndex(end));
            fullInputxml = [fullInputimage,'xml'];
            slashIndex = strfind(fullInputimage,'\');
            inputimage = fullInputimage(slashIndex(end)+1:end-1);
            fullOutputxml = [FolderName,'/',inputimage,'_',taskinfo.id,'.xml'];
            copyfile (fullInputxml, fullOutputxml);
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
                num2str(taskinfo.duration), ',', ...
                num2str(taskinfo.score)]);
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

function editCount_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    set(handles.NextButton, 'Enable', 'on');
    % Pack the results
    taskinfo.score = get(handles.editCount, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles); 
end

function RotateImage_Callback (hObj, eventdata)
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    if taskinfo.rotateback == 1 
       taskinfo.rotateback = 0;
       set(handles.RotateImage,'String','Rotate to ImageScope direction');
    else
       taskinfo.rotateback = 1;
       set(handles.RotateImage,'String','Rotate to Microscope direction');
    end
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);
    taskimage_load(hObj);
end



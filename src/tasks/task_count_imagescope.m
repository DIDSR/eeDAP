function task_count(hObj)
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
%             %generate WSI file
%             wsi_info = handles.myData.wsi_files{taskinfo.slot};
%             wsi_scan_scale = handles.myData.settings.scan_scale;
%             Left = taskinfo.roi_x-(taskinfo.roi_w/2);
%             Top  = taskinfo.roi_y-(taskinfo.roi_h/2);
%             exportXML(wsi_info.fullname,wsi_scan_scale, taskinfo.id,handles.myData.workdir,...
%             Left, Top, taskinfo.roi_w, taskinfo.roi_h);
        aaa=1;
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            %generate WSI file and openimage scope
            if strcmp(handles.myData.mode_desc,'Digital')
                wsi_info = handles.myData.wsi_files{taskinfo.slot};
                %wsi_scan_scale = handles.myData.settings.scan_scale;
                wsi_scan_scale = wsi_info.scan_scale;
                Left = taskinfo.roi_x-(taskinfo.roi_w/2);
                Top  = taskinfo.roi_y-(taskinfo.roi_h/2);
                exportXML(wsi_info.fullname,wsi_scan_scale, taskinfo.id,handles.myData.workdir,...
                Left, Top, taskinfo.roi_w, taskinfo.roi_h);
                taskinfo.rotateback = 1;
                myData.taskinfo = taskinfo;
                handles.myData = myData;
                guidata(hObj, handles);
            end
            
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
                'String', '<int>', ...
                'KeyPressFcn', @integer_test, ...
                'Callback', @editCount_Callback);

            % Make count task response box active
            uicontrol(handles.editCount);
           
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.textCount);
            delete(handles.editCount);
            handles = rmfield(handles, 'textCount');
            handles = rmfield(handles, 'editCount');

            taskimage_archive(handles);

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
% 
% function editCount_KeyPressFcn(hObj, eventdata)
% try
%     %--------------------------------------------------------------------------
%     % When the text box is non-empty, the user can continue
%     %--------------------------------------------------------------------------
%     handles = guidata(findobj('Tag','GUI'));
%     editCount_string = eventdata.Key;
% 
%     desc_digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
%     test = max(strcmp(editCount_string, desc_digits));
%     if test
%         set(handles.NextButton,'Enable','on');
%         
%     else
%         desc = 'Input should be an integer';
%         h_errordlg = errordlg(desc,'Application error','modal');
%         uiwait(h_errordlg)
% 
%         set(handles.editCount, 'String', '');
%         set(handles.NextButton, 'Enable', 'off');
% 
%         return
%     end
% 
% catch ME
%     error_show(ME)
% end
% 
% end

function editCount_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    valiad_input=taskinfo.valiad_input;
    if valiad_input==1
        set(handles.NextButton,'Enable','on');
        valiad_input=0;
    else
        set(handles.NextButton, 'Enable', 'off');
    end
    taskinfo.valiad_input=valiad_input;
    % Pack the results
    taskinfo.score = get(handles.editCount, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end
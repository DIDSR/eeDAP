function task_count(hObj)
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            taskinfo_default(hObj, taskinfo)
            handles = guidata(hObj);
            taskinfo = handles.myData.taskinfo;
            
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
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
                'String', taskinfo.q_op1);

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
                'KeyPressFcn', @editCount_KeyPressFcn, ...
                'Callback', @editCount_Callback);

            % Make count task response box active
            uicontrol(handles.editCount);
           
        case {'NextButtonPressed', ...
                'PauseButtonPressed'} % Clean up the task elements
            
            % Hide management buttons
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
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
                taskinfo.q_op1, ',', ...
                taskinfo.q_op2, ',', ...
                taskinfo.q_op3, ',', ...
                taskinfo.q_op4, ',', ...
                num2str(taskinfo.ans_time), ',', ...
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

function editCount_KeyPressFcn(hObj, eventdata)
try
    %--------------------------------------------------------------------------
    % When the text box is non-empty, the user can continue
    %--------------------------------------------------------------------------
    handles = guidata(findobj('Tag','GUI'));
    editCount_string = eventdata.Key;

    desc_digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
    test = max(strcmp(editCount_string, desc_digits));
    if test
        set(handles.NextButton,'Enable','on');
        
    else
        desc = 'Input should be an integer';
        h_errordlg = errordlg(desc,'Application error','modal');
        uiwait(h_errordlg)

        set(handles.editCount, 'String', '');
        set(handles.NextButton, 'Enable', 'off');

        return
    end

catch ME
    error_show(ME)
end

end

function editCount_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};

    % Pack the results
    taskinfo.ans_time = etime(clock, handles.myData.StartTime);
    taskinfo.score = get(handles.editCount, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end
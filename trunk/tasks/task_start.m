function task_start(hObj)
try

    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            % Any start task must have the following id/flag
            taskinfo.id = 'start';
            taskinfo.order = 0;
            
        case 'Update_GUI_Elements' % Update with the task elements
            
            set(handles.NextButton, 'Visible', 'on');

            % This function creates an image with text to be displayed to the user
            billboard(handles, '\bfWelcome');
            
            % Update the text describing the task
            desc = {'We appreciate your participation in our reader study', ...
                'Please enter your readerID'};
            handles.text_readerID = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', myData.settings.FontSize,...
                'BackgroundColor',myData.settings.BG_color, ...
                'ForegroundColor',myData.settings.FG_color, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'normalized', ...
                'Position', [.2, .5, .8, .5]);
            set(handles.text_readerID,'String',desc);    

            handles.edit_readerID = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [0.95, 0.95, 0.95], ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'normalized', ...
                'Position', [.2, 0, .6, .5], ...
                'String', 'readerID', ...
                'Tag', 'edit_readerID', ...
                'Callback', @edit_readerID_Callback, ...
                'KeyPressFcn', @edit_readerID_KeyPressFcn);
            
            % Set the focus to the edit_readerID box
            uicontrol(handles.edit_readerID);

        case 'NextButtonPressed' % Clean up the task elements
            
            set(handles.NextButton, 'Visible', 'off');

            delete(handles.edit_readerID);
            delete(handles.text_readerID);
            handles = rmfield(handles, 'edit_readerID');
            handles = rmfield(handles, 'text_readerID');
            
        case 'Save_Results' % Save the results for this task
            
            fprintf(taskinfo.fid, '%s\r\n', taskinfo.id);

    end

    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

function edit_readerID_KeyPressFcn(hObj, eventdata)
try
    %--------------------------------------------------------------------------
    % When the text box is non-empty, the reader can continue
    %--------------------------------------------------------------------------
    handles = guidata(findobj('Tag','GUI'));

    if strcmpi(get(handles.edit_readerID, 'String'),'')
        set(handles.NextButton,'Enable','off');
    else
        set(handles.NextButton,'Enable','on');
    end

catch ME
    error_show(ME)
end

end

function edit_readerID_Callback(hObj, eventdata, handles)
try
    
    handles = guidata(findobj('Tag','GUI'));
    uicontrol(handles.NextButton);

    % Save the readerID
    readerID = get(handles.edit_readerID, 'String');
    handles.myData.readerID = strrep(readerID, ' ', '_');

    % Start the clock
    handles.myData.StartTime=clock;
    desc_start_time = datestr(handles.myData.StartTime,30);

    % Determine the output filename
    outputfile = strrep(handles.myData.inputfile, ...
                '.dapsi','.dapso');
            switch handles.myData.mode_desc
                case 'Digital'
                    outputfile = ['digital.',...
                        handles.myData.readerID,'.',...
                        desc_start_time,'.',...
                        outputfile] %#ok<NOPRT>
                case 'MicroRT'
                    outputfile = ['micro_rt.',...
                        handles.myData.readerID,'.',...
                        desc_start_time,'.',...
                        outputfile] %#ok<NOPRT>
            end
            handles.myData.outputfile = outputfile;

    guidata(handles.GUI, handles);

catch ME
    error_show(ME)
end

end 
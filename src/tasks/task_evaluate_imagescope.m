function task_evaluate_imagescope(hObj)
%description
%evaluate ROI with one number
%task opens imagescope with ROI annotation

%task input column
%evaluate_imagescope,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,Qtext,evaluateText

%task input column
%evaluate_imagescope,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,Qtext,evaluateText
%task duration,evaluate result
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
            desc = taskinfo.desc;
            taskinfo.rotateback = 0;
            taskinfo.evaluateText = char(desc{10});
            if length(taskinfo.desc)>10
                myData.finshedTask = myData.finshedTask + 1;
            end         
%             %generate WSI file
%             wsi_info = handles.myData.wsi_files{taskinfo.slot};
%             wsi_scan_scale = handles.myData.settings.scan_scale;
%             Left = taskinfo.roi_x-(taskinfo.roi_w/2);
%             Top  = taskinfo.roi_y-(taskinfo.roi_h/2);
%             exportXML(wsi_info.fullname,wsi_scan_scale, taskinfo.id,handles.myData.workdir,...
%             Left, Top, taskinfo.roi_w, taskinfo.roi_h);
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
            handles.textEvaluate = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.2, .2, .2, .2], ...
                'Style', 'text', ...
                'Tag', 'textEvaluate', ...
                'String', taskinfo.evaluateText);

            % Count task response box
            handles.editEvaluate = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [.45, .2, .1, .2], ...
                'Style', 'edit', ...
                'Tag', 'editEvaluate', ...
                'Callback', @editEvaluate_Callback);

            % Make count task response box active
            uicontrol(handles.editEvaluate);
           
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback',...
                'Refine_Register_Button_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.textEvaluate);
            delete(handles.editEvaluate);
            handles = rmfield(handles, 'textEvaluate');
            handles = rmfield(handles, 'editEvaluate');

            taskimage_archive(handles);
        case 'exportOutput' % export current task information and reuslt
            evaluateText = strrep(taskinfo.evaluateText,'%','%%');
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
                    taskinfo.text, ',', ...
                    evaluateText, ',', ...
                    num2str(taskinfo.duration), ',', ...
                    num2str(taskinfo.score)]);
          elseif taskinfo.currentWorking ==0 % write undone task
                fprintf(myData.fid, [...
                    taskinfo.task, ',', ...
                    taskinfo.id, ',', ...
                    num2str(taskinfo.order), ',', ...
                    num2str(taskinfo.slot), ',',...
                    num2str(taskinfo.roi_x), ',',...
                    num2str(taskinfo.roi_y), ',', ...
                    num2str(taskinfo.roi_w), ',', ...
                    num2str(taskinfo.roi_h), ',', ...
                    taskinfo.text, ',', ...
                    evaluateText]);
            else                               % write done task from previous study
                desc = taskinfo.desc;
                for i = 1 : length(desc)-1
                    fprintf(myData.fid,[strrep(desc{i},'%','%%'),',']);
                end
                fprintf(myData.fid,[desc{strrep(length(desc),'%','%%')}]);
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
% 


function editEvaluate_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    set(handles.NextButton,'Enable','on');
    % Pack the results
    taskinfo.score = get(handles.editEvaluate, 'String');
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end
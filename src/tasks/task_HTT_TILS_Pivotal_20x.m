function task_HTT_TILS_Pivotal_20x(hObj)
%description
%collect "Evaluable/Not Evaluable" for sTILs in each ROI 
%IF ROI is "Evaluable" collect % Tumor Associated Stroma & sTILs Density

%task input column
%HTT_TILS_Pivotal_20x,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,Qtext


%task output column
%HTT_TILS_Pivotal_20x,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,Qtext,
%duration,status,percentstroma,score

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
            taskinfo.showingROI = 1;
            if length(taskinfo.desc)>9
                myData.finshedTask = myData.finshedTask + 1;
            end
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            % Load the image
            ROIname = [handles.myData.task_images_dir, taskinfo.id, '.tif'];
            taskinfo.ROIname = ROIname;
            taskinfo.showingROI = 1;
            handles.myData.taskinfo = taskinfo;
            guidata(hObj, handles);
%           taskimage_load_halfscale(hObj);  kne2023, function  not found
            taskimage_load(hObj);       % line45  workaround? -kne2023
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
 % question 1: Evaluable / Not Evaluable for sTILs
            handles.question1panel = uibuttongroup('Parent',handles.task_panel,...
                'Position',[0.1,0.7,0.28,0.1],...
                'visible','on');
            
            handles.question1text = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [0.1,0.8,0.8,0.1], ...
                'Style', 'text', ...
                'Tag', 'question1text', ...
                'String', '1. Is this ROI Evaluable for sTILs?');
            
            handles.radiobutton1A = uicontrol(...
                'Parent', handles.question1panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [0,0,0.25,1], ...
                'Style', 'radiobutton', ...
                'Tag', 'radiobutton1A', ...
                'String', 'Evaluable');
            
            handles.radiobutton1B = uicontrol(...
                'Parent', handles.question1panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [0.25,0,0.25,1], ...
                'Style', 'radiobutton', ...
                'Tag', 'radiobutton1B', ...
                'String', 'Not Evaluable');
            
            set(handles.question1panel, ...
                'SelectionChangeFcn', @radiobutton1_Callback, ...
                'SelectedObject', []);
 % question 2: Percent Tumor-Associated Stroma
            handles.question2text = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [0.1,0.55,0.8,0.1], ...  
                'Style', 'text', ...
                'Enable','off',...
                'Tag', 'question2text', ...
                'String', '2: What is the percent of tumor-assocciated stroma?');
            
            handles.question2percent = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [0.32,0.55,0.05,0.1], ...
                'Style', 'edit', ...
                'Enable','off',...
                'Tag', 'question2percent', ...
                'Callback', @question2percent_Callback);
            

 % question 3: sTILs Density Score
            handles.question3text = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [0.1,0.3,0.8,0.1], ...
                'Style', 'text', ...
                'Enable','off',...
                'Tag', 'question3text', ...
                'String', '3: What is the intra-tumoral stromal TIL density?');
                    
           handles.question3score = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [0.32,0.3,0.05,0.1], ...
                'Style', 'edit', ...
                'Enable','off',...
                'Tag', 'qquestion3score', ...
                'Callback', @question3score_Callback);

            % switch ROI
            handles.switchROI = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'ForegroundColor',  handles.myData.settings.FG_color, ...
                'BackgroundColor',  handles.myData.settings.BG_color, ...
                'Position',[0.85,0.85,0.15,0.15], ...
                'Style', 'pushbutton', ...
                'Tag', 'editvalue', ...
                'Enable','on',...
                'visible','on',...
                'String', 'Switch to WSI thumbnail',...
                'Callback',@switchROI_Callback);
            
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback',...
                'Refine_Register_Button_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
%             set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.question1text);
            delete(handles.question1panel);
            delete(handles.radiobutton1A);
            delete(handles.radiobutton1B);
            delete(handles.question2text);
            delete(handles.question2percent);
            delete(handles.question3text);
            delete(handles.question3score);
            delete(handles.switchROI);

            
            handles = rmfield(handles, 'question1text');
            handles = rmfield(handles, 'question1panel');
            handles = rmfield(handles, 'radiobutton1A');
            handles = rmfield(handles, 'radiobutton1B');
            handles = rmfield(handles, 'question2text');
            handles = rmfield(handles, 'question2percent');
            handles = rmfield(handles, 'question3text');
            handles = rmfield(handles, 'question3score');
            handles = rmfield(handles, 'switchROI');
            
            taskimage_archive(handles);
            
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
                    taskinfo.text, ',', ...
                    num2str(taskinfo.duration), ',', ...
                    taskinfo.question1result, ',', ...
                    taskinfo.question2result, ',', ...
                    taskinfo.question3result]);
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
                    taskinfo.text]);
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



function radiobutton1_Callback(hObj, eventdata)
try
    
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};

    taskinfo.button_desc = get(eventdata.NewValue, 'Tag');
    switch taskinfo.button_desc
        case 'radiobutton1A'
            taskinfo.question1result = 'Evaluable';
        case 'radiobutton1B'
            taskinfo.question1result = 'Not Evaluable';
    end

    % Enable next button
    if strcmp(taskinfo.question1result, 'Evaluable')
        set(handles.question2text,'Enable','on');
        set(handles.question2percent,'Enable','on');
        set(handles.question3text,'Enable','on');
        set(handles.question3score,'Enable','on');
        set(handles.NextButton,'Enable','off');
    else
        set(handles.NextButton,'Enable','on');
        set(handles.question2text,'Enable','off');
        set(handles.question2percent,'Enable','off');
        set(handles.question3text,'Enable','off');
        set(handles.question3score,'Enable','off');
        taskinfo.question2result = 'NA';
        taskinfo.question3result = 'NA';
        uicontrol(handles.NextButton);
    end
    

    % Pack the results
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);

catch ME
    error_show(ME)
end

end




function question2percent_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};

    percent = str2double(get(handles.question2percent, 'String'));

    if percent > 100
        percent = 100;
        set(handles.question2percent, 'String', '100');
    elseif percent < 0
        percent = 0;
        set(handles.question2percent, 'String', '0');
    end
    
    % Pack the results
    taskinfo.question2result = num2str(percent);
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
% 

end


function question3score_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    taskinfo = handles.myData.tasks_out{handles.myData.iter};

    score = str2double(get(handles.question3score, 'String'));

    if score > 100
        score = 100;
        set(handles.question3score, 'String', '100');
    elseif score < 0
        score = 0;
        set(handles.question3score, 'String', '0');
    end
    
    
    set(handles.NextButton,'Enable','on');
    uicontrol(handles.NextButton);
    
    % Pack the results
    taskinfo.question3result = num2str(score);
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);

end

function switchROI_Callback(hObj, eventdata) %#ok<DEFNU>
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    if taskinfo.showingROI == 0
        ROIname = [handles.myData.task_images_dir, taskinfo.id, '.tif'];
        taskinfo.ROIname = ROIname;
        taskinfo.showingROI = 1;
        set(handles.switchROI,'String','Switch to WSI thumbnail');
        myData.taskinfo = taskinfo;
        myData.tasks_out{myData.iter} = taskinfo;
        handles.myData = myData;
        guidata(hObj, handles);
        taskimage_load_halfscale(hObj);
    else
        wsi_info = myData.wsi_files{taskinfo.slot};
        WSIfile=wsi_info.fullname;
        slideIndex = strfind(WSIfile,'\');
        fileName = WSIfile((slideIndex(end)+1): end);
        dotIndex = strfind(fileName,'.');
        fileName = fileName(1: (dotIndex(end)-1));       
        ROIname = [handles.myData.task_images_dir, fileName, '_thumb.tif'];
        taskinfo.ROIname = ROIname;
        taskinfo.showingROI = 0;
        set(handles.switchROI,'String','Switch to ROI');
        
        if ~isfile(ROIname)        
            roi_w = max(wsi_info.wsi_w);
            roi_h = max(wsi_info.wsi_h);
            roi_x = floor(roi_w/2+1);
            roi_y = floor(roi_h/2+1);
            Left = 1;
            Top  = 1;
            mp = get(0, 'MonitorPositions');
            screensize= mp(find(mp(:,1)==1&mp(:,2)==1),:);
            if  roi_w/ roi_h>(screensize(4)*0.8)/screensize(3); 
                img_w = floor(screensize(4)*0.7)/2;
                img_h = 0;
            else
                img_w = 0;
                img_h = floor(screensize(3)*0.9)/2;
            end
            WSIfile=wsi_info.fullname;
            success = ExtractROI_BIO(wsi_info, WSIfile, ROIname,...
                        Left, Top, roi_w, roi_h,...
                        img_w, img_h,...
                        handles.myData.settings.RotateWSI,...
                        wsi_info.rgb_lut);                
        end
        myData.taskinfo = taskinfo;
        myData.tasks_out{myData.iter} = taskinfo;
        handles.myData = myData;
        guidata(hObj, handles);
        taskimage_load(hObj);
     end
     
     handles = guidata(hObj);

end

function task_globalAndBestReg(hObj)
%description
%collect global and best registration distance

%task input column
%globalAndBestReg,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H

%task output column
%globalAndBestReg,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H
%stage moving duration,auto registration duration, study duration,
%global registration distance,
%global registration stage x position,global registration stage y
%best registration distance,
%best registration stage x position,best registration stage y
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
            taskinfo.img_h =  taskinfo.roi_h;
            taskinfo.text  = 'Measure registration distance';
            taskinfo.rotateback = 0;
            taskinfo.done(1)=0;
            taskinfo.done(2)=0;
            taskinfo.stagePosition{1}='0,0';
            taskinfo.stagePosition{2}='0,0';
            if length(desc)>8
                myData.finshedTask = myData.finshedTask + 1;
            end
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            
            % Global registration text 
            handles.textGlobal = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.2, .4, .1, .2], ...
                'Style', 'text', ...
                'Tag', 'textGlobal', ...
                'String', 'Global');
            
            % Global registration
            handles.globalReg = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'center', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [.95, .95, .95], ...
                'Position', [.2, .3, .1, .2], ...
                'Style', 'edit', ...
                'Tag', 'globalReg', ...
                'Callback', @globalReg_Callback);

            % Best registration text 
            handles.textBest = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'normalized', ...
                'HorizontalAlignment', 'right', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [.7, .4, .1, .2], ...
                'Style', 'text', ...
                'Tag', 'textBest', ...
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
            
            % Make count task response box active
            uicontrol(handles.globalReg);
           
        case {'NextButtonPressed',...
                'PauseButtonPressed',...
                'Backbutton_Callback',...
                'Refine_Register_Button_Callback'} % Clean up the task elements
            
            % Hide image and management buttons
            
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            taskinfo = handles.myData.taskinfo;

            
            set(handles.iH,'visible','off');
            set(handles.ImageAxes,'visible','off');
            delete(handles.textGlobal);
            delete(handles.textBest);
            delete(handles.globalReg);
            delete(handles.bestReg);
            handles = rmfield(handles, 'textGlobal');
            handles = rmfield(handles, 'textBest');
            handles = rmfield(handles, 'globalReg');
            handles = rmfield(handles, 'bestReg');
     %   case 'abortbutton_Callback' % export undo task without results

            
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
                num2str(taskinfo.durationMove), ',', ...
                num2str(taskinfo.durationAutoReg), ',', ...
                num2str(taskinfo.duration), ',', ...
                taskinfo.regResult{1}, ',', ...
                taskinfo.stagePosition{1},',',...
                taskinfo.regResult{2}, ',', ...
                taskinfo.stagePosition{2}]);
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

function globalReg_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    myData=handles.myData;
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.done(1)=1;
    if  taskinfo.done(1)* taskinfo.done(2)==1
        set(handles.NextButton,'Enable','on');
    end
    taskinfo.regResult{1} = get(handles.globalReg, 'String');
    % get stage position
    stage = stage_get_pos(myData.stage,myData.stage.handle);
    x = stage.Pos(1);
    y = stage.Pos(2);
    taskinfo.stagePosition{1} = [int2str(x),',',int2str(y)];
    % Pack the results
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end

function bestReg_Callback(hObj, eventdata)
    handles = guidata(findobj('Tag','GUI'));
    myData=handles.myData;
    taskinfo = handles.myData.tasks_out{handles.myData.iter};
    taskinfo.done(2)=1;
    if  taskinfo.done(1)* taskinfo.done(2)==1
        set(handles.NextButton,'Enable','on');
    end
    taskinfo.regResult{2} = get(handles.bestReg, 'String');
    % get stage position
    stage = stage_get_pos(myData.stage,myData.stage.handle);
    x = stage.Pos(1);
    y = stage.Pos(2);
    taskinfo.stagePosition{2} = [int2str(x),',',int2str(y)];
    % Pack the results
    handles.myData.tasks_out{handles.myData.iter} = taskinfo;
    guidata(handles.GUI, handles);
    
end






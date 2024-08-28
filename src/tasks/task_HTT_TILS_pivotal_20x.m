% This function defines the data-collection task for pivotal HTT study

% collect "Evaluable/Not Evaluable" for sTILs in each ROI
% IF ROI is "Evaluable" collect % Tumor Associated Stroma & sTILs Density

% task input column
% HTT_TILS_Pivotal_20x,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,Qtext


% task output column
% HTT_TILS_Pivotal_20x,TaskID,TaskOrder,Slot,ROI_X,ROI_Y,ROI_W,ROI_H,Qtext,
% duration,status,percentstroma,score

function task_HTT_TILS_pivotal_20x(hObj)
    try

        % Initialize handles, myData, taskinfo, and calling_function
        handles = guidata(hObj);
        myData = handles.myData;
        taskinfo = myData.taskinfo;
        calling_function = handles.myData.taskinfo.calling_function;

        display([taskinfo.task, ' called from ', calling_function])

        % Manage the GUI based on the calling_function
        switch calling_function

            case 'Load_Input_File'

                % Initialize GUI, handles, taskinfo, desc
                taskinfo_default(hObj, taskinfo)
                handles = guidata(hObj);
                taskinfo = handles.myData.taskinfo;
                taskinfo.rotateback = 0;
                taskinfo.showingROI = 1;

                % Downsample the task image by 1/2
                taskinfo.scan_scale = handles.myData.wsi_files{taskinfo.slot}.scan_scale;
                taskinfo.roi2img = 1/2;
                taskinfo.img2roi = 1/taskinfo.roi2img;
                taskinfo.img_w = taskinfo.roi_w * taskinfo.roi2img;
                taskinfo.img_h = taskinfo.roi_h * taskinfo.roi2img;

                % Check if there is output data
                if length(taskinfo.desc)>9
                    myData.finshedTask = myData.finshedTask + 1;
                end

            case {'Update_GUI_Elements', ...
                    'ResumeButtonPressed'} % Initialize task elements

                % Create reticle mask for the scanned image
                % for i=1:n_wsi
                %     pixel_size = wsi_files{i}.scan_scale * settings.mag_hres;
                %     settings.scan_mask{i} = ...
                %         reticle_make_mask(settings.reticleID, pixel_size, [0,0]);
                % end

                % i = handles.myData.taskinfo.slot;
                % pixel_size = ...
                %     handles.myData.wsi_files{i}.scan_scale * ...
                %     handles.myData.settings.mag_hres * ...
                %     handles.myData.taskinfo.img2roi;
                % handles.myData.settings.scan_mask{i} = reticle_make_mask(...
                %     handles.myData.settings.reticleID, pixel_size, [0,0]);



                % Load the image
                ROIname = [handles.myData.task_images_dir, taskinfo.id, '.tif'];
                taskinfo.ROIname = ROIname;
                taskinfo.showingROI = 1;
                handles.myData.taskinfo = taskinfo;

                
                
                guidata(hObj, handles);
                taskimage_load(hObj);
                handles = guidata(hObj);

                % Show management buttons
                taskmgt_default(handles, 'on');
                handles = guidata(hObj);

                % Initialize UI objects for question 1, visible
                initializeQ1(hObj)

                % Initialize UI objects for question 2, not visible
                initializeQ2(hObj)

                % Initialize UI objects for question 3, not visible
                initializeQ3(hObj)

                % switch ROI
                handles.switchROI = uicontrol(...
                    'Parent', handles.task_panel, ...
                    'FontSize', handles.myData.settings.FontSize, ...
                    'Units', 'normalized', ...
                    'ForegroundColor',  handles.myData.settings.FG_color, ...
                    'BackgroundColor',  handles.myData.settings.BG_color, ...
                    'Position',[0.85,0.85,0.15,0.15], ...
                    'Style', 'pushbutton', ...
                    'Tag', 'switchROI', ...
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
                set(handles.iH,'visible','off');
                set(handles.ImageAxes,'visible','off');

                % Find and close all uicontrols created above
                %     Tags 'Q1', 'Q2', 'Q3', 'switchROI'
                objectsToRemove = [
                    findobj(handles.task_panel, 'Tag', 'Q1');
                    findobj(handles.task_panel, 'Tag', 'Q2');
                    findobj(handles.task_panel, 'Tag', 'Q3');
                    findobj(handles.task_panel, 'Tag', 'switchROI');
                    ];

                closeObjects(hObj, objectsToRemove)

                taskimage_archive(handles);

            case 'exportOutput' % export current task information and reuslt

                if taskinfo.currentWorking == 1

                    % If 1, write task output
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
                        num2str(taskinfo.question1result), ',', ...
                        taskinfo.question2result, ',', ...
                        taskinfo.question3result]);

                elseif taskinfo.currentWorking == 0

                    % If 0, write incomplete task
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

                else

                    % write tasks completed from previous session
                    desc = taskinfo.desc;
                    for i = 1 : length(desc)-1
                        fprintf(myData.fid,[desc{i},',']);
                    end
                    fprintf(myData.fid,[desc{length(desc)}]);
                end

                % End the file with a carraige return and newline
                fprintf(myData.fid,'\r\n');

                % Pack up the data
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

function initializeQ1(hObj)

    % Initialize handles
    handles = guidata(hObj);

    % Initialize text for Q1
    handles.question1text = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', [0.1,0.75,0.1,0.1], ...
        'Style', 'text', ...
        'Tag', 'Q1', ...
        'String', 'ROI Type:');

    % Initialize tissue type button group
    handles.question1panel = uibuttongroup( ...
        'Parent',handles.task_panel,...
        'Position',[0.2,0.75,0.4,0.1],...
        'SelectionChangedFcn',@radiobutton1_Callback, ...
        'Tag', 'Q1');

    % Intialize radio button 1, Evaluable
    handles.radiobutton1A = uicontrol(...
        'Parent', handles.question1panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', [0,0,0.5,1], ...
        'Style', 'radiobutton', ...
        'Tag', 'Q1', ...
        'String', 'Evaluable for sTILs');

    % Intialize radio button 2, Not Evaluable
    handles.radiobutton1B = uicontrol(...
        'Parent', handles.question1panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', [0.5,0,0.5,1], ...
        'Style', 'radiobutton', ...
        'Tag', 'Q1', ...
        'String', 'Not Evaluable for sTILs');

    % Deselect all radio buttons
    set(handles.question1panel, 'SelectedObject', []);

end

function initializeQ2(hObj)

    % Initialize handles
    handles = guidata(hObj);

    % Initialize the slider position, size, and init value
    initvalue = -1;
    slider_x = .1;
    slider_y = .4;
    slider_w = .55;
    slider_h = .1;
    position = [slider_x, slider_y, slider_w, slider_h];

    % Initialize slider not visible
    handles.sliderStroma = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', [.95, .95, .95], ...
        'Position', position, ...
        'Style', 'slider', ...
        'Tag','textQ2', ...
        'String', 'slider_string', ...
        'Min', -1, ...
        'Max', 100, ...
        'SliderStep', [1.0/101.0, 10.0/101.0], ...
        'Value', initvalue, ...
        'Visible','off', ...
        'Tag','Q2', ...
        'Callback', @sliderStroma_Callback);

    % Initialize input box for number that is "linked" to slider
    position = [slider_x+slider_w+.05, slider_y, .1, slider_h];
    handles.editStroma = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', [.95, .95, .95], ...
        'Position', position, ...
        'Style', 'edit', ...
        'Visible','off',...
        'Tag','Q2', ...
        'String', num2str(initvalue), ...
        'Callback', @editStroma_Callback);




    % Initialize text for Q2
    handles.textQ2 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', [.1, .6, .8, .1], ...
        'Style', 'text', ...
        'Visible','off',...
        'Tag', 'Q2', ...
        'String', 'What is % Tumor-Associated Stroma?');

    % Initialize text label at 0
    position = [slider_x, slider_y+slider_h, .1, .1];
    handles.textStroma000 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q2', ...
        'String', '0');

    % Initialize text label at 50
    position = [slider_x+slider_w/2-.05, slider_y+slider_h, .1, .1];
    handles.textStroma050 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q2', ...
        'String', '50');

    % Initialize text label at 100
    position = [slider_x+slider_w-.1, slider_y+slider_h, .1, .1];
    handles.textStroma100 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q2', ...
        'String', '100');

    % Initialize text for numeric input box
    position = [slider_x+slider_w+.05, slider_y+slider_h, .1, .1];
    handles.textEditStroma = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q2', ...
        'String', '%');

    % Save handles
    guidata(hObj, handles);

end

function initializeQ3(hObj)

    % Initialize handles
    handles = guidata(hObj);

    % Initialize text for Q3
    handles.textQ3 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'left', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', [.1, .25, .8, .1], ...
        'Style', 'text', ...
        'Visible','off',...
        'Tag','Q3', ...
        'String', 'What is % Tumor-Associated Stroma?');

    % Initialize the slider position, size, and init value
    initvalue = -1;
    slider_x = .1;
    slider_y = .05;
    slider_w = .55;
    slider_h = .1;
    position = [slider_x, slider_y, slider_w, slider_h];

    % Initialize slider not Visible
    handles.sliderTILs = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', [.95, .95, .95], ...
        'Position', position, ...
        'Style', 'slider', ...
        'Tag', 'Q3', ...
        'String', 'slider_string', ...
        'Min', -1, ...
        'Max', 100, ...
        'SliderStep', [1.0/101.0, 10.0/101.0], ...
        'Value', initvalue, ...
        'Visible','off',...
        'Callback', @sliderTILs_Callback);

    % Initialize text label at 0
    position = [slider_x, slider_y+slider_h, .1, .1];
    handles.textTILs0000 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q3', ...
        'String', '0');

    % Initialize text label at 50
    position = [slider_x+slider_w/2-.05, slider_y+slider_h, .1, .1];
    handles.textTILs050 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q3', ...
        'String', '50');

    % Initialize text label at 100
    position = [slider_x+slider_w-.1, slider_y+slider_h, .1, .1];
    handles.textTILs100 = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off',...
        'Tag','Q3', ...
        'String', '100');

    % Initialize input box for number that is "linked" to slider
    position = [slider_x+slider_w+.05, slider_y, .1, slider_h];
    handles.editTILs = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', [.95, .95, .95], ...
        'Position', position, ...
        'Style', 'edit', ...
        'Value', initvalue, ...
        'Visible','off', ...
        'Tag', 'Q3', ...
        'String', num2str(initvalue), ...
        'Callback', @editTILs_Callback);

    % Initialize text for numeric input box
    position = [slider_x+slider_w+.05, slider_y+slider_h, .1, .1];
    handles.textEditTILs = uicontrol(...
        'Parent', handles.task_panel, ...
        'FontSize', handles.myData.settings.FontSize, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'center', ...
        'ForegroundColor', handles.myData.settings.FG_color, ...
        'BackgroundColor', handles.myData.settings.BG_color, ...
        'Position', position, ...
        'Style', 'text', ...
        'Visible','off', ...
        'Tag','Q3', ...
        'String', '%');

    % Save handles
    guidata(hObj, handles);

end

function closeObjects(hObj, objectsToRemove)

    % Initialize handles
    handles = guidata(hObj);

    % Initialize a list to store field names to remove
    fieldsToRemove = {};

    % Iterate over the fields of the handles structure
    fieldNames = fieldnames(handles);
    for i = 1:length(fieldNames)
        field = fieldNames{i};

        % Skip the field if it is not a UI control
        if(~isa(handles.(field), 'matlab.ui.control.UIControl'))
            continue
        end

        % Check if the field's value is in the list of objects to remove
        if ismember(handles.(field), objectsToRemove)
            % Add field name to the list
            fieldsToRemove{end+1} = field;
        end
    end

    % Remove the fields from handles
    for i = 1:length(fieldsToRemove)
        handles = rmfield(handles, fieldsToRemove{i});
    end

    % Delete Q1 objects from GUI and from handles
    for i = 1:length(objectsToRemove)
        delete(objectsToRemove(i));
    end

    % Save handles
    guidata(hObj, handles);

end

function radiobutton1_Callback(hObj, eventdata)
    try

        % Initialize handles
        handles = guidata(hObj);

        % Find and close all Q2 and Q3 objects
        objectsToRemove =[
            findobj(handles.task_panel, 'Tag', 'Q2');
            findobj(handles.task_panel, 'Tag', 'Q3');
            ];
        closeObjects(hObj, objectsToRemove)

        % Initialize Q2 and Q3 objects
        initializeQ2(hObj)
        initializeQ3(hObj)

        % Initialize handles and taskinfo
        % handles = guidata(findobj('Tag','GUI'));
        handles = guidata(hObj);
        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        % Disable Next button
        set(handles.NextButton, 'Enable', 'off')

        % Get the result for the selected button
        % 'Evaluable for sTILs' or 'Not Evaluable for sTILs'
        taskinfo.question1result = get(eventdata.NewValue, 'String');

        % Change the ui based on the selected button
        if strcmp(taskinfo.question1result, 'Evaluable for sTILs')

            % If Evaluable, make Q2 objects visible
            tagQ2 = findobj(handles.task_panel, 'Tag', 'Q2');
            for i = 1:length(tagQ2); tagQ2(i).Visible = 'on'; end

            % Give  focus to the stroma edit box
            uicontrol(handles.editStroma);

        else

            % Set output for Q1
            taskinfo.question2result = 'NA';
            taskinfo.question3result = 'NA';

            % Not Evaluable, enable next button
            set(handles.NextButton,'Enable','on');

            % Give  focus to the next button
            uicontrol(handles.NextButton);

        end

        % Pack the results
        handles.myData.tasks_out{handles.myData.iter} = taskinfo;
        guidata(handles.GUI, handles);

    catch ME
        error_show(ME)
    end

end

function sliderStroma_Callback(hObj, ~)
    try

        % Initialize handles and taskinfo
        handles = guidata(hObj);
        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        % Get the slider value
        score = round(get(handles.sliderStroma, 'Value'));

        % Set the score value in the stroma text input box
        set(handles.editStroma, 'String', num2str(score));

        % Pack the results
        handles.myData.tasks_out{handles.myData.iter} = taskinfo;
        guidata(hObj, handles);

        editStroma_Callback(hObj)

    catch ME
        error_show(ME)
    end

end

function editStroma_Callback(hObj, ~)
    try

        % Initialize handles and taskinfo
        handles = guidata(findobj('Tag','GUI'));
        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        % Get the score from the stroma text input box
        score = str2double(get(handles.editStroma, 'String'));

        % Manage special cases
        if isnan(score)

            % If stroma text box is not a number, clear it
            set(handles.editStroma, 'String', '-1');
            score = -1;

        elseif score < -1

            % If stroma text box is a number less than -1, set to -1
            score = -1;
            set(handles.editStroma, 'String', '-1');

        elseif score > 100

            % If stroma greater than 100, set to 100
            score = 100;
            set(handles.editStroma, 'String', '100');

        end

        % Set the slider to the score
        set(handles.sliderStroma, 'Value', score);

        % If stroma == -1, reset Q3 objects.
        % Otherwise, save data and make Q3 objects visible
        if score == -1

            % Disable Next button
            set(handles.NextButton, 'Enable', 'off')

            % Pack the results
            handles.myData.tasks_out{handles.myData.iter} = taskinfo;
            guidata(handles.GUI, handles);

            % Find and close all Q3 objects
            objectsToRemove = findobj(handles.task_panel, 'Tag', 'Q3');
            closeObjects(hObj, objectsToRemove)

            % Initialize Q3 objects
            initializeQ3(hObj)

            % Give  focus to the stroma edit box
            uicontrol(handles.editStroma);

        else

            % Set the output for Q2, converting number to a string
            taskinfo.question2result = num2str(score);

            % Make Q3 objects visible
            tagQ3 = findobj(handles.task_panel, 'Tag', 'Q3');
            for i = 1:length(tagQ3); tagQ3(i).Visible = 'on'; end

            % Pack the results
            handles.myData.tasks_out{handles.myData.iter} = taskinfo;
            guidata(hObj, handles);

            % Give  focus to the TILs edit box
            uicontrol(handles.editTILs);

        end


    catch ME
        error_show(ME)
    end

end

function sliderTILs_Callback(hObj, ~)
    try

        % Initialize handles and taskinfo
        handles = guidata(hObj);
        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        % Get the slider value
        score = round(get(handles.sliderTILs, 'Value'));

        % Set the score value in the TILs text input box
        set(handles.editTILs, 'String', num2str(score));

        % Pack the results
        handles.myData.tasks_out{handles.myData.iter} = taskinfo;
        guidata(hObj, handles);

        editTILs_Callback(hObj)

    catch ME
        error_show(ME)
    end

end

function editTILs_Callback(hObj, ~)
    try

        % Initialize handles and taskinfo
        handles = guidata(findobj('Tag','GUI'));
        taskinfo = handles.myData.tasks_out{handles.myData.iter};

        % Get the score from the stroma text input box
        score = str2double(get(handles.editTILs, 'String'));

        % Manage special cases
        if isnan(score)

            % If stroma text box is not a number, clear it
            set(handles.editTILs, 'String', '-1');
            score = -1;

        elseif score < -1

            % If TILs less than -1, set to -1
            score = -1;
            set(handles.editTILs, 'String', '-1');

        elseif score > 100

            % If TILs greater than 100, set to 100
            score = 100;
            set(handles.editTILs, 'String', '100');

        end

        % Set the slider to the score
        set(handles.sliderTILs, 'Value', score);

        % If TILs == -1 disable the Next button
        % Otherwise, save data and enable Next button
        if score == -1

            % Disable Next button
            set(handles.NextButton, 'Enable', 'off')

        else

            % Set the output for Q2, converting number to a string
            taskinfo.question3result = num2str(score);

            % Not Evaluable, enable next button
            set(handles.NextButton,'Enable','on');

            % Enable and give focus to the Next button
            set(handles.NextButton, 'Enable', 'on')
            uicontrol(handles.NextButton);

        end

        % Pack the results
        handles.myData.tasks_out{handles.myData.iter} = taskinfo;
        guidata(hObj, handles);

    catch ME
        error_show(ME)
    end

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
        taskimage_load(hObj);
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

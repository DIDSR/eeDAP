function task_start(hObj)
%description
%start study
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
            
           
            handles = guidata(findobj('Tag','GUI'));
            set(handles.NextButton, 'Visible', 'off');

            delete(handles.edit_readerID);
            delete(handles.text_readerID);
            handles = rmfield(handles, 'edit_readerID');
            handles = rmfield(handles, 'text_readerID');
            
         case 'exportOutput' % export current task information and reuslt
              Save_Results(handles);
              handles = guidata(findobj('Tag','GUI'));
              myData.fid = handles.myData.fid;
              myData.iter = handles.myData.iter;
         case 'Save_Results' % Save the results for this task
             fprintf(myData.fid, [...
                    taskinfo.id, ',', ...
                    handles.myData.mode_desc,',', ...
                    myData.readerID]);
             fprintf(myData.fid,'\r\n');
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
                case 'TrackingView'
                    outputfile = ['trackView.',...
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
% start generate output file: 
% 1. free command
% 2. setting
% 3. finished task
function Save_Results(handles)
try
    
    % SAVE THE DATA
    % The filename of the newly created file will be the name of the
    % pathologist. Gaps in the string are replaced by the
    % '_' symbol.
    
    myData = handles.myData;
    wsi_files = myData.wsi_files;
    %tasks_out = myData.tasks_out;
    settings = myData.settings;
    n_wsi = settings.n_wsi;
    
    outputfile=myData.outputfile;
    full_outputfile = [myData.workdir,'Output_Files\',outputfile];
    
    % The path to the file is composed from the filename and the current
    % application path. File at this path is then opened.
    fid = fopen(full_outputfile,'w+');
    
    % The header part of the input file is written into the output file
    % first
    fprintf(fid,'Comments from the input file:\r\n');
    for i=1:1:size(myData.InputFileHeader)
        fprintf(fid,myData.InputFileHeader{i,:});
    end
    
    %The settings obtained from the input file are again written into the
    %the output file.
    fprintf(fid,'SETTINGS\r\n');
    
    desc = ['NUMBER_OF_WSI=', num2str(n_wsi)];
    fprintf(fid, '%s \r\n',desc);
    
    % Read in the file names of the WSI corresponding to the slots
    for i=1:n_wsi
        desc = ['wsi_slot_',num2str(i,'%d'),'=', ...
            wsi_files{i}.fullname];
        fprintf(fid,'%s \r\n',desc);
        desc = ['rgb_lut_slot_',num2str(i,'%d'),'=', ...
            wsi_files{i}.rgb_lutfilename];
        fprintf(fid,'%s \r\n',desc);
         desc = ['scan_scale_',num2str(i,'%d'),'=', ...
            num2str( wsi_files{i}.scan_scale)];
        fprintf(fid,'%s \r\n',desc);
    end
    
    fprintf(fid,strcat('label_pos','=',num2str(settings.label_pos),'\r\n'));
    fprintf(fid,strcat('reticleID','=',num2str(settings.reticleID),'\r\n'));
    fprintf(fid,strcat('cam_kind','=',num2str(settings.cam_kind),'\r\n'));
    fprintf(fid,strcat('cam_format','=',settings.cam_format,'\r\n'));
    fprintf(fid,strcat('cam_pixel_size','=',num2str(settings.cam_pixel_size),'\r\n'));
    fprintf(fid,strcat('mag_cam','=',num2str(settings.mag_cam),'\r\n'));
    fprintf(fid,strcat('mag_lres','=',num2str(settings.mag_lres),'\r\n'));
    fprintf(fid,strcat('mag_hres','=',num2str(settings.mag_hres),'\r\n'));

    fprintf(fid,strcat('stage_label','=',num2str(myData.stage.label),'\r\n'));
    desc = ['BG_Color_RGB=',...
        num2str(myData.settings.BG_color(1)),'=',...
        num2str(myData.settings.BG_color(2)),'=',...
        num2str(myData.settings.BG_color(3)),...
        '\r\n'];
    fprintf(fid,desc);
    desc = ['FG_Color_RGB=',...
        num2str(myData.settings.FG_color(1)),'=',...
        num2str(myData.settings.FG_color(2)),'=',...
        num2str(myData.settings.FG_color(3)),...
        '\r\n'];
    fprintf(fid,desc);
    desc = ['AxesBG_Color_RGB=',...
        num2str(myData.settings.Axes_BG(1)),'=',...
        num2str(myData.settings.Axes_BG(2)),'=',...
        num2str(myData.settings.Axes_BG(3)),...
        '\r\n'];
    fprintf(fid,desc);
    fprintf(fid,strcat('FontSize','=',num2str(myData.settings.FontSize),'\r\n'));
    fprintf(fid,strcat('autoreg','=',num2str(myData.settings.autoreg),'\r\n'));
    fprintf(fid,strcat('saveimages','=',num2str(myData.settings.saveimages),'\r\n'));
    fprintf(fid,strcat('taskorder','=',num2str(myData.settings.taskorder),'\r\n'));
    fprintf(fid,'\r\n');
    
    fprintf(fid,'BODY\r\n');
    
    % The arrays containing information about the evaluation task and the
    % answers of the evaluator are saved into the file that was opened.

    st = dbstack;
    calling_function = st(1).name;

    % Write the 'start' task output according to taskinfo.task_handle
    taskinfo = myData.task_start;
    
    taskinfo.calling_function = calling_function;
    handles.myData.taskinfo = taskinfo;
    handles.myData.fid = fid;
    guidata(handles.GUI, handles);
    taskinfo.task_handle(handles.GUI);
    
    % Write the 'finish' task output according to taskinfo.task_handle
    taskinfo = myData.task_finish;
    taskinfo.calling_function = calling_function;
    handles.myData.taskinfo = taskinfo;
    guidata(handles.GUI, handles);
    taskinfo.task_handle(handles.GUI);
    myData.iter = myData.iter+1;
    
    % Write finished tasks
    while myData.iter <= myData.finshedTask+1
        taskinfo = myData.tasks_out{myData.iter};
       % handles.myData.tasks_out{handles.myData.iter} = taskinfo;
        taskinfo.calling_function = st(1).name;
        handles.myData.taskinfo = taskinfo;
        guidata(handles.GUI, handles);
        taskinfo.task_handle(handles.GUI);
        handles = guidata(handles.GUI);
        myData.iter = myData.iter +1;
    end
    myData.iter = myData.iter -1;
    handles.myData.iter = myData.iter;
    guidata(handles.GUI, handles);
catch ME
    error_show(ME)
end
end
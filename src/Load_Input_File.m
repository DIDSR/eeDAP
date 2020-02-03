%  ##########################################################################
%% ######################### LOAD INPUT FILE ################################
%  ##########################################################################
function succeed = Load_Input_File(handles)
try
    %--------------------------------------------------------------------------
    % Load_Input_File ensures that the input file defining the set of
    % evaluation tasks for the current session is loaded into the myData
    % structure
    % Most input variables are saved in a structure called settings
    % The information related to wsi files are stored in a cell array of
    % structures called wsi_files
    % Both "settings" and "wsi_files" are stored in myData
    %--------------------------------------------------------------------------
    succeed = 0;
    myData = handles.myData;
    if (~isdeployed)
        addpath('bfmatlab');
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    settings = struct;
    
    % The file at the path Path_to_Question_File is opened
    fid = fopen(myData.workdir_inputfile);
    
    %----------------------------------------------------------------------
    % Read in the header information. Stop at 'SETTINGS'
    % myData.InputFileHeader is a matrix where every cell is a
    % string that contains one line of the header.
    %----------------------------------------------------------------------
    tline = fgets(fid);
    found=strfind(tline,'SETTINGS');
    i=0;
    while (~feof(fid)) && isempty(found)
        i=i+1;
        myData.InputFileHeader{i,:}=tline;
        tline = fgets(fid);
        [found]=strfind(tline,'SETTINGS');
    end
    
    %----------------------------------------------------------------------
    % Read in the settings information.
    % The number of slots being used and the corresponding filenames will
    % be saved in myData.
    %----------------------------------------------------------------------
    tline = fgets(fid);
    % Read in the number of slots defined
    field = textscan(tline,'%s %d','delimiter','=');
    name = 'NUMBER_OF_WSI';
    if strcmp(strtrim(char(field{1})),name)==1
        n_wsi = field{2};
        settings.n_wsi = n_wsi;
    else
        io_error(name);
        return;
    end
    
    % Read in the file names of the WSI and the RGB look up table
    % corresponding to each WSI image
    wsi_files = cell(n_wsi,1);
    for i=1:n_wsi

        % Read in the file name of the WSI
        tline = fgets(fid);
        field = textscan(tline,'%s %s','delimiter','=');
        name = ['wsi_slot_',num2str(i,'%d')];
        if strcmp(strtrim(char(field{1})),name)==1
            % Check to see if filename is relative or absolute
            % If not absolute, make it absolute
            temp_absolute = char(field{2});
            temp_relative = char([myData.workdir, field{2}]);

                if ~isempty(dir( temp_absolute ))
                    wsi_fullname = char(cellstr(temp_absolute));
                    
                elseif ~isempty(dir( temp_relative ))
                    wsi_fullname = char(cellstr(temp_relative));
                    
                else
                    desc = sprintf('WSI does not exist. \nFilename = %s\nSlot Number = %d\n\nYou need to load a new input file.', temp_absolute, i);
                    h_errordlg = errordlg(desc,'Application error','modal');
                    return;
                end
           
            
        else
            name = [name ': does not match expected label: ' strtrim(char(field{1}))];
            io_error(name);
            return;
        end
        
        % Get WSI information
        WSI_data = bfGetReader(wsi_fullname);
        % get size of each resolution, Ignore the last two because there
        % are image with label
        WSI_data.setSeries(0);
        wsi_w(1)= WSI_data.getSizeX();
        wsi_h(1)= WSI_data.getSizeY();
        numberOfImages = WSI_data.getSeriesCount();
        for j = 1 : numberOfImages - 3
            WSI_data.setSeries(j);
            wsi_w(j+1)= WSI_data.getSizeX();
            wsi_h(j+1)= WSI_data.getSizeY();
        end
        wsi_files{i}.WSI_data = WSI_data;
        wsi_files{i}.fullname=wsi_fullname;
        wsi_files{i}.wsi_w = wsi_w;
        wsi_files{i}.wsi_h = wsi_h;
        
        % Read in the file name of the RGB look up table
        tline = fgets(fid);
        field = textscan(tline,'%s %s','delimiter','=');
        name = ['rgb_lut_slot_',num2str(i,'%d')];
        if strcmp(strtrim(char(field{1})),name)==1
            % Check to see if filename is relative or absolute
            % If not absolute, make it absolute
            temp_absolute = char(field{2});
            temp_relative = char([myData.workdir, field{2}]);
            
            if ~isempty(dir( temp_absolute ))
                rgb_lut_filename = char(cellstr(temp_absolute));
            elseif ~isempty(dir( temp_relative ))
                rgb_lut_filename = char(cellstr(temp_relative));
            else
                name = ['WSI does not exist. Filename = ',temp_absolute];
                io_error(name);
                return;
            end
            
            fid2 = fopen(rgb_lut_filename);
            rgb_lut = uint8(zeros(256,3));
            for channel=1:3
                for level=1:256
                    tline2 = fgets(fid2);
                    rgb_lut(level,channel) = uint8(str2double(tline2));
                end
            end
            wsi_files{i}.rgb_lutfilename = rgb_lut_filename;
            wsi_files{i}.rgb_lut = rgb_lut;
            
            fclose(fid2);
            
        else
            io_error(name);
            return;
        end
        
        
        % Read in image scan scale
        tline = fgets(fid);
        field = textscan(tline,'%s %s','delimiter','=');
        name = ['scan_scale_',num2str(i,'%d')];
        if strcmp(strtrim(char(field{1})),name)==1
            % Check to see if filename is relative or absolute
            % If not absolute, make it absolute
            [setting_name, setting_value]=strread(tline, '%s %f', 'delimiter', '=');
            wsi_files{i}.scan_scale = setting_value;            
        else
            io_error(name);
        end
        
        
    end
    myData.wsi_files = wsi_files;
    handles.myData=myData;
    guidata(handles.Administrator_Input_Screen,handles);
    tline = fgets(fid);
    % The Reticle ID is recorded into settings structure
    [setting_name, setting_value]=strread(tline, '%s %s', 'delimiter', '='); %#ok<*REMFF1,*FPARK>
    name = 'label_pos';
    if strcmp(strtrim(setting_name),name)==1
        settings.label_pos=char(setting_value);
    else
        io_error(name);
        return;
    end
     % label_pos on glass slide relative to the microscope operator
    % in units of the clock (0,3,6,9,12)
    % The typical microscope image in the eyepiece is rotated by 6 hours
    % relative to the position on the stage.
    % The typical label position of a WSI is at 9 o'clock
    label_pos=str2num(settings.label_pos);
    label_pos = mod(label_pos, 12);
    % RotateWSI maps the rotation to the code expected by TIFFcomp
    switch label_pos
        case 0  % Label position of microscope image in eyepiece is 6:00
            settings.RotateWSI = 1*90;  % Rotate WSI CW 9 hours;  9:00 wsi->6:00 in eyepiece = 12:00 on stage
        case 3  % Label position of microscope image in eyepiece is 9:00
            settings.RotateWSI = 0*90;  % No WSI rotation needed; 9:00 wsi->9:00 in eyepiece = 3:00 on stage
        case 6  % Label position of microscope image in eyepiece is 12:00
            settings.RotateWSI = 3*90;  % Rotate WSI CW 3 hours;  9:00 wsi->12:00 in eyepiece = 6:00 on stage
        case 9  % Label position of microscope image in eyepiece is 3:00
            settings.RotateWSI = 2*90;  % Rotate wsi CW 6 hours;  9:00 wsi->3:00 in eyepiece = 9:00 on stage
    end
    tline = fgets(fid);
    % The Reticle ID is recorded into settings structure
    [setting_name, setting_value]=strread(tline, '%s %s', 'delimiter', '='); %#ok<*REMFF1,*FPARK>
    name = 'reticleID';
    if strcmp(strtrim(setting_name),name)==1
        settings.reticleID=char(setting_value);
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %s', 'delimiter', '=');
    name = 'cam_kind';
    if strcmp(strtrim(setting_name),name)==1
        settings.cam_kind=char(setting_value);
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %s', 'delimiter', '=');
    name = 'cam_format';
    if strcmp(strtrim(setting_name),name)==1
        settings.cam_format=char(setting_value);
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %f', 'delimiter', '=');
    name = 'cam_pixel_size';
    if strcmp(strtrim(setting_name),name)==1
        settings.cam_pixel_size=setting_value;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %f', 'delimiter', '=');
    name = 'mag_cam';
    if strcmp(strtrim(setting_name),name)==1
        settings.mag_cam=setting_value;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %f', 'delimiter', '=');
    name = 'mag_lres';
    if strcmp(strtrim(setting_name),name)==1
        settings.mag_lres=setting_value;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %f', 'delimiter', '=');
    name = 'mag_hres';
    if strcmp(strtrim(setting_name),name)==1
        settings.mag_hres=setting_value;
    else
        io_error(name);
        return;
    end
%     tline = fgets(fid);
%     [setting_name, setting_value]=strread(tline, '%s %f', 'delimiter', '=');
%     name = 'scan_scale';
%     if strcmp(strtrim(setting_name),name)==1
%         settings.scan_scale=setting_value;
%     else
%         io_error(name);
%         return;
%     end

    
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %s', 'delimiter', '=');
    name = 'stage_label';
    if strcmp(strtrim(setting_name),name)==1
        myData.stage.label=char(setting_value);
    else
        io_error(name); 
        return;
    end
    
    % Create reticle mask for the scanned image
    for i=1:n_wsi
        pixel_size = wsi_files{i}.scan_scale * settings.mag_hres;
        settings.scan_mask{i} = ...
            reticle_make_mask(settings.reticleID, pixel_size, [0,0]);
    end
    
    tline = fgets(fid);
    [setting_name, tempR, tempG, tempB] =...
        strread(tline, '%s %f %f %f', 'delimiter', '=');
    name = 'BG_Color_RGB';
    if strcmp(strtrim(setting_name),name)==1
        settings.BG_color(1)=tempR;
        settings.BG_color(2)=tempG;
        settings.BG_color(3)=tempB;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, tempR, tempG, tempB] =...
        strread(tline, '%s %f %f %f', 'delimiter', '=');
    name = 'FG_Color_RGB';
    if strcmp(strtrim(setting_name),name)==1
        settings.FG_color(1)=tempR;
        settings.FG_color(2)=tempG;
        settings.FG_color(3)=tempB;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, tempR, tempG, tempB] =...
        strread(tline, '%s %f %f %f', 'delimiter', '=');
    name = 'AxesBG_Color_RGB';
    if strcmp(strtrim(setting_name),name)==1
        settings.Axes_BG(1)=tempR;
        settings.Axes_BG(2)=tempG;
        settings.Axes_BG(3)=tempB;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %d', 'delimiter', '=');
    name = 'FontSize';
    if strcmp(strtrim(setting_name),name)==1
        settings.FontSize=setting_value;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %d', 'delimiter', '=');
    name = 'autoreg';
    if strcmp(strtrim(setting_name),name)==1
        settings.autoreg=setting_value;
    else
        io_error(name);
        return;
    end
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %d', 'delimiter', '=');
    name = 'saveimages';
    if strcmp(strtrim(setting_name),name)==1
        settings.saveimages=setting_value;
    else
        io_error(name);
        return;
    end    
    tline = fgets(fid);
    [setting_name, setting_value]=strread(tline, '%s %d', 'delimiter', '=');
    name = 'taskorder';
    if strcmp(strtrim(setting_name),name)==1
        settings.taskorder=setting_value;
    else
        io_error(name);
        return;
    end
    
    while (~feof(fid)) && isempty(strfind(fgets(fid),'BODY'))
    end
    
    
    %----------------------------------------------------------------------
    % Each row in the BODY of the input file defines an ROI and a task
    % The first row defines the "start" task
    % The second row defines the "finish" task
    % The remaining rows are the individual tasks themselves
    % All tasks are stored in cell array and sorted according to taskorder
    % The start task goes at the beginning
    % The finish task goes at the end
    %----------------------------------------------------------------------
    st = dbstack;
    calling_function = st(1).name;

    % Read and store the task_start description
    tline = fgets(fid);
    temp = textscan(tline, '%s', 'delimiter', ',');
    temp = temp{1};
    taskinfo = struct;
    taskinfo.desc = temp;
    % Read the task_type and create the task_handle
    % The task_handle points to the task_type.m file
    taskinfo.task = char(temp{1});
    taskinfo.task_handle = str2func(['@task_',taskinfo.task]);
    % Call the task_type function. Here we read in the taskinfo.
    taskinfo.calling_function = calling_function;
    handles.myData.taskinfo = taskinfo;
    handles.myData.taskinfo.duration = 0;
    guidata(handles.Administrator_Input_Screen, handles);
    taskinfo.task_handle(handles.Administrator_Input_Screen);
    % Update the handles and task_start structure
    handles = guidata(handles.Administrator_Input_Screen);
    task_start = handles.myData.taskinfo;
    
    % Read and store the task_finish description
    tline = fgets(fid);
    temp = textscan(tline, '%s', 'delimiter', ',');
    temp = temp{1};
    taskinfo = struct;
    taskinfo.desc = temp;
    % Read the task_type and create the task_handle
    % The task_handle points to the task_type.m file
    taskinfo.task = char(temp{1});
    taskinfo.task_handle = str2func(['@task_',taskinfo.task]);
    % Call the task_type function. Here we read in the taskinfo.
    taskinfo.calling_function = calling_function;
    handles.myData.taskinfo = taskinfo;
    handles.myData.taskinfo.duration = 0;
    handles.myData.settings = settings;
    guidata(handles.Administrator_Input_Screen, handles);
    taskinfo.task_handle(handles.Administrator_Input_Screen);
    % Update the handles and task_finish structure
    handles = guidata(handles.Administrator_Input_Screen);
    task_finish = handles.myData.taskinfo;

    % tasks_in structure will hold all the input tasks
    tasks_in = [];
    ntasks = 0;
    % new variable to track how many task has been done.
    handles.myData.finshedTask = 0;
    while ~feof(fid)
        
        % Read and store the taskinfo
        tline = fgets(fid);
        temp = textscan(tline, '%s', 'delimiter', ',');
        if isempty(temp{1})
            break
        else
            ntasks=ntasks+1;
        end
        temp = temp{1};
        taskinfo = struct;
        taskinfo.desc = temp;
        % Read the task_type and create the task_handle
        taskinfo.task = char(temp{1});
        taskinfo.task_handle = str2func(['@task_',taskinfo.task]);
        % Call the task_type function. Here we read in the taskinfo.
        taskinfo.calling_function = calling_function;
        handles.myData.taskinfo = taskinfo;
        guidata(handles.Administrator_Input_Screen, handles);
        taskinfo.task_handle(handles.Administrator_Input_Screen);
        % Update the handles and taskinfo structure
        handles = guidata(handles.Administrator_Input_Screen);
        handles.myData.taskinfo.duration = 0;
        tasks_in{ntasks} = handles.myData.taskinfo; %#ok<AGROW>
        
    end
    % The file is closed
    fclose(fid);
    % if some tasks are done, use given order. 
    myData.finshedTask = handles.myData.finshedTask;
    if handles.myData.finshedTask >0
        settings.taskorder = 2;
    end
    % Create a random order
    if settings.taskorder == 0
        rng('shuffle');
        order_vector = randperm(ntasks);
        for i=1:ntasks
            order = order_vector(i);
            tasks_in{i}.order = order; %#ok<AGROW>
        end
        display('random order')
    end
    % Create the listed order
    if settings.taskorder == 1
        for i=1:ntasks
            tasks_in{i}.order = i; %#ok<AGROW>
        end
        display('list order')
    end
    % Use/check the order given in the input file
    if settings.taskorder == 2
        order_vector = zeros(ntasks);
        for i=1:ntasks
            order_vector(i) = tasks_in{i}.order;
        end
        order_check = sort(order_vector);
        for i=1:ntasks
            if order_check(i) ~= i
                display(num2str(order_vector))
                field = 'Error in user specified order';
                io_error(field);
            end
        end
        display('user defined order')
    end

    % tasks_out holds task_in sorted according to taskorder
    % it also has task_start as the first task and task_finish as the last
    % therefore it has ntasks+2 elements
    ntasks_out = ntasks+2;
    tasks_out = cell(1,ntasks_out); %#ok<NASGU>
    % Sort the tasks in order
    tasks_out = tasks_in;
    for i=1:ntasks
        order = tasks_in{i}.order;
        tasks_out{order} = tasks_in{i};
    end
    tasks_out(2:ntasks+1) = tasks_out(1:ntasks);
    tasks_out{1} = task_start;
    tasks_out{ntasks+2} = task_finish;
    
    temp = get(0, 'ScreenSize');
    myData.ScreenWidth = temp(3);
    myData.ScreenHeight = temp(4);
    
    % The rest of the myData structure is created
    myData.ntasks = ntasks;
    myData.ntasks_out = ntasks_out;
    myData.iter = 1;
    myData.wsi_files = wsi_files;
    myData.settings = settings;
    myData.tasks_in = tasks_in;
    myData.tasks_out = tasks_out;
    myData.task_start = task_start;
    myData.task_finish = task_finish;
    
    % Pack myData into handles
    % Update handles.Administrator_Input_Screen
    handles.myData=myData;
    guidata(handles.Administrator_Input_Screen,handles);
    succeed = 1;
catch ME
    error_show(ME);
end
end

function io_error(name)

desc = char('ERROR: Inputfile not formatted correctly.',name);
disp(desc)
dbstack()
h_errordlg = errordlg(desc,'Application error','modal');
uiwait(h_errordlg)
% keyboard

end
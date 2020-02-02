function task_finish(hObj)
%description
%finish study
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            % Any 'finish' task must have the following id/flag
            taskinfo.id = 'finish';
            taskinfo.order = 0;
            
        case 'Update_GUI_Elements' % Update with the task elements
            
            set(handles.NextButton, 'Visible', 'on');
            set(handles.Backbutton,'Visible','on');
            % This function creates an image with text to be displayed to the user
            billboard(handles,'\bfThank You');
            
 
            set(handles.NextButton, 'Enable','on');
            uicontrol(handles.NextButton);
            
            % Close communications to camera and preview
            % Close the serial port

            
        case 'NextButtonPressed' % Clean up the task elements
           switch handles.myData.mode_desc
                case 'MicroRT'
                    if handles.myData.yesno_micro == 1
                        
                        close(handles.cam_figure)
                        delete(handles.cam)
                        
                        delete(handles.myData.stage.handle);
                    end
                 case 'TrackingView'
                    close(handles.cam_figure)
                    delete(handles.cam)

            end
              %  Save_Results(handles);
            return
            
        case 'Save_Results' % Save the results for this task
            
            fprintf(myData.fid, '%s\r\n', taskinfo.id);

    end
    
    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;    
    guidata(hObj, handles);

catch ME
    error_show(ME)
end
end

% function Save_Results(handles)
% try
%     
%     % SAVE THE DATA
%     % The filename of the newly created file will be the name of the
%     % pathologist. Gaps in the string are replaced by the
%     % '_' symbol.
%     
%     myData = handles.myData;
%     wsi_files = myData.wsi_files;
%     tasks_out = myData.tasks_out;
%     settings = myData.settings;
%     n_wsi = settings.n_wsi;
%     
%     outputfile=myData.outputfile;
%     full_outputfile = [myData.workdir,'Output_Files\',outputfile];
%     
%     % The path to the file is composed from the filename and the current
%     % application path. File at this path is then opened.
%     fid = fopen(full_outputfile,'w+');
%     
%     % The header part of the input file is written into the output file
%     % first
%     fprintf(fid,'Comments from the input file:\r\n');
%     for i=1:1:size(myData.InputFileHeader)
%         fprintf(fid,myData.InputFileHeader{i,:});
%     end
%     
%     %The settings obtained from the input file are again written into the
%     %the output file.
%     fprintf(fid,'SETTINGS\r\n');
%     
%     desc = ['NUMBER_OF_WSI=', num2str(n_wsi)];
%     fprintf(fid, '%s \r\n',desc);
%     
%     % Read in the file names of the WSI corresponding to the slots
%     for i=1:n_wsi
%         desc = ['wsi_slot_',num2str(i,'%d'),'=', ...
%             wsi_files{i}.fullname];
%         fprintf(fid,'%s \r\n',desc);
%         desc = ['rgb_lut_slot_',num2str(i,'%d'),'=', ...
%             wsi_files{i}.rgb_lutfilename];
%         fprintf(fid,'%s \r\n',desc);
%          desc = ['rgb_lut_slot_',num2str(i,'%d'),'=', ...
%             num2str( wsi_files{i}.scan_scale)];
%         fprintf(fid,'%s \r\n',desc);
%     end
%     
%     fprintf(fid,strcat('label_pos','=',num2str(settings.label_pos),'\r\n'));
%     fprintf(fid,strcat('reticleID','=',num2str(settings.reticleID),'\r\n'));
%     fprintf(fid,strcat('cam_format','=',settings.cam_format,'\r\n'));
%     fprintf(fid,strcat('cam_pixel_size','=',num2str(settings.cam_pixel_size),'\r\n'));
%     fprintf(fid,strcat('mag_cam','=',num2str(settings.mag_cam),'\r\n'));
%     fprintf(fid,strcat('mag_lres','=',num2str(settings.mag_lres),'\r\n'));
%     fprintf(fid,strcat('mag_hres','=',num2str(settings.mag_hres),'\r\n'));
%     %fprintf(fid,strcat('scan_scale','=',num2str(settings.scan_scale),'\r\n'));
%     fprintf(fid,strcat('stage_label','=',num2str(myData.stage.label),'\r\n'));
%     desc = ['BG_Color_RGB=',...
%         num2str(myData.settings.BG_color(1)),'=',...
%         num2str(myData.settings.BG_color(2)),'=',...
%         num2str(myData.settings.BG_color(3)),...
%         '\r\n'];
%     fprintf(fid,desc);
%     desc = ['FG_Color_RGB=',...
%         num2str(myData.settings.FG_color(1)),'=',...
%         num2str(myData.settings.FG_color(2)),'=',...
%         num2str(myData.settings.FG_color(3)),...
%         '\r\n'];
%     fprintf(fid,desc);
%     desc = ['AxesBG_Color_RGB=',...
%         num2str(myData.settings.Axes_BG(1)),'=',...
%         num2str(myData.settings.Axes_BG(2)),'=',...
%         num2str(myData.settings.Axes_BG(3)),...
%         '\r\n'];
%     fprintf(fid,desc);
%     fprintf(fid,strcat('FontSize','=',num2str(myData.settings.FontSize),'\r\n'));
%     fprintf(fid,strcat('saveimages','=',num2str(myData.settings.saveimages),'\r\n'));
%     fprintf(fid,strcat('taskorder','=',num2str(myData.settings.taskorder),'\r\n'));
%     fprintf(fid,'\r\n');
%     
%     fprintf(fid,'BODY\r\n');
%     
%     % The arrays containing information about the evaluation task and the
%     % answers of the evaluator are saved into the file that was opened.
% 
%     st = dbstack;
%     calling_function = st(1).name;
% 
%     % Write the 'start' task output according to taskinfo.task_handle
%     taskinfo = myData.task_start;
%     taskinfo.fid = fid;
%     taskinfo.calling_function = calling_function;
%     handles.myData.taskinfo = taskinfo;
%     guidata(handles.GUI, handles);
%     taskinfo.task_handle(handles.GUI);
%     
%     % Write the 'finish' task output according to taskinfo.task_handle
%     taskinfo = myData.task_finish;
%     taskinfo.fid = fid;
%     taskinfo.calling_function = calling_function;
%     handles.myData.taskinfo = taskinfo;
%     guidata(handles.GUI, handles);
%     taskinfo.task_handle(handles.GUI);
%     
%     % Write each task output according to taskinfo.task_handle
%     for iter = 2:myData.ntasks+1
%         
%         taskinfo = tasks_out{iter};
%         taskinfo.fid = fid;
%         taskinfo.calling_function = calling_function;
%         handles.myData.taskinfo = taskinfo;
%         guidata(handles.GUI, handles);
%         taskinfo.task_handle(handles.GUI);
%         
%     end
%     
%     fclose(fid);
%     fileattrib(strcat(myData.workdir,'Output_Files\',outputfile),'-w')
%     
% catch ME
%     error_show(ME)
% end
% end
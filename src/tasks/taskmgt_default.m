function taskmgt_default(handles, on_off)
try
    
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    
%     % Moving allowed?
%     if taskinfo.moveflag==1
%         set(handles.moving_indication, ...
%             'CData',myData.graphics.moving_allowed);
%     else
%         set(handles.moving_indication, ...
%             'CData',myData.graphics.moving_not_allowed);
%     end
%     
%     % Zooming allowed?
%     if taskinfo.zoomflag==1
%         set(handles.zooming_indication, ...
%             'CData',myData.graphics.zooming_allowed);
%     else
%         set(handles.zooming_indication, ...
%             'CData',myData.graphics.zooming_not_allowed);
%     end
    
    % Show management buttons
    if strcmpi(handles.myData.mode_desc,'MicroRT')
        set(handles.Best_Register_Button, 'Visible',on_off);
        set(handles.Fast_Register_Button, 'Visible',on_off);
        set(handles.Refine_Register_Button, 'Visible',on_off);
        set(handles.videobutton, 'Visible',on_off);
    elseif strcmpi(handles.myData.mode_desc,'TrackingView')
        set(handles.videobutton, 'Visible',on_off);
    end
%     set(handles.moving_indication,'visible',on_off);
% 
%     set(handles.zooming_indication,'visible',on_off);
    set(handles.NextButton, 'Visible',on_off);
    set(handles.ResetViewButton, 'Visible',on_off);
    set(handles.PauseButton, 'Visible',on_off);
    set(handles.ResumeButton, 'Visible', on_off, ...
        'Enable', 'off');
    set(handles.Reticlebutton, 'Visible', on_off);
    if handles.myData.iter > handles.myData.finshedTask+2
        set(handles.Backbutton,'visible',on_off);
    end
    
    
    % Update reader on study progress
    switch on_off
        case 'on'
            
            desc = ['Task ', num2str(myData.iter-1), ...
                ' of ', num2str(myData.ntasks)];
            desc = {desc, taskinfo.text};
            handles.text_progress = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', myData.settings.FontSize,...
                'BackgroundColor',myData.settings.BG_color, ...
                'ForegroundColor',myData.settings.FG_color, ...
                'Style', 'text', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'normalized', ...
                'Position', [.2, .5, .8, .5], ...
                'String', desc);
            
        case 'off'
            
            delete(handles.text_progress);
            handles = rmfield(handles, 'text_progress');
            
    end
    
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(handles.GUI, handles);
    
catch ME
    error_show(ME)
end
end
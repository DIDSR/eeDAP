%%-------- billboard --------
function billboard(handles, desc)
try
   % This function creates an image with text to be displayed to the user
    set(handles.GUI, 'Units', 'pixels');
    pause(0.5);
     set(handles.ImageAxes,...
         'Units', 'normalized',...
         'Position', [0, 0.2, 1.0, 0.8],...
         'Units', 'pixels',...
         'Visible', 'off');
    position = int64(get(handles.ImageAxes, 'Position'));
    set(handles.GUI, 'Units', 'normalized');
    temp_image = ones([position(4), position(3), 3])-.5;
    i=(1:double(position(3)))/double(position(3));
    for j=1:position(4)
        temp_image(j,:,1) = i;
    end
    set(handles.ImageAxes,'Units', 'normalized');
    img_object = image(temp_image, 'Parent', handles.ImageAxes); %#ok<NASGU>
    axis image
    set(handles.ImageAxes, 'Visible', 'off');
    mp = get(0, 'MonitorPositions');
    sc= mp(find(mp(:,1)==1&mp(:,2)==1),:);
    if sc(3)<sc(4)
        fontsize=0.15;
    else
        fontsize=0.25;
    end
    st = dbstack;
    if strcmp( st(2).name,'task_get_WSI_position' )||strcmp( st(2).name,'WSI_Position_Callback' )
        fontsize = 0.05;
    end
    text('Parent', handles.ImageAxes,...
        'FontName', 'Times',...
        'FontUnits', 'normalized',...
        'FontSize', fontsize,...
        'HorizontalAlignment', 'center',...
        'VerticalAlignment', 'middle',...
        'Position', [position(3)/2, position(4)/2],...
        'String', desc);
   
catch ME
    error_show(ME)
end
end


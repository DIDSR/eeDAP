function taskinfo_default(hObj, taskinfo)
try
    
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
    taskinfo.text  = char(desc{9}); 
    taskinfo.img_w = taskinfo.roi_w; 
    taskinfo.img_h = taskinfo.roi_h;
    handles.myData.taskinfo = taskinfo;
    guidata(hObj, handles);
    
catch ME
    error_show(ME)
end

end
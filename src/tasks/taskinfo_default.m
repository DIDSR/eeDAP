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
    taskinfo.img_w = str2double(desc{9});
    taskinfo.img_h = str2double(desc{10});
    taskinfo.text  = char(desc{11});
    taskinfo.moveflag = str2double(desc{12});
    taskinfo.zoomflag = str2double(desc{13});
    taskinfo.q_op1 = char(desc{14});
    taskinfo.q_op2 = char(desc{15});
    taskinfo.q_op3 = char(desc{16});
    taskinfo.q_op4 = char(desc{17});
 
    handles.myData.taskinfo = taskinfo;
    guidata(hObj, handles);
    
catch ME
    error_show(ME)
end

end
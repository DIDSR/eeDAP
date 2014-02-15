function taskimage_archive(handles)
try
    
    myData = handles.myData;
    taskinfo = myData.taskinfo;
    
    FolderName=[myData.output_files_dir,...
        strrep(myData.outputfile,'.dapso','')];
    
    if ~exist(FolderName,'file')
        mkdir(FolderName);
    end
    
    switch handles.myData.mode_desc
        case 'MicroRT'
            if handles.myData.yesno_micro == 1
                img=camera_take_image(handles.cam);
                imwrite(img,strcat(FolderName,'\',...
                    'ID-',taskinfo.id,...
                    '_iter-',num2str(taskinfo.order),...
                    '_cam.tif'));
            end
    end
    
    img=imread(taskinfo.ROIname);
    imwrite(img,strcat(FolderName,'\',...
        'ID-',taskinfo.id,...
        '_iter-',num2str(taskinfo.order),...
        '_wsi.tif'));
    
catch ME
    error_show(ME)
end

end
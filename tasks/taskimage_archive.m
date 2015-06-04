function taskimage_archive(handles)
try

    % If we arrive here because we click "back" button do not save images
        myData = handles.myData;
        taskinfo = myData.taskinfo;
        saveimages = myData.settings.saveimages;
        FolderName=[myData.output_files_dir,...
            strrep(myData.outputfile,'.dapso','')];
        
        if ~exist(FolderName,'file')
            mkdir(FolderName);
        end
        
        switch handles.myData.mode_desc
            case 'MicroRT'
                if (saveimages == 1 || saveimages == 3)
                    if handles.myData.yesno_micro == 1
                        img=camera_take_image(handles.cam);
                        imwrite(img,strcat(FolderName,'\',...
                            'ID-',taskinfo.id,...
                            '_iter-',num2str(taskinfo.order),...
                            '_cam.tif'));
                    end
                end
        end
        if (saveimages == 1 || saveimages == 2)
            img=imread(taskinfo.ROIname);
            imwrite(img,strcat(FolderName,'\',...
                'ID-',taskinfo.id,...
                '_iter-',num2str(taskinfo.order),...
                '_wsi.tif'));
        end
    
catch ME
    error_show(ME)
end

end
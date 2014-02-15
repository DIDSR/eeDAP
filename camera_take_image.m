function img=camera_take_image(vid)
try
    start(vid);

    data = getdata(vid,10); 
    img=data(:,:,:,10);
    stop(vid);

catch ME
    error_show(ME)
end
end

function cam=camera_open(cam_kind,cam_format,defaultR,defaultB)
try

    % imaqtool: launches an interactive GUI to allow you to explore,
    %   configure, and acquire data from your installed and supported image
    %   acquisition devices
    
    % imaqhwinfo: a structure that contains information about the image
    %   acquisition adaptors available on the system. An adaptor is the
    %   interface between MATLAB® and the image acquisition devices
    %   connected to the system. The adaptor's main purpose is to pass
    %   information between MATLAB and an image acquisition device via its
    %   driver.

    % imaqhwinfo(adaptorname): returns out, a structure that contains
    %   information about the adaptor specified by the text string
    %   adaptorname. The information returned includes adaptor version and
    %   available hardware for the specified adaptor.

    % imaqfind: matlab function to find image acquisition objects

    % http://www.mathworks.com/help/imaq/configuring-image-acquisition-object-properties.html
    
    % delete any currently running (stale) video inputs
    objects = imaqfind;
    delete(objects);
    if strcmp( cam_kind,'USB')
       cam_adaptor = 'pointgrey';
    elseif strcmp( cam_kind,'Firewire')
       cam_adaptor = 'dcam';
    end
    % Create the video object to communicate with the camera 
    if exist('cam_format','var')
        cam = videoinput(cam_adaptor,1,cam_format) %#ok<NOPRT>
    else
        cam = videoinput(cam_adaptor,1) %#ok<NOPRT>
    end
    imaqhwinfo(cam)
    cam.Tag = 'Microscope Camera Object';
    cam.TriggerRepeat = 0;
    cam.FramesPerTrigger = 10;
    cam.FrameGrabInterval = 1;
    dim = cam.VideoResolution;
    
    % Camera iamge must be at least 640 x 480
    if dim(1) < 640 || dim(2) < 480
        desc = 'Camera image must be at least 640x480' %#ok<NOPRT>
        h_errordlg = errordlg(desc,'Insufficient Camera Size','modal');
        uiwait(h_errordlg)
        close all force
    end
    % Camera image must be rgb
    if ~strcmp(cam.ReturnedColorSpace,'rgb');
        desc = 'Camera image must be rgb' %#ok<NOPRT>
        h_errordlg = errordlg(desc,'Insufficient Camera Size','modal');
        uiwait(h_errordlg)
        close all force
    end
    
    % Set value of a video source object property.
    cam_src = getselectedsource(cam);
    cam_src.Tag = 'Microscope Camera Source';
    if strcmp( cam_kind,'USB')
       cam_src.WhiteBalanceRBMode = 'Off';
%        defaultR = 587;
%        defaultB = 710;
       cam_src.WhiteBalanceRB = [defaultR defaultB];
%        colorDone = 0;
%        waitingBar = waitbar (0.5,'Adjusting color');
%        while colorDone == 0 
%            img=camera_take_image(cam);
%            [x,y,z] = size(img);
%            R = mean(mean((img((ceil(x/2)-10:ceil(x/2)+10),(ceil(y/2)-10:ceil(y/2)+10),1))));
%            G = mean(mean((img((ceil(x/2)-10:ceil(x/2)+10),(ceil(y/2)-10:ceil(y/2)+10),2))));
%            B = mean(mean((img((ceil(x/2)-10:ceil(x/2)+10),(ceil(y/2)-10:ceil(y/2)+10),3))));
%            if abs(R-G)>5 || abs(B-G)>5 || abs(R-B)>5
%                defaultR = log2(G/R) * 256 + defaultR;
%                defaultB = log2(G/B) * 256 + defaultB;
%                cam_src.WhiteBalanceRB = [defaultR defaultB];
%            else
%                colorDone = 1;
%                close(waitingBar);
%            end
%        end
       
    end
catch ME
    error_show(ME)
end
end
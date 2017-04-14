function success = exportXML(fullname,scan_scale, task_id,workdir,Left, Top, roi_w, roi_h)
%EXPORTXML Summary of this function goes here
% process data
try
    success = 0;
    length = 2*(roi_w + roi_h);
    lengthM = length*scan_scale;
    area= roi_w* roi_h;
    areaM= area * scan_scale *scan_scale;
    x1 = Left;
    y1 = Top;
    x2 = Left + roi_w;
    y2 = Top;
    x3 = Left + roi_w;
    y3 = Top + roi_h;
    x4 = Left; 
    y4 = Top + roi_h;
%     y1 = Left;
%     x1 = Top;
%     y2 = Left + roi_w;
%     x2 = Top;
%     y3 = Left + roi_w;
%     x3 = Top + roi_h;
%     y4 = Left; 
%     x4 = Top + roi_h;

  %  indexslash = findstr(fullname, '\');
    indexdot = findstr(fullname, '.');
  %  wsi_name = fullname((indexslash(end)+1):(indexdot(end)-1));
    imageDir = fullname(1:(indexdot(end)-1));
 %   workdir = [workdir, 'Temporary_Task_Images\'];
%     XMLfolder = [workdir, wsi_name,'XML\'];
%     filename = [XMLfolder,task_id,'.xml'];
  %  XMLname = [workdir, wsi_name];
    filename = [imageDir,'.xml'];
%     if isdir(XMLfolder)
%        delete(filename);
%     else
%        mkdir(XMLfolder);
%     end

    % generate xml
    % annotation information
    docNode = com.mathworks.xml.XMLUtils.createDocument('Annotations');
    docRootNode = docNode.getDocumentElement;
    docRootNode.setAttribute('MicronsPerPixel','0.250300');

    
    % image information
    entry_level_info = docNode.createElement('Image_information');
    entry_level_info.setAttribute('Full_path',fullname);
    docNode.getDocumentElement.appendChild(entry_level_info);
    
    entry_level1 = docNode.createElement('Annotation');
    entry_level1.setAttribute('MacroName','');
    entry_level1.setAttribute('MarkupImagePath','');
    entry_level1.setAttribute('Selected','1');
    entry_level1.setAttribute('Visible','1');
    entry_level1.setAttribute('LineColor','65280');
    entry_level1.setAttribute('Type','4');
    entry_level1.setAttribute('Incremental','0');
    entry_level1.setAttribute('LineColorReadOnly','0');
    entry_level1.setAttribute('NameReadOnly','0');
    entry_level1.setAttribute('ReadOnly','0');
    entry_level1.setAttribute('Name','');
    entry_level1.setAttribute('Id','1');
    docNode.getDocumentElement.appendChild(entry_level1);

    entry_level1_1 = docNode.createElement('Attributes');
    entry_level1.appendChild(entry_level1_1);

    entry_level1_1_1 = docNode.createElement('Attribute');
    entry_level1_1_1.setAttribute('Name','Description');
    entry_level1_1_1.setAttribute('Id','0');
    entry_level1_1_1.setAttribute('Value','');
    entry_level1_1.appendChild(entry_level1_1_1);


    entry_level1_2 = docNode.createElement('Regions');
    entry_level1.appendChild(entry_level1_2);
    entry_level1_2_1 = docNode.createElement('RegionAttributeHeaders');
    entry_level1_2.appendChild(entry_level1_2_1);
    entry_level1_2_1_1 = docNode.createElement('AttributeHeaders');
    entry_level1_2_1_1.setAttribute('Name','Region');
    entry_level1_2_1_1.setAttribute('Id','9999');
    entry_level1_2_1_1.setAttribute('ColumunWidth','-1');
    entry_level1_2_1.appendChild(entry_level1_2_1_1);

    entry_level1_2_1_2 = docNode.createElement('AttributeHeaders');
    entry_level1_2_1_2.setAttribute('Name','Length');
    entry_level1_2_1_2.setAttribute('Id','9997');
    entry_level1_2_1_2.setAttribute('ColumunWidth','-1');
    entry_level1_2_1.appendChild(entry_level1_2_1_2);

    entry_level1_2_1_3 = docNode.createElement('AttributeHeaders');
    entry_level1_2_1_3.setAttribute('Name','Area');
    entry_level1_2_1_3.setAttribute('Id','9996');
    entry_level1_2_1_3.setAttribute('ColumunWidth','-1');
    entry_level1_2_1.appendChild(entry_level1_2_1_3);

    entry_level1_2_1_4 = docNode.createElement('AttributeHeaders');
    entry_level1_2_1_4.setAttribute('Name','Text');
    entry_level1_2_1_4.setAttribute('Id','9998');
    entry_level1_2_1_4.setAttribute('ColumunWidth','-1');
    entry_level1_2_1.appendChild(entry_level1_2_1_4);

    entry_level1_2_1_5 = docNode.createElement('AttributeHeaders');
    entry_level1_2_1_5.setAttribute('Name','Description');
    entry_level1_2_1_5.setAttribute('Id','1');
    entry_level1_2_1_5.setAttribute('ColumunWidth','-1');
    entry_level1_2_1.appendChild(entry_level1_2_1_5);

    entry_level1_2_2 = docNode.createElement('Region');
    entry_level1_2.appendChild(entry_level1_2_2);
    entry_level1_2_2.setAttribute('Selected','1');
    entry_level1_2_2.setAttribute('Type','1');
    entry_level1_2_2.setAttribute('Id','1');
    entry_level1_2_2.setAttribute('DisplayId','1');
    entry_level1_2_2.setAttribute('Analyze','1');
    entry_level1_2_2.setAttribute('InputRegionId','0');
    entry_level1_2_2.setAttribute('NegativeROA','0');
    entry_level1_2_2.setAttribute('Text','');
    entry_level1_2_2.setAttribute('AreaMicrons',num2str(areaM));
    entry_level1_2_2.setAttribute('LengthMicrons',num2str(lengthM));
    entry_level1_2_2.setAttribute('Area',num2str(area));
    entry_level1_2_2.setAttribute('Length',num2str(length));
    entry_level1_2_2.setAttribute('ImageFocus','0');
    entry_level1_2_2.setAttribute('ImageLocation','');
    entry_level1_2_2.setAttribute('Zoom','0.022562');

    entry_level1_2_2_1 = docNode.createElement('Attributes');
    entry_level1_2_2.appendChild(entry_level1_2_2_1);

    entry_level1_2_2_2 = docNode.createElement('Vertices');
    entry_level1_2_2.appendChild(entry_level1_2_2_2);

    entry_level1_2_2_2_1 = docNode.createElement('Vertex');
    entry_level1_2_2_2.appendChild(entry_level1_2_2_2_1);
    entry_level1_2_2_2_1.setAttribute('Y',num2str(y1));
    entry_level1_2_2_2_1.setAttribute('X',num2str(x1));

    entry_level1_2_2_2_2 = docNode.createElement('Vertex');
    entry_level1_2_2_2.appendChild(entry_level1_2_2_2_2);
    entry_level1_2_2_2_2.setAttribute('Y',num2str(y2));
    entry_level1_2_2_2_2.setAttribute('X',num2str(x2));

    entry_level1_2_2_2_3 = docNode.createElement('Vertex');
    entry_level1_2_2_2.appendChild(entry_level1_2_2_2_3);
    entry_level1_2_2_2_3.setAttribute('Y',num2str(y3));
    entry_level1_2_2_2_3.setAttribute('X',num2str(x3));

    entry_level1_2_2_2_4 = docNode.createElement('Vertex');
    entry_level1_2_2_2.appendChild(entry_level1_2_2_2_4);
    entry_level1_2_2_2_4.setAttribute('Y',num2str(y4));
    entry_level1_2_2_2_4.setAttribute('X',num2str(x4));

    entry_level1_2_3 = docNode.createElement('plots');
    entry_level1_2.appendChild(entry_level1_2_3);

    xmlwrite(filename,docNode);
   
    % delete the first line from XML file
    fid = fopen(filename, 'r') ;     % Open source file.
    fgetl(fid) ;                   % Read/discard line.
    buffer = fread(fid, Inf) ;     % Read rest of the file.
    fclose(fid);
    fid = fopen(filename, 'w')  ;   % Open destination file.
    fwrite(fid, buffer) ;          % Save to file.
    fclose(fid) ;

    winopen(fullname);
  % [status2,cmdout2]=system(fullname);
    %[status2,cmdout2]=system(fullname,'-echo');
    success = 1;
    
catch ME
    error_show(ME)
end

end


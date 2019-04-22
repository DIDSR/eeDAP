function mask = reticle_make_mask(reticleID, pixel_size, offset)
try
    
    offset = int64(offset);
    
%    if strcmp(cam_or_roi,'cam')
        % Draw the reticle on a camera image
        switch reticleID
%             case 'KR-429'
%                 
%                 box_w = int64(31.25/cam_scale_hres);
%                 box_h = int64(31.25/cam_scale_hres);
%                 line_black_w = zeros(width,3);
%                 line_white_w = line_black_w+255;
%                 line_black_h = zeros(height,3);
%                 line_white_h = line_black_h+255;
%                 
%                 % Make horizontal lines middle and up on camera image
%                 pos_h = center_h;
%                 while pos_h+1 < height
%                     img(pos_h,:,:) = line_black_w;
%                     img(pos_h+1,:,:) = line_white_w;
%                     pos_h = pos_h+box_h;
%                 end
%                 % Make horizontal lines middle and down on camera image
%                 pos_h = center_h;
%                 while pos_h > 0
%                     img(pos_h,:,:) = line_black_w;
%                     img(pos_h+1,:,:) = line_white_w;
%                     pos_h = pos_h-box_h;
%                 end
%                 % Make vertical lines middle and right on camera image
%                 pos_w = center_w;
%                 while pos_w+1 < width
%                     img(:,pos_w,:) = line_black_h;
%                     img(:,pos_w+1,:) = line_white_h;
%                     pos_w = pos_w+box_w;
%                 end
%                 % Make horizontal lines middle and left on camera image
%                 pos_w = center_w;
%                 while pos_w > 0
%                     img(:,pos_w,:) = line_black_h;
%                     img(:,pos_w+1,:) = line_white_h;
%                     pos_w = pos_w-box_w;
%                 end
                
            case 'KR-32536'
                
                % The reticle features are contained in 6500um x 6500um
                % The reticle mask defined below is upside down compared to
                % the drawing, thank you matlab.

                % The following are lengths of lines (um) in pixels
                l_6500um = 2*int64(6500/pixel_size/2);
                l_1000um = int64(1000/pixel_size);
                l_0500um = int64( 500/pixel_size);
                l_0250um = int64( 250/pixel_size);

                % Define the reticle region with a 10 pixel boarder
                border = max([max(abs(offset))+10,25]);
                width = l_6500um+2*border;
                mask = uint8( ones(width, width) );
                x0 = width/2 + offset(1);
                y0 = width/2 + offset(2);

                % Center vertical lines
                top = y0  - l_0250um;
                bot = top - l_1000um;
                mask(bot:top,x0,:) = 0;
                bot = bot - 2*l_1000um;
                top = top - 2*l_1000um;
                mask(bot:top,x0,:) = 0;
                bot = y0  + l_0250um;
                top = bot + l_0500um;
                mask(bot:top,x0,:) = 0;
                top = top + l_1000um;
                bot = bot + l_1000um;
                mask(bot:top,x0,:) = 0;
                % Left column of vertical lines
                bot = y0  + l_0500um;
                top = bot + l_1000um;
                mask(bot:top,x0-l_1000um-l_0500um-l_0250um,:) = 0;
                top = y0  - l_0500um;
                bot = top - l_1000um;
                mask(bot:top,x0-l_1000um-l_0500um-l_0250um,:) = 0;
                % Right column of vertical lines
                bot = y0  + l_0250um;
                top = bot + l_0500um;
                mask(bot:top,x0+l_1000um,:) = 0;
                top = y0  - l_0250um;
                bot = top - l_0500um;
                mask(bot:top,x0+l_1000um,:) = 0;

                % Center horizontal lines
                bot = x0  + l_0250um;
                top = bot + l_0500um;
                mask(y0,bot:top,:) = 0;
                bot = bot + l_1000um;
                top = top + l_1000um;
                mask(y0,bot:top,:) = 0;
                top = x0  - l_0250um;
                bot = top - l_1000um;
                mask(y0,bot:top,:) = 0;
                top = top - 2*l_1000um;
                bot = bot - 2*l_1000um;
                mask(y0,bot:top,:) = 0;
                % Top row of horizontal lines
                bot = x0  + l_0500um;
                top = bot + l_1000um;
                mask(y0-l_1000um-l_0500um-l_0250um,bot:top,:) = 0;
                top = x0  - l_0500um;
                bot = top - l_1000um;
                mask(y0-l_1000um-l_0500um-l_0250um,bot:top,:) = 0;
                % Bottom row of horizontal lines
                bot = x0  + l_0250um;
                top = bot + l_0500um;
                mask(y0+l_1000um,bot:top,:) = 0;
                top = x0  - l_0250um;
                bot = top - l_0500um;
                mask(y0+l_1000um,bot:top,:) = 0;
        
        
          case 'KR-871'
                
                % The reticle features are contained in 10000um x 10000um
                % The reticle mask defined below is upside down compared to
                % the drawing, thank you matlab.

                % The following are lengths of lines (um) in pixels
                l_14000um = 2*int64(14000/pixel_size/2);
                l_1000um = int64(1000/pixel_size);
%                l_0500um = int64( 500/pixel_size);
%                l_0250um = int64( 250/pixel_size);

                % Define the reticle region with a 10 pixel boarder
                border = max([max(abs(offset))+10,25]);
                width = l_14000um+2*border;
                mask = uint8( ones(width, width) );
                x0 = width/2 + offset(1);
                y0 = width/2 + offset(2);

                for i=1:5     %5 squares
                    length=l_1000um*i;
                    up = y0-length;
                    down= y0 + length;
                    left= x0- length;
                    right= x0+length;
                     mask(up,left:right,:) = 0;
                     mask(down,left:right,:) = 0;
                     mask(up:down,left,:) = 0;
                     mask(up:down,right,:) = 0;                     
                end
                
                %reticle
                up=y0-l_14000um/2;
                down=y0+l_14000um/2;
                mask(up:down,x0,:)=0;
                left=x0-l_14000um/2;
                right=x0+l_14000um/2;
                mask(y0,left:right,:)=0;
                
        end

        % h_figure = figure
        % image(img)
        % axis xy
        % colormap(gray)
                

%     elseif strcmp(cam_or_roi,'roi')
%         % Draw the reticle on an extracted ROI
%         switch settings.reticle
%             case 'KR-429'
%                 
%                 box_w = int64(31.25/scan_scale);
%                 box_h = int64(31.25/scan_scale);
%                 line_black_w = zeros(width,3);
%                 line_white_w = line_black_w+255;
%                 line_black_h = zeros(height,3);
%                 line_white_h = line_black_w+255;
%                 
%                 % Make horizontal lines middle and up on camera image
%                 pos_h = center_h;
%                 while pos_h+1 < height
%                     img(pos_h,:,:) = line_black_w;
%                     img(pos_h+1,:,:) = line_white_w;
%                     pos_h = pos_h+box_h;
%                 end
%                 % Make horizontal lines middle and down on camera image
%                 pos_h = center_h;
%                 while pos_h > 0
%                     img(pos_h,:,:) = line_black_w;
%                     img(pos_h+1,:,:) = line_white_w;
%                     pos_h = pos_h-box_h;
%                 end
%                 % Make vertical lines middle and right on camera image
%                 pos_w = center_w;
%                 while pos_w+1 < width
%                     img(:,pos_w,:) = line_black_h;
%                     img(:,pos_w+1,:) = line_white_h;
%                     pos_w = pos_w+box_w;
%                 end
%                 % Make horizontal lines middle and left on camera image
%                 pos_w = center_w;
%                 while pos_w > 0
%                     img(:,pos_w,:) = line_black_h;
%                     img(:,pos_w+1,:) = line_white_h;
%                     pos_w = pos_w-box_w;
%                 end
%                 
%         end
%         
%     end
    
    
catch ME
    error_show(ME)
end

end
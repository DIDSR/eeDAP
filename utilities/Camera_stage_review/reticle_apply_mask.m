function img = reticle_apply_mask(img, mask)
try
    % To be used with RGB images, 8 bits per channel
    
    temp = size(img);
    img_w = temp(2);
    img_h = temp(1);
    temp = size(mask);
    mask_w = temp(2);
    mask_h = temp(1);
    
    bot_h_mask = 1;
    top_h_mask = mask_h;
    bot_w_mask = 1;
    top_w_mask = mask_w;
    if img_h < mask_h
        bot_h_mask = floor(mask_h/2 - img_h/2 + 1);
        top_h_mask = floor(mask_h/2 + img_h/2);
    end
    if img_w < mask_w
        bot_w_mask = floor(mask_w/2 - img_w/2 + 1);
        top_w_mask = floor(mask_w/2 + img_w/2);
    end
    bot_h_img = 1;
    top_h_img = img_h;
    bot_w_img = 1;
    top_w_img = img_w;
    if mask_h < img_h
        bot_h_img = floor(img_h/2 - mask_h/2 + 1);
        top_h_img = floor(img_h/2 + mask_h/2);
    end
    if mask_w < img_w
        bot_w_img = floor(img_w/2 - mask_w/2 + 1);
        top_w_img = floor(img_w/2 + mask_w/2);
    end

    % Apply black mask
    for i_channel=1:3
        img(bot_h_img:top_h_img, bot_w_img:top_w_img, i_channel) = ...
            img(bot_h_img:top_h_img, bot_w_img:top_w_img, i_channel) ...
            .* ... (element by element multiplication)
            mask(bot_h_mask:top_h_mask, bot_w_mask:top_w_mask);
    end
    
    % Create white mask (shift by one pixel up and to the right
    mask(2:mask_h,2:mask_w) = mask(1:mask_h-1,1:mask_w-1);
    % Apply white mask
    for i_channel=1:3
        img(bot_h_img:top_h_img, bot_w_img:top_w_img, i_channel) = ...
            (...
            img(bot_h_img:top_h_img, bot_w_img:top_w_img, i_channel) ...
            .* ... (element by element multiplication)
            mask(bot_h_mask:top_h_mask, bot_w_mask:top_w_mask)...
            )...
            + ... (element by element addition)
            (1-mask(bot_h_mask:top_h_mask, bot_w_mask:top_w_mask))*255;

    end
    
catch ME
    error_show(ME)
end

end
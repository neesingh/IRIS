function [ value ] = iqm_xcorr( a, ~, cf )
% iqm_xcorr - Calculates the cross correlation between target image and its
% retinal simulation. This metric takes a long time to compute!
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    ui_handles = getappdata(cf, 'ui_handles');
    img = get(ui_handles.target_image, 'UserData');
    img = img(:,:,a.lambda_idx);

    sim_img = conv2(double(img), double(a.PSF_resized), 'same');
    
    % Discard 15% border because it fucks things up
    border = 0.15;
    border_r = floor(border*size(img,1));
    border_c = floor(border*size(img,2));
    
    img = img(border_r:size(img,1)-border_r, border_c:size(img,2)-border_c);
    sim_img = sim_img(border_r:size(sim_img,1)-border_r, border_c:size(sim_img,2)-border_c);

    value = normxcorr2(img, sim_img);
    value = max(abs(value(:)));
    
end


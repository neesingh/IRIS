function [ PSF_resized ] = is_psf_resize(PSF, scale, method)% Rescale the PSF%        % LNT comment 17Apr10. Prior to today, interpolation method was 'bicubic'    % which can produce negative values of PSFroi. Not a good idea! So change    % to 'bilinear' interpolation.    if nargin < 3 || isempty(method), method = 'lanczos3'; end    PSF_resized = imresize(PSF, scale, method, 'Antialiasing', false);end
function [ value ] = iqm_islogmar( a, ~, ~ )
% iqm_islogmar - Image Simulator's Visual Acuity expressed as log MAR
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    
    %threshold = 0.735;         % As in Practical Astrophotography by Jeffrey R. Charles,
                                % and Optical Imaging Techniques in Cell Biology by Guy Cox
    
    threshold = 0.735;
    
    PSF_bin = a.PSF_cropped > threshold*max(a.PSF_cropped(:));
    
    area = sum(PSF_bin(:));
    
    theta = 2*sqrt(area/pi);
    theta = theta * a.psf_resolution;
    
    value =  log10(theta);           % logMAR
     
end


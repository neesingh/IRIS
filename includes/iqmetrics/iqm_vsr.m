function [ value ] = iqm_vsr( a, s, ~ )
% iqm_vsr - Calculates the visual strehl ratio of a PSF
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    roi = a.psf_crop_roi;
    dPSF = s.dPSF(roi(2,1):roi(2,2), roi(1,1):roi(1,2), a.lambda_idx);

    value = max(a.PSF_cropped(:))/max(dPSF(:));

end


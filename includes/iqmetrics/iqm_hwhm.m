function [ value ] = iqm_hwhm( a, pixsize, ~ )
% iqm_hwhm - Calculates the half width at half height (arcmin)
% method is to count the number of pixels for which intensity > max/2 and
% interpret the result as area, from which we compute radius.
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    value = sqrt(sum(sum(a.PSF_cropped >= max(a.PSF_cropped(:))/2))/pi)*pixsize;

end


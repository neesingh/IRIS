function [ value ] = iqm_dummy( a, ~ )
%IQM_DUMMY A dummy metric returning random numbers. Can be used for testing
%or as a template.
%
% a - structure of calculated data for a given wavelength, and pupil
% see zernike2psf to get a hang of its contents
%

    value = rand(1);
    
end


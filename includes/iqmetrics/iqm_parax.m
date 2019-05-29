function [ value ] = iqm_parax( a, s, ~ )
% iqm_parax -  The value of M for the Paraxial Curve Matching to the Wavefront
% as found in:
% Thibos LN, Hong X, Bradley A, Applegate RA. "Accuracy and precision of objective refraction from wavefront
% aberrations" Journal of Vision, 2004.
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    z = a.zernikes;
    z(s.selected_zernike) = z(s.selected_zernike) + s.analysis_range(a.step_id);

    value = (-4*sqrt(3)*z(5) + 12*sqrt(5)*z(13) - 24*sqrt(7)*z(25)) / a.r^2;

end


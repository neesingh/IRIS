function [ value ] = iqm_mtr( a, s, ~ )
% iqm_mtr - MTR Metric - Spherical Equivalent as a function of t(r)
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%

    z = a.zernikes;
    
    if(length(a.zernikes) < 28)
        z = zeros(28,1);
        z(1:length(a.zernikes)) = a.zernikes;
    end
    
    z(s.selected_zernike) = z(s.selected_zernike) + s.analysis_range(a.step_id);

    bend = 2.0;
    t = (a.r<bend) * 1 + (a.r>=bend) * (bend+0.0378)./(a.r^1.009);
    
    delta = sqrt(3)*z(5) + 3*sqrt(5)*z(13)*(t^2 - 1) + sqrt(7)*z(25)*(10*t^4 - 15*t^2 + 6);

    value = -(4*delta)/(a.r^2);

end


function [ value ] = iqm_mtf30cpd( a, ~, ~ )
% iqm_mtf30cpd - The International Organization for Standardization (ISO) standard
% 11979-21 has been used to define how the optical quality of multifocal IOLs or any IOL should be assessed.
% Measurement of the modulation transfer function (MTF) is now recognized as a routine test for measuring
% the optical quality of IOLs.
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%

    MTF_cpd = 30;   
    MTF = abs(a.OTF);
    
    [~, ~, freq, MTF_radial] = RadialAverage(MTF, a.psf_x, a.psf_y);
    
    idx = abs((freq*a.psf_bandwidth) - MTF_cpd);
    [~, idx] = min(idx);
    
    value = MTF_radial(idx);

end
function [ value ] = iqm_entropy( a, ~, ~ )
% iqm_entropy - Calculates the Dave William's entropy
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    value = Entropy(a.PSF);

end


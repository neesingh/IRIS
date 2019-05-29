function [ c20 ] = diopters2microns( D, r )
% DIOPTERS2MICRONS does what's advertised
% For normalised Zernike coefficients, recommended in ANSI Z80.28, the sphere power is:
% sph = 4 sqrt(3) C2,0 / r^2. where r is the pupil radius in mm, and C2,0 is the (rms)
% amplitude of the Z20 Zernike mode in micrometers.
    
    c20 = (D * r^2) / (4*sqrt(3));
    %D = (4*sqrt(3) * c20) / r^2;
 
end


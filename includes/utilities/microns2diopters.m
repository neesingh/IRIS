function [ D ] = microns2diopters( c20, r )
% MICRONS2DIOPTERS does what's advertised
% For normalised Zernike coefficients, recommended in ANSI Z80.28, the sphere power is:
% sph = 4 sqrt(3) C2,0 / r^2. where r is the pupil radius in mm, and C2,0 is the (rms)
% amplitude of the Z20 Zernike mode in micrometers.
    
    %c20 = (D * r^2) / (4*sqrt(3))
    D = (4*sqrt(3) * c20) / r^2;
 
% Useful hints about astigmatism power by Alan Robinson:
% Power for the cylinder terms varies with azimuth
% S(0)  = +2 sqrt(6) C2,2 / RP2.      at 0 degrees
% S(90) = -2 sqrt(6) C2,2 / RP2.     at 90 degrees
% Peak-peak variation in power Scyl = 4 sqrt(6) C2,2/ RP2. This is what is normally referred to as the cylinder power.
% Similarly for the Z2-2 coefficient at 45 and 135 degrees.
% The Zernike distortions are orthogonal, so the net cylinder power is given by the root-sum-of-squares of the Z2-2  and Z2+2 coefficients.
% In typical ophthalmic practice, the reported cylinder term is asymmetric, corresponding to a lens with zero power in the reference axis.
% This is achieved by adding a sphere term with half the peak-peak power.
% The reported sphere distortion is adjusted by subtracting an equivalent value from the reported sphere power.

end


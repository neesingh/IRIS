function [psf_halfwidth, psf_bandwidth, psf_pix_halfwidth, cutoff_freq] = psf_scaling_factors(cf, r, lambda)
% Calculate physical scaling factors needed to make any sense out of the PSF
% This function is fundamental for the correct work of zernike2psf.m, which
% is the most fundamental core function of the IS.
% ARGUMENTS:
%   r [mm]
%   lambda [m]
%
        
        ui_defaults = getappdata(cf, 'ui_defaults');
        psf_multiplier = ui_defaults.psf_multiplier;    % multiplying factor for size of PSF, OTF relative to PF. Default = 2 = minimum value needed to see the entire OTF up to cutoff frequency 
                                                        % note: increasing psf_multiplier increases the bandwidth of OTF and increases spatial resolution of PSF 
                                                        % 1 is not recommended because it produces aliasing in OTF due to undersampling.
        
        reference_lambda = ui_defaults.reference_lambda * 1e-9;
        lambda_ratio = lambda/reference_lambda;
        pupil_bits = ui_defaults.pupil_bits;
        pupil_support = 2^(pupil_bits-1);
        
                                                        
        psf_pix_halfwidth = psf_multiplier * pupil_support;                                           
        
        psf_multiplier = psf_multiplier*lambda_ratio;   % accounts for wavelength changes  
                                                        % Required to correctly scale the MTF difraction reference in the spatial domain

        cutoff_freq = ((r*2E-3)/lambda)*(pi/180);       % optical cutoff frequency in cyc/deg for this pupil
                                                        % The reference point is in the frequency domain: cutoff spatial frequency = D/lambda [cycles/radian].  Multiplying by pi/180 simply changes units to cyc/deg.
                                                        % Because of the need to pad the pupil function with zeros, we need to distinguish between the optical cutoff frequency (which depends on the physical pupil)
                                                        % and the bandwidth of the OTF (which depends on the fully padded pupil function).
                                                
        psf_bandwidth = cutoff_freq*psf_multiplier/2;   % This is why “psf_multiplier" enters the calculations to determine the highest spatial frequency in the computed OTF, which is typically greater than the optical cutoff frequency.
                                                        % highest spatial frequency represented in 2-sided OTF = Nyquist freq.
    
        sampling_freq = 2*psf_bandwidth;                % sampling frequency = 2* Nyquist freq
        
        sampling_period = 1/(sampling_freq);            % The highest frequency in the computed OTF (in cyc/det) is then inverted to get the corresponding period (in deg), which is equal to the spatial resolution of the PSF. 

        psf_halfwidth = 60*sampling_period*psf_pix_halfwidth;
                                                        % Rresolution is the spatial position of the first point next to the origin in the PSF graph, and therefore is also the step size between neighboring points.
                                                        % I then multiply this resolution value by the number of points in the half-PSF to get the half-width of the PSF.
                                                        % The units are then converted to arcmin by multiplying by 60min/deg. 
                                                        
                                                        % It might have been more logical to do the full width=#pts * step size, but half-width is more conveneint for practical purposes because the normalized support mesh runs from -1 to +1.
                                                        % This is why you can put the computed PSF into physical units by multiplying the normalized support mesh by half-width in degrees.
        
        % fundamental_freq = bandwidth/psf_support;     % fundamental freq=freq. resolution
        
end

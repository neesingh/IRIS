function [ value ] = iqm_lib( a, s, ~ )
% iqm_lib - light-in-the-bucket is the ratio of total light energy within
%  the core area of Airy disk to the light in the core of a perfect system.
%  value should be between 0 and 1; value for diffraction-limited PSF is 1
%  zero is for the poorest optics.
% LNT 16May05. Discovered that the algorithm for finding the core of PSF
%   was completely wrong. Also noticed a small discrepancy with the
%   definition published in JOV2004. Should normalize by total intensity 
%   inside the mask, not coreIntensity. This change will also make the 
%   formula appropriate for polyPSFs.
%
% MJ May17 See 2004 Thibos et.al. Accuracy and Precision...
% LNT: In contrast to the Strehl Ratio, which depends only on the single pixel at the coordinate origin, and is unitless, LIB sums over some criterion area, which can be chosen by the user.
% I specified the dPSFcore as a reasonable choice for “the bucket”, but that isn’t necessarily the best choice for all applications.
% The down side is that the bucket size changes with pupil diameter, which for some applications may be seen as an up-side!
% Other users may prefer to use a bucket of fixed size, such as a cone aperture for example. There is no consensus on how large the bucket should be - it all depends on the application.

    diag = 0;

    roi = a.psf_crop_roi;                   % PSF stored in the structure is cropped to save memory. Other matrices are not, so...
    
    PSF = a.PSF_cropped;
    [~, cr, cc] = PSFcenter(PSF,[],0);
    
    x = a.psf_x * a.psf_halfwidth;
    y = a.psf_y * a.psf_halfwidth;
    
    airy_radius = 1.22*((a.lambda*1E-9)/(2*a.r*1E-3))*(180*60/pi);
    
    %DLcore = (x.^2 + y.^2) < airy_radius^2;
      
    dPSF = s.dPSF(:,:,a.lambda_idx);
    
    shift = [-floor(size(y,1)/2)+cr+roi(2,1), -floor(size(x,1)/2)+cc+roi(1,1)];
    
    %DLcore = circshift(DLcore, shift);
    %DLcore = crop_to_roi(DLcore, roi);
    
    dPSF = circshift(dPSF, shift);
    dPSF = crop_to_roi(dPSF, roi);
    
    DLcore = dPSF > 1E-2*max(dPSF(:)); % sanity check ok

    value = sum(sum(PSF.*DLcore)); %/Itotal;	%new formula 16May05
    
    if(a.step_id == 1 && diag == 1)
    
        f = gca;
        figure(202);
        subplot(1,2,1)
            imagesc(DLcore); axis square;
        subplot(1,2,2);
            imagesc(dPSF); %hold on
            %plot(cc, cr, 'r+'); hold off;
             axis square;

        axes(f);
        
    end
end
function [ value ] = iqm_isva( a, s, ~ )
% iqm_isva - Image Simulator's Visual Acuity (Decimal)
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
    
    mode = 'simple';
    %threshold = 0.735;         % As in Practical Astrophotography by Jeffrey R. Charles,
                                % and Optical Imaging Techniques in Cell Biology by Guy Cox
                               
        threshold = 0.600;

        if(strcmp(mode, 'simple'))     
            PSF_bin = a.PSF_cropped > threshold*max(a.PSF_cropped(:));
            area = sum(PSF_bin(:));
            theta = 2*sqrt(area/pi);

            theta = theta * a.psf_resolution;

            value =  1/theta;           % AVd  
        else
            
            
            roi = a.psf_crop_roi;

            PSF = a.PSF_cropped;
            nPSF= s.nPSF(:,:,a.lambda_idx).^2;
            
            th = threshold*max(PSF(:));

            [~, cr, cc] = PSFcenter(PSF,[],0);

            x = a.psf_x * a.psf_halfwidth;
            y = a.psf_y * a.psf_halfwidth;

            shift = [-floor(size(y,1)/2)+cr+roi(2,1), -floor(size(x,1)/2)+cc+roi(1,1)];

            nPSF = circshift(nPSF, shift);
            nPSF = crop_to_roi(nPSF, roi);
            
            nPSF = nPSF/max(nPSF(:));

            PSF = PSF'*nPSF;
            
            PSF_bin = PSF > th;
            area = sum(PSF_bin(:));
            theta = 2*sqrt(area/pi);

            theta = theta * a.psf_resolution;

            value =  1/theta;           % AVd  
        end
   
end


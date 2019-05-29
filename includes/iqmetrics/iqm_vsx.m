function [ value ] = iqm_vsx( a, s, ~ )
% iqm_vsx - Visual Strehl Ratio computed in space domain using Campbell & Green neural weighting function on the optical psf at the PSFcenter 
% Units aren't obvious, so normalize by DL case to make metric unitless.
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%


    
    %fi = 2*r*1E6;                                                       % [nm]
    %airy_support = out.psf_halfwidth * out.psf_y(:,1)*pi/(180*60);      % vector of sample points supporting PSF (radians)
    %airy_support = airy_support*(fi/lambda/1.22);                       % normalize by multiplying physical distance by cutoff frequency. 1st zero is at s=1.22
    %dPSF = somb2d(airy_support, airy_support);                          % get Airy disk and its support mesh
    %dPSF = dPSF.^2;                                                     % convert amplitude to intensity
    %dPSF = dPSF/sum(dPSF(:));    
    
    %fig = gca;
    roi = a.psf_crop_roi;
    
    PSF = a.PSF_cropped;
    nPSF= s.nPSF(:,:,a.lambda_idx);
    dPSF= s.dPSF(:,:,a.lambda_idx);                                      % should it be squared to get intensity?
    [~, cr, cc] = PSFcenter(PSF,[],0);
    
    x = a.psf_x * a.psf_halfwidth;
    y = a.psf_y * a.psf_halfwidth;
    
    shift = [-floor(size(y,1)/2)+cr+roi(2,1), -floor(size(x,1)/2)+cc+roi(1,1)];
    
    nPSF_shifted = circshift(nPSF, shift);
    nPSF_shifted = crop_to_roi(nPSF_shifted, roi);
    
    nom = nPSF_shifted'*PSF; nom = sum(nom(:));
    denom=nPSF'*dPSF;        denom = sum(denom(:));
    
    value = nom/denom;
    % visual strength normalized by visual strength for diffraction-limited optics using Campbell & Green psf 
    %value = (nPSF_shifted'*PSF) / (nPSF'*dPSF);                         % Larry's implementation. But this is not scalar!
  
    %figure(202);
    %subplot(1,2,1)
    %    imagesc(nPSF_shifted); axis square;
    %subplot(1,2,2);
    %    imagesc(PSF); hold on
    %    plot(cc, cr, 'r+'); hold off;
    %     axis square;
    %
    %axes(fig);
    
end
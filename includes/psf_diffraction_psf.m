function [ out ] = psf_diffraction_psf(cf, z, r, lambda, s)
%PSF_DIFFRACTION_PSF Calculate the diffraction-limited using one of several methods
% Also useful as a "dry run" of the zernike2psf.m to establish the scaling factors
%
% Adapted from Š 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009
% Larry Thibos, Indiana University by Matt Jaskulski, University of Murcia
%
% Adapted and developed by Matt Jaskulski, University of Murcia Š 2016
%

    ui_defaults = getappdata(cf, 'ui_defaults');

    out = zernike2psf(cf, 0*z, r, lambda, s);

    switch(ui_defaults.psf_diffraction_method)

        case 'somb' % Compute Airy disk on same spatial scale as returned by zernike2psf = basis for normalizing to abs. std.
            fi = 2*r*1E6;                                                       % [nm]
            airy_support = out.psf_halfwidth * out.psf_y(:,1)*pi/(180*60);      % vector of sample points supporting PSF (radians)
            airy_support = airy_support*(fi/lambda/1.22);                       % normalize by multiplying physical distance by cutoff frequency. 1st zero is at s=1.22
            dPSF = somb2d(airy_support, airy_support);                          % get Airy disk and its support mesh
            dPSF = dPSF.^2;                                                     % convert amplitude to intensity
            dPSF = dPSF/sum(dPSF(:));
            dOTF = fft2(dPSF);
            dOTF = fftshift(dOTF).*out.otf_mask;
            dOTF = dOTF/max(dOTF(:));

        case 'goodman' % As in Goodman, also as used in the DiffractionMTF.m of the FOC

            freq = out.psf_support*out.psf_bandwidth/out.cutoff_freq;
                                                                % scale frequencies so cutoff falls on edge of unit circle
            MTF = (2/pi)*(acos(freq) - freq.*sqrt(1-freq.^2));  % Goodman's formula for diffraction-limited MTF
            MTF = out.otf_mask.*MTF;                            % clear MTF for frequencies > cutoff
            PTF = zeros(size(out.psf_y));                       % phase = 0 for diffraction-limited system

            dOTF = MTF.*(cos(PTF) + 1i*sin(PTF));               % recombine complex spectrum
            dPSF = fftshift(ifft2(ifftshift(dOTF)));            % recompute PSF of altered OTF
            dPSF = dPSF/sum(dPSF(:));

        otherwise % In the FOC, running zernike2psf.m with Zernikes zeroed-out is the preferred method of calculating the dPSF. As a second choice, the somb2d method is used.
            dPSF = out.PSF;
            dOTF = out.OTF;
    end 
    
    out.PSF = dPSF;
    out.OTF = dOTF;
    
    if(s.diagnostic)
        fig = gcf;
        figure(floor(r*1e3+lambda));

        imagesc(real(dPSF)); axis square; title([ui_defaults.psf_diffraction_method, ' max: ', num2str(max(dPSF(:)))]);

        figure(fig);
    end

end
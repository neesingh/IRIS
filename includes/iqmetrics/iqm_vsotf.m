function [ value ] = iqm_vsotf( a, s, ~ )
% iqm_vsotf - volume under nCS-weighted OTF/ volume under nCS-weighted DL-OTF = Visual Strehl Ratio computed by OTF method. 
%   was conceived by LNT in mid-November, 2002 as variant of srotf and votf, that take neural contrast sensitivity into account.
%   The denominator of R(7) is the volume under the detection CSF for an observer with Campbell & Green's neural system and perfect
%   optics. Ideally, we would like to use the subject's own neural CS fn, if known. This metric is called "Visual Strehl".
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
% Note that for polychromatic OTFs, the diffraction-limited comparison is
% the monochromatic OTF computed for wavelength=lambda, pupil=PupilDia.

    %lambda = a.lambda * 1E-3;     % [um]
    %fi = a.r * 2E3;               % [um]
    
    dMTF = real(s.dOTF(:,:,a.lambda_idx));
    OTF = real(a.OTF);
    
    X = a.psf_x .* a.psf_bandwidth;
    Y = a.psf_y .* a.psf_bandwidth;
    
    CSF = ContrastSensitivityFunction(X, Y);
    
    
    % X,Y = support mesh for OTF (cyc/deg).
   % r=sqrt(X.^2+Y.^2);			% support matrix of radial frequencies
	%index=find(r <= 64);		% use only frequencies in the range 0-60c/d
	%SF=r(index);				% the spatial frequencies for which we need 
                                    % neural contrast sensitivity     
    
    %[~,~,~,CS,~]=getNeuralCSF(SF);	% get Campbell&Green neural CSF at nominated SFs
    
    % vol under product of surfaces is computed by inner product. 
    % Elemental base area is not needed since result is normalized
    nOTFv = CSF * OTF;	% volume under neurally-weighted OTF (= complex-valued CSF)
	nDLv  = CSF * dMTF;    % volume under neurally-weighted, DL-MTF
	%nOTFv = CSF'* OTF(index);	% volume under neurally-weighted OTF (= complex-valued CSF)
	%nDLv  = CSF'*dMTF(index);    % volume under neurally-weighted, DL-MTF
    
	value = sum(nOTFv(:)) / sum(nDLv(:));
    
    if(false)
    if(a.step_id == 4)
        f = gcf;
        pause(1);
        figure(200);

            subplot(2,2,1);
                imagesc(dMTF); axis square;
            subplot(2,2,2);
                imagesc(CSF); axis square;
            subplot(2,2,3);
                imagesc(OTF); axis square;
                
        pause(1);        
        set(0, 'currentfigure', f);
        pause(1);

        
    end
    end
    
    
end
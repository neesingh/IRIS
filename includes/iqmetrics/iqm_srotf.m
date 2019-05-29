function [ value ] = iqm_srotf( a, s, ~ )
% iqm_srotf - volume under OTF/ volume under diffraction-limited OTF = Strehl Ratio by OTF method
%   is the correct way to compute Strehl ratio in the frequency domain
%   based on central ordinate theorem.  A common error is to compute SR as
%   volume under MTF, but this is wrong in principle because MTF=|OTF|.  
%   This non-linear transformation destroys the Fourier-transform
%   relationship between PSF and OTF that is the basis of central ordinate
%   theorem, which in turn is the justification for computing SR in the
%   frequency domain.
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
% Note that for polychromatic OTFs, the diffraction-limited comparison is
% the monochromatic OTF computed for wavelength=lambda, pupil=PupilDia.
    
    % Larrys algorithm in FOC:
    % [f,MTF_1D, fx,fy,MTF_2D,fc] = DiffractionMTF(PupilDia,lambda,X(1,:),0); % use frequencies given by user
    % DLv = sum(MTF_2D(:));		% volume under diffraction-limited MTF and OTF
    % OTFv = sum(real(OTF(:)));	% imag(OTF) sums to zero because of conjugate symmetry
    % SROTF = OTFv/DLv; end % normalize OTF volume by DL volume to get Strehl(OTF)
    
    roi = a.psf_crop_roi;
    dMTFv = abs(s.dOTF(roi(2,1):roi(2,2), roi(1,1):roi(1,2)));
    OTFv  = real(a.OTF(roi(2,1):roi(2,2), roi(1,1):roi(1,2)));

    value = sum(OTFv(:))/sum(dMTFv(:));          % normalize OTF volume by DL volume to get Strehl(OTF)
    
end
function [ value ] = iqm_votf( a, ~, ~ )
% iqm_votf - volume under OTF/ volume under MTF
%   was conceived by LNT in August 2002 as a metric that would be
%   sensitive to spatial phase shifts.  It was	inspired by a measure
%   called "Bias" developed by Thibos & Levick (Exp. Brain Research,
%   58:1-10, 1985) for describing orientation bias in the receptive fields
%   of retinal ganglion cells. 
%
% a - structure of calculated data for a given wavelength, and pupil
% List all of the structure: >> fieldnames(s)
%
%    R(6) = VOTF: volume under OTF/ volume under MTF 
%	 R(7) = VSOTF: volume under nCS-weighted OTF/ volume under nCS-weighted DL-OTF
%         = Visual Strehl Ratio computed by OTF method. 
%    R(8) = VNOTF: volume under nCS-weighted OTF/ volume under nCS-weighted MTF 
%    R(9) = SRMTF: volume under MTF/ volume under diffraction-limited MTF 
%         = Strehl Ratio by MTF method.  Note that Strehl ratio computed by 
%           MTF method = SR for a hypothetical PSF computed assuming PTF=0
% 	 R(10) = VSMTF: visual Strehl ratio computed by MTF method.  This is VSR for a
%           hypothetical PSF computed assuming PTF = 0.
%  DLnorm = the diffraction-limited normalizations. To un-normalize the
%    metrics, multiply Y.*DLnorm  This may be useful when comparing pupils 
%    of different sizes.
%	RI_MTF = uniformly-spaced spatial-frequency (cyc/deg) row-vector for WI_MTF
%   WI_MTF = radial average MTF interpolated onto sampling points RI_MTF
%   WI_OTF = radial average OTF interpolated onto sampling points RI_MTF
%   CSF - the predicted contrast sensitivity function
%   sfCSF - the vector of spatial frequencies (cyc/deg) supporting CSF
%
% Note that for polychromatic OTFs, the diffraction-limited comparison is
% the monochromatic OTF computed for wavelength=lambda, pupil=PupilDia.

    roi = a.psf_crop_roi;
    
    OTFv = real(a.OTF(roi(2,1):roi(2,2), roi(1,1):roi(1,2)));
    MTFv = abs (a.OTF(roi(2,1):roi(2,2), roi(1,1):roi(1,2)));

    value = sum(OTFv(:))/sum(MTFv(:));          % normalize OTF volume by MTF volume to get new metric
    
end
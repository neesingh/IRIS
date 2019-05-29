function [ value ] = iqm_foc_PSF( a, args, ~ )
% iqm_foc_PSF -  a wrapper for FOC's image quality metrics calculating
% scripts. It is calculating only one at the time, which is pretty
% inefficient... a thing to improve.
%
    lambda = a.lambda * 1E-3;     % [um]
    fi = a.r * 2E3;               % [um]
    which = args;
    
    doit = zeros(11,1); doit(which) = 1;
    value = PSFMetrics(a.PSF, a.psf_x, a.psf_y, fi, lambda, 0, 0, doit, 0);
    
    value = value(which);
    
end


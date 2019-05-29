function [ value ] = iqm_foc_OTF( a, args, ~ )
% iqm_foc_OTF - a wrapper for FOC's image quality metrics calculating
% scripts. It is calculating only one at the time, which is pretty
% inefficient... a thing to improve.
%
    lambda = a.lambda * 1E-3;     % [um]
    fi = a.r * 2E3;               % [um]
    which = args;
    
    doit = zeros(10,1); doit(which) = 1;
    value = OTFMetrics(a.OTF, a.psf_x, a.psf_y, fi, lambda, 0, doit, 1);
    
    value = value(which);
    
end


function [ value ] = iqm_foc_Wave( a, args, ~ )
% iqm_foc_Wave - a wrapper for FOC's image quality metrics calculating
% scripts. It is calculating only one at the time, which is pretty
% inefficient... a thing to improve.
%
    lambda = a.lambda * 1E-3;     % [um]
    which = args;
    
    pf_x = a.pf_x * a.r;
    pf_y = a.pf_y * a.r;
    
    radius = [0:0.05:1];    % normalilzed radius values for interpolation in WaveMetrics
                            % seems clumsy, arbitrary step?
    radius = radius * a.r;
    
    doit = zeros(10,1); doit(which) = 1;
    value = WaveMetrics(a.Wxy, pf_x, pf_y, a.Axy, radius, lambda, doit, a.Axy, 0);
    % I'm passing here the A100 and A90 boolean matrices even though Axy is
    % the real pupil that takes into account the SCE and pupil masking.
    
    value = value(which);
    
end


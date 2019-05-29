function [ D ] = lca_defocus( lambda, reflambda, r )
%
% [ D ] = lca_defocus( lambda, reflambda, r )
%
%   pupil_radius [mm]
%   lambda [nm]
%   D [um]
%
% Author: M. Jaskulski, Universidad de Murcia, mateusz.jaskulski@gmail.com.
% PolyPSF 2014

    reflambda = reflambda/1e3;
    lambda = lambda/1e3; % formula requires lambda in [um]
    
    D = -0.63346*(1/(reflambda-0.2141) - 1/(lambda-0.2141));
    
    if nargin > 2
        D = (D * r^2) / (4*sqrt(3));
    end

    % eye emmetropic to green, +defocus for blue, -defocus for red
    
end


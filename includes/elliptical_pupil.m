function [ ellipse ] = elliptical_pupil( x, y, angle, ellipticity)
% ELLIPTICAL_PUPIL spin a pretty pupil over the xy meshgrids
% angle [deg]
% ratio = a/b ratio = 1 - circular pupil
%
% this ellipse needs an ellipse <= 1 to be useful.
%
    th = -angle * pi/180;
    a = 1;
    b = a*(1-min(0.95, ellipticity));

    a2 = a^2; b2 = b^2;

    sinth = sin(th); costh = cos(th);
    sin2th = sinth^2; cos2th = costh^2;

    ellipse = (cos2th/a2 + sin2th/b2)*(x.^2) - 2*costh*sinth*(1/a2 - 1/b2)*(x.*y) + (sin2th/a2 + cos2th/b2)*(y.^2);

end


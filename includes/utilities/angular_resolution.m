function [ theta, AVd, logMAR ] = angular_resolution( r, lambda, criterion )
%ANGULAR_RESOLUTION
% IN:
% r [mm]
% lambda [nm]
% criterion - rayleigh/
% OUT:
% theta [arcmin]

% Rayleigh limit: 1.22, Dawes Limit: 1.025, Sparrow's Limit: 0.94.

% For a perfect optic the Rayleigh limit suggests about a 28% drop in contrast differential between two Airy Disks,
% 5 percent at the Dawes Limit and 0% at Sparrow's limit. An MTF of zero between Airy disks is one of the formal definitions of the Sparrow limit.
% "Airy Disk" is a mathematically derived theoretical term only (as strictly applied).
% "Spurious disk", on the other hand, is that portion of the theoretically derived Airy disk as seen visually through an actual optic.

% The Abbe Limit: 1)Also know as the "Diffraction Limit", the Abbe limit was developed by Ernst Abbe in 1873.
% The formula for microscopes is 0.5l/NA which translates to 113/D = resolution arcmins for telescopes, putting it between the Dawes and Sparrow limits.

% Notes about the Rayleigh Limit: This is the "gold standard" of optical resolution, in wide use throughout professional optical science.
% It was derived entirely mathematically with experimental confirmation by John William Strutt (the Lord Rayleigh) in 1896.
% Rayleigh was a genius level physicist and mathematician and was a Nobel Prize winner as well.
% The Rayleigh Limit is based upon the performance of an optic delivering an 0.82 strehl at the focal plane,
% the so-called "diffraction limited" standard of an optic meeting the minimum aberration requirements for
% spherical aberration defined by the Rayleigh Criteria (an optical construction standard) .

% Notes about the Dawes Limit: The Dawes limit particularly is considered empirical, not only from the way it was derived in the first place (by observation),
% but also by virtue of the fact that it de facto assumes a contrast threshold for the human eye (on bright high contrast objects of equal brilliance) to be 5%.
% Of course, on an individual basis, the contrast threshold of the eye will vary. So, in a given optic, one person, with exceptional contrast sensitivity,
% might be able to detect a Dawes limit separation - while another, with less than average contrast sensitivity, would not.
% Only in use by the amateur astronomy community, Dawes Limit represents a good empirical limit on double star resolution for amateur telescopes of high quality.

% Notes about the Sparrow limit: as the Sparrow limit is defined by a zero contrast differential, and contrast differential is required for any resolution to take place,
% it follows that the Sparrow limit is not a resolution limit at all but rather a *non*-resolution limit, a point above which resolution first becomes theoretically possible
% and *at* which it is impossible.
% A simple web search will show that the Sparrow limit is most commonly used in the context of microscopy rather than astronomy - at least on a professional level.
% It has also come into some vogue in amateur astronomy circles, rather inexplicably I'm afraid, as considering the ever present contribution of the atmosphere to
% astronomical observation, any limit less than dawes becomes de facto an exercise in simple wishful thinking.

    if(nargin < 3),
        criterion = 'rayleigh';
    end;
    
    switch criterion
        case 'dawes'
            coeff = 1.025;
        case 'sparrow'
            coeff = 0.94;
        otherwise
            coeff = 1.22;
    end

    fi = 2*r/1e3;
    lambda = lambda/1e9;
    
    theta = coeff * lambda/fi;  % [rad]
    theta = theta * 180/pi;     % [deg]
    theta = theta*60;           % [arcmin]
    AVd = 1/theta;
    logMAR = log10(theta);


end


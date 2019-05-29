function [Vr, Vt] = wavefront2vergence(Wxy, Axy, r, removeMeanSlope)
% Wxy pupil should be marked by NaN
    if(nargin < 4)
        removeMeanSlope = 0;
    end

    Wxy(Axy == 0) = NaN;

    [Sx, Sy] = wavefront2slope(Wxy, r);

    if(removeMeanSlope)
        mSx = mean(Sx(~isnan(Sx)));
        mSy = mean(Sy(~isnan(Sy)));

        Sx = Sx - mSx;
        Sy = Sy - mSy;
    end

    [Vr, Vt] = slope2vergence(Sx, Sy, r);

    function [Sx, Sy] = wavefront2slope(Wxy, r)
    % Wxy pupil should be marked by NaN

        Axy = ~isnan(Wxy);

        evenOdd = ~mod(size(Wxy, 1), 2); % 1 even 0 odd
        v = floor(size(Wxy, 1) / 2);

        v = (-v:1:v-evenOdd)/v;
        [x, y] = meshgrid(v);           % Normalized meshgrid

        xr = x*r;
        yr = y*r;

        [row, col] = size(xr);				% this should be true for all input matrices
        xc = round(row/2);                  % go to center of function to get step size
        yc = round(col/2);
        xstep = xr(xc,1+yc) - xr(xc,yc);	% x-distance between sample points in pupil, in mm
        ystep = yr(1+xc,yc) - yr(xc,yc);	% y-distance between sample points in pupil, in mm

        % Gradient gives transverse aberration, in microns/mm = milliradians
        % sign convention: T>0 => wavefront points towards z-axis 
        [Sx, Sy] = gradient(Wxy, xstep, ystep);
        Sx(Axy==0) = NaN;
        Sy(Axy==0) = NaN;

    end

    function [Vr, Vt] = slope2vergence(Sx, Sy, r)
    % slope2Vergence - Convert Cartesian slope maps to polar (radial, tangential) slope maps
    % Inputs:
    %   r:                     scalar radius of pupil in mm
    %   Sx:                    matrix of wavefront x-slopes inside pupil (mrad)
    %   Sy:                    matrix of wavefront y-slopes inside pupil (mrad)
    %
    % Note: missing data should be coded as NaNs before calling this program.
    %
    % Outputs:
    %   radVergence:           radial vergence inside pupil (D)
    %   tanVergence:           tangential vergence inside pupil (D)
    %
    %  First remove paraxial prism as prescribed by Nam et al 2009. [Nam, J.,
    %  L. N. Thibos and D. R. Iskander (2009). "Zernike radial slope polynomials
    %  for wavefront reconstruction and refraction." J Opt Soc Am A Opt Image
    %  Sci Vis 26(4): 1035-1048]. The rationale is that the measurement axis  
    %  should coincide with the chief ray (per ANSI Z80.28 standard) and 
    %  therefore any wavefront will have zero slope at the pupil center. 
    %  For example, a tilted plane wave produced by an aberration-free prism 
    %  should have zero vergence at the pupil center.
    %  Existing program pointWavefront.m is not useful here because the goal is
    %  to compute vergence from slope maps, not wavefront phase maps. Instead,
    %  simply subtract the paraxial slopes from the slope matrices. It is OK
    %  that dvx_pupil changes since the original values have been saved.

        evenOdd = ~mod(size(Sx, 1), 2); % 1 even 0 odd
        v = floor(size(Sx, 1) / 2);

        v = (-v:1:v-evenOdd)/v;
        [x, y] = meshgrid(v);           % Normalized meshgrid

        %n = size(Sx, 1)/2;
        %[x, y] = meshgrid((-n : 1 : n-1)/n);

        normR = sqrt(x.^2 + y.^2);      % normalized radial distance of each sample

        paraxialMask = normR <= 0.25;   % a boolean paraxial pupil
        middleMask = normR > 0.25;
        middleMask(normR >= 0.30) = 0;
        outerMask = (normR) >= 1;
        normR(normR == 0) = NaN;         % replace r = 0 (pupil center) with NaN

        mean_dX = mean(Sx(paraxialMask));
        mean_dY = mean(Sy(paraxialMask));
        Sx = Sx - mean_dX;              % make the correction
        Sy = Sy - mean_dY;              % make the correction

        % Compute radial and tengential slopes from x= & y-slopes using formula in 
        % [Nam, J., L. N. Thibos and D. R. Iskander (2009). "Describing ocular
        % aberrations with wavefront vergence maps." Clin Exp Optom 92(3): 194-205] 
        [TH, ~] = cart2pol(x,y);        % convert pupil mesh to polar coordinates
        dR = Sx.*cos(TH)+Sy.*sin(TH);   % radial slope
        dT = -Sx.*sin(TH)+Sy.*cos(TH);  % tangential slope

        % Compute vergence by diving slope by radial distance from pupil center
        % Vergence units are mrad/mm = diopters, so need to convert normalized
        % pupil coordinates back to physical mm
        Vr = - dR./(normR * r);  % radial wavefront vergence 
        Vt = dT./(normR * r);    % tangential wavefront vergence 

        middleVr = Vr(middleMask);
        middleVr(isnan(middleVr)) = 0;
        middleVr = mean(middleVr(:));
        Vr(paraxialMask) = middleVr;

        middleVt = Vt(middleMask);
        middleVt(isnan(middleVt)) = 0;
        middleVt = mean(middleVt(:));
        Vt(paraxialMask) = middleVt;

        Vr(outerMask) = NaN;
        Vt(outerMask) = NaN; 

    end
    
end
function [radVergence,tanVergence,radVerPlot,tanVerPlot]=slope2vergence(pupilX,pupilY,...
    pupilRadmm,dX,dY,figHandle)
% convert Cartesian slope maps to polar (radial, tangential) slope maps
%
% Syntax: [radVergence,tanVergence]=slope2vergence(pupilX,pupilY,...
%    pupilRadmm,dX,dY,figHandle);
%
% Inputs:
%   pupilX, pupilY:        meshgrid of normalized, relative pupil locations
%   pupilRadmm:            scalar radius of pupil in mm
%   dX:                    matrix of wavefront x-slopes inside pupil (mrad)
%   dY:                    matrix of wavefront y-slopes inside pupil (mrad)
%   figHandle:             figure handle for showing the data (optional)
%
% Note: missing data should be coded as NaNs before calling this program.
%
% Outputs:
%   radVergence:           radial vergence inside pupil (D)
%   tanVergence:           tangential vergence inside pupil (D)
%   radVerPlot:            radVergence with paraxial values set to NaNs
%   tanVerPlot:            tanVergence with paraxial values set to NaNs
%
% LNT 27Feb2017ß  Codes extracted from COASviewer to modularize routines

%% initialize
if nargin<6 || isempty(figHandle), showit=false; else showit=true; end

%% Use pupil data to compute vergence maps 
% First remove paraxial prism as prescribed by Nam et al 2009. [Nam, J.,
%  L. N. Thibos and D. R. Iskander (2009). "Zernike radial slope polynomials
%  for wavefront reconstruction and refraction." J Opt Soc Am A Opt Image
%  Sci Vis 26(4): 1035-1048]. The rationale is that the measurement axis  
%  should coincide with the chief ray (per ANSI Z80.28 standard) and 
%  therefore any wavefront will have zero slope at the pupil center. 
%  For example, a tilted plane wave produced by an aberration-free prism 
%  should have zero vergence at the pupil center.
% Existing program pointWavefront.m is not useful here because the goal is
%  to compute vergence from slope maps, not wavefront phase maps. Instead,
%  simply subtract the paraxial slopes from the slope matrices. It is OK
%  that dvx_pupil changes since the original values have been saved.
normR = sqrt(pupilX.^2 + pupilY.^2);  % normalized radial distance of each sample
pupilMask=(normR) <= 1;     % a boolean pupil
paraxialMask=(normR) <= 0.05;     % a boolean paraxial pupil
badXslopeMask = isnan(pupilX); % COAS may reject central data due to reflections
badYslopeMask = isnan(pupilY);
mean_dX = mean(dX(paraxialMask & ~badXslopeMask));
mean_dY = mean(dY(paraxialMask & ~badXslopeMask));
dX = dX - mean_dX;  % make the correction
dY = dY - mean_dY; % make the correction

% Compute radial and tengential slopes from x= & y-slopes using formula in 
% [Nam, J., L. N. Thibos and D. R. Iskander (2009). "Describing ocular
% aberrations with wavefront vergence maps." Clin Exp Optom 92(3): 194-205] 
[TH,R] = cart2pol(pupilX,pupilY);  % convert pupil mesh to polar coordinates
dR = dX.*cos(TH)+dY.*sin(TH); %radial slope
dT = -dX.*sin(TH)+dY.*cos(TH); % tangential slope

% Another pre-correction: it is better to plot a NaN than inf
normRR = normR; 
normRR(find(normRR==0)) = NaN;  %replace r=0 (pupil center) with NaN

% Compute vergence by diving slope by radial distance from pupil center
% Vergence units are mrad/mm = diopters, so need to convert normalized
% pupil coordinates back to physical mm
radVergence = dR./(normRR*pupilRadmm);  % radial wavefront vergence 
tanVergence = dT./(normRR*pupilRadmm);  % tangential wavefront vergence 
xVergence = dX./(normRR*pupilRadmm);    % horizontal vergence $$$$$$  RETHINK THIS DEF! 
yVergence = dY./(normRR*pupilRadmm);    % vertical vergence


% Graphics in clinician's view, centered on pupil. Suppress paraxial values
radVerPlot = radVergence; % a copy to play with
radVerPlot(paraxialMask)=NaN; % suppress paraxial data to keep colorbar useful
tanVerPlot = tanVergence; 
tanVerPlot(paraxialMask)=NaN;
if showit
    figure(figHandle);  
%     figHandle.Name = 'Vergence maps';
    subplot(1,2,1)
    imagesc(pupilRadmm*pupilX(1,:), pupilRadmm*pupilY(:,1), radVerPlot) 
    colormap jet, colorbar, axis xy, axis square  
    title('Radial vergence (D)')
    xlabel('Pupil x-coordinate (mm)')
    ylabel('Pupil y-coordinate (mm)')

    subplot(1,2,2)
    imagesc(pupilRadmm*pupilX(1,:), pupilRadmm*pupilY(:,1), tanVerPlot) 
    colormap jet, colorbar, axis xy, axis square  
    title('Tangential vergence (D)')
    xlabel('Pupil x-coordinate (mm)')
    ylabel('Pupil y-coordinate (mm)')
end
% I'm not sure how to define or interpret horizontal & vertical components
%  so leave them out for now.
% subplot(2,2,3)
% imagesc(pupilRadmm*normX(1,:), pupilRadmm*normY(:,1), xVergence) 
% colormap jet, colorbar, axis xy, axis square  
% title('Horizontal vergence (D)')
% xlabel('Pupil x-coordinate (mm)')
% ylabel('Pupil y-coordinate (mm)')
% 
% subplot(2,2,4)
% imagesc(pupilRadmm*normX(1,:), pupilRadmm*normY(:,1), xVergence) 
% colormap jet, colorbar, axis xy, axis square  
% title('Vertical vergence (D)')
% xlabel('Pupil x-coordinate (mm)')
% ylabel('Pupil y-coordinate (mm)')



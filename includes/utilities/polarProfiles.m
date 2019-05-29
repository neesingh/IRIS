function [radData,merData,regstats]=polarProfiles(X,Y,Z,maxRadius,thetaN,radiusN,...
    figHandle, fitline)
% Show average radial and meridional profiles of Z(X,Y)
%
% This utility summarizes 2-D functions like MTF, PSF, WFE, pupil function,
%  or visual field plots as 1-D functions averaged over meridian or radius/
%  eccentricity. 

% Syntax:  [radData,merData,regstats]=polarProfiles(X,Y,Z,maxRadius,thetaN,...
%    radiusN,figHandle, fitline);
% Inputs:
%   (X,Y) = Cartesian support mesh for function Z(X,Y)
%   Z = matrix of values associated with each X,Y sample point
%   maxRadius = maximum radius to be used for computing profiles
%   thetaN = number of bins for discretizing theta
%   radiusN = number of bins for discretizing radius
%   figHandle = optional figure handle for making the graphs
%   fitline = flag to fit line to radialVergence profile (default= true)
%   
% Outputs:
%   radData = matrix of 4 rows used to show radial profiles
%       col 1 = radius sample points
%       col 2 = radial profile, averaged over meridian (a dt measure)
%       col 3 = sem for points in col 2
%       col 4 = radial profile, summed over meridian (a r*dt measure)
%   merData = matrix of 4 rows used to show meridional profiles
%       col 1 = angular sample points
%       col 2 = meridional profile, averaged over radius (a dt measure)
%       col 3 = sem for points in col 2
%       col 4 = meridional profile, summed over radius (a r*dt measure)
%   regstats = [b, bint] returned by regress. 
%               b = vector of regression coeffs
%               bint = matrix of 95% confidence intervals for b
%
% LNT 01FEB2017:  based on test_cart2polMap, a script to test cart2polMap
% LNT 28Feb2017:  move code here to do regression on radial profile

%% initialize
if nargin<8 || isempty(fitline), fitline = false; end  
if nargin<7 || isempty(figHandle), showit=false; else showit=true; end
if nargin<6, radiusN = 10; end  % let experience be the guide
if nargin<5, thetaN = 10; end

R = sqrt(X.^2+Y.^2); % matrix of radial distances in (X,Y)
mask = R<=maxRadius;  % a boolean validity mask
mask2 = R>0.8*maxRadius; 
marginalMask = mask & mask2; % isolate marginal points

if false  % diagnostic
    figure
    surf(X,Y,Z)  % show the original function
end

% get the Cartesian to Polar mapping (use default binning)
[theMAP,theta_nodes,radius_nodes]=cart2polMap(X,Y,Z,mask,thetaN,radiusN);
x = theMAP(:,1); % valid data, vectorized
y = theMAP(:,2);
z = theMAP(:,3);     

% repeat for the marginal mask
[theMAP2,theta_nodes2,radius_nodes2]=cart2polMap(X,Y,Z,marginalMask,thetaN,radiusN);
x2 = theMAP2(:,1); % valid data, vectorized
y2 = theMAP2(:,2);
z2 = theMAP2(:,3);     

if false  % diagnostic
    figure; subplot(1,2,1)
    plot3(x,y,z,'k.'), view(0,90), axis square, title ('All samples')
    subplot(1,2,2)
    plot3(x2,y2,z2,'k.'), view(0,90), axis square, title('Marginal samples')
end
%% pool meridians to get a "radial average" graph Z(r)
% Note: this common terminology can be confusing because the averaging is
%  over meridian, not radius.
% Plotting vergence as a function of radius^2 makes it easy to visually
%  inspect paraxial power (y-intercept) and spherical aberration (slope)
for k=1:length(radius_nodes)
   % find the rows in theMAP that map to each radius node
   idx = find(theMAP(:,7)==k); 
   ZradAve(k) = mean(z(idx));      % do the stats
   ZradSem(k) = sum(z(idx));
   ZradSum(k) = sum(z(idx));      
end
%radData = [radius_nodes', ZradAve', ZradSem', ZradSum'];  % return to user
radData = [radius_nodes; ZradAve; ZradSem; ZradSum];  % return to user

if showit
    figure(figHandle)   
    subplot(1,2,1)
    errorbar(radius_nodes.^2,ZradAve, ZradSem,'bo')
    xlabel('Squared radial distance (mm^2)')
    ylabel('Average Radial Profile')
    legend('Mean ± sem')
    title('Radial Profile (averaged over meridian)')
end


%% pool radii to get a "meridian average" graph Z(theta)
% Note: this common terminology can be confusing because the averaging is
%  over radius, not meridian.  This graph can be difficult to interpret
%  when SA is strong.  May be better to show a marginal profile?
for k=1:length(theta_nodes)
   % find the rows in theMAP that map to each meridian node
   idx = find(theMAP(:,6)==k); 
   ZmerAve(k) = mean(z(idx));      % do the stats
   ZmerSem(k) = sum(z(idx));
   ZmerSum(k) = sum(z(idx));      
end
%merData = [theta_nodes',ZmerAve', ZmerSem', ZmerSum'];  % return to user

% repeat for the marginal data
for k=1:length(theta_nodes2)
   % find the rows in theMAP that map to each meridian node
   idx = find(theMAP2(:,6)==k); 
   ZmerAve2(k) = mean(z2(idx));      % do the stats
   ZmerSem2(k) = sum(z2(idx));
   ZmerSum2(k) = sum(z2(idx));      
end
merData = [theta_nodes; theta_nodes2; ZmerAve; ZmerAve2; ZmerSem; ZmerSem2; ZmerSum];  % return to user

if showit
    subplot(1,2,2)
    errorbar(theta_nodes*180/pi(),ZmerAve, ZmerSem,'bo-')
    xlabel('Meridional angle (deg)')
    ylabel('Average Meridional Profile')
    title('Meridional Profile (averaged over radius)')
    hold on
    errorbar(theta_nodes2*180/pi(),ZmerAve2, ZmerSem2,'r^-')
    legend('Mean ± sem', 'Marginal profile')
end

if fitline
    x= radData(:,1).^2;  % square the radius values
    Xdat = [ones(size(x)) x];
    y = radData(:,2);
    [b, bint] = regress(y,Xdat);  % a least squares fit
    yFit = b(1) + b(2)*x;
    subplot(1,2,1), hold on
    plot(x,yFit,'r-')
    regstats = [b, bint];
else
    regstats = [];
end

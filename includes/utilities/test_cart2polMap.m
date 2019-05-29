% test_cart2polMap - a script to test cart2polMap
% LNT 01FEB2017

clear variables, close all

[X,Y] = meshgrid(-1:0.1:1);
R = sqrt(X.^2+Y.^2); % the unit circle
mask = R<=1;  % a boolean validity mask
Z = X.^2+Y.^2;  % fake data
figure
surf(X,Y,Z)  % show the function

% get the Cartesian to Polar map (use default binning)
[theMAP,theta_nodes,radius_nodes]=cart2polMap(X,Y,Z,mask);%,edgesTH,edgesR)

x = theMAP(:,1); % valid data, vectorized
y = theMAP(:,2);
z = theMAP(:,3);     


%% pool meridians to get a "radial average" graph Z(r)
% Note: this common terminology can be confusing because the averaging is
%  over meridian, not radius.
for k=1:length(radius_nodes)
   % find the rows in theMAP that map to each radius node
   idx = find(theMAP(:,7)==k); 
   ZradAve(k) = mean(z(idx));      % do the stats
   ZradSem(k) = sem(z(idx));
   ZradSum(k) = sum(z(idx));      
end

figure
errorbar(radius_nodes,ZradAve, ZradSem,'bo-')
xlabel('Radial distance')
ylabel('Average Radial Profile')
legend('Mean ± sem')
title('Radial Profile (averaged over meridian)')

%% pool radii to get a "meridian average" graph Z(r)
% Note: this common terminology can be confusing because the averaging is
%  over radius, not meridian.
for k=1:length(theta_nodes)
   % find the rows in theMAP that map to each meridian node
   idx = find(theMAP(:,6)==k); 
   ZmerAve(k) = mean(z(idx));      % do the stats
   ZmerSem(k) = sem(z(idx));
   ZmerSum(k) = sum(z(idx));      
end

figure
errorbar(theta_nodes*180/pi(),ZmerAve, ZmerSem,'bo-')
xlabel('Meridional angle')
ylabel('Average Meridional Profile (deg)')
legend('Mean ± sem')
title('Meridional Profile (averaged over radius)')


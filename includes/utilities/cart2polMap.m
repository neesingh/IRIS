function [theMAP,theta_nodes,radius_nodes]=cart2polMap(X,Y,Z,mask,edgesTH,edgesR)
% Map cartesian (x,y) coordinates to nodes in a polar grid
% This program converts from Cartesian to polar coordinates and then 
%   discretizes the polar coordinates into the nearest polar node.
% The returned mapping from cartesian to polar nodes will enable the
%  calling program to assign Z(x,y) values into Z(TH,R) values for summing
%  or averaging to produce 1-D radial and meridional profiles Z(r), Z(th).
% This is useful for summarizing 2-D functions like MTF, PSF, WFE, pupil
%  function, or visual field plots as 1-D functions of meridian or radius/
%  eccentricity. 
%
% Syntax: [theMAP,theta_nodes,radius_nodes]=cart2polMap(X,Y,Z,mask,edgesTH,edgesR)
%
% Inputs:
%   (X,Y) = mesh support for some function Z(X,Y)
%   Z = real or complex-valued function of (x,y)
%   mask = boolean mask to select valid (X,Y) locations
%   edgesTH = vector of bin edges (or # of bins) for discretizing theta
%   edgesR = vector of bin edges (or # of bins) for discretizing radius
%
% Outputs:
%   theMAP = matrix of 4 columns
%       col 1 = valid X coordinates (vectorized)
%       col 2 = valid Y coordinates
%       col 3 = valid Z coordinates
%       col 4 = vectorized theta coordinates for (X,Y)
%       col 5 = vectorized radius coordinates for (X,Y)
%       col 6 = index into theta_nodes for (X,Y)
%       col 7 = index into radius_nodes for (X,Y)
%   
%   theta_nodes = vector of angles indexed in col 5 of theMAP
%   radius_nodes = vector of radial distances indexed in col 6 of theMAP
%
% LNT 01FEB2017.  A long-overdue utility!

%% Begin by eliminating invalid data, then convert to polar coordinates
X = X(mask);
Y = Y(mask);
Z = Z(mask);
idx = find(~isnan(Z));
X = X(idx); Y=Y(idx); Z=Z(idx); % omit points where Z is undefined.
[theta,radius] = cart2pol(X,Y); % polar coordinates of every point in (X,Y)
theMAP = [X,Y,Z,theta,radius];  % the first 5 columns of the map

%% discretize theta values

% first, set up the theta nodes
if nargin<5 || isempty(edgesTH)
  x = (0:19)*pi/10+pi/20;  % default is 20 steps from 0 to 2pi 
else
  if length(edgesTH)==1,
    N=edgesTH;  % user supplied N, the number of bins
    x = (0:N-1)*2*pi/N + pi/N; 
  else
    x = sort(rem(edgesTH(:)',2*pi)); % user supplied a vector of bin edges
  end
end

edges = sort(rem([(x(2:end)+x(1:end-1))/2 (x(end)+x(1)+2*pi)/2],2*pi));
edges = [edges edges(1)+2*pi];
nn = histcounts(rem(theta+2*pi-edges(1),2*pi),edges-edges(1)); % bin counts (diagnostic)
% Keep track of bin number assigned to each element of theta
theta_index = discretize(rem(theta+2*pi-edges(1),2*pi),edges-edges(1));
theMAP = [theMAP, theta_index(:)]; % append theta index to the map
theta_nodes = edges(1:end-1)+(edges(2)-edges(1))/2;  % polar nodes for theta (centered)

%% discretize radius values

% first, set up the radius nodes
if nargin<6 || isempty(edgesR)
  x = linspace(min(radius(:)),max(radius(:)),20); % default is 20 steps over the range of radius values
else
  if length(edgesR)==1,
    N=edgesR;  % user supplied N, the number of bins
    x = linspace(min(radius(:)),max(radius),N); 
  else
    x = sort(edgesR); % user supplied a vector of bin edges
  end
end

edges = x;
nn = histcounts(rem(radius+2*pi-edges(1),2*pi),edges-edges(1)); % bin counts (diagnostic)
% Keep track of bin number assigned to each element of theta
radius_index = discretize(radius,edges-edges(1));
theMAP = [theMAP, radius_index(:)]; % append radius index to the map
radius_nodes = edges+(edges(2)-edges(1))/2;  % polar nodes for radius (centered)




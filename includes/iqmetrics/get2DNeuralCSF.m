function [zi,xi,yi]=get2DNeuralCSF(r)
% get a radially symmetric, 2-dimensional neural contrast sensitivity function 
%
% syntax: [zi,xi,yi]=get2DNeuralCSF(r);
% for demo, type get2DNeuralCSF;
% 
% input: 
%	r = vector of positve spatial frequencies required (cyc/deg), including
%       zero (r(1)) and the highest frequency (r(end)).
%   OR the fx matrix of the desired [fx,fy] plaid mesh
%
% output:
%	zi = values of the neural CSF, centered (i.e. DC in center of matrix)
%	xi,yi  = mesh grid of spatial frequencies that supports z
%
% Note: use Q=ifftshift(zi); to make DC term = Q(1,1)
%
% LNT 26jun05

showit=0;
% get a standard CSF with 1 c/d freq. resolution  
[p1,Spoly1,SF,CS,Thresh]=getNeuralCSF(0:64);	
sf = [SF(1:end-1),fliplr(-SF(2:end))];	% make support two-sided; DC=cs(1)
sf2 = fftshift(sf); % should be -64:63
[x,y] = meshgrid(sf2);  % a plaid mesh with signed frequencies
radialFreq = sqrt(x.^2+y.^2);	% the radial frequency grid
cs2D = interp1(SF,CS,radialFreq); % matlab cleverly returns a square matrix 

 if nargin==0
    if showit
        surf(x,y,cs2D)
        xlabel('x spatial frequency'); ylabel('y spatial frequency')
        zlabel('Contrast Sensitivity'); title('Campbell & Green CSF')
    end
    zi=cs2D;
    idx = find(isnan(zi));
    zi(idx) = 0; % replace NaNs with zeros
    xi=x;
    yi=y;
    return
 end

% make support mesh from given vector of radial frequencies
if isvector(r)
    rf = [r(1:end-1),fliplr(-r(2:end))]; % make support two-sided; DC=rf(1)
    rf = fftshift(rf);          % put DC in the center
else
    rf = r(1,:);    % extract first row of the supplied fx matrix
end
[xi,yi] = meshgrid(rf);  % a plaid mesh of points to be interpolated
zi = interp2(x,y,cs2D,xi,yi);
idx = find(isnan(zi));
zi(idx) = 0; % replace NaNs with zeros

%diagnostic
%figure; surf(xi,yi,zi);  



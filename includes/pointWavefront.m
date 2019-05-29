function [Wxyz, ZcPrism] = pointWavefront(Wxy,xp,yp)
%pointWavefront - rotate a wavefront so chief ray = z-axis
% This program was created to satisfy the ANSI standard requiring the 
%   chief ray to be the reference z-axis. Method is to point the wavefront
%   correctly by finding the paraxial prism values and subtract the
%   corresponding wavefront from the given wavefront.
%
% syntax: [Wxyz, ZcPrism] = pointWavefront(Wxy,xp,yp);
% inputs:
%   Wxy = the wavefront to be pointed in z-direction
%   xp, yp = support mesh for unit radius pupil
% outputs:
%   Wxyz = the oriented wavefront
%   ZcPrism = the first 3 Zernike coeffs of wavefront used to point Wxyz
%
% LNT 04Jan09.  Created to solve the problem uncovered by Adam Hickenbotham
% at UCB (Austin Roorda's group) that was causing some OTF metrics to
% behave badly.  Earlier attempts to avoid this problem by nulling the
% prism Zernike coefficients were invalid, as discovered by Jayoung Nam and
% Rob Iskander when working on Zernike expansion of vergence maps.
%
% LNT 05-Jul-09. Reset points outside pupil to zero for graphing purposes.

% rMin = 0.02;  % criterion value for paraxial analysis 
%               = circle 16 pix diam = 153 points
rMin = 0.01;  % criterion value for paraxial analysis 
%               = circle 12 pix diam = 81 points
mask=(xp.^2 + yp.^2) <= rMin;     % a paraxial pupil
index=find(mask>0);  % pointers to the valid data

W = Wxy(index); % extract the paraxial data
X = xp(index);  % not a problem that these are vectors rather than matrices
Y = yp(index);

modes = 1:3;
verbose = 0;
ZcPrism = Zernike_fit2D(W,X,Y,modes,verbose);  % fit paraxial data with prism

prism=zeros(size(xp)); % reconstruct prismatic wavefront over whole pupil
ZernBasis = zernikeR_6(xp,yp);
for j = 1:3   % accumulate prism by summing basis functions
    prism= prism + ZernBasis(:,:,j) * ZcPrism(j); %  scaled by coeffs
end

fullmask=(xp.^2 + yp.^2) > 1;     % points outside the full pupil
Wxyz = Wxy - prism;  % result should have zero slope paraxially
Wxyz(find(fullmask))=0;  % reset points outside pupil to zero
if std(Wxyz(index)) > 0.01 
    disp('Warning- pointWavefront: paraxial RMS > 0.01 microns')
end


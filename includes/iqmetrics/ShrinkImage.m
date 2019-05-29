function B = ShrinkImage(A,Bsize,scale,padvalue,method)
%ShrinkImage - shrink (or magnify) an image, pad (or trim) result to size [M,N]
%
% Syntax: B = ShrinkImage(A,Bsize,scale,padvalue,method);
%
% Inputs:
%   A = image to be shrunken
%   Bsize = [#rows, #cols] required for output
%   scale = scale factor. If scale = scalar, then use isotropic scaling.
%           If scale = vector [yscale (for rows), xscale (for cols)], 
%           use non-isotropic scaling.
%   padvalue = value used when padding image out to final size
%   method = options available in imresize.m
%
% example:  load SmallEyeChart; 
%           B = ShrinkImage(chart,[128 128],[1,2],NaN,'nearest');
%           figure; imagesc(B); axis image
% LNT 14Mar06
% LNT 18Apr07  Do a better job of handling scale factors > 1
% LNT 13-Apr-08.  Allow non-isotropic scaling

if nargin<5, method='nearest'; end
if nargin<4, padvalue=0; end
if isscalar(scale), scale(1,2)=scale; end
M=Bsize(1); N=Bsize(2);

[r,c] = size(A);
sr = round(r*scale(1)); sc = round(c*scale(2)); % new size of A
B = padvalue*ones(M,N);
C = imresize(A,[sr,sc],method); % resize the image
a = round((M-sr)/2);    % the vertical border around C
b = round((N-sc)/2);    % the horizontal border around C
if size(C,1) < M % the image A has been minified
    B(a:(a+sr-1), b:(b+sc-1)) = C;  % paste in the shrunken image
else% the image A has been magnified
    %B = C(-a:(a+sr+1), -b:(b+sc+1));  % trim the magnified image
    B = C(1:M, 1:N);  % trim the magnified image
end
% Note: no provision is made for the case of shrinking along one dimension
% but magnifying along the other.
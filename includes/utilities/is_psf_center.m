function [maxvalue,rowno,colno] = is_psf_center(psf, threshold)
%PSFcenter - find the center of a point-spread function
%
% syntax:
%   [maxvalue,rowno,colno] = PSFcenter(psf,threshold,showit);
% input:
%   psf = matrix of luminance values defining the psf
%   threshold = scalar multiplier for max(psf); default = 0.8
%   showit = flag to display results graphically; default = False
% output:
%   maxvalue = peak value of psf
%   colno = col number of center point = x-coordinate
%   rowno = row number of center point = y-coordinate
% note: if PSF is supported by a meshgrid (X,Y) in calling program, then 
%   (x,y) coordinates of the center are: (X(rowno,colno), Y(rowno,colno)).
%    If PSF is displayed as an image, then should use "axis xy" command and
%    plot(center(1),center(2),'r+')	to mark centroid with red plus symbol
%
% method:
%   Center = centroid of all points with luminance > max*threshold
%   The goal is to find a robust method for locating the center of a PSF
%   that is a compromise between peak value (fails if peak is an annulus,
%   as for defocus) and centroid (fails for skewed psfs, as for coma).
%
% LNT 22Jun05
% LNT 15Apr07 correct an error detected by Sowmya. 
% Prior to 15-Apr-07 I had switched rowno and colno when
% interpreting the results of centroi2. This affected 
% the variables returned to the calling program as shown here:
% function [maxvalue,rowno,colno] = PSFcenter(psf,threshold,showit);
% i.e. the third returned variable, colno, actually contained the row number.
%% This flub was not evident in the diagnostic graphics produced by
% PSFcenter because the graphics used a different variable (center) which
% was not affected by my misinterpretation.  That is, the command:
% plot(center(1),center(2)) correctly used the convention established by 
% the author of centroi2. If I had returned center instead of rowno,colno
% then the mistake might not have happened.
%% The fix was easy: swap the assignment of variables in PSFcenter so that
% colno=center(1)=x, rowno=center(2)=y. 
%% Extensive testing with program testPSFmetrics3 revealed that large errors
% were generated for PSFmetrics 1,3,7,10,11. These metrics depended on
% accurate location of the PSF center and therefore swapping of the x,y
% coordinates caused large errors.  Errors were much smaller for Jason
% Marsack's test cases since none of them contained prismatic coefficients.

    if(nargin<2 || isempty(threshold)), threshold = 0.8; end

    [maxvalue,~,~] = max2D(psf);            % find the pixel with peak intensity
    mask = (psf > maxvalue*threshold);      % find all pixels above threshold
    center = centroi2(psf.*mask);           % get (x,y) centroid of points above threshold
    center = round(center);                 % return interger row & col numbers for psf
    colno = center(1); rowno = center(2);   % corrected code 15Apr07

end

function C = ZernikeExpansion( x, y, pupilr, w, C )
% IMF retake on FastZernikeExpansion: Jose Alonso's implementation of
% Horner's method to compute the sampled Zernike polynomials for fitting to
% Z-data by LSQ method. The original FastZernikeExpansion has been split
% into two this one (ZernikeExpansion) and ZernikeExpansionPrep that
% prepares a structure with the setup to compute Zernikes. See
% ZernikeExpansionPrep
%
% The Zernike polynomials indexing scheme can either be that of Wyant or
% the standard adopted by the OSA.
%
% The names of the fields in C remain unchanged for compatibility with
% Jose's code.
%
% Syntax
% [ zc, A ] = ZernikeExpansion( x, y, w, C )
%
% DESCRIPTION
% x, y are the sampling points in same units as pupilr
% pupilr is radius in same units as x and y
% w is height
%
% C a structure with all the necesary information from the fitting. Its
% fields are
%       C.S:           Coefficients of the expansion
%       C.pupilr:      Pupil radius for the Zernike expansion in mm
%       C.h:           Transformation matrices such that
%                      A = SUM( S( n ) * hmat( n ) ). See ZernikeExpansion
%       C.dx:          Transformation matrices for the differential of the
%                      polynomials on x
%       C.dy:          Transformation matrices for the differential of the
%                      polynomials on y
%       C.maxmode:     Maximum mode of the expansion (maximum single index)
%       C.Indices:     Radial and azimutal indices, according to the chosen
%                      ordering
%       C.Type:       'Zernike' 
%       C.scheme:      Zernike ordering. It can either be 'osa' or 'wyant'
%       C.rmsnorm:     whether to perform rms normalization or not (true or
%                      false) 
%       C.normcoeff:   normalization coefficients. If rmscoeff is false
%                      then this is a vector of ones
%
% SEE ALSO
% ZernikeExpansionPrep, ZernikeExpansionSlope
%
% IMF December 2015

% check input
if nargin < 5, error( 'This function needs at least 5 arguments' ), end

% reshape and scale data
x = x(:) / pupilr; y = y(:) / pupilr; w = w(:);

% remove all points outside the pupil
x( isnan( w ) ) = []; y( isnan( w ) ) = []; w( isnan( w ) ) = [];

% mount the design matrices to evaluate Zernike polynomials
len = size( C.h(:,:,1), 1 );
xx = zeros( length( x ), len ); yy = zeros( length( y ), len );
for i = 1:len
    xx(:,i) = x.^( i - 1 );
    yy(:,i) = y.^( i - 1 );
end

% Evaluate polynomials
zpoly = zeros( length( x ), C.maxmode );
for i = 1:C.maxmode
    zpoly(:,i) = C.normcoeff(i) * sum( ( xx * C.h(:,:,i) ) .* yy, 2 );
end
C.S = zpoly \ w;

C.pupilr = pupilr;
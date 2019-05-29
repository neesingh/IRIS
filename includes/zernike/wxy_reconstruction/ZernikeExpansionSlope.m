function C = ZernikeExpansionSlope( x, y, pupilr, dx, dy, C )
% gets Zernike coefficients from slopes in x and y
% ZernikeExpansion
%
% The Zernike polynomials indexing scheme can either be that of Wyant or
% the standard adopted by the OSA.
%
% Syntax
% zc = ZernikeExpansionSlope( x, y, dx, dy, C )
%
% DESCRIPTION
% x, y are the sampling points in same units as pupilr
% pupilr is radius in same units as x and y
% dx, dy are sampled slopes data
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
%       C.indices:     Radial and azimutal indices, according to the chosen
%                      ordering
%       C.type:       'Zernike' 
%       C.scheme:      Zernike ordering. It can either be 'osa' or 'wyant'
%       C.rmsnorm:     whether to perform rms normalization or not (true or
%                      false) 
%       C.normcoeff:   normalization coefficients. If rmscoeff is false
%                      then this is a vector of ones
%
% SEE ALSO
% ZernikeExpansionPrep, ZernikeExpansionSlope
%
% IMF Jan 3 2016: first program of the year

% check input
if nargin < 6, error( 'This function needs at least 6 arguments' ), end

% reshape data and rescale
x = x(:) / pupilr; y = y(:) / pupilr; dx = pupilr * dx(:); dy = pupilr * dy(:);

% remove all points outside the pupil
x( isnan( dy ) ) = []; y( isnan( dy ) ) = []; dx( isnan( dy ) ) = []; dy( isnan( dy ) ) = [];

% mount the design matrices to evaluate Zernike polynomials
len = size( C.h(:,:,1), 1 );
xx = zeros( length( x ), len ); yy = zeros( length( y ), len );
for i = 1:len
    xx(:,i) = x.^( i - 1 );
    yy(:,i) = y.^( i - 1 );
end

% Evaluate polynomials
zpolydx = zeros( length( x ), C.maxmode );
zpolydy = zeros( length( y ), C.maxmode );
for i = 1:C.maxmode
    zpolydx(:,i) = C.normcoeff(i) * sum( ( xx * C.dx(:,:,i) ) .* yy, 2 );
    zpolydy(:,i) = C.normcoeff(i) * sum( ( xx * C.dy(:,:,i) ) .* yy, 2 );
end
% CARE: WITH THIS METHOD WE LOOSE INFORMATION ABOUT PISTON!
C.S = [ zpolydx; zpolydy; ones( 1, C.maxmode ) ] \ [ dx; dy; 0 ];
C.S(1) = 0;

C.pupilr = pupilr;
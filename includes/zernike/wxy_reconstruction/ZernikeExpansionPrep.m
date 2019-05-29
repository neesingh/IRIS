function C = ZernikeExpansionPrep( maxmode, rmsnorm, scheme )
% prepares the structure to compute Zernike coefficients.
%
% DESCRIPTION
% maxmode is a integer, the highest index in the Zernike expansion. The
% total number of Zernike coefficients is maxmode
%
% normalization: whether to do RMS normalization or not. Default is true:
% perform normalization
%
% scheme is a string that can either be 'wyant' or 'osa'. Default is 'osa'
%
% C a structure with all the necesary information from the fitting. Its
% fields are
%       C.S:           Coefficients of the expansion. This function returns
%                      and empty field, as this is just preps
%       C.pupilr:      Pupil radius for the Zernike expansion in mm. This
%                      function returns and empty field, as this is just
%                      preps
%       C.h:           Transformation matrices such that
%                      A = SUM( S( n ) * h( n ) ). See ZernikeExpansion
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
% ZernikeExpansion, ZernikeExpansionSlope
%
% IMF 22Dec2015
%
% IMF 11 Jan 2016: finish implementation of Wyant scheme

if nargin < 1, error( 'This function needs at least 5 arguments' ), end
if nargin < 2 || isempty( rmsnorm ), rmsnorm = true; end
if nargin < 3 || isempty( scheme ),  scheme  = 'osa'; end
if ~( strcmp( scheme, 'osa' ) || strcmp( scheme, 'wyant' ) )
    error( 'Incorrect scheme. Must be ''osa'' or ''wyant''' )
end
C.S = []; C.pupilr = [];

% create return structure with the fields in the desired order
C.maxmode           = maxmode;
[ C.h, C.dx, C.dy ] = polymatbasezc( maxmode, scheme );

% get index ordering
if strcmp( scheme, 'osa' )
    [ order, freq ] = mode2index( ( 1:maxmode )' );
elseif strcmp( scheme, 'wyant' )
    [ order, freq ] = wyantmode2index( ( 1:maxmode )' );
end
C.indices     = [ order, freq ];

C.type        = 'Zernike';
C.scheme      = scheme;
C.rmsnorm     = rmsnorm;
if rmsnorm
    C.normcoeff = rmszcpol( maxmode, scheme );
else
    C.normcoeff = ones( maxmode, 1 );
end
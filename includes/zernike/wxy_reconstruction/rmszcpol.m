function rmszc = rmszcpol( maxmode, scheme )
% calculates the rms of each polynomial for normalization
%
% maxmode is a integer, the highest index in the Zernike expansion. The
% total number of Zernike coefficients is nmax
%
% scheme is a string that can either be 'wyant' or 'osa'. Default is 'osa'
%
% created by IMF 11 Oct 2015
%
% IMF 11 Jan 2016: add Wyant ordenation too

% default maximum mode is 66 and it cannot be larger than 66 or smaller
% than 1.
if nargin < 1 || isempty( maxmode )
    maxmode = 66;
end
if nargin < 2 || isempty( scheme )
    scheme = 'osa';
end

if strcmpi( scheme, 'osa' )
    [ order, freq ] = mode2index( ( 1:maxmode )' );
elseif strcmpi( scheme, 'wyant' )
    [ order, freq ] = wyantmode2index( ( 1:maxmode )' );
end
rmszc = sqrt( 2 * ( order + 1 ) );
rmszc( freq == 0 ) = sqrt( order( freq == 0 ) + 1 );
function [ h, dx, dy ] = polymatbasezc( maxmode, scheme )
% generate the matrices up to a certain order to compute either the heigth
% of the wavefront (type = 'h'), the gradient in x (type = 'dx') or the the
% gradient in y (type = 'dy'). By default maxmode is 66 and type is h
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

% size of all square matrices with polynomials is the order of the maximum
% mode + 1
len = mode2index( maxmode ) + 1;

if strcmpi( scheme, 'osa' )
    [ order, freq ] = mode2index( ( 1:maxmode )' );
elseif strcmpi( scheme, 'wyant' )
    [ order, freq ] = wyantmode2index( ( 1:maxmode )' );
end

% init matrix: 11 is the maximum size for a maximum order of 66
h  = zeros( len, len, maxmode );
dx = zeros( len, len, maxmode );
dy = zeros( len, len, maxmode );

% fill the coefficients for h or dx or dy.
for mode = 1:maxmode
    [ h(1:order(mode) + 1,  1:order(mode) + 1, mode ), dx(1:order(mode) + 1,  1:order(mode) + 1, mode ), dy(1:order(mode) + 1,  1:order(mode) + 1, mode ) ] = polymatzc( order(mode), freq(mode) );
end
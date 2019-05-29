function [ order, freq ] = wyantmode2index( pos )
% hasomode2indx: gets the frequency and order from the order in the HASO
% list of Zernike coefficients
%
% usege:  [ freq, order ] = hasomode2index( pos )
%
% output: pos:     position in the HASO list of Zernike coefficients 
%
% output:  order:     degree; integer power of radius variable
%         frequency: integer multiple of angular variable
%
% IMF 23-Nov-2014 in Murcia
%
% See also: HASOINDEX2MODE

% make sure we don't have any unreasonable position
if any( pos ) > 400
    error( 'are you sure positions are correct?' )
end

% deduce first the column and row of the position. Number of columns per
% row is 2 * row - 1
elprevrows = [ 0; cumsum( ( 2 * (1:19) - 1 ) )' ]; % there is definitely not going to be more than 20 rows

% deduce row
row = zeros( length(pos), 1 );
for i = 1:( length( elprevrows ) - 1 )
    row( pos <= elprevrows( i+1 ) & pos > elprevrows(i) ) = i;
end

% deduce column
col = 2 * row - pos + elprevrows(row);

% from column we deduce the frequency
freq = ( col - 1 ) / 2;
negfreq = ~mod( col, 2 ) & freq ~= 0;
freq( negfreq ) = - col( negfreq ) / 2;

% and finanlly, deduce order
order = 2 * ( row - 1 ) - abs( freq );
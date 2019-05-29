function [ Psi, mask, masked_Psi, theta, R ] = refpowpol( j_end, npix )
% Calculate the Refractive Power Polynomials as in:
% Objective refraction from monochromatic wavefront aberrations via Zernike power polynomials.
% D. Robert Iskander, Brett A. Davis, Michael J. Collins and Ross Franklin
% Ophthal. Physiol. Opt. 2007 27: 245–255

v = ( -npix/2 : 1 : npix/2-1 )/( npix/2 );
[ xp, yp ] = meshgrid( v );
[ theta, R ] = cart2pol( xp, yp );
R = R( : );
theta = theta( : );
Psi = zeros( length( R ), j_end-2 );
masked_Psi = Psi;

for j = 3 : j_end
    L = length( R );
    n = ceil( 0.5*( -3+sqrt( 9+8*j ) ) );
    m = abs( 2*j-n*( n+2 ) );
    m_sign = 2*j-n*( n+2 );
    Q_nm = zeros( L, 1 );
    if m <= 1
        q = 1;
    else
        q = 0;
    end
    for s = 0 : 1 : ( n-m )/2-q
        Q_nm = Q_nm+(-1).^s*prod(1:n-s).*(n-2*s)./prod(1:s)./ ...
            prod(1:(n+m)/2-s)./prod(1:(n-m)/2-s).*R.^(n-2*s-2);
    end
    if m == 0
        Psi( :, j-2 ) = sqrt( n+1 ).*Q_nm;
    else
        if m_sign > 0
            Psi( :, j-2 ) = sqrt( 2*( n+1 ) ).*Q_nm.*cos( m.*theta );
        else
            Psi( :, j-2 ) = sqrt( 2*( n+1 ) ).*Q_nm.*sin( m.*theta );
        end
    end
end

mask = R <= 1;
for i = 1 : size( Psi, 2 )
    maskPsi = Psi( :, i );
    %maskPsi( mask == 0 ) = NaN;
    masked_Psi( :, i ) = maskPsi;
end
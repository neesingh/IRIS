function [ LA ] = is_refractive_power_map(z, r, array_size)
% Calculate the Refractive Power Map from the polynomials as in:
% Objective refraction from monochromatic wavefront aberrations via Zernike power polynomials.
% D. Robert Iskander, Brett A. Davis, Michael J. Collins and Ross Franklin
% Ophthal. Physiol. Opt. 2007 27: 245–255
    
    % Last Zernike mode to consider (it has to be last mode minus 1).
    no_z  = length( z ) - 1;

    % Generate refractive power polynomials.
    [Psi, ~, ~, ~, R]= refpowpol( no_z, array_size );
    %[ Psi, mask, ~, ~, ~ ] = refpowpol( no_z, array_size );

    % Generate refractive power map.
    dW = zeros( size( Psi, 1 ), 1 );
    for i = 4 : no_z+1
        dW = dW + z( i )*Psi( :, i-3 );
    end
    LA = dW/r^2;
    LA = reshape( LA, array_size, array_size );
    
    %LA(R <= 0.075) = NaN;
    
end
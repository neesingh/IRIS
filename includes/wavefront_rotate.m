function [Wxyz, ZcPrism] = wavefront_rotate(Wxy, xp, yp, paraxial_xy)
    %wavefront_rotate - rotate a wavefront so chief ray = z-axis
    % This program was created to satisfy the ANSI standard requiring the 
    %   chief ray to be the reference z-axis. Method is to point the wavefront
    %   correctly by finding the paraxial prism values and subtract the
    %   corresponding wavefront from the given wavefront.
    %
    % syntax: [Wxyz, ZcPrism] = pointWavefront(Wxy,xp,yp);
    % inputs:
    %   Wxy = the wavefront to be pointed in z-direction
    %   xp, yp = support mesh for unit radius pupil
    % outputs:
    %   Wxyz = the oriented wavefront
    %   ZcPrism = the first 3 Zernike coeffs of wavefront used to point Wxyz
    %
    % LNT 04Jan09.  Created to solve the problem uncovered by Adam Hickenbotham
    % at UCB (Austin Roorda's group) that was causing some OTF metrics to
    % behave badly.  Earlier attempts to avoid this problem by nulling the
    % prism Zernike coefficients were invalid, as discovered by Jayoung Nam and
    % Rob Iskander when working on Zernike expansion of vergence maps.
    %
    % LNT 05-Jul-09. Reset points outside pupil to zero for graphing purposes.

    W = Wxy(paraxial_xy); % extract the paraxial data
    X = xp(paraxial_xy);  % not a problem that these are vectors rather than matrices
    Y = yp(paraxial_xy);

    modes = 1:3;
    verbose = 0;
    ZcPrism = Zernike_fit2D(W,X,Y,modes,verbose);  % fit paraxial data with prism

    prism=zeros(size(xp)); % reconstruct prismatic wavefront over whole pupil
    ZernBasis = zernikeR_6(xp,yp);
    for j = 1:3   % accumulate prism by summing basis functions
        prism= prism + ZernBasis(:,:,j) * ZcPrism(j); %  scaled by coeffs
    end

    fullmask=(xp.^2 + yp.^2) > 1;     % points outside the full pupil
    Wxyz = Wxy - prism;  % result should have zero slope paraxially
    Wxyz(fullmask)=0;  % reset points outside pupil to zero
end
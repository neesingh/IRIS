function [Tx, Ty, Mer, Tang, tanVergence, radVergence, DX, DY, D2, xx, yy, Txx, Tyy, radius, calib] = wavefront_details(a)

    % Not very elegant, but here is the very belly of the showWdx function,
    % duplicating its functionality. Fusion it in the next version. This
    % function is executed also in analysis_mtf_ptf_pf.

    x = a.pf_x*a.r;
    y = a.pf_y*a.r;
    
    num = 16;                        % default = 1mrad, 1diopter, 1diopter
    calib = ones(1,4);

    [r,c] = size(x);				% this should be true for all input matrices
    xc = round(r/2);				% go to center of function to get step size
    yc = round(c/2);
    xstep = x(xc,1+yc) - x(xc,yc);	% x-distance between sample points in pupil, in mm
    ystep = y(1+xc,yc) - y(xc,yc);	% y-distance between sample points in pupil, in mm
    
    radius = max(max(x));			% infer pupil radius for plotting

    n = round(r/num);				% for indexing
    m = find(a.Axy);				% mask index
    R = sqrt(x.^2+y.^2);			% radial support mesh
    middle = find(R==0);			% find troublesome middle of pupil
    [I,J] = ind2sub(size(R),middle);

    % Gradient gives transverse aberration, in microns/mm = milliradians
    % sign convention: T>0 => wavefront points towards z-axis 
    [Tx,Ty] = gradient(a.Wxy,xstep,ystep);
    Tx(a.Axy==0) = NaN;                       % a trick to avoid plotting outside pupil
    Ty(a.Axy==0) = NaN;	% a trick to avoid plotting outside pupil
    
    Txx=Tx(1:n:r,1:n:c);  Tyy=Ty(1:n:r,1:n:c); %subsample gradient matrix to reduce clutter
    xx=x(1:n:r,1:n:c); yy=y(1:n:r,1:n:c);

    % Longitudinal aberration = TA/pupil height, in mrad/mm = rad/m = diopters
    % Plot LA in meridional plane as best approximation in case rays are skew to optical axis
    % sign convention: LA>0 => converging rays point towards z-axis 
    % sign convention: TG>0 => tangential rays point in clockwise direction
    L=zeros(r,c);
    Mer=L;
    Tang=L;
    Tg=L;
    
    R(middle) = xstep;                                  % temporarily replace the point of singularity
    Mer(m) = (x(m).*Tx(m) + y(m).*Ty(m)) ./ R(m);       % project TA onto unit radial vector = meridional slope
    L(m) = Mer(m) ./ R(m);                              % divide by ray height in radial direction to get diopters
    L(middle) = L(middle+1);                            % assume function is continuous at origin
    L(I,J) = (L(I,J+1)+L(I,J-1)+L(I+1,J)+L(I-1,J))/4;	% assume function is continuous at origin

    %L(1,1)=-calib(3);	L(1,2)=0;	L(1,3)=calib(3);	% calibration pixels, -1,0 +1 diopters
    %L(find(isnan(L))) = 0;                             % replace singular values with zero
    Tang(m) = (-y(m).*Tx(m) + x(m).*Ty(m)) ./ R(m);		% project TA onto unit tangential vector = tangential slope
    
    % This code was initially used to calculate the tangential vergence
    % map. It is superseded by the code below. Gives exactly the same
    % result - tested.
    
    %Tg(m) = Tang(m) ./ R(m);				% divide by ray height in radial direction to get diopters
    %Tg(middle) = Tg(middle+1);			% assume function is continuous at origin
    %Tg(I,J) = (Tg(I,J+1)+Tg(I,J-1)+Tg(I+1,J)+Tg(I-1,J))/4;	% assume function is continuous at origin
    
    %% Use pupil data to compute vergence maps 
    % First remove paraxial prism as prescribed by Nam et al 2009. [Nam, J.,
    %  L. N. Thibos and D. R. Iskander (2009). "Zernike radial slope polynomials
    %  for wavefront reconstruction and refraction." J Opt Soc Am A Opt Image
    %  Sci Vis 26(4): 1035-1048]. The rationale is that the measurement axis  
    %  should coincide with the chief ray (per ANSI Z80.28 standard) and 
    %  therefore any wavefront will have zero slope at the pupil center. 
    %  For example, a tilted plane wave produced by an aberration-free prism 
    %  should have zero vergence at the pupil center.
    % Existing program pointWavefront.m is not useful here because the goal is
    %  to compute vergence from slope maps, not wavefront phase maps. Instead,
    %  simply subtract the paraxial slopes from the slope matrices. It is OK
    %  that dvx_pupil changes since the original values have been saved.
    
    normR = sqrt(a.pf_x.^2 + a.pf_y.^2);    % normalized radial distance of each sample
                                            % COAS may reject central data due to reflections
                                            
    paraxial_mask = (normR) <= 0.075;        % a boolean paraxial pupil                                                                                
                                            
    mean_dX = mean(Tx(paraxial_mask & ~isnan(a.pf_x))); 
    mean_dY = mean(Ty(paraxial_mask & ~isnan(a.pf_y)));
    dX = Tx - mean_dX;                      % make the correction
    dY = Ty - mean_dY;

    % Compute radial and tengential slopes from x= & y-slopes using formula in 
    % [Nam, J., L. N. Thibos and D. R. Iskander (2009). "Describing ocular
    % aberrations with wavefront vergence maps." Clin Exp Optom 92(3): 194-205] 
    [TH,~] = cart2pol(a.pf_x, a.pf_y);      % convert pupil mesh to polar coordinates
    dR = dX.*cos(TH)+dY.*sin(TH);           % radial slope
    dT = -dX.*sin(TH)+dY.*cos(TH);          % tangential slope
                                            % Another pre-correction: it is better to plot a NaN than inf
    normR(normR == 0) = NaN;                % replace r=0 (pupil center) with NaN

    % Compute vergence by diving slope by radial distance from pupil center
    % Vergence units are mrad/mm = diopters, so need to convert normalized
    % pupil coordinates back to physical mm
    %radVergence = dR./(normR * a.r);  % radial wavefront vergence 
    radVergence = - dR./(normR * a.r);  % radial wavefront vergence 
    radVergence(paraxial_mask) = mean(radVergence(:));
    tanVergence = dT./(normR * a.r);  % tangential wavefront vergence 
    tanVergence(paraxial_mask) = mean(tanVergence(:));
    
    % I'm not sure how to define or interpret horizontal & vertical components
    % so leave them out for now.
    % xVergence = dX./(normRR*pupilRadmm);   % horizontal vergence RETHINK THIS DEF! 
    % yVergence = dY./(normRR*pupilRadmm);   % vertical vergence


    %% Laplacian gives curvature map = local dioptric power
    % Note: del2 returns (d^2u/dx^2 + d^2/dy^2)/4, but we want 2x this, which is average second deriv.
    % 03-Feb-02.  Evidently this reasoning is wrong. Don't double the results.
    
    D2 = zeros(r,c); DX = D2; DY = D2;
    [Del2,DelX,DelY] = del2LNT(a.Wxy,xstep,ystep); 

    D2(m) = 2*Del2(m); DX(m) = 2*DelX(m); DY(m) = 2*DelY(m); DXY=(DX+DY)/2;
    
    D2(1,1)=-calib(4);	D2(1,2)=0;	D2(1,3)=calib(4);		% calibration pixels, -1,0 +1 diopters
    DX(1,1)=-calib(4);	DX(1,2)=0;	DX(1,3)=calib(4);		% calibration pixels, -1,0 +1 diopters
    DY(1,1)=-calib(4);	DY(1,2)=0;	DY(1,3)=calib(4);		% calibration pixels, -1,0 +1 diopters
    DXY(1,1)=-calib(4);	DXY(1,2)=0;	DXY(1,3)=calib(4);		% calibration pixels, -1,0 +1 diopters
    
end


    z = zeros(6, 1);
    z(5) = 0.2;
    z(2) = 0.0;
    z(3) = 0.1;

    pupil_area = 1;
    pupil_bits = 7;
	pupil_ellipticity = 0;    
    pupil_rotation = 0;
    lambda = 550 * 1e-9;
    reference_lambda = 550 * 1e-9;

    pupil_support = 2^(pupil_bits-1);
    lambda_ratio = lambda/reference_lambda;
    
    psf_pix_halfwidth = pupil_support/2;
                                                
    k = 2*pi/lambda;
    
    v = (-pupil_support:lambda_ratio:pupil_support-1)/pupil_support; %asymm.
    [x,y] = meshgrid(v);	                                          		
      
    pupil_support = elliptical_pupil(x, y, pupil_rotation, pupil_ellipticity);           
    Axy = pupil_support <= pupil_area;
    xp = x; yp = y;
       
    Wxy = zeros(size(x)); 
    modes = length(z);
    if modes==6;
        ZernBasis = zernikeR_6(x,y);	
    elseif modes==10;
        ZernBasis = zernikeR_10(x,y);	
    elseif modes==15;
        ZernBasis = zernikeR_15(x,y);	
    elseif modes==21;
        ZernBasis = zernikeR_21(x,y);	
    elseif modes==28;
        ZernBasis = zernikeR_28(x,y);	
    elseif modes==36;
        ZernBasis = zernikeR_36(x,y);	
    elseif modes==45;
        ZernBasis = zernikeR_45(x,y);	
    elseif modes==55;
        ZernBasis = zernikeR_55(x,y);	
    elseif modes==66;
        ZernBasis = zernikeR_66(x,y);
    else
        show_msg(cf, sprintf('Number of modes (%s) is not standard', modes), 'error');
    end

    for j = 1:modes
        Wxy = Wxy + ZernBasis(:,:,j) * z(j);
    end
    
    ZernBasis

    r_min = 0.01;
    paraxial_xy = (xp.^2 + yp.^2) <= r_min;     % a paraxial pupil
    paraxial_xy = find(paraxial_xy > 0);        % pointers to the valid data

    [Wxy, zernike_prisms] = wavefront_rotate(Wxy, xp, yp, paraxial_xy);  % make chief ray = z-axis(04Jan09)

    Wxy_method1 = Wxy;
    
    [radial_theta, radial_r] = cart2pol(x,y);
    idx = radial_r <= 1;
    
    modes = length(z);
    [n,m] = mode2index(1:modes);
    base_functions = zernfun(n,m,radial_r(idx),radial_theta(idx), 'norm');
    
    base= zeros(size(x));
    Wxy = zeros(size(x)); % initialize the wavefront

    for j = 1:modes

        base(idx) = base_functions(:,j);
        Wxy = Wxy + base * z(j);     % scaled by coeffs
    end
    
    %[Wxy, zernike_prisms] = wavefront_rotate(Wxy, xp, yp, paraxial_xy);  % make chief ray = z-axis(04Jan09)
    Wxy_method2 = Wxy;
    
    % create the pupil function
    PF = Axy .* exp(1i*k*Wxy*1e-6);


    ASF = ifft2(PF, 2*psf_pix_halfwidth, 2*psf_pix_halfwidth);  % amplitude spread function 
    % ---------- Obtain the PSF -----------
    PSF = ASF.*conj(ASF);                           % intensity spread function, not centered
    % ---------- Obtain the PSF -----------
    PSF = fftshift(PSF);                            % center the origins of PSF & OTF for display purposes

    PSF = flipud(PSF);
    PSF = real(PSF);
    
    figure(1)
        subplot(1,2,1);
            surf(Wxy_method1); axis square;
        subplot(1,2,2);
            surf(Wxy_method2); axis square;
            
    figure(2)
    
        for i = 1:modes
            subplot(2,modes,i);
                surf(ZernBasis(:,:,j));
            subplot(2,modes,modes+i);
                base(idx) = base_functions(:,j);
                surf(base);
        end
        

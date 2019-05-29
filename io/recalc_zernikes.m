function [ zernikes ] = recalc_zernikes(~, ~)

    cf = gcbf;

    ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    ui_handles =  getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    
    pupil_radius = str2double(get(ui_handles.pupil_radius, 'String'));
    zernike_rotation = str2double(get(ui_handles.zernike_rotation, 'String'));
    zernike_translate_x = str2double(get(ui_handles.zernike_translate_x, 'String'));
    zernike_translate_y = str2double(get(ui_handles.zernike_translate_y, 'String'));
    pupil_radius_recalc = str2double(get(ui_handles.pupil_radius_recalc, 'String'));
    
    propagate_Wxy = str2double(get(ui_handles.propagate_Wxy, 'String'));
    radius = pupil_radius;
    
    %controls_onoff_toggle( cf );                 % freeze the interface so that a bored user doesn't play
    
    if(pupil_radius ~= 0 && pupil_radius_recalc ~= 0 && pupil_radius ~= pupil_radius_recalc)
        
        zernikes = zeros(length(ui_zernikes),1)';
        for i = 1:length(ui_zernikes)
            zernikes(i) = str2double(get(ui_zernikes(i), 'String'));
        end
        
        % Linda's method works for any number of modes. Verified the same results at least up to the fourth decimal.
        zernikes = zernike_rescale_lundstrom([2*pupil_radius, zernikes], 2*pupil_radius_recalc, zernike_translate_x, zernike_translate_y, zernike_rotation);
        zernikes = zernikes(2:end); % for schwiegerling comment this out as well
        %zernikes = zernike_rescale_schwiegerling(zernikes, pupil_radius_recalc/pupil_radius);

        for i = 1:length(ui_zernikes)
            set(ui_zernikes(i), 'String', sprintf(['%',ui_defaults.float_precision,'f'], zernikes(i)));
        end

        set(ui_handles.pupil_radius, 'String', sprintf(['%',ui_defaults.float_precision,'f'], pupil_radius_recalc));
        set(ui_handles.pupil_radius_recalc, 'String', sprintf(['%',ui_defaults.float_precision,'f'], pupil_radius_recalc));
        
        show_msg(cf, sprintf('Wxy Rescaled from:%3.2f to:%3.2f mm.', radius, pupil_radius_recalc));
        
        radius = pupil_radius_recalc;
    end
    
    if(zernike_rotation ~= 0 || zernike_translate_x ~=0 || zernike_translate_y ~= 0)
        
        zernikes = zeros(length(ui_zernikes),1)';
        for i = 1:length(ui_zernikes)
            zernikes(i) = str2double(get(ui_zernikes(i), 'String'));
        end
        
        zernikes = zernike_rescale_lundstrom([2*radius, zernikes], 2*radius, zernike_translate_x, zernike_translate_y, zernike_rotation);
        zernikes = zernikes(2:end);

        for i = 1:length(ui_zernikes)
            set(ui_zernikes(i), 'String', sprintf(['%',ui_defaults.float_precision,'f'], zernikes(i)));
        end
        
        set(ui_handles.zernike_rotation, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
        set(ui_handles.zernike_translate_x, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
        set(ui_handles.zernike_translate_y, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
        
        show_msg(cf, sprintf('Wxy Recalculated: x:%3.2f mm, y:%3.2f mm, rotation:%3.2f deg.', zernike_translate_x, zernike_translate_y, zernike_rotation));
    end
    
    if(propagate_Wxy ~= 0)
        
        % Settings structure - passed to, and returned by the analyses functions, controlling their behavior
        s = struct( 'cf',                   cf,...                                        % current figure - single most important number for the GUI
                    'analysis_mode',        'quickview',...
                    'analysis_type',        0,...
                    'analysis_range',       str2double(get(ui_handles.analysis_offset, 'String')),...
                    'polypsf_mode',         0,...
                    'batch',                0,...
                    'calculate_psf',        1,...
                    'calculate_psf_go',     get(ui_handles.calculate_psf_go, 'Value'),... % Geometrical Optics PSF. Experimental. Increases computation time.
                    'pixsize',              str2double(get(ui_handles.image_pixsize, 'String')),...
                    'psf_crop_threshold',   str2double(get(ui_handles.psf_crop_threshold, 'String')),...
                    'pupil_sce',            str2double(get(ui_handles.pupil_sce, 'String')),...
                    'pupil_rotation',       get(ui_handles.pupil_rotation, 'Value'),...
                    'pupil_ellipticity',    get(ui_handles.pupil_ellipticity, 'Value'),...
                    'pupil_mask',           get(ui_handles.pupil_mask, 'UserData'),...
                    'zernikes',             [],...                                % Zernike Coefficients for wave aberration (microns, VSIA normalization), first mode is the piston.
                    'r',                    pupil_radius_recalc,...
                    'source',               0,...
                    'offset',               0,...
                    'selected_zernike',     ui_defaults.selected_zernike,...
                   'selected_zernike_value',0,...
                    'rotate_chief_ray',     get(ui_handles.rotate_chief_ray, 'Value'),...
                    'no_psfs',              str2double(get(ui_handles.no_psfs, 'String')),...
                    'device_lambda',        str2double(get(ui_handles.device_lambda, 'String')),...
                    'rgb_lambdas',          str2double(get(ui_handles.device_lambda, 'String')),...
                    'reference_lambda',     str2double(get(ui_handles.device_lambda, 'String')),...
                    'diagnostic',           0,...
                    'lca_switch',           1,...                                       % used by the Indiana Eye Model
                    'qp',                   0);                                         % used by the Indiana Eye Model

        zernikes(1:3) = [0, 0, 0];
        dist = propagate_Wxy;
        pupil_support = 2^(ui_defaults.pupil_bits-1);
        
        v = (-pupil_support:1:pupil_support-1)/pupil_support;
        [x,y] = meshgrid(v);	                                          		
        	                                          		
        Axy = double(sqrt(x.^2 + y.^2) < 0.99);
        
        out = zernike2psf(cf, zernikes, radius, s.reference_lambda, s); % pass reference lambda so that the grid is always uniform and spaced 1
        Wxy = out.Wxy;
        
        xmm = x*radius;
        ymm = y*radius;

        [rows,cols] = size(xmm);            % this should be true for all input matrices
        xc = round(rows/2);                 % go to center of function to get step size
        yc = round(cols/2);
        xstep = xmm(xc,1+yc) - xmm(xc,yc);	% x-distance between sample points in pupil, in mm
        ystep = ymm(1+xc,yc) - ymm(xc,yc);	% y-distance between sample points in pupil, in mm

        % Gradient gives transverse aberration, in microns/mm = milliradians
        % sign convention: T>0 => wavefront points towards z-axis 
        [dWdx, dWdy] = gradient(Wxy, xstep, ystep);
        Wxy( Axy==0) = NaN;
        dWdx(Axy==0) = NaN;
        dWdy(Axy==0) = NaN;

        Wxy = Wxy * 1E-3;
        dWdx = dWdx * 1E-3;                 % mm/mm = radians
        dWdy = dWdy * 1E-3;


        %% Wavefront propagation
        % notice that X and Y coordinates also change in the propagation
        
        % Normal vectors (Nx, Ny, Nz)
        Nz = 1 ./ sqrt( dWdx.^2 + dWdy.^2 + 1 );
        Nx = - dWdx .* Nz;
        Ny = - dWdy .* Nz;

        % projection of propagation
        x_p = xmm + dist * Nx;
        y_p = ymm + dist * Ny;
        Wxyp = Wxy + dist * Nz;
        
        Wxy = Wxy * 1E3;
        Wxyp = Wxyp * 1E3;

        % sanity check: compute Zernikes from wavefront generated with FOC's Zvec2Wxy
        C  = ZernikeExpansionPrep( length(ui_zernikes) );
        C  = ZernikeExpansion( xmm, ymm, radius, Wxy, C );

        show_msg(cf, sprintf('\nOriginal Wavefront: %3.2fD, c20: %3.3fum, radius: %3.3fmm.', -4*sqrt(3)*C.S(5)/radius^2, C.S(5), radius));

        %% Recover Zernikes from the propagated Wavefront
        % we start by obtaining the centroid and radius of the new wavefront, such as the circular pupil contains all projected (X,Y points)

        centerx_p = mean( x_p( ~isnan( Wxyp ) ) );
        centery_p = mean( y_p( ~isnan( Wxyp ) ) );
        
        radii = sqrt(x_p.^2 + y_p.^2);
        radii = radii( ~isnan(Wxyp) );

        rp = max(radii(:));
    
        C = ZernikeExpansion( x_p - centerx_p, y_p - centery_p, rp, Wxyp, C ); % compute Zernikes after propagation and converting wavefront height back to microns
        show_msg(cf, sprintf('Propagated Wavefront: %3.2fD, c20: %3.3fum, radius: %3.3fmm.', -4*sqrt(3)*C.S(5)/rp^2, C.S(5), rp));
        C.S(1:3) = [0 0 0];
    
        %% Rescale the new Zernikes to the original radius and calculate RMS

        new_z = zernike_rescale_lundstrom([rp; C.S], radius);
        new_z = new_z(2:end);
        new_z(1:3) = [0 0 0];

        comp_z = zeros(length(ui_zernikes), 4);
        comp_z(:,1) = zernikes; % original
        comp_z(:,2) = C.S;      % propagated, Horner
        comp_z(:,3) = new_z;    % propagated, rescaled
        comp_z(:,4) = new_z - zernikes;

        rms = comp_z(:,4).^2;
        rms = sqrt(sum(rms(:)));
        
        for i = 1:length(ui_zernikes)
            set(ui_zernikes(i), 'String', sprintf(['%',ui_defaults.float_precision,'f'], C.S(i)));
        end
        
        set(ui_handles.pupil_radius, 'String', sprintf(['%',ui_defaults.float_precision,'f'], rp));
        set(ui_handles.pupil_radius_recalc, 'String', sprintf(['%',ui_defaults.float_precision,'f'], rp));
        set(ui_handles.propagate_Wxy, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
        set(ui_handles.zernike_rotation, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
         
        show_msg(cf, sprintf('Wxy propagated %3.3f mm, delta RMS: %3.3f.', dist, rms)); 

    end
    analysis_quickview( [], [], gcbf );
    calc_opthalmic( [], [], gcbf );
    %controls_onoff_toggle( cf );                 % unfreeze the interface
end


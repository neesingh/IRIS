function launch_analysis(~, ~, analysis_type)

    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_zernikes= getappdata(gcbf, 'ui_zernikes');
    ui_defaults= getappdata(gcbf, 'ui_defaults');
    ui_radios =  getappdata(gcbf, 'ui_radios');
    ui_devices = getappdata(gcbf, 'ui_devices');
    
    % Settings structure - passed to, and returned by the analyses functions, controlling their behavior
    s = struct( 'cf',                   gcbf,...                                      % current figure - single most important number for the GUI
                'analysis_mode',        'single',...                                  % single/through-focus/batch/quickview
                'analysis_type',        analysis_type,...                             % sim/iqm/mtf
                'analysis_range',       str2double(get(ui_handles.analysis_offset, 'String')),...
                'polypsf_mode',         0,...
                'calculate_psf',        1,...
                'add_Wxy',              [],...
                'add_Wxy_lambda',       str2double(get(ui_handles.add_Wxy_lambda, 'String')),...
                'add_Wxy_radius',       str2double(get(ui_handles.add_Wxy_radius, 'String')),...
                'add_Wxy_scale',        str2double(get(ui_handles.add_Wxy_scale, 'String')),...
                'calculate_psf_go',     get(ui_handles.calculate_psf_go, 'Value'),... % Geometrical Optics PSF. Experimental. Increases computation time.
                'pixsize',              str2double(get(ui_handles.image_pixsize, 'String')),...
                'psf_crop_threshold',   str2double(get(ui_handles.psf_crop_threshold, 'String')),...
                'pupil_sce',            str2double(get(ui_handles.pupil_sce, 'String')),...
                'pupil_rotation',       get(ui_handles.pupil_rotation, 'Value'),...
                'pupil_ellipticity',    get(ui_handles.pupil_ellipticity, 'Value'),...
                'pupil_mask',           get(ui_handles.pupil_mask, 'UserData'),...
                'zernikes',             [],...                                      % Zernike Coefficients for wave aberration (microns, VSIA normalization), first mode is the piston.
                'r',                    str2double(get(ui_handles.pupil_radius, 'String')),...
                'source',               ui_devices{get(ui_handles.zernike_source, 'Value')}.id,...
                'offset',               ui_devices{get(ui_handles.zernike_source, 'Value')}.offset,...
                'selected_zernike',     ui_defaults.selected_zernike,...
               'selected_zernike_value',0,...
                'rotate_chief_ray',     get(ui_handles.rotate_chief_ray, 'Value'),...
                'no_psfs',              str2double(get(ui_handles.no_psfs, 'String')),...
                'reference_lambda',     ui_defaults.reference_lambda,...
                'device_lambda',        str2double(get(ui_handles.device_lambda, 'String')),...
                'rgb_lambdas',          ui_defaults.lambdas,...
                'diagnostic',           0,...
                'lca_switch',           1,...                                       % used by the Indiana Eye Model
                'lca_multiplier',       str2double(get(ui_handles.lca_multiplier, 'String')),...
                'include_vlambda',      get(ui_handles.include_vlambda, 'Value'),...
                'qp',                   0);                                         % used by the Indiana Eye Model
            
    s.zernikes = zeros(length(ui_zernikes),1);
    for z = 1:length(ui_zernikes)
        s.zernikes(z) = str2double(get(ui_zernikes(z), 'String'));
    end  

    for z = 1:length(ui_radios)
        if(get(ui_radios(z), 'Value') == 1)
            s.selected_zernike = z;
            s.selected_zernike_value = s.zernikes(z);
        end
    end
    
    if(~isempty(get(ui_handles.add_Wxy, 'Tag')))
        
        load(get(ui_handles.add_Wxy, 'Tag'), 'data');
        s.add_Wxy = data.Wxy;
        
    end
    
    if(get(ui_handles.mode_through, 'Value') == 1)
        s.analysis_mode = 'through-focus';
        
        analysis_from = get(ui_handles.analysis_from, 'Value');
        analysis_to = get(ui_handles.analysis_to, 'Value');
        analysis_steps = str2double(get(ui_handles.analysis_steps, 'String'))-1;
        analysis_steps = max(analysis_steps, 1);
        
        analysis_step = (analysis_to - analysis_from)/analysis_steps;
        s.analysis_range = analysis_from:analysis_step:analysis_to;
    end

    if(get(ui_handles.poly_mode_polypsf, 'Value') == 1), s.polypsf_mode = 1; end
    
    controls_onoff_toggle( gcbf );                    % freeze the interface so that a bored user doesn't play
    if(get(ui_handles.batch_switch, 'Value'))
        s.analysis_mode = 'batch';
        s.analysis_range= 0;
        analysis_batch(s);
    else
        if(get(ui_handles.poly_mode_simple, 'Value') == 1)
            analysis_simple( [], [], s);
        elseif(get(ui_handles.poly_mode_polypsf, 'Value') == 1)
            analysis_polypsf([], [], s);
        end
    end
    controls_onoff_toggle( gcbf );                    % unfreeze the interface
end
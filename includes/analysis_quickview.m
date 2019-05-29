function analysis_quickview( ~, ~, cf )
% Displays the contents of the Quick View panel in the Launcher, contains
% 2D and 3D representations of the Wavefront and Vergence described by the
% current zernike set.

    warning('off', 'MATLAB:contour:ConstantData');

    if(nargin<3), cf = gcbf; end

    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures');
    ui_defaults= getappdata(cf, 'ui_defaults');
    ui_zernikes= getappdata(cf, 'ui_zernikes');
    ui_devices = getappdata(cf, 'ui_devices');

    uis = ui_figures.ui_unit_spacing;

    delete(findobj(ui_handles.uitab_quickview_2d, 'type', 'axes'));
    delete(findobj(ui_handles.uitab_quickview_psf,'type', 'axes'));
    delete(findobj(ui_handles.uitab_quickview_pupil,'type', 'axes'));
    delete(findobj(ui_handles.uitab_quickview_summary,'style', 'text'));
    
    % Settings structure - passed to, and returned by the analyses functions, controlling their behavior
    s = struct( 'cf',                   cf,...                                        % current figure - single most important number for the GUI
                'analysis_mode',        'quickview',...
                'analysis_type',        0,...
                'analysis_range',       str2double(get(ui_handles.analysis_offset, 'String')),...
                'polypsf_mode',         0,...
                'batch',                0,...
                'add_Wxy',              [],...
                'add_Wxy_lambda',       str2double(get(ui_handles.add_Wxy_lambda, 'String')),...
                'add_Wxy_radius',       str2double(get(ui_handles.add_Wxy_radius, 'String')),...
                'add_Wxy_scale',        str2double(get(ui_handles.add_Wxy_scale, 'String')),...
                'calculate_psf',        1,...
                'calculate_psf_go',     get(ui_handles.calculate_psf_go, 'Value'),... % Geometrical Optics PSF. Experimental. Increases computation time.
                'pixsize',              str2double(get(ui_handles.image_pixsize, 'String')),...
                'psf_crop_threshold',   str2double(get(ui_handles.psf_crop_threshold, 'String')),...
                'pupil_sce',            str2double(get(ui_handles.pupil_sce, 'String')),...
                'pupil_rotation',       get(ui_handles.pupil_rotation, 'Value'),...
                'pupil_ellipticity',    get(ui_handles.pupil_ellipticity, 'Value'),...
                'pupil_mask',           get(ui_handles.pupil_mask, 'UserData'),...
                'zernikes',             [],...                                % Zernike Coefficients for wave aberration (microns, VSIA normalization), first mode is the piston.
                'r',                    str2double(get(ui_handles.pupil_radius, 'String')),...
                'source',               ui_devices{get(ui_handles.zernike_source, 'Value')}.id,...
                'offset',               ui_devices{get(ui_handles.zernike_source, 'Value')}.offset,...
                'selected_zernike',     ui_defaults.selected_zernike,...
               'selected_zernike_value',0,...
                'rotate_chief_ray',     get(ui_handles.rotate_chief_ray, 'Value'),...
                'no_psfs',              str2double(get(ui_handles.no_psfs, 'String')),...
                'device_lambda',        str2double(get(ui_handles.device_lambda, 'String')),...
                'rgb_lambdas',          str2double(get(ui_handles.device_lambda, 'String')),...
                'reference_lambda',     str2double(get(ui_handles.device_lambda, 'String')),...
                'diagnostic',           0,...
                'lca_switch',           1,...                                       % used by the Indiana Eye Model
                'lca_multiplier',       str2double(get(ui_handles.lca_multiplier, 'String')),...
                'qp',                   0);                                         % used by the Indiana Eye Model
    
    s.zernikes = zeros(length(ui_zernikes),1);
    for z = 1:length(ui_zernikes)
        s.zernikes(z) = str2double(get(ui_zernikes(z), 'String'));
    end  

    if(get(ui_handles.correct_defocus, 'Value')), s.zernikes(5) = 0; end
    if(~isempty(get(ui_handles.add_Wxy, 'Tag')))
        get(ui_handles.add_Wxy, 'Tag')
        load(get(ui_handles.add_Wxy, 'Tag'), 'data');
        s.add_Wxy = data.Wxy;
        
    end
    
    controls_onoff_toggle( cf );                 % freeze the interface so that a bored user doesn't play
    % ------------------------------------------ %
    analyses = analysis_simple([],[], s);
    a = analyses{1}.data_rgb{1};
    % ------------------------------------------ %
    controls_onoff_toggle( cf );                 % unfreeze the interface
    
    x = a.pf_x*a.r;
    y = a.pf_y*a.r;
    
    if(~isempty(s.add_Wxy))
        
        Vr = wavefront2vergence(a.Wxy, a.Axy, a.r, 0);
        
    else
        % Use the methodology by Rob Iskander to calculate the refractive power map
        Vr = -is_refractive_power_map(a.zernikes, a.r, size(a.Axy,1));
        Vr(a.Axy == 0) = NaN;
    end
    
    data_Wxy= a.Wxy;
    %if(sum(data_Wxy(:)) == 0), data_Wxy(end/2, end/2) = eps; end; 
    data_Wxy(a.Axy == 0) = NaN;
    
    axes('Parent', ui_handles.uitab_quickview_2d); axis off;
    ax = subplot(2,1,1);    
        %data_range = [floor(min(min(data_Wxy))) ceil(max(max(data_Wxy)))];
        %cstep = (data_range(2) - data_range(1))/ui_figures.no_contours;
        %v = (data_range(1):cstep:data_range(2));
        
        
        imagesc(data_Wxy, 'XData', x(1,:), 'YData', y(:,1));
        %contourf(x,y,data_Wxy,v);
        title(t('WFE [um]'), 'FontSize', ui_figures.fontsize_title);
        xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
        ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
        colorbar('peer', ax, 'vert'); 
        axis square; colormap('jet');
        
    ax = subplot(2,1,2);
        %data_range = [floor(min(min(data_LA))) ceil(max(max(data_LA)))];

        %cstep = (data_range(2) - data_range(1))/ui_figures.no_contours;
        %v = (data_range(1):cstep:data_range(2));
        
        imagesc(Vr, 'XData', x(1,:), 'YData', y(:,1));
        %contourf(x,y,data_LA,v);	
        title (t('Vergence [D]'), 'FontSize', ui_figures.fontsize_title);
        xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
        ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
        colorbar('peer', ax, 'vert'); 
        %caxis(data_range);
        axis square; colormap('jet');
    
    pause(0.1); % make the figure update quickly
        
    axes('Parent', ui_handles.uitab_quickview_psf); axis off;
    psf_size = size(a.PSF_resized);
    subplot(2,1,1);
        PSF_disp = a.PSF_resized;
        scale2d = (-psf_size(1):psf_size(1)-1)/2*s.pixsize;
        scale1d = (-psf_size(1):2:psf_size(1)-1)/2*s.pixsize;
        
        if(sum(s.zernikes(:)) == 0 && psf_size(1) == 4)
            PSF_disp = PSF_disp(1:end-1, 1:end-1);
            scale2d = scale2d(1:end-1);
            scale1d = scale1d(1:end-1);
        end
        
        imagesc(PSF_disp, 'XData', scale2d, 'YData', scale2d);
        title(sprintf(['%4.2fnm ', t('PSF Preview')], a.lambda), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        xlabel(t('Visual Angle [arcmin]')); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
        
    subplot(2,1,2);
        psf_slice_x = PSF_disp(max(1,floor(psf_size(1)/2)), :);
        psf_slice_y = PSF_disp(:, max(1,floor(psf_size(2)/2)));
        
        plot(scale1d, psf_slice_x, scale1d, psf_slice_y);
        title(sprintf(['%4.2fnm ', t('PSF Profiles')], a.lambda), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        l = legend('x', 'y'); set(l, 'Color', ui_figures.bg_simulation, 'TextColor', ui_figures.axis_simulation);
        xlabel(t('Visual Angle [arcmin]')); set(gca, 'Color', ui_figures.bg_simulation, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
        
    axes('Parent', ui_handles.uitab_quickview_pupil); axis off;
    ax = subplot(2,1,1);
        scale = -a.r:a.r;
        imagesc(a.Axy, 'XData', scale, 'YData', scale);
        colorbar('peer', ax, 'vert', 'Color', ui_figures.axis_simulation);
        title(t('Pupil Preview'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
        xlabel('X [mm]'); ylabel('Y [mm]'); 
        
    subplot(2,1,2);
        pupil_slice_x = a.Axy(floor(length(a.Axy(1,:))/2), :);
        pupil_slice_y = a.Axy(:, floor(length(a.Axy(:,1))/2));
        
        lps = floor(length(pupil_slice_x));
        scale = (-lps/2:1:lps/2-1)/lps*2*a.r;
        
        plot(scale,pupil_slice_x, scale,pupil_slice_y);
        title(t('Pupil Profiles'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        l = legend('x', 'y'); set(l, 'Color', ui_figures.bg_simulation, 'TextColor', ui_figures.axis_simulation);
        xlabel('X [mm]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation, 'Color', ui_figures.bg_simulation); axis square;
        
    ui_summary = uicontrol( 'Parent', ui_handles.uitab_quickview_summary, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'left',...
                            'String', '', 'Position', [uis uis 1-2*uis 1-2*uis],...
                            'FontSize', ui_figures.fontsize_text, 'BackgroundColor', ui_figures.bg_charts);
        
    txt_summary = '';
    fields = fieldnames(a);
    
    for i=1:numel(fields)
        field_name = strrep(fields{i}, '_', ' ');
        
        spaces = ''; nsp = 20-length(field_name);
        for(sp = 1:nsp), spaces = [spaces,' ']; end
        
        if( isscalar(a.(fields{i})) || length(a.(fields{i})(:))==2 )
            field_value = num2str( a.(fields{i}) );
        else
            field_value = ['[', num2str(size(a.(fields{i}))), ']'];
        end
        txt_summary = sprintf('%s\n', [txt_summary, field_name, ': ', spaces, field_value]);
    end
    set(ui_summary, 'String', txt_summary);
    set(ui_summary, 'FontName', 'FixedWidth');  
    is_ui_toclipboard(cf, ui_handles.uitab_quickview_summary, [20 20], txt_summary);    
        
end


function update_additional_wavefront(~, ~, cf)
% load image that will serve as the target into the workspace

    if nargin < 3
        cf = gcbf;
    end
    
    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures');
    ui_zernikes =getappdata(cf, 'ui_zernikes');
    ui_defaults= getappdata(cf, 'ui_defaults'); 

    data = get(ui_handles.add_Wxy, 'Tag');
    if(~isempty(data))
        load(get(ui_handles.add_Wxy, 'Tag'), 'data');
        
        r = str2double(get(ui_handles.add_Wxy_radius, 'String'));
        scale = str2double(get(ui_handles.add_Wxy_scale, 'String'));

        Wxy = data.Wxy;

        pupil_support = size(data.Wxy, 1);
        v = (-pupil_support:1:pupil_support-1)/pupil_support; %asymm.
        [x,y] = meshgrid(v);	                                          		

        x = x*r*scale;
        y = y*r*scale;
        
        set(ui_zernikes(1), 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0.001));
        
    else

        r = ui_defaults.pupil_radius;
        scale = 1.0;
        
        pupil_support = 2^(ui_defaults.pupil_bits - 1);
        v = (-pupil_support:1:pupil_support-1)/pupil_support; %asymm.
        [x,y] = meshgrid(v);	                                          		

        pupil_support = elliptical_pupil(x, y, 0, 0);           
        Wxy = abs(pupil_support <= 1);
        Wxy(Wxy == 0) = NaN;
        Wxy(~isnan(Wxy)) = 0;
        
        x = x*r*scale;
        y = y*r*scale;
        
        set(ui_zernikes(1), 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0.0));
        
    end
    
    set(0, 'CurrentFigure', cf);
    pause(0.1);

    ax = subplot(1,1,1, 'Parent', ui_handles.add_Wxy);

        imagesc(Wxy, 'XData', x(1,:), 'YData', y(:,1));
        xlabel(t('X [mm]'),'FontSize', ui_figures.fontsize_axes);
        ylabel(t('Y [mm]'),'FontSize', ui_figures.fontsize_axes);
        colorbar('peer', ax, 'vert');
        axis square; colormap('jet');
        
end
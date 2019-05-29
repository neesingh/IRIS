function calc_opthalmic( ~, ~, cf )
% Displays the Ophtalmic Coefficients panel in the Launcher.
% J. Porter - Adaptive Optics for Vision Science (Wiley 2006)

    if(nargin<3), cf = gcbf; end;

    ui_handles = getappdata(cf, 'ui_handles');
    ui_zernikes= getappdata(cf, 'ui_zernikes');
    
    almost_zero = eps*10^6;
    
    bar_colors = [  0.30, 0.30, 0.50;
                    0.70, 0.30, 0.40;
                    0.30, 0.89, 0.60;
                    0.40, 0.80, 0.99;
                    0.40, 0.99, 0.80];
    
    z = zeros(length(ui_zernikes),1);
    r = str2double(get(ui_handles.pupil_radius, 'String'));
    
    for i = 1:length(ui_zernikes)
        z(i) = str2double(get(ui_zernikes(i), 'String'));
        % make sure that neither is zero, to avoid ugly looking NaN's (cosmetics)
        z(i) = (abs(z(i)) > almost_zero) * z(i) + (abs(z(i)) <= almost_zero)*almost_zero;
    end
    
    RMS     = sqrt(sum(z(4:end).^2));
    
    alpha = 0.5*atan(z(4)/z(6));
    A = z(4)*2*sqrt(6)/sin(2*alpha);
    D = 2*sqrt(3)*z(5)-A/2;
    
    % https://www.researchgate.net/post/How_can_I_convert_Zernike_modes_in_micrometer_to_Diopter
    
    cylinder_axis = alpha*180/pi;
    if(cylinder_axis < 0), cylinder_axis = 90 + cylinder_axis; end
    cylinder = - 2*A/r^2;
    sphere = - 2*D/r^2;
    
    % power vectors;
    M   = (sphere + cylinder/2);
    J0  = -(cylinder/2)*cos(2*alpha);
    J45 = -(cylinder/2)*sin(2*alpha);
    
    % MTR metric
    mtr_a = struct();
    mtr_a.zernikes = z;
    mtr_a.r = r;
    mtr_a.step_id = 1;
    
    mtr_s = struct();
    mtr_s.selected_zernike = 1;
    mtr_s.analysis_range = 0;
    
    MTR = iqm_mtr(mtr_a, mtr_s);
    
    % basic ophthalmic coefficients
    sph_eq = - z(5)*(4*sqrt(3))/r^2;
    %sph_eq  = - 4*pi*sqrt(3)*RMS/(pi*r^2);
    sa      = z(13)*24*sqrt(5)/r^4;

    coma    = - 9*sqrt(8)*sqrt(z(8)^2+z(9)^2)/r^3;
    coma_axis= atan(z(9)/z(8))*180/pi;  
    if(coma_axis < 0), coma_axis = 90 - coma_axis; end
    
    set(ui_handles.wavefront_rms,   'String', sprintf('%4.3f', RMS));
    set(ui_handles.rx_spherical_eq, 'String', sprintf('%4.3f', sph_eq));
    
    out = sprintf('%s %4.3f', t('RMS Wavefront Error:'), RMS);
    out = sprintf('%s\n%s %4.3f', out, t('Spherical Equivalent [D]:'), sph_eq);
    
    set(ui_handles.rx_sphere,       'String', sprintf('%4.3f', sphere));
    set(ui_handles.rx_spherical,    'String', sprintf('%4.3f', sa));
    
    set(ui_handles.rx_M,            'String', sprintf('%4.3f', M));
    set(ui_handles.rx_J0,           'String', sprintf('%4.3f', J0));
    set(ui_handles.rx_J45,          'String', sprintf('%4.3f', J45));
    set(ui_handles.rx_mtr_eq,       'String', sprintf('%4.3f', MTR));
    
    out = sprintf('%s\n%s %4.3f', out, t('Sphere [D]:'), sphere);
    out = sprintf('%s\n%s %4.3f', out, t('Spherical Aberration [D/mm2]:'), sa);
    
    set(ui_handles.rx_cylinder,     'String', sprintf('%4.3f', cylinder));
    set(ui_handles.rx_cylinder_axis,'String', sprintf('%4.1f', cylinder_axis));
    
    out = sprintf('%s\n%s %4.3f', out, t('Cylinder [D]:'), cylinder);
    out = sprintf('%s\n%s %4.3f', out, t('Axis [deg]:'), cylinder_axis);
      
    set(ui_handles.rx_coma,         'String', sprintf('%4.3f', coma));
    set(ui_handles.rx_coma_axis,    'String', sprintf('%4.1f', coma_axis));
    
    out = sprintf('%s\n%s %4.3f', out, t('Coma [D/mm]:'), coma);
    out = sprintf('%s\n%s %4.3f', out, t('Axis [deg]:'), coma_axis);
    
    is_ui_toclipboard(cf, ui_handles.uitab_ophtalmic, [20 20], strrep(out, '.', ','));
       
    if(get(ui_handles.correct_defocus, 'Value'))
        z(5) = 0;
        z(abs(z) <= almost_zero) = 0; % zero bars that otherwise would show eps
    end
    
    subplot(1,1,1, 'parent', ui_handles.zernike_bars);
        cla;
        hold on;
        for i=2:mode2index(min(length(z),21))
            first_zernike = index2mode(i,-i);
            indices = first_zernike:first_zernike+i;  
            bar(indices-1, z(indices), 'facecolor', bar_colors(i-1, :))
        end
        stem(4, 0, 'rx');
        hold off;
        
        xlabel(t('Zernike Term')); ylabel(t('Coefficient Value [um]'));
        set(gca,'XMinorTick','on'); xlim([2 indices(end)]); 
        set(gca,'XMinorGrid','on'); set(gca,'YMinorGrid','on');
end


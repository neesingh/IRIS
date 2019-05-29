function populate_zernikes( cf, zernikes, pupil_radius, source, filename )

    generate_zernikes_pyramid(cf, length(zernikes));
    
    ui_zernikes = getappdata(cf, 'ui_zernikes');
    ui_handles  = getappdata(cf, 'ui_handles');
    ui_defaults = getappdata(cf, 'ui_defaults');
    %ui_devices = getappdata(cf, 'ui_devices');
    
    title = get(cf, 'name');
    num = strfind(title, ' - ');
    if(~isempty(num)), title = title((num+3):end); end
    title = [filename, ' - ', title];

    for i = 1:length(ui_zernikes)
        set(ui_zernikes(i), 'String', '0.0');
    end
        
    for i = 1:min(length(ui_zernikes), length(zernikes))
        pos = sign(zernikes(i)) > 0;
        neg = sign(zernikes(i)) < 0;
        set(ui_zernikes(i), 'String', sprintf(['%',ui_defaults.float_precision,'f'], zernikes(i)));
        set(ui_zernikes(i), 'BackgroundColor', [neg*0.4+0.5 pos*0.4+0.5 ((neg+pos)==0)*0.6+0.3]);
    end


    set(ui_handles.pupil_radius, 'String', sprintf(['%',ui_defaults.float_precision,'f'], pupil_radius));
    set(ui_handles.pupil_radius_recalc, 'String', sprintf(['%',ui_defaults.float_precision,'f'], pupil_radius));
    set(ui_handles.zernike_rotation, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
    set(ui_handles.zernike_translate_x, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
    set(ui_handles.zernike_translate_y, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
    set(ui_handles.propagate_Wxy, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));

    set_source_params(cf, source);
    
    set(cf, 'name', title);
    
    [order, frequency] = mode2index(ui_defaults.selected_zernike);
    if(ui_defaults.selected_zernike == 5), units = 'D'; else units = 'um'; end
    set(ui_handles.mode_single, 'String', sprintf(t('Single Analysis - C(%s,%s) [%s]'), num2str(order), num2str(frequency), units));
    set(ui_handles.mode_through,'String', sprintf(t('Through Zernike - C(%s,%s) [%s]'), num2str(order), num2str(frequency), units));
    
    analysis_quickview( [], [], gcbf );
    calc_opthalmic( [], [], gcbf );

end

function set_source_params(cf, source)

    ui_handles  = getappdata(cf, 'ui_handles');
    ui_defaults = getappdata(cf, 'ui_defaults');
    ui_devices = getappdata(cf, 'ui_devices');

    for i = 1:length(ui_devices)
        if(strcmp(ui_devices{i}.id, source)), break; end
    end
    %set(ui_handles.zernike_source, 'String', ui_devices{i}.name);
    set(ui_handles.zernike_source, 'Value', i);
    set(ui_handles.device_lambda, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_devices{i}.lambda));
    
end


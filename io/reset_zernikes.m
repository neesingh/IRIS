function reset_zernikes(~, ~)

    ui_handles =  getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    ui_devices = getappdata(gcbf, 'ui_devices');
    
    generate_zernikes_pyramid( gcbf, ui_defaults.initial_zernikes );
    
    title = get(gcbf, 'name');
    num = strfind(title, ' - ');
    if(~isempty(num))
        title = title((num+3):end);
        set(gcbf, 'name', title);
    end
    
    set(ui_handles.pupil_radius, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_defaults.pupil_radius));
    set(ui_handles.zernike_rotation, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
    set(ui_handles.pupil_radius_recalc, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_defaults.pupil_radius));
    set(ui_handles.device_lambda, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_devices{1}.lambda));
    set(ui_handles.propagate_Wxy, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0));
    set(ui_handles.zernike_source, 'Value', 1);
    set(ui_handles.generate_normal, 'Value', 1);
    
    [order, frequency] = mode2index(ui_defaults.selected_zernike);
    if(ui_defaults.selected_zernike == 5), units = 'D'; else units = 'um'; end
    set(ui_handles.mode_single, 'String', sprintf(t('Single Analysis - C(%s,%s) [%s]'), num2str(order), num2str(frequency), units));
    set(ui_handles.mode_through,'String', sprintf(t('Through Zernike - C(%s,%s) [%s]'), num2str(order), num2str(frequency), units));
    analysis_quickview( [], [], gcbf );
    calc_opthalmic( [], [], gcbf );

end
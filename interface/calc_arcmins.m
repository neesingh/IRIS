function calc_arcmins( ~, ~ )

    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');

    height = max(1, round(str2double(get(ui_handles.image_height, 'String'))));
    distance = str2double(get(ui_handles.image_distance, 'String'));
    
    val = sprintf(['%',ui_defaults.float_precision,'f'], atan(height/2/distance)*10800/pi);
    set(ui_handles.calculated_arcmins, 'String', val);
    set(ui_handles.image_arcmins, 'String', val);
end


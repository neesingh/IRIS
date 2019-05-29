function calc_pixsize( ~, ~ )

    ui_handles = getappdata(gcbf, 'ui_handles');

    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');

    pixels = max(1, round(str2double(get(ui_handles.image_pixels, 'String'))));
    arcmins = str2double(get(ui_handles.image_arcmins, 'String'));
    set(ui_handles.image_pixels, 'String', num2str(pixels));
    set(ui_handles.image_pixsize, 'String', num2str(arcmins/pixels)); % important - although hidden, it's from here that the data gets passed further
    set(ui_handles.calculated_pixsize, 'String', sprintf(['%',ui_defaults.float_precision,'f'], arcmins/pixels));
    set(ui_handles.target_thumb, 'String', sprintf(['%',ui_defaults.float_precision,'f [am/px]'], arcmins/pixels));

end


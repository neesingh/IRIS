function divide_zernikes(~, ~, by)
    
    ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    
    by = str2double(get(by, 'String'));
    
    for z = 1:length(ui_zernikes)
        zernike = str2double(get(ui_zernikes(z), 'String'))/by;
        zernike = sprintf(['%',ui_defaults.float_precision,'f'], zernike);
        set(ui_zernikes(z), 'String', zernike);
    end

    show_msg(gcbf, sprintf('All %d Zernike coefficients divided by %3.2f.', length(ui_zernikes), by));
        
end
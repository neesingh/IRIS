function copy_zernikes(~, ~)
% Copy the Zernike Coefficients data to clipboard

    ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    ui_handles = getappdata(gcbf, 'ui_handles');

    pupil_radius = strrep(get(ui_handles.pupil_radius, 'String'), '.', ',');
    zernike_str = sprintf('r %s', pupil_radius);

    for z = 1:length(ui_zernikes)
        zernike = strrep(get(ui_zernikes(z), 'String'), '.', ',');
        [o, f] = mode2index(z);
        zernike_str = sprintf('%s\nc(%d,%d) %s', zernike_str, o, f, zernike);
    end

    clipboard('copy', zernike_str);
    show_msg(gcbf, t('Zernike Data Copied to Clipboard'));
    
end


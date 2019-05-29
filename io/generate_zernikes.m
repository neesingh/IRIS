function [ zernikes, pupil_radius ] = generate_zernikes(~, ~)
% Display a popup window with settings of models of eyes used to generate
% the zernike coefficients.
    
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    ui_handles = getappdata(gcbf, 'ui_handles');
    %ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    
    if(get(ui_handles.generate_normal, 'Value') ==  1)
        mode = 'N';
        word = t('normal');
    else
        mode = 'K';
        word = t('keratoconic');
    end
    
    tic; zernikes = WF_Model(1, mode); % 1 as in one eye
    tt = toc;
    
    pupil_radius = 2.5;
    source = 'manual';
        
    % truncate unorthodox modes yarr
    valid_modes = [6 15 21 28 36 45 55 66 1000];
    idx = find(valid_modes >= length(zernikes), 1, 'first');
    if(valid_modes(idx) > ui_defaults.zernike_import_cap)
        show_msg(gcbf, sprintf('%d imported coefficients, truncating to 66.', valid_modes(idx)));
    end
    valid_modes = min(ui_defaults.zernike_import_cap, valid_modes(idx));
    %zernikes = [0, 0, 0, zernikes];
    zernikes = zernikes(1:valid_modes);

    show_msg(gcbf, sprintf('Generated a new %s eye in %3.3f ms.', word, tt));
    populate_zernikes(gcbf, zernikes, pupil_radius, source, t('New Eye, Unsaved'));

end
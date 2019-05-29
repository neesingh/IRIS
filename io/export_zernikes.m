function export_zernikes(~, ~)
% Export data as a .mat file

    ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    ui_devices = getappdata(gcbf, 'ui_devices');
       
    [filename, pathname] = uiputfile({ '*.mat', t('Matlab MAT data file')},...
                                       'Save Data As', ui_defaults.current_filepath);

    zernikes = zeros(length(ui_zernikes),1);

    pupil_radius = str2double(get(ui_handles.pupil_radius, 'String'));
    source = get(ui_handles.zernike_source, 'Value');
    source = ui_devices{source}.id;

    for z = 1:length(ui_zernikes)
        zernikes(z) = str2double(get(ui_zernikes(z), 'String'));
    end

    if ~isequal(filename,0) || ~isequal(pathname,0)   
        save(fullfile(pathname, filename), 'zernikes', 'pupil_radius', 'source');
        
        title = get(gcbf, 'name');
        num = strfind(title, ' - ');
        if(~isempty(num)), title = title((num+3):end); end
        title = [filename, ' - ', title];
        set(gcbf, 'name', title);
        
        ui_defaults.current_filepath = pathname;
        setappdata(gcbf, 'ui_defaults', ui_defaults);
        
        show_msg(gcbf, sprintf('Saved as file %s.', filename));
    end
end
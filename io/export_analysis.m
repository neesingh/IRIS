function export_analysis(a, s)
% Save the performed analysis (a - analysis and s - settings data
% structures) to not have to repeat the simulation again.

    %ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    %ui_handles = getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    %ui_devices = getappdata(gcbf, 'ui_devices');
       
    [filename, pathname] = uiputfile({ '*.mat', t('Matlab MAT data file')},...
                                       'Save Data As', ui_defaults.current_filepath);

    if ~isequal(filename,0) || ~isequal(pathname,0)   
        save(fullfile(pathname, filename), 'a', 's');
        
        title = get(gcbf, 'name');
        num = strfind(title, ' - ');
        if(~isempty(num)), title = title((num+3):end); end
        title = [filename, ' - ', title];
        set(gcbf, 'name', title);
        
        ui_defaults.current_filepath = pathname;
        setappdata(gcbf, 'ui_defaults', ui_defaults);
        
        show_msg(gcbf, sprintf('Analysis exported to %s.', filename));
    end
end
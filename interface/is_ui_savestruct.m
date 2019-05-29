function is_ui_savestruct( cf, axis_handle, position, structToSave )
%IS_UI_SAVEIMG Outputs a uicontrol pushbutton that allows the user to save
%a structure associated with the specified axis.

    ui_figures = getappdata(cf, 'ui_figures');
    
    panel = get(axis_handle, 'Parent');
    icon = imread('export.png');
    
    pos = [position(1) position(2) 1.4*size(icon,1) 1.4*size(icon,2)];

    uicontrol(  'Parent', panel, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'pixels', 'Position', pos, 'cdata', icon,...
                'Callback', { @is_saveimg, cf, structToSave });
    uicontrol(  'Parent', panel, 'Style', 'text', 'cdata', icon, 'String', 'Save',...
                'BackgroundColor', ui_figures.bg_figure, 'ForegroundColor', ui_figures.fontcolor_primary,...
                'FontSize', 0.9*ui_figures.fontsize_panel,...
                'Units', 'pixels', 'Position', [20 pos(2)+pos(4) pos(3) 2*ui_figures.fontsize_panel]);

end

function is_saveimg(~, ~, cf, data)

    ui_defaults = getappdata(cf, 'ui_defaults');

    [filename, pathname] = uiputfile({ '*.mat', t('Matlab data file')},...
                                       t('Save Data As'), ui_defaults.current_filepath);
                                   
    if ~isequal(filename,0) || ~isequal(pathname,0)
        save(fullfile(pathname, filename), 'data');
        
        ui_defaults.current_filepath = pathname;
        setappdata(cf, 'ui_defaults', ui_defaults);
    end
end


function is_ui_saveimg( cf, axis_handle, position )
%IS_UI_SAVEIMG Outputs a uicontrol pushbutton that allows the user to save
%a graphics object within the specified axis.

    ui_figures = getappdata(cf, 'ui_figures');
    
    panel = get(axis_handle, 'Parent');
    icon = imread('save.png');
    
    pos = [position(1) position(2) 1.4*size(icon,1) 1.4*size(icon,2)];
    
    img = getimage(axis_handle);

    uicontrol(  'Parent', panel, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_simulation,...
                'Units', 'pixels', 'Position', pos, 'cdata', icon,...
                'Callback', { @is_saveimg, cf, img });
    uicontrol(  'Parent', panel, 'Style', 'text', 'cdata', icon, 'String', 'Save',...
                'BackgroundColor', ui_figures.bg_simulation, 'ForegroundColor', [1.0 1.0 1.0],...
                'FontSize', 0.9*ui_figures.fontsize_panel,...
                'Units', 'pixels', 'Position', [20 pos(2)+pos(4) pos(3) 2*ui_figures.fontsize_panel]);

end

function is_saveimg(~, ~, cf, img)

    ui_defaults = getappdata(cf, 'ui_defaults');

    [filename, pathname] = uiputfile({ '*.png', 'PNG Image File';... 
                                       '*.jpg', 'JPG Image File';...
                                       '*.bmp', 'BMP Image File (uncompressed)'},...
                                       'Save Image As', ui_defaults.current_filepath);
                                   
    img = img/max(max(img(:)));
    if ~isequal(filename,0) || ~isequal(pathname,0)
        imwrite(img, fullfile(pathname, filename));
        
        ui_defaults.current_filepath = pathname;
        setappdata(cf, 'ui_defaults', ui_defaults);
    end
end


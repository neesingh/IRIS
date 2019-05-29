function is_ui_saveclipboard( cf, axis_handle, position, data )
%IS_UI_SAVEIMG Outputs a uicontrol pushbutton that allows the user to save
%a graphics object within the specified axis.

    ui_figures = getappdata(cf, 'ui_figures');
    
    panel = get(axis_handle, 'Parent');
    icon = imread('clipboard.png');
    
    pos = [position(1) position(2) 1.4*size(icon,1) 1.4*size(icon,2)];

    uicontrol(  'Parent', panel, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'pixels', 'Position', pos, 'cdata', icon,...
                'Callback', { @is_saveclipboard, data });
    uicontrol(  'Parent', panel, 'Style', 'text', 'cdata', icon, 'String', 'Copy',...
                'BackgroundColor', ui_figures.bg_white,...
                'FontSize', 0.9*ui_figures.fontsize_panel,...
                'Units', 'pixels', 'Position', [20 pos(2)+pos(4) pos(3) 2*ui_figures.fontsize_panel]);

end

function is_saveclipboard(~, ~, data)

    clipboard('copy', data);
    
end


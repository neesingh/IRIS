function is_ui_toclipboard( cf, axis_handle, position, text )
% is_ui_toclipboard - outputs a uicontrol pushbutton that allows the user to save
% text from within the specified axis.

    ui_figures = getappdata(cf, 'ui_figures');
    
    panel = axis_handle;
    icon = imread('clipboard.png');
    
    pos = [position(1) position(2) 1.4*size(icon,1) 1.4*size(icon,2)];

    uicontrol(  'Parent', panel, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'pixels', 'Position', pos, 'cdata', icon,...
                'Callback', { @is_toclipboard, cf, text });
    uicontrol(  'Parent', panel, 'Style', 'text', 'cdata', icon, 'String', 'Copy',...
                'BackgroundColor', get(panel, 'BackgroundColor'), 'ForegroundColor', [0 0 0],...
                'FontSize', 0.9*ui_figures.fontsize_panel,...
                'Units', 'pixels', 'Position', [20 pos(2)+pos(4) pos(3) 2*ui_figures.fontsize_panel]);

end

function is_toclipboard(~, ~, cf, text)

    clipboard('copy', text);
    show_msg(cf, 'Summary Copied To Clipboard');
    
end


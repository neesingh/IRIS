function is_ui_saveplot( cf, axis_handle, position )
%IS_UI_SAVEIMG Outputs a uicontrol pushbutton that allows the user to save
%a plot object within the specified axis.

    ui_figures = getappdata(cf, 'ui_figures');
    
    panel = get(axis_handle, 'Parent');

    icon = imread('save_plot.png');
    
    pos = [position(1) position(2) 1.4*size(icon,1) 1.4*size(icon,2)];

    uicontrol(  'Parent', panel, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'pixels', 'Position', pos, 'cdata', icon,...
                'Callback', { @is_saveplot, cf, axis_handle });
    uicontrol(  'Parent', panel, 'Style', 'text', 'cdata', icon, 'String', 'Save',...
                'BackgroundColor', ui_figures.bg_charts,...
                'FontSize', ui_figures.fontsize_panel,...
                'Units', 'pixels', 'Position', [20 pos(2)+pos(4) pos(3) 2*ui_figures.fontsize_panel]);

end

function is_saveplot(~, ~, cf, axis_handle)

    ui_defaults = getappdata(cf, 'ui_defaults');

    [filename, pathname] = uiputfile({ '*.pdf', 'PDF document'},...
                                       'Save Figure As', ui_defaults.current_filepath);
                                   
    if ~isequal(filename,0) || ~isequal(pathname,0)
        panel = get(axis_handle, 'Parent');
        
        found = 0;
        tries = 4; t = 1;
        while( found == 0 && t <= tries )
            
            try
                set(panel, 'PaperOrientation', 'landscape');
                found = 1;
            catch
                panel = get(panel, 'Parent');
                t = t+1;
            end
            
        end
        
        if(found == 1)
            set(panel, 'PaperUnits', 'normalized');
            %set(panel, 'PaperPositionMode', 'Manual');
            %set(panel, 'PaperPosition', [-0.125 -0.085 1.75 1.27]);

            set(panel, 'PaperPosition', [-0.125 -0.085 1.75 1.27]);
            saveas(panel, fullfile(pathname, filename), 'pdf');
        end

        ui_defaults.current_filepath = pathname;
        setappdata(cf, 'ui_defaults', ui_defaults);
    end
end


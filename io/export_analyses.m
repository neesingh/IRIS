function export_analyses(~, ~, cf, analyses, s, sourceFigure) %#ok<*INUSD>
% Save the performed analysis (a - analysis and s - settings data
% structures) to not have to repeat the simulation again.

    if(nargin < 6)
        sourceFigure = 'iqm'; % or iqm / sim / mtf
    end
    %ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    %ui_handles = getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(cf, 'ui_defaults');
    %ui_devices = getappdata(gcbf, 'ui_devices');
       
    [filename, pathname] = uiputfile({ '*.mat', t('Matlab MAT data file')},...
                                       'Save Data As', ui_defaults.current_filepath);

    % remove all graphics handles from the structure, or else Matlab will
    % save 800 Mb of figure data for each step!
    s = rmfield(s, 'cf');
    
    fields = fieldnames(s);
    for i = 1:numel(fields)
        field = fields{i};
        if(strcmp(field(1:min(length(field),3)), 'ui_'))
            s = rmfield(s, field);
        end
    end
    
    if ~isequal(filename,0) || ~isequal(pathname,0)
        
        %f = figure(666);
        %set(f, 'name', 'Saving Analysis Data');
        %uicontrol(  'Style', 'text',...
        %            'String', 'Please Wait. This process may take a while depending on the number of analysis steps...',...
        %            'Units', 'normalized',...
        %            'Position', [0.9 0.2 0.1 0.1]);
        
        controls_onoff_toggle(gcbf);
        save(fullfile(pathname, filename), 'analyses', 's', 'sourceFigure', '-v7.3');
        controls_onoff_toggle(gcbf);
        
        %close(f);
        
        title = get(gcbf, 'name');
        num = strfind(title, ' - ');
        if(~isempty(num)), title = title((num+3):end); end
        title = [filename, ' - ', title];
        set(gcbf, 'name', title);
        
        ui_defaults.current_filepath = pathname;
        setappdata(cf, 'ui_defaults', ui_defaults);
        
        show_msg(cf, sprintf('Analysis exported to %s.', filename));
    end
end
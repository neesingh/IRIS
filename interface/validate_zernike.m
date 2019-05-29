function validate_zernike(hObject, ~, default_value)
    % Validate user input so that they don't enter weird crap in editboxes
    % where they should be putting DOUBLE values
    
    ui_figures = getappdata(gcbf, 'ui_figures');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    
    if(nargin < 3)
        default_value = 0;
    end
    
    val = get(hObject, 'String');
    val = strrep(val, ',', '.');
    numval = str2double(val);

    if( isnan(str2double(val)) )
        set(hObject, 'String', sprintf(['%',ui_defaults.float_precision,'f'], default_value));
        set(hObject, 'BackgroundColor', ui_figures.bg_edit);
    else
        pos = sign(numval) > 0;
        neg = sign(numval) < 0;
        set(hObject, 'String', val);
        set(hObject, 'BackgroundColor', [neg*0.5+0.4 pos*0.5+0.4 0.4]);
        %analysis_quickview(gcbf);
    end
    
end


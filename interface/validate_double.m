function validate_double(hObject, ~, default_value)
    % Validate user input so that they don't enter weird crap in editboxes
    % where they should be putting DOUBLE values
    
    ui_defaults = getappdata(gcbf, 'ui_defaults');

    if(nargin < 3)
        default_value = 0;
    end
    
    val = get(hObject, 'String');
    val = strrep(val, ',', '.');
    numval = str2double(val);

    if( isnan(numval) )
        set(hObject, 'String', sprintf(['%',ui_defaults.float_precision,'f'], default_value));
    else
        set(hObject, 'String', val);
    end
end


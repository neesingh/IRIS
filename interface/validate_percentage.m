function validate_percentage(hObject, ~, default_value)
    % Validate user input so that they don't enter weird crap in editboxes
    % where they should be putting PERCENTAGE values
    
    if(nargin < 3)
        default_value = 1;
    end
    
    val = get(hObject, 'String');
    val = strrep(val, ',', '.');

    if( isnan(str2double(val))||str2double(val)<=0||str2double(val)>=100 )
        set(hObject, 'String', sprintf('%1.0f', default_value));
    else
        set(hObject, 'String', num2str(round(str2double(val))));
    end
end


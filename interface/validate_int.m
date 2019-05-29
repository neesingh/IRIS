function validate_int(hObject, ~, default_value)
    % Validate user input so that they don't enter weird crap in editboxes
    % where they should be putting INT values
    
    if(nargin < 3)
        default_value = 1;
    end
    
    val = get(hObject, 'String');
    val = strrep(val, ',', '.');

    if( isnan(str2double(val))||str2double(val)==0 )
        set(hObject, 'String', sprintf('%1.1f', default_value));
    else
        set(hObject, 'String', num2str(round(str2double(val))));
    end
end


function update_spd( hObject, ~, hSpd_dropdown, target_axes, default_value )
% UPDATE_SPD Updates the SPD plot after the user changes the number of
% samples.

    val = get(hObject, 'String');
    val = strrep(val, ',', '.');
    idx = get(hSpd_dropdown, 'Value');

    if( isnan(str2double(val))||str2double(val)==0 )
        set(hObject, 'String', sprintf('%1.1f', default_value));
    else
        set(hObject, 'String', num2str(round(str2double(val))));
        plot_spd([], idx, target_axes, hObject);
    end

end


function change_selected_zernike( ~, args, ui_handles )
%CHANGE_SELECTED_ZERNIKE Update the interface after the user selects a different zernike radiobox for analysis

    mode = str2double(get(args.NewValue, 'Tag'));
    [order, frequency] = mode2index(mode+1);
    
    if(mode == 4)
        units = 'D';
    else
        units = 'um';
    end
    
    set(ui_handles.mode_single, 'String', sprintf(t('Single Analysis - C(%s,%s) [%s]'), num2str(order), num2str(frequency), units));
    set(ui_handles.mode_through,'String', sprintf(t('Through Zernike - C(%s,%s) [%s]'), num2str(order), num2str(frequency), units));

end


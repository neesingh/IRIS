function  set_target_image( ~, args, cf )

    ui_handles = getappdata(cf, 'ui_handles');

    if(isempty(args))
        chn = 0;
    else
        chn = str2double(args.NewValue.Tag);
    end
    
    imgdata = get(ui_handles.original_image, 'UserData');
    if(chn >= 1)
        set(ui_handles.target_image, 'UserData', imgdata(:,:,chn));
    else
        set(ui_handles.target_image, 'UserData', imgdata);
    end
    
    setappdata(cf, 'ui_handles', ui_handles);
    
end


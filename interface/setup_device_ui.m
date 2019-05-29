function setup_device_ui(h, ~, device_lambda_textbox)
    % Fill in the aberrometer-device related parameters (device lambda)
    % after selecting it from the dropdown menu
    
    ui_devices = getappdata(gcbf, 'ui_devices');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    
    set(device_lambda_textbox, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_devices{ get(h, 'Value') }.lambda));

end


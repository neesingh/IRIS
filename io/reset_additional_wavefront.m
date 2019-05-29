function reset_additional_wavefront(~, ~, cf)
% load image that will serve as the target into the workspace

    if nargin < 3
        cf = gcbf;
    end
    
    ui_handles = getappdata(cf, 'ui_handles');
    ui_defaults= getappdata(cf, 'ui_defaults'); 
            
    set(ui_handles.add_Wxy_radius, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_defaults.pupil_radius));
    set(ui_handles.add_Wxy_lambda, 'String', sprintf(['%',ui_defaults.float_precision,'f'], ui_defaults.reference_lambda));
    set(ui_handles.add_Wxy_scale, 'String', sprintf(['%',ui_defaults.float_precision,'f'], 1.0));
    set(ui_handles.add_Wxy, 'Tag', '');
    
    update_additional_wavefront([], [], cf);

end
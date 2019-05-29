function load_pupil_mask(~, ~)
% Load image that will be applied on top of the pupil apodization function Axy
% to simulate any type of ocular occlusion, cataract, etc.

    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_figures = getappdata(gcbf, 'ui_figures');
    ui_defaults= getappdata(gcbf, 'ui_defaults');

    [filename, pathname, ~] = uigetfile({ '*.jpg;*.tif;*.hdf;*.png;*.bmp', t('Compatible Image Files')},...
                                                    t('Select an image file to import'), ui_defaults.current_filepath,...
                                                    'MultiSelect', 'off');
    go = 0;

    if ~isequal(filename,0)
        go = 1;
        mask_img = double(imread(fullfile(pathname, filename)));
        mask_img = mask_img/(2^ui_defaults.bpp);
        
        ui_defaults.current_filepath = pathname;
        setappdata(gcbf, 'ui_defaults', ui_defaults);
    else
        show_msg(ui_handles.cf, t('Pupil Mask removed.'));
    end
    
    if(go == 1)
        set(ui_handles.pupil_mask, 'UserData', mask_img);
        set(ui_handles.load_pupil_mask, 'String', 'Loaded');
        set(ui_handles.load_pupil_mask, 'BackgroundColor', ui_figures.bg_special);
        show_msg(ui_handles.cf, sprintf('Pupil Mask %s loaded.', filename));
    else
        set(ui_handles.pupil_mask, 'UserData', []);
        set(ui_handles.load_pupil_mask, 'String', 'None');
        set(ui_handles.load_pupil_mask, 'BackgroundColor', ui_figures.bg_figure);    
    end
       
end

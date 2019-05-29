function pupil_preview( ~, ~, cf )
% Pupil Preview - Small extra script to show the pupil shape defined by the user in the interface.
    if nargin < 3
        cf = gcbf;
    end
        
    ui_handles =  getappdata(cf, 'ui_handles');
    
    target = ui_handles.pupil_preview;
    legend = ui_handles.pupil_legend;

    rotation = get(ui_handles.pupil_rotation, 'Value');
    ellipticity = get(ui_handles.pupil_ellipticity, 'Value');
    
    analysis_from = get(ui_handles.analysis_from, 'Value');
    analysis_to = get(ui_handles.analysis_to, 'Value');
    
    if(analysis_to - analysis_from <= 0.5)
        analysis_from = -2;
        analysis_to = 2;
        set(ui_handles.analysis_from, 'Value', -2);
        set(ui_handles.analysis_to, 'Value', +2);
    end
    
    to_txt = ui_handles.to_txt;
    from_txt = ui_handles.from_txt;
    
    siz = floor(get(0, 'screensize')/20);
    siz = siz(4)/2;
    [x, y] = meshgrid((-siz:1:siz-1)/siz);
    
    pupil = elliptical_pupil(x, y, rotation, ellipticity);
    pupil = pupil <= 1;

    pupil = 255*gray2rgb(pupil); % cdata wants 3 channels
    
    set(target, 'cdata', pupil);
    set(legend, 'String', sprintf(t('Angle: %2.2f, ellipticity: %2.2f.'), rotation, ellipticity));
    set(to_txt, 'String', sprintf('%+2.1f', analysis_to));
    set(from_txt, 'String', sprintf('%+2.1f', analysis_from));
    
    
end


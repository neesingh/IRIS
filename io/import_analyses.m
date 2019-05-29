function import_analyses(~, ~, cf)
% Load a previously exported analyses file.

    ui_defaults = getappdata(cf, 'ui_defaults');
       
    [filename, pathname, ~] = uigetfile({   '*.mat', 'MAT file from Imaging Simulator'},...
                                            'Select a file to import', ui_defaults.current_filepath,...
                                            'MultiSelect', 'off');
    
    sourceFigure = [];
    if ~isequal(filename,0) || ~isequal(pathname,0)
        
        show_msg(cf, t('Loading analyses, please wait...'));
        
        controls_onoff_toggle(gcbf);
        load(fullfile(pathname, filename), 'analyses', 's', 'sourceFigure'); % will load 'analyses' and 's'
        controls_onoff_toggle(gcbf);
        
        if(exist('analyses', 'var') && exist('s', 'var') && exist('sourceFigure', 'var'))
        
            s.cf = cf;

            title = get(gcbf, 'name');
            num = strfind(title, ' - ');
            if(~isempty(num)), title = title((num+3):end); end
            title = [filename, ' - ', title];
            set(gcbf, 'name', title);

            ui_defaults.current_filepath = pathname;
            setappdata(cf, 'ui_defaults', ui_defaults);

            show_msg(cf, sprintf('Analyses imported from %s.', filename));

            if(strcmp(sourceFigure, 'iqm'))
                analysis_iq_metrics([], [], analyses, s);
            elseif(strcmp(sourceFigure, 'sim'))
                analysis_retinal_sim([], [], analyses, s);
            elseif(strcmp(sourceFigure, 'mtf'))
                analysis_mtf_ptf_pf([], [], analyses, s);
            end
            
        else
            
            warndlg(t('The specified file is not a valid IRIS analysis data file. Use the IQ Metrics analysis window (chart icon) to save analyses to be loaded.'), t('Incorrect data format'));
            
        end
        show_msg(cf, t('Ready'));
    end
end
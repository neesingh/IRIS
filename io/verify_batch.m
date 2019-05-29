function [ zernikes, pupil_radius ] = verify_batch(~, ~)
% Load each of the user-selected files of the batch and verify that it is
% importable. Output the filelist with importability information.
    
    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    
    [filename, pathname, ~] = uigetfile({   '*.dat;*.xls;*.xlsx;*.mat;*.txt', 'All Compatible Files';... 
                                            '*.dat', 'XML file from HASO';...
                                            %'*.xls;*.xlsx', 'XLS file from IRX3';...
                                            '*.txt', 'TXT file from IRX3';...
                                            '*.mat', 'MAT file from Imaging Simulator'},...
                                            'Select a file to import', ui_defaults.current_filepath,...
                                            'MultiSelect', 'on');
    if ~isequal(filename,0)
        
        ui_defaults.current_filepath = pathname;
        setappdata(gcbf, 'ui_defaults', ui_defaults);
                
        enable = 'off'; error = 0;
        status = cell(length(filename),1);
        for f = 1:length(filename)

            try
                [ zernikes, pupil_radius, ~ ] = import_parser(gcbf, filename{f}, pathname);
            catch
                error = 1;
            end

            if( ~error )                  
                status{f} = sprintf('%s%s', pathname, filename{f});
                enable = 'on';
            else
                status = sprintf(t('An import error has occurred while processing "%s". Please fix the file or avoid selecting it and try again. The batch can''t proceed.'), filename{f});
                enable = 'off';
                break;
            end

        end
        set(ui_handles.batch_switch, 'Enable', enable);                                                                             
        set(ui_handles.batch_filelist, 'String', status);
    end
    
end
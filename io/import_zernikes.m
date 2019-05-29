function [ zernikes, pupil_radius ] = import_zernikes(~, ~, mode)
% Display a popup window to select file containing zernike coefficients to import
% Parsers in this file REQUIRE MORE WORK
    
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    
    if(nargin < 3), mode = 'overwrite'; end
    
    [filename, pathname, ~] = uigetfile({   '*.dat;*.xls;*.xlsx;*.mat;*.txt;*.F4;*.F6;*.F8;*.F10;*.f4;*.f6;*.f8;*.f10;*.csv', 'All Compatible Files';... 
                                            '*.dat', 'HASO XML File';...
                                            '*.F4;*.F6;*.F8;*.F10;*.f4;*.f6;*.f8;*.f10', 'COAS Zernike Coefficients File';...
                                            '*.txt', 'IRX3 Plain Text File';...
                                            '*.csv', 'Nidek OPD-Scan III File';...
                                            '*.mat', [ui_defaults.is_name, ' Matlab Data File']},...
                                            'Select a file to import', ui_defaults.current_filepath,...
                                            'MultiSelect', 'off');
    if ~isequal(filename,0)
        
        error = 0;
        ui_defaults.current_filepath = pathname;
        setappdata(gcbf, 'ui_defaults', ui_defaults);
        
        try
            [ zernikes, pupil_radius, source ] = import_parser(gcbf, filename, pathname);
        catch
            error = 1;
        end

        if(~error)

            % truncate unorthodox modes yarr
            valid_modes = [6 15 21 28 36 45 55 66 1000];
            idx = find(valid_modes >= length(zernikes), 1, 'first');
            if(valid_modes(idx) > ui_defaults.zernike_import_cap)
                show_msg(gcbf, sprintf('%d imported coefficients, truncating to 66.', valid_modes(idx)));
            end
            valid_modes = min(ui_defaults.zernike_import_cap, valid_modes(idx));
            zernikes = zernikes(1:valid_modes);

            if(strcmp(mode, 'add')) % a mode where one can add up aberrations on top of each other
                pupil_radius = (str2double(get(ui_handles.pupil_radius, 'String')) + pupil_radius)/2;
                uiz = zeros(length(ui_zernikes),1);
                for z = 1:length(ui_zernikes)
                    uiz(z) = str2double(get(ui_zernikes(z), 'String'));
                end

                z = zeros(max(length(zernikes), length(uiz)),1);
                z(1:length(uiz)) = uiz;

                if(size(zernikes,2)>size(zernikes,1)), zernikes = zernikes'; end
                z(1:length(zernikes)) = z(1:length(zernikes)) + zernikes;
                zernikes = z;
            end

            show_msg(gcbf, sprintf('Loaded file %s.', filename));
            show_msg(gcbf, sprintf('Succesfully imported %d coefficients.', length(zernikes)));
            populate_zernikes(gcbf, zernikes, pupil_radius, source, filename);

        else
            show_msg(gcbf, sprintf('Error while processing %s.', filename), 'error');
        end
    end
end
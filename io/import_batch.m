function [ zernikes, pupil_radius ] = import_batch(~, ~, mode)
% Display a popup window to select file containing zernike coefficients to import
% Parsers in this file REQUIRE MORE WORK
    
    ui_defaults = getappdata(gcbf, 'ui_defaults');
    ui_handles = getappdata(gcbf, 'ui_handles');
    ui_zernikes = getappdata(gcbf, 'ui_zernikes');
    
    if(nargin < 3), mode = 'overwrite'; end
    
    [filename, pathname, ~] = uigetfile({ '*.dat;*.xls;*.xlsx;*.mat;*.txt', 'All Compatible Files';... 
                                                    '*.dat', 'XML file from HASO';...
                                                    %'*.xls;*.xlsx', 'XLS file from IRX3';...
                                                    '*.txt', 'TXT file from IRX3';...
                                                    '*.mat', 'MAT file from Imaging Simulator'},...
                                                    'Select a file to import',...
                                                    'MultiSelect', 'on');

    set(ui_handles.batch_filelist, 'String', filename);
    
    % [ zernikes, pupil_radius, source ] = import_parser(gcbf, filename, pathname);
    zernikes = [];
    
    if(~isempty(zernikes))
        
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
            
            if(size(zernikes,2)>size(zernikes,1)), zernikes = zernikes'; end;
            z(1:length(zernikes)) = z(1:length(zernikes)) + zernikes;
            zernikes = z;
        end
        
        show_msg(gcbf, sprintf('Loaded file %s.', filename));
        show_msg(gcbf, sprintf('Succesfully imported %d coefficients.', length(zernikes)));
        populate_zernikes(gcbf, zernikes, pupil_radius, source, filename);
        
    end
end
function [zernikes, pupil_radius, source] = import_parser(cf, filename, pathname)

    ui_defaults = getappdata(cf, 'ui_defaults');
    %ui_devices = getappdata(cf, 'ui_devices');
    
    zernikes = []; source = ''; pupil_radius = ui_defaults.pupil_radius;
    
    if ~isequal(filename,0)
        
            ui_defaults.current_filepath = pathname;
            setappdata(cf, 'ui_defaults', ui_defaults);
        
            [~,~,ext] = fileparts(filename);
            file = fullfile(pathname, filename);
            
            switch(ext)
                
                case '.csv'
                    
                    source = 'opdscan3';
                    pre_radius_str = 'Zone : ';
                    pre_zernikes_row = 'Fitting Coefficent,Radial Order,Angular Frequency,Coefficient[um]';
                    pre_zernike_str = ',';
                    eol = newline;

                    txt = fileread(file);      

                    cut_idx = strfind(txt, pre_radius_str) + length(pre_radius_str);
                    txt = txt(cut_idx:end);

                    eols = strfind(txt, eol);
                    pupil_radius = str2double(txt(1:eols(1)-2-length(eol)))/2;

                    cut_idx = strfind(txt, pre_zernikes_row)+length(pre_zernikes_row);
                    txt = txt(cut_idx:end);
                    
                    double_eols = strfind(txt, [eol,eol]);
                    
                    txt = txt(1:double_eols(1));
                    eols = strfind(txt, eol);
                    
                    no_zernikes = length(eols)-1;

                    zernikes = zeros(1,no_zernikes);
                    for i=1:no_zernikes
                        line = txt(eols(i)+length(eol):eols(i+1));
                        line = explode(line, pre_zernike_str);
                        
                        zernikes(i) = str2double(line{4});
                    end

                    zernikes = zernikes';
                
                case {'.F4', '.F6',  '.F8', '.F10', '.f4', '.f6', '.f8', '.f10'}

                    source = 'coas';
                    load('XY2YX.mat', 'XY2YX'); % To convert coeffs to OSA format
                    
                    pre_scale_str = 'SCALE:  ';
                    eol = newline;

                    txt = fileread(file);

                    % find where the scale string is at
                    cut_idx = strfind(txt, pre_scale_str);
                    cut_idx = cut_idx + length(pre_scale_str);
                    
                    txt = txt(cut_idx:end);
                    eols = strfind(txt, eol);
                    
                    % Pupil size in meters is called “scale” given on line 2 of the *.Fn file.
                    scale = str2double(['0', strrep(txt(1:eols(1)), '"', '')]);
                    no_zernikes = str2double(txt(eols(1)+1:eols(2)));
                    
                    coeffs = zeros(no_zernikes,1);
                    for i=1:no_zernikes
                        coeffs(i) = str2double(txt( eols(i+1)+1:eols(i+2)-1 ));
                    end
                    
                    zernikes = COAS2OSAPupil([scale; coeffs], XY2YX, 1);
                    
                    pupil_radius = zernikes(1)*1E3;
                    zernikes = zernikes(2:end);
                
                case {'.txt'}

                    source = 'irx3';
                    pre_radius_str = 'Normalized pupil diameter (mm)';
                    pre_zernikes_row = 'Fitting quality';
                    pre_zernikes_str = 'm)';
                    eol = newline;

                    txt = fileread(file);      

                    cut_idx = strfind(txt, pre_radius_str) + length(pre_radius_str);
                    txt = txt(cut_idx:end);

                    eols = strfind(txt, eol);

                    pupil_radius = str2double(txt(1:eols(1)))/2;

                    cut_idx = strfind(txt, pre_zernikes_row);
                    txt = txt(cut_idx:end);

                    cut_idx = strfind(txt, pre_zernikes_str);
                    cut_idx = cut_idx + length(pre_zernikes_str);
                    eols = strfind(txt, eol); eols = eols(2:end);

                    zernikes = zeros(1,length(cut_idx));
                    for i=1:length(cut_idx)
                        zernikes(i) = str2double(txt(cut_idx(i):eols(i)));
                    end

                    zernikes = zernikes';
                    zernikes = [0; 0; 0; zernikes];

                case{'.dat'}

                    source = 'haso';
                    xml = xmlread(file);

                    [ zc, pupil_radius ] = readhasoxml( xml );

                    % the system in Murcia applies 1.9 coefficient for the radius between the HASO and MIRAO
                    pupil_radius = ui_defaults.haso_magnification * pupil_radius;

                    zc = [ 0; zc ];    

                    % we want to convert from Wyant ordering to ANSI ordering
                    [ order, freq ] = wyantmode2index( ( 1:length( zc ) )' );
                    posansi = index2mode( order, freq );

                    % we need at least up to 7th order to recalculate the coefficients
                    lenzcansi = index2mode( max( max( order ), 7 ), max( max( order ), 7 ) );

                    % create a vector to add the coefficients in the correct ANSI order
                    zernikes = zeros( lenzcansi, 1 );

                    % signs in HASO are reversed, HOWEVER on export as the MAT file this will get saved with the minus sign and on load
                    % it will not reverse the sign again.

                    % NOPE, the above makes sense but the results don't DONT CHANGE THE SIGN
                    % or maybe change it, goddamn
                    zernikes(posansi) = zc;

                    %truncate a bunch of zeros remaining at the end
                    %zernikes = zernikes(1:find((zernikes~=0),1,'last'));

                    clearvars xml;

                case{'.mat'}
                    load(file, 'zernikes', 'pupil_radius', 'source');
                    if(isempty(zernikes) && isempty(source)) 
                        show_msg(cf, t('Loaded .mat file does not contain Zernike data'), 'error');
                    end
                    % very important that it includes 'source' or else the analysis
                    % will be inconsistent in case of loading an (say) irx3 file,
                    % saving it and loading back the .mat
            end
    end 
end
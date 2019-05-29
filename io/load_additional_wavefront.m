function load_additional_wavefront(~, ~, cf)
% load image that will serve as the target into the workspace

    if nargin < 3
        cf = gcbf;
    end
    
    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures');
    ui_zernikes =getappdata(cf, 'ui_zernikes');
    ui_defaults= getappdata(cf, 'ui_defaults'); 

    [filename, pathname, ~] = uigetfile({ '*.mat', t('Matlab Data File')},...
                                          t('Select a file containing wavefront data'), ui_defaults.current_filepath, ...
                                          'MultiSelect', 'off');
                                      
    prefix = 'IRIS_';
    
    if ~isequal(filename, 0)
        
        % get the image and update the last visited path
        ui_defaults.current_filepath = pathname;
        
        go = 0;
        data = struct();
        
        load(fullfile(pathname, filename));
        if(exist('Z_wav', 'var'))
            
            r = abs(X(1,1));

            lambda = 550;
            Wxy = Z_wav .* lambda/1000;
            
            data = struct(  'Wxy', Wxy,...
                            'radius', r,...
                            'lambda', lambda,...
                            'scale', 1.0);
            go = 1;
                        
        elseif(exist('coas', 'var'))
            
            r = coas.zHalfWidth;
            Wxy = coas.zWxy;
            if(coas.settings.correctLCA == 1)
                lambda = coas.settings.lambda;
            else
                lambda = coas.settings.measurementLambda;
            end
            
            data = struct(  'Wxy', Wxy,...
                            'radius', r,...
                            'lambda', lambda,...
                            'scale', 1.0);
            go = 1;
                        
        elseif(exist('data', 'var'))
            if(isfield(data, 'Wxy'))
                go = 1;
            end
        end
        
        if(go)
            
            % Avoid having to handle different file formats down the road.
            if(~contains(filename, prefix))
                filename = [prefix, filename];
            end
            
            r = str2double(get(ui_handles.pupil_radius, 'String'));
            
            if(isfield(data, 'radius'))
                if(data.radius ~= r)
                    warndlg(sprintf(t('The loaded wavefront''s pupil radius (%3.2f) is different than the main pupil radius (%3.2f). Please make sure that the radii match to avoid unexpected results.'), data.radius, r), t('Pupil radius mismatch'));
                end
                r = data.radius;
            end
            
            lambda = str2double(get(ui_handles.device_lambda, 'String'));
            if(isfield(data, 'lambda'))
                if(data.lambda ~= lambda)
                    warndlg(sprintf(t('The loaded wavefront''s wavelength (%3.0f) is different than the device wavelength (%3.0f). Please make sure that the wavelengths match to avoid unexpected results.'), data.lambda, lambda), t('Wavelength mismatch'));
                end
                lambda = data.lambda;
            end
            
            scale = 1.0;
            if(isfield(data, 'scale'))
                scale = data.scale;
            end
            
            set(0, 'CurrentFigure', cf);
            
            pause(0.1);
                
            set(ui_handles.add_Wxy_radius, 'String', sprintf(['%',ui_defaults.float_precision,'f'], r));
            set(ui_handles.add_Wxy_scale, 'String', sprintf(['%',ui_defaults.float_precision,'f'], scale));
            set(ui_handles.add_Wxy_lambda, 'String', sprintf(['%',ui_defaults.float_precision,'f'], lambda));
            set(ui_handles.add_Wxy, 'Tag', fullfile(pathname, filename));
            save(fullfile(pathname, filename), 'data');

            pupil_support = size(data.Wxy, 1);
            v = (-pupil_support:1:pupil_support-1)/pupil_support; %asymm.
            [x,y] = meshgrid(v);	                                          		

            x = x*r*scale;
            y = y*r*scale;

            ax = subplot(1,1,1, 'Parent', ui_handles.add_Wxy);

                imagesc(data.Wxy, 'XData', x(1,:), 'YData', y(:,1));
                xlabel(t('X [mm]'),'FontSize', ui_figures.fontsize_axes);
                ylabel(t('Y [mm]'),'FontSize', ui_figures.fontsize_axes);
                colorbar('peer', ax, 'vert');
                axis square; colormap('jet');

            set(ui_zernikes(1), 'String', sprintf(['%',ui_defaults.float_precision,'f'], 0.001));
            
        else
            
            warndlg(t('The specified file does not contain valid wavefront data.'), t('Incorrect data format'));
            
        end

        pause(0.1);
        
        setappdata(cf, 'ui_defaults', ui_defaults);

    end
        
end
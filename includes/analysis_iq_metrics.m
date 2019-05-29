function analysis_iq_metrics( ~, ~, analyses, s, analysis_id, figure_id )

% Parts based upon the Fourier Optics Calculator © 2004 Larry Thibos, Indiana University
% Parts based upon the w-Tool © 2003 D. R. Iskander
%
% Adapted and developed by Matt Jaskulski, University of Murcia © 2015
%

    warning('off', 'MATLAB:uitabgroup:OldVersion'); % Geez, got it already!
    warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    cf = s.cf;
    
    channelNames = {t('Red'), t('Green'), t('Blue')};
    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures'); 
    ui_defaults =getappdata(cf, 'ui_defaults');
    
    uih = ui_figures.ui_unit_height;
    uil = ui_figures.ui_unit_length;
    uis = ui_figures.ui_unit_spacing;
    uiy = 1 - uih;
    
    %                  R         G         B
    plot_colors = [ 0.3664    0.3883    0.7309;
                    0.3692    0.5518    0.0915;
                    0.7850    0.2290    0.4053;
                    1.0000    0.8000    0.2048;        
                    0.6677    0.3518    0.8844;
                    0.2060    0.7819    0.2916;
                    0.0867    0.1006    0.6035;
                    0.7719    0.2941    0.9644;
                    0.2057    0.2374    0.4325;
                    1.0000    0.0000    0.0000;
                    0.0000    1.0000    0.0000;
                    0.0000    0.0000    1.0000];
    
    spline_density = 100; % times the number of original datapoints
    
    if(strcmp(s.analysis_mode, 'batch')) 
        plot_xlabel = t('Batch Step');
        title_str = t('Batch Analysis');
        format = '%d';
    else
        plot_xlabel = mode2index_txt(s.selected_zernike);
        title_str = sprintf('%s %s', mode2index_txt(s.selected_zernike), s.analysis_mode);
        format = '%3.3f';
    end

    % act before destroying the current figure, retrieve checkboxes' values
    % consider wrapping it in a loop
    if(isfield(s, 'ui_show_legend'))
        s.show_legend = get(s.ui_show_legend, 'Value');
        s = rmfield(s, 'ui_show_legend');
    else
        s.show_legend = 1;
    end
    
    if(isfield(s, 'ui_rescale_xaxis')&& ~strcmp(s.analysis_mode, 'batch') )
        s.rescale_xaxis = get(s.ui_rescale_xaxis, 'Value');
        s = rmfield(s, 'ui_rescale_xaxis');
    else
        s.rescale_xaxis = 0;
    end
    if(isfield(s, 'ui_fit_bspline'))
        s.fit_bspline = get(s.ui_fit_bspline, 'Value');
        s = rmfield(s, 'ui_fit_bspline');
    else
        s.fit_bspline = 1;
    end
    if(isfield(s, 'ui_calculate_dof'))
        s.calculate_dof = get(s.ui_calculate_dof, 'Value');
        s = rmfield(s, 'ui_calculate_dof');
    else
        s.calculate_dof = 0;
    end
    if(isfield(s, 'ui_normalize'))
        s.normalize = get(s.ui_normalize, 'Value');
        s = rmfield(s, 'ui_normalize');
    else
        s.normalize = 0;
    end
    if(isfield(s, 'ui_save_sim_img'))
        s.save_sim_img = get(s.ui_save_sim_img, 'Value');
        s = rmfield(s, 'ui_save_sim_img');
    else
        s.save_sim_img = 0;
    end
    if(isfield(s, 'ui_dof_percentage'))
        s.dof_percentage = get(s.ui_dof_percentage, 'String');
        s = rmfield(s, 'ui_dof_percentage');
    else
        s.dof_percentage = 0;
    end
    
    % import available iqmetrics   
    iqmetrics = cell(1,1);
    iqmetrics_library;
    iqmetrics_in_tab = 14;

    % act before destroying the current figure, retrieve checkboxes' values
    for i = 1:length(iqmetrics)
        ui_name = iqmetrics{i}.ui_name;
        if(isfield(s, ui_name))
                       
            %checkbox_handle = getfield(s, ui_name);
            checkbox_handle = s.(ui_name);
            iqmetrics{i}.ui_value = get(checkbox_handle, 'Value');
            s = rmfield(s, ui_name);
        end
    end
    
    if(nargin < 6)
        figure_id = figure( 'name', sprintf('Image Quality Estimation - %s v.%s', ui_defaults.is_name, num2str(ui_defaults.is_version)),...
                            'units', 'pixels', 'OuterPosition', ui_figures.figure_size); axis off;
    else
        figure( figure_id ); clf;
    end
    if(nargin < 5) 
        analysis_id = 1;
    end
    
    uicontrol(  'Parent', figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'left',...
                'ForegroundColor', 0.8*ui_figures.bg_figure, 'BackgroundColor', ui_figures.bg_figure, 'Position', [0.025 0.90 0.9 0.1],...
                'String', title_str, 'FontSize', 4*ui_figures.fontsize_title);

    ui_progress_bar = uicontrol('Parent', figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center',...
                                'BackgroundColor', [0 0 0],...
                                'Position', [0.025 0.995 0.025 0.075],...
                                'String', '', 'FontSize', 4); 

                            
    uip_psfs  = uipanel(    'Title', 'PSF Evolution', 'Units', 'normalized', 'Position', [0.025 0.05 0.950 0.150],...
                            'BackgroundColor', [0 0 0], 'FontSize', ui_figures.fontsize_panel);                        
                        
    uip_scores =   uipanel( 'Title', '', 'Units', 'normalized', 'Position', [0.025 0.175 0.680 0.725],...
                            'BackgroundColor', ui_figures.bg_charts, 'FontSize', ui_figures.fontsize_panel);
    uip_metrics =  uipanel( 'Title', '', 'Units', 'normalized', 'Position', [0.704 0.425 0.271 0.475],...
                            'BackgroundColor', ui_figures.bg_panel, 'FontSize', ui_figures.fontsize_panel);
            
    uitabs_tl = uitabgroup( uip_scores, 'Units', 'normalized', 'Position', [0 0 1 1]);
    uitabs_tr = uitabgroup( uip_metrics,'Units', 'normalized', 'Position', [0 0 1 1]);
    
     
    uip_options =   uipanel('Title', 'Settings', 'Units', 'normalized', 'Position', [0.704 0.175 0.271 0.250],...
                            'BackgroundColor', ui_figures.bg_panel, 'FontSize', ui_figures.fontsize_panel);
                        
    personalize_figure(figure_id, ui_figures.figure_size);
    show_progress(ui_progress_bar, 0);
                         
    %% available metrics panel
    
    % don't try to understand this script. it will blow your brain. it only
    % generates the layout. no physics. flee for your own sake. you have
    % been warned.
    
    tab_id = 1;
    tab = uitab(uitabs_tr, 'Title', sprintf('Metrics %d', tab_id));
    
    for i = 1:length(iqmetrics)
         
        new_handle = uicontrol(  'Parent', tab, 'Style', 'checkbox', 'Units', 'normalized',...
                                 'String', iqmetrics{i}.name, 'Position', [uis uiy 1-2*uis uih], 'Value', 0);                
                             
        uiy = uiy - 0.5*uih - uis; 
        
        if(isequal(iqmetrics{i}.ui_value, 1))
            set(new_handle , 'Value', 1);
        end
        %s = setfield(s, iqmetrics{i}.ui_name, new_handle);
        s.(iqmetrics{i}.ui_name) = new_handle;
        
        if(mod(i, iqmetrics_in_tab+1) == 0)
            tab_id = tab_id + 1;
            uiy = 1 - uih; 
            tab = uitab(uitabs_tr, 'Title', sprintf('Metrics %d', tab_id));  
        end
        
    end

    %% options panel
    uiy = 1 - 2*uih;
    
    % convoluted and ugly way to achieve a simplest thing in matlab or else I'm just plain damn dumb
    ui_show_legend = uicontrol( 'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized',...
                                'String', 'Show / Hide Legend (on the fly)', 'Position', [uis uiy 0.8 uih], 'Value', 1);
    if(isequal(s.show_legend, 1))
        set(ui_show_legend, 'Value', 1);
    else
        set(ui_show_legend, 'Value', 0);
    end
    s.ui_show_legend = ui_show_legend; % add it to the settings structure to be able to check its state after recurrent call
    
    
    if(~strcmp(s.analysis_mode, 'batch')) 
        uiy = uiy - 2*uih+uis; 
        ui_rescale_xaxis = uicontrol(   'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized',...
                                        'String', 'Rescale x-axis relative to the base value', 'Position', [uis uiy 0.8 uih], 'Value', 0);

        if(isequal(s.rescale_xaxis, 1))
            set(ui_rescale_xaxis, 'Value', 1);
        else
            set(ui_rescale_xaxis, 'Value', 0);
        end
        s.ui_rescale_xaxis = ui_rescale_xaxis;
    end

    
    uiy = uiy - 2*uih+uis; 
    ui_fit_bspline = uicontrol( 'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized',...
                                'String', 'Perform Spline fit to data', 'Position', [uis uiy 0.8 uih], 'Value', 1);
                            
    if(isequal(s.fit_bspline, 1))
        set(ui_fit_bspline, 'Value', 1);
    else
        set(ui_fit_bspline, 'Value', 0);
    end
    s.ui_fit_bspline = ui_fit_bspline;
    
    uiy = uiy - 2*uih+uis;
    ui_calculate_dof = uicontrol( 'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized', 'Enable', 'off',...
                                  'String', 'Try to estimate DOF for the following % of max. value (50% = FWHM)', 'Position', [uis uiy 0.8 uih], 'Value', 0);
                              
    if(isequal(s.calculate_dof, 1))
        set(ui_calculate_dof, 'Value', 1);
    else
        set(ui_calculate_dof, 'Value', 0);
    end
    s.ui_calculate_dof = ui_calculate_dof;
    ui_dof_percentage = uicontrol(  'Parent', uip_options, 'Style', 'edit', 'Units', 'normalized', 'Enable', 'off',...
                                    'String', '35', 'Position', [1-uil-uis uiy uil uih], 'Value', 0,...
                                    'Callback', { @validate_percentage, 35 });
    if(isequal(s.dof_percentage, 0))
        set(ui_dof_percentage, 'String', '35');
    else
        set(ui_dof_percentage, 'String', s.dof_percentage);
    end
    s.ui_dof_percentage = ui_dof_percentage;
    
    uiy = uiy - 2*uih+uis; 
    ui_normalize = uicontrol(   'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized',...
                                'String', 'Normalize all metrics (show relative values)', 'Position', [uis uiy 0.8 uih], 'Value', 0);                         
    if(isequal(s.normalize, 1))
        set(ui_normalize, 'Value', 1);
    else
        set(ui_normalize, 'Value', 0);
    end
    s.ui_normalize = ui_normalize;
    
    uiy = uiy - 2*uih+uis; 
    ui_save_sim_img = uicontrol('Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized',...
                                'String', 'Save Simulated Retinal Images in /output/IMG Series/ (slow!)', 'Position', [uis uiy 0.8 uih], 'Value', 0);                         
    if(isequal(s.save_sim_img, 1))
        set(ui_save_sim_img, 'Value', 1);
    else
        set(ui_save_sim_img, 'Value', 0);
    end
    s.ui_save_sim_img = ui_save_sim_img;
    
    icon = imread('update.png');
    ui_update_figure = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'normalized', 'Position', [0.925 0.9125 0.05 0.075], 'cdata', icon);

    %icon = imread('new_window.png');
    %ui_launch_iqm = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', [86 157 199]/256,...
    %            'Units', 'normalized', 'Position', [0.870 0.9125 0.05 0.075], 'cdata', icon);

    icon = imread('wavefront.png');
    ui_launch_mtf = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'normalized', 'Position', [0.815 0.9125 0.05 0.075], 'cdata', icon); 
            
    icon = imread('img_sim.png');
    ui_launch_sim = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', [0 0 0],...
                'Units', 'normalized', 'Position', [0.760 0.9125 0.05 0.075], 'cdata', icon);
            
    icon = imread('export.png');
    ui_export = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'normalized', 'Position', [0.870 0.9125 0.05 0.075], 'cdata', icon);
            
    %% go  

    active_metrics = cell(length(iqmetrics),1);
    j = 0;
    for i = 1:length(iqmetrics)
        
        %checkbox_value = get(getfield(s, iqmetrics{i}.ui_name), 'Value');
        checkbox_value = get(s.(iqmetrics{i}.ui_name), 'Value');
        if(isequal(checkbox_value, 1))
            j = j + 1;
            active_metrics{j} = iqmetrics{i};
            %active_metrics{end}.maxvalue = 0;
        end
    end
    
    no_metrics = j;
    no_analyses = length(analyses);
    no_channels = length(analyses{1}.data_rgb);
       
    x_values = zeros(no_analyses,1);
    plots = zeros(no_channels,1);
    legends = zeros(no_channels,1);
    
    selected_zernike_value = s.selected_zernike_value;
        
    first_plot_title = sprintf('%s', channelNames{analyses{1}.data_rgb{1}.lambda_idx});
    if(no_channels > 1)
        first_plot_title = 'Polychromatic';
    end
    tab = uitab(uitabs_tl, 'Title', first_plot_title, 'BackgroundColor', ui_figures.bg_charts);
    
    % Prepare the polychromatic plot.
    plots(1) = subplot(1,1,1, 'Parent', tab);
    progress = 0;
    % STEP 1: Calculate the metrics' scores.
    
    target_image = double(get(ui_handles.target_image, 'UserData'));
    
    %empty_directory(sprintf(['%soutput%sPSF Series%s'], [pwd,filesep], filesep, filesep));
    %empty_directory(sprintf(['%soutput%sIMG Series%s'], [pwd,filesep], filesep, filesep));

    for step = 1:no_analyses
        % important
        ai = analyses{ step }.data_rgb;
        psf_size = ai{1}.psf_size(1);
        
        if(strcmp(s.analysis_mode, 'batch'))
            
            x_values(step) = step;
            
            %batch_filelist = get(ui_handles.batch_filelist, 'String');
            %file = batch_filelist{i};
            %[~, filename, ext] = fileparts(file);             

            %dropdown_content{i} = sprintf(t('Batch Step %d/%d - %s'), i, no_analyses, [filename,ext]);
        else

            x_values(step) = ai{1}.zernike_step;
            if(s.rescale_xaxis)
                x_values(step) = x_values(step) - s.selected_zernike_value;
                selected_zernike_value = 0;
            end
        
        end

        poly_PSF = zeros(psf_size, psf_size, no_channels);
        poly_IMG = zeros(size(target_image,1), size(target_image,2), no_channels);
        for chn = 1:no_channels
            a = ai{ chn };
            
            if(no_metrics ~= 0)
                if(step == 1)
                    if(no_channels > 1)
                        tab = uitab(uitabs_tl, 'Title', sprintf('%s', channelNames{a.lambda_idx}), 'BackgroundColor', ui_figures.bg_charts);
                        plots(chn+1)= subplot(1,1,1, 'Parent', tab);
                    end
                end
            
                for iqm = 1:no_metrics
                    progress = progress + 1;
                    
                    % the calculate_iq field of the structure receives the entire analysis "a".
                    a.lambda_idx = chn; % trick for one channel sims
                    active_metrics{iqm}.scores(chn, step) = active_metrics{iqm}.calculate_iq( a, active_metrics{iqm}.args, cf );

                    show_progress(ui_progress_bar, 75*(progress/(no_metrics*no_channels*no_analyses)));

                end
            end
            
            if(ui_defaults.psf_normalize == 1)
                poly_PSF(:,:,chn) = abs(a.PSF_resized)/max(a.PSF_resized(:));
            end
            
            if(isequal(s.save_sim_img, 1))
            
                img_chn = min(chn, size(target_image,3)); % the image may be grayscale, in such case treat it as 3 same channels.
                img = target_image(:,:,img_chn);
                
                psf_volume = sum(a.PSF_resized(:));

                if(ui_defaults.psf_normalize == 1)
                    PSF_resized = a.PSF_resized./psf_volume; % normalize to unit volume
                end

                poly_IMG(:,:,img_chn) = conv2(img, PSF_resized, 'same');
            
            end
            
            
        end       
               
        psf_width = size(poly_PSF,1);
        if(isequal(s.save_sim_img, 1))
            imwrite(poly_PSF, sprintf('%soutput%sPSF Series%s%d_%3.1f_arcmin.png', [ui_defaults.iris_root, filesep], filesep, filesep, step, s.pixsize*psf_width));
            imwrite(poly_IMG/max(poly_IMG(:)), sprintf('%soutput%sIMG Series%ssim_img_%d.png', [ui_defaults.iris_root, filesep], filesep, filesep, step));
        end
        
        no_plots = min(28, no_analyses);
        
        if(step <= no_plots)
            subplot('Position', [(step-1)/no_plots 0 1/no_plots 1], 'Parent', uip_psfs);
                %poly_PSF = sqrt(poly_PSF);
                %poly_PSF = imresize(poly_PSF, 100/psf_width, 'nearest', 'Antialiasing', false);
                %poly_PSF(1,:,:) = ui_figures.axis_simulation(1);

                imshow(poly_PSF); axis off; axis image; %axis square;%box on;

                text(.5,.2,sprintf('%3.0f', s.pixsize*psf_width),...
                    'horiz','center', 'vert', 'middle', 'units','normalized',...
                    'Color', ui_figures.axis_simulation,...
                    'FontSize', ui_figures.fontsize_text);
        end
            
    end
     
    if(no_metrics == 0)
        uicontrol(  'Parent', tab, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center',...
                    'ForegroundColor', ui_figures.bg_panel, 'BackgroundColor', ui_figures.bg_charts,...
                    'Position', [0.025 0.45 0.950 0.350], 'FontSize', 6*ui_figures.fontsize_title,...
                    'String', 'Please select at least one metric.'); 
    else

        %% main loop to display metrics' scores
        plot_colors = plot_colors - min(plot_colors(:))/2; % make it darkish
        plot_ylabel = 'Values of Metric(s) (Absolute)';
        
        y_values_summary = zeros(length(x_values), no_metrics);
        txt_summary = '';
   
        for chn = 0:no_channels - 1*(no_channels == 1)
            plot_legend = cell(no_metrics,1);
            plot_handles= zeros(no_metrics,1);

            current_axes = plots(chn+1);
            axes(current_axes);
            
            for iqm = 1:no_metrics
                iqm_color = plot_colors(iqm, :);
                iqm_name = active_metrics{iqm}.name;
                plot_legend{iqm} = iqm_name;

                if(chn == 0) % initial run of the loop that will take care of the polychromatic plot
                    y_values = active_metrics{iqm}.scores;
                    y_values = sum(y_values, 1)/no_channels;
                    % sum column-wise, average
                else             
                    y_values = active_metrics{iqm}.scores(chn, :);
                end

                if(s.normalize == 1)
                    y_values = y_values / max(y_values(:));
                    plot_ylabel = 'Values of Metric(s) (Normalized)';
                end
                
                if(s.fit_bspline == 1 && no_analyses > 1)
                    cs = spline(x_values,[0 y_values 0]);
                    fit_x = linspace(x_values(1), x_values(end), spline_density*length(x_values));
                    fit_y = ppval(cs,fit_x);

                    plot_handles(iqm) =   plot(x_values, y_values,'o', 'MarkerEdgeColor', 0.5*iqm_color, 'MarkerFaceColor', iqm_color); hold on
                                          plot(fit_x,    fit_y,	'-', 'LineWidth', 1.5, 'Color', iqm_color);
                    %plot_legend{end+1} = 'B-Spline fit to data';

                    if(s.calculate_dof == 1) 
                        %y_max = max(y_values(:)); y_min = min(y_values(:));
                        y_max = max(fit_y(:)); y_min = min(fit_y(:));
                        
                        y_dof = y_max - (y_max - y_min)*(100-str2double(get(ui_dof_percentage, 'String')))/100;
                        x_dof = fit_x;

                        % find intersections of the dof line with the spline fit
                        isec = abs(fit_y - y_dof) <= (y_max + y_min)/spline_density;
                        len = length(isec);

                        go = 0;
                        
                        % the above yields a matrix of zeros with clusters of 'ones' and we want just a single 'one' in the middle of each cluster        
                        looking_for = 1;
                        isec_idx = [];
                        for i=1:len
                            if(isec(i) == looking_for), isec_idx(end+1) = i; end
                            looking_for = ~isec(i);
                        end
                        if(mod(length(isec_idx),2)), isec_idx(end+1) = len; end
                        
                        isec_idx(1:2:end) = floor((isec_idx(1:2:end) + isec_idx(2:2:end))/2);
                        isec_idx(2:2:end) = [];
                        
                        isec = isec_idx; % back it up for plotting
                        no_isecs = length(isec_idx);
                        slopes = zeros(no_isecs,1);
                        
                        % verify that we have at least two intersections
                        if(no_isecs >= 2)
                            isec_idx = [isec_idx(1) isec_idx(end)];
                            
                            for i = 1:no_isecs
                                % calculate the sign of the slope
                                point = isec(i);
                                p_before = point - round(spline_density/10);
                                p_after = point + round(spline_density/10);

                                % make sure we'll not fall off the plot data range
                                p_before = max(1, p_before);
                                p_after = min(length(fit_x), p_after);

                                slopes(i) = sign((fit_y(p_after) - fit_y(p_before))/(p_after - p_before));
                            end

                            if(slopes(1)~=slopes(2))
                                go = 1;
                            end
                        end

                        if(go)
                            % display dof value on plot
                            dof = fit_x(isec_idx);
                            dof_value = dof(end) - dof(1);
                            lag_value = s.selected_zernike_value - sum(dof)/2;
                            
                            pl = plot_legend{iqm};
                            
                            plot_legend{iqm} = sprintf('%s - DOF %1.3f, LAG %+1.3f', pl(1:strfind(pl, ')')+1), dof_value, lag_value);
                            %text(1.05*dof(mod(iqm,2)+1), y_dof, sprintf('DOF %1.3f, LAG %1.3f', dof_value, lag_value), 'Color', iqm_color);
                            
                            isec_idx = isec; % restore it to mark all intersections on plot

                            % plot dof intersections
                            plot(x_dof(isec_idx), y_dof*(isec_idx~=0),  '-o',...
                                                                        'Color', iqm_color,...
                                                                        'LineWidth', 1.5,...
                                                                        'MarkerEdgeColor', 0.5*iqm_color,...
                                                                        'MarkerFaceColor', [1 1 1]);
                            plot(xlim, [y_dof y_dof], ':k',             'LineWidth', 1.3);
                        end
                        
                    end
                else
                    plot_handles(iqm) = plot(x_values, y_values,        'o-',...
                                                                        'Color', iqm_color,...
                                                                        'LineWidth', 1.5,...
                                                                        'MarkerEdgeColor', 0.5*iqm_color,...
                                                                        'MarkerFaceColor', iqm_color); hold on
                end
                
                y_values_summary(:, iqm) = y_values;

            end % end metrics loop
            
            % Prepare the Summary text with all the scores data
            for i=1:length(x_values)
                
                if(chn == 0)
                    if(no_channels > 1)
                        lambda_str = 'Polychromatic';
                    else
                        lambda_str = 'Monochromatic';
                    end
                else
                    lambda_str = sprintf(format, ui_defaults.lambdas(chn));
                end
                x_value = sprintf(format, x_values(i));
                
                summary_row = '';
                title_row = plot_xlabel;
                
                for iqm = 1:no_metrics
                    y_value = sprintf('%.3e', y_values_summary(i, iqm)); 
                    if(i == 1)
                        metric_name = plot_legend{iqm};
                        metric_name = strrep(metric_name(1:strfind(metric_name, ')')+1), ' ', '');
                        title_row = [title_row, sprintf('\t'), metric_name];
                    else
                        title_row = '';
                    end
                    
                    if(iqm == 1), summary_row = x_value; end
                    summary_row = [summary_row, sprintf('\t'), y_value];
                end
                if(~isempty(title_row)), title_row = sprintf('%s\n%s\n', lambda_str, title_row); end
                        
                txt_summary = strrep(sprintf('%s\n', [txt_summary, title_row, summary_row]), '.', ',');
                
            end

            % Make it so (ekhem) that when the user clicks a point, he gets to see the image simulation.
            if(chn == 0)
                set(get(current_axes, 'Children'), 'ButtonDownFcn', { @click_point, current_axes, x_values, analyses, s });  
            end
                
            yl = ylim;
            ylim([0.95*yl(1); 1.05*yl(2)]);

            marker_basevalue_y = ylim;
            marker_basevalue_x = [selected_zernike_value, selected_zernike_value];
                                      
            if(~strcmp(s.analysis_mode, 'batch'))
                plot_handles(iqm+1) = plot(marker_basevalue_x, marker_basevalue_y, ':r', 'LineWidth', 1.3);
                plot_legend{iqm+1} = sprintf('Base Value (%2.3f) of %s', s.selected_zernike_value, plot_xlabel);      
            end

            legends(chn+1) = legend(plot_handles, plot_legend, 'Location', 'Best', 'FontName', 'FixedWidth', 'Box', 'off');
            grid on; grid minor;
            xlabel(plot_xlabel); ylabel(plot_ylabel);
            hold off;
            
            progress = 75+25*chn/no_channels;
            show_progress(ui_progress_bar, progress);

        end % end rgb loop
    end
    is_ui_saveclipboard(cf, plots(1), [20 20], txt_summary);
    
    % show some luv :3
    show_progress(ui_progress_bar, 0);
      
    set(ui_update_figure, 'Callback', { @analysis_iq_metrics, analyses, s, analysis_id, figure_id });
    set(ui_launch_mtf, 'Callback', { @analysis_mtf_ptf_pf, analyses, s });
    set(ui_launch_sim, 'Callback', { @analysis_retinal_sim, analyses, s });
    
    set(ui_export, 'Callback', { @export_analyses, cf, analyses, s, 'iqm' });
    
    uicontrol(  figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center', 'BackgroundColor', ui_figures.bg_figure,...
                'String', ui_defaults.is_footer, 'Position', [0.025 0.0125 0.95 0.025], 'FontSize', ui_figures.fontsize_text, 'ForegroundColor', 0.6*ui_figures.bg_figure);
    
    if(s.fit_bspline == 1)
        set(ui_dof_percentage, 'Enable', 'on');
        set(ui_calculate_dof,  'Enable', 'on');
    end
    
    set(ui_show_legend, 'Callback', { @toggle_legend, legends });
    set(ui_fit_bspline, 'Callback', { @toggle_dof, ui_calculate_dof, ui_dof_percentage });
    
    set(figure_id, 'DeleteFcn', { @close_figure, analyses, s });

    function close_figure(~, ~, analyses, s)
        % this cleans up heaps of memory consumed by each analysis window
        clearvars analyses;
        clearvars s;
    end
    
    function toggle_legend(hObject, ~, legends)
        if(get(hObject, 'Value') == 1)
            set(legends, 'Visible', 'on');
        else
            set(legends, 'Visible', 'off');
        end 
    end

    function toggle_dof(hObject, ~, ui_calculate_dof, ui_dof_percentage)
        if(get(hObject, 'Value') == 1)
            set(ui_calculate_dof,  'Enable', 'on');
            set(ui_dof_percentage, 'Enable', 'on');
        else
            set(ui_calculate_dof,  'Enable', 'off');
            set(ui_dof_percentage, 'Enable', 'off');
        end 
    end

    function click_point(~,~, ax, x_values, analyses, s)
    
        % Get the location that was clicked on
        click_x = get(ax, 'Currentpoint');
        click_x = click_x(1,1);
        
        % x_values has indices that correspond to each of our Through-Zernike steps
        [distance, analysis_id] = min(abs(x_values - click_x));
        if(distance < 0.1), analysis_retinal_sim([], [], analyses, s, analysis_id); end
  
    end

end % end function
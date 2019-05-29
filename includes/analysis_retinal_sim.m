function analysis_retinal_sim( ~, ~, analyses, s, analysis_id, figure_id )
% Parts based upon the Fourier Optics Calculator © 2004 Larry Thibos, Indiana University
% Parts based upon the w-Tool © 2003 D. R. Iskander
%
% Adapted and developed by Matt Jaskulski, University of Murcia © 2015
%
% analyses - a cell array containing structures with data returned by
% analysis_single or analysis_through_focus
%
% HINT:
% analyses - cell array containing all of the analyses, first by step, then by wavelength
% analysis = analyses{i} - cell array containing one analysis step
% a = analysis{rgb} - cell array containing the analysis for one step, one wavelength
%
    warning('off', 'MATLAB:uitabgroup:OldVersion'); % Geez, got it already!
    warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    if(nargin < 5), analysis_id = 1; end
    
    cf = s.cf;
    
    channelNames = {t('Red'), t('Green'), t('Blue')};
    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures'); 
    ui_defaults =getappdata(cf, 'ui_defaults');
    
    uih = ui_figures.ui_unit_height;
    uil = ui_figures.ui_unit_length;
    uis = ui_figures.ui_unit_spacing;
    uiy = 1 - 2*(uih + uis);
    
    if(strcmp(s.analysis_mode, 'batch'))
        
        batch_filelist = get(ui_handles.batch_filelist, 'String');
        file = batch_filelist{analysis_id};
        [~, filename, ext] = fileparts(file);
                
        title_str = sprintf('%s', [filename,ext]);
    else
        title_str = sprintf('%s', mode2index_txt(s.selected_zernike));
    end
    
    if(s.calculate_psf_go), psf_type = 'Geometrical Optics'; else
                            psf_type = 'Fourier Optics'; end
    
    % act before destroying the current figure, retrieve checkboxes' values
    if(isfield(s, 'ui_img_normalize')&&nargin>=6)
        s.img_normalize = get(s.ui_img_normalize, 'Value');
        s = rmfield(s, 'ui_img_normalize');
    else
        s.img_normalize = 0;
    end

    if(isfield(s, 'ui_psf_original')&&nargin>=6)
        s.psf_original = get(s.ui_psf_original, 'Value');
        s = rmfield(s, 'ui_psf_original');
    else
        s.psf_original = 1;
    end
    
    if(isfield(s, 'ui_psf_sqrt')&&nargin>=6)
        s.psf_sqrt = get(s.ui_psf_sqrt, 'Value');
        s = rmfield(s, 'ui_psf_sqrt');
    else
        s.psf_sqrt = 1;
    end     
                        
    if(nargin < 6)
        figure_id = figure( 'name', sprintf('Retinal Image Simulation - %s v.%s', ui_defaults.is_name, num2str(ui_defaults.is_version)),...
                            'units', 'pixels', 'OuterPosition', ui_figures.figure_size); axis off;
    else
        figure( figure_id ); clf;  
    end
    
    personalize_figure(figure_id, ui_figures.figure_size); 

    analysis = analyses{analysis_id};   % select desired through-zernike step
    analysis = analysis.data_rgb;
    
    colormap(analysis{1}.colormap);

    no_channels = length(analysis);
    no_analyses = length(analyses);   
    
    uicontrol(  'Parent', figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'left',...
                'ForegroundColor', 0.8*ui_figures.bg_figure, 'BackgroundColor', ui_figures.bg_figure, 'Position', [0.025 0.90 0.9 0.1],...
                'String', title_str, 'FontSize', 4*ui_figures.fontsize_title);
            
    ui_progress_bar =   uicontrol(  'Parent', figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center',...
                                    'BackgroundColor', [0 0 0],...
                                    'Position', [0.025 0.995 0.025 0.075],...
                                    'String', '', 'FontSize', 4);

    icon = imread('wavefront.png');
    ui_launch_mtf = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'normalized', 'Position', [0.815 0.9125 0.05 0.075], 'cdata', icon); 
            
    icon = imread('iq_metrics.png');
    ui_launch_iqm = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'normalized', 'Position', [0.760 0.9125 0.05 0.075], 'cdata', icon);

    uip_simulation = uipanel(   'Title', '', 'Units', 'normalized', 'Position', [0.025 0.05 0.575 0.85]);
    uip_psfs =       uipanel(   'Title', '', 'Units', 'normalized', 'Position', [0.600 0.05 0.375 0.85]);

    uip_options =   uipanel( 'Title', '', 'Units', 'normalized', 'Position', [0.500 0.9125 0.25 0.075],...
                             'BackgroundColor', ui_figures.bg_panel, 'FontSize', ui_figures.fontsize_panel); 
    
    uitabs_tl = uitabgroup(uip_simulation,  'Units', 'normalized', 'Position', [0 0 1 1]);
    uitabs_tr = uitabgroup(uip_psfs,        'Units', 'normalized', 'Position', [0 0 1 1]); 
    
    uitab_polypsf = uitab(uitabs_tr, 'Title', t('Color PSF'), 'BackgroundColor', ui_figures.bg_simulation);
    
    uitab_img = uitab(uitabs_tl,            'Title', 'Polychromatic Image', 'BackgroundColor', ui_figures.bg_simulation);
    uitab_chn = uitab(uitabs_tl,            'Title', 'Color Channels', 'BackgroundColor', ui_figures.bg_simulation);
    
    uitabs_imgs = uitabgroup(uitab_chn,     'Units', 'normalized', 'Position', [0 0 1 1]);
   
    uiy = uiy - 2*(uih - uis);
    
    dropdown_content = cell(length(analyses),1); selected_dropdown = 1;
    for i = 1:no_analyses
        if i == analysis_id
            selected_dropdown = i;
        end
        ai = analyses{i}.data_rgb;

        if(strcmp(s.analysis_mode, 'batch'))
            batch_filelist = get(ui_handles.batch_filelist, 'String');
            file = batch_filelist{i};
            [~, filename, ext] = fileparts(file);             

            dropdown_content{i} = sprintf(t('Batch Step %d/%d - %s'), i, no_analyses, [filename,ext]);
        else
            dropdown_content{i} = sprintf(t('%s - Base value: %1.3f%+1.3f'),...
                                            mode2index_txt(s.selected_zernike),...
                                            s.selected_zernike_value,...
                                            ai{1}.zernike_step);
        end
    end

    dropdown = uicontrol(   'Parent', uip_options, 'Style', 'popup', 'Units', 'normalized',...
                            'String', dropdown_content, 'Position', [1-uis-3.35*uil uiy-2*uih 3.35*uil 2*uih],...
                            'Callback', { @select_from_dropdown, analyses, s, figure_id });
    set(dropdown, 'Value', selected_dropdown);
        
    if(no_analyses == 1)
        set(dropdown, 'Enable', 'off');
    end
    
    ui_psf_original =uicontrol( 'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized', 'BackgroundColor', ui_figures.bg_panel,...
                                'String', sprintf('Enhanced PSF'), 'Position', [uis uiy 2*uil 3.5*uih], 'Value', 0);
    if(isequal(s.psf_original, 1)), set(ui_psf_original, 'Value', 1); end
    s.ui_psf_original = ui_psf_original; % add it to the settings structure to be able to check its state after recurrent call
    
    uiy = uiy - 4.5*uih + uis;
    ui_psf_sqrt=uicontrol( 'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized', 'BackgroundColor', ui_figures.bg_panel,...
                           'String', sprintf('SQRT PSF (display only)'), 'Position', [uis uiy 3*uil 3.5*uih], 'Value', 0);
    if(isequal(s.psf_sqrt, 1)), set(ui_psf_sqrt, 'Value', 1); end
    s.ui_psf_sqrt = ui_psf_sqrt; % add it to the settings structure to be able to check its state after recurrent call
    
    uiy = uiy - 4.5*uih + uis;
    ui_img_normalize=uicontrol( 'Parent', uip_options, 'Style', 'checkbox', 'Units', 'normalized', 'BackgroundColor', ui_figures.bg_panel,...
                                'String', sprintf('Normalize Image'), 'Position', [uis uiy 2*uil 3.5*uih], 'Value', 0);
    if(isequal(s.img_normalize, 1)), set(ui_img_normalize, 'Value', 1); end
    s.ui_img_normalize = ui_img_normalize; % add it to the settings structure to be able to check its state after recurrent call
    
    icon = imread('update.png');
    uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'normalized', 'Position', [0.925 0.9125 0.05 0.075], 'cdata', icon,...
                'Callback', { @analysis_retinal_sim, analyses, s, analysis_id, figure_id });  

    % = imread('new_window.png');
    %uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', [86 157 199]/256,...
    %            'Units', 'normalized', 'Position', [0.870 0.9125 0.05 0.075], 'cdata', icon,...
    %            'Callback', { @analysis_retinal_sim, analyses, s, analysis_id });  
            
    icon = imread('export.png');
    ui_export = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'normalized', 'Position', [0.870 0.9125 0.05 0.075], 'cdata', icon);

    % STEP 1
    target_image = double(get(ui_handles.target_image, 'UserData'));
    
    for chn = 1:no_channels
        ai = analysis{ chn };
        
        if(isequal(s.psf_original, 1)), PSF = ai.PSF_cropped; else
                                        PSF = ai.PSF_resized; end
        psf_size = size(PSF, 1);
        
        % This used to be done after the PSF calculation, but since only
        % the retinal image simulation module uses the convolved image,
        % there is no need to do it elsewhere.
        
        show_progress(ui_progress_bar, 50*chn/no_channels);
        show_msg(cf, 'Performing Convolution');
        
        img_chn = min(chn, size(target_image,3)); % the image may be grayscale, in such case treat it as 3 same channels.
        img = target_image(:,:,img_chn);
        
        psf_volume = sum(analysis{chn}.PSF_resized(:));

        if(ui_defaults.psf_normalize == 1)
            PSF_resized = analysis{chn}.PSF_resized./psf_volume; % normalize to unit volume
        end
            
        analysis{chn}.sim_img = conv2(img, PSF_resized, 'same');
        analysis{chn}.sim_img_size = size(analysis{chn}.sim_img);   
        
    end
    
    % STEP 2
    tabs_psfs = zeros(no_channels,1); tabs_imgs = zeros(no_channels,1);
    poly_img = zeros(analysis{1}.sim_img_size(1), analysis{1}.sim_img_size(2), no_channels);
    poly_PSF = zeros(psf_size, psf_size, no_channels);
    
    img_scale_y = (-analysis{1}.sim_img_size(1):analysis{1}.sim_img_size(1)-1)*s.pixsize/2/60;
    img_scale_x = (-analysis{1}.sim_img_size(2):analysis{1}.sim_img_size(2)-1)*s.pixsize/2/60;
    
    psf_scale_x = (-psf_size:psf_size-1)*s.pixsize/2;
    psf_scale_y = psf_scale_x;
    
    imgMax = 0; imgMin = 1;
    
    for chn = 1:no_channels
        
        a = analysis{ chn };
        show_progress(ui_progress_bar, 50+50*chn/no_channels);
        if(isequal(s.psf_original, 1)), psf_scale = a.psf_scale; PSF = a.PSF_cropped; else
                                        psf_scale = 1;           PSF = a.PSF_resized; end
        
        PSF_disp = PSF;
        
        % Arthur's requested fix
        img = a.sim_img;
        img(end, end) = 0;
        img(end-1, end) = 2^ui_defaults.bpp-1;
        
        if(s.psf_sqrt), PSF_disp = real(sqrt(PSF_disp)); end
        [~, center_y, center_x] = PSFcenter(PSF_disp, [], 0);
        
        tabs_imgs(chn) = uitab(uitabs_imgs, 'Title', sprintf('%s', channelNames{a.lambda_idx}), 'Tag', num2str(chn), 'BackgroundColor', ui_figures.bg_simulation);
        ax = subplot(1,1,1, 'Parent', tabs_imgs(chn));
            
            imagesc(img, 'XData', img_scale_x, 'YData', img_scale_y);
              
            is_ui_saveimg(cf, ax, [20 20]);    

            title(sprintf('%s Channel', channelNames{a.lambda_idx}), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
            xlabel('Visual Angle [deg]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;

        tabs_psfs(chn) = uitab(uitabs_tr, 'Title', sprintf('%s', channelNames{a.lambda_idx}), 'Tag', num2str(chn), 'BackgroundColor', ui_figures.bg_simulation);
        ax = subplot(1,1,1, 'Parent', tabs_psfs(chn));

            center_x = (-psf_size/2 + center_x)*s.pixsize*psf_scale;
            center_y = (-psf_size/2 + center_y)*s.pixsize*psf_scale;
        
            imagesc(PSF_disp, 'XData', psf_scale*psf_scale_x, 'YData', psf_scale*psf_scale_y);
            hold on; plot(center_x, center_y,'r+'); hold off;

            is_ui_saveimg(cf, ax, [20 20]);
            set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
            
            title(sprintf('%s %s Polychromatic PSF', channelNames{a.lambda_idx}, psf_type), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
            xlabel('Visual Angle [arcmin]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
            
        poly_PSF(:,:,chn) = abs(PSF_disp)/max(PSF_disp(:));
        
        img = a.sim_img / 2^ui_defaults.bpp;
        imgMax = max(max(img(:)), imgMax);
        imgMin = min(min(img(:)), imgMin);
        
        poly_img(:,:,chn) = img;
        
    end
    
    if(s.img_normalize)
    
        for chn = 1:no_channels
            poly_img(:,:,chn) = imadjust(poly_img(:,:,chn), [imgMin imgMax], [0 1]);
        end
            
    end
                  
    ax = subplot(1,1,1, 'Parent', uitab_img);
    
        % Arthur's requested fix 
        %poly_img(end, end, :) = zeros(no_channels, 1);
        %poly_img(end-1, end, :) = (2^ui_defaults.bpp-1) * ones(no_channels, 1);
    
        imagesc(poly_img, 'XData', img_scale_x, 'YData', img_scale_y);
        is_ui_saveimg(cf, ax, [20 20]);
        
        title(sprintf('Retinal Image Simulation'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        xlabel('Visual Angle [deg]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
        
    ax = subplot(1,1,1, 'Parent', uitab_polypsf);

        % mental note, the psf_scale changes with wavelength, so perhaps the poly PSF scale should be averaged?
        imagesc(poly_PSF, 'XData', psf_scale*psf_scale_x, 'YData', psf_scale*psf_scale_y);
        is_ui_saveimg(cf, ax, [20 20]);

        title(sprintf('Polychromatic PSF'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        xlabel('Visual Angle [arcmin]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
     
    set(uitabs_tr, 'SelectionChangedFcn', { @change_colormap_rgb, analysis, tabs_imgs });
    set(uitabs_imgs, 'SelectionChangedFcn', { @change_colormap_rgb, analysis, tabs_psfs });
        
    %% Spectral Power Distribution poly PSF stuff...
    
    if(s.polypsf_mode == 1 && strcmp(s.analysis_mode, 'single'))
        
        analysis = analyses{analysis_id};
        analysis = analysis.data_spd;
        
        uitab_psfs = uitab(uitabs_tr,           'Title', 'Mono-PSF Stack', 'BackgroundColor', ui_figures.bg_simulation);
        uitabs_psfs = uitabgroup(uitab_psfs,    'Units', 'normalized', 'Position', [0 0 1 1], 'TabLocation', 'right');
        
        no_channels = length(analysis);
        tabs_psfs = zeros(no_channels,1); 
        for chn = 1:no_channels
            
            a = analysis{chn};
            
            % Resize the PSF to be commensurate with object.
            psf_scale = a.psf_resolution/s.pixsize;             % scale required to make pixel size of PSF = pixel size of object   
            [PSF_resized, PSF_cropped] = is_psf_rescale(a.PSF, psf_scale, ui_defaults.psf_rescale_method);
            
            if(isequal(s.psf_original, 1)), PSF = PSF_cropped; scale = a.psf_resolution; else
                                            PSF = PSF_resized; scale = s.pixsize; end
            
            psf_scale_x = (-size(PSF,1):size(PSF,1)-1)/2*scale;
            psf_scale_y = psf_scale_x;
            
            tabs_psfs(chn) = uitab(uitabs_psfs, 'Title', sprintf('%4.1f nm', a.lambda), 'Tag', num2str(chn), 'BackgroundColor', ui_figures.bg_simulation);
            ax = subplot(1,1,1, 'Parent', tabs_psfs(chn));

                imagesc(PSF, 'XData', psf_scale_x, 'YData', psf_scale_y); axis('square');
                is_ui_saveimg(cf, ax, [20 20]);
                
                title(sprintf('Monochromatic PSF'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
                xlabel('Visual Angle [arcmin]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
        end
        % set(uitabs_psfs, 'SelectionChangeFcn', { @change_colormap_spd, analysis }); % Matlab 2012
        set(uitabs_psfs, 'SelectionChangedFcn', { @change_colormap_spd, analysis });
    end
    
    uitab_pupil=uitab(uitabs_tr, 'Title', 'Pupil', 'BackgroundColor', ui_figures.bg_simulation);
    ax = subplot(1,1,1, 'Parent', uitab_pupil);
        scale = -a.r:a.r;
        imagesc(a.Axy, 'XData', scale, 'YData', scale);
        is_ui_saveimg(cf, ax, [20 20]);
        title(sprintf('Pupil, original radius %2.3f mm', a.r), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;

    % show some luv :3
    show_progress(ui_progress_bar, 0);
    
    set(ui_launch_mtf, 'Callback', { @analysis_mtf_ptf_pf, analyses, s, 1, analysis_id });
    set(ui_launch_iqm, 'Callback', { @analysis_iq_metrics, analyses, s });

    set(figure_id, 'DeleteFcn', { @close_figure, analyses, s });
      
    set(ui_export, 'Callback', { @export_analyses, cf, analyses, s, 'sim' });
    
    uicontrol(  figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center', 'BackgroundColor', ui_figures.bg_figure,...
                'String', ui_defaults.is_footer, 'Position', [0.025 0.0125 0.95 0.025], 'FontSize', ui_figures.fontsize_text, 'ForegroundColor', 0.6*ui_figures.bg_figure); 
    
end % end function

function close_figure(~, ~, analyses, s)
    % this cleans up heaps of memory consumed by each analysis window
    clearvars analyses;
    clearvars s;
end

function select_from_dropdown(hObject, ~, analyses, s, figure_id)
    i = get(hObject, 'Value');
    analysis_retinal_sim([], [], analyses, s, i, figure_id);
end

function change_colormap_rgb(~, args, a, other_tabs)
    selected_tab_idx = str2double(args.NewValue.Tag); % I'm being a fucking genious.
    if(selected_tab_idx <= length(a))
    
        colormap(a{selected_tab_idx}.colormap);
        other_tabgroup = get(other_tabs(selected_tab_idx), 'Parent');
        set(other_tabgroup, 'SelectedTab', other_tabs(selected_tab_idx));
        
    end
end

function change_colormap_spd(~, args, a)
    selected_tab_idx = str2double(args.NewValue.Tag);
    colormap(a{selected_tab_idx}.colormap);
end
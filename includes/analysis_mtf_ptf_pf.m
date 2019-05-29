function analysis_mtf_ptf_pf( ~, ~, analyses, s, channel, analysis_id, figure_id )
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

    cf = s.cf;
    
    channelNames = {t('Red'), t('Green'), t('Blue')};
    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures'); 
    ui_defaults =getappdata(cf, 'ui_defaults');

    uih = ui_figures.ui_unit_height;
    uil = ui_figures.ui_unit_length;
    uis = ui_figures.ui_unit_spacing;
    uiy = 1 - 2*(uih + uis);
    
    if(s.calculate_psf_go), psf_type = 'Geometrical Optics'; else
                            psf_type = 'Fourier Optics'; end

    if(nargin < 6), analysis_id = 1; end
    if(nargin < 5), channel = 1; end 

    analysis = analyses{ analysis_id }; % select desired through-focus step 
    analysis = analysis.data_rgb;
    a = analysis{ channel };            % this structure has all the fields populated by zernike2psf and analysis_launcher
    
    colormap(ui_figures.colormap); 
    
    no_analyses = length(analyses);
    no_channels = length(analysis);
    
    figure_name = sprintf('%s Channel Detailed Analysis - %s v.%s', channelNames{a.lambda_idx}, ui_defaults.is_name, num2str(ui_defaults.is_version));
    
    if(nargin >= 7)
        figure( figure_id ); clf;
        set(figure_id, 'name', figure_name);
    else
        figure_id = figure( 'name', figure_name,...
                            'units', 'pixels', 'OuterPosition', ui_figures.figure_size); axis off;
    end
    
    personalize_figure(figure_id, ui_figures.figure_size);
    
    if(strcmp(s.analysis_mode, 'batch'))
        
        batch_filelist = get(ui_handles.batch_filelist, 'String');
        file = batch_filelist{analysis_id};
        [~, filename, ext] = fileparts(file);
                
        title_str = sprintf('%s, %s', channelNames{a.lambda_idx}, [filename,ext]);
    elseif(strcmp(s.analysis_mode, 'through-focus'))
        title_str = sprintf('%s, %s', channelNames{a.lambda_idx}, mode2index_txt(s.selected_zernike));
    else
        title_str = sprintf('%s', channelNames{a.lambda_idx});
    end

    uicontrol(  'Parent', figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'left',...
                'ForegroundColor', 0.8*ui_figures.bg_figure, 'BackgroundColor', ui_figures.bg_figure, 'Position', [0.025 0.90 0.9 0.1],...
                'String', title_str, 'FontSize', 4*ui_figures.fontsize_title);
            
    ui_progress_bar =   uicontrol(  'Parent', figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center',...
                                    'BackgroundColor', [0 0 0],...
                                    'Position', [0.025 0.995 0.025 0.075],...
                                    'String', '', 'FontSize', 4);

    % at this stage once analysis_launcher has calculated stuff, we can launch different analysis without repeating it!
    icon = imread('img_sim.png');
    ui_launch_sim = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', [0 0 0],...
                'Units', 'normalized', 'Position', [0.760 0.9125 0.05 0.075], 'cdata', icon);

    icon = imread('iq_metrics.png');
    uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_edit,...
                'Units', 'normalized', 'Position', [0.815 0.9125 0.05 0.075], 'cdata', icon,...
                'Callback', { @analysis_iq_metrics, analyses, s });

    uip_analysis =  uipanel( 'Title', '', 'Units', 'normalized', 'Position', [0.025 0.050 0.675 0.85]);
    uip_psfs =      uipanel( 'Title', '', 'Units', 'normalized', 'Position', [0.700 0.050 0.275 0.85]);
    
    uip_options =   uipanel( 'Title', '', 'Units', 'normalized', 'Position', [0.500 0.9125 0.25 0.075],...
                             'BackgroundColor', ui_figures.bg_panel, 'FontSize', ui_figures.fontsize_panel); 
                         
    uitabs_tl = uitabgroup( uip_analysis, 'Units', 'normalized', 'Position', [0 0 1 1]);
    uitabs_tr = uitabgroup( uip_psfs,     'Units', 'normalized', 'Position', [0 0 1 1]);
    
    uitab_2d =     uitab( uitabs_tr, 'Title', t('2D WFE'));
    uitab_3d =     uitab( uitabs_tr, 'Title', t('3D WFE'));
    uitab_psf =    uitab( uitabs_tr, 'Title', sprintf('%s PSF', channelNames{a.lambda_idx}), 'BackgroundColor', ui_figures.bg_simulation);
    %uitab_pupil =  uitab( uitabs_tr, 'Title', t('Pupil'), 'BackgroundColor', ui_figures.bg_simulation);
    uitab_summary =uitab( uitabs_tr, 'Title', t('Summary'), 'BackgroundColor', ui_figures.bg_charts);
    
    uitab_mtf =    uitab( uitabs_tl, 'Title', 'MTF Analysis', 'BackgroundColor', ui_figures.bg_charts);
    uitabs_mtf = uitabgroup( uitab_mtf, 'Units', 'normalized', 'Position', [0 0 1 1]);
    uitab_mtf_current =     uitab( uitabs_mtf, 'Title', sprintf('%s  MTF', channelNames{a.lambda_idx}), 'BackgroundColor', ui_figures.bg_charts);
    %uitab_mtf_current3d =   uitab( uitabs_mtf, 'Title', sprintf('3D MTF'), 'BackgroundColor', ui_figures.bg_charts);
    uitab_mtf_horizontal =  uitab( uitabs_mtf, 'Title', 'Horizontal MTFs', 'BackgroundColor', ui_figures.bg_charts);
    uitab_mtf_vertical =    uitab( uitabs_mtf, 'Title', 'Vertical MTFs', 'BackgroundColor', ui_figures.bg_charts);
    uitab_mtf_radial =      uitab( uitabs_mtf, 'Title', 'Radial MTFs', 'BackgroundColor', ui_figures.bg_charts);

    if(s.polypsf_mode == 1)
        if(strcmp(s.analysis_mode, 'single'))
            uitabs_2d =uitabgroup( uitab_2d, 'Units', 'normalized', 'Position', [0 0 1 1]);
            uitabs_3d =uitabgroup( uitab_3d, 'Units', 'normalized', 'Position', [0 0 1 1]);
        else
            delete(uitab_2d);
            delete(uitab_3d);
        end
    else   
        %[Tx, Ty, Mer, Tang, tanVergence, radVergence, DX, DY, D2, xx, yy, Txx, Tyy, radius, calib] = wavefront_details(a);
        [Tx, Ty, Mer, Tang, ~, ~, DX, DY, D2, xx, yy, Txx, Tyy, radius, calib] = wavefront_details(a);
        
        uitab_slopes = uitab( uitabs_tl, 'Title', t('Wavefront Slopes'), 'BackgroundColor', ui_figures.bg_charts);
        %uitab_vergence = uitab( uitabs_tl, 'Title', t('Vergence'), 'BackgroundColor', ui_figures.bg_charts);
        uitab_curvature = uitab( uitabs_tl, 'Title', t('Curvature'), 'BackgroundColor', ui_figures.bg_charts);
        uitab_spots = uitab( uitabs_tl, 'Title', t('Spot Diagrams'), 'BackgroundColor', ui_figures.bg_charts);
    end

    % dropdown menus - for the through zernike step and for the lambda
    uiy = uiy - 2*(uih + uis);
    dropdown_content = cell(no_analyses,1); selected_dropdown = 1;

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
                            'String', dropdown_content, 'Position', [uis uiy 3.35*uil 2*uih],...
                            'Callback', { @select_dropdown_step, analyses, s, channel, figure_id });
    set(dropdown, 'Value', selected_dropdown);

    if(no_analyses == 1)
        set(dropdown, 'Enable', 'off');
    end
    
    if(no_channels > 1)

        %uiy = uiy - 2*(uih + uis);
        dropdown_content = cell(no_channels,1); selected_dropdown = 1;

        for i = 1:no_channels

            if ui_defaults.lambdas(i) == a.lambda
                selected_dropdown = i;
            end

            dropdown_content{i} = sprintf(  '%3.1f nm - (LCA %+1.2fD)',...
                                            ui_defaults.lambdas(i), lca_defocus(ui_defaults.lambdas(i), s.reference_lambda, a.r));
        end
        
        dropdown = uicontrol(   'Parent', uip_options, 'Style', 'popup', 'Units', 'normalized',...
                                'String', dropdown_content, 'Position', [3.35*uil+2*uis uiy 3.35*uil 2*uih],...
                                'Callback', { @select_dropdown_lambda, analyses, s, analysis_id, figure_id });
        set(dropdown, 'Value', selected_dropdown);
    end
    
    % Generate the summary of numeric data from the analysis data structure
    ui_summary = uicontrol( 'Parent', uitab_summary, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'left',...
                            'String', '', 'Position', [uis uis 1-2*uis 1-2*uis],...
                            'FontSize', ui_figures.fontsize_text, 'BackgroundColor', ui_figures.bg_charts);
    
    txt_summary = '';
    fields = fieldnames(a);
    
    for i=1:numel(fields)
        field_name = strrep(fields{i}, '_', ' ');
        
        spaces = ''; nsp = 20-length(field_name);
        for(sp = 1:nsp), spaces = [spaces,' ']; end %#ok<NO4LP,AGROW>
        
        if( isscalar(a.(fields{i})) || (size(a.(fields{i}),1)==2&&size(a.(fields{i}),2)==1) )
            field_value = num2str( a.(fields{i}) );
        else
            field_value = ['[', num2str(size(a.(fields{i}))), ']'];
        end
        txt_summary = sprintf('%s\n', [txt_summary, field_name, ': ', spaces, field_value]);
    end
    set(ui_summary, 'String', txt_summary);
    set(ui_summary, 'FontName', 'FixedWidth');
    is_ui_toclipboard(cf, uitab_summary, [20 20], txt_summary); 

    icon = imread('update.png');
    uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'normalized', 'Position', [0.925 0.9125 0.05 0.075], 'cdata', icon,...
                'Callback', { @analysis_mtf_ptf_pf, analyses, s, channel, analysis_id, figure_id }); 

    %icon = imread('new_window.png');
    %uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', [86 157 199]/256,...
    %            'Units', 'normalized', 'Position', [0.870 0.9125 0.05 0.075], 'cdata', icon,...
    %            'Callback', { @analysis_mtf_ptf_pf, analyses, s, channel, analysis_id });
            
    icon = imread('export.png');
    ui_export = uicontrol(  'Parent', figure_id, 'Style', 'PushButton', 'BackgroundColor', ui_figures.bg_special,...
                'Units', 'normalized', 'Position', [0.870 0.9125 0.05 0.075], 'cdata', icon);
                            
%% STEP 1 Calculate some general min/max values
    psf_max_crop_size = 0;
    
    for chn = 1:no_channels
        ai = analysis{ chn };

        PSF = ai.PSF_cropped;
        psf_max_crop_size = max(psf_max_crop_size, size(PSF, 1));
    end

%% Wavefront Analysis
    if(s.polypsf_mode == 0)
        % We dont have this data when we are in polyPSF mode, because the
        % R, G and B PSFs are assembled from the stack.
        
        show_progress(ui_progress_bar, 5);

        x = a.pf_x*a.r;
        y = a.pf_y*a.r;
        
        if(~isempty(s.add_Wxy))

            Vr = wavefront2vergence(a.Wxy, a.Axy, a.r, 0);

        else
            % Use the methodology by Rob Iskander to calculate the refractive power map
            Vr = -is_refractive_power_map(a.zernikes, a.r, size(a.Axy,1));
            Vr(a.Axy == 0) = NaN;
        end

        data_Wxy= a.Wxy; data_Wxy(a.Axy==0)= NaN;

        ax = plot_map(x, y, data_Wxy, uitab_2d, ui_figures, [2,1,1], t('Wavefront Error [um]')); 
        plot_map(x, y, Vr,  uitab_2d, ui_figures, [2,1,2], t('Vergence [D]'));
        
        dataToSave = struct('Wxy', data_Wxy,...
                            'Vr', Vr,...
                            'lambda', a.lambda,...
                            'radius', a.r);
        is_ui_savestruct(cf, ax, [20 20], dataToSave);

        subplot(2,1,1, 'Parent', uitab_3d);
            surfc(a.pf_x*a.r, a.pf_y*a.r, data_Wxy); shading interp;  
            axis ([-a.r a.r -a.r a.r min(-0.01, min(data_Wxy(:))) max(max(data_Wxy(:), 0.01))]);
            title(t('Wavefront Error [um]'), 'FontSize', ui_figures.fontsize_title);
            xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
            ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
            zlabel('WFE [\mu m]','FontSize', ui_figures.fontsize_axes);
            colorbar('vert'); colormap('jet');

        subplot(2,1,2, 'Parent', uitab_3d);
            surfc(a.pf_x*a.r, a.pf_y*a.r, Vr); shading interp; 
            axis ([-a.r a.r -a.r a.r min(-0.01, min(Vr(:))) max(max(Vr(:), 0.01))]);
            title (t('Vergence [D]'), 'FontSize', ui_figures.fontsize_title);
            xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
            ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
            zlabel('V [D]','FontSize', ui_figures.fontsize_axes);
            colorbar('vert'); colormap('jet');
            
        show_progress(ui_progress_bar, 10);
 
        %% Slopes
        data=Tx; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_slopes, ui_figures, [2,2,3], 'Horizontal Slope dW/dx [mrad]');
        
        data=Ty; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_slopes, ui_figures, [2,2,4], 'Vertical Slope dW/dy [mrad]');

        data=Mer;	data(1,1)=-calib(1);	data(1,2)=0;	data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_slopes, ui_figures, [2,2,1], 'Radial Slope dW/dr [mrad]');

        data=Tang;	data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_slopes, ui_figures, [2,2,2], 'Tangential Slope dW/dt [mrad]');
        
        show_progress(ui_progress_bar, 20);
        
        %% Curvature
        data=DX; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_curvature, ui_figures, [2,2,1], 'Horizontal Curvature [D]');
        
        data=DY; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_curvature, ui_figures, [2,2,2], 'Vertical Curvature [D]');
        
        data=D2; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
        plot_map(x, y, data, uitab_curvature, ui_figures, [2,2,3], 'Mean Curvature [D]');
        
        show_progress(ui_progress_bar, 25);
         
        %% Vergence

        if(false)
            [rData, mData, regstats] = polarProfiles(x, y, radVergence, a.r); % use default thetaN,radiusN;

            subplot(2,2,3, 'Parent', uitab_vergence)
                errorbar(rData(1).^2, rData(2), rData(3), 'bo')
                xlabel('Squared radial distance (mm^2)')
                ylabel('Average Radial Profile')
                legend('Mean ± sem')
                title('Radial Profile (averaged over meridian)')

            subplot(2,2,4, 'Parent', uitab_vergence)
                errorbar(mData(1)*180/pi(), mData(3), mData(5),'bo-')
                xlabel('Meridional angle (deg)')
                ylabel('Average Meridional Profile')
                title('Meridional Profile (averaged over radius)')
                hold on
                errorbar(mData(2)*180/pi(), mData(4), mData(6),'r^-')
                legend('Mean ± sem', 'Marginal profile')

                % add the powerVector predictions for M
                %hold on
                %PV4 = -Zernike2Fourier(s.zernikes, a.r, 4); % 4th order Seidel calculation
                %PV6 = -Zernike2Fourier(s.zernikes, a.r, 6); % 6th order Seidel calculation
                %plot(0,PV4(1),'ks', 0,PV6(1),'k^')
                %legend('Data',['Slope= ',num2str(regstats(2,1)),' D/mm^2'],'Seidel M (4th order)','Seidel M (6th order)','Location','NorthWest')
                %legend('Mean ± sem');


            data=radVergence; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
            plot_map(x, y, data, uitab_vergence, ui_figures, [2,2,1], 'Radial Vergence [D]');

            data=tanVergence; data(1,1)=-calib(1); data(1,2)=0; data(1,3)=calib(1); data(a.Axy==0)= NaN;
            plot_map(x, y, data, uitab_vergence, ui_figures, [2,2,2], 'Tangential Vergence [D]');
        end
        
        show_progress(ui_progress_bar, 30);
        
        
        %% Spots
        
        Txx(1,1)=NaN; Tyy(1,1)=NaN;	% remove the calibration values added earlier
        ax = subplot(1,2,1, 'Parent', uitab_spots);
            plot(-Txx, -Tyy, '.r');
            axis square; linkaxes(ax);
            axis(1.1*[-radius radius -radius radius]); grid on;
            title('Spot Diagram', 'FontSize' , ui_figures.fontsize_title);
            xlabel('Horiz. visual angle [mrad]', 'FontSize' , ui_figures.fontsize_axes);
            ylabel('Vert. visual angle [mrad]', 'FontSize' , ui_figures.fontsize_axes);  

        ax = subplot(1,2,2, 'Parent', uitab_spots);
            quiver(xx, yy, -Txx, -Tyy);
            axis square; linkaxes(ax);
            axis(1.1*[-radius radius -radius radius]); grid on;
            title('Transverse Ray Aberrations [mrad]', 'FontSize', ui_figures.fontsize_title);
            text(-0.95*radius, -0.92*radius, num2str(calib(2))); % label the calibration arrow
            xlabel('Horizontal Pupil Location [mm]', 'FontSize', ui_figures.fontsize_axes);
            ylabel('Vertical Pupil Location [mm]', 'FontSize', ui_figures.fontsize_axes);  
        
    end

%% MTF Analysis

    show_progress(ui_progress_bar, 35);
    % MTF plots - all colour channels on common plot. Suggested by Phil Kruger.
         
    legend_entries = cell(2*no_channels,1);
    
    bandwidth = 0.5*analysis{1}.psf_bandwidth;
    
    for chn = 1:no_channels
        ai = analysis{chn};
        %data = abs(ai.OTF_cropped);
        data = abs(ai.OTF);
        
        %data(ai.otf_mask == 0) = NaN;	% a trick to avoid plotting outside pupil
        %data(data < 1e-6) = NaN;        % trap very small modulations
        if(chn == channel), current_channel_data = data; end
        midrow = floor(1 + size(data,1)/2);
        
        dMTF = abs(s.dOTF(:,:,chn));
        
        legend_entries{2*chn-1} = sprintf('%s MTF', channelNames{ai.lambda_idx});
        legend_entries{2*chn} = sprintf('Diffraction for %3.2fnm', ai.lambda);

        subplot(1,1,1, 'Parent', uitab_mtf_horizontal);
            plot(ai.psf_x(midrow,:)*ai.psf_bandwidth, data(midrow,:),   '-', 'Color', ai.lambda_rgb, 'LineWidth', 1.5); hold on
            plot(ai.psf_x(midrow,:)*ai.psf_bandwidth, dMTF(midrow,:),   '-.', 'Color', ai.lambda_rgb, 'LineWidth', 1);
            xlabel('freq [c/d]', 'FontSize', ui_figures.fontsize_axes);
            axis ([0 2*bandwidth 0 1]);
            legend(legend_entries{1:2*chn});
            grid on; grid minor;

        subplot(1,1,1, 'Parent', uitab_mtf_vertical);
            plot(ai.psf_y(:,midrow)*ai.psf_bandwidth, data(:,midrow),   '-', 'Color', ai.lambda_rgb, 'LineWidth', 1.5); hold on
            plot(ai.psf_y(:,midrow)*ai.psf_bandwidth, dMTF(midrow,:),   '-.', 'Color', ai.lambda_rgb, 'LineWidth', 1);
            xlabel('freq [c/d]', 'FontSize', ui_figures.fontsize_axes);
            axis ([0 bandwidth 0 1]);
            legend(legend_entries{1:2*chn});
            grid on; grid minor;
            
        [~, ~, data_x, data_radial] = RadialAverage(data, ai.psf_x, ai.psf_y);
        [~, ~, dMTF_x, dMTF_radial] = RadialAverage(dMTF, ai.psf_x, ai.psf_y);
            
        subplot(1,1,1, 'Parent', uitab_mtf_radial);
            plot(data_x*ai.psf_bandwidth, data_radial,   '-', 'Color', ai.lambda_rgb, 'LineWidth', 1.5); hold on
            plot(dMTF_x*ai.psf_bandwidth, dMTF_radial,   '-.', 'Color', ai.lambda_rgb, 'LineWidth', 1);
            xlabel('freq [c/d]', 'FontSize', ui_figures.fontsize_axes);
            axis ([0 bandwidth 0 1]);
            legend(legend_entries{1:2*chn});
            grid on; grid minor;
            
        show_progress(ui_progress_bar, 35+(25*chn/no_channels)); 
            
    end
    hold off;
    
    show_progress(ui_progress_bar, 60);
    
    ax = subplot(1,1,1, 'Parent', uitab_mtf_current);
        data = current_channel_data;
        midrow = floor(1 + size(data,1)/2);
        
        dMTF = abs(s.dOTF(:,:,channel));
        
        [~, ~, data_x, data_radial] = RadialAverage(data, a.psf_x, a.psf_y);
        
        dMTF_support = ai.psf_x(midrow,:)*ai.psf_bandwidth;
        [~,~,~, CS] = getNeuralCSF(dMTF_support);
        CSF = CS/max(CS(:));
        neural_mtf = dMTF_support(dMTF_support >= 0);
        plot(a.psf_x(midrow,:)*a.psf_bandwidth, data(midrow,:),     '-', 'Color', analysis{channel}.lambda_rgb,'LineWidth',2); hold on
        plot(a.psf_y(:,midrow)*a.psf_bandwidth, data(:,midrow),     ':', 'Color', analysis{channel}.lambda_rgb,'LineWidth',2);
        plot(data_x*a.psf_bandwidth, data_radial,                   '-.', 'Color', analysis{channel}.lambda_rgb,'LineWidth',2);
        plot(a.psf_x(midrow,:)*a.psf_bandwidth, dMTF(midrow,:),     'k-.', 'LineWidth', 1);
        plot(neural_mtf(1:length(CSF)), CSF,                        'k:', 'LineWidth', 1.5);
        
        % For Arthur
        %fprintf('Radial MTF freuquencies [cyc / deg] and values');
        %output = [data_x*a.psf_bandwidth, data_radial]
        
        xlabel('freq [c/d]', 'FontSize', ui_figures.fontsize_axes);
        ylabel('MTF', 'FontSize', ui_figures.fontsize_axes);
        legend('Horizontal MTF', 'Vertical MTF', 'Radial MTF', 'Diffraction MTF', 'Neural CSF');
        axis ([0 bandwidth 0 1]);
        grid on; grid minor;
        hold off;
        
        mtf_data = sprintf('[c/d]\tRadial MTF\tCSF\n');
        for f = 1:length(data_x)
            mtf_data = sprintf('%s%3.3f\t%1.3f\t%1.3f\n', mtf_data, data_x(f)*a.psf_bandwidth, data_radial(f), CSF(min(f, length(CSF))));
        end

        is_ui_saveclipboard(cf, ax, [20 20], mtf_data);
        
        
    %subplot(1,1,1, 'Parent', uitab_mtf_current3d);

        %surfc(a.psf_x*a.psf_bandwidth, a.psf_y*a.psf_bandwidth,data); shading interp;
        %axis xy; axis ([-bandwidth bandwidth -bandwidth bandwidth 0 1]);
        %view(3);

        %xlabel('freq x [c/d]','FontSize', ui_figures.fontsize_axes);
        %ylabel('freq y [c/d]','FontSize', ui_figures.fontsize_axes);
    
        

%% Display the PSF
    show_progress(ui_progress_bar, 80);

    psf_scale = a.psf_scale;
    PSF = a.PSF_cropped;
    PSF_disp = PSF;
    
    ax = subplot(1,1,1, 'Parent', uitab_psf);
        scale = -size(PSF_disp,1):size(PSF_disp,1);

        imagesc(PSF_disp, 'XData', s.pixsize*psf_scale*scale/2, 'YData', s.pixsize*psf_scale*scale/2);
        colorbar('peer', ax, 'off')
        is_ui_saveimg(cf, ax, [20 20]);
        
        %plot(cx, cy, 'yx');
        %is_draw_arcmin_scale(size(PSF(:,:,rgb)), psf_line, ui_figures.legend_linecolor);
        %is_text(10, 20, sprintf('%3.0f x %3.0f px, %s arcmin', size(PSF,2), size(PSF,1), num2str(ui_figures.legend_arcmins)), ui_figures.legend_linecolor);
        title(sprintf('%s %s PSF', channelNames{a.lambda_idx}, psf_type), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
        xlabel('Visual Angle [arcmin]');
        set(gca, 'XColor', [0.5 0.5 0.5], 'YColor', [0.5 0.5 0.5]); axis square;
      
    %ax = subplot(2,1,1, 'Parent', uitab_pupil);
    %    scale = -a.r:a.r;
    %    imagesc(a.Axy, 'XData', scale, 'YData', scale);
    %    is_ui_saveimg(cf, ax, [20 20]);
    %    colorbar('peer', ax, 'vert', 'Color', ui_figures.axis_simulation);
    %    title(t('Pupil Preview'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
    %    set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
    %    xlabel('X [mm]'); ylabel('Y [mm]'); 
        
    %ax = subplot(2,1,2, 'Parent', uitab_pupil);
    %    pupil_slice_x = a.Axy(floor(length(a.Axy(1,:))/2), :);
    %    pupil_slice_y = a.Axy(:, floor(length(a.Axy(:,1))/2));
    %    
    %    lps = floor(length(pupil_slice_x));
    %    scale = (-lps/2:1:lps/2-1)/lps*2*a.r;
    %    
    %    plot(scale,pupil_slice_x, scale,pupil_slice_y);
    %    colorbar('peer', ax, 'off')
    %    title(t('Pupil Profiles'), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
    %    l = legend('x', 'y'); set(l, 'Color', ui_figures.bg_simulation, 'TextColor', ui_figures.axis_simulation);
    %    xlabel('X [mm]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation, 'Color', ui_figures.bg_simulation);
    %    axis square;  
          
    show_progress(ui_progress_bar, 100);        
        
    if(s.polypsf_mode == 1 && strcmp(s.analysis_mode, 'single'))
        
        analysis = analyses{analysis_id};
        analysis = analysis.data_spd;
        
        uitab_psfs = uitab(uitabs_tr,           'Title', 'Mono-PSF Stack', 'BackgroundColor', ui_figures.bg_simulation);
        uitabs_psfs = uitabgroup(uitab_psfs,    'Units', 'normalized', 'Position', [0 0 1 1]);
        
        no_channels = length(analysis);
        tabs_psfs = zeros(no_channels,1); 
        
        for chn = 1:no_channels
            
            a = analysis{chn};
            radiance = s.spd(chn, channel)/max(s.spd(:,channel));
            
            % Display the PSF Stack in the right panel.
            % Resize the PSF to be commensurate with object.
            % psf_resolution = 2*a.psf_halfwidth/size(a.PSF,1);	
            psf_scale = a.psf_resolution/s.pixsize;               % scale required to make pixel size of PSF = pixel size of object   
            [~, PSF_cropped] = is_psf_rescale(a.PSF, psf_scale, ui_defaults.psf_rescale_method);
            
            PSF = PSF_cropped; scale = a.psf_resolution;
            
            psf_scale_x = (-size(PSF,1):size(PSF,1)-1)/2*scale;
            psf_scale_y = psf_scale_x;
            
            tabs_psfs(chn) = uitab(uitabs_psfs, 'Title', sprintf('%4.1f nm', a.lambda), 'Tag', num2str(chn), 'BackgroundColor', ui_figures.bg_simulation);
            ax = subplot(1,1,1, 'Parent', tabs_psfs(chn));

                imagesc(PSF, 'XData', psf_scale_x, 'YData', psf_scale_y); axis('square');
                is_ui_saveimg(cf, ax, [20 20]);
                
                title(sprintf('Mono-PSF, relative radiance: %2.2f', radiance), 'FontSize', ui_figures.fontsize_title, 'Color', [1 1 1]);
                xlabel('Visual Angle [arcmin]'); set(gca, 'XColor', ui_figures.axis_simulation, 'YColor', ui_figures.axis_simulation); axis square;
        end
    end
    
    if(s.polypsf_mode == 1 && strcmp(s.analysis_mode, 'single'))
        tabs_wxys_2d = zeros(no_channels,1);
        tabs_wxys_3d = zeros(no_channels,1);

        for chn = 1:no_channels
            % Display the PSF Stack wavefronts in the left panel
            tabs_wxys_2d(chn) = uitab(uitabs_2d, 'Title', sprintf('%4.1f nm', a.lambda), 'Tag', num2str(chn), 'BackgroundColor', ui_figures.bg_charts);
            tabs_wxys_3d(chn) = uitab(uitabs_3d, 'Title', sprintf('%4.1f nm', a.lambda), 'Tag', num2str(chn), 'BackgroundColor', ui_figures.bg_charts);
        end
        %set(uitabs_psfs, 'SelectionChangedFcn', { @change_colormap_spd, analysis });
        set(uitabs_2d, 'SelectionChangedFcn', { @reload_wavefront, analysis, tabs_wxys_2d, tabs_wxys_3d, ui_figures });
        set(uitabs_3d, 'SelectionChangedFcn', { @reload_wavefront, analysis, tabs_wxys_2d, tabs_wxys_3d, ui_figures });
        
        reload_wavefront([], [], analysis, tabs_wxys_2d, tabs_wxys_3d, ui_figures);
    end
    
    % show some luv :3 
    show_progress(ui_progress_bar, 0);

    set(ui_launch_sim, 'Callback', { @analysis_retinal_sim, analyses, s, analysis_id });
    set(figure_id, 'DeleteFcn', { @close_figure, analyses, s });
    
    set(ui_export, 'Callback', { @export_analyses, cf, analyses, s, 'mtf' });
    
    uicontrol(  figure_id, 'Style', 'text', 'Units', 'normalized', 'HorizontalAlignment', 'center', 'BackgroundColor', ui_figures.bg_figure,...
                'String', ui_defaults.is_footer, 'Position', [0.025 0.0125 0.95 0.025], 'FontSize', ui_figures.fontsize_text, 'ForegroundColor', 0.6*ui_figures.bg_figure); 
    
end % end function

function close_figure(~, ~, analyses, s) %#ok<INUSD>
    % this cleans up heaps of memory consumed by each analysis window
    clearvars analyses;
    clearvars s;
end

function select_dropdown_step(hObject, ~, analyses, s, channel, figure_id)
    i = get(hObject, 'Value');
    analysis_mtf_ptf_pf([], [], analyses, s, channel, i, figure_id);
end

function select_dropdown_lambda(hObject, ~, analyses, s, analysis_id, figure_id)
    rgb = get(hObject, 'Value');
    analysis_mtf_ptf_pf([], [], analyses, s, rgb, analysis_id, figure_id);
end

function reload_wavefront(~, args, analysis, tabs2d, tabs3d, ui_figures)

    if(isempty(args))
        chn = 1;
    else
        chn = str2double(args.NewValue.Tag);
    end
    
    tabs2d = tabs2d(chn);
    tabs3d = tabs3d(chn);
    
    a = analysis{chn};
    
    % Display the PSF Stack wavefronts in the left panel

    x = a.pf_x*a.r;
    y = a.pf_y*a.r;

    % [~, ~, LA, ~, ~] = showdWdx(a.Wxy, x, y, a.Axy,[],[],0); % <- last var is 'plot extra graphics'
    
    % Use the code from FOC to calculate the refractive power map
    % Elapsed time is 0.033065 seconds.
    % tic; [~, ~, LA, ~, ~] = showdWdx(a.Wxy, x, y, a.Axy,[],[],0); toc % <- last var is 'plot extra graphics'

    % Use the methodology by Rob Iskander to calculate the refractive power map
    % Elapsed time is 0.555130 seconds.
    LA = is_refractive_power_map(a.zernikes, a.r, size(a.Axy,1));  

    data_LA = -LA;   data_LA(a.Axy==0) = NaN;
    data_Wxy= a.Wxy; data_Wxy(a.Axy==0)= NaN;
    
    plot_map(x, y, data_Wxy, tabs2d, ui_figures, [2,1,1], t('Wavefront Error [um]'));
    plot_map(x, y, data_LA,  tabs2d, ui_figures, [2,1,2], t('Vergence [D]'));

    ax = subplot(2,1,1, 'Parent', tabs3d);
        surfc(a.pf_x*a.r, a.pf_y*a.r, data_Wxy); shading interp;  
        axis ([-a.r a.r -a.r a.r min(-0.01, min(data_Wxy(:))) max(max(data_Wxy(:), 0.01))]);
        %title(sprintf('Wavefront Error [um]'), 'FontSize', ui_figures.fontsize_title);
        xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
        ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
        zlabel('WFE [\mu m]','FontSize', ui_figures.fontsize_axes);
        colorbar('peer', ax, 'vert');
        colormap('jet');

    ax = subplot(2,1,2, 'Parent', tabs3d);
        surfc(a.pf_x*a.r, a.pf_y*a.r, data_LA); shading interp; 
        axis ([-a.r a.r -a.r a.r min(-0.01, min(data_LA(:))) max(max(data_LA(:), 0.01))]);
        %title ('Refraction map [D]', 'FontSize', ui_figures.fontsize_title);
        xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
        ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
        zlabel('Vergence [D]','FontSize', ui_figures.fontsize_axes);
        colorbar('peer', ax, 'vert');
        colormap('jet');  
    
end


%function plot_contour(x, y, data, h, ui_figures, i, title_text)
%    ax = subplot(i(1),i(2),i(3), 'Parent', h);
%
%        data_range = [floor(min(min(data))) ceil(max(max(data)))];
%        cstep = (data_range(2) - data_range(1))/ui_figures.no_contours;
%        v = (data_range(1):cstep:data_range(2));
%
%        contourf(x,y,data,v);
%
%        title(title_text, 'FontSize' , ui_figures.fontsize_title);
%        xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
%        ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
%        colorbar('peer', ax, 'vert');
%        axis square; colormap('jet');
%end

function ax = plot_map(x, y, data, h, ui_figures, i, title_text)
    ax = subplot(i(1),i(2),i(3), 'Parent', h);

        imagesc(data, 'XData', x(1,:), 'YData', y(:,1));

        title(title_text, 'FontSize' , ui_figures.fontsize_title);
        xlabel('X [mm]','FontSize', ui_figures.fontsize_axes);
        ylabel('Y [mm]','FontSize', ui_figures.fontsize_axes);
        colorbar('peer', ax, 'vert');
        axis square; colormap('jet');
end

%function change_colormap(~, ~, desired_colormap)
%    colormap(desired_colormap);
%end

%function change_colormap_spd(~, args, a)
%    selected_tab_idx = str2double(args.NewValue.Tag);
%    colormap(a{selected_tab_idx}.colormap);
%end
function settings_dialog( ~, ~ )
%SETTINGS_DIALOG Launches the advanced settings dialog box.

    ui_defaults = getappdata(gcbf, 'ui_defaults');
    ui_figures = getappdata(gcbf, 'ui_figures');

    if(exist(ui_defaults.config_file, 'file')), load(ui_defaults.config_file); end
    
    rows_per_col = 10;
    
    uih = ui_figures.ui_unit_height;
    uil = ui_figures.ui_unit_length;
    uis = ui_figures.ui_unit_spacing;
    
    sf = figure('name', 'Advanced Settings', 'Units', 'normalized', 'OuterPosition', [0.3 0.10 0.4 0.80]); axis off;
    set(sf, 'NumberTitle', 'off');
    jframe = get(sf, 'javaframe');
    jIcon = javax.swing.ImageIcon([pwd,filesep,'includes',filesep,'icons',filesep,'icon.png']);
    jframe.setFigureIcon(jIcon);
    
    info = {};
    info{end+1} = 'The default settings below affect the core functionality of the program and probably shouldn''t be changed.';
    info{end+1} = 'Please observe the syntax: dots, square brackets, quotation marks.';

    uip_info =      uipanel(    'Parent', sf, 'Title', 'Information', 'Units', 'normalized', 'Position', [uis 0.9-uis 1-2*uis 0.1]);
                    uicontrol(  'Parent', uip_info, 'Style', 'text', 'units', 'normalized', 'Position', [uis -4*uis 1-uis 1-uis],...
                                'HorizontalAlignment', 'left', 'FontSize', ui_figures.fontsize_text,...
                                'String', info);
    
    uitabs_settings = uitabgroup('Parent',sf, 'Units', 'normalized', 'Position', [uis 0.11 1-2*uis 0.75]);
        uitab_about = uitab(uitabs_settings, 'Title', 'About', 'BackgroundColor', ui_figures.bg_panel);
        uitab_defaults = uitab(uitabs_settings, 'Title', 'Default Values', 'BackgroundColor', ui_figures.bg_panel);
        uitab_figures = uitab(uitabs_settings, 'Title', 'Appearance', 'BackgroundColor', ui_figures.bg_panel);
    
    fields = fieldnames(ui_defaults);
    new_defaults = zeros(length(fields));
    uiy = 1 - uih - 2*uis;
    uix = uis;
    for i=1:length(fields)
        if(mod(i, rows_per_col) == 0)
            uix = uix + 2.3*uil;
            uiy = 1 - uih - 2*uis;
        end
        field = fields{i};
        value = ui_defaults.(fields{i});
        if(ischar(value))
            value = sprintf('"%s"', value);
        elseif(ismatrix(value)&&length(value)>1)
            value = sprintf('[%s]', implode(value, ';'));
        end
                        uicontrol(  'Parent', uitab_defaults, 'Style', 'text', 'units', 'normalized', 'Position', [uix uiy 1.3*uil uih],...
                                    'HorizontalAlignment', 'left', 'FontSize', ui_figures.fontsize_text,...
                                    'String', sprintf('%s:', strrep(field, '_', ' ')));
        new_defaults(i) = uicontrol('Parent', uitab_defaults, 'Style', 'edit', 'units', 'normalized', 'Position', [uix+(2*uis+uil) uiy+1.5*uis 0.9*uil 0.7*uih],...
                                    'HorizontalAlignment', 'center', 'FontSize', ui_figures.fontsize_text,...
                                    'String', value);
        uiy = uiy - uih;
    end
    
    fields = fieldnames(ui_figures);
    new_figures = zeros(length(fields));
    uiy = 1 - uih - 2*uis;
    uix = uis;
    for i=1:length(fields)
        if(mod(i, rows_per_col) == 0)
            uix = uix + 2.3*uil;
            uiy = 1 - uih - 2*uis;
        end
        field = fields{i};
        value = ui_figures.(fields{i});
        if(ischar(value))
            value = sprintf('"%s"', value);
        elseif(ismatrix(value)&&length(value)>1)
            value = sprintf('[%s]', implode(value, ';'));
        end
                        uicontrol(  'Parent', uitab_figures, 'Style', 'text', 'units', 'normalized', 'Position', [uix uiy 1.3*uil uih],...
                                    'HorizontalAlignment', 'left', 'FontSize', ui_figures.fontsize_text,...
                                    'String', sprintf('%s:', strrep(field, '_', ' ')));
        new_figures(i) = uicontrol( 'Parent', uitab_figures, 'Style', 'edit', 'units', 'normalized', 'Position', [uix+(2*uis+uil) uiy+1.5*uis 0.9*uil 0.7*uih],...
                                    'HorizontalAlignment', 'center', 'FontSize', ui_figures.fontsize_text,...
                                    'String', value);
        uiy = uiy - uih;
    end
    
    credits = {};
    credits{end+1} = [ui_defaults.is_name, ' is jointly developed by the CiViUM Research Group, at the University of Murcia and IUSO, at the Indiana University.'];
    credits{end+1} = 'http://blogs.iu.edu/corl, and http://um.es/civium';
    credits{end+1} = '';
    credits{end+1} = 'Matt Jaskulski - lead developer, ';
    credits{end+1} = 'Larry Thibos et. al. - core developer,';
    credits{end+1} = '';
    credits{end+1} = 'Contributors: Sowmya Ravikumar (polychromatic PSF algorithms), Jos Rozema (statistical wavefront generator),';
    credits{end+1} = 'Linda Lundström (Zernike rescaling algorithms), and others.';
    credits{end+1} = '';
    credits{end+1} = 'Special Thanks to: Norberto López Gil, Arthur Bradley, Pete Kollbaum, D. Robert Iskander, Iván Marin-Franch, Miguel Faria Ribeiro.';
    credits{end+1} = 'For support and feedback visit: http://blogs.iu.edu/corl/iris.';
    credits{end+1} = '';
    credits{end+1} = 'With collaboration of FP7-Marie Curie–ITN-2013-AGEYE-GA 608049.';
    credits{end+1} = '';
    credits{end+1} = 'Released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License. See license.txt for details.';
    
        uicontrol(  'Parent', uitab_about, 'Style', 'text', 'units', 'normalized', 'Position', [uis 0 1-2*uis 0.75],...
                    'HorizontalAlignment', 'left', 'FontSize', ui_figures.fontsize_text,...
                    'String', credits);
                
        icon = imread('credits.png');
        uicontrol(  'Parent', uitab_about, 'Style', 'PushButton', 'Units', 'normalized', 'HorizontalAlignment', 'center',...
                    'String', '', 'cdata', icon, 'Position', [0 0.8 1 0.2],...
                    'FontSize', ui_figures.fontsize_text, 'BackgroundColor', ui_figures.bg_panel,...
                    'Callback', { @open_url, 'http://um.es/civium' });

            
    % aligned to the bottom

    uicontrol(  'Parent', sf, 'Style', 'text', 'units', 'normalized', 'Position', [0.25 uis 0.6-2*uis uih],...
                'HorizontalAlignment', 'right', 'FontSize', ui_figures.fontsize_text,...
                'String', t('All changes are applied immediately, but to see them in the GUI please restart the program. There is no input validation here. Proceed with caution!'));

    icon = imread('apply.png');
                    uicontrol(  'Parent', sf, 'Style', 'PushButton', 'Units', 'normalized', 'HorizontalAlignment', 'right',...
                                'String', '', 'cdata', icon, 'Position', [1-uis-0.15 uis 0.15 uih],...
                                'FontSize', ui_figures.fontsize_text, 'BackgroundColor', ui_figures.bg_green,...
                                'Callback', { @settings_dialog_save, gcbf, ui_defaults, ui_figures, new_defaults, new_figures });
                           

end

function open_url(~, ~, url)
    web(url);
end

function settings_dialog_save(~, ~, cf, ui_defaults, ui_figures, new_defaults, new_figures)

    fields = fieldnames(ui_defaults);
    for i=1:length(fields)
        new_value = get(new_defaults(i), 'String');
        if(strcmp(new_value(1),'[')) % is matrix
            new_value = new_value(2:end-1);
            new_value = explode(new_value, ';');
            val = zeros(length(new_value),1);
            for j=1:length(new_value)
                val(j) = str2double(new_value{j});
            end
            new_value = val;
        elseif(strcmp(new_value(1),'"')) % is string
            new_value = new_value(2:end-1);
        else % is numeric
            new_value = str2double(new_value);
        end
        
        ui_defaults.(fields{i}) = new_value;
    end
    
    fields = fieldnames(ui_figures);
    for i=1:length(fields)
        new_value = get(new_figures(i), 'String');
        if(strcmp(new_value(1),'[')) % is matrix
            new_value = new_value(2:end-1);
            new_value = explode(new_value, ';');
            val = zeros(length(new_value),1);
            for j=1:length(new_value)
                val(j) = str2double(new_value{j});
            end
            new_value = val;
        elseif(strcmp(new_value(1),'"')) % is string
            new_value = new_value(2:end-1);
        else % is numeric
            new_value = str2double(new_value);
        end
        
        ui_figures.(fields{i}) = new_value;
    end
    
    setappdata(cf, 'ui_defaults', ui_defaults);
    setappdata(cf, 'ui_figures', ui_figures);

    save(ui_defaults.config_file, 'ui_defaults', 'ui_figures');

    show_msg(cf, 'Settings Saved')
    close gcbf;
end

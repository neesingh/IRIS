function generate_zernikes_pyramid( cf, no_zernikes )

    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures'); 
    ui_defaults =getappdata(cf, 'ui_defaults');
    ui_zernikes =getappdata(cf, 'ui_zernikes');   % array to hold zernike ui elements (and values) from the GUI
    ui_radios =  getappdata(cf, 'ui_radios');     % array to hold the user's selection of zernike term to sweep thru

    uil = ui_figures.ui_unit_length;
    uih = ui_figures.ui_unit_height;
    uis = ui_figures.ui_unit_spacing;
    
    zernike_orders = mode2index(no_zernikes+1)+1;
    
    if(~isempty(ui_zernikes))
        delete(ui_zernikes);
        delete(ui_radios);
    end
    
    ui_radios = zeros(no_zernikes,1);
    ui_zernikes = zeros(no_zernikes,1);
    i = 1;
    
    uil = (7/zernike_orders)*uil;
    uih = 0.56 * (9/zernike_orders)*uih;

    for o=1:zernike_orders-1
        for f=1:o
            uix = 0.505+(uis/2+uil)*(f-1)-(o*(uis/2+uil)/2);
            uiy = 0.9-3*uis-(2*uih)*o;
            ui_zernikes(i) = uicontrol( 'Parent', ui_handles.uipanel_zernikes, 'Style', 'edit', 'Units', 'normalized',...
                                        'String', sprintf(['%',ui_defaults.float_precision,'f'], 0), 'Position', [uix uiy uil uih],...
                                        'FontSize', floor(12/zernike_orders*ui_figures.fontsize_small), 'BackgroundColor', [0.2 0.4+0.6*((o+f)/no_zernikes) sqrt(0.4+0.8*((o+f)/no_zernikes))],...
                                        'Callback', { @validate_zernike });

            % jEdit = findjobj(ui_zernikes(end)); jEdit.Border = [];
            % undocumented matlab, way to get rid of borders and whatnot - cosmetics

            [order, frequency] = mode2index(i);
            ui_radios(i) = uicontrol(   'Parent', ui_handles.uigroup_radios, 'Style', 'radiobutton', 'Units', 'normalized',...
                                        'String', sprintf('C(%d,%d)', order, frequency), 'Tag', num2str(i-1),...
                                        'FontSize', ui_figures.fontsize_small, 'Position', [uix uiy-0.7*ui_figures.ui_unit_height uil ui_figures.ui_unit_height]);
             i = i+1;
        end
    end

    set(ui_radios(ui_defaults.selected_zernike), 'Value', 1);

    setappdata(cf, 'ui_zernikes', ui_zernikes);
    setappdata(cf, 'ui_radios', ui_radios);

end


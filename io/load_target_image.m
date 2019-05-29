function load_target_image(hObject, ~, cf)
% load image that will serve as the target into the workspace

    if nargin < 3
        cf = gcbf;
    end
    
    ui_handles = getappdata(cf, 'ui_handles');
    ui_figures = getappdata(cf, 'ui_figures');
    ui_defaults= getappdata(cf, 'ui_defaults'); 

    names = {t('Red'), t('Green'), t('Blue')};
    imgs = {};
    images_library;

    if(isempty(hObject)) % init
        filename = imgs{1,1};
        pathname = [ui_defaults.iris_root, filesep, 'images'];   
    else
        [filename, pathname, ~] = uigetfile({ '*.jpg;*.tif;*.hdf;*.png;*.bmp', t('Compatible Image Files')},...
                                              t('Select an image file to import'), ui_defaults.current_filepath, ...
                                              'MultiSelect', 'off');
    end
    
    if ~isequal(filename,0)
        
        % get the image and update the last visited path
        ui_defaults.current_filepath = pathname;
        img = imread(fullfile(pathname, filename));
        imgsize = size(img);
        
        % resize the image to the size of the thumb
        thumb_height = get(cf, 'OuterPosition');
        thumb_height = thumb_height(4)/4;
        thumb = imresize(img, thumb_height/size(img,1));
        if(size(img,3)==1), thumb = gray2rgb(thumb); end
        ts = size(thumb);
        ts = [min(ts(1:2)) min(ts(1:2))]; % crop so it's a square
        
        % get the uitabgroup where to generate channel tabs
        first_tab= get(ui_handles.target_image, 'Parent'); % tab
        tabgroup = get(first_tab, 'Parent');
        
        % remove the existing tabs except the original one
        tabs = get(tabgroup, 'Children');
        if(length(tabs) > 1)
            tabs = tabs(2:end);
            delete(tabs);
        end
     
        % figure out the position of the thumb     
        if(isempty(get(ui_handles.target_thumb, 'cdata'))) % first run
            tab = get(ui_handles.target_thumb, 'Parent');
            ps = getpixelposition(tab);  
            thumb_position = [(ps(3)-ts(2))/2 -3+(ps(4)-ts(1))/2 ts(2) ts(1)];
        else
            thumb_position = get(ui_handles.target_thumb, 'Position');
        end
        
        % if the image is a colour image, split it into channel tabs
        if(length(imgsize)==2)
            imgsize(3) = 1;
        else  
            
            for c = 1:imgsize(3)
                tab = uitab(tabgroup, 'Title', names{c}, 'Tag', num2str(c));
                
                ui_channel_thumb = uicontrol(   'Parent', tab, 'Style', 'PushButton', 'Units', 'pixels',...
                                                'String', '', 'Position', [0 0 1 1], 'cdata', [],...
                                                'ForegroundColor', ui_figures.legend_linecolor,...
                                                'BackgroundColor', ui_figures.bg_simulation,...
                                                'FontSize', 2*ui_figures.fontsize_title);
                                            
                ui_channel_dimensions=uicontrol('Parent', tab, 'Style', 'text', 'Units', 'normalized',...
                                                'String', '', 'Position', [0 0 1 ui_figures.ui_unit_height+ui_figures.ui_unit_spacing],...
                                                'FontSize', ui_figures.fontsize_text);               
                
                set(ui_channel_thumb, 'cdata', gray2rgb(thumb(:,:,c)));
                set(ui_channel_thumb, 'position', thumb_position);
                set(ui_channel_thumb, 'Callback', { @load_target_image });
                
                set(ui_channel_dimensions,  'String',  sprintf(t('%d channel(s), %d bit, %dx%dpx - %s.'),...
                                            1,...
                                            ui_defaults.bpp,...
                                            imgsize(2), imgsize(1),...
                                            filename));
            end
        end
        
        for i = 1:size(imgs,1)
            if strcmp(imgs(i,1), filename)
                ui_defaults.pixsize = imgs{i,2};
                break
            end
        end

        pause(0.1);
        
        set(ui_handles.image_pixsize, 'String', num2str(ui_defaults.pixsize)); % important - although hidden, it's from here that the data gets passed further
        set(ui_handles.image_dimensions, 'String',  sprintf(t('%d channel(s), %d bit, %dx%dpx - %s.'),...
                                                    imgsize(3),...
                                                    ui_defaults.bpp*imgsize(3),...
                                                    imgsize(2), imgsize(1),...
                                                    filename));
                                     
        set(ui_handles.target_thumb, 'position', thumb_position);
        set(ui_handles.target_thumb, 'cdata', thumb);
        set(ui_handles.target_thumb, 'String', sprintf('%2.3f [am/px]', ui_defaults.pixsize));
        set(ui_handles.target_image, 'UserData', img);
        set(ui_handles.original_image, 'UserData', img);
   
        % reset the pupil mask because if the number of channels change...
        set(ui_handles.pupil_mask, 'UserData', []);
        set(ui_handles.load_pupil_mask, 'String', 'None');
        set(ui_handles.load_pupil_mask, 'BackgroundColor', ui_figures.bg_figure);
        
        %ui_defaults.no_channels = imgsize(3);
        setappdata(cf, 'ui_defaults', ui_defaults);

    end
        
end
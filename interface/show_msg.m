function show_msg( cf, txt, status )
%MESSAGE this function outputs messages to Matlab's console IF the user
%wants to see them

    if(nargin < 3), status = 'info'; end    % info, success or error

    ui_defaults = getappdata(cf, 'ui_defaults');
    ui_figures =  getappdata(cf, 'ui_figures');
    ui_handles =  getappdata(cf, 'ui_handles');

    txt2 = ['[',status,'] ',txt];
    len = max(length(txt2), 80);
    
    if(ui_defaults.show_messages == 1)
        
        fontsize = (80/len)*ui_figures.fontsize_title;
        
        set(ui_handles.preloader, 'String', txt);
        set(ui_handles.preloader, 'FontSize', fontsize);
        pause(0.5);
        
    end
    
    log_file = fopen(ui_defaults.log_file, 'a');
    fprintf(log_file, ['\r\n',txt2]);
    fclose(log_file);
    
    if(strcmp(status, 'error')), error(txt2); end

end


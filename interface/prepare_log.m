function [log_file] = prepare_log( cf )
%PREPARE_LOG This function clears the log during IS's startup.

    ui_defaults = getappdata(cf, 'ui_defaults');
    ct = clock;
    ct = sprintf('%d.%d.%d, %d:%d:%2.0f', ct(3), ct(2), ct(1), ct(4), ct(5), ct(6));
    txt = sprintf('%s version %2.2f\r\n%s\r\n%s.\r\n\r\nGREETINGS PROFESSOR FALKEN.\r\nSHALL WE PLAY A GAME?\r\n', ui_defaults.is_name, ui_defaults.is_version, ui_defaults.is_footer, ct);
    
    log_file = fopen(ui_defaults.log_file, 'w');
    fprintf(log_file, txt);
    fclose(log_file);

end


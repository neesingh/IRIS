function controls_onoff_toggle( cf )
    pause(0.1);
    handles = findall(cf,  'Style', 'pushbutton', '-or',...
                           'Style', 'checkbox', '-or',...
                           'Style', 'radiobutton', '-or',...
                           'Style', 'edit', '-or',...
                           'Style', 'slider', '-or',...
                           'Style', 'popup');

    for i = 1:length(handles)
       if(~strcmp(get(handles(i), 'Tag'), 'readonly'))
           action = 'on';
           enable = get(handles(i), 'Enable');
           if(strcmp(enable, 'on')), action = 'off'; end
           set(handles(i), 'Enable', action);
       end
    end 
    pause(0.1);
end
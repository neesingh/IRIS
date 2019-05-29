function [ out ] = t( txt, cf )
% t - translate a string
% cf needs to point to the main figure. For the calls from the launcher, no
% need to specify it. For the calls from the analysis windows, gcbf should
% work. For deeper calls you need to improvise.

out = txt;
if(false)
    error = 0;
    if nargin < 2
        if isempty(gcbf), cf = gcf; else cf = gcbf; end
    end

    try 
        ui_languages = getappdata(cf, 'ui_languages');
    catch
        error = 1;
    end

    out = txt;
    
    if(~error)
        original = {ui_languages.strings_original};
        translation = {ui_languages.strings_translation};

        idx = strcmp(original, txt);
        [val, idx] = max(idx);

        if(val == 0)
            out = txt;
            show_msg(cf, ['Missing translation for: ', txt], 'warning');
        else
            out = translation{idx};
        end
    end
end
end

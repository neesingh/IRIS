function [ path ] = find_root_path()
%FIND_ROOT_PATH

    if(isdeployed)
        
        file_to_verify = 'IRIS readme.txt';

        [~, result] = system('path');
        PATHroot = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
        MFILEroot = mfilename('fullpath');
        MFILEroot = MFILEroot(1:end-5); % scrap "\IRIS"
        LASTroot = 'C:\Program Files\IRIS';
        
        paths = {PATHroot, MFILEroot, LASTroot};
        
        for p = 1:length(paths)
            
            path = paths{p};
            if(fopen(fullfile(path, file_to_verify)) ~= 0)
                break;
            end
            
        end

    else
        path = pwd;
    end


end


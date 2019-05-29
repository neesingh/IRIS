function empty_directory( dirpath )
    
    if(7==exist(dirpath, 'dir'))
        rmdir(dirpath, 's');
        mkdir(dirpath);
    end

end


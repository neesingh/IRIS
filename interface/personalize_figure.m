function personalize_figure(fid, figuresize)
% Set all program's icons to a custom one. This is against Matlab's license - proceed with caution

    set(fid, 'NumberTitle', 'off');
    F = filesep;
    jframe = get(fid, 'javaframe'); jIcon = javax.swing.ImageIcon([pwd,F,'includes',F,'icons',F,'icon.png']); jframe.setFigureIcon(jIcon);
    set(fid, 'OuterPosition', figuresize);
    set(fid, 'SizeChangedFcn', { @resize_figure, fid, figuresize });
        
end
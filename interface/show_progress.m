function show_progress( progress_bar, percentage )
% show_progress - this cool function moves the progress bar on top of the
% application's window

    per = percentage/100;
    
    set(progress_bar, 'Position', [0.025 0.995 0.025 + per*0.925 0.05]);
    set(progress_bar, 'BackgroundColor', [(1-per)*1.0 per*1.0 0.75]);
    set(progress_bar, 'String', sprintf('%2.1f%%', percentage));
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                pause(0.1);

end


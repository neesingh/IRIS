function plot_spd( hObject, args, target_axes, no_psfs )
% PLOT_SPD Plots the RGB profiles of the user-selected SPD.

    if(isempty(hObject))
        idx = args;
    else
        idx = get(hObject, 'Value');
    end
    
    no_psfs = str2double(get(no_psfs, 'String'));
    spd = SPD(idx);
    
    lambdas = spd(end,1) - spd(1,1);
    lambdas = lambdas/(no_psfs+1);
    lambdas = spd(1,1):lambdas:spd(end,1);

    axes(target_axes);
    plot(spd(:,1), spd(:,2), 'r', spd(:,1), spd(:,3), 'g', spd(:,1), spd(:,4), 'b'); hold on;
    ys = ylim; ys = ys(2) .* ones(1,length(lambdas));
    stem(lambdas, ys, ':r', 'MarkerSize', 0.1); hold off;
    xlim([min(spd(:,1))-10 max(spd(:,1))]+10);
    ylabel('SPD');
    
end


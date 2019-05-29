% script used to calculate and plot DOF estimates in the IQ metrics window
  
    y_max = max(y_values(:));
    y_dof = 0.01*str2double(get(ui_dof_percentage, 'String'))*y_max;                  

    % plot dof dotted line
    plot(xlim, [y_dof y_dof],   ':',...
                                'LineWidth', 1.5,...
                                'Color', iqm_color);
    plot_legend{end+1} = sprintf('DOF line');

    % find intersections of the dof line with the spline fit
    intersections = abs(fit_y - y_dof) <= y_max/spline_density/3;
    intersections = find(intersections);

    slopes = []; go = 0;

    % verify that we have at least two intersections
    if(length(intersections)>2)
        intersections = [intersections(1) intersections(end)];

        % verify that they're not really just one point
        if(intersections(2) - intersections(1) > spline_density/2)

            for i = 1:2
                % calculate the sign of the slope
                point = intersections(i);
                p_before = point - round(spline_density/10);
                p_after = point + round(spline_density/10);

                % make sure we'll not fall off the plot data range
                p_before = max(1, p_before);
                p_after = min(length(fit_x), p_after);

                slopes(i) = sign((fit_y(p_after) - fit_y(p_before))/(p_after - p_before));
            end

            if(slopes(1)~=slopes(2))
                go = 1;
            end
        end

    end

    if(go)
        intersections = fit_x(intersections);
        dof = intersections(2) - intersections(1);
        text(x_values(1), y_dof, sprintf('DOF %1.3f', dof), 'Color', iqm_color, 'BackgroundColor', [1 1 1]);

        % plot dof intersections
        plot(intersections, [y_dof y_dof],  '-ok',... %'Color', iqm_color,...
                                            'LineWidth', 1.5,...
                                            'MarkerEdgeColor', iqm_color,...
                                            'MarkerFaceColor', [1 1 1]);
    else
        text(x_values(1), y_dof, 'DOF Unknown', 'Color', iqm_color, 'BackgroundColor', [1 1 1]);
    end
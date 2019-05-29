function [spd, list] = SPD(device)
% Spectral Power Distribution Curves for R, G and B pixels of a display.

    if(nargin < 1), device = 1; end
    list = {'Uniform', 'Triangular', 'LCD', 'CRT'};

    switch(device)
        case 1
            spd = (400:75:700)';
            spd(:,2) = 1;
            spd(:,3) = 1;
            spd(:,4) = 1;
        case 2
            spd = (400:75:700)';
            spd(:,2) = [0; 0; 0; 0.5; 1];
            spd(:,3) = [0; 0; 1.0; 0; 0];
            spd(:,4) = [1; 0.5; 0; 0; 0];
        case 3
            SPD_LCD;

        case 4
            SPD_CRT;
    end

end
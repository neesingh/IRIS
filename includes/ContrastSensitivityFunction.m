function [CSF] = ContrastSensitivityFunction(x, y)
    % x, y are meshgrids in units of [cyc/deg] - unit meshgrids
    % multiplied by maximum bandwidth for a given pupil.

    r = sqrt(x.^2 + y.^2);

    P = [2.8876e-08	-5.2957e-06	3.5818e-04	-1.1241e-02	1.2704e-01	1.8636e+00];
    NLfit = polyval(P, r);
    NLfit(r > 64) = 0;
    CSF = 10.^NLfit;

    CSF = CSF - min(CSF(:)); % remove floor
    CSF = CSF/max(CSF(:)); % normalize to 1
end


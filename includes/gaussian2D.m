% GAUSSIAN2D    Generate a custom 2D gaussian 
%
               
function mat = gaussian2D(mat, sigma, center)
    gsize = size(mat);
    for r=1:gsize(1)
        for c=1:gsize(2)
            mat(r,c) = gaussC(r,c, sigma, center);
        end
    end

    function val = gaussC(x, y, sigma, center)
    xc = center(1);
    yc = center(2);
    exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma^2);
    amplitude = 1 / (sigma * sqrt(2*pi));  
    % The above is very much different than Alan's "1./2*pi*sigma^2"
    % which is the same as pi*Sigma^2 / 2.
    val       = amplitude  * exp(-exponent);
    end

end
function is_line( x, y, color )
%IS_LINE as in Imaging Simulator Line. Wrapper for Matlab's LINE, only
%drawing it with a shadow for legibility both on black and white
%backgrounds
    
    line(x+1, y+1, 'color', [0 0 0]);
    line(x, y, 'color', color);


end


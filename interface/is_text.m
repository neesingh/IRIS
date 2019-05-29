function is_text( x, y, txt, color )
%IS_TEXT as in Imaging Simulator Text. Wrapper for Matlab's TEXT, only
%drawing it with a shadow for legibility both on black and white
%backgrounds
    
    text(x+1, y+2, txt, 'color', [0 0 0]);
    text(x, y, txt, 'color', color);


end


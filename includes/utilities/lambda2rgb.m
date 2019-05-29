function [RGB] = lambda2rgb(lambda, formulary)
%   Wrapper for colorMatchFcn, declaration is self explanatory :)
%
%    Reference: http://cvrl.ioo.ucl.ac.uk/cmfs.htm 
%
%    See also illuminant.
%

    if(nargin<2)
        formulary = 'stiles_2';
    end
    
    [l, r, g, b] = colorMatchFcn(formulary); 
    [~, idx] = min(abs(l-lambda)); 
    RGB = abs([r(idx) g(idx) b(idx)]);
    RGB = RGB/max(RGB);
end
function [ M ] = pad2size(M, tsize, value)
% ts - target size
    if(nargin < 3), value = 0; end;
    if(isscalar(tsize)), tsize = tsize * ones(1,length(size(M))); end

    if(size(M) < tsize)
        offset = floor((tsize - size(M))/2);
        newM = value*ones(tsize);

        newM(1+offset(1):offset(1)+size(M,1), 1+offset(2):offset(2)+size(M,2)) = M;
    else
        newM = M;
    end
    
    M = newM;

end
function [ txt ] = mode2index_txt( mode )
    [m, n] = mode2index(mode);
    txt = sprintf('C(%d,%d)', m, n);
end
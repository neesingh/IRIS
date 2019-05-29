function [ M_crop ] = crop_to_roi( M, roi )
%CROP_TO_ROI 

    M_crop = M(roi(2,1):roi(2,2), roi(1,1):roi(1,2));


end


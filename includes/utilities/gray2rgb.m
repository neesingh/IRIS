function [ img ] = gray2rgb( img )
    %Gives a grayscale image an extra dimension
    %in order to use color within it
    [m n]=size(img);
    rgb=zeros(m,n,3);
    rgb(:,:,1)=img;
    rgb(:,:,2)=rgb(:,:,1);
    rgb(:,:,3)=rgb(:,:,1);
    img=rgb/255;
end

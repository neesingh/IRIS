function show_Zc2psf2otf(W,pupilMask,PSF,OTF,x,y,spaceHalfwidth,bandwidth,...
    Irange)
% show some graphics: wavefront, PSF, OTF, eyechart
%   
% see QualityMetrics for example of calling Zc2psf2otf and this program.
% LNT 29Mar06
% 14Jul09. Change the input args to be compatible with changes in
%   QualityMetrics. This allows the PSF to be labeled with a size bar.
%   Add Irange to control dynamic range of blurred images.
if nargin<9, Irange = []; end

fx = x*bandwidth; fy = y*bandwidth;
PSFpixsize = 2*spaceHalfwidth/size(PSF, 1);
PSFrange=65:192; % define a smaller region of interest
PSFwidth = PSFpixsize*length(PSFrange);
disp(['PSF width (arcmin) = ',num2str(PSFwidth)]);  % tell user the size of PSF in arcmin

% prepare a retinal image simulation for eye chart
% object = letter chart stretched so 20/20 letters = 5' = 1/12 deg tall
load SmallEyeChart; % DHEVP = 20/20 line
fundamentalFreq = fy(2)-fy(1);
objWidth = 1/fundamentalFreq; % width of desired object in degrees
chartWidth = 0.82; % calibrated width (deg)=(5'/13pix)*128pix = 49.23'
scalefactor = objWidth/chartWidth; % required scaling of object to make
                                   %   it commensurate with OTF
object = ShrinkImage(chart,size(OTF),scalefactor,254);
objSpectrum = fft2(double(object));
blurredImage = ifft2(ifftshift(OTF).*objSpectrum);
% % in case the image has more light than the object by fudgeFactor
% fudgeFactor = sum(blurredImage(:))/sum(object(:));
% blurredImageScaled = blurredImage/fudgeFactor; % energy conservation: 
%                         % blurring should not affect total light energy 
%Irange = [min(object(:)) max(object(:))];

% clearImage = ifft2(ifftshift(DL_OTF).*objSpectrum);
% deltaImage = clearImage-blurredImage;
% fidelity = 1 - std(deltaImage(:))/std(clearImage(:));
% figure; 
% subplot(1,3,1); imagesc(clearImage); axis image, axis off, colormap 'gray'
% title(['clear: std=',num2str(std(clearImage(:)))])
% subplot(1,3,2); imagesc(blurredImage); axis image, axis off, colormap 'gray'
% title(['blurred: std=',num2str(std(blurredImage(:)))])
% subplot(1,3,3); imagesc(deltaImage); axis image, %axis off, colormap 'gray'
% title(['delta: std=',num2str(std(deltaImage(:)))])
% xlabel(['Image fidelity=',num2str(fidelity)])

figure
cal=1;

Wshow=W.*pupilMask; Wshow(find(pupilMask==0))=NaN; 
Wshow(1)=-cal; Wshow(2)=cal; %two calibration pixels force the scale factor 
subplot(2,2,1);	imagesc(Wshow,[-cal cal]); axis image; axis xy;  
axis off, colormap 'jet',colorbar, title('WAF','FontSize',24)
subplot(2,2,2);	imagesc(PSF(PSFrange,PSFrange)); axis image; axis xy; 
axis off, colormap 'gray', colorbar, title('PSF','FontSize',24)
% display a size bar 5 arcmin long
barlength = 5;
unitsize = barlength/PSFpixsize;	% length of a bar 5 arcmin long in pix
line([10 unitsize+10],[10 10],'color',[1 1 0]);
unitstring=[num2str(barlength),' arcmin'];	 
text(10,20,unitstring,'color',[1 1 0]);

subplot(2,2,3);	
%surfc(Wshow);colormap 'jet',colorbar,title('WAF'),set(gca,'ZLim',[-2 2])
if isempty(Irange)
    imagesc(blurredImage); axis image, colormap 'gray', axis off
else
    imagesc(blurredImage,Irange); axis image, colormap 'gray', axis off
end
title('Image','FontSize',24)
[radius,meanW,RI,WI] = RadialAverage(real(OTF),fx, fy);
subplot(2,2,4); plot(RI,WI), axis([0 60 -0.2 1]), title('rOTF','FontSize',24)
xlabel('Spatial Frequency (c/d)','FontSize',18) 
ylabel('Contrast transfer','FontSize',18)	

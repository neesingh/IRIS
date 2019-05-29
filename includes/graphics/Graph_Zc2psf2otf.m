%script Graph_Zc2psf2otf
% call this script in any function that has called Zc2psf2otf
% see QualityMetrics for example of calling Zc2psf2otf and this program.
% outpt is identical to show_Zc2psf2otf(W, pupilMask, PSF, OTF, fx, fy)
% the difference is the flexibility gained by having input args
% LNT 29Mar06

% prepare a retinal image simulation for eye chart
% object = letter chart stretched so 20/20 letters = 5' = 1/12 deg tall
load SmallEyeChart; % DHEVP = 20/20 line
objWidth = 1/fundamentalFreq; % width of desired object in degrees
chartWidth = 0.82; % calibrated width (deg)=(5'/13pix)*128pix = 49.23'
scalefactor = objWidth/chartWidth; % required scaling of object to make
                                   %   it commensurate with OTF
object = ShrinkImage(chart,size(OTF),scalefactor,254);
objSpectrum = fft2(object);
blurredImage = ifft2(ifftshift(OTF).*objSpectrum);
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
cal=2;
Wshow=W.*pupilMask; Wshow(find(pupilMask==0))=NaN; Wshow(1)=-cal;
Wshow(2)=cal; % two calibration pixels to force the scale factor 
subplot(2,2,1);	imagesc(Wshow,[-cal cal]); axis image; axis xy;  
axis off, colormap 'jet',colorbar, title('WAF','FontSize',24)
subplot(2,2,2);	imagesc(PSF(65:192,65:192)); axis image; axis xy; 
axis off, colormap 'gray', colorbar, title('PSF','FontSize',24)
subplot(2,2,3);	
%surfc(Wshow);colormap 'jet',colorbar,title('WAF'),set(gca,'ZLim',[-2 2])
imagesc(blurredImage); axis image, colormap 'gray', axis off
title('Image','FontSize',24)
[radius,meanW,RI,WI] = RadialAverage(real(OTF),x*bandwidth, y*bandwidth);
subplot(2,2,4); plot(RI,WI), axis([0 60 -0.2 1]), title('rOTF','FontSize',24)
xlabel('Spatial Frequency (c/d)','FontSize',18) 
ylabel('Contrast transfer','FontSize',18)	

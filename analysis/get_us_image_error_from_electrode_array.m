%--------------------------------------------------------------------------
% Quantify the image error from adding the electrode array to the probe
%--------------------------------------------------------------------------
clear all
close all
%--------------------------------------------------------------------------
% Read the images
img0 = imread('us_no_array.jpg');
img1 = imread('us_with_array.jpg');
%--------------------------------------------------------------------------
% Convert to grayscale if they are RGB images
if size(img0, 3) == 3
    img0 = rgb2gray(img0);
end
if size(img1, 3) == 3
    img1 = rgb2gray(img1);
end
%--------------------------------------------------------------------------
% Calculate the mean brightness of each image
meanBrightness0 = mean(img0(:));
meanBrightness1 = mean(img1(:));
%--------------------------------------------------------------------------
% Scale the images to have the same mean brightness
scaleFactor = meanBrightness0 / meanBrightness1;
img1_scaled = img1 * scaleFactor;
%--------------------------------------------------------------------------
% Ensure pixel values remain in the valid range
img1_scaled = min(img1_scaled, 255);
%--------------------------------------------------------------------------
% Subtract the images to find the error
errorImage = imabsdiff(img0, uint8(img1_scaled));
%--------------------------------------------------------------------------
pixsum0 = sum(img0,'all');
pixsum1 = sum(img1,'all');
pixsum1sc = sum(img1_scaled,'all');
pixsumerr = sum(errorImage,'all');
%--------------------------------------------------------------------------
%%
% Display the error image
figure;
t = tiledlayout('horizontal','TileSpacing','tight','Padding','tight');
nexttile
imshow(img0); title('1. Probe only (no electrode array)'); xlabel(num2str(pixsum0/pixsum0))
nexttile
imshow(img1); title('2. Probe with electrode array (unscaled)'); xlabel(num2str(pixsum1/pixsum0))
nexttile
imshow(img1_scaled); title('3. Probe with electrode array (scaled)'); xlabel(num2str(pixsum1sc/pixsum0))
nexttile
imshow(errorImage); title('4. Error = abs(Image1 - Image3)'); xlabel(num2str(pixsumerr/pixsum0))
title(t,'Quantify image quality degradation from added electrodes')
xlabel(t,'Scaled image pixel value sums = sum(ImageN)/sum(Image1)')
%--------------------------------------------------------------------------
%%
probeArea = 1:100; % image domain nearest the probe
newError = sum(errorImage(probeArea,:),'all')/sum(img0(probeArea,:),'all')
figure; imshow(errorImage(1:100,:))
title('Error image zoomed in to image area nearest the probe')
xlabel(newError)


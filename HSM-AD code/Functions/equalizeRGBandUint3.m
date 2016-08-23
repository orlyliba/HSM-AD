function imgRGB = equalizeRGBandUint3(imgRGB,saturated,black)
% equalizeRGBandUint.m 
% Scales RGB image, in a similar way to Envi SW
% All channels are scaled SEPARATELY by the maximum of each channel
% INPUT:
% imgRGB - RGB image, before scaling
% saturated - ratio of pixels that can be saturated
% black - ratio of pixels that are truncated, and will be black in image

% Written by Orly Liba, Stanford Universtiy, 2016

imgRGB(:,:,1) = removeDark(imgRGB(:,:,1),black);
imgRGB(:,:,2) = removeDark(imgRGB(:,:,2),black);
imgRGB(:,:,3) = removeDark(imgRGB(:,:,3),black);

imgRGB(:,:,1) = scaleI(imgRGB(:,:,1),saturated);
imgRGB(:,:,2) = scaleI(imgRGB(:,:,2),saturated);
imgRGB(:,:,3) = scaleI(imgRGB(:,:,3),saturated);

imgRGB = imgRGB*255;
imgRGB = uint8(imgRGB);

function I = removeDark(I,black)
I = I - min(min(I));
sortedI = sort(I(:),'ascend');
blackVal = sortedI(max(1,round(black*length(sortedI))));
I = I - blackVal;
I(I<0) = 0;

function I = scaleI(I,saturated)
sortedI = sort(I(:),'ascend');
satVal = sortedI(min(length(sortedI),round((1-saturated)*length(sortedI))));
I(I>=satVal) = satVal;
I = I/satVal;

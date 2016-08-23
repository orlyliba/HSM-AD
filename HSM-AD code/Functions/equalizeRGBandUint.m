function imgRGB = equalizeRGBandUint(imgRGB,saturated,black)
% equalizeRGBandUint.m 
% Scales RGB image, in a similar way to Envi SW
% All channels are scaled TOGETHER by the maximum of 1 channel (global max)
% INPUT:
% imgRGB - RGB image, before scaling
% saturated - ratio of pixels that can be saturated
% black - ratio of pixels that are truncated, and will be black in image

% Written by Orly Liba, Stanford Universtiy, 2016

imgRGB(:,:,1) = removeDark(imgRGB(:,:,1),black);
imgRGB(:,:,2) = removeDark(imgRGB(:,:,2),black);
imgRGB(:,:,3) = removeDark(imgRGB(:,:,3),black);
V = sum(imgRGB,3);
sortedV = sort(V(:),'ascend');
satVal = sortedV(min(length(sortedV),round((1-saturated)*length(sortedV))));
imgRGB(imgRGB >= satVal/3) = satVal/3;
imgRGB = imgRGB./max(imgRGB(:))*255;

imgRGB = uint8(imgRGB);

function I = removeDark(I,black)
I = I - min(min(I));
sortedI = sort(I(:),'ascend');
blackVal = sortedI(max(1,round(black*length(sortedI))));
I = I - blackVal;
I(I<0) = 0;

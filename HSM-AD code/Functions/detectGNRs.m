function [pixAboveNoise, pixAboveGnrThr, pixGnr] = ...
    detectGNRs(datapath,scaleSeparate, dVignetting, cutoff, normEnable, noiseThr, gnrThr, adaptiveThr, smoothParams, adjustable_bands,C, indCluster, overlayColor)
% detectGNRs.m 
% Detects nanoparticles in a hyperspectral image
% based on Euclidean nearest neighbors
% provides statistical information for biodistribution calculation
% INPUT:
% datapath - of hyperspectral image
% scaleSeparate - scaling of channels for display, 0 to scale together, 1 to scale separately
% dVignetting - d for cos^4 vignetting correction
% cutoff - spectrum truncation of lower wavelengths
% normEnable - normalize spectrum by max, during pre-processing
% noiseThr - threshold for tissue, overriden if adaptive threshold is enabled
% gnrThr - threshold for potentail nanoparticle, overriden if adaptive threshold is enabled
% adaptiveThr - enable calculation of adaptive thresholding
% smoothParams - smoothing the spectrum, during pre processing
% adjustable_bands - band centers for display of the hyperspectral image
% C - clusters, for classification
% indCluster - index of the nanoparticle cluster
% overlayColor - color for displaying detected nanoparticles on top of intensity image
% 
% OUPUT:
% pixAboveNoise - number of pixels that are not background (includes tissue and nanoarticles)
% pixAboveGnrThr - number of pixels that are potential nanoparticles
% pixGnr - number of pixels detected as nanoparticles

% Written by Orly Liba, Stanford Universtiy, 2016

% Read raw data
[D,info]=enviread([datapath],[datapath '.hdr']);
wl = sscanf(info.wavelength(2:end-1),'%f,');

% Vignetting correction, used for display and for adaptive thresholding
DfixVignett = vignettCorrection(D,info, dVignetting);

% Calc adaptive Thresholds, if enabled
if adaptiveThr
    [noiseThr, gnrThr] = adaptiveImgThr(mean(DfixVignett(:,:,cutoff:end),3));
end

% Create mean intensity image, for display
meanI = repmat(mean(DfixVignett,3),[1 1 3]);
if scaleSeparate
    meanIScaled = equalizeRGBandUint3(meanI,0.01,0.02);
else % scale all channels together
    meanIScaled = equalizeRGBandUint(meanI,0.01,0.02);
end

% Create hyperspectral color mage, for display
imgRGB = equalizeRGBandUint3(convert2RGB(DfixVignett,adjustable_bands,[80 80 80]),0.01,0.02);
figure; imshow(imgRGB);
% imwrite(uint8(imgRGB),[datapath '_hsi.png'])

% Pre processing
[Dp, location, aboveGnrThr] = prepData(D, info, cutoff, normEnable, gnrThr, noiseThr, smoothParams);
pixAboveNoise = length(aboveGnrThr);
pixAboveGnrThr = sum(aboveGnrThr);
locationAboveGnrThr = location(aboveGnrThr==1,:);

% Classification of each pixel above the threshold
% and show segmentation map
clusterNum = size(C,1);
label = zeros(length(Dp),1);
segmentationMap = zeros(size(D,1),size(D,2));
for ind = 1:length(location)
    if aboveGnrThr(ind)
        % find nearest cluster center
        [~, I] = min(diag((repmat(Dp(ind,:),[clusterNum,1]) - C)*(repmat(Dp(ind,:),[clusterNum,1]) - C)'));
        label(ind) = I;
        if I == indCluster
            segmentationMap(location(ind,1),location(ind,2)) = 3; % nanoparticle
        else
            segmentationMap(location(ind,1),location(ind,2)) = 2; % tissue (high intensity)
        end
    else
        segmentationMap(location(ind,1),location(ind,2)) = 1; % tissue (lower intensity)
    end
    % 0 - background, the cover glass
end
figure; imagesc(segmentationMap); axis image; title('Threshold and detection map'); colormap jet;  caxis([0 3]);
% saveas(gca,[datapath '_map.png'])

pixGnr = sum(label==indCluster); % number of detected pixels
imgOverlay = double(meanIScaled).*repmat((segmentationMap~=3),[1 1 3]) + repmat(permute(255*overlayColor,[3,1,2]),[size(meanIScaled,1) size(meanIScaled,2) 1]).*repmat(segmentationMap==3,[1 1 3]);
figure; imshow(uint8(imgOverlay));
title(['Pixels with label=' num2str(indCluster) ', mask'])
% imwrite(uint8(imgOverlay),[datapath '_detection_noiseThr=' num2str(noiseThr) '_gnrThr=' num2str(gnrThr) '.png'])


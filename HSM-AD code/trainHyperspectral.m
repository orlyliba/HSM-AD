% trainHyperspectral.m
% Processes a hyperspectral image or several images and calculate the
% cluster centers with k-means. Save cluster centers for fututre use.

% Written by Orly Liba, Stanford Universtiy, 2016

ImgPath = '';
ImgFile = {''};  % Can add multiple images

%% Parameters
dVignetting = 0.2e-3; % d for vignetting correction

%% Pre-processing parameters
normEnable = 1; % don't change
cutoff = 100; % spectral truncation
noiseThr = 100; % noise threshold, change if needed. Overriden by adaptive thresholding
gnrThr = 350; % threshold for detecting GNRs. Overriden by adaptive thresholding
adaptiveThr = 1; % find Thr according to histogram
% Savitzky Golay smoothing parameters
smoothParams.enable = 1; % don't change
smoothParams.deg = 2; % don't change
smoothParams.width = 33; % don't change

%%
addpath('Functions\');
addpath('Envi\');

%%
D_ = [];
for imgInd = 1:length(ImgFile)
    % Read raw data
    datapath = [ImgPath ImgFile{imgInd}];
    [D,info]=enviread([datapath],[datapath '.hdr']);     
    % Vignetting correction, used for display and for adaptive thresholding
    DfixVignett = vignettCorrection(D,info, dVignetting);    
    % Calc adaptive Thresholds, if enabled
    if adaptiveThr
        [noiseThr, gnrThr] = adaptiveImgThr(mean(DfixVignett(:,:,cutoff:end),3));
    end        
    % Pre processing
    [Dp, location, aboveGnrThr] = prepData(D, info, cutoff, normEnable, gnrThr, noiseThr, smoothParams);        
    D_ = [D_; Dp];
end
[IDX, C] = kmeans(D_, 4);
figure; plot(C'); title('Cluster centers')
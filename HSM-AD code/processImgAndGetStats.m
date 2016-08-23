% processImgAndGetStats.m 
% Processes a hyperspectral image and displays the location of detected
% nanoparticles. Also provides the number of pixels detected as tissue,
% background and nanoparticles.

% Written by Orly Liba, Stanford Universtiy, 2016

ImgPath = '\';
ImgFile = {''}; % Can add multiple images
clusterPath = '5 clusters based on training on 4 images plus CA removal GNR is 2.mat';
clusterGNR = 2;

%% Parameters
colorGNR = [1 0.5 0.2]; % color of overlay for detected pixels [1 0.5 0.2] is orange
adjustable_bands = [251 193 85]; % visualization, RGB bands, shows GNRs as reddish.
scaleSeparate = 0; % Determines how scaling is done on all channels
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

% Show clusers
load 'wave lengths';
load(clusterPath)
figure; plot(wl,C')
legend('1','2','3','4','5')

% Process and display
pixRatio_ = []; % ratio of nanoparticles in tissue
for imgInd = 1:length(ImgFile)
    disp(ImgFile{imgInd})
    [pixAboveNoise, pixAboveGnrThr, pixGnr] = ...
        detectGNRs([ImgPath ImgFile{imgInd}],scaleSeparate, dVignetting, cutoff, normEnable, noiseThr, gnrThr, adaptiveThr, smoothParams, adjustable_bands,C,clusterGNR,colorGNR);
    str = sprintf('File #%d: Total above noise threshold = %d, above gnr threshold = %d, detected as GNRs = %d, positives ratio = %f%',...
        imgInd,pixAboveNoise,pixAboveGnrThr,pixGnr,pixGnr/pixAboveNoise*100);
    disp(str)    
    disp(' ')
    pixRatio_ = [pixRatio_ pixGnr/pixAboveNoise*100];
end

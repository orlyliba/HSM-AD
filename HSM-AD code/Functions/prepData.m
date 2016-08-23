function [D, location, aboveGnrThr] = prepData(D,info,cutoff,normEnable,gnrThr,noiseThr,smoothParams)
% prepData.m 
% Prepares hyperspectral raw data for classification.
% INPUT:
% D - hyperspectral image
% info - info regarding the hyperspectral file, is outputted by enviread 
% cutoff - truncation of the spectrum, remove initial pixels if noisy or
% irrelevant
% normEnable - indicates if the spectra should be normalized so that
% maximum is 1
% gnrThr - high intensity threshold, for potential nanoparticles
% noiseThr - low threshold, segment tissue from slide background
% smoothParams - parameters for Svaitzky-Golay spectrum smoothing
% OUTPUT:
% D - spectral of pixels that are not background, after pre-processing
% location - location of the pixels in D, [row, col]
% aboveGNRThr - flag indicating if the pixel is a potential nanoparticle

% Written by Orly Liba, Stanford Universtiy, 2016

% vignetting correction
maxRow = size(D,1);
maxCol = size(D,2);
D = D(:,:,cutoff:end);
m = 1:size(D,1);
n = 1:size(D,2);
[N, M] = meshgrid(n,m); % [X,Y]
px = info.pixel_size.x;
py = info.pixel_size.y;
R = sqrt((px*(N-size(D,2)/2)).^2+(py*(M-size(D,1)/2)).^2);
d = 0.2e-3; % m, working distance of the lens
theta = atan(R/d);
D = D./repmat(cos(theta).^4,[1 1 size(D,3)]);

% removing pixels that are background
% "marking" pixels that are potential nanoparticles
M = M(:);
N = N(:);
D = reshape(D,[],size(D,3));
D_intensity = mean(D,2);
D(D_intensity<noiseThr,:) = [];
M(D_intensity<noiseThr,:) = [];
N(D_intensity<noiseThr,:) = [];
D_intensity(D_intensity<noiseThr) = [];
aboveGnrThr = ones(size(D_intensity));
aboveGnrThr(D_intensity<gnrThr) = 0;

% smoothing the spectrum, check Matlab help for more info
if smoothParams.enable
    D = sgolayfilt(D,smoothParams.deg,smoothParams.width,[],2);
end

% normalize each spectrum by max
if normEnable
    norm_map = max(D,[],2);
    D = D./repmat(norm_map,[1,size(D,2)]);
end

% Location in the original image
location = [M N]; % [row col]

function [noiseThr, gnrThr] = adaptiveImgThr(I)
% adaptiveImgThr.m
% Image adaptive thresholding according to mean spectrum 
% Thresholding into 3 segments:
% 1. background (under noiseThr)
% 2. tissue (above noiseThr and under gnrThr)
% 3. potential nanoparticle (above gnrThr)
% INPUT:
% I - image intensity (mean of the spectrum for each pixel)
% OUTPUT:
% The 2 thresholds

% Written by Orly Liba, Stanford Universtiy, 2016

% parameters for the adaptive thresholding algorithm
minPeakThr = 100;
minNoiseThr = 10;
noiseThrMargin = 0.5;
gnrThrMargin = 0.2;

a = I(:);
[N,X] = hist(a,sqrt(length(a)));
X_ = 1:5:max(X);
N_ = interp1(X,N,X_,'pchip');
X_(1:2) = [];
N_(1:2) = [];

X__ = X_(X_ > minPeakThr);
N__ = N_(X_ > minPeakThr);
[Y,I] = max(N__);
peakHist = X__(I);

X__ = X_(X_ < peakHist);
N__ = N_(X_ < peakHist);
[Y,I] = min(N__);
minHist = X__(I);
minHist = max(minHist,minNoiseThr);

noiseThr = minHist*(1+noiseThrMargin);
gnrThr = peakHist*(1+gnrThrMargin);
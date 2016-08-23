function I = vignettCorrection(I,info,d)
% vignettCorrection.m 
% Corrects cos^4 vignetting
% I - hyperspectral image
% info - info for the hyperspectral image, provided by enviread.m
% d - lens diamter (aperture)

% Written by Orly Liba, Stanford Universtiy, 2016

m = 1:size(I,1);
n = 1:size(I,2);
[N, M] = meshgrid(n,m); % [X,Y]
px = info.pixel_size.x;
py = info.pixel_size.y;
R = sqrt((px*(N-size(I,2)/2)).^2+(py*(M-size(I,1)/2)).^2);
theta = atan(R/d);
I = I./repmat(cos(theta).^4,[1 1 size(I,3)]);
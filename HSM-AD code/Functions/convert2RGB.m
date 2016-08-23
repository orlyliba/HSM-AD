function RGBImg = convert2RGB(imgHyperSpect,centerRGB,GaussSize)
% convert2RGB.m 
% Converts hyperspectral image to RGB
% imgHyperSpect - hyperspectral image
% centerRGB - centers of RGB bands, in pixel index
% GaussSize - width of RGB bands

% Written by Orly Liba, Stanford Universtiy, 2016

GaussSize = round(GaussSize/2)*2;
[m n s] = size(imgHyperSpect);

RFilt = createFilt(GaussSize(1),s,centerRGB(1));
GFilt = createFilt(GaussSize(2),s,centerRGB(2));
BFilt = createFilt(GaussSize(3),s,centerRGB(3));

RFilt = permute(RFilt,[2 3 1]);
GFilt = permute(GFilt,[2 3 1]);
BFilt = permute(BFilt,[2 3 1]);

R = sum(imgHyperSpect.*repmat(RFilt,[m n 1]),3);
G = sum(imgHyperSpect.*repmat(GFilt,[m n 1]),3);
B = sum(imgHyperSpect.*repmat(BFilt,[m n 1]),3);

RGBImg = cat(3,R,G,B);
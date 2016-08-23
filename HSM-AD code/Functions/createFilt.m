function winFilt = createFilt(GaussSize,s,c)
% createFilt.m 
% Creates a gaussian window
% GaussSize - Gaussian width
% c - center
% s - total size of winFilt (the output), which is 0 anywhere but the
% gaussian

% Written by Orly Liba, Stanford Universtiy, 2016

GaussSize = round(GaussSize/2)*2;

gWin = gausswin(GaussSize);
gWin = gWin(max(1,GaussSize/2-c +1) : min(end,GaussSize/2 + s - c));
winFilt = zeros(s,1);
winFilt(max(1,c - GaussSize/2 + 1) : min(s,c + GaussSize/2)) = gWin;



% pixelSpectrum.m 
% Displays the image of a hyperspectral envi file and allows the user to select pixels 
% it then dispalys the spectrum of the selected pixel.
% Press any key to continue choosing pixels.
% Press "cntrl+c" to stop pixel selection, or change the while loop below.

% Written by Orly Liba, Stanford Universtiy, 2016

% Path to the envi file
ImgPath = '\';
ImgFile = ''; % no need for file extension

% Display parameters
centersRGB = [251 193 85]; % band centers for RGB (pixel index)
widthRGB = [80 80 80]; % band width (in index units)
%%
addpath('..\Functions\');
addpath('..\Envi\');

[D,info]=enviread([ImgPath ImgFile],[ImgPath ImgFile '.hdr']);
wl = sscanf(info.wavelength(2:end-1),'%f,');
h1 = figure(1);
imshow(equalizeRGBandUint3(convert2RGB(D,centersRGB,widthRGB),0.01,0.02)); hold on;
while 1 % Do cntrl + C to quit
    figure(1);
    [x,y] = ginput(1);
    figure(2);
    plot(wl,squeeze(D(round(y),round(x),:)));   
    pause
end
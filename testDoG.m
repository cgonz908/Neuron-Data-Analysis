clear all variables;
close all;

params(1) = 2;
params(2) = 1.2*2;
params(3) = 18;
params(4) = 17;
params(5) = 6;
params(6) = 5;

res = 32;

[xVals, yVals] = meshgrid(1:1:res);

figure(1);
Z = dog2DFunction(params, xVals, yVals);
surf(Z);
title('Created DoG');

%Fit
[fittedDoG, values] = fitDog2D(double(Z));
figure(2);
surf(fittedDoG);
title('Created DoG Fit');

figure(3);
imagesc(fittedDoG-Z); colorbar;

%Make Z an actual receptive field instead
fileList = dir('/Users/christiangonzalez/Google Drive/MATLAB/*.mat');
nFiles = length(fileList);
figNum = 4;
for iter = 1:1
    fName = fileList(iter).name;
    load('H4505.039_1_Ch28-McGill-clips.mat');
    peakLagIndex = findPeakLag(zScore.valueLag, 5);
    Z = 1000*kernel2D(:, :, peakLagIndex);

    figure(figNum);
    figNum = figNum + 1;
    surf(Z);
    title('Actual Receptive Field');

    %Fit
    [fittedDoG, values] = fitDog2D(double(Z));
    figure(figNum);
    figNum = figNum + 1;
    surf(fittedDoG);
    title('Fit to Receptive Field');
    
    figure(figNum);
    figNum = figNum + 1;
    surf(10*fittedDoG-Z);
    title('Residual');
end
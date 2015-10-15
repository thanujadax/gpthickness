% create ellipse image

saveImageFileName = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/ellipses/01.png';

sizeR = 600;
sizeC = 600;

meanIntensity = 0.65;
sdIntensity = 0.1;

meanIntensityDark = 0.2;

sigmaGauss = 1;
maskSizeGauss = 5;

imageBase = ones(sizeR,sizeC);
% apply background noise
% imageBase = meanIntensity + sdIntensity .* randn(sizeR,sizeC);

% neuron membrane-like texture
darkImageBase = zeros(sizeR,sizeC);
% add noise
% darkImageBase = meanIntensityDark + sdIntensity .* randn(sizeR,sizeC);

% figure;imshow(imageBase);

% figure;imshow(darkImageBase);

ellipseCenters = [120 120; 200 400; 350 120; 450 450];
%radius = 70;
a = 40;
b = 70;

thickness = 20;

ellipseImage = getEllipses(ellipseCenters,a,b,thickness,sizeR,sizeC);

% figure;imshow(circleImage)

% add circles with neuron membrane-like texture
imageBase(ellipseImage>0) = darkImageBase(ellipseImage>0);

imageBase = gaussianFilter(imageBase,sigmaGauss,maskSizeGauss);

figure;imshow(imageBase)

imwrite(imageBase,saveImageFileName)

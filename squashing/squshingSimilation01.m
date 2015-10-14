% similate effects of squashing on image similarity

sizeR = 600;
sizeC = 600;

meanIntensity = 0.5;
sdIntensity = 0.2;

imageBase = meanIntensity + sdIntensity .* randn(sizeR,sizeC);

figure;imshow(imageBase);
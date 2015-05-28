function [predictedThickness, thicknessSD] = predictThicknessXZ_Y...
        (inputImageStackFileName,meanVector,sdVector,inputResolution,...
        distMin,method,interleave)
    
% read image stack
% calculate pairwise c.o.c of each adjacent pair of images YZ_X
% interpolate the decay curve to predict thickness
% meanVector - unscaled
% sdVector - unscaled

inputImageStack = readTiffStackToArray(inputImageStackFileName);

[sizeR,sizeC,sizeZ] = size(inputImageStack);
distMax = numel(meanVector);
A = zeros(sizeC,sizeZ);
B = zeros(sizeC,sizeZ);

numSectionIntervals = numel(1:(interleave+1):sizeR-(1+interleave));
predictedThickness = zeros(numSectionIntervals,1);
thicknessSD = zeros(numSectionIntervals,1);
k = 0;
for i=1:(interleave+1):sizeR-(1+interleave)
    A(:,:) = inputImageStack(i,:,:);
    B(:,:) = inputImageStack((i+1+interleave),:,:);
    coc = corr2(A,B);
    k = k + 1;
    predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
    predictedThickness(k) = predThicknessUnscaled .* inputResolution;
    thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
            predThicknessUnscaled,method) .* inputResolution;
            
end
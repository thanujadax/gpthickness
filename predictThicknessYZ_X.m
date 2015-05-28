function [predictedThickness, thicknessSD] = predictThicknessYZ_X...
        (inputImageStackFileName,meanVector,sdVector,inputResolution,...
        distMin,method,interleave)
    
% read image stack
% calculate pairwise c.o.c of each adjacent pair of images YZ_X
% interpolate the decay curve to predict thickness

inputImageStack = readTiffStackToArray(inputImageStackFileName);

[sizeR,sizeC,sizeZ] = size(inputImageStack);
distMax = numel(meanVector);
A = zeros(sizeR,sizeZ);
B = zeros(sizeR,sizeZ);

numSectionIntervals = numel(1:(interleave+1):sizeC-(1+interleave));
predictedThickness = zeros(numSectionIntervals,1);
thicknessSD = zeros(numSectionIntervals,1);

for i=1:(interleave+1):sizeC-(1+interleave)
    A(:,:) = inputImageStack(:,i,:);
    B(:,:) = inputImageStack(:,(i+1+interleave),:);
    coc = corr2(A,B);
    predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
    predictedThickness(i) = predThicknessUnscaled .* inputResolution;
    thicknessSD(i) = interp1((distMin:distMax-1),sdVector,...
            predThicknessUnscaled,method) .* inputResolution;
end
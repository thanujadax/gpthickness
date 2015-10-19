function [predictedThickness, thicknessSD,syntheticStack] = predictThicknessYZ_X...
        (inputImageStackFileName,meanVector,sdVector,inputResolution,...
        distMin,method,interleave,saveSyntheticStack,distanceMeasure)
    
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

if(isempty(saveSyntheticStack))
    saveSyntheticStack = 0;
end

if(saveSyntheticStack)
    syntheticStack = zeros(sizeR,sizeZ,(numSectionIntervals+1));
end

k = 0;

if(strcmp(distanceMeasure,'COC'))
    for i=1:(interleave+1):sizeC-(1+interleave)
        A(:,:) = inputImageStack(:,i,:);
        B(:,:) = inputImageStack(:,(i+1+interleave),:);
        coc = corr2(A,B);
        k = k + 1;
        predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
        predictedThickness(k) = predThicknessUnscaled .* inputResolution;
        thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                predThicknessUnscaled,method) .* inputResolution;

        if(saveSyntheticStack)
            syntheticStack(:,:,k) = A(:,:);
        end
    end
elseif(strcmp(distanceMeasure,'SDI'))
    for i=1:(interleave+1):sizeC-(1+interleave)
        A(:,:) = inputImageStack(:,i,:);
        B(:,:) = inputImageStack(:,(i+1+interleave),:);
        coc = getPixIntensityDeviation(A,B);
        k = k + 1;
        predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
        predictedThickness(k) = predThicknessUnscaled .* inputResolution;
        thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                predThicknessUnscaled,method) .* inputResolution;

        if(saveSyntheticStack)
            syntheticStack(:,:,k) = A(:,:);
        end     
    end    
    
elseif(strcmp(distanceMeasure,'MSE'))
    for i=1:(interleave+1):sizeC-(1+interleave)
        A(:,:) = inputImageStack(:,i,:);
        B(:,:) = inputImageStack(:,(i+1+interleave),:);
        coc = getPixIntensityMSE(A,B);
        k = k + 1;
        predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
        predictedThickness(k) = predThicknessUnscaled .* inputResolution;
        thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                predThicknessUnscaled,method) .* inputResolution;

        if(saveSyntheticStack)
            syntheticStack(:,:,k) = A(:,:);
        end     
    end     
end
    

if(saveSyntheticStack)
    syntheticStack(:,:,end) = B(:,:);
else
    syntheticStack = 0;
end
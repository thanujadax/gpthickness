function [estimatedResolution,thicknessSD,syntheticStack] = estimateYresUsingY...
        (inputImageStackFileName,meanVector,sdVector,inputResolution,...
        distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
        minShift,maxShift,maxNumImages,startImageInd)
    
% estimate average x resolution for column over N number of images    
% meanVector - unscaled
% sdVector - unscaled

inputImageStack = readTiffStackToArray(inputImageStackFileName);

[sizeR,sizeC,sizeZ] = size(inputImageStack);
distMax = numel(meanVector);
A = zeros(sizeC,sizeZ);
B = zeros(sizeC,sizeZ);

numSectionIntervals = numel(1:(interleave+1):sizeR-(1+interleave));

if(isempty(saveSyntheticStack))
    saveSyntheticStack = 0;
end

if(saveSyntheticStack)
    syntheticStack = zeros(sizeC,sizeZ,(numSectionIntervals+1));
end

estimatedResolution = zeros(numSectionIntervals,1);
thicknessSD = zeros(numSectionIntervals,1);
k = 0;

% if(strcmp(distanceMeasure,'COC'))
%     for i=1:(interleave+1):sizeR-(1+interleave)
%         A(:,:) = inputImageStack(i,:,:);
%         B(:,:) = inputImageStack((i+1+interleave),:,:);
%         coc = corr2(A,B);
%         k = k + 1;
%         predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
%         estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
%         thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
%                 predThicknessUnscaled,method) .* inputResolution;
% 
%         if(saveSyntheticStack)
%             syntheticStack(:,:,k) = A(:,:);
%         end     
%     end
% elseif(strcmp(distanceMeasure,'SDI'))
%     for i=1:(interleave+1):sizeR-(1+interleave)
%         A(:,:) = inputImageStack(i,:,:);
%         B(:,:) = inputImageStack((i+1+interleave),:,:);
%         coc = getPixIntensityDeviation(A,B);
%         k = k + 1;
%         predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
%         estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
%         thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
%                 predThicknessUnscaled,method) .* inputResolution;
% 
%         if(saveSyntheticStack)
%             syntheticStack(:,:,k) = A(:,:);
%         end     
%     end    
%     
% elseif(strcmp(distanceMeasure,'MSE'))
%     for i=1:(interleave+1):sizeR-(1+interleave)
%         A(:,:) = inputImageStack(i,:,:);
%         B(:,:) = inputImageStack((i+1+interleave),:,:);
%         coc = getPixIntensityMSE(A,B);
%         k = k + 1;
%         predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
%         estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
%         thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
%                 predThicknessUnscaled,method) .* inputResolution;
% 
%         if(saveSyntheticStack)
%             syntheticStack(:,:,k) = A(:,:);
%         end     
%     end     
% end

if(strcmp(distanceMeasure,'maxNCC'))
    for z=(startImageInd+1):(startImageInd + maxNumImages)
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);
            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            j=j+1;

            xcorrImage = normxcorr2(A,B);
            coc = max(abs(xcorrImage(:)));
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
            thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(:,:,k) = A(:,:);
            end

        end
    end    
    
elseif(strcmp(distanceMeasure,'COC'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);
            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            j=j+1;

            coc = corr2(A,B);
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
            thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(:,:,k) = A(:,:);
            end            
        end
    end
    
elseif(strcmp(distanceMeasure,'SDI'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);
            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            j=j+1;
            
            coc = getPixIntensityDeviation(A,B);
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
            thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(:,:,k) = A(:,:);
            end            
        end
    end
    
elseif(strcmp(distanceMeasure,'MSE'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);
            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            j=j+1;
            [~,MSE_intensity,~,~] = measerr(A,B);
            coc = MSE_intensity;
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(k) = predThicknessUnscaled .* inputResolution;
            thicknessSD(k) = interp1((distMin:distMax-1),sdVector,...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(:,:,k) = A(:,:);
            end            
        end
    end    
    
else
    error('Unrecognized distance measure!');
end



if(saveSyntheticStack)
    syntheticStack(:,:,end) = B(:,:);
else
    syntheticStack = 0;
end


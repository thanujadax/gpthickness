function [estimatedResolution,thicknessSD,syntheticStack] = estimateYresUsingY...
        (inputImageStackFileName,meanVector,sdVector,inputResolution,...
        distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
        minShift,maxShift,maxNumImages,startImageInd)
    
% estimate average x resolution for column over N number of images    
% meanVector - unscaled
% sdVector - unscaled

saveSyntheticStack = 0;

inputImageStack = readTiffStackToArray(inputImageStackFileName);

[sizeR,sizeC,sizeZ] = size(inputImageStack);
distMax = numel(meanVector);

numResolutionPoints = sizeR - maxShift;
if(isempty(saveSyntheticStack))
    saveSyntheticStack = 0;
end

if(saveSyntheticStack)
    syntheticStack = zeros(sizeR-maxShift,sizeC,maxNumImages);
end

estimatedResolution = zeros(maxNumImages,maxShift+1);
thicknessSD = zeros(maxNumImages,maxShift+1);

k=0;

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
            A = zeros(numR-maxShift-1,numC);
            B = zeros(numR-maxShift-1,numC);
            Astart = 1 + g;
            Aend = size(I,1) - maxShift + g-1;
            Bstart = Astart + 1;
            Bend = Aend + 1;
            A(:,:) = I(Astart:Aend,:);
            B(:,:) = I(Bstart:Bend,:);
            j=j+1;

            xcorrImage = normxcorr2(A,B);
            coc = max(abs(xcorrImage(:)));
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(z-startImageInd,g+1) = predThicknessUnscaled .* inputResolution;
            thicknessSD(z-startImageInd,g+1) = interp1(sdVector,(distMin:distMax-1),...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(1:size(A,1),1:size(A,2),k) = A(:,:);
            end

        end
    end    
    
elseif(strcmp(distanceMeasure,'COC'))
    for z=(startImageInd+1):(startImageInd + maxNumImages)
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-maxShift-1,numC);
            B = zeros(numR-maxShift-1,numC);
            Astart = 1 + g;
            Aend = size(I,1) - maxShift + g-1;
            Bstart = Astart + 1;
            Bend = Aend + 1;
            A(:,:) = I(Astart:Aend,:);
            B(:,:) = I(Bstart:Bend,:);
            j=j+1;

            coc = corr2(A,B);
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(z-startImageInd,g+1) = predThicknessUnscaled .* inputResolution;
            thicknessSD(z-startImageInd,g+1) = interp1(sdVector,(distMin:distMax-1),...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(1:size(A,1),1:size(A,2),k) = A(:,:);
            end            
        end
    end
    
elseif(strcmp(distanceMeasure,'SDI'))
    for z=(startImageInd+1):(startImageInd + maxNumImages)
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-maxShift-1,numC);
            B = zeros(numR-maxShift-1,numC);
            Astart = 1 + g;
            Aend = size(I,1) - maxShift + g-1;
            Bstart = Astart + 1;
            Bend = Aend + 1;
            A(:,:) = I(Astart:Aend,:);
            B(:,:) = I(Bstart:Bend,:);
            j=j+1;
            
            coc = getPixIntensityDeviation(A,B);
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(z-startImageInd,g+1) = predThicknessUnscaled .* inputResolution;
            thicknessSD(z-startImageInd,g+1) = interp1(sdVector,(distMin:distMax-1),...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(1:size(A,1),1:size(A,2),k) = A(:,:);
            end            
        end
    end
    
elseif(strcmp(distanceMeasure,'MSE'))
    for z=(startImageInd+1):(startImageInd + maxNumImages)
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        j=0;
        for g=minShift:maxShift
            A = zeros(numR-maxShift-1,numC);
            B = zeros(numR-maxShift-1,numC);
            Astart = 1 + g;
            Aend = size(I,1) - maxShift + g-1;
            Bstart = Astart + 1;
            Bend = Aend + 1;
            A(:,:) = I(Astart:Aend,:);
            B(:,:) = I(Bstart:Bend,:);
            j=j+1;
            [~,MSE_intensity,~,~] = measerr(A,B);
            coc = MSE_intensity;
            k = k + 1;
            predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,method);
            estimatedResolution(z-startImageInd,g+1) = predThicknessUnscaled .* inputResolution;
            thicknessSD(z-startImageInd,g+1) = interp1(sdVector,(distMin:distMax-1),...
                    predThicknessUnscaled,method) .* inputResolution;

            if(saveSyntheticStack)
                syntheticStack(1:size(A,1),1:size(A,2),k) = A(:,:);
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


function cocMat = getXcorrXZstackX(inputImageStackFileName,maxShift,...
    minShift,startInd,endInd,distanceMeasure,gaussianSigma,gaussianMaskSize)
% calculate the correlation of XZ face along the X axis.

% Inputs:
% imageStack - image stack (tif) for which the thickness has to be
% estimated. This has to be registered along the z axis already.

% Outputs:
%   cocMat - Matrix containg coefficient of correlation for image pairs.
%   Each row corresponds to a different starting image. The distance
%   increases with the column index

inputImageStack = readTiffStackToArray(inputImageStackFileName);
% inputImageStack is a 3D array where the 3rd dimension is along the z axis

% gaussain blur
if(isempty(gaussianSigma))
    gaussianSigma = 0;
end
if(gaussianSigma>0)
    inputImageStack = gaussianFilter(inputImageStack,gaussianSigma,gaussianMaskSize);
end

% estimate the correlation curve (mean and sd) from different sets of
% images within the max window given by maxShift

% initially use just one image

% I = double(imread(imageStack));

[numY,numR,numC] = size(inputImageStack);
numImages = numY;

% TODO: current we take the first n images for the estimation. Perhaps we
% can think of geting a random n images.
fprintf('Estimating similarity curve using %s of shifted XY sections ...',distanceMeasure);
if(endInd>numImages)
    endInd = numImages;
    str1 = sprintf('maxNumImages > numImages. using numImages = %d instead',numImages);
    disp(str1)
end
numShifts = maxShift - minShift + 1;
numDataPoints = numel(startInd:endInd);
cocMat = zeros(numDataPoints,numShifts);
I = zeros(numR,numC);
i = 0;
if(strcmp(distanceMeasure,'maxNCC'))
    for z=startInd:endInd
        i=i+1;
        I(:,:) = inputImageStack(z,:,:);
        % [numR,numC] = size(I);
        k=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            k=k+1;

            xcorrImage = normxcorr2(A,B);
            cocMat(i,k) = max(abs(xcorrImage(:)));

        end
    end
    
elseif(strcmp(distanceMeasure,'COC'))
    for z=startInd:endInd
        i=i+1;
        I(:,:) = inputImageStack(z,:,:);
        % [numR,numC] = size(I);
        k=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            k=k+1;

            cocMat(i,k) = corr2(A,B);

        end
    end
elseif(strcmp(distanceMeasure,'SDI'))
    for z=startInd:endInd
        i=i+1;
        I(:,:) = inputImageStack(z,:,:);
        % [numR,numC] = size(I);
        k=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            k=k+1;
            
            cocMat(i,k) = getPixIntensityDeviation(A,B);

        end
    end
elseif(strcmp(distanceMeasure,'MSE'))
    for z=startInd:endInd
        i=i+1;
        I(:,:) = inputImageStack(z,:,:);
        % [numR,numC] = size(I);
        k=0;
        for g=minShift:maxShift
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            k=k+1;
            [~,MSE_intensity,~,~] = measerr(A,B);
            cocMat(i,k) = MSE_intensity;

        end
    end
            
else
    error('Unrecognized distance measure')
end


%% plot
% titleStr = 'Coefficient of Correlation using XZ sections along X axis';
% xlabelStr = 'Shifted pixels';
% ylabelStr = 'Coefficient of Correlation';
% transparent = 0;
% shadedErrorBar((1:maxShift),mean(cocMat,1),std(cocMat),'g',transparent,...
%     titleStr,xlabelStr,ylabelStr);
function xcorrMat = getXcorrXYstack(inputImageStackFileName,maxShift,minShift,maxNumImages,...
                        distanceMeasure,gaussianSigma,gaussianMaskSize)
% calculate the correlation of XY face along the Y axis . i.e. parallel to the
% cutting plane where we have maximum resolution (5nmx5nm for FIBSEM)

% Inputs:
% imageStack - image stack (tif) for which the thickness has to be
% estimated. This has to be registered along the z axis already.

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
numImages = size(inputImageStack,3);

% TODO: current we take the first n images for the estimation. Perhaps we
% can think of geting a random n images.
fprintf('Estimating similarity curve using %s of shifted XY sections ...',distanceMeasure);
if(maxNumImages>numImages)
    maxNumImages = numImages;
    str1 = sprintf('maxNumImages > numImages. using numImages = %d instead',numImages);
    disp(str1)
end
numShifts = maxShift - minShift + 1;
xcorrMat = zeros(maxNumImages,numShifts);

if(strcmp(distanceMeasure,'maxNCC'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        k = 0;
        for g=minShift:maxShift
            k = k + 1;
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);
            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            xcorrImage = normxcorr2(A,B);
            xcorrMat(z,k) = max(abs(xcorrImage(:)));
        end
    end
    
elseif(strcmp(distanceMeasure,'COC'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        k = 0;
        for g=minShift:maxShift
            k = k + 1;
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            xcorrMat(z,k) = corr2(A,B);
            
        end
    end 
elseif(strcmp(distanceMeasure,'SDI'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        k = 0;
        for g=minShift:maxShift
            k = k + 1;
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            
            xcorrMat(z,k) = getPixIntensityDeviation(A,B);           
        end
    end 
elseif(strcmp(distanceMeasure,'MSE'))
    for z=1:maxNumImages
        I = inputImageStack(:,:,z);
        [numR,numC] = size(I);
        k = 0;
        for g=minShift:maxShift
            k = k + 1;
            A = zeros(numR-g,numC);
            B = zeros(numR-g,numC);

            A(:,:) = I(1+g:size(I,1),:);
            B(:,:) = I(1:size(I,1)-g,:);
            [~,MSE_intensity,~,~] = measerr(A,B);
            xcorrMat(z,k) = MSE_intensity;            
        end
    end 
else
    error('Unrecognized distance measure!')
end

%% plot
% titleStr = 'Coefficient of Correlation using XY sections along Y axis';
% xlabelStr = 'Shifted pixels';
% ylabelStr = 'Coefficient of Correlation';
% transparent = 0;
% shadedErrorBar((1:maxShift),mean(xcorrMat,1),std(xcorrMat),'g',transparent,...
%     titleStr,xlabelStr,ylabelStr);

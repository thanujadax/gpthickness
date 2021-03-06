function xcorrMat = getXcorrZYstack(inputImageStackFileName,maxShift,...
    minShift,startInd,endInd,distanceMeasure,gaussianSigma,gaussianMaskSize)
% calculate the correlation of the ZY plane along the X axis.

% Inputs:
% imageStack - image stack (tif) for which the thickness has to be
% estimated. This has to be registered along the z axis already.

inputImageStack = readTiffStackToArray(inputImageStackFileName);
% inputImageStack is a 3D array where the 3rd dimension is along the z axis

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
numR = size(inputImageStack,1);
numC = size(inputImageStack,3); % z axis
numImages = size(inputImageStack,2); % x axis

A = zeros(numR,numC);
B = zeros(numR,numC);

z = 1; % starting image
% TODO: current we take the first n images for the estimation. Perhaps we
% can think of geting a random n images.
fprintf('Estimating %s similarity curve using zy sections ...',distanceMeasure);
numImages = numImages - maxShift;
if(endInd>numImages)
    endInd = numImages;
    str1 = sprintf('maxNumImages > numImages. using numImages = %d instead',numImages);
    disp(str1)
end
numShifts = maxShift - minShift + 1;
numDataPoints = numel(startInd:endInd);
xcorrMat = zeros(numDataPoints,numShifts);

i = 0;
if(strcmp(distanceMeasure,'maxNCC'))
    for z=startInd:endInd
        i = i+1;
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            xcorrImage = normxcorr2(A,B);
%             gpuA = gpuArray(A);
%             gpuB = gpuArray(B);
%             xcorrImage = normxcorr2(gpuA,gpuB);
%             xcorrImage = double(xcorrImage);
            xcorrMat(i,k) = max(abs(xcorrImage(:)));
        end
    end
    
elseif(strcmp(distanceMeasure,'COC'))
    for z=startInd:endInd
        i = i+1;
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            xcorrMat(i,k) = corr2(A,B);
        end
    end
elseif(strcmp(distanceMeasure,'SDI'))
    for z=startInd:endInd
        i = i+1;
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            % dI = B - A;
            xcorrMat(i,k) = getPixIntensityDeviation(A,B);
        end
    end
elseif(strcmp(distanceMeasure,'MSE'))
    for z=startInd:endInd
        i = i+1;
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            [~,MSE_intensity,~,~] = measerr(A,B);
            xcorrMat(i,k) = MSE_intensity;
        end
    end    
else
    error('Unrecognized distance measure!')
end




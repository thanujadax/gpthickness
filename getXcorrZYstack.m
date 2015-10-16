function xcorrMat = getXcorrZYstack(inputImageStackFileName,maxShift,...
    minShift,maxNumImages,distanceMeasure)
% calculate the correlation of the ZY plane along the X axis.

% Inputs:
% imageStack - image stack (tif) for which the thickness has to be
% estimated. This has to be registered along the z axis already.

inputImageStack = readTiffStackToArray(inputImageStackFileName);
% inputImageStack is a 3D array where the 3rd dimension is along the z axis

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
if(maxNumImages>numImages)
    maxNumImages = numImages;
    str1 = sprintf('maxNumImages > numImages. using numImages = %d instead',numImages);
    disp(str1)
end
numShifts = maxShift - minShift + 1;
xcorrMat = zeros(maxNumImages,numShifts);

if(strcmp(distanceMeasure,'maxNCC'))
    for z=1:maxNumImages
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
            xcorrMat(z,k) = max(abs(xcorrImage(:)));
        end
    end
    
elseif(strcmp(distanceMeasure,'COC'))
    for z=1:maxNumImages
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            xcorrMat(z,k) = corr2(A,B);

        end
    end
elseif(strcmp(distanceMeasure,'SDI'))
    for z=1:maxNumImages
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            % dI = B - A;
            xcorrMat(z,k) = getNormalizedPixIntensityDeviation(A,B);

        end
    end
elseif(strcmp(distanceMeasure,'MSE'))
    for z=1:maxNumImages
        k=0;
        for g=minShift:maxShift
            k = k + 1;
            A(:,:) = inputImageStack(:,z,:);
            B(:,:) = inputImageStack(:,z+g,:);  % with shift
            [~,MSE_intensity,~,~] = measerr(A,B);
            xcorrMat(z,k) = MSE_intensity;

        end
    end    
else
    error('Unrecognized distance measure!')
end




function sigmaMat = getIntensityMSE_Ystack...
    (inputImageStackFileName,maxShift,minShift,maxNumImages)
% calculate the sd of intensity MSE along X axis.

% Inputs:
% imageStack - image stack (tif) for which the thickness has to be
% estimated. This has to be registered along the z axis already.

inputImageStack = readTiffStackToArray(inputImageStackFileName);
% inputImageStack is a 3D array where the 3rd dimension is along the z axis

% estimate the correlation curve (mean and sd) from different sets of
% images within the max window given by maxShift

% initially use just one image

% I = double(imread(imageStack));
numImages = size(inputImageStack,3);
if(maxNumImages>numImages)
    maxNumImages = numImages;
    str1 = sprintf('maxNumImages > numImages. using numImages = %d instead',numImages);
    disp(str1)
end
numShifts = maxShift - minShift + 1;
sigmaMat = zeros(maxNumImages,numShifts);

% TODO: current we take the first n images for the estimation. Perhaps we
% can think of geting a random n images.
disp('Estimating similarity curve using MSE of intensity differences along Y axis')

for z=1:maxNumImages
    I = inputImageStack(:,:,z);
    [numR,numC] = size(I);
    k = 0;
    for g=minShift:maxShift
        % d1I = (I(1+g:size(I,1),:)-I(1:size(I,1)-g,:)); % shifted in y
        [~,MSE_intensity,~,~] = measerr(I(1+g:size(I,1),:),I(1:size(I,1)-g,:)); % shifted in x         
        k = k + 1;
        sigmaMat(z,k) = MSE_intensity;
    end
end

%% plot
% titleStr = 'SD of pixel intensity deviations using shifted XY sections';
% xlabelStr = 'Shifted pixels';
% ylabelStr = 'SD of pixel intensity deviation';
% transparent = 1;
% shadedErrorBar((1:maxShift),mean(sigmaMat,1),std(sigmaMat),'g',transparent,...
%     titleStr,xlabelStr,ylabelStr);
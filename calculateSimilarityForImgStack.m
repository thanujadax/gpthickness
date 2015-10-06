function sV = calculateSimilarityForImgStack(imageStackFileName,distanceMeasure)

% calculate pairwise image similarity for each adjacent image pair

inputImageStack = readTiffStackToArray(imageStackFileName);
numImg = size(inputImageStack,3);
numSectionIntervals = numImg - 1;

sV = zeros(numSectionIntervals,1);

if(strcmp(distanceMeasure,'SDI'))
    % use the method of SD of pixelwise intensity difference
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between two images based on the SD of
        % pixel differences
        deviationSigma = getPixIntensityDeviationSigma(image1,image2);
        sV(i) = deviationSigma;
        
    end
elseif(strcmp(distanceMeasure,'COC'))
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        coc = corr2(image1,image2);
        sV(i) = coc;
    end
elseif(strcmp(distanceMeasure,'maxNCC'))
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        xcorrMat = normxcorr2(image1,image2);
        maxXcorr = max(abs(xcorrMat(:)));
        sV(i) = maxXcorr;
    end
else
    error('unrecongnized distance measure!')
end
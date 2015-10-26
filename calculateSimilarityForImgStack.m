function sV = calculateSimilarityForImgStack(imageStackFileName,distanceMeasure,...
    startInd,endInd)

% calculate pairwise image similarity for each adjacent image pair

inputImageStack = readTiffStackToArray(imageStackFileName);
numImg = size(inputImageStack,3);
numSectionIntervals = numImg - 1;

if(endInd>numSectionIntervals)
    endInd = numSectionIntervals;
end

numIntervalsToCalculate = endInd - startInd + 1; 

sV = zeros(numIntervalsToCalculate,1);

if(strcmp(distanceMeasure,'SDI'))
    % use the method of SD of pixelwise intensity difference
    for i = startInd:endInd
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between two images based on the SD of
        % pixel differences
        deviationSigma = getPixIntensityDeviation(image1,image2);
        sV(i-startInd + 1) = deviationSigma;
        
    end
elseif(strcmp(distanceMeasure,'COC'))
    for i = startInd:endInd
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        coc = corr2(image1,image2);
        sV(i-startInd + 1) = coc;
    end
elseif(strcmp(distanceMeasure,'maxNCC'))
    for i = startInd:endInd
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        xcorrMat = normxcorr2(image1,image2);
        maxXcorr = max(abs(xcorrMat(:)));
        sV(i-startInd + 1) = maxXcorr;
    end
else
    error('unrecongnized distance measure!')
end

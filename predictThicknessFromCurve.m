function [predictedThickness, predictionSD] = predictThicknessFromCurve(...
        imageStackFileName,meanVector,sdVector,distMin,...
        interpolationMethod,inputResolution,distanceMeasure)
% Returns the section thickness relative to the xy resolution. Multiply by
% xyResolution to get the actual thickness.

% calibrationMethod
% % 1 - c.o.c across XY sections, along X
% % 2 - c.o.c across XY sections, along Y axis
% % 3 - c.o.c across ZY sections, along x axis
% % 4 - c.o.c across ZY sections along Y
% % 5 - c.o.c acroxx XZ sections, along X
% % 6 - c.o.c acroxx XZ sections, along Y
% % 7 - c.o.c across XY sections, along Z
% % 8 - c.o.c across ZY sections, along Z
% % 9 - c.o.c. across XZ sections, along Z
% % 10 - SD of XY per pixel intensity difference
% TODO: methods robust against registration problems

% numPairs -
%   if set to 1, use sections i and i + 1 to estimate thickness of i
%   if 2, use sections i, i+1 and i+2 to estiamte the thickness of i
    
inputImageStack = readTiffStackToArray(imageStackFileName);
numImg = size(inputImageStack,3);
numSectionIntervals = numImg - 1;
distMax = numel(meanVector);

predictedThickness = zeros(1,numImg-1); % relative to xy pix resolution
predictionSD = zeros(1,numImg-1);

str1 = sprintf('Calculating distances');
disp(str1);


if(strcmp(distanceMeasure,'SDI'))
    % use the method of SD of pixelwise intensity difference
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between two images based on the SD of
        % pixel differences
        deviationSigma = getPixIntensityDeviationSigma(image1,image2);
        predictedThicknessUnscaled = getRelativeDistance(meanVector,distMin,distMax,deviationSigma);
        predictedThickness(1,i) = predictedThicknessUnscaled .* inputResolution;
        predictionSD(k) = interp1((distMin:distMax-1),sdVector,...
            predictedThicknessUnscaled,interpolationMethod) .* inputResolution;
    end
elseif(strcmp(distanceMeasure,'MSE'))
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        mse_intensity = getPixIntensityMSE(image1,image2);
        predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),mse_intensity,interpolationMethod);
        predictedThickness(i) = predThicknessUnscaled .* inputResolution;
        predictionSD(i) = interp1((distMin:distMax-1),sdVector,...
            predThicknessUnscaled,interpolationMethod) .* inputResolution;
    end    
elseif(strcmp(distanceMeasure,'COC'))
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        coc = corr2(image1,image2);
        predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),coc,interpolationMethod);
        predictedThickness(i) = predThicknessUnscaled .* inputResolution;
        predictionSD(i) = interp1((distMin:distMax-1),sdVector,...
            predThicknessUnscaled,interpolationMethod) .* inputResolution;
    end
elseif(strcmp(distanceMeasure,'maxNCC'))
    for i = 1:numSectionIntervals
        image1 = inputImageStack(:,:,i);
        image2 = inputImageStack(:,:,(i+1));
        % calculate the distance between the two images based on the
        % correlation coefficient
        xcorrMat = normxcorr2(image1,image2);
        maxXcorr = max(abs(xcorrMat(:)));
        predThicknessUnscaled = interp1(meanVector,(distMin:distMax-1),maxXcorr,interpolationMethod);
        predictedThickness(i) = predThicknessUnscaled .* inputResolution;
        predictionSD(i) = interp1((distMin:distMax-1),sdVector,...
            predThicknessUnscaled,interpolationMethod) .* inputResolution;
    end
else
    error('unrecongnized distance measure!')
end

function validate2()

% Validate X and Y resolution based estimates separately. For this we split
% the volume into 2 different parts. First part is used for calibration
% (learning the regression curve). The second part is used for validation. 

%% Inputs
saveSyntheticStack = 1 ; % the synthetic stack used for validation to be saved in output path
inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s603/s603.tif';
precomputedMatFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s603';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/validation/20151019/s603/sdi/xResUsingY';
fileStr = 'xcorrMat'; % general string that defines the .mat file
distMin = 0;
saveOnly = 0;
xResolution = 5; % nm
yResolution = 5; % nm
numImagesUsedForCalibration = 100; % these images will not be used for testing
minShift = 0;
maxShift = 20;
maxNumImages = 100;

numBins = 10;

%******************************************************************
%*** CHECK CALIBRATION METHODS VECTOR UNDER VALIDATION SECTION ****
%******************************************************************
interleave = 0; % if 1, e.g for x axis there will be a gap of 10nm
% between two images used for prediction (interleaving 1 image)

validateXUsingXresolution = 0;
validateYUsingYresolution = 0;
validateYUsingXresolution = 0;
validateXUsingYresolution = 1;
%% Param
distanceMeasure = 'SDI';
% method = 'spline'; % method of interpolation
method = 'linear';

color = 'b';
predictionFigureFileStr = 'prediction';

%% Validation
% checkAndCreateSubDir(outputSavePath,subDir);
if(validateXUsingXresolution)
    % predict y resolution using x
    % calibrationMethods = [1 3 5];
    calibrationMethods = [1];
    calibrationString = sprintf('Avg %s curve using X resolution',distanceMeasure);
    calibrationFigureFileString = sprintf('%s_xResolution',distanceMeasure);
    subTitle = 'xUseX';


elseif(validateYUsingYresolution)
    % predict x resolution using y
    % calibrationMethods = [2 4 6];
    calibrationMethods = [2];
    calibrationString = sprintf('Avg %s curve using Y resolution',distanceMeasure);
    calibrationFigureFileString = sprintf('%s_yResolution_ensemble',distanceMeasure);
    subTitle = 'yUseY';

elseif(validateYUsingXresolution)
    calibrationMethods = [1];
    calibrationString = sprintf('Avg %s curve using X resolution',distanceMeasure);
    calibrationFigureFileString = sprintf('%s_xResolution',distanceMeasure);
    subTitle = 'yUseX';
    
elseif(validateXUsingYresolution)
    calibrationMethods = [2];
    calibrationString = sprintf('Avg %s curve using Y resolution',distanceMeasure);
    calibrationFigureFileString = sprintf('%s_xResolution',distanceMeasure);
    subTitle = 'xUseY';
end

% get the calibration curves from the precomputed .mat files        
% get the avg calibration curve
[meanVector,stdVector] = makeEnsembleDecayCurveForVolume...
    (precomputedMatFilePath,fileStr,0,calibrationMethods,distanceMeasure);

% plot decay curve
plotSaveMeanCalibrationCurveWithSD...
    (inputImageStackFileName,calibrationString,saveOnly,...
    distMin,meanVector,stdVector,color,outputSavePath,calibrationFigureFileString);

%% method1 predict the thickness/resolution in the assumed unknown direction
if(validateXUsingXresolution)
    inputResolution = xResolution;
    outputResolution = yResolution;
    [predictedResolution, predResSd,syntheticStack] = estimateXresUsingX...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
            minShift,maxShift,maxNumImages,numImagesUsedForCalibration);    
elseif(validateYUsingYresolution)
    inputResolution = yResolution;
    outputResolution = xResolution;
    [predictedResolution, predResSd,syntheticStack] = estimateYresUsingY...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
            minShift,maxShift,maxNumImages,numImagesUsedForCalibration);
elseif(validateYUsingXresolution)
    inputResolution = yResolution;
    outputResolution = xResolution;
    [predictedResolution, predResSd,syntheticStack] = estimateYresUsingY...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
            minShift,maxShift,maxNumImages,numImagesUsedForCalibration);
        
elseif(validateXUsingYresolution)
    inputResolution = yResolution;
    outputResolution = xResolution;
    [predictedResolution, predResSd,syntheticStack] = estimateXresUsingX...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
            minShift,maxShift,maxNumImages,numImagesUsedForCalibration);
end

if(saveSyntheticStack)
    outputFileName = sprintf('syntheticStack_%s.tif',subTitle);
    outputFileName = fullfile(outputSavePath,outputFileName);
    syntheticStack = syntheticStack./255;
    for K=1:size(syntheticStack,3)
       imwrite(syntheticStack(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
    end

end

meanResolutionPerImage = mean(predictedResolution,2);

% plot predicted thickness
figure;plot(predictedResolution);
% lineProps = [];
% transparent = 1;
titleStr = sprintf('Predicted resolution for different images %s - (%s interpolation)',...
                    subTitle,method);
title(titleStr)
xlabel('Image ID');
ylabel('Resolution (nm)');
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% plot predicted thickness with error bar
lineProps = [];
transparent = 1;
titleStr = sprintf('Predicted resolution %s - (%s interpooation)',...
                    subTitle,method);
xlabelStr = 'Image ID';
ylabelStr = 'Resolution (nm)';

figure();
shadedErrorBar((1:size(predictedResolution,1)),mean(predictedResolution,2),...
    getSumStd(predResSd,2),color,transparent,...
    titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s_wErrBar',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% save thickness in txt file
save(strcat(predictionFileName,'.dat'),'predictedResolution','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predResSd','-ASCII');
% calculate the error, mean error and the variance

% plot SD
figure;
plot(predResSd);
titleStr = sprintf('Predicted Resolution SD %s - (%s interpolation)',...
                    subTitle,method);
title(titleStr)

xlabel('Image ID');
ylabel('Resolution SD (nm))');
% save
predictionFileName = sprintf('SD_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% histograms.
% numBins = floor(numel(predictedThickness)/(100/(interleave+1)));
figure;hist(meanResolutionPerImage,numBins)
title(titleStr)
xlabel('Predicted Resolution (nm)')
ylabel('# images')
% save
predictionFileName = sprintf('hist_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% calculate the error, mean error and the variance
trueThickness = ones(numel(meanResolutionPerImage),1).* (outputResolution * (1+interleave));
predictionError = (trueThickness - meanResolutionPerImage)./trueThickness(1);
msePredictionError = mean((trueThickness - meanResolutionPerImage).^2);
stdPredictionError = std(predictionError);
meanSectionThickness = mean(meanResolutionPerImage);
stdSectionThickness = getSumStd(predResSd,2);
stdSectionThickness = getSumStd(stdSectionThickness,1);
% save prediction error
predictionFileName = sprintf('NError_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
save(strcat(predictionFileName,'.dat'),'predictionError','-ASCII');

% plot prediction error
figure;
plot(predictionError);
titleStr = sprintf('Normalized Estimation Error %s - (%s interploation)',...
                    subTitle,method);
title(titleStr)

xlabel('Image ID');
ylabel('Estimation Error');
% save prediction plot
predictionFileName = sprintf('predictionError_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% write stats to text file
statsFileName = sprintf('stats_%s_%s_%s',predictionFigureFileStr,subTitle,method);
statsFileName = fullfile(outputSavePath,statsFileName);
statsFileName = strcat(statsFileName,'.dat'); 
fidStats = fopen(statsFileName,'w');
fprintf(fidStats,'mean squared estimation error = %d (nm2)\n',msePredictionError);
fprintf(fidStats,'SD of estimation error = %d (nm)\n',stdPredictionError);
fprintf(fidStats,'mean image resolution = %d (nm) \n',meanSectionThickness);
fprintf(fidStats,'SD of image resolution = %d (nm)\n',stdSectionThickness);
fclose(fidStats);
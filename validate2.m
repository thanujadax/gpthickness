function validate2()

% Validate X and Y resolution based estimates separately. For this we split
% the volume into 2 different parts. First part is used for calibration
% (learning the regression curve). The second part is used for validation. 

%% Inputs
saveSyntheticStack = 1 ; % the synthetic stack used for validation to be saved in output path
inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s502/s502.tif';
precomputedMatFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/validation/20151019/s502/sdi/xResUsingX';
fileStr = 'xcorrMat'; % general string that defines the .mat file
distMin = 0;
saveOnly = 0;
xResolution = 5; % nm
yResolution = 5; % nm
numImagesUsedForCalibration = 100; % these images will not be used for testing
minShift = 0;
maxShift = 35;
maxNumImages = 100;
%******************************************************************
%*** CHECK CALIBRATION METHODS VECTOR UNDER VALIDATION SECTION ****
%******************************************************************
interleave = 0; % if 1, e.g for x axis there will be a gap of 10nm
% between two images used for prediction (interleaving 1 image)

validateXUsingXresolution = 1;
validateYUsingYresolution = 0;
validateYUsingXresolution = 0;

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
    [predictedThickness, predThickSd,syntheticStack] = estimateXresUsingX...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
            minShift,maxShift,maxNumImages,numImagesUsedForCalibration);    
elseif(validateYUsingYresolution)
    inputResolution = yResolution;
    outputResolution = xResolution;
    [predictedThickness, predThickSd,syntheticStack] = estimateYresUsingY...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure,...
            minShift,maxShift,maxNumImages,numImagesUsedForCalibration);
elseif(validateYUsingXresolution)
    inputResolution = yResolution;
    outputResolution = xResolution;
    [predictedThickness, predThickSd,syntheticStack] = estimateYresUsingY...
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

% plot predicted thickness
figure;plot(predictedThickness);
% lineProps = [];
% transparent = 1;
titleStr = sprintf('Predicted thickness %s - Interleave = %d (%s interpolation)',...
                    subTitle,interleave,method);
title(titleStr)
xlabel('Inter-section interval');
ylabel('Thickness (nm)');
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% plot predicted thickness with error bar
lineProps = [];
transparent = 1;
titleStr = sprintf('Predicted thickness %s - Interleave = %d (%s interpooation)',...
                    subTitle,interleave,method);
xlabelStr = 'Inter-section interval';
ylabelStr = 'Thickness (nm)';
shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
    titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s_wErrBar',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% save thickness in txt file
save(strcat(predictionFileName,'.dat'),'predictedThickness','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predThickSd','-ASCII');
% calculate the error, mean error and the variance

% plot SD
figure;
plot(predThickSd);
titleStr = sprintf('Predicted thickness SD %s - Interleave = %d (%s interpolation)',...
                    subTitle,interleave,method);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Thickness SD (nm))');
% save
predictionFileName = sprintf('SD_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% histograms.
numBins = floor(numel(predictedThickness)/(100/(interleave+1)));
figure;hist(predictedThickness,numBins)
title(titleStr)
xlabel('Predicted thickness (nm)')
ylabel('# sections')
% save
predictionFileName = sprintf('hist_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% calculate the error, mean error and the variance
trueThickness = ones(numel(predictedThickness),1).* (outputResolution * (1+interleave));
predictionError = (trueThickness - predictedThickness)./trueThickness(1);
meanAbsPredictionError = mean(abs(predictionError));
stdPredictionError = std(predictionError);
meanSectionThickness = mean(predictedThickness);
stdSectionThickness = std(predictedThickness);

% save prediction error
predictionFileName = sprintf('NError_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
save(strcat(predictionFileName,'.dat'),'predictionError','-ASCII');

% plot prediction error
figure;
plot(predictionError);
titleStr = sprintf('Normalized Prediction Error %s - Interleave = %d (%s interploation)',...
                    subTitle,interleave,method);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Prediction Error');
% save prediction plot
predictionFileName = sprintf('predictionError_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% write stats to text file
statsFileName = sprintf('stats_%s_%s_%s',predictionFigureFileStr,subTitle,method);
statsFileName = fullfile(outputSavePath,statsFileName);
statsFileName = strcat(statsFileName,'.dat'); 
fidStats = fopen(statsFileName,'w');
fprintf(fidStats,'mean abs normalized prediction error = %d \n',meanAbsPredictionError);
fprintf(fidStats,'SD of prediction error = %d \n',stdPredictionError);
fprintf(fidStats,'mean section thickness = %d \n',meanSectionThickness);
fprintf(fidStats,'SD of section thickness = %d \n',stdSectionThickness);
fclose(fidStats);
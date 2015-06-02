function mainPredictThicknessOfVolume()

inputImageStackFileName = '/home/thanuja/projects/data/ssSEM_dataset/cubes/30/s108/s108.tif';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/ssSEM/30m/s108/20150602';

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

calibrationMethods = [1 2];

% params only for doThicknessEstimation
params.imgStackFileExt = 'tif';
params.minShift = 0;
params.predict = 0; % we don't use the predict method in doThicknessEstimation
params.xyResolution = 5; % nm
params.maxShift = 16;
params.maxNumImages = 100; % number of sections to initiate calibration.
                % the calibration curve is the mean value obtained by all
                % these initiations
params.numPairs = 1; % number of section pairs to be used to estimate the thickness of one section
params.plotOutput = 1; % don't plot intermediate curves.
params.usePrecomputedCurve = 0;
params.pathToPrecomputedCurve = '';
params.suppressPlots = 1;

% other params
methodCOC = 1;
fileStr = 'xcorrMat'; % general string that defines the .mat file
distMin = 0;
saveOnly = 0;
xResolution = 5; % nm
yResolution = 5; % nm
inputResolution = 5;

tokenizedFName = strsplit(inputImageStackFileName,filesep);
nameOfStack = strtok(tokenizedFName(end),'.');
subTitle = nameOfStack{1};

interpolationMethod = 'linear';

calibrationString = 'Avg c.o.c decay using X, Y resolutions';
calibrationFigureFileString = 'coc_xyResolution_ensemble';
color = 'b';

predictionFigureFileStr = 'Prediction';

% create xcorr mat files. We do not use the predictions here.
doThicknessEstimation(...
    calibrationMethods,inputImageStackFileName,outputSavePath,params);

% get the calibration curves from the precomputed .mat files        
% get the avg calibration curve
[meanVector,stdVector] = makeEnsembleDecayCurveForVolume...
    (outputSavePath,fileStr,0,calibrationMethods);

% plot decay curve
plotSaveMeanCalibrationCurveWithSD...
    (inputImageStackFileName,calibrationString,saveOnly,...
    distMin,meanVector,stdVector,color,outputSavePath,calibrationFigureFileString);

% predict thickness
[predictedThickness, predictionSD] = predictThicknessFromCurve(...
        inputImageStackFileName,meanVector,stdVector,distMin,methodCOC,...
        interpolationMethod,inputResolution);

%% Plots
% plot predicted thickness
figure;plot(predictedThickness);
titleStr = sprintf('Estimated thickness %s (%s interpolation)',...
                    subTitle,interpolationMethod);
title(titleStr)
xlabel('Inter-section interval');
ylabel('Thickness (nm)');
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s',predictionFigureFileStr,subTitle,interpolationMethod);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% plot predicted thickness with error bar
lineProps = [];
transparent = 1;
titleStr = sprintf('Estimated thickness %s (%s interpolation)',...
                    subTitle,interpolationMethod);
xlabelStr = 'Inter-section interval';
ylabelStr = 'Thickness (nm)';
shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predictionSD,color,transparent,...
    titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s_wErrBar',predictionFigureFileStr,subTitle,interpolationMethod);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% save thickness in txt file
save(strcat(predictionFileName,'.dat'),'predictedThickness','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predThickSd','-ASCII');
% calculate the error, mean error and the variance

% plot SD
figure;
plot(predictionSD);
titleStr = sprintf('Predicted thickness SD %s (%s interpolation)',...
                    subTitle,interpolationMethod);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Thickness SD (nm))');
% save
predictionFileName = sprintf('SD_%s_%s_%s',predictionFigureFileStr,subTitle,interpolationMethod);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% % histograms.
% numBins = floor(numel(predictedThickness)/(100/(interleave+1)));
% figure;hist(predictedThickness,numBins)
% title(titleStr)
% xlabel('Predicted thickness (nm)')
% ylabel('# sections')
% % save
% predictionFileName = sprintf('hist_%s_%s_%s',predictionFigureFileStr,subTitle,method);
% predictionFileName = fullfile(outputSavePath,predictionFileName);
% print(predictionFileName,'-dpng');


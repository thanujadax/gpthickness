function [predictedThickness_u, predictionSD_u] = ...
    mainPredictThicknessOfVolumeGP...
    (inputImageStackFileName,outputSavePath,gpModelPath,...
    params, startInd,numImagesToEstimate,interpolationMethod,distanceMeasure)

%inputImageStackFileName = '/home/thanuja/projects/data/ssSEM_dataset/cubes/30/s108/s108.tif';
%outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/ssSEM/maxNCC/30m/20150812/s108';

% inputImageStackFileName = '/home/thanuja/projects/data/rita/cropped_aligned/D4.tif';
% inputImageStackFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/rawStack.tif';
% inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/xShifted/s502xShiftedGap15_xShiftedStack_sliceID101.tif';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c1pred';
% outputSavePath = '/home/thanuja/projects/data/rita/predictions/D4';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/ssTEM/20151031';
% gpModelPath = '/home/thanuja/projects/data/rita/gpModels/y_sdi/gpModel.mat';
% gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/gpModels/y/gpModel.mat';

% % 1 - c.o.c across XY sections, along X
% % 2 - c.o.c across XY sections, along Y axis
% % 3 - c.o.c across ZY sections, along x axis
% % 4 - c.o.c across ZY sections along Y
% % 5 - c.o.c acroxx XZ sections, along X
% % 6 - c.o.c acroxx XZ sections, along Y
% % 7 - c.o.c across XY sections, along Z
% % 8 - c.o.c across ZY sections, along Z
% % 9 - c.o.c. across XZ sections, along Z

% calibrationMethods = [2];

% distanceMeasure = 'SDI';  % standard deviation of pixel intensity
% differences
% distanceMeasure = 'COC';  % coefficient of correlation
% distanceMeasure = 'maxNCC'; % maximum normalized cross correlation

% % params only for doThicknessEstimation
% params.imgStackFileExt = 'tif';
% params.minShift = 0;
% params.predict = 0; % we don't use the predict method in doThicknessEstimation
% params.xyResolution = 5; % nm
% params.maxShift = 40;
% params.maxNumImages = 3; % number of sections to initiate calibration.
%                 % the calibration curve is the mean value obtained by all
%                 % these initiations
% params.numPairs = 1; % number of section pairs to be used to estimate the thickness of one section
% params.plotOutput = 1; % don't plot intermediate curves.
% params.usePrecomputedCurve = 1;
% params.pathToPrecomputedCurve = '';
% params.suppressPlots = 0;
% 
% % other params
% % methodCOC = 1; % if it's based on correlation
% fileStr = 'xcorrMat'; % general string that defines the .mat file
% distMin = 0;
% saveOnly = 0;
% %xResolution = 5; % nm
% %yResolution = 5; % nm

% inputResolution = 5;
inputResolution = params.xyResolution;

% startInd = 1;
% numImagesToEstimate = 3;
endInd = startInd + numImagesToEstimate - 1;

tokenizedFName = strsplit(inputImageStackFileName,filesep);
nameOfStack = strtok(tokenizedFName(end),'.');
subTitle = nameOfStack{1};

% interpolationMethod = 'linear';

calibrationString = sprintf('Avg %s decay using X, Y resolutions',distanceMeasure);
calibrationFigureFileString = sprintf('%s_xyResolution_ensemble',distanceMeasure);
color = 'b';

predictionFigureFileStr = 'Prediction';

% % get the calibration curves from the precomputed .mat files        
% % get the avg calibration curve
% [meanVector,stdVector] = makeEnsembleDecayCurveForVolume...
%     (outputSavePath,fileStr,0,calibrationMethods,distanceMeasure);
% 
% % plot decay curve
% plotSaveMeanCalibrationCurveWithSD...
%     (inputImageStackFileName,calibrationString,saveOnly,...
%     distMin,meanVector,stdVector,color,outputSavePath,calibrationFigureFileString);
% 
% % predict thickness
% [predictedThickness, predictionSD] = predictThicknessFromCurve(...
%         inputImageStackFileName,meanVector,stdVector,distMin,...
%         interpolationMethod,inputResolution,distanceMeasure);

gpModelPath = fullfile(gpModelPath,'gpModel.mat');
gpModel = importdata(gpModelPath);
similarityValues = calculateSimilarityForImgStack(inputImageStackFileName,...
    distanceMeasure,startInd,endInd);
[predictedThickness_u, predictionSD_u] = estimateThicknessGP(...
        similarityValues,gpModel,outputSavePath,subTitle);
    
    predictedThickness = predictedThickness_u .* inputResolution;
    predictionSD = predictionSD_u .* inputResolution;

%% Plots
if(params.plotOutput)
% plot predicted thickness
figure;plot(predictedThickness);
titleStr = sprintf('Estimated thickness %s)',...
                    subTitle);
set(gca,'FontSize',14)
% title(titleStr)
xlabel('Inter-section interval','FontSize',25);
ylabel('Thickness (nm)','FontSize',25);
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s',predictionFigureFileStr,subTitle);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% plot predicted thickness with error bar
lineProps = [];
transparent = 1;
titleStr = sprintf('Estimated thickness %s',...
                    subTitle);
xlabelStr = 'Inter-section interval';
ylabelStr = 'Thickness (nm)';
% 2 sigma
sigmas = predictionSD*2;
% Temporarily removing plot
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,sigmas,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_wErrBar',predictionFigureFileStr,subTitle);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% save thickness in txt file
predictedThicknessCol = predictedThickness';
predictionSDCol = predictionSD';
save(strcat(predictionFileName,'.dat'),'predictedThicknessCol','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predictionSDCol','-ASCII');
% calculate the error, mean error and the variance

% plot SD
figure;
plot(predictionSD);
%axis ([1 ])
titleStr = sprintf('Predicted thickness SD %s (Gaussian Process Regression)',...
                    subTitle);
title(titleStr)
set(gca,'FontSize',14)
xlabel('Inter-section interval','FontSize',25);
ylabel('Thickness SD (nm))','FontSize',25);
% save
predictionFileName = sprintf('SD_%s_%s',predictionFigureFileStr,subTitle);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');
end
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


function mainPredictThicknessOfVolumeGP()

%inputImageStackFileName = '/home/thanuja/projects/data/ssSEM_dataset/cubes/30/s108/s108.tif';
%outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/ssSEM/maxNCC/30m/20150812/s108';

inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s704/s704.tif';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20150818/s704';
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151001/s704';


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

calibrationMethods = [10 11 12 13 14];

% distanceMeasure = 'SDI';  % standard deviation of pixel intensity
% differences
distanceMeasure = 'COC';  % coefficient of correlation
% distanceMeasure = 'maxNCC'; % maximum normalized cross correlation

% params only for doThicknessEstimation
params.imgStackFileExt = 'tif';
params.minShift = 0;
params.predict = 0; % we don't use the predict method in doThicknessEstimation
params.xyResolution = 5; % nm
params.maxShift = 35;
params.maxNumImages = 100; % number of sections to initiate calibration.
                % the calibration curve is the mean value obtained by all
                % these initiations
params.numPairs = 1; % number of section pairs to be used to estimate the thickness of one section
params.plotOutput = 1; % don't plot intermediate curves.
params.usePrecomputedCurve = 0;
params.pathToPrecomputedCurve = '';
params.suppressPlots = 1;

% other params
% methodCOC = 1; % if it's based on correlation
fileStr = 'xcorrMat'; % general string that defines the .mat file
distMin = 0;
saveOnly = 0;
%xResolution = 5; % nm
%yResolution = 5; % nm
inputResolution = 5;

tokenizedFName = strsplit(inputImageStackFileName,filesep);
nameOfStack = strtok(tokenizedFName(end),'.');
subTitle = nameOfStack{1};

interpolationMethod = 'linear';

calibrationString = sprintf('Avg %s decay using X, Y resolutions',distanceMeasure);
calibrationFigureFileString = sprintf('%s_xyResolution_ensemble',distanceMeasure);
color = 'b';

predictionFigureFileStr = 'Prediction';

% create xcorr mat files. We do not use the predictions here.
if(~params.usePrecomputedCurve)
    doThicknessEstimation(...
        calibrationMethods,inputImageStackFileName,outputSavePath,params,distanceMeasure);
    
end

% get the calibration curves from the precomputed .mat files        
% get the avg calibration curve
[meanVector,stdVector] = makeEnsembleDecayCurveForVolume...
    (outputSavePath,fileStr,0,calibrationMethods,distanceMeasure);

% plot decay curve
plotSaveMeanCalibrationCurveWithSD...
    (inputImageStackFileName,calibrationString,saveOnly,...
    distMin,meanVector,stdVector,color,outputSavePath,calibrationFigureFileString);

% predict thickness
[predictedThickness, predictionSD] = predictThicknessFromCurve(...
        inputImageStackFileName,meanVector,stdVector,distMin,...
        interpolationMethod,inputResolution,distanceMeasure);

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
predictedThicknessCol = predictedThickness';
predictionSDCol = predictionSD';
save(strcat(predictionFileName,'.dat'),'predictedThicknessCol','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predictionSDCol','-ASCII');
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

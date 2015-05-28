function validate()

%% Inputs
inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s108/s108.tif';
precomputedMatFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/20150525/s108';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/validation/20150528/s108';
fileStr = 'xcorrMat'; % general string that defines the .mat file
distMin = 0;
saveOnly = 0;
xResolution = 5; % nm
yResolution = 5; % nm

interleave = 1; % if 1, e.g for x axis there will be a gap of 10nm
% between two images used for prediction (interleaving 1 image)

validateUsingXresolution = 1 ; % if 0, validation is done using y resolution.
% For FIBSEM, the resolution of x and y are known (~ 5 nm)
% if set we treat y as the known resolution to calibrate the decay curves
% and x as the direction for which  

%% Param
method = 'spline'; % method of interpolation
method2 = 'linear';

color = 'b';
predictionFigureFileStr = 'prediction';

%% Validation
% checkAndCreateSubDir(outputSavePath,subDir);
if(validateUsingXresolution)
    % predict y resolution using x
    calibrationMethods = [1 3 5];
    calibrationString = 'Avg c.o.c decay using X resolution';
    calibrationFigureFileString = 'coc_xResolution_ensemble';
    subTitle = 'XZ_y';
else
    % predict x resolution using y
    calibrationMethods = [2 4 6];
    calibrationString = 'Avg c.o.c decay using Y resolution';
    calibrationFigureFileString = 'coc_yResolution_ensemble';
    subTitle = 'YZ_x';
end

% get the calibration curves from the precomputed .mat files        
% get the avg calibration curve
[meanVector,stdVector] = makeEnsembleDecayCurveForVolume...
    (precomputedMatFilePath,fileStr,0,calibrationMethods);

% plot decay curve
plotSaveMeanCalibrationCurveWithSD...
    (inputImageStackFileName,calibrationString,saveOnly,...
    distMin,meanVector,stdVector,color,outputSavePath,calibrationFigureFileString);

%% method1 predict the thickness/resolution in the assumed unknown direction
if(validateUsingXresolution)
    [predictedThickness, predThickSd] = predictThicknessXZ_Y...
            (inputImageStackFileName,meanVector,stdVector,xResolution,...
            distMin,method,interleave);
    
else
    [predictedThickness, predThickSd] = predictThicknessYZ_X...
            (inputImageStackFileName,meanVector,stdVectoryResolution,...
            distMin,method,interleave);
end

% plot predicted thickness
figure;plot(predictedThickness);
% lineProps = [];
% transparent = 1;
titleStr = sprintf('Predicted thickness %s - Interleave = %d (%s interploation)',...
                    subTitle,interleave,method);
title(titleStr)
% H = mseb((1:numel(predictedThickness)),predictedThickness,predThickSd,lineProps,transparent);
xlabel('Inter-section interval');
ylabel('Thickness (nm)');
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');
% save thickness in txt file
save(strcat(predictionFileName,'.dat'),'predictedThickness','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predThickSd','-ASCII');
% calculate the error, mean error and the variance

% plot SD
figure;
plot(predThickSd);
titleStr = sprintf('Predicted thickness SD %s - Interleave = %d (%s interploation)',...
                    subTitle,interleave,method);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Thickness SD (nm))');
% save
predictionFileName = sprintf('SD_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

%% method 2: predict the thickness/resolution in the assumed unknown direction
if(validateUsingXresolution)
    [predictedThickness, predThickSd] = predictThicknessXZ_Y...
            (inputImageStackFileName,meanVector,stdVector,xResolution,...
            distMin,method2,interleave);
    
else
    [predictedThickness, predThickSd] = predictThicknessYZ_X...
            (inputImageStackFileName,meanVector,stdVectoryResolution,...
            distMin,method2,interleave);
end

% plot predicted thickness
figure;plot(predictedThickness);
titleStr = sprintf('Predicted thickness %s - Interleave = %d (%s interploation)',...
    subTitle,interleave,method2);
title(titleStr)
% H = mseb((1:numel(predictedThickness)),predictedThickness,predThickSd,lineProps,transparent);
xlabel('Inter-section interval');
ylabel('Thickness (nm)');
% shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
%     titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s',predictionFigureFileStr,subTitle,method2);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');
% save thickness in txt file
save(strcat(predictionFileName,'.dat'),'predictedThickness','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predThickSd','-ASCII');

% plot SD
figure;
plot(predThickSd);
titleStr = sprintf('Predicted thickness SD %s - Interleave = %d (%s interploation)',...
                    subTitle,interleave,method);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Thickness SD (nm))');
% save
predictionFileName = sprintf('SD_%s_%s_%s',predictionFigureFileStr,subTitle,method);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% calculate the error, mean error and the variance

% todo add histograms.


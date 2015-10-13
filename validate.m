function validate()

%% Inputs
saveSyntheticStack = 1 ; % the synthetic stack used for validation to be saved in output path
inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s704/s704.tif';
precomputedMatFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151012/s704/100i/mse';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/validation/20151012/s704/mse/y';
fileStr = 'xcorrMat'; % general string that defines the .mat file
distMin = 0;
saveOnly = 0;
xResolution = 5; % nm
yResolution = 5; % nm
%******************************************************************
%*** CHECK CALIBRATION METHODS VECTOR UNDER VALIDATION SECTION ****
%******************************************************************
interleave = 1; % if 1, e.g for x axis there will be a gap of 10nm
% between two images used for prediction (interleaving 1 image)

validateUsingXresolution = 0 ; % if 0, validation is done using y resolution.
% For FIBSEM, the resolution of x and y are known (~ 5 nm)
% if set we treat y as the known resolution to calibrate the decay curves
% and x as the direction for which  

%% Param
distanceMeasure = 'MSE';
method = 'spline'; % method of interpolation
method2 = 'linear';

color = 'b';
predictionFigureFileStr = 'prediction';

%% Validation
% checkAndCreateSubDir(outputSavePath,subDir);
if(validateUsingXresolution)
    % predict y resolution using x
    % calibrationMethods = [1 3 5];
    calibrationMethods = [13];
    calibrationString = sprintf('Avg %s decay using X resolution',distanceMeasure);
    calibrationFigureFileString = sprintf('%s_xResolution_ensemble',distanceMeasure);
    subTitle = 'XZ_y';
    % subTitle = 'XZ_y';
else
    % predict x resolution using y
    % calibrationMethods = [2 4 6];
    calibrationMethods = [14];
    calibrationString = sprintf('Avg %s decay using Y resolution',distanceMeasure);
    calibrationFigureFileString = sprintf('%s_yResolution_ensemble',distanceMeasure);
    subTitle = 'YZ_x';
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
if(validateUsingXresolution)
    inputResolution = xResolution;
    outputResolution = yResolution;
    [predictedThickness, predThickSd,syntheticStack] = predictThicknessXZ_Y...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure);    
else
    inputResolution = yResolution;
    outputResolution = xResolution;
    [predictedThickness, predThickSd,syntheticStack] = predictThicknessYZ_X...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method,interleave,saveSyntheticStack,distanceMeasure);
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

%% method 2: predict the thickness/resolution in the assumed unknown direction
if(validateUsingXresolution)
    [predictedThickness, predThickSd,syntheticStack] = predictThicknessXZ_Y...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method2,interleave,saveSyntheticStack,distanceMeasure);
    
else
    [predictedThickness, predThickSd,syntheticStack] = predictThicknessYZ_X...
            (inputImageStackFileName,meanVector,stdVector,inputResolution,...
            distMin,method2,interleave,saveSyntheticStack,distanceMeasure);
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

% plot predicted thickness with error bar
titleStr = sprintf('Predicted thickness %s - Interleave = %d (%s interpooation)',...
                    subTitle,interleave,method2);
xlabelStr = 'Inter-section interval';
ylabelStr = 'Thickness (nm)';
shadedErrorBar((1:numel(predictedThickness)),predictedThickness,predThickSd,color,transparent,...
    titleStr,xlabelStr,ylabelStr);
% save plot
predictionFileName = sprintf('%s_%s_%s_wErrBar',predictionFigureFileStr,subTitle,method2);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');




% save thickness in txt file
save(strcat(predictionFileName,'.dat'),'predictedThickness','-ASCII');
save(strcat(predictionFileName,'_SD','.dat'),'predThickSd','-ASCII');

% plot SD
figure;
plot(predThickSd);
titleStr = sprintf('Predicted thickness SD %s - Interleave = %d (%s interploation)',...
                    subTitle,interleave,method2);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Thickness SD (nm))');
% save
predictionFileName = sprintf('SD_%s_%s_%s',predictionFigureFileStr,subTitle,method2);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% histograms.
numBins = floor(numel(predictedThickness)/(100/(interleave+1)));
figure;hist(predictedThickness,numBins)
title(titleStr)
xlabel('Predicted thickness (nm)')
ylabel('# sections')
% save
predictionFileName = sprintf('hist_%s_%s_%s',predictionFigureFileStr,subTitle,method2);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% calculate the error, mean error and the variance
trueThickness = ones(numel(predictedThickness),1).* (outputResolution * (1+interleave));
predictionError = (trueThickness - predictedThickness)./trueThickness(1);
meanAbsPredictionError = mean(abs(predictionError));
stdPredictionError = std(predictionError);
meanSectionThickness = mean(predictedThickness);
stdSectionThickness = std(predictedThickness);

% save
predictionFileName = sprintf('NError_%s_%s_%s',predictionFigureFileStr,subTitle,method2);
predictionFileName = fullfile(outputSavePath,predictionFileName);
save(strcat(predictionFileName,'.dat'),'predictionError','-ASCII');

% plot prediction error
figure;
plot(predictionError);
titleStr = sprintf('Normalized Prediction Error %s - Interleave = %d (%s interploation)',...
                    subTitle,interleave,method2);
title(titleStr)

xlabel('Inter-section interval');
ylabel('Prediction Error');
% save
predictionFileName = sprintf('predictionError_%s_%s_%s',predictionFigureFileStr,subTitle,method2);
predictionFileName = fullfile(outputSavePath,predictionFileName);
print(predictionFileName,'-dpng');

% write to text file
statsFileName = sprintf('stats_%s_%s_%s',predictionFigureFileStr,subTitle,method2);
statsFileName = fullfile(outputSavePath,statsFileName);
statsFileName = strcat(statsFileName,'.dat'); 
fidStats = fopen(statsFileName,'w');
fprintf(fidStats,'mean abs normalized prediction error = %d \n',meanAbsPredictionError);
fprintf(fidStats,'SD of prediction error = %d \n',stdPredictionError);
fprintf(fidStats,'mean section thickness = %d \n',meanSectionThickness);
fprintf(fidStats,'SD of section thickness = %d \n',stdSectionThickness);
fclose(fidStats);



function runAllCalibrationMethodsOnVolume...
    (inputImageStackFileName,outputSavePath,params)

% almost obsolete. Refer to mainPredictThicknessOfVolume.m

% run all calibration methods for one volume and save the calibration
% curves and the predictions in the outputPath

% % calibrationMethod
% % 1 - COC/SDI/MSE/maxNCC across XY sections, along X
% % 2 - COC/SDI/MSE/maxNCC across XY sections, along Y axis
% % 3 - COC/SDI/MSE/maxNCC across ZY sections, along x axis
% % 4 - COC/SDI/MSE/maxNCC across ZY sections along Y
% % 5 - COC/SDI/MSE/maxNCC across XZ sections, along X
% % 6 - COC/SDI/MSE/maxNCC across XZ sections, along Y
% % 7 - COC/SDI/MSE/maxNCC across XY sections, along Z
% % 8 - COC/SDI/MSE/maxNCC across ZY sections, along Z
% % 9 - COC/SDI/MSE/maxNCC across XZ sections, along Z

params.predict = 0; % set to 0 if only the interpolation curve is required.
params.xyResolution = 5; % nm
params.maxShift = 40;
params.minShift = 0;
params.maxNumImages = 3; % number of sections to initiate calibration.
                % the calibration curve is the mean value obtained by all
                % these initiations
params.numPairs = 1; % number of section pairs to be used to estimate the thickness of onesection
params.plotOutput = 1;
params.suppressPlots = 1;
params.usePrecomputedCurve = 0;
params.pathToPrecomputedCurve = '';
params.imgStackFileExt = 'tif';
distanceMeasure = 'SDI';

inputImageStackFileName = '/home/thanuja/projects/data/rita/cropped_aligned/D4.tif';
outputSavePath = '/home/thanuja/projects/data/rita/distMat';

for calibrationMethod=1:9
% calibrationMethod=10;
    str1 = sprintf('Running calibration method %02d',calibrationMethod);
    disp(str1)
    thicknessEstimates = doThicknessEstimation(...
    calibrationMethod,inputImageStackFileName,outputSavePath,params,distanceMeasure);
    
end
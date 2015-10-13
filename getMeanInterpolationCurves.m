function [y,errBar,c_legendStr] = getMeanInterpolationCurves...
                        (matFilePath,fileStr,calibrationInds,distanceMeasure)

% Reads the .mat files saved in matFilePath. Each of those files should
% correspond to a different interpolation curve
% e.g. curve1 = mean(xcorrMat_1,1);
% errBar is the standard deviation of each curve
% file names should be of pattern fileStr%d.mat

% matFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/s108';
% fileStr = 'xcorrMat';

% calibrationInds - vector containing the indices of the calibration methods to be used. If empty, all are used.

% ONLY THE MAT FILES WITH THE SAME DISTANCE MEASURE WILL BE COMBINED

% % 1 - COC/SDI/MSE/maxNCC across XY sections, along X
% % 2 - COC/SDI/MSE/maxNCC across XY sections, along Y axis
% % 3 - COC/SDI/MSE/maxNCC across ZY sections, along x axis
% % 4 - COC/SDI/MSE/maxNCC across ZY sections along Y
% % 5 - COC/SDI/MSE/maxNCC across XZ sections, along X
% % 6 - COC/SDI/MSE/maxNCC across XZ sections, along Y
% % 7 - COC/SDI/MSE/maxNCC across XY sections, along Z
% % 8 - COC/SDI/MSE/maxNCC across ZY sections, along Z
% % 9 - COC/SDI/MSE/maxNCC across XZ sections, along Z

fileStr = sprintf('%s_%s',fileStr,distanceMeasure);
matFileNames = strcat(fileStr,'*.mat');
matFileNames = fullfile(matFilePath,matFileNames);

matFileDir = dir(matFileNames);

numCurves = length(matFileDir);

if(numCurves==0)
    error('No .mat files found in %s',matFilePath);
end

if(isempty(calibrationInds))
    calibrationInds = 1:numCurves;
end

c_legendStr = getCalibrationIndLegend(calibrationInds);

% load mat file to get the number of data points
load(fullfile(matFilePath,matFileDir(1).name));
numDataPoints = size(xcorrMat,2);

y = zeros(numCurves,numDataPoints);
errBar = zeros(numCurves,numDataPoints);

for i=1:numel(calibrationInds)
    load(fullfile(matFilePath,matFileDir(calibrationInds(i)).name));
    y(i,:) = mean(xcorrMat,1);
    errBar(i,:) = std(xcorrMat);
    clear xcorrMat
end

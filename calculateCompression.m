% script calculate compression
function stats = calculateCompression()

yCompRelX = 1; % calculate relative compression of Y axis wrt X. 0 for opposite.
dataPointsToUse = 20;
% k > 1 suggests that Y axis has been compressed wrt to X. 
% e.g. k=2 means Y has been compressed twice. TODO: invert k?

%% file names
% y shifted images
inputImageStackFileName = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/y/im04_yShiftedStack_sliceID1.tif';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/yUseX';
% gpModel learned for X axis
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/x/gpModel.mat';

%% thickness estimation GP
% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
[compMeanVect, compSdVect] = ...
    mainPredictThicknessOfVolumeGP...
    (inputImageStackFileName,outputSavePath,gpModelPath);

%% compression stats
meanCompression = mean(compMeanVect(1:dataPointsToUse))
sdCompression = mean(compSdVect(1:dataPointsToUse))

stats = zeros(1,2);
stats(1) = meanCompression;
stats(2) = sdCompression;

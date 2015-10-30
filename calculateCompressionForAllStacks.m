function stats = calculateCompressionForAllStacks()

yCompRelX = 1; % calculate relative compression of Y axis wrt X. 0 for opposite.
dataPointsToUse = 100;
% startImgInd = 100;
% k > 1 suggests that Y axis has been compressed wrt to X. 
% e.g. k=2 means Y has been compressed twice. TODO: invert k?
compVectAll = [];
compVectSdAll = [];
%% file names
% y shifted images
inputImageStackDirName = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShiftedStats';
% gpModel learned for X axis
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/gpModels/x/gpModel.mat';

%% thickness estimation GP
% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
inputImageStackDirContents = dir(fullfile(inputImageStackDirName,'*.tif'));
numStacks = length(inputImageStackDirContents);
for i=1:numStacks
    inputImageStackFileName = inputImageStackDirContents(i).name;
    inputImageStackFileName = fullfile(inputImageStackDirName,inputImageStackFileName)
    [compMeanVect, compSdVect] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelPath);

%     compVectAll = [compVectAll; compMeanVect(1:dataPointsToUse)];
%     compVectSdAll = [compVectSdAll; compSdVect(1:dataPointsToUse)];

    compMeanVect(end) = [];
    compSdVect(end) = [];
    
    compVectAll = [compVectAll; compMeanVect];
    compVectSdAll = [compVectSdAll; compSdVect];

end

%% compression stats
meanCompression = mean(compVectAll)
sdCompression = mean(compVectSdAll)

plot(compVectAll)

stats = zeros(1,2);
stats(1) = meanCompression;
stats(2) = sdCompression;
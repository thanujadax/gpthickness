function stats = calculateCompressionForAllStacks()

yCompRelX = 1; % calculate relative compression of Y axis wrt X. 0 for opposite.
dataPointsToUse = 100;
% startImgInd = 100;
% k > 1 suggests that Y axis has been compressed wrt to X. 
% e.g. k=2 means Y has been compressed twice. TODO: invert k?
compVectAll = [];
thickVectSdAll = [];
compVectSdAll = [];
%% file names
% y shifted images
% inputImageStackDirName = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';
inputImageStackDirName = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/yShifted500_2_new';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShiftedStats';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151102_s502_500';
% gpModel learned for X axis
% gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/gpModels/x/gpModel.mat';
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c1/gpModel.mat';
gap = 2;
%% thickness estimation GP
% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
inputImageStackDirContents = dir(fullfile(inputImageStackDirName,'*.tif'));
numStacks = length(inputImageStackDirContents);
for i=1:numStacks
    inputImageStackFileName = inputImageStackDirContents(i).name;
    inputImageStackFileName = fullfile(inputImageStackDirName,inputImageStackFileName)
    [thicknessVect, thicknessSdVect] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelPath);

    thicknessVect(end) = [];
    thicknessSdVect(end) = [];
    
    meanThickness = mean(thicknessVect) ./gap;
    compression = 1/meanThickness
    sdThickness = mean(thicknessSdVect) ./(sqrt(gap));
    sdCompression = std(1./(thicknessVect));    
    
    compVectAll = [compVectAll; compression];
    thickVectSdAll = [thickVectSdAll; sdThickness];
    compVectSdAll = [compVectSdAll; sdCompression];

end

%% compression stats
% compVectAll = 1./compVectAll;
% thickVectSdAll = 1./thickVectSdAll;
meanCompression = mean(compVectAll)
sdCompressionM = mean(compVectSdAll)

plot(compVectAll)

stats = zeros(1,2);
stats(1) = meanCompression;
stats(2) = sdCompressionM;

meanFileName = fullfile(outputSavePath,'compressionMeans.txt');
compSdFileName = fullfile(outputSavePath,'compressionSds.txt');
thicknessSdFileName = fullfile(outputSavePath,'compressionSds.txt');

save compressionMeans.txt compVectAll -ASCII;
save compressionSDs.txt thickVectSdAll -ASCII;

save(meanFileName,'compVectAll','-ASCII')
save(compSdFileName,'compVectSdAll','-ASCII')
save(thicknessSdFileName,'thicknessVectSdAll','-ASCII')
% script calculate compression
function stats = calculateCompression()
% create Y-shifted sub-stacks for the given stack
% estimate Y-shifts using Fx (Yx) and Fy (Yy)
% compression (gamma_yx) = Yy/Yx
% k < 1 suggests that Y axis has been compressed wrt to X. 
% 20160304

%% file names
% y shifted images
% inputImageStackDirName = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';
inputImageStackDirName = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/yShifted500_2_new';
outputSavePath = '/home/thanuja/projects/RESULTS/compression'; % this has to exist already
outputSubDir = 's502_20160304'; % this will be created if it doesn't exist already
% gpModel learned for X axis
% gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/gpModels/x/gpModel.mat';
gpModelXPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c1/gpModel.mat';
gpModelYPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c2/gpModel.mat';

%% Params
gap = 2;
yCompRelX = 1; % calculate relative compression of Y axis wrt X. 0 for opposite.
dataPointsToUse = 100;
% startImgInd = 100;

compVectAll = [];
thickVectSdAll = [];
compVectSdAll = [];


%% thickness estimation GP
% create output path
checkAndCreateSubDir(outputSavePath,outputSubDir);
outputSavePath = fullfile(outputSavePath,outputSubDir);

% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
inputImageStackDirContents = dir(fullfile(inputImageStackDirName,'*.tif'));
numStacks = length(inputImageStackDirContents);
for i=1:numStacks
    inputImageStackFileName = inputImageStackDirContents(i).name;
    inputImageStackFileName = fullfile(inputImageStackDirName,inputImageStackFileName);
    str1 = sprintf('Processing stack %s',inputImageStackFileName);
    disp(str1)
    
    % using f_x
    [thicknessVect_X, thicknessSdVect_X] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelXPath);

    thicknessVect_X(end) = [];
    thicknessSdVect_X(end) = [];
    
    meanThickness_x = mean(thicknessVect_X) ./gap;
    compression_x = 1/meanThickness_x;
    sdThickness_x = mean(thicknessSdVect_X) ./(sqrt(gap));
    sdCompression_x = std(1./(thicknessVect_X));    
    
    compVectAll = [compVectAll; compression_x];
    thickVectSdAll = [thickVectSdAll; sdThickness_x];
    compVectSdAll = [compVectSdAll; sdCompression_x];
    
    % using f_y
    [thicknessVect_Y, thicknessSdVect_Y] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelYPath);

    thicknessVect_Y(end) = [];
    thicknessSdVect_Y(end) = [];
    
    meanThickness_y = mean(thicknessVect_Y) ./gap;
    compression_y = 1/meanThickness_y;
    sdThickness_y = mean(thicknessSdVect_Y) ./(sqrt(gap));
    sdCompression_y = std(1./(thicknessVect_Y));    
    

end

%% compression stats
% compVectAll = 1./compVectAll;
% thickVectSdAll = 1./thickVectSdAll;
meanCompression_x = mean(compVectAll)
sdCompressionM_x = mean(compVectSdAll)

plot(compVectAll)

stats = zeros(1,2);
stats(1) = meanCompression_x;
stats(2) = sdCompressionM_x;

meanFileName = fullfile(outputSavePath,'compressionMeans.txt');
compSdFileName = fullfile(outputSavePath,'compressionSds.txt');
thicknessSdFileName = fullfile(outputSavePath,'compressionSds.txt');

save compressionMeans.txt compVectAll -ASCII;
save compressionSDs.txt thickVectSdAll -ASCII;

save(meanFileName,'compVectAll','-ASCII')
save(compSdFileName,'compVectSdAll','-ASCII')
save(thicknessSdFileName,'thicknessVectSdAll','-ASCII')

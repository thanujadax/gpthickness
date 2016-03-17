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
inputImageStackDirName = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/compression/20151030/sstem/yShifted';
% inputImageStackDirName = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/yShifted500_2_new';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShiftedStats';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151102_s502_500';
outputSavePath = '/home/thanuja/projects/RESULTS/compression/20160317_sstem/002';
% gpModel learned for X axis
gpModelXPath = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/compression/20151030/sstem/gpModels/x';
% gpModelXPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c1/gpModel.mat';
% gpModelYPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c2/gpModel.mat';

%% params
gap = 2;
gaussianSigma = 0;
gaussianMaskSize = 5;
distanceMeasure = 'SDI';
params.predict = 0; % set to 0 if only the interpolation curve is required while
% running doThicknessEstimation in runAllCalibrationMethodsOnAllVolumes. 

params.xyResolution = 5; % nm
params.maxShift = 20;
params.minShift = 0;
params.maxNumImages = 10; % number of sections to initiate calibration.
                % the calibration curve is the mean value obtained by all
                % these initiations
params.numPairs = 1; % number of section pairs to be used to estimate the thickness of onesection
params.plotOutput = 0;
params.suppressPlots = 1;
params.usePrecomputedCurve = 0;
params.pathToPrecomputedCurve = '';
params.imgStackFileExt = 'tif';

% GP estimation
startIndV = 1;  % thickness prediction starts with this image index.
% this refers to the index of the virtual stacks made out of each image.


numImagesToEstimate = 50; % how many images in the virtual stack to be estimated
%% thickness estimation GP
% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
inputImageStackDirContents = dir(fullfile(inputImageStackDirName,'*.tif'));
numStacks = length(inputImageStackDirContents);
for i=1:numStacks
    inputImageStackFileName = inputImageStackDirContents(i).name;
    inputImageStackFileName = fullfile(inputImageStackDirName,inputImageStackFileName);
    str1 = sprintf('Processing stack %s',inputImageStackFileName);
    disp(str1)
    [thicknessVect, thicknessSdVect] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelXPath,...
        params, startIndV,numImagesToEstimate,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
        % (inputImageStackFileName,outputSavePath,gpModelXPath);
    

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

% save compressionMeans.txt compVectAll -ASCII;
% save compressionSDs.txt thickVectSdAll -ASCII;

save(meanFileName,'compVectAll','-ASCII')
save(compSdFileName,'compVectSdAll','-ASCII')
save(thicknessSdFileName,'thickVectSdAll','-ASCII')
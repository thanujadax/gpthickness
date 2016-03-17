% script calculate compression
function stats = calculateCompression()
% create Y-shifted sub-stacks for the given stack. These are the inputs.
% Path for this data should be provided below
% estimate Y-shifts using Fx (Yx) and Fy (Yy)
% compression (gamma_yx) = Yy/Yx
% k < 1 suggests that Y axis has been compressed wrt to X. 
% 20160304

% Output:
% stats(1,1) = meanCompression_yx;
% stats(1,2) = sdCompressionM_yx;
% stats(2,1) = meanCompression_yy;
% stats(2,2) = sdCompressionM_yy;

%% file names
% y shifted images
% inputImageStackDirName = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';
usingXshifted = 0;
% inputImageStackDirName = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/xShifted500_2_new';
% inputImageStackDirName = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/compression/20151030/sstem/yShifted';
inputImageStackDirName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/xyShifted/yShifted';
outputSavePath = '/home/thanuja/projects/RESULTS/compression/20160317'; % this has to exist already
outputSubDir = 'sstem_drosophila_004'; % this will be created if it doesn't exist already

% gpModel learned for X axis
% gpModelXPath = '/home/thanuja/projects/RESULTS/sectionThickness/FIBSEM_20160301/s502/gpModels/SDI/s502/1';
% gpModelYPath = '/home/thanuja/projects/RESULTS/sectionThickness/FIBSEM_20160301/s502/gpModels/SDI/s502/2';

% gpModelXPath = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c1';
% gpModelYPath = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_02/c2';

gpModelXPath = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/compression/20151030/sstem/gpModels/x';
gpModelYPath = '/home/thanuja/projects/RESULTS/sectionThickness/similarityCurves/compression/20151030/sstem/gpModels/y';
%% Params
distanceMeasure = 'SDI';
gap = 2;
gaussianSigma = 0;
gaussianMaskSize = 5;

yCompRelX = 1; % calculate relative compression of Y axis wrt X. 0 for opposite.
dataPointsToUse = 100;
% startImgInd = 100;

compVectAll = [];
thickVectSdAll = [];
compVectSdAll = [];

compVectYY = [];
thickVectSdYY = [];
compVectSdYY = [];

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
interpolationMethod = 'linear'; % depricated
%% thickness estimation GP
% create output path
checkAndCreateSubDir(outputSavePath,outputSubDir);
outputSavePath = fullfile(outputSavePath,outputSubDir);

% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
inputImageStackDirContents = dir(fullfile(inputImageStackDirName,'*.tif'));
numStacks = length(inputImageStackDirContents);
compressionProfiles_yx = [];
compressionProfiles_yy = [];
for i=1:numStacks
    inputImageStackFileName = inputImageStackDirContents(i).name;
    inputImageStackFileName = fullfile(inputImageStackDirName,inputImageStackFileName);
    str1 = sprintf('Processing stack %s',inputImageStackFileName);
    disp(str1)
    
    % using f_x
    [thicknessVect_X, thicknessSdVect_X] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelXPath,...
        params, startIndV,numImagesToEstimate,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);

    thicknessVect_X(end) = [];
    thicknessSdVect_X(end) = [];
    
    meanThickness_x = mean(thicknessVect_X) ./gap;
    compressionVect_x = gap./thicknessVect_X;
    compression_x = 1/meanThickness_x;
    sdThickness_x = mean(thicknessSdVect_X) ./(sqrt(gap));
    sdCompression_x = std(1./(thicknessVect_X));    
    
    compVectAll = [compVectAll; compression_x];
    compressionProfiles_yx = [compressionProfiles_yx; compressionVect_x];
    thickVectSdAll = [thickVectSdAll; sdThickness_x];
    compVectSdAll = [compVectSdAll; sdCompression_x];
    
    % using f_y
    [thicknessVect_Y, thicknessSdVect_Y] = ...
        mainPredictThicknessOfVolumeGP...
        (inputImageStackFileName,outputSavePath,gpModelYPath,...
        params, startIndV,numImagesToEstimate,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);

    thicknessVect_Y(end) = [];
    thicknessSdVect_Y(end) = [];
    
    meanThickness_y = mean(thicknessVect_Y) ./gap;
    compressionVect_y = gap./thicknessVect_Y;
    compression_y = 1/meanThickness_y;
    sdThickness_y = mean(thicknessSdVect_Y) ./(sqrt(gap));
    sdCompression_y = std(1./(thicknessVect_Y));    

    compVectYY = [compVectYY; compression_y];
    compressionProfiles_yy = [compressionProfiles_yy; compressionVect_y];
    thickVectSdYY = [thickVectSdYY; sdThickness_y];
    compVectSdYY = [compVectSdYY; sdCompression_y];    

end

%% compression stats
% compVectAll = 1./compVectAll;
% thickVectSdAll = 1./thickVectSdAll;
meanCompression_x = mean(compVectAll)
sdCompressionM_x = mean(compVectSdAll)

meanCompression_y = mean(compVectYY)
sdCompressionM_y = mean(compVectSdYY)

figure;
plot(compVectAll)
if(usingXshifted)
    ylabel('\gamma_{xx}');
else
    ylabel('\gamma_{yx}');
end
xlabel('Inter-section interval')

figure;
plot(compVectYY)
if(usingXshifted)
    ylabel('\gamma_{xy}')
else
    ylabel('\gamma_{yy}')
end
xlabel('Inter-section interval')

stats = zeros(2,2);
stats(1,1) = meanCompression_x;
stats(1,2) = sdCompressionM_x;
stats(2,1) = meanCompression_y;
stats(2,2) = sdCompressionM_y;

if(usingXshifted)
    meanFileName_yx = fullfile(outputSavePath,'compressionMeans_xx.txt');
    compSdFileName_yx = fullfile(outputSavePath,'compressionSds_xx.txt');
    thicknessSdFileName_yx = fullfile(outputSavePath,'compressionSds_xx.txt');

    meanFileName_yy = fullfile(outputSavePath,'compressionMeans_xy.txt');
    compSdFileName_yy = fullfile(outputSavePath,'compressionSds_xy.txt');
    thicknessSdFileName_yy = fullfile(outputSavePath,'compressionSds_xy.txt');

    % save compressionMeans.txt compVectAll -ASCII;
    % save compressionSDs.txt thickVectSdAll -ASCII;
    
else
    meanFileName_yx = fullfile(outputSavePath,'compressionMeans_yx.txt');
    compSdFileName_yx = fullfile(outputSavePath,'compressionSds_yx.txt');
    thicknessSdFileName_yx = fullfile(outputSavePath,'compressionSds_yx.txt');

    meanFileName_yy = fullfile(outputSavePath,'compressionMeans_yy.txt');
    compSdFileName_yy = fullfile(outputSavePath,'compressionSds_yy.txt');
    thicknessSdFileName_yy = fullfile(outputSavePath,'compressionSds_yy.txt');

    % save compressionMeans.txt compVectAll -ASCII;
    % save compressionSDs.txt thickVectSdAll -ASCII;

end
    save(meanFileName_yx,'compVectAll','-ASCII')
    save(compSdFileName_yx,'compVectSdAll','-ASCII')
    save(thicknessSdFileName_yx,'thickVectSdAll','-ASCII')

    save(meanFileName_yy,'compVectYY','-ASCII')
    save(compSdFileName_yy,'compVectSdYY','-ASCII')
    save(thicknessSdFileName_yy,'thickVectSdYY','-ASCII')

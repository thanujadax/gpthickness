% for all tif stacks in the folder

%% create .mat distance matrices in all distance metrics for each volume in
% different subdirectories

distFileStr = 'xcorrMat'; % general string that defines the .mat file
% distanceMeasuresList = {'COC','SDI','MSE'};
distanceMeasuresList = {'SDI'};

params.predict = 0; % set to 0 if only the interpolation curve is required while
% running doThicknessEstimation in runAllCalibrationMethodsOnAllVolumes. 

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

stacksAreInSeparateSubDirs = 0; % all the stacks are in the same sub-directory

% imageStackDirectory = '/home/thanuja/projects/data/rita/cropped_aligned';
% matFilePath = '/home/thanuja/projects/data/rita/batchrun20160223/distMat';
% outputSavePath = '/home/thanuja/projects/data/rita/batchrun20160223/thicknessPredictions';
% gpModelSavePath = '/home/thanuja/projects/data/rita/batchrun20160223/gpModels';

imageStackDirectory = '/home/thanuja/projects/data/rita/cropped_rigid/D5b';
matFilePath = '/home/thanuja/projects/RESULTS/sectionThickness/ssTEM_20160229/D5b_rigid/distMat';
outputSavePath = '/home/thanuja/projects/RESULTS/sectionThickness/ssTEM_20160229/D5b_rigid/thicknessPredictions';
gpModelSavePath = '/home/thanuja/projects/RESULTS/sectionThickness/ssTEM_20160229/D5b_rigid/gpModels';

startInd = 1;
numImagesToEstimate = 3;
interpolationMethod = 'linear';


% textFile = fullfile(outputSavePath,'output.txt');
% 
runAllCalibrationMethodsOnAllVolumes...
    (imageStackDirectory,matFilePath,params,...
    stacksAreInSeparateSubDirs,distanceMeasuresList,distFileStr);

%% create gp models for each volume, each dist measure , for x and y
% separately


zDirection = 0; %?
calibrationMethods = [1 2]; % we generate GPs for x and y directions only
numImagesToUse = 3;

% for each distanceMeasure i
% for each volume j
% for each calibration method k

for i=1:length(distanceMeasuresList)
    % for this dist measure, read all the sub-dirs (volumeIDs)
    distMeasureDir = fullfile(matFilePath,char(distanceMeasuresList(i)));
    checkAndCreateSubDir(gpModelSavePath,char(distanceMeasuresList(i)));
    saveGPmodelDistDir = fullfile(gpModelSavePath,char(distanceMeasuresList(i)));
    volumeDirs = dir(distMeasureDir);
    isub = [volumeDirs(:).isdir];
    volumeDirs = {volumeDirs(isub).name}';
    volumeDirs(ismember(volumeDirs,{'.','..'})) = [];
    for j=1:length(volumeDirs)
        volMatDirFull = fullfile(distMeasureDir,char(volumeDirs(j)));
        checkAndCreateSubDir(saveGPmodelDistDir,char(volumeDirs(j)));
        saveGPModelDistVolDir = fullfile(saveGPmodelDistDir,char(volumeDirs(j)));
        % read relevant mat files cID = calibration method
        for k=1:length(calibrationMethods)
            cID = calibrationMethods(k);
            checkAndCreateSubDir(saveGPModelDistVolDir,num2str(cID));
            saveGPModelDistVolcIDDir = fullfile(saveGPModelDistVolDir,num2str(cID));
            makeGPmodelFromSimilarityData...
    (volMatDirFull,saveGPModelDistVolcIDDir,distFileStr,zDirection,cID,numImagesToUse);        
        end
    end
end

%% predict thickness for each stack using fx and fy and save results

% for each distanceMeasure i
% for each volume j
% for each calibration method k
inputFiles = strcat('*.',params.imgStackFileExt);
inputFilesFullPath = fullfile(imageStackDirectory,inputFiles);
inputFilesListing = dir(inputFilesFullPath);

% fileID = fopen(textFile,'a');

for i=1:length(distanceMeasuresList)
    % for this dist measure, read all the sub-dirs (volumeIDs)
    distMeasureDir = fullfile(matFilePath,char(distanceMeasuresList(i)));
    saveGPmodelDistDir = fullfile(gpModelSavePath,char(distanceMeasuresList(i)));
    volumeDirs = dir(distMeasureDir);
    isub = [volumeDirs(:).isdir];
    volumeDirs = {volumeDirs(isub).name}';
    volumeDirs(ismember(volumeDirs,{'.','..'})) = [];
    checkAndCreateSubDir(outputSavePath,char(distanceMeasuresList(i)));
    saveOutputDistDir = fullfile(outputSavePath,char(distanceMeasuresList(i)));
    for j=1:length(volumeDirs)
        volMatDirFull = fullfile(distMeasureDir,char(volumeDirs(j)));
        imageFileName = fullfile(imageStackDirectory,char(volumeDirs(j)));
        imageFileName = strcat(imageFileName,'.',params.imgStackFileExt);
        disp(imageFileName);
        saveGPModelDistVolDir = fullfile(saveGPmodelDistDir,char(volumeDirs(j)));
        checkAndCreateSubDir(saveOutputDistDir,char(volumeDirs(j)));
        saveOutputDistVolDir = fullfile(saveOutputDistDir,char(volumeDirs(j)));
        % read relevant mat files cID = calibration method
        for k=1:length(calibrationMethods)
            cID = calibrationMethods(k);           
            saveGPModelDistVolcIDDir = fullfile(saveGPModelDistVolDir,num2str(cID));
            checkAndCreateSubDir(saveOutputDistVolDir,num2str(cID));
            saveOutputDistVolcIDDir = fullfile(saveOutputDistVolDir,num2str(cID));
            mainPredictThicknessOfVolumeGP(imageFileName,saveOutputDistVolcIDDir,...
                saveGPModelDistVolcIDDir,params,startInd,...
                numImagesToEstimate,interpolationMethod,char(distanceMeasuresList(i)));
            
        end
    end
end
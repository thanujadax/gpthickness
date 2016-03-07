%% Input and output paths
% input image stack directory. thickness prediction is done for all .tif
% stacks available in this path
imageStackDirectory = '/home/thanuja/projects/data/rita/cropped_elastic/D4_elastic_aaa_square';
% results go here
resultsRoot = '/home/thanuja/projects/RESULTS/sectionThickness/ssTEM_20160301/';
resultsSubDir = 'D4_elastic_aaa_sq_t2';

%% GP model specifications
% Execute the startup
run('gpml/startup.m');

% Specify covariance, mean and likelihood
covfunc = containers.Map;
covfunc('SDI') = @covSEiso;   

hypsdi.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);

likfunc = containers.Map;
likfunc('SDI') = @likGauss;

hypsdi.lik = log(0.1);

meanfunc = containers.Map;
meanfunc('SDI') = {@meanProd, { {@meanConst}, {'meanPow', 5.356, {@meanLinear}} } };
hypsdi.mean = [0,1];

hyperparams = containers.Map;
hyperparams('SDI') = hypsdi;

%muConst = 1.849e-08;    sConst = ( ( (2.244e-8) - (1.455e-8) )/2)^2;     % 95% = (1.455e-08, 2.244e-08)
%muPow = 5.321;          sPow = ( (5.375 - 5.266)/2 )^2;                  % 95% = (5.266, 5.375)
%prior.mean = {{@priorGauss,muConst,sConst}; {@priorGauss,muPow,sPow}};
%inf = {@infPrior,@infExact,prior};
inf = containers.Map;
inf('SDI') = @infExact;

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

% GP model (learning)
zDirection = 0; %?
calibrationMethods = [1 2]; % we generate GPs for x and y directions only
numImagesToUse = 3;
% GP estimation
startInd = 1;  % thickness prediction starts with this image index
numImagesToEstimate = 3; % how many images in the stack to be estimated
interpolationMethod = 'linear'; % depricated

%% Create required sub directories
checkAndCreateSubDir(resultsRoot,resultsSubDir);
resultsRoot = fullfile(resultsRoot,resultsSubDir);

checkAndCreateSubDir(resultsRoot,'distMat');
matFilePath = fullfile(resultsRoot,'distMat');

checkAndCreateSubDir(resultsRoot,'thicknessPredictions');
outputSavePath = fullfile(resultsRoot,'thicknessPredictions');

checkAndCreateSubDir(resultsRoot,'gpModels');
gpModelSavePath = fullfile(resultsRoot,'gpModels');


% textFile = fullfile(outputSavePath,'output.txt');
% 
runAllCalibrationMethodsOnAllVolumes...
    (imageStackDirectory,matFilePath,params,...
    stacksAreInSeparateSubDirs,distanceMeasuresList,distFileStr);

%% create gp models for each volume, each dist measure , for x and y
% separately

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
    (volMatDirFull,saveGPModelDistVolcIDDir,distFileStr,zDirection,cID,...
    numImagesToUse,...
    covfunc(char(distanceMeasuresList(i))),...
    likfunc(char(distanceMeasuresList(i))),...
    meanfunc(char(distanceMeasuresList(i))),...
    hyperparams(char(distanceMeasuresList(i))),...
    inf(char(distanceMeasuresList(i))));        
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
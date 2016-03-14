%% Input and output paths
% input image stack directory. thickness prediction is done for all .tif
% stacks available in this path
imageStackDirectory = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/xShifted/s502xShiftedGap02_xShiftedStack_sliceID101.tif';
% results go here
resultsRoot = '/home/thanuja/projects/RESULTS/sectionThickness/FIBSEM_20160311_gauss';
resultsSubDir = 's502_sig-zero_xShifted_gap2_slice101';
dataSource = 'FIBSEM'; % options: 'FIBSEM','ssTEM','ssSEM'

%% main params
% distanceMeasuresList = {'COC','SDI','MSE'};
distanceMeasuresList = {'SDI'};
distFileStr = 'xcorrMat'; % general string that defines the .mat file

params.predict = 0; % set to 0 if only the interpolation curve is required while
% running doThicknessEstimation in runAllCalibrationMethodsOnAllVolumes. 

params.xyResolution = 5; % nm
params.maxShift = 40;
params.minShift = 0;
params.maxNumImages = 15; % number of sections to initiate calibration.
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
numImagesToUse = params.maxNumImages;
% GP estimation
startInd = 1;  % thickness prediction starts with this image index
numImagesToEstimate = 500; % how many images in the stack to be estimated

%% GP model specifications
% Execute the startup
run('gpml/startup.m');

% Specify covariance, mean and likelihood
covfuncDict = containers.Map;
covfuncDict('SDI') = @covSEiso;
covfuncDict('COC') = @covSEiso;

hypsdi.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);
hypcoc.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);

likfuncDict = containers.Map;
likfuncDict('SDI') = @likGauss;
likfuncDict('COC') = @likGauss;

hypsdi.lik = log(0.1);
hypcoc.lik = log(0.1);

if(strcmp(dataSource,'ssTEM'))
    
    hypsdi.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);
    hypcoc.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);
    
    meanfuncDict = containers.Map;
    meanfuncDict('SDI') = {@meanProd, { {@meanConst}, {'meanPow', 5.356, {@meanLinear}} } };
    meanfuncDict('COC') = {@meanSum, { {@meanConst}, ...
        { @meanProd, { {@meanConst}, {'meanPow', -0.005158, {@meanLinear}} } } } };

    hypsdi.mean = [0,1];
    hypcocm_cons1 = 4319;
    hypcocm_cons2 = -4319;
    hypcocm_lin = 1;
elseif(strcmp(dataSource,'ssSEM'))
    % untuned for ssSEM. still the same as ssTEM
    
    hypsdi.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);
    hypcoc.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);    
    
    meanfuncDict = containers.Map;
    meanfuncDict('SDI') = {@meanProd, { {@meanConst}, {'meanPow', 5.356, {@meanLinear}} } };
    meanfuncDict('COC') = {@meanSum, { {@meanConst}, ...
        { @meanProd, { {@meanConst}, {'meanPow', -0.005158, {@meanLinear}} } } } };

    hypsdi.mean = [0,1];
    hypcocm_cons1 = 4319;
    hypcocm_cons2 = -4319;
    hypcocm_lin = 1;    
elseif(strcmp(dataSource,'FIBSEM'))
    % hypsdi.cov = log([lengthParameter,SDofSignal])
    hypsdi.cov = log([20,1]);%log([1;0.1]);%log([1.9;25;10]);
    hypcoc.cov = log([10,1]);%log([1;0.1]);%log([1.9;25;10]);    
    
    meanfuncDict = containers.Map;
    meanfuncDict('SDI') = {@meanProd, { {@meanConst}, {'meanPow', 5.356, {@meanLinear}} } };
    meanfuncDict('COC') = {@meanSum, { {@meanConst}, ...
        { @meanProd, { {@meanConst}, {'meanPow', -0.005158, {@meanLinear}} } } } };

    hypsdi.mean = [1.607e-8,1];
    hypcocm_cons1 = 4319; % ssTEM
    hypcocm_cons2 = -4319; % ssTEM
    hypcocm_lin = 1; % ssTEM
else
    error('Unknown datasource!')
end


hypcocm_pow = hypcocm_lin;
hypcocm_prod = [hypcocm_cons2 hypcocm_pow];
hypcoc.mean = [hypcocm_cons1 hypcocm_prod];

%hypcoc.mean = [100,1,1];

hyperparams = containers.Map;
hyperparams('SDI') = hypsdi;
hyperparams('COC') = hypcoc;

%muConst = 1.849e-08;    sConst = ( ( (2.244e-8) - (1.455e-8) )/2)^2;     % 95% = (1.455e-08, 2.244e-08)
%muPow = 5.321;          sPow = ( (5.375 - 5.266)/2 )^2;                  % 95% = (5.266, 5.375)
%prior.mean = {{@priorGauss,muConst,sConst}; {@priorGauss,muPow,sPow}};
%inf = {@infPrior,@infExact,prior};
infDict = containers.Map;
infDict('SDI') = @infExact;
infDict('COC') = @infExact;

axisVect = containers.Map;
axisVect('SDI') = [0,inf,0,40];
axisVect('COC') = [0,1,0,40];

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
    hyp = hyperparams(char(distanceMeasuresList(i)));
    covfunc = covfuncDict(char(distanceMeasuresList(i)));
    meanfunc = meanfuncDict(char(distanceMeasuresList(i)));
    likfunc = likfuncDict(char(distanceMeasuresList(i)));
    inf = infDict(char(distanceMeasuresList(i)));
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
    numImagesToUse,covfunc,likfunc,meanfunc,hyp,inf,axisVect(char(distanceMeasuresList(i))));        
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
                numImagesToEstimate,char(distanceMeasuresList(i)));
            
        end
    end
end
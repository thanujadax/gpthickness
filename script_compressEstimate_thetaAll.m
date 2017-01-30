% main script to create compression estimates \gamma_{yx} for different
% rotated versions of the original image stack
% rotations \theta = [0,10,90]

%% input file paths and parameters
% to create shifted images
usePrecomputedStacks = 0;
usingXshifted = 0;
gap = 2; 
minShift = 0;
maxShift = 20;
saveShiftedStack = 1;

originalStackFileName = '/home/thanuja/DATA/ssSEM/20161215/tiff_blocks1/r2_c1_0_20_aligned2/r2_c1_0_20_aligned_2.tif';
dataSource = 'ssSEM'; % options: 'FIBSEM','ssTEM','ssSEM'
rotations = 0:10:60; % rotation in degrees [0 10 20 30 40]
gaussianSigma = 2; % to preprocess input image. for FIBSEM set to 0.5. ssSEM 1.5?
gaussianMaskSize = 5;

resultsRoot = '/home/thanuja/RESULTS/sectionThickness/ssSEM_70nm/r2_c1_0_20_2/orientationsTest';
resultsSubDir = '001';

distanceMeasuresList = {'SDI'};
distFileStr = 'xcorrMat'; % general string that defines the .mat file

stacksAreInSeparateSubDirs = 0; % all the stacks are in the same sub-directory

params.predict = 0; % set to 0 if only the interpolation curve is required while
% running doThicknessEstimation in runAllCalibrationMethodsOnAllVolumes. 

params.xyResolution = 5; % nm
params.maxShift = 30; % for dist curve
params.minShift = 0; % for dist curve
% for training - generating distance-dissimilarity data points
params.startInd = 1;
params.endInd = 10;
params.maxNumImages = numel(params.startInd:params.endInd); % number of sections to initiate calibration.
                % the calibration curve is the mean value obtained by all
                % these initiations
params.numPairs = 1; % number of section pairs to be used to estimate the thickness of onesection
params.plotOutput = 0;
params.suppressPlots = 1;
params.usePrecomputedCurve = 0;
params.pathToPrecomputedCurve = '';
params.imgStackFileExt = 'tif';

% GP model (learning)
zDirection = 0; %?
calibrationMethods = [1 2]; % we generate GPs for x and y directions only
numImagesToUse = params.maxNumImages;
% GP estimation
startInd = 1;  % thickness prediction starts with this image index
endInd = maxShift; % how many images in the stack to be estimated

%% Create required sub directories
gausStr = sprintf('_sig_%s',num2str(gaussianSigma));
resultsSubDir = strcat(resultsSubDir,gausStr);
checkAndCreateSubDir(resultsRoot,resultsSubDir);
resultsRoot = fullfile(resultsRoot,resultsSubDir);

%% create and save gp models for new x and y axis
% GP model specifications
% Execute the startup
run('gpml/gpmlStartup.m');

% Specify covariance, mean and likelihood
covfuncDict = containers.Map;
covfuncDict('SDI') = @covSEiso;
covfuncDict('COC') = @covSEiso;

hypsdi.cov = log([3,1]); %log([1;0.1]);%log([1.9;25;10]);
hypcoc.cov = log([1,1]); %log([1;0.1]);%log([1.9;25;10]);

likfuncDict = containers.Map;
likfuncDict('SDI') = @likGauss;
likfuncDict('COC') = @likGauss;

hypsdi.lik = log(0.1);
hypcoc.lik = log(0.1);

if(strcmp(dataSource,'ssTEM'))
    % hypsdi.cov = log([lengthParameter,SDofSignal])
    hypsdi.cov = log([10,1]);%log([1;0.1]);%log([1.9;25;10]);
    hypcoc.cov = log([1,1]);%log([1;0.1]);%log([1.9;25;10]);
    
    meanfuncDict = containers.Map;
    meanfuncDict('SDI') = {@meanProd, { {@meanConst}, {'meanPow', 5.356, {@meanLinear}} } };
    meanfuncDict('COC') = {@meanSum, { {@meanConst}, ...
        { @meanProd, { {@meanConst}, {'meanPow', 6.801, {@meanLinear}} } } } };
    % meanPow, b?

    hypsdi.mean = [0,1];
    hypcocm_cons1 = 2.193; % c
    hypcocm_cons2 = 2.31e-10; % a
    hypcocm_lin = 1;
elseif(strcmp(dataSource,'ssSEM'))
    % untuned for ssSEM. still the same as ssTEM
    
    hypsdi.cov = log([10,1]);%log([1;0.1]);%log([1.9;25;10]);
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
    hypcocm_cons1 = 4319; % ssTEM ?
    hypcocm_cons2 = -4319; % ssTEM ?
    hypcocm_lin = 1; % ssTEM ?
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
clear infDict
infDict = containers.Map;
infDict('SDI') = @infExact;
infDict('COC') = @infExact;

clear axisVect
axisVect = containers.Map;
axisVect('SDI') = [0,inf,params.minShift,params.maxShift];
axisVect('COC') = [0,1,params.minShift,params.maxShift];

for r = 1:length(rotations)
    theta = rotations(r);
    blockName = sprintf('%03d',theta);
    %% create subdirectories for saving stuff
    checkAndCreateSubDir(resultsRoot,blockName);
    resultDir = fullfile(resultsRoot,blockName);
    
    checkAndCreateSubDir(resultDir,'distMat');
    matFilePath = fullfile(resultDir,'distMat');

    checkAndCreateSubDir(resultDir,'thicknessPredictions');
    outputSavePath = fullfile(resultDir,'thicknessPredictions');

    checkAndCreateSubDir(resultDir,'gpModels');
    gpModelSavePath = fullfile(resultDir,'gpModels');

    checkAndCreateSubDir(resultDir,'rotatedImages');
    rotatedImgesSavePath = fullfile(resultDir,'rotatedImages');
    %% read image stack and rotate by t
    im_original = readTiffStackToArray(originalStackFileName)./255;
    imtest = im_original(:,:,1);
    % B = imrotate(A,angle,method,bbox) 
    % rotates image A, where bbox specifies the size of the returned image.
    im_rotated = imrotate(im_original,theta,'bilinear','crop');
    %% extract cubic block with horizontal x axis (rotated axis)
    cropSize = min(size(imtest))/sqrt(2);
    im_rot_cropped = cropImageFromCenter(im_rotated,cropSize,cropSize) .*255;
    % save rotated cropped image stack
    rotatedCroppedImgFileName = sprintf('%03d.tif',theta);
    rotatedCroppedImgFileName = fullfile(rotatedImgesSavePath,rotatedCroppedImgFileName);
    writeImageMatrixToTiffStack(im_rot_cropped,rotatedCroppedImgFileName);
    %% create and save GP models for rotated stack
    % create distance matrices
    runAllCalibrationMethodsOnAllVolumes...
    (rotatedImgesSavePath,matFilePath,params,...
    stacksAreInSeparateSubDirs,distanceMeasuresList,distFileStr,...
    calibrationMethods,gaussianSigma,gaussianMaskSize);

    for i=1:length(distanceMeasuresList)
        hyp = hyperparams(char(distanceMeasuresList(i)));
        covfunc = covfuncDict(char(distanceMeasuresList(i)));
        meanfunc = meanfuncDict(char(distanceMeasuresList(i)));
        likfunc = likfuncDict(char(distanceMeasuresList(i)));
        infe = infDict(char(distanceMeasuresList(i)));
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
        numImagesToUse,covfunc,likfunc,meanfunc,hyp,infe,axisVect(char(distanceMeasuresList(i))));        
            end
        end
    end    
    
    %% create inputs stacks of shifted images
    if(~usePrecomputedStacks)       
        checkAndCreateSubDir(rotatedImgesSavePath,'yShifted');
        yShiftedSavePath = fullfile(rotatedImgesSavePath,'yShifted');
        for imageID = 1:size(im_rot_cropped,3)
            syntheticStack = createYshiftedStack(im_rot_cropped,imageID,...
                minShift,maxShift,gap,yShiftedSavePath,'',saveShiftedStack);
        end
    end
    %% run distance (thickness) estimator to predict \gamma_{yx}
    % using all the shifted images
    gpModelXPath = fullfile(saveGPModelDistVolDir,'1');
    gpModelYPath = fullfile(saveGPModelDistVolDir,'2');
    stats = calculateCompressionFn(...
    yShiftedSavePath,outputSavePath,blockName,gpModelXPath,gpModelYPath,...
    char(distanceMeasuresList(1)),gap,gaussianSigma,gaussianMaskSize,params,...
    startInd,endInd,usingXshifted)
end
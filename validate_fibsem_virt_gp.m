function validate_fibsem_virt_gp()

% Validate using virtual FIBSEM stacks
% uses separate training images and test images
% test images are used to create X shifted and Y shifted stacks
% gpModels are generated for the training images

% still buggy. use the older version (validate2_GP instead)

%% Inputs

usingXshiftedStack = 1;
usingYshiftedStack = 1;

usingGPmodelX = 1;
usingGPmodelY = 1;

saveVirtualStack = 1;
inputImageStackDirecory = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s502';
inputImageName = 's502.tif';

subTitle = '';

resultsRoot = '/home/thanuja/projects/RESULTS/sectionThickness/20160315/fibsemValidation';
resultsSubDir = '003';

gaussianSigma = 0;
gaussianMaskSize = 5;

% to train GP models
trainStartInd = 11;
trainStopInd = 20;

% to create virtual stacks
testStartInd = 21;
testStopInd = 30;

% when predicting thickness for virtual stacks
vStartInd = 1;
vEndInd = 30;

minShift = 0;
maxShift = 40;

% change maxShift accordingly
gap = 2; % translates to the distance between 2 adjacent images in the virtual stack

dataSource = 'FIBSEM';
%% Params
% distanceMeasuresList = {'COC','SDI','MSE'};
distanceMeasuresList = {'SDI'}; % provide only one :-)
distFileStr = 'xcorrMat'; % general string that defines the .mat file

params.predict = 0; % set to 0 if only the interpolation curve is required while
% running doThicknessEstimation in runAllCalibrationMethodsOnAllVolumes. 

params.xyResolution = 5; % nm
params.maxShift = maxShift;
params.minShift = minShift;

% this is to generate the distanceMetric mat files to train the GPmodels
params.startInd = trainStartInd;
params.endInd = trainStopInd;
params.maxNumImages = numel(trainStartInd:trainStopInd); % number of sections to initiate calibration.
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
startInd = testStartInd;  % thickness prediction starts with this image index - of virtual stack
endInd = testStopInd;
numImagesToEstimate = 500; % how many images in the stack to be estimated
%% GP model
% Execute the startup
run('gpml/gpmlStartup.m');

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
axisVect('SDI') = [0,inf,minShift,maxShift];
axisVect('COC') = [0,1,minShift,maxShift];

%% create sub-directories
gausStr = sprintf('_gap_%s_sig_%s',num2str(gap),num2str(gaussianSigma));
resultsSubDir = strcat(resultsSubDir,gausStr);
checkAndCreateSubDir(resultsRoot,resultsSubDir);
resultsRoot = fullfile(resultsRoot,resultsSubDir);

checkAndCreateSubDir(resultsRoot,'distMat');
matFilePath = fullfile(resultsRoot,'distMat');

checkAndCreateSubDir(resultsRoot,'thicknessPredictions');
thicknessPredictionsSavePath = fullfile(resultsRoot,'thicknessPredictions');

checkAndCreateSubDir(resultsRoot,'gpModels');
gpModelSavePath = fullfile(resultsRoot,'gpModels');

checkAndCreateSubDir(resultsRoot,'virtStacks');
virtualStackePath = fullfile(resultsRoot,'virtStacks');

% textFile = fullfile(outputSavePath,'output.txt');
%% create data points for distance-dissimilarity curves (training data for gpModels)
runAllCalibrationMethodsOnAllVolumes...
    (inputImageStackDirecory,matFilePath,params,...
    stacksAreInSeparateSubDirs,distanceMeasuresList,distFileStr,...
    gaussianSigma,gaussianMaskSize);

%% Create GP models
cID = 1;
gpModel_1 = createGPmodel(hyperparams,covfuncDict,meanfuncDict,likfuncDict,...
    infDict,distanceMeasuresList,matFilePath,gpModelSavePath,cID,...
    distFileStr,zDirection,numImagesToUse,axisVect);

cID = 2;
gpModel_2 = createGPmodel(hyperparams,covfuncDict,meanfuncDict,likfuncDict,...
    infDict,distanceMeasuresList,matFilePath,gpModelSavePath,cID,...
    distFileStr,zDirection,numImagesToUse,axisVect);

%% create virtual stacks (test data)
inputResolution = params.xyResolution;
outputResolution = params.xyResolution;
distanceMeasure = char(distanceMeasuresList(1));

% using X shifted stacks, using gpModel_x
predictedThicknessXX = [];
predThickSdXX = [];
% using Y shifted stacks, using gpModel_y
predictedThicknessYY = [];
predThickSdYY = [];
% using X shifted stacks, using gpModel_y
predictedThicknessXY = [];
predThickSdXY = [];
% using y shifted stacks, using gpModel_x
predictedThicknessYX = [];
predThickSdYX = [];

inputImageStackFileName = fullfile(inputImageStackDirecory,inputImageName);
inputImageStack = readTiffStackToArray(inputImageStackFileName);
% gaussain blur to the input image stack
if(isempty(gaussianSigma))
    gaussianSigma = 0;
end
if(gaussianSigma>0)
    inputImageStack = gaussianFilter(inputImageStack,gaussianSigma,gaussianMaskSize);
end

% create virtual stacks and predict thickness
for imageID = testStartInd:testStopInd
    if(usingXshiftedStack)
        % prediction on unseen data - virtual stacks
        virtualStack = createXshiftedStack(inputImageStack,imageID,...
            minShift,maxShift,gap,virtualStackePath,subTitle,saveVirtualStack);
        similarityValues = calculateSimilarityForImgStack(virtualStack,...
            distanceMeasure,vStartInd,vEndInd,gaussianSigma,gaussianMaskSize);
        if(usingGPmodelX)
        [predictedThickness, predThickSd] = estimateThicknessGP(...
                similarityValues,gpModel_1,thicknessPredictionsSavePath,subTitle);
            predictedThicknessXX = [predictedThicknessXX; predictedThickness];
            predThickSdXX = [predThickSdXX; predThickSd];
        end
        if(usingGPmodelY)
        [predictedThickness, predThickSd] = estimateThicknessGP(...
                similarityValues,gpModel_2,thicknessPredictionsSavePath,subTitle);
            predictedThicknessXY = [predictedThicknessXY; predictedThickness];
            predThickSdXY = [predThickSdXY; predThickSd];
        end
    end

    if(usingYshiftedStack)
        % prediction on unseen data - virtual stacks
        virtualStack = createYshiftedStack(inputImageStack,imageID,...
            minShift,maxShift,gap,virtualStackePath,subTitle,saveVirtualStack);
        similarityValues = calculateSimilarityForImgStack(virtualStack,...
            distanceMeasure,vStartInd,vEndInd,gaussianSigma,gaussianMaskSize);
        if(usingGPmodelX)
        [predictedThickness, predThickSd] = estimateThicknessGP(...
                similarityValues,gpModel_1,thicknessPredictionsSavePath,subTitle);
            predictedThicknessYX = [predictedThicknessYX; predictedThickness];
            predThickSdYX = [predThickSdYX; predThickSd];
        end
        if(usingGPmodelY)
        [predictedThickness, predThickSd] = estimateThicknessGP(...
                similarityValues,gpModel_2,thicknessPredictionsSavePath,subTitle);
            predictedThicknessYY = [predictedThicknessYY; predictedThickness];
            predThickSdYY = [predThickSdYY; predThickSd];
        end
    end    
    
end

%% write stats

if(usingXshiftedStack)
    if(usingGPmodelX)
        predictedThicknessXX = predictedThicknessXX .* params.xyResolution;
        predThickSdXX = predThickSdXX .* params.xyResolution;
        
        mean_fileName = fullfile(thicknessPredictionsSavePath,'predMean_XX.txt');
        sd_fileName = fullfile(thicknessPredictionsSavePath,'predSD_XX.txt');
        stats_fileName = fullfile(thicknessPredictionsSavePath,'predStats_XX.txt');
        
        meanThickness = mean(predictedThicknessXX);
        SdThickness = mean(predThickSdXX);
        
        save(mean_fileName,'predictedThicknessXX','-ASCII')
        save(sd_fileName,'predThickSdXX','-ASCII')
        
        fID = fopen(stats_fileName,'w');
        fprintf(fID,'meanThickness = %6.4f\n',meanThickness);
        fprintf(fID,'SDThickness = %6.4f\n',SdThickness);
        fclose(fID);       
    end
    if(usingGPmodelY)
        predictedThicknessXY = predictedThicknessXY .* params.xyResolution;
        predThickSdXY = predThickSdXY .* params.xyResolution;
        
        mean_fileName = fullfile(thicknessPredictionsSavePath,'predMean_XY.txt');
        sd_fileName = fullfile(thicknessPredictionsSavePath,'predSD_XY.txt');
        stats_fileName = fullfile(thicknessPredictionsSavePath,'predStats_XY.txt');
        
        meanThickness = mean(predictedThicknessXY);
        SdThickness = mean(predThickSdXY);
        
        save(mean_fileName,'predictedThicknessXY','-ASCII')
        save(sd_fileName,'predThickSdXY','-ASCII')
        
        fID = fopen(stats_fileName,'w');
        fprintf(fID,'meanThickness = %6.4f\n',meanThickness);
        fprintf(fID,'SDThickness = %6.4f\n',SdThickness);
        fclose(fID);        
        
    end
end
if(usingYshiftedStack)
    if(usingGPmodelX)
        predictedThicknessYX = predictedThicknessYX .* params.xyResolution;
        predThickSdYX = predThickSdYX .* params.xyResolution;
        
        mean_fileName = fullfile(thicknessPredictionsSavePath,'predMean_YX.txt');
        sd_fileName = fullfile(thicknessPredictionsSavePath,'predSD_YX.txt');
        stats_fileName = fullfile(thicknessPredictionsSavePath,'predStats_YX.txt');
        
        meanThickness = mean(predictedThicknessYX);
        SdThickness = mean(predThickSdYX);
        
        save(mean_fileName,'predictedThicknessYX','-ASCII')
        save(sd_fileName,'predThickSdYX','-ASCII')
        
        fID = fopen(stats_fileName,'w');
        fprintf(fID,'meanThickness = %6.4f\n',meanThickness);
        fprintf(fID,'SDThickness = %6.4f\n',SdThickness);
        fclose(fID);       
    end
    if(usingGPmodelY)
        predictedThicknessYY = predictedThicknessYY .* params.xyResolution;
        predThickSdYY = predThickSdYY .* params.xyResolution;
        
        mean_fileName = fullfile(thicknessPredictionsSavePath,'predMean_YY.txt');
        sd_fileName = fullfile(thicknessPredictionsSavePath,'predSD_YY.txt');
        stats_fileName = fullfile(thicknessPredictionsSavePath,'predStats_YY.txt');
        
        meanThickness = mean(predictedThicknessYY);
        SdThickness = mean(predThickSdYY);
        
        save(mean_fileName,'predictedThicknessYY','-ASCII')
        save(sd_fileName,'predThickSdYY','-ASCII')
        
        fID = fopen(stats_fileName,'w');
        fprintf(fID,'meanThickness = %6.4f\n',meanThickness);
        fprintf(fID,'SDThickness = %6.4f\n',SdThickness);
        fclose(fID);        
        
    end
end




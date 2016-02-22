function runAllCalibrationMethodsOnAllVolumes...
    (imageStackDirectory,outputSavePath,params,...
    stacksAreInSeparateSubDirs,distanceMeasuresList,distFileStr)

% run all calibration methods for one volume and save the calibration
% curves and the predictions in the outputPath
% keep params.predict = 0 to only generate distance matrices (.mat)

%% Parameters and input arguments
% distanceMeasuresList = {'COC','SDI','MSE'};
% params.predict = 0; % set to 0 if only the interpolation curve is required.
% params.xyResolution = 5; % nm
% params.maxShift = 40;
% params.minShift = 0;
% params.maxNumImages = 3; % number of sections to initiate calibration.
%                 % the calibration curve is the mean value obtained by all
%                 % these initiations
% params.numPairs = 1; % number of section pairs to be used to estimate the thickness of onesection
% params.plotOutput = 1;
% params.suppressPlots = 1;
% params.usePrecomputedCurve = 0;
% params.pathToPrecomputedCurve = '';
% params.imgStackFileExt = 'tif';
% stacksAreInSeparateSubDirs = 0;
% imageStackDirectory = '/home/thanuja/projects/data/rita/cropped_aligned';
% outputSavePath = '/home/thanuja/projects/data/rita/batchrun20160219/thicknessPredictions';

%%
diaryFile = fullfile(outputSavePath,'log.txt');
diary(diaryFile);

if(stacksAreInSeparateSubDirs==1)
% get the list of directories
[sampleDirectories,~] = subdir(imageStackDirectory);

% get the tiff stack from each directory. some may have multiple tiff
% stacks.

    for j=1:length(distanceMeasuresList)
        % for all distance measures
        distanceMeasure = distanceMeasuresList{j};
        outputSaveDistMeasure = fullfile(outputSavePath,distanceMeasure);
        checkAndCreateSubDir(outputSavePath,distanceMeasure)
        for i=1:length(sampleDirectories)

            sampleSubDirName = sampleDirectories{i};
            % read all image stacks in this sample
            imageStackFileString = strcat('*.',params.imgStackFileExt);
            imageStackFileString = fullfile(sampleSubDirName,imageStackFileString);
            imageStackDir = dir(imageStackFileString);

        %     str1 = sprintf('Processing image stack %s',sampleSubDirName,calibrationMethod);
        %     disp(str1)    

            % process each image stack in the sample
            for k=1:length(imageStackDir)
                inputImageStackFileName = fullfile...
                    (sampleSubDirName,imageStackDir(k).name);

                tokenizedFName = strsplit(inputImageStackFileName,filesep);
                nameOfStack = strtok(tokenizedFName(end),'.');
                nameOfStack = nameOfStack{1};
                % check if subdir exists. if not create.
                checkAndCreateSubDir(outputSaveDistMeasure,nameOfStack);
                outputSavePath_i = fullfile(outputSaveDistMeasure,nameOfStack);

                % writes output to output path as txt file. Col vector.
                for calibrationMethod=1:9
                    str1 = sprintf...
                        ('Running calibration method %02d on image stack %s using distMeasure %s',calibrationMethod,sampleSubDirName,distanceMeasure);
                    disp(str1)
                    thicknessEstimates = doThicknessEstimation(...
                    calibrationMethod,inputImageStackFileName,outputSavePath_i,params,...
                    distanceMeasure,distFileStr);
                end 
                
            end    
        end

    end
else
    % read all tiff files. each tiff file is a separate volume
    inputFiles = strcat('*',params.imgStackFileExt);
    inputFilesFullPath = fullfile(imageStackDirectory,inputFiles);
    inputFilesListing = dir(inputFilesFullPath);
    
    for j=1:length(distanceMeasuresList)
        % for all distance measures
        distanceMeasure = distanceMeasuresList{j};
        outputSaveDistMeasure = fullfile(outputSavePath,distanceMeasure);
        checkAndCreateSubDir(outputSavePath,distanceMeasure);
        for i=1:length(inputFilesListing)
            sampleName = strsplit(inputFilesListing(i).name,'.');
            sampleName = sampleName(1);
            sampleName = char(sampleName);
            inputImageStackFileName = fullfile(imageStackDirectory,inputFilesListing(i).name);
            outputSavePathStack = fullfile(outputSaveDistMeasure,sampleName);
            checkAndCreateSubDir(outputSaveDistMeasure,sampleName);
            for calibrationMethod=1:9
                str1 = sprintf...
                    ('Running calibration method %02d on image stack %s using distMeasure %s',calibrationMethod,sampleName,distanceMeasure);
                disp(str1)
                thicknessEstimates = doThicknessEstimation(...
                calibrationMethod,inputImageStackFileName,outputSavePathStack,params,...
                distanceMeasure,distFileStr);
            end
                       
        end
        
    end
    
end
% save parameters for future reference
outputParamsFileName = fullfile(outputSavePath,'params.mat');
save(outputParamsFileName,'params');
diary off

function thicknessEstimates = doThicknessEstimation(...
    calibrationMethods,inputImageStackFileName,outputSavePath,params,...
    distanceMeasure)

% Performs section thickness estimation using representative
% curves to determine the distance between two (adjacent) sections
% do thickness estimation based on one of the following methods to
% calibrate the similarity curve
%
% output:
%   thicknessEstimates - column vector of thickness estimates = distance
%   between 2 adjacent sections. It will have multiple columns if
%   param.numPairs > 1. 2nd column will be the estimate using the i and
%   i+2nd image. etc.

%% Parameters
% 
% calibrationMethod = 10;
% 
% % 1 - c.o.c across XY sections, along X
% % 2 - c.o.c across XY sections, along Y axis
% % 3 - c.o.c across ZY sections, along x axis
% % 4 - c.o.c across ZY sections along Y
% % 5 - c.o.c acroxx XZ sections, along X
% % 6 - c.o.c acroxx XZ sections, along Y
% % 7 - c.o.c across XY sections, along Z
% % 8 - c.o.c across ZY sections, along Z
% % 9 - c.o.c. across XZ sections, along Z
% % 10 - SD of XY per pixel intensity difference

% % TODO: methods robust against registration problems
% 
% params.predict = 1; % set to 0 if only the interpolation curve is required.
% params.xyResolution = 5; % nm
% params.minShift = 0;
% params.maxShift = 10;
% params.maxNumImages = 60; % number of sections to initiate calibration.
%                 % the calibration curve is the mean value obtained by all
%                 % these initiations
% params.numPairs = 1; % number of section pairs to be used to estimate the thickness of onesection
% params.plotOutput = 1;
% params.usePrecomputedCurve = 0;
% params.suppressPlots = 0;
% params.pathToPrecomputedCurve = '';
% 
% inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s202/s202_1.tif';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/test';

%% 
tokenizedFName = strsplit(inputImageStackFileName,filesep);
nameOfStack = strtok(tokenizedFName(end),'.');
nameOfStack = nameOfStack{1};

if(sum(calibrationMethods == 3)>0)
    disp('Calculating c.o.c decay curve using ZY stack, along X ...')
    calibrationString = 'c.o.c ZY along X';
    calibrationFigureFileString = '01_xcorZY_X';
    xcorrMat = getXcorrZYstack(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('done!')
    % each column of xcorrMat corresponds to a sequence of shifted frames of
    % the zy plane along the x axis.
    % each row corresponds to one starting image (zy section) of the stack
    
    saveXcorrMat(nameOfStack,3,outputSavePath,xcorrMat);
    
end
if(sum(calibrationMethods == 2)>0)
    disp('Calculating c.o.c decay curve using XY images stack, along Y ...')
    calibrationString = 'c.o.c XY along Y';
    calibrationFigureFileString = '02_xcorXY_Y';
    xcorrMat = getXcorrXYstack(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('done!')    
    saveXcorrMat(nameOfStack,2,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 10)>0)
    calibrationString = 'SD of pixel intensity XY along X';
    disp('Calculating SD of intensity deviation curve using shifted XY sections stack, along X ...')
    xcorrMat = getIntensityDeviationXYstack(inputImageStackFileName,...
        params.maxShift,params.minShift,params.maxNumImages,distanceMeasure);
    disp('done!')
    calibrationFigureFileString = '03_sdpiXY_X';
    saveXcorrMat(nameOfStack,10,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 4)>0)
    calibrationString = 'c.o.c ZY along Y';
    disp('Calculating c.o.c decay curve using ZY stack, along Y ...')
    xcorrMat = getXcorrZYstackY(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done')
    calibrationFigureFileString = '04_xcorZY_Y';
    saveXcorrMat(nameOfStack,4,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 1)>0)
    calibrationString = 'c.o.c XY along X';
    disp('Calculating c.o.c decay curve using XY images stack, along X ...')
    xcorrMat = getXcorrXYstackX(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done!')    
    calibrationFigureFileString = '05_xcorXY_X';
    saveXcorrMat(nameOfStack,1,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 5)>0)
    calibrationString = 'c.o.c XZ along X';
    disp('Calculating c.o.c decay curve using XZ images stack, along X ...')
    xcorrMat = getXcorrXZstackX(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done!')    
    calibrationFigureFileString = '06_xcorXZ_X';
    saveXcorrMat(nameOfStack,5,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 6)>0)
    calibrationString = 'c.o.c XZ along Y';
    disp('Calculating c.o.c decay curve using XZ images stack, along Y ...')
    xcorrMat = getXcorrXZstackY(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done!')
    calibrationFigureFileString = '07_xcorXZ_Y';
    saveXcorrMat(nameOfStack,6,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 7)>0)
    calibrationString = 'c.o.c XY along Z';
    disp('Calculating c.o.c decay curve using XY images stack, along Z ...')
    xcorrMat = getXcorrXYstackZ(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done!')
    calibrationFigureFileString = '08_xcorXY_Z';
    saveXcorrMat(nameOfStack,7,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 8)>0)
    calibrationString = 'c.o.c ZY along Z';
    disp('Calculating c.o.c decay curve using ZY images stack, along Z ...')
    xcorrMat = getXcorrZYstackZ(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done!')
    calibrationFigureFileString = '09_xcorZY_Z';
    saveXcorrMat(nameOfStack,8,outputSavePath,xcorrMat);
end    
if(sum(calibrationMethods == 9)>0)
    calibrationString = 'c.o.c XZ along Z';
    disp('Calculating c.o.c decay curve using XZ images stack, along Z ...')
    xcorrMat = getXcorrXZstackZ(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure);
    disp('curve estimation done!')
    calibrationFigureFileString = '10_xcorXZ_Z';    
    saveXcorrMat(nameOfStack,9,outputSavePath,xcorrMat);
end
    % error('Unrecognized calibration method specified. Check calibrationMethod')


%% plot calibration curve



if(params.plotOutput && (numel(calibrationMethods)==1))
    titleStr = sprintf('Similarity curve (%d): %s. Vol %s',calibrationMethods(1),calibrationString,nameOfStack);
    title(titleStr)
    xlabelStr = 'Shifted pixels';
    if(strcmp(distanceMeasure,'maxNormalizedXcorr'))
        ylabelStr = 'Max Normalized Cross Correlation';
    else
        ylabelStr = 'Coefficient of Correlation';
    end
    transparent = 0;
    if(params.suppressPlots)
        set(gcf,'Visible','off');
    end
    shadedErrorBar((params.minShift:params.maxShift),mean(xcorrMat,1),std(xcorrMat),'g',transparent,...
        titleStr,xlabelStr,ylabelStr);
    % save calibration curve figure
    % calibrationFigureFileName = strcat(calibrationFigureFileString,'.png')
    calibrationFigureFileName = fullfile(outputSavePath,calibrationFigureFileString);
    print(calibrationFigureFileName,'-dpng');
end

% %% save calibration curve .mat
% disp('Saving xcorrMat')
% 
% matName = sprintf('xcorrMat_%s_%02d.mat',nameOfStack,calibrationMethod);
% xcorrFileName = fullfile(outputSavePath,matName);
% save(xcorrFileName,'xcorrMat')
% disp('done')

%% Predict thickness
if(params.predict && (numel(calibrationMethods)==1))
% predict section thickness for the data set
% relZresolution = predictThicknessFromCurve(...
%         inputImageStackFileName,xcorrMat,params.maxShift,calibrationMethod);
    
relZresolution = predictThicknessFromCurveFromMultiplePairs(...
        inputImageStackFileName,xcorrMat,params.minShift,params.maxShift,...
        calibrationMethods(1),params.numPairs,distanceMeasure);
% each row contains one set of estimates for all the sections. First row is
% from the images i and i+1, the second row is from images i and i+2 etc    
thicknessEstimates = relZresolution .* params.xyResolution;
%% save predicted thickness to text file
thicknessFileName = sprintf('_cm%02d_thickness.txt',calibrationMethods(1));

thicknessFileName = strcat(nameOfStack,thicknessFileName);
thicknessFileName = fullfile(outputSavePath,thicknessFileName);
thicknessEstimates = thicknessEstimates';
save(thicknessFileName,'thicknessEstimates','-ASCII');

% save also the relative thickness (not scaled by relative xy resolution)
relzFileName = sprintf('_cm%02d_relZresolution.dat',calibrationMethods(1));

relzFileName = strcat(nameOfStack,relzFileName);
relzFileName = fullfile(outputSavePath,relzFileName);
relZresolution = relZresolution';
save(relzFileName,'relZresolution','-ASCII');

%% plot output if required
if(params.plotOutput)
    if(size(thicknessEstimates,2)==1)
        figure;
        if(params.suppressPlots)
            set(gcf,'Visible','off');
        end
        plot(thicknessEstimates);
    elseif(size(thicknessEstimates,2)==2)
        figure;
        if(params.suppressPlots)
            set(gcf,'Visible','off');
        end        
        plot(thicknessEstimates(:,1),'r');
        hold on
        plot((thicknessEstimates(:,2).* 0.5),'g');
        hold off
    end
    titleStr = sprintf('Section thickness estimates. Vol: %s. Cal: %d',nameOfStack,calibrationMethods(1));
    title(titleStr);
    xlabel('Section index')
    ylabel('Estimated thickness (nm)')
end
else
    thicknessEstimates = 0;
end

function saveXcorrMat(nameOfStack,calibrationID,outputSavePath,xcorrMat)
    % save calibration curve .mat
    disp('Saving xcorrMat')

    matName = sprintf('xcorrMat_%s_%02d.mat',nameOfStack,calibrationID);
    xcorrFileName = fullfile(outputSavePath,matName);
    save(xcorrFileName,'xcorrMat')
    disp('done')

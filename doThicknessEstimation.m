function thicknessEstimates = doThicknessEstimation(...
    calibrationMethods,inputImageStackFileName,outputSavePath,params,...
    distanceMeasure,distFileStr,gaussianSigma,gaussianMaskSize)

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
%   writes thickness estimates in txt file in outpoutSavePath

%% Parameters
% 
% calibrationMethod = 10;
% 
% % 1 - COC/SDI/MSE/maxNCC across XY sections, along X
% % 2 - COC/SDI/MSE/maxNCC across XY sections, along Y axis
% % 3 - COC/SDI/MSE/maxNCC across ZY sections, along x axis
% % 4 - COC/SDI/MSE/maxNCC across ZY sections along Y
% % 5 - COC/SDI/MSE/maxNCC across XZ sections, along X
% % 6 - COC/SDI/MSE/maxNCC across XZ sections, along Y
% % 7 - COC/SDI/MSE/maxNCC across XY sections, along Z
% % 8 - COC/SDI/MSE/maxNCC across ZY sections, along Z
% % 9 - COC/SDI/MSE/maxNCC across XZ sections, along Z
% % FOLLOWING ARE DEPRICATED SINCE THE ABOVE 9 IMPLEMENT THEM ALREADY
% % 10 - SD of per pixel intensity difference - XY avg
% % 11 - SD of per pixel intensity difference - XY along X only
% % 12 - SD of per pixel intensity difference - XY along Y only
% % 13 - MSE of per pixel intensity difference - along X only
% % 14 - MSE of per pixel intensity difference - along Y only

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
    str1 = sprintf('Calculating %s decay curve using ZY stack, along X ...',distanceMeasure); 
    disp(str1)
    calibrationString = sprintf('%s ZY along X',distanceMeasure);
    calibrationFigureFileString = sprintf('03_%s_ZY_X',distanceMeasure);
    xcorrMat = getXcorrZYstack(inputImageStackFileName,params.maxShift,...
        params.minShift,params.startInd,params.endInd,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('done!')
    % each column of xcorrMat corresponds to a sequence of shifted frames of
    % the zy plane along the x axis.
    % each row corresponds to one starting image (zy section) of the stack
    
    saveXcorrMat(nameOfStack,3,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
    
end
if(sum(calibrationMethods == 2)>0)
    fprintf('Calculating %s decay curve using XY images stack, along Y ...',distanceMeasure);
    calibrationString = sprintf('%s XY along Y',distanceMeasure);
    calibrationFigureFileString = sprintf('02_%s_XY_Y',distanceMeasure);
    xcorrMat = getXcorrXYstack(inputImageStackFileName,params.maxShift,...
        params.minShift,params.startInd,params.endInd,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('done!')    
    saveXcorrMat(nameOfStack,2,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end        
if(sum(calibrationMethods == 4)>0)
    calibrationString = sprintf('%s ZY along Y',distanceMeasure);
    fprintf('Calculating %s decay curve using ZY stack, along Y ...',distanceMeasure);
    xcorrMat = getXcorrZYstackY(inputImageStackFileName,params.maxShift,...
        params.minShift,params.startInd,params.endInd,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done')
    calibrationFigureFileString = sprintf('04_%s_ZY_Y',distanceMeasure);
    saveXcorrMat(nameOfStack,4,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end    
if(sum(calibrationMethods == 1)>0)
    calibrationString = sprintf('%s XY along X',distanceMeasure);
    fprintf('Calculating %s decay curve using XY images stack, along X ...',distanceMeasure);
    xcorrMat = getXcorrXYstackX(inputImageStackFileName,params.maxShift,...
        params.minShift,params.startInd,params.endInd,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done!')    
    calibrationFigureFileString = sprintf('01_%s_XY_X',distanceMeasure);
    saveXcorrMat(nameOfStack,1,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end    
if(sum(calibrationMethods == 5)>0)
    calibrationString = sprintf('%s XZ along X',distanceMeasure);
    fprintf('Calculating %s decay curve using XZ images stack, along X ...',distanceMeasure);
    xcorrMat = getXcorrXZstackX(inputImageStackFileName,params.maxShift,...
        params.minShift,params.startInd,params.endInd,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done!')    
    calibrationFigureFileString = sprintf('05_%s_XZ_X',distanceMeasure);
    saveXcorrMat(nameOfStack,5,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end    
if(sum(calibrationMethods == 6)>0)
    calibrationString = sprintf('%s XZ along Y',distanceMeasure);
    fprintf('Calculating %s decay curve using XZ images stack, along Y ...',distanceMeasure)
    xcorrMat = getXcorrXZstackY(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done!')
    calibrationFigureFileString = sprintf('06_%s_XZ_Y',distanceMeasure);
    saveXcorrMat(nameOfStack,6,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end    
if(sum(calibrationMethods == 7)>0)
    calibrationString = sprintf('%s XY along Z',distanceMeasure);
    fprintf('Calculating %s decay curve using XY images stack, along Z ...',distanceMeasure);
    xcorrMat = getXcorrXYstackZ(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done!')
    calibrationFigureFileString = sprintf('07_%s_XY_Z',distanceMeasure);
    saveXcorrMat(nameOfStack,7,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end    
if(sum(calibrationMethods == 8)>0)
    calibrationString = sprintf('%s ZY along Z',distanceMeasure);
    fprintf('Calculating %s decay curve using ZY images stack, along Z ...',distanceMeasure)
    xcorrMat = getXcorrZYstackZ(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done!')
    calibrationFigureFileString = sprintf('08_%s_ZY_Z',distanceMeasure);
    saveXcorrMat(nameOfStack,8,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end    
if(sum(calibrationMethods == 9)>0)
    calibrationString = sprintf('%s XZ along Z',distanceMeasure);
    fprintf('Calculating %s decay curve using XZ images stack, along Z ...',distanceMeasure);
    xcorrMat = getXcorrXZstackZ(inputImageStackFileName,params.maxShift,...
        params.minShift,params.maxNumImages,distanceMeasure,...
        gaussianSigma,gaussianMaskSize);
    disp('curve estimation done!')
    calibrationFigureFileString = sprintf('09_%s_XZ_Z',distanceMeasure);    
    saveXcorrMat(nameOfStack,9,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end
if(sum(calibrationMethods == 10)>0)
    calibrationString = 'SD of pixel intensity XY along X and Y';
    disp('Calculating SD of intensity deviation curve using shifted XY sections stack, along X and Y...')
    xcorrMat = getIntensityDeviationXYstack(inputImageStackFileName,...
        params.maxShift,params.minShift,params.maxNumImages);
    disp('done!')
    calibrationFigureFileString = '10_sdpi_XY';
    saveXcorrMat(nameOfStack,10,outputSavePath,xcorrMat,distanceMeasure,distFileStr);
end
% if(sum(calibrationMethods == 11)>0)
%     calibrationString = 'SD of pixel intensity along X';
%     disp('Calculating SD of intensity deviation curve along X ...')
%     xcorrMat = getIntensityDeviationXstack(inputImageStackFileName,...
%         params.maxShift,params.minShift,params.maxNumImages);
%     disp('done!')
%     calibrationFigureFileString = '11_sdpi_X';
%     saveXcorrMat(nameOfStack,11,outputSavePath,xcorrMat,distanceMeasure);
% end
% if(sum(calibrationMethods == 12)>0)
%     calibrationString = 'SD of pixel intensity along Y';
%     disp('Calculating SD of intensity deviation curve along Y ...')
%     xcorrMat = getIntensityDeviationYstack(inputImageStackFileName,...
%         params.maxShift,params.minShift,params.maxNumImages);
%     disp('done!')
%     calibrationFigureFileString = '12_sdpi_Y';
%     saveXcorrMat(nameOfStack,12,outputSavePath,xcorrMat,distanceMeasure);
% end
% if(sum(calibrationMethods == 13)>0)
%     calibrationString = 'MSE of pixel intensity along X';
%     disp('Calculating MSE of intensity deviation curve along X ...')
%     xcorrMat = getIntensityMSE_Xstack(inputImageStackFileName,...
%         params.maxShift,params.minShift,params.maxNumImages);
%     disp('done!')
%     calibrationFigureFileString = '13_MSE_X';
%     saveXcorrMat(nameOfStack,13,outputSavePath,xcorrMat,distanceMeasure);
% end
% if(sum(calibrationMethods == 14)>0)
%     calibrationString = 'MSE of pixel intensity along Y';
%     disp('Calculating MSE of intensity deviation curve along Y ...')
%     xcorrMat = getIntensityMSE_Ystack(inputImageStackFileName,...
%         params.maxShift,params.minShift,params.maxNumImages);
%     disp('done!')
%     calibrationFigureFileString = '14_MSE_Y';
%     saveXcorrMat(nameOfStack,14,outputSavePath,xcorrMat,distanceMeasure);
% end
    % error('Unrecognized calibration method specified. Check calibrationMethod')


%% plot calibration curve
if(params.plotOutput && (numel(calibrationMethods)==1))
    titleStr = sprintf('Similarity curve %s (%d): %s. Vol %s',distanceMeasure,calibrationMethods(1),calibrationString,nameOfStack);
    title(titleStr)
    xlabelStr = 'Shifted pixels';
    ylabelStr = 'Similarity';
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

function saveXcorrMat(nameOfStack,calibrationID,outputSavePath,xcorrMat,...
    distanceMeasure,distFileStr)
    % save calibration curve .mat
    disp('Saving xcorrMat')

    matName = sprintf('%s_%s_%s_cID%02d.mat',distFileStr,distanceMeasure,nameOfStack,calibrationID);
    xcorrFileName = fullfile(outputSavePath,matName);
    save(xcorrFileName,'xcorrMat')
    disp('done')

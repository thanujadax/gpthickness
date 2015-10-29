function plotAllInterpolationCurves(outputSavePath,distanceMeasure,c_legendString)

% script to plot different calibration curves for the same volume
% outputSavePath contains all the .mat files that encodes the estimation
% curve. These files are created by doThicknessEstimation().
%% Parameters

% calibrationMethod
% % 1 - COC/SDI/MSE/maxNCC across XY sections, along X
% % 2 - COC/SDI/MSE/maxNCC across XY sections, along Y axis
% % 3 - COC/SDI/MSE/maxNCC across ZY sections, along x axis
% % 4 - COC/SDI/MSE/maxNCC across ZY sections along Y
% % 5 - COC/SDI/MSE/maxNCC across XZ sections, along X
% % 6 - COC/SDI/MSE/maxNCC across XZ sections, along Y
% % 7 - COC/SDI/MSE/maxNCC across XY sections, along Z
% % 8 - COC/SDI/MSE/maxNCC across ZY sections, along Z
% % 9 - COC/SDI/MSE/maxNCC across XZ sections, along Z

params.xyResolution = 5; % nm
params.minShift = 0;
params.maxShift = 25;
params.maxNumImages = 1; % number of sections to initiate calibration.
                % the calibration curve is the mean value obtained by all
                % these initiations
params.numPairs = 1; % number of section pairs to be used to estimate the thickness of onesection
params.plotOutput = 1;
params.usePrecomputedCurve = 1;

% distanceMeasure = 'SDI';

% distanceMeasure = 'maxNCC'; % override by the info given in xcorrDistMeas.mat file name
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013/s704/ncc';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/ellipses3_curves/y';
% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEMpng/similarity/s704/differentPos/001/rowShifted/allX';

%outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/gradientImagesGimp/xcorr/x';

calibrationInds = [];
params.pathToPrecomputedCurve = outputSavePath;

fileStr = 'xcorrMat'; % general string that defines the .mat file


tokenizedSubDirName = strsplit(outputSavePath,filesep);
tokenizedSubDirName = tokenizedSubDirName{end};

plotPredctionsFromTxt = 0;

%% Plot all interpolation curves with shaded error bars with different colors
% x
% y - C x N matrix. C is the number of curves. N is the number of samples
% errBar - vector with SD.

% figure; title('Thickness interpolation curves');
% mseb(x,y_mean,y_std);ylim([-50 150])
% legend('Line 1','Line 2','Line 3')
% figure; title('openGL');
% mseb(x,y_mean,y_std,[],1);ylim([-50 150]) 
% legend('Line 1','Line 2','Line 3')

x = 1:params.maxShift;
[y,errBar,c_legendStr] = getMeanInterpolationCurves...
                (outputSavePath,fileStr,calibrationInds,distanceMeasure);
lineProps = [];
transparent = 1;

% figure; 
% H = mseb(x,y,errBar,lineProps,transparent);
% legend('1.ZY_x','2.XY_y','4.ZY_y','5.XY_x','6.XZ_x','7.XZ_y');
% xlabel('Distance (num pixels)')
% ylabel('Coefficient of correlation')
% title('Thickness interpolation curves: s502');
%set(gca,'position',[0 0 1 1],'units','normalized')

% same plot without error bars

% errBarZero = zeros(size(errBar));
% H2 = mseb(x,y,errBarZero,lineProps,transparent);
x = params.minShift:params.maxShift;
plot(x,y','LineWidth',2.5);
% axis([XMIN XMAX YMIN YMAX])
% axis([params.minShift size(y,1) 0 max(max(y))])
%legend('1.XY_x','2.XY_y','3.ZY_x','4.ZY_y','5.XZ_x','6.XZ_y','7.XY_z','9.ZY_z','10.SD-XY_xy');
% legend('a=40,b=80','a=40,b=60','a=40,b=40');
% legend('original','compressed in y')
legend(c_legendString);
xlabel('Distance (num pixels)','FontSize',30)
ylabel('Dissimilarity','FontSize',30)
set(gca,'FontSize',25,'LineWidth',1.5)
titleStr = sprintf('Distance-Dissimilarity curves: %s',tokenizedSubDirName);
title(titleStr);
%set(gca,'position',[0 0 1 1],'units','normalized')

if(plotPredctionsFromTxt)
    %% Plot all predicted thicknesses
    predictedThickness = getPredictedThicknessesFromTxtFile(outputSavePath);
    errBarZ = zeros(size(predictedThickness));
    figure;
    % H3 = mseb([],predictedThickness,errBarZ,lineProps,transparent);
    plot(predictedThickness')
    % legend('1.XY_x','2.XY_y','3.ZY_x','4.ZY_y','5.XZ_x','6.XZ_y','7.XY_z','9.ZY_z','10.SD-XY_xy');
    legend(c_legendStr)
    xlabel('Section interval index')
    ylabel('Estimated thickness (nm)')
    titleStr = sprintf('Thickness estimates: %s',tokenizedSubDirName);
    title(titleStr);
    %set(gca,'position',[0 0 1 1],'units','normalized')
    %% Calculate variance of prediction across different methods, from the same section

end

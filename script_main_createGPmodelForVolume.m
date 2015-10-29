function script_main_createGPmodelForVolume()

% % calibrationMethod
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

matFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/xcorr';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/y';
fileStr = 'xcorrMat'; % general string that defines the .mat file
zDirection = 0; %?
calibrationMethods = [2];

numImagesToUse = 1;

makeGPmodelFromSimilarityData...
    (matFilePath,outputSavePath,fileStr,zDirection,calibrationMethods,numImagesToUse);

function script_createXYshiftedStacks()

inputImageStackFileName = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/1x8_1.png';

outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/newImages/im04/x';

subTitle = 'im04';

imageID = 1; % image in the stack to be used
shiftX = 1; % 0 to shift along Y

minShift = 0;
gap = 1;
maxShift = 25*gap;


if(shiftX)
    createXshiftedStack(inputImageStackFileName,imageID,...
        minShift,maxShift,gap,outputSavePath,subTitle)
else
    createYshiftedStack(inputImageStackFileName,imageID,...
        minShift,maxShift,gap,outputSavePath,subTitle)
end
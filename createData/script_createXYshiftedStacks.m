function script_createXYshiftedStacks()

inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s502/s502.tif';

outputSavePath = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/yShifted';
subTitle = 's502yShiftedGap15';

imageID = 101; % image in the stack to be used
shiftX = 0; % 0 to shift along Y

minShift = 0;
gap = 15;
maxShift = 35*gap;


if(shiftX)
    createXshiftedStack(inputImageStackFileName,imageID,...
        minShift,maxShift,gap,outputSavePath,subTitle)
else
    createYshiftedStack(inputImageStackFileName,imageID,...
        minShift,maxShift,gap,outputSavePath,subTitle)
end
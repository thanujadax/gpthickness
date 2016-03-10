function script_createXYshiftedStacks()

% inputImageStackFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/em_2013january/raw/09.tif';
inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s502/s502.tif';

% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';
% outputSavePath = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/yShifted500_2_new';
outputSavePath = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/xShifted500_2_new';

subTitle = '';

% imageID = 1; % image in the stack to be used
shiftX = 1; % 0 to shift along Y

minShift = 0;
gap = 2;
maxShift = 10*gap;

inputImageStack = readTiffStackToArray(inputImageStackFileName);

for i=1:500

    imageID = i;
    
    if(shiftX)
        createXshiftedStack(inputImageStack,imageID,...
            minShift,maxShift,gap,outputSavePath,subTitle)
    else
        createYshiftedStack(inputImageStack,imageID,...
            minShift,maxShift,gap,outputSavePath,subTitle)
    end

end
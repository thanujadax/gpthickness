function script_createXYshiftedStacks()

% inputImageStackFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/em_2013january/raw/09.tif';
inputImageStackFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/rawStack.tif';

% inputImageStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/largercubes/s502/s502.tif';

% outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';
% outputSavePath = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/yShifted500_2_new';
% outputSavePath = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/xShifted500_2_new';
outputSavePath = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/xyShifted/yShifted';

subTitle = 'gap02';
saveStack = 1;
numImagesToUse = 20;
% imageID = 1; % image in the stack to be used
shiftX = 0; % 0 to shift along Y

minShift = 0;
gap = 2;
maxShift = 10*gap;

inputImageStack = readTiffStackToArray(inputImageStackFileName);

[sizeR,sizeC,sizeZ] = size(inputImageStack);

if(numImagesToUse>sizeZ)
    numImagesToUse = sizeZ;
end

for i=1:numImagesToUse

    imageID = i
    
    if(shiftX)
       createXshiftedStack(inputImageStack,imageID,...
            minShift,maxShift,gap,outputSavePath,subTitle,saveStack);
    else
       createYshiftedStack(inputImageStack,imageID,...
            minShift,maxShift,gap,outputSavePath,subTitle,saveStack);
    end

end
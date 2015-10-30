function script_createXYshiftedStacks()

inputImageStackFileName = '/home/thanuja/projects/data/drosophilaLarva_ssTEM/em_2013january/raw/09.tif';

outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/compression/20151030/sstem/yShifted';

                                                            subTitle = '09';

imageID = 1; % image in the stack to be used
shiftX = 0; % 0 to shift along Y

minShift = 0;
gap = 1;
maxShift = 25*gap;

% for i=101:120

    % imageID = i;
    
    if(shiftX)
        createXshiftedStack(inputImageStackFileName,imageID,...
            minShift,maxShift,gap,outputSavePath,subTitle)
    else
        createYshiftedStack(inputImageStackFileName,imageID,...
            minShift,maxShift,gap,outputSavePath,subTitle)
    end

% end
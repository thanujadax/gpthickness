function createXshiftedStack(inputImageStackFileName,imageID,...
        minShift,maxShift,gap,outputSavePath,subTitle)
    
   
inputImageStack = readTiffStackToArray(inputImageStackFileName);

I = inputImageStack(:,:,imageID);

[numR,numC] = size(I);

numImages = numel(minShift:gap:maxShift);
syntheticStack = zeros(numR,numC-maxShift-1,numImages); 

k = 0;
for g=minShift:gap:maxShift
    A = zeros(numR,numC-maxShift-1);
    B = zeros(numR,numC-maxShift-1);
    Astart = 1 + g;
    Aend = size(I,2) - maxShift + g-1;
    Bstart = Astart + 1;
    Bend = Aend + 1;
%     Astart
%     Aend
%     Bstart
%     Bend
    A(:,:) = I(:,Astart:Aend);
    B(:,:) = I(:,Bstart:Bend);
   
    k = k+1;
    syntheticStack(:,:,k) = A(:,:);
          
end

syntheticStack(:,:,end) = B(:,:);

% saveMat
outputFileName = sprintf('%s_xShiftedStack_sliceID%0d.tif',subTitle,imageID);

outputFileName = fullfile(outputSavePath,outputFileName);
syntheticStack = syntheticStack./255;

for K=1:size(syntheticStack,3)
    imwrite(syntheticStack(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
end
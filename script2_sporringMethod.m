function script2_sporringMethod()

% inputStackFileName = '/home/thanuja/projects/data/FIBSEM_dataset/XYshiftedStacks/s502/xShifted/s502xShiftedGap02_xShiftedStack_sliceID101.tif';
inputStackFileName = '/home/thanuja/DATA/ssSEM/20161215/tiff_blocks1/r2_c1_0_20_aligned_2.tif';

imageArray = readTiffStackToArray(inputStackFileName);

[sizeR,sizeC,sizeZ] = size(imageArray);

maxG = 30; % maximum sampling distance to evaluate

maxData = sizeZ; %2?

endInd = 25;

g = zeros(sizeZ-1,1);
m12 = zeros(sizeZ-1,maxG);

imat = zeros(sizeR,sizeC,2);
for i=1:sizeZ-1
    imat(:,:,1) = imageArray(:,:,i);
    imat(:,:,2) = imageArray(:,:,i+1);
    [g(i),m12(i,:)] = estimateSamplingRatio(imat,maxG);
end

f = g .* 5;
figure;
plot(f(1:end))

% plot(g(1:maxData));

% meanG = mean(g(1:maxData)) * 5
% sdG = std(g(1:maxData)) * 5
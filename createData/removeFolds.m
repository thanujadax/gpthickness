% create validation data using the sections with folds
% read the sections
% manually identify the bounding box containing the fold
% replace this box in the sequence of images with average pix intensity of
% the image
% save the image sequence in the given location

inputPath = '/home/thanuja/projects/data/rita/folds_ssTEM_2';

inputFileName1 = 'D4-06.tif';
inputFileName2 = 'D4-07.tif';
inputFileName3 = 'D4-08.tif';

outputSavePath = '/home/thanuja/projects/data/rita/folds_removed_ssTEM2';

% Read image 2
inputFileName2_full = fullfile(inputPath,inputFileName2);
im2 = double(imread(inputFileName2_full));
im2 = im2./255;
figure;imshow(im2);title('im 2');
[sizeR2,sizeC2] = size(im2);

% Read image 1
inputFileName1_full = fullfile(inputPath,inputFileName1);
im1 = double(imread(inputFileName1_full));
im1 = im1./255;
figure;imshow(im1);title('im 1');
[sizeR1,sizeC1] = size(im1);

% Read image 3
inputFileName3_full = fullfile(inputPath,inputFileName3);
im3 = double(imread(inputFileName3_full));
im3 = im3./255;
figure;imshow(im3); title('im 1');
[sizeR3,sizeC3] = size(im3);

% calculate average pixel value
meanPixVal = mean(mean(im2));

%% define bounding box boundaries
%% mask1
bb1.x1 = 1;
bb1.y1 = 1136;

bb1.x2 = 2653;
bb1.y2 = 1;

bb1.x3 = 3070;
bb1.y3 = 1;

bb1.x4 = 1;
bb1.y4 = 1400;

x1 = [bb1.x1 bb1.x2 bb1.x3 bb1.x4];
y1 = [bb1.y1 bb1.y2 bb1.y3 bb1.y4];

mask1 = poly2mask(x1,y1,sizeR1,sizeC1);

%figure;imshow(mask1)

bb2.x1 = 0;
bb3.x1 = 0;
%% mask 2
bb2.x1 = 3080;
bb2.y1 = 2588;

bb2.x2 = 4008;
bb2.y2 = 2588;

bb2.x3 = 4008;
bb2.y3 = 2672;

bb2.x4 = 3080;
bb2.y4 = 2672;

x2 = [bb2.x1 bb2.x2 bb2.x3 bb2.x4];
y2 = [bb2.y1 bb2.y2 bb2.y3 bb2.y4];
mask2 = poly2mask(x2,y2,sizeR1,sizeC1);

%% mask 3
bb3.x1 = 0;
bb3.y1 = 0;

bb3.x2 = 0;
bb3.y2 = 0;

bb3.x3 = 0;
bb3.y3 = 0;

bb3.x4 = 0;
bb3.y4 = 0;

x3 = [bb3.x1 bb3.x2 bb3.x3 bb3.x4];
y3 = [bb3.y1 bb3.y2 bb3.y3 bb3.y4];
mask3 = poly2mask(x3,y3,sizeR1,sizeC1);

%% get bounding box
% Gaussian smoothning? At least at the boundary of the replacement patch
% replace pixel values in bounding boxes
% bb1
if(bb1.x1>0)
    im1(mask1) = meanPixVal;
    im2(mask1) = meanPixVal;
    im3(mask1) = meanPixVal;
else
    disp('bounding box 1 is zero')
end
% bb2
if(bb2.x1>0)
    im1(mask2) = meanPixVal;
    im2(mask2) = meanPixVal;
    im3(mask2) = meanPixVal;
else
    disp('bounding box 2 is zero')
end
% bb3
if(bb3.x1>0)
    im1(mask3) = meanPixVal;
    im2(mask3) = meanPixVal;
    im3(mask3) = meanPixVal;
else
    disp('bounding box 3 is zero')
end
%% save
% im 1
outputFileName1 = fullfile(outputSavePath,inputFileName1);
figure;imshow(im1)
imwrite(im1,outputFileName1,'TIFF');
% im 2
outputFileName2 = fullfile(outputSavePath,inputFileName2);
figure;imshow(im2)
imwrite(im2,outputFileName2,'TIFF');
% im 3
outputFileName3 = fullfile(outputSavePath,inputFileName3);
figure;imshow(im3)
imwrite(im3,outputFileName3,'TIFF');


% main script to create compression estimates \gamma_{yx} for different
% rotated versions of the original image stack
% rotations \theta = [0,10,90]

%% input file paths and parameters
originalStackFileName = '/home/thanuja/DATA/ssSEM/20161215/tiff_blocks1/r2_c1_0_20_aligned2/r2_c1_0_20_aligned_2.tif';
t = 30; % rotation in degrees

%% read image stack and rotate by t
im_original = double(imread(originalStackFileName));
imtest = im_original(:,:,1);
imtest = imtest./255;
figure;imshow(imtest)
% B = imrotate(A,angle,method,bbox) 
% rotates image A, where bbox specifies the size of the returned image.

im_rotated = imrotate(imtest,t,'bilinear','crop');
figure;imshow(im_rotated)
cropSize = min(size(imtest))/sqrt(2);
im_cropped = cropImageFromCenter(im_rotated,cropSize,cropSize);
figure;imshow(im_cropped)
%% extract cubic block with horizontal x axis (rotated axis)


%% create and save gp models for new x and y axis


%% create inputs stacks of shifted images


%% run distance (thickness) estimator to predict \gamma_{yx}
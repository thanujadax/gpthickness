% testing normalized cross correlation

% inputImage1
imageFileName1 = '';

image1 = imread(imageFileName1);
shiftPixels = 5;
[image1Cropped,shiftedImage1Cropped] = shiftImage(image1,shiftPixels);

xcorrImage = normxcorr2(image1Cropped,shiftedImage1Cropped);



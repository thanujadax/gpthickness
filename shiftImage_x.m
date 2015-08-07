function [image1Cropped,shiftedImage1] = shiftImage_x(image1,shiftPixels)
% shifting image along x axis to get second image
[~,sizeC] = size(image1);

shiftedImage1 = image1(:,(shiftPixels+1):sizeC);
image1Cropped = image1(:,1:(sizeC-shiftPixels));
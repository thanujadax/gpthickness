% testing normalized cross correlation

% inputImage1
imageFileName1 = '/home/thanuja/projects/data/ssSEM_dataset/testTinyTiles/80test/s108/Tile_r1-c1_Sample108_section_01_tinyTile_row09_col10.png';

image1 = imread(imageFileName1);
figure;imshow(image1)

size(image1)

shiftPixels = 5;
[image1Cropped,shiftedImage1Cropped] = shiftImage_x(image1,shiftPixels);

xcorrImage = normxcorr2(image1Cropped,shiftedImage1Cropped);
figure;imagesc(xcorrImage);title('xcorrimage')

% find the offset
[max_c,imax] = max(abs(xcorrImage(:)));
[ypeak,xpeak] = ind2sub(size(xcorrImage),imax(1));
corr_offset = [(xpeak-size(shiftedImage1Cropped,2))
    (ypeak-size(shiftedImage1Cropped,1))];
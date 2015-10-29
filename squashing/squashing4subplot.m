

im1name = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/gradientImagesGimp/4units.png';
im2name = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/gradientImagesGimp/8units.png';

distanceMeasure = 'SDI';
xpath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/gradientImagesGimp/xcorr/x';
ypath = '/home/thanuja/projects/tests/thickness/similarityCurves/squashing/gradientImagesGimp/xcorr/y';

im1 = imread(im1name);
im2 = imread(im2name);

figure()
subplot(2,2,1)
imshow(im1)
title('(a)','FontSize',25)

subplot(2,2,2)
imshow(im2)
title('(b)','FontSize',25)

subplot(2,2,3)
c_legendString = {'original','compressed in Y'};
plotAllInterpolationCurves(xpath,distanceMeasure,c_legendString);
title('(c)','FontSize',25)

subplot(2,2,4)
c_legendString = {'original','compressed in Y'};
plotAllInterpolationCurves(ypath,distanceMeasure,c_legendString);
title('(d)','FontSize',25)
function relativeDistancePix = getRelativeDistance_cc2(image1,image2,curve,maxVal,minVal)
% predicts relative section interval in terms of the pixel length in xy
% plane, using correlation coefficient
% Inputs:
% image names, curve, maxval

cc = corr2(image1,image2);

relativeDistancePix = interp1(curve,minVal:maxVal,cc);
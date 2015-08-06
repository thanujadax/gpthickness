function relativeDistancePix = getRelativeDistance_maxXcorr(image1,image2,curve,maxVal,minVal)
% predicts relative section interval in terms of the pixel length in xy
% plane, using maximum normalized cross correlation
% Inputs:
% image names, curve, maxval

xcorrMat = normxcorr2(image1,image2);

cc = max(abs(xcorrMat(:)));

relativeDistancePix = interp1(curve,minVal:maxVal,cc);
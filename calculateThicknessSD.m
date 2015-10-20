function thicknessSD = calculateThicknessSD(coc,sdSimilarityVector,...
    meanSimilarityVector,distMin,distMax,predictedThickness,method)

similaritySD = interp1((distMin:distMax-1),sdSimilarityVector,...
    predictedThickness,method);

d1 = interp1(meanSimilarityVector,(distMin:distMax-1),(coc-similaritySD),method); % unscaled
d2 = interp1(meanSimilarityVector,(distMin:distMax-1),(coc+similaritySD),method); % unscaled

if(d1<0)
    thicknessSD = d2 - predictedThickness;
else
    thicknessSD = (d2 - d1)/2;
end
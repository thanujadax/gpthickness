% script calculate compression
function k = calculateCompression()

yCompRelX = 1; % calculate relative compression of Y axis wrt X. 0 for opposite.

% k > 1 suggests that Y axis has been compressed wrt to X. 
% e.g. k=2 means Y has been compressed twice. TODO: invert k?

%% file names
% y shifted images
inputImageStackFileName = '';
outputSavePath = '';
% gpModel learned for X axis
gpModelPath = '';

%% thickness estimation GP
% returned values are unscaled thickness: predictedThickness_u, predictionSD_u
[compMeanVect, compSdVect] = ...
    mainPredictThicknessOfVolumeGP...
    (inputImageStackFileName,outputSavePath,gpModelPath);

%% compression stats
meanCompression = mean(compMeanVect);
sdCompression = mean(compSdVect);

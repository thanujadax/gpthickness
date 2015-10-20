function makeGPmodelFromSimilarityData...
    (matFilePath,outputSavePath,fileStr,zDirection,calibrationMethods)

% Inputs:
% calibrationMethods - which directions to be used for similarity curve

% Output:
% similarity-distance curve
%   x axis - similarity of a pair of images
%   y axis - distance between the pair of images

% read similarity data (all give images)
similarityDataMat = readAllMatFiles(matFilePath,fileStr,zDirection,calibrationMethods);

totNumImages = size(similarityDataMat,1);
% Sample the data (for being fast)
% select half the data
%numImgToUse = floor(totNumImages/2);
numImgToUse = 100;
vSampled = randi(length(similarityDataMat),1,numImgToUse);

% plot similarities to be used for GP
figure(), 
plot(repmat([0:1:size(similarityDataMat,2)-1]',1,numImgToUse),similarityDataMat(vSampled,:)'), ...
title('Similarities between images'), ...
xlabel('distance'), ylabel('similarity'), ...
%axis([0,size(similarityDataMat,2),0.1,1]);

% create x y values
% x - similarity values
% y - distance
vY = repmat([0:1:size(similarityDataMat,2)-1]',numImgToUse,1);
vX = reshape(similarityDataMat(vSampled,:)',1,size(similarityDataMat,2)*numImgToUse)';

% Execute the startup
run('gpml/startup.m');

% Specify covariance, mean and likelihood
covfunc = @covSEisoU;                                        
hyp.cov = rand(1);

likfunc = @likGauss; 
hyp.lik = log(0.1);

meanfunc = {@meanSum, {{'meanPow', 3, {@meanLinear}},@meanConst} };
hyp.mean = [0;0];

% Learn the hyperparameters
hyp = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, vX, vY);

% Infer the function using a gaussian process
% disp('nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)')
disp('Infering hyper-parameters for gaussian process ...')
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, vX, vY)
disp('done! ')

% Generalize to new datapoints
disp('z = linspace(0, 1, 10000)'';')
vZ = linspace(0, 1, 10000)';
disp('[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);')
[m,s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, vX, vY, vZ);

% Plot the infered function and confidence intervals
figure()
set(gca, 'FontSize', 24)
title('Similarity-Distance curve')
f = [m+2*sqrt(s2); flip(m-2*sqrt(s2),1)];
fill([vZ; flip(vZ,1)], f, [7 7 7]/8);
hold on; plot(vZ, m, 'LineWidth', 2); plot(vX, vY, '+', 'MarkerSize', 12),
% axis([0,1,0,36]),
grid on, xlabel('similarity'), ylabel('distance'); hold off;
% save plot
plotFileName = fullfile(outputSavePath,'similarity_distance_curve.svg');
print(plotFileName,'-dsvg')

% save GP model
gpModel.hyp = hyp;
gpModel.meanfunc = meanfunc;
gpModel.covfunc = covfunc;
gpModel.likfunc = likfunc;
gpModel.vX = vX;
gpModel.vY = vY;
gpFileName = fullfile(outputSavePath,'gpModel.mat');
save(gpFileName,'gpModel');
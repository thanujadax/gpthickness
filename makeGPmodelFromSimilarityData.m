function makeGPmodelFromSimilarityData...
    (matFilePath,outputSavePath,fileStr,zDirection,calibrationMethods,numImgToUse)

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
% numImgToUse = 100;
if(totNumImages>numImgToUse)
    vSampled = randi(length(similarityDataMat),1,numImgToUse);
else
    vSampled = 1:totNumImages;
end
% plot similarities to be used for GP
figure(), 
plot(repmat([0:1:size(similarityDataMat,2)-1]',1,numImgToUse),similarityDataMat(vSampled,:)'), ...
title('Dissimilarities between images'), ...
xlabel('distance (pixels)'), ylabel('dissimilarity'), ...
%axis([0,size(similarityDataMat,2),0.1,1]);

% create x y values
% x - similarity values
% y - distance
vY = repmat([0:1:size(similarityDataMat,2)-1]',numImgToUse,1);
vX = reshape(similarityDataMat(vSampled,:)',1,size(similarityDataMat,2)*numImgToUse)';

% Execute the startup
run('gpml/startup.m');

% Specify covariance, mean and likelihood
covfunc = @covSEiso;                                        
hyp.cov = log([10,1]);%log([1;0.1]);%log([1.9;25;10]);

likfunc = @likGauss; 
hyp.lik = log(0.1);

meanfunc = {@meanProd, { {@meanConst}, {'meanPow', 5.356, {@meanLinear}} } };
hyp.mean = [1.607e-8,1];

muConst = 1.849e-08;    sConst = ( ( (2.244e-8) - (1.455e-8) )/2)^2;     % 95% = (1.455e-08, 2.244e-08)
muPow = 5.321;          sPow = ( (5.375 - 5.266)/2 )^2;                  % 95% = (5.266, 5.375)
prior.mean = {{@priorGauss,muConst,sConst}; {@priorGauss,muPow,sPow}};
inf = {@infPrior,@infExact,prior};

% Learn the hyperparameters
%hyp = minimize(hyp, @gp, -500, @infExact, meanfunc, covfunc, likfunc, vX, vY)
hyp = minimize(hyp, @gp, -500, inf, meanfunc, covfunc, likfunc, vX, vY)
disp('Hyp ');
exp(hyp.cov), exp(hyp.lik)

% Infer the function using a gaussian process
disp('nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)')
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, vX, vY);
disp(' ')

% Generalize to new datapoints
disp('z = linspace(0, 1.9, 101)'';')
vZ = linspace(0, 55, 10000)';
disp('[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);')
[m s2 mu sig] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, vX, vY, vZ);

% Plot the infered function and confidence intervals
figure(2)
set(gca, 'FontSize', 24)
f = [m+3*sqrt(s2); flipdim(m-3*sqrt(s2),1)];
f2 = [mu+3*sqrt(sig); flipdim(mu-3*sqrt(sig),1)];
fill([vZ; flipdim(vZ,1)], f, [7 7 7]/8), hold on,
%fill([vZ; flipdim(vZ,1)], f2, [5 5 5]/8);
hold on; plot(vZ, m, 'Color', 'black','LineWidth', 2); plot(vX, vY, '+r', 'MarkerSize', 5), hold on,
%plot(vZ, mu, 'Color', 'black','LineWidth', 2);
axis([0,55,0,35]),
grid on, xlabel('disimilarity'), ylabel('distance (pixels)'); hold off;

% save plot
plotFileName = fullfile(outputSavePath,'dissimilarity_distance_curve.svg');
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
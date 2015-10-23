clear all;

nNumImg = 10;
xcorrMatFilePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/xcorrMat_SDI_s502_cID02.mat';
% Load data
load(xcorrMatFilePath);
mData = xcorrMat;

% Sample the data (for being fast)
vSampled = randi(length(mData),1,nNumImg);

% Plot random nNumImg similarities
figure(), 
plot(repmat([0:1:size(mData,2)-1]',1,nNumImg),mData(vSampled,:)','+'), ...
title('Dissimilarity between images'), ...
xlabel('distance (pixel units)'), ylabel('dissimilarity'), ...
axis([0,size(mData,2),0,55]);

% Execute the startup
run('gpml/startup.m');

vX = repmat([0:1:size(mData,2)-1]',nNumImg,1);
vY = reshape(mData(vSampled,:)',1,size(mData,2)*nNumImg)';

% Specify covariance, mean and likelihood
covfunc = @covSEiso;                                        
hyp.cov = [0;0];%log([1.9;25;10]);

likfunc = @likGauss; 
hyp.lik = log(0.1);

meanfunc = {@meanSum, {@meanLinear, @meanConst}};%{@meanPoly, 2}; %{@meanSum, {{'meanPow', 2 ,{@meanLinear}}, @meanConst}};
hyp.mean = [0.1,0.2];

% Learn the hyperparameters
hyp = minimize(hyp, @gp, -100, @infExact, meanfunc, covfunc, likfunc, vX, vY)

% Infer the function using a gaussian process
disp('nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y)')
nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, vX, vY)
disp(' ')

% Generalize to new datapoints
disp('z = linspace(0, 1.9, 101)'';')
vZ = linspace(0, 30, 10000)';
disp('[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, z);')
[m s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, vX, vY, vZ);

% Plot the infered function and confidence intervals
figure()
set(gca, 'FontSize', 24)
f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
fill([vZ; flipdim(vZ,1)], f, [7 7 7]/8);
hold on; plot(vZ, m, 'LineWidth', 2); plot(vX, vY, '+', 'MarkerSize', 4),
axis([0,30,0,60]),
grid on, xlabel('distance (pixel units)'), ylabel('dissimilarity'); 
title('Gaussian Process Regression with 95% confidence interval');
hold off;
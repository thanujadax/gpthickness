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
plot(mData(vSampled,:)',repmat([0:1:size(mData,2)-1]',1,nNumImg),'+'), ...
title('Similarities between images'), ...
xlabel('disimilarity'), ylabel('z section'), ...
axis([0,55,0,size(mData,2)]);

% Execute the startup
run('gpml/gpmlStartup.m');

vY = repmat([0:1:size(mData,2)-1]',nNumImg,1);
vX = reshape(mData(vSampled,:)',1,size(mData,2)*nNumImg)';

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
figure()
set(gca, 'FontSize', 24)
% f = [m+3*sqrt(s2); flipdim(m-3*sqrt(s2),1)];
f3 = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
%f2 = [mu+3*sqrt(sig); flipdim(mu-3*sqrt(sig),1)];
% fill([vZ; flipdim(vZ,1)], f, [7 7 7]/8), hold on,
fill([vZ; flipdim(vZ,1)], f3, [6 6 6]/8), hold on,
% fill([vZ; flipdim(vZ,1)], f2, [5 5 5]/8);
hold on; plot(vZ, m, 'Color', 'black','LineWidth', 2); plot(vX, vY, '+r', 'MarkerSize', 5), hold on,
%plot(vZ, mu, 'Color', 'black','LineWidth', 2);
axis([0,55,0,35]),
grid on, xlabel('disimilarity'), ylabel('distance (pixels)'); hold off;

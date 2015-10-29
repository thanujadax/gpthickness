function stats = doStats()

txtFileName = '/home/thanuja/projects/tests/thickness/similarityCurves/validation/20151027/s502XY/x/g15/mean.dat';
formatSpec = '%f';

fileID = fopen(txtFileName,'r');
predicted = fscanf(fileID,formatSpec);
fclose(fileID);

numSections = numel(predicted);

trueThickness = 75 * ones(numSections,1);

meanT = mean(predicted);

MeanSqEr = mean((trueThickness - predicted).^2);
sdOfMse = std(sqrt((trueThickness - predicted).^2));

txtFileName = '/home/thanuja/projects/tests/thickness/similarityCurves/validation/20151027/s502XY/x/g15/sd.dat';
formatSpec = '%f';

fileID = fopen(txtFileName,'r');
predictedSD = fscanf(fileID,formatSpec);
fclose(fileID);

meanSD = mean(predictedSD); 

stats = zeros(1,4);
stats(1) = meanT;
stats(2) = MeanSqEr;
stats(3) = sdOfMse;
stats(4) = meanSD;
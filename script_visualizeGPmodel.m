function script_visualizeGPmodel()

similarityValues = linspace(0,120,1000)';
gpModelPath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_01/gpModel.mat';
outputSavePath = '/home/thanuja/projects/tests/thickness/similarityCurves/FIBSEM/20151013_allVols/SDI/s502/gpEstimates_01';
volID = 's502';

gpModel = importdata(gpModelPath);

[thickness, thicknessSD] = estimateThicknessGP(...
        similarityValues,gpModel,outputSavePath,volID);
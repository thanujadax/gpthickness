function gpModel = createGPmodel(hyperparams,covfuncDict,meanfuncDict,likfuncDict,...
    infDict,distanceMeasuresList,matFilePath,gpModelSavePath,calibrationMethods,...
    distFileStr,zDirection,numImagesToUse,axisVect)

    hyp = hyperparams(char(distanceMeasuresList(1)));
    covfunc = covfuncDict(char(distanceMeasuresList(1)));
    meanfunc = meanfuncDict(char(distanceMeasuresList(1)));
    likfunc = likfuncDict(char(distanceMeasuresList(1)));
    inf = infDict(char(distanceMeasuresList(1)));
    % for this dist measure, read all the sub-dirs (volumeIDs)
    distMeasureDir = fullfile(matFilePath,char(distanceMeasuresList(1)));
    checkAndCreateSubDir(gpModelSavePath,char(distanceMeasuresList(1)));
    saveGPmodelDistDir = fullfile(gpModelSavePath,char(distanceMeasuresList(1)));
    volumeDirs = dir(distMeasureDir);
    isub = [volumeDirs(:).isdir];
    volumeDirs = {volumeDirs(isub).name}';
    volumeDirs(ismember(volumeDirs,{'.','..'})) = [];
    for j=1:length(volumeDirs)
        volMatDirFull = fullfile(distMeasureDir,char(volumeDirs(j)));
        checkAndCreateSubDir(saveGPmodelDistDir,char(volumeDirs(j)));
        saveGPModelDistVolDir = fullfile(saveGPmodelDistDir,char(volumeDirs(j)));
        % read relevant mat files cID = calibration method
        for k=1:length(calibrationMethods)
            cID = calibrationMethods(k);
            checkAndCreateSubDir(saveGPModelDistVolDir,num2str(cID));
            saveGPModelDistVolcIDDir = fullfile(saveGPModelDistVolDir,num2str(cID));
            gpModel = makeGPmodelFromSimilarityData...
    (volMatDirFull,saveGPModelDistVolcIDDir,distFileStr,zDirection,cID,...
    numImagesToUse,covfunc,likfunc,meanfunc,hyp,inf,axisVect(char(distanceMeasuresList(1))));        
        end
    end 
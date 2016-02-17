Readme.txt: sectionThickness

# First generate the .mat files containing the image similarity values
matFiles are generated by running:
runAllCalibrationMethodsOnVolume...
    (inputImageStackFileName,outputSavePath,params)

# Create GP model from these similarity matrices
makeGPmodelFromSimilarityData...
    (matFilePath,outputSavePath,fileStr,zDirection,calibrationMethods,numImgToUse)

# Predict thickness for new tiff stack
mainPredictThicknessOfVolumeGP(inputImageStackFileNAme,outputSavePath,gpModelPath)
also have to specify calibration method [1,6] as described in the comments section


Uses [GPML library](http://www.gaussianprocess.org/gpml/code/matlab/doc/)

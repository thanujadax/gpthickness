function c_calibrationIndLegend = getCalibrationIndLegend(calibrationInds)

c_calibrationIndLegend = cell(1,numel(calibrationInds));

for i=1:numel(calibrationInds)
    c_calibrationIndLegend{i} = calibrationInd2Str(calibrationInds(i));
end
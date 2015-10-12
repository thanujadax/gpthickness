function mse_intensity = getPixIntensityMSE(I1,I2)
if(size(I1)==size(I2))
    
    [~,mse_intensity,~,~] = measerr(I2,I1);
    
else
    error('I1 and I2 should have the same dimensions')
end
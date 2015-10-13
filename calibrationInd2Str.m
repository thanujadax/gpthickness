function calibrationStr = calibrationInd2Str(calibrationInd)


% % 1 - COC/SDI/MSE/maxNCC across XY sections, along X
% % 2 - COC/SDI/MSE/maxNCC across XY sections, along Y axis
% % 3 - COC/SDI/MSE/maxNCC across ZY sections, along x axis
% % 4 - COC/SDI/MSE/maxNCC across ZY sections along Y
% % 5 - COC/SDI/MSE/maxNCC across XZ sections, along X
% % 6 - COC/SDI/MSE/maxNCC across XZ sections, along Y
% % 7 - COC/SDI/MSE/maxNCC across XY sections, along Z
% % 8 - COC/SDI/MSE/maxNCC across ZY sections, along Z
% % 9 - COC/SDI/MSE/maxNCC across XZ sections, along Z

switch calibrationInd
    case 1
        calibrationStr = 'XY_x';
    case 2
        calibrationStr = 'XY_y';
    case 3
        calibrationStr = 'ZY_x';
    case 4
        calibrationStr = 'ZY_y';
    case 5
        calibrationStr = 'XZ_x';
    case 6
        calibrationStr = 'XZ_y';
    case 7
        calibrationStr = 'XY_z';
    case 8
        calibrationStr = 'ZY_z';
    case 9
        calibrationStr = 'XZ_z';
        
end
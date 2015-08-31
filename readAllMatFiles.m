function combinedMat = readAllMatFiles(matFilePath,fileStr,z,indices)

% read each matfile and combine into one
% what's the mat file structure?
%   each row corresponds to a different image
%   each column corresponds to a different distance
%   so all the mat files can be appended beneath the previous one
% indices (optional) - list of calibration methods to be used

matFileNames = strcat(fileStr,'*.mat');
matFileNames = fullfile(matFilePath,matFileNames);

matFileDir = dir(matFileNames);
TotNumCurves = length(matFileDir);

if(z)
    % along z axis. only 3 curves to be combined
    indices = [7,8,9];
    % numCurves = numel(indices); % 8,9,10
    disp('Reading .mat files ending with 08, 09 and 10 - along z axis')
    
else
    % x,y directions. i.e. 6 curves
    if(isempty(indices))
        indices = [1,2,3,4,5,6];
        % numCurves = 6; % 1,2,4,5,6,7
        disp('Reading .mat files ending with 1,2,4,5,6,7 - along x,y');
    else
        disp('Reading .mat files ending with the given list of indices')
    end
        
end

combinedMat = readMats(indices,matFilePath,matFileDir);


function mat = readMats(indices,matFilePath,matFileDir)

mat = [];
numInds = length(indices);
numMatFiles = length(matFileDir);
for i=1:numInds
    clear xcorrMat
    for j=1:numMatFiles
        % check if numInds(i) exists as part of a file name        
        str1 = strsplit((matFileDir(j).name),'cID');
        if(iscell(str1) && length(str1)==2)
            if(str2num(strtok(str1{2},'.'))==indices(i))
                load(fullfile(matFilePath,matFileDir(j).name));
                mat = [mat; xcorrMat];
                break
            end
        end
        
    end
    
end

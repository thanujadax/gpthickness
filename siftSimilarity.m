function s = siftSimilarity(I,J)
% Calculates image similarity based on SIFT features
% - Extract SIFT frames from both images
% - Get best matching pairs of key points
% - calculate the distance for each pair (up to n pairs)
% s = mean distance of each matching pair of points
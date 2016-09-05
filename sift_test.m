function sift_test()
% needs vlfeat library to be installed 
% http://www.vlfeat.org/matlab/vl_sift.html

% http://stackoverflow.com/questions/1500498/how-to-use-sift-algorithm-to-compute-how-similiar-two-images-are

I = imread('p1.jpg');
J = imread('p2.jpg');

I = single(rgb2gray(I)); % Conversion to single is recommended
J = single(rgb2gray(J)); % in the documentation

[F1 D1] = vl_sift(I);
[F2 D2] = vl_sift(J);

% Where 1.5 = ratio between euclidean distance of NN2/NN1
[matches score] = vl_ubcmatch(D1,D2,1.5); 

subplot(1,2,1);
imshow(uint8(I));
hold on;
plot(F1(1,matches(1,:)),F1(2,matches(1,:)),'b*');

subplot(1,2,2);
imshow(uint8(J));
hold on;
plot(F2(1,matches(2,:)),F2(2,matches(2,:)),'r*');
    
% vl_ubcmatch() essentially does the following:
% Suppose you have a point P in F1 and you want to find the "best" match in 
% F2. One way to do that is to compare the descriptor of P in F1 to all the 
% descriptors in D2. By compare, I mean find the Euclidean distance (or the 
% L2-norm of the difference of the two descriptors).
% Then, I find two points in F2, say U & V which have the lowest and 
% second-lowest distance (say, Du and Dv) from P respectively.
% Here's what Lowe recommended: if Dv/Du >= threshold (I used 1.5 in the 
% sample code), then this match is acceptable; otherwise, it's ambiguously 
% matched and is rejected as a correspondence and we don't match any point 
% in F2 to P. Essentially, if there's a big difference between the best and 
%     second-best matches, you can expect this to be a quality match.
% This is important since there's a lot of scope for ambiguous matches in 
% an image: imagine matching points in a lake or a building with several 
% windows, the descriptors can look very similar but the correspondence is 
% obviously wrong.
% You can do the matching in any number of ways .. you can do it yourself 
% very easily with MATLAB or you can speed it up by using a KD-tree or an 
% approximate nearest number search like FLANN which has been implemented 
% in OpenCV.


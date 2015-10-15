function circleImage = getCircles...
                (circleCenters,radius,thickness,sizeR,sizeC)
            
% inputs:
%   circleCenters - each row gives r,c coordinates of a centre of a circle
%   radius - inner radius
%   thickness - thickness of circle 
%   sizeR,sizeC

% output
%   circleImage - circles with the given specs are drawn with pix val 1

circleImage = zeros(sizeR,sizeC);

numCircles = size(circleCenters,1);

for i=1:numCircles
    circlePixels = drawThickCircle(circleCenters(i,:), radius,thickness,sizeR,sizeC);
    circleImage(circlePixels>0) = 1;
end
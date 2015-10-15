function ellipseImage = getEllipses...
                (ellipseCenters,a,b,thickness,sizeR,sizeC)
            
% inputs:
%   circleCenters - each row gives r,c coordinates of a centre of a circle
%   radius - inner radius
%   thickness - thickness of circle 
%   sizeR,sizeC

% output
%   circleImage - circles with the given specs are drawn with pix val 1

ellipseImage = zeros(sizeR,sizeC);

numEllipses = size(ellipseCenters,1);

for i=1:numEllipses
    ellipsePixels = drawThickEllipse(ellipseCenters(i,:),a,b,thickness,sizeR,sizeC);
    ellipseImage(ellipsePixels>0) = 1;
end
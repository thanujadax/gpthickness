function J = getEllipsePixels(centreRC,a,b,sizeR,sizeC)

% returns the points of the perimeter of the ellipse

rCentre = centreRC(1);
cCentre = centreRC(2);

% cMin = cCentre - radius;
% cMax = cCentre + radius;

% cVect = cMin:cMax;

% numPointsHalfC = numel(cVect);

theta = -pi:0.1:pi;
rtheta = sqrt( (b*cos(theta)).^2 + (a*sin(theta)).^2 );

% r = fix(rCentre + radius*cos(theta));
% c = fix(cCentre + radius*sin(theta));

r = rtheta .* sin(theta) + rCentre;
c = rtheta .* cos(theta) + cCentre;

%rMax = max(r);

% This will select a set of pixels that are in the circle edge. you can
% use roipoly function , as below , to get a filled circle and finally
% get its perimeter:
% J = roipoly(I,X,Y) ;
% K = bwperim(J) ;

I = zeros(sizeR,sizeC);

J = roipoly(I,c,r);


function J = getEllipsePixels(centreRC,a,b,sizeR,sizeC)

% returns the points of the perimeter of the ellipse

% rCentre = centreRC(1);
% cCentre = centreRC(2);
% 
% theta = -pi:0.1:pi;
% rtheta = sqrt( (b*cos(theta)).^2 + (a*sin(theta)).^2 );
% 
% r = rtheta .* sin(theta) + rCentre;
% c = rtheta .* cos(theta) + cCentre;
% 
% % This will select a set of pixels that are in the circle edge. you can
% % use roipoly function , as below , to get a filled circle and finally
% % get its perimeter:
% % J = roipoly(I,X,Y) ;
% % K = bwperim(J) ;
% 
% I = zeros(sizeR,sizeC);
% 
% J = roipoly(I,c,r);

% Create a logical image of an ellipse with specified
% semi-major and semi-minor axes, center, and image size.
% First create the image.

[columnsInImage,rowsInImage] = meshgrid(1:sizeC, 1:sizeR);
% Next create the ellipse in the image.
centerX = centreRC(2);
centerY = centreRC(1);
% a = 25;
% b = 150;
J = (rowsInImage - centerY).^2 ./ b^2 ...
    + (columnsInImage - centerX).^2 ./ a^2 <= 1;
% circlePixels is a 2D "logical" array.
% Now, display it.
% image(J) ;
% colormap([0 0 0; 1 1 1]);
% title('Binary image of a ellipse', 'FontSize', 20);
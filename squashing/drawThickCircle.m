function circlePixels = drawThickCircle(centreRC, innerRadius,thickness,sizeR,sizeC)

outerRadius = innerRadius + thickness;

innerCircle = getCirclePixels(centreRC,innerRadius,sizeR,sizeC);
outerCircle = getCirclePixels(centreRC,outerRadius,sizeR,sizeC);

circlePixels = zeros(sizeR,sizeC);

circlePixels(outerCircle) = 1;
circlePixels(innerCircle) = 0;


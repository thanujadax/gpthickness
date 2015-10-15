function ellipsePixels = drawThickEllipse(centreRC,a,b,thickness,sizeR,sizeC)


innerEllipse = getEllipsePixels(centreRC,a,b,sizeR,sizeC);
outerEllipse = getEllipsePixels(centreRC,(a+thickness),(b+thickness),sizeR,sizeC);

ellipsePixels = zeros(sizeR,sizeC);

ellipsePixels(outerEllipse) = 1;
ellipsePixels(innerEllipse) = 0;


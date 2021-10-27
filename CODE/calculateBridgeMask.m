function maskBridge = calculateBridgeMask(stdImage)


maxStd          = max(stdImage(:));
stdImageGray    = imfilter(rgb2gray(stdImage/maxStd),fspecial('Gaussian',15),'replicate');
stdMaskT        = 1.5*graythresh(stdImageGray);
%
stdMask1        = bwlabel(imopen( imclose( (stdImageGray>stdMaskT),strel('disk',7)),strel('disk',7)));
stdMask2        = regionprops(stdMask1,'Area');
[~,maxReg]      = max([stdMask2.Area]);
maskBridge      = ismember(stdMask1,maxReg);
maskBridgeP     = regionprops(1-maskBridge,'orientation','ConvexHull');
%imagesc(maskBridge)


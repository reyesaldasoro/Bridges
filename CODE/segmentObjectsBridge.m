function [segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks)

if nargin==1
    load('laneMasks.mat')
end
%%
%remove noise, smaller than 2x2 per lane
lowerObjects0    = imopen(currentThresholded.*laneMasks.lower,ones(1,2));
upperObjects0    = imopen(currentThresholded.*laneMasks.upper,ones(1,2));
footObjects0     = imopen(currentThresholded.*laneMasks.foot,ones(2));

[lowerObjects1,numLower]    = bwlabel(imopen(imclose(lowerObjects0,ones(8,9)),ones(3)));
[upperObjects1,numUpper]    = bwlabel(imopen(imclose(upperObjects0,ones(8,9)),ones(3)));
[footObjects1 ,numFoot]     = bwlabel(imopen(imclose(footObjects0,ones(3,2)),ones(3)));

lowerObjects                = lowerObjects1;
upperObjects                = (upperObjects1+numLower).*(upperObjects1>0);
footObjects                 = (footObjects1+numLower+numUpper).*(footObjects1>0);
%allObjects                  = bwlabel((lowerObjects1+upperObjects1+footObjects1)>0);
segmentedObjects            = lowerObjects+upperObjects+footObjects;
segmentedObjects_P          = regionprops(segmentedObjects,'Area','MajoraxisLength','MinoraxisLength','orientation','Centroid','boundingbox');
imagesc(segmentedObjects)




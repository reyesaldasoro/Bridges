function [segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks)

% if nargin==1
%     load('laneMasks.mat')
% end
%%
[rows,cols]=size(currentThresholded);
%remove noise, smaller than 2x2 per lane
lowerObjects0    = imopen(currentThresholded.*laneMasks.lower,ones(1,2));
upperObjects0    = imopen(currentThresholded.*laneMasks.upper,ones(1,2));
footObjects0     = imopen(currentThresholded.*laneMasks.foot,ones(1,2));

[lowerObjects1,numLower]    = bwlabel(imopen(imclose(lowerObjects0,ones(8,9)),ones(3)));
[upperObjects1,numUpper]    = bwlabel(imopen(imclose(upperObjects0,ones(8,9)),ones(3)));
[footObjects1 ,numFoot]     = bwlabel(imopen(imclose(footObjects0,ones(3,2)),ones(3)));

lowerObjects_P              = regionprops(lowerObjects1(:,end:-1:1),'Area','orientation','Centroid','boundingbox');
[lowerObjects2,numLower]    = bwlabel(ismember(lowerObjects1,find([lowerObjects_P.Area]>55)));
upperObjects_P              = regionprops(upperObjects1(:,end:-1:1),'Area','orientation','Centroid','boundingbox');
[upperObjects2,numUpper]    = bwlabel(ismember(upperObjects1,find([upperObjects_P.Area]>55)));



lowerObjects                = lowerObjects2;
upperObjects                = (upperObjects2+numLower).*(upperObjects2>0);
footObjects                 = (footObjects1+numLower+numUpper).*(footObjects1>0);
%allObjects                  = bwlabel((lowerObjects1+upperObjects1+footObjects1)>0);
allObjects                  = numLower+numUpper+numFoot;
segmentedObjects            = lowerObjects+upperObjects+footObjects;
segmentedObjects_P          = regionprops(segmentedObjects(:,end:-1:1),'Area','orientation','Centroid','boundingbox');


bBox                        = (reshape([segmentedObjects_P.BoundingBox],4,allObjects))';
onEdge                      = num2cell((bBox(:,1)<5)|((bBox(:,1)+bBox(:,3))>(cols-5)));

[segmentedObjects_P.onEdge] = onEdge{:};

%imagesc(segmentedObjects)




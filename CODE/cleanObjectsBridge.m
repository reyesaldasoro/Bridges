function [bboxes,scores,labels,numObjectsRemoved    ]  = cleanObjectsBridge(bboxes,scores,labels)
% This function 
%  1  removes mistaken traffic sign for person 

% with a lower threshold, there are cases where two labels are
% detected for a single object, merge
numObjectsReceived      = numel(labels);
%keepIndex               = logical(ones(size(scores)));

% The traffic light is located between rr 165:188 cc 218:224 

overlapTraffic          = abs(sum(bboxes - [216 165 10 25],2));
keepIndex1              = (overlapTraffic>10);
keepIndex2              = (labels~='person');
% remove huge objects, bboxes > 200/100
keepIndex3              = bboxes(:,3)<200;
keepIndex4              = bboxes(:,3)<100;

keepIndex               = (keepIndex1|keepIndex2)&keepIndex3&keepIndex4;

bboxes                  = bboxes(keepIndex,:);
scores                  = scores(keepIndex);
labels                  = labels(keepIndex);
numObjectsRemoved       = numObjectsReceived - numel(labels);


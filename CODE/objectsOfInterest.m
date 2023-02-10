function [bboxes,scores,labels,numObjectsRemoved]  = objectsOfInterest(bboxes,scores,labels)
% This function 
%    1 removes objects that are not of interest, 

numObjectsReceived      = numel(labels);
% remove all objects that are not of interest (umbrellas, boats, etc.)
keepIndex               = (labels=='car')|(labels=='person')|(labels=='bus')|(labels=='truck')|(labels=='motorbike');
labels                  = labels(keepIndex);
bboxes                  = bboxes(keepIndex,:);
scores                  = scores(keepIndex);
% reduce the index
%keepIndex               = logical(ones(size(scores)));
numObjectsRemoved       = numObjectsReceived - numel(labels);
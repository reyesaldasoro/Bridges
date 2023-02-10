function [bboxes,scores,labels,numObjectsRemoved    ]  = cleanOverlappingObjects(bboxes,scores,labels,rows,cols)
% This function 
%  1  detects overlapping boxes and keeps only one, checking the label
%  2  removes mistaken traffic sign for person 

% with a lower threshold, there are cases where two labels are
% detected for a single object, merge
numObjectsReceived      = numel(labels);
keepIndex               = logical(ones(size(scores)));
if size(bboxes,1)>1
    % there is overlap only if there are 2 or more objects
    [overlap,sizeROI]       = detectBoxesOverlap(bboxes,rows,cols);
    [obj1,obj2]             = ind2sub(size(overlap),find(overlap>0.35));
    for k2 = 1:numel(obj1)
        %process each overlap separately
        %disp(labels(obj1(k2)))
        %disp(labels(obj2(k2)))
        if labels(obj1(k2))==labels(obj2(k2))
            % same object, keep the first
            keepIndex(obj2(k2))   = 0;
        else
            % different objects person/motorcycle, car/truck, etc
            if      (labels(obj1(k2))=='person'&labels(obj2(k2))=='motorbike')
                % keep the motorbike
                keepIndex(obj1(k2))   = 0;
            elseif  (labels(obj2(k2))=='person'&labels(obj1(k2))=='motorbike')
                % keep the motorbike
                keepIndex(obj2(k2))   = 0;
            elseif  (labels(obj1(k2))=='car'&labels(obj2(k2))=='truck')
                % keep depending on size of the box
                if sizeROI(obj1(k2))>3000
                    % keep the truck
                    keepIndex(obj2(k2))   = 0;
                else
                    % keep the car
                    keepIndex(obj1(k2))   = 0;
                end
            elseif  (labels(obj1(k2))=='truck'&labels(obj2(k2))=='car')
                if sizeROI(obj1(k2))>3000
                    % keep the truck
                    keepIndex(obj1(k2))   = 0;
                else
                    % keep the car
                    keepIndex(obj2(k2))   = 0;
                end
            elseif  (labels(obj1(k2))=='car'&labels(obj2(k2))=='motorbike')
                % keep depending on size of the box
                if sizeROI(obj1(k2))<300
                    % keep the motorbike
                    keepIndex(obj2(k2))   = 0;
                else
                    % keep the car
                    keepIndex(obj1(k2))   = 0;
                end
            elseif  (labels(obj1(k2))=='motorbike'&labels(obj2(k2))=='car')
                if sizeROI(obj1(k2))<300
                    % keep the motorbike
                    keepIndex(obj2(k2))   = 0;
                else
                    % keep the car
                    keepIndex(obj1(k2))   = 0;
                end
            else
                % bus and truck ?
                keepIndex(obj2(k2))   = 0;
                disp(labels(obj1(k2)))
                disp(labels(obj2(k2)))
                qqq=1;
            end
        end
    end

end

bboxes                  = bboxes(keepIndex,:);
scores                  = scores(keepIndex);

numObjectsRemoved       = numObjectsReceived - numel(labels);
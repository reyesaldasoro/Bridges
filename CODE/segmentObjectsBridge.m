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

[lowerObjects1,numLower]    = bwlabel(imopen(imclose(lowerObjects0,ones(22,22)),ones(3)));
[upperObjects1,numUpper]    = bwlabel(imopen(imclose(upperObjects0,ones(22,22)),ones(3)));
% [lowerObjects1,numLower]    = bwlabel(imopen(imclose(lowerObjects0,ones(14,12)),ones(3)));
% [upperObjects1,numUpper]    = bwlabel(imopen(imclose(upperObjects0,ones(14,12)),ones(3)));
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
segmentedObjects_P          = regionprops(segmentedObjects            ,'Area','orientation','Centroid','boundingbox');
segmentedObjects_P2          = regionprops(segmentedObjects(:,end:-1:1),'Area','orientation','Centroid','boundingbox');

currCentroid                = [segmentedObjects_P.Centroid];

bBox                        = (reshape([segmentedObjects_P2.BoundingBox],4,allObjects))';
onEdge                      = num2cell((bBox(:,1)<120)|((bBox(:,1)+bBox(:,3))>(cols-200)));

[segmentedObjects_P.onEdge] = onEdge{:};
% Calibrate for position over the bridge.
% https://www.google.com/maps/place/High+Bridge+Evripos/@38.462794,23.5891122,59m/data=!3m1!1e3!4m5!3m4!1s0x14a1176be68d6a11:0x16bf37cb1c41f5f1!8m2!3d38.4448767!4d23.5908359
% approx 50 metres (from junctions) 35 metres over water
% Position starts in column 150 and finishes in 935 = 785 pixels for 50 metres
avPos                       = num2cell(50*(currCentroid(1:2:end)-150)/785);
[segmentedObjects_P.position]=avPos{:};
% Calibrate for weights
% https://cars.lovetoknow.com/List_of_Car_Weights
% https://motorgearexpert.com/how-much-does-a-motorcycle-weigh/
% CAR           Average weight 1,500 kg
% MOTORCYCLE    average weight 180 kg + 1 person = 250 kg
% PERSON        average weight 70 kg
avW = num2cell( 1500* ([segmentedObjects_P.Area]>=600) + ...
        250* (([segmentedObjects_P.Area]<600)&([segmentedObjects_P.Area]>200)) + ...
         70* ([segmentedObjects_P.Area]<200) );      
%imagesc(segmentedObjects)
[segmentedObjects_P.weight]=avW{:};



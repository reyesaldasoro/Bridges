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

 % remove objects that are close to edges
edgeFromRight               = 150;
lowerObjects_P              = regionprops(lowerObjects1(:,end:-1:1),'Area','orientation','Centroid','boundingbox');
lowerObjects_bBox           = (reshape([lowerObjects_P.BoundingBox],4,numLower))';
lowerObjects_onEdge1        = ((lowerObjects_bBox(:,1)<edgeFromRight)|((lowerObjects_bBox(:,1)+lowerObjects_bBox(:,3))>(cols-200)));

[lowerObjects2,numLower]    = bwlabel(ismember(lowerObjects1,find(  (lowerObjects_onEdge1'==0) &([lowerObjects_P.Area]>85) )));

upperObjects_P              = regionprops(upperObjects1(:,end:-1:1),'Area','orientation','Centroid','boundingbox');
upperObjects_bBox           = (reshape([upperObjects_P.BoundingBox],4,numUpper))';
upperObjects_onEdge1        = ((upperObjects_bBox(:,1)<edgeFromRight)|((upperObjects_bBox(:,1)+upperObjects_bBox(:,3))>(cols-200)));

[upperObjects2,numUpper]    = bwlabel(ismember(upperObjects1,find(   (upperObjects_onEdge1'==0)   &([upperObjects_P.Area]>85) )));

footObjects_P              = regionprops(footObjects1(:,end:-1:1),'Area','orientation','Centroid','boundingbox');
footObjects_bBox           = (reshape([footObjects_P.BoundingBox],4,numFoot))';
footObjects_onEdge1        = ((footObjects_bBox(:,1)<edgeFromRight)|((footObjects_bBox(:,1)+footObjects_bBox(:,3))>(cols-200)));

[footObjects2,numFoot]     = bwlabel(ismember(footObjects1,find(  (footObjects_onEdge1'==0) &  ([footObjects_P.Area]>35))));




% arrange so that labels correspond to position: lower>upper>foot
lowerObjects                = lowerObjects2;
upperObjects                = (upperObjects2+numLower).*(upperObjects2>0);
footObjects                 = (footObjects2+numLower+numUpper).*(footObjects2>0);
%allObjects                  = bwlabel((lowerObjects1+upperObjects1+footObjects1)>0);
allObjects                  = numLower+numUpper+numFoot;
segmentedObjects            = lowerObjects+upperObjects+footObjects;
segmentedObjects_P          = regionprops(segmentedObjects            ,'Area','orientation','Centroid','boundingbox');
segmentedObjects_P2          = regionprops(segmentedObjects(:,end:-1:1),'Area','orientation','Centroid','boundingbox');

currCentroid                = [segmentedObjects_P.Centroid];

% bBox                        = (reshape([segmentedObjects_P2.BoundingBox],4,allObjects))';
% onEdge1                      = ((bBox(:,1)<120)|((bBox(:,1)+bBox(:,3))>(cols-200)));
% onEdge                      = num2cell((bBox(:,1)<120)|((bBox(:,1)+bBox(:,3))>(cols-200)));

% Remove objects on edge
%[segmentedObjects_P.onEdge] = onEdge{:};
% Calibrate for position over the bridge.
% https://www.google.com/maps/place/High+Bridge+Evripos/@38.462794,23.5891122,59m/data=!3m1!1e3!4m5!3m4!1s0x14a1176be68d6a11:0x16bf37cb1c41f5f1!8m2!3d38.4448767!4d23.5908359
% approx 50 metres (from junctions) 35 metres over water
% Position starts in column 150 and finishes in 935 = 785 pixels for 50 metres
avPosX                        = num2cell(50*(currCentroid(1:2:end)-150)/785);
[segmentedObjects_P.positionX]=avPosX{:};
avPosY                        = num2cell(50*(currCentroid(2:2:end))/785);
[segmentedObjects_P.positionY]=avPosY{:};
% Calibrate for weights
% https://cars.lovetoknow.com/List_of_Car_Weights
% https://motorgearexpert.com/how-much-does-a-motorcycle-weigh/
% CAR           Average weight 1,500 kg
% MOTORCYCLE    average weight 180 kg + 1 person = 250 kg
% PERSON        average weight 70 kg
avW = num2cell( 1500* ([segmentedObjects_P.Area]>=400) + ...
        250* (([segmentedObjects_P.Area]<400)&([segmentedObjects_P.Area]>=170)) + ...
         70* ([segmentedObjects_P.Area]<170) );      

     
     
[segmentedObjects_P.weight]=avW{:};
for k=1:allObjects
    if avW{k}==1500
        segmentedObjects_P(k).typeObj='C';
    elseif avW{k}==250
        segmentedObjects_P(k).typeObj='M';
    elseif avW{k}==70
        segmentedObjects_P(k).typeObj='P';
    end
end

%% Remove objects in the edge (not over the bridge)
% segmentedObjects_P([segmentedObjects_P.onEdge]==1)=[];


%     currentObjects      = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).Area];
%     currentCentroids    = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).Centroid];
%     currentPosX         = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).positionX];
%     currentPosY         = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).positionY];
%     currentWeights      = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).weight];
%     currentTypeObj      = {segmentedObjects_P([segmentedObjects_P.onEdge]==0).typeObj};



%  figure(7)
%  imagesc(segmentedObjects)
%  tt=1;

function [temporalResults,temporalResults2,newOrder]  = recordObjectsBridge(bboxes,labels,currentTime,k,currentFrame,avPosX,avPosY)

% Store one row per object, in columns
% 1  X position with respect to bridge, callibrated in metres
% 2  Y  position,  Negative upper lane, positive, lower lane 
% 3  Lane, 1 going towards the right, 2 going towards the left
% 4  Time Frame  (previously weight OBSOLETE as there are labels) 
% 5  time, callibrated in seconds
% 6  label (PREVIOUSLY Bounding box area)
%    labels person =1, motorcycle =2, car =3, truck = 4, bus = 5;
% 7-9  RGB colour, 
% 10 unique tag in Frame
% 11 will be for unique tag overtime

% number of current Objects
numCurrentObjects       = size(bboxes,1);


% current lane is determined by the sign of avPosY
% negative is lane 2, positive is lane 1
currentLane             = 1.5+sign(-avPosY)/2;

%%%********* unnecessary as the labels exist, keep but later remove
% Calibrate for weights  
% https://cars.lovetoknow.com/List_of_Car_Weights
% https://motorgearexpert.com/how-much-does-a-motorcycle-weigh/
% CAR           Average weight 1,500 kg
% MOTORCYCLE    average weight 180 kg + 1 person = 250 kg
% PERSON        average weight 70 kg
% currentWeights= ( 1500* (currentBoxArea>=700) + ...
%                 250* ((currentBoxArea<700)&(currentBoxArea>=400)) + ...
%                 70*   (currentBoxArea<400) );      
%currentWeights =0;


%% Colours
[currentRGB]  = extractColourObjectsBridge(bboxes,currentFrame);


%% these are the results as returned by the detector
temporalResults             = [round(avPosX) round(avPosY) currentLane repmat([k   currentTime],[numCurrentObjects 1]) labels currentRGB];

%% Discard objects not in bridge, and order by lane and position
temporalResults1            = temporalResults;
temporalResults1            = temporalResults1(labels>0,:);

carsMovingRight             = temporalResults1(currentLane(labels>0)==1,:);
carsMovingLeft              = temporalResults1(currentLane(labels>0)==2,:);

[~,orderRight]              = sort(carsMovingRight(:,1));
[~,orderLeft]               = sort(carsMovingLeft(:,1),'descend');


carsMovingRight             = carsMovingRight(orderRight,:) ;
carsMovingLeft              = carsMovingLeft(orderLeft,:) ;
% add a tag for current car in lane not for pedestrians or motorcycles!
notPedestriansLeft          = carsMovingLeft(:,6)>2;
notPedestriansRight         = carsMovingRight(:,6)>2;

tagLeft                     = notPedestriansLeft.*(cumsum(notPedestriansLeft));
tagRight                    = notPedestriansRight.*(cumsum(notPedestriansRight));

%carsMovingRight             = [carsMovingRight(orderRight,:) tagRight(orderRight,:)];
%carsMovingLeft              = [carsMovingLeft(orderLeft,:)  -tagLeft(orderLeft,:)];
temporalResults2            = [[carsMovingRight tagRight];[carsMovingLeft -tagLeft]];
newOrder                    = [orderRight; numel(orderRight)+orderLeft];






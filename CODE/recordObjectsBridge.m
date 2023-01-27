function [temporalResults,labels2]  = recordObjectsBridge(bboxes,labels,currentTime,currentFrame)

% Store one row per object, in columns
% 1  position with respect to bridge, callibrated in metres
% 2  Lane, 1 going towards the right, 2 going towards the left
% 3  time, callibrated in seconds
% 4  weight (OBSOLETE as there are labels) 
% 5  Bounding box area, callibrated, but not really perfect, better to use
%    labels
% 6-8  RGB colour, or Hue, decide later


% number of current Objects
numCurrentObjects       = numel(labels);
% time
% currentTime             = stepBetweenFrames*k/videoHandle.FrameRate;
% Position as centre of the bounding box
currentRows             = round(bboxes(:,1)+0.5*bboxes(:,3));
currentCols             = round(bboxes(:,2)+0.5*bboxes(:,4));
currentAreas            = bboxes(:,1)+bboxes(:,3).*bboxes(:,3)+bboxes(:,4);


% to calculate position in bridge two steps are necessary,
% First rotate an angle of 12.5 so that the positions are in a horizontal
% line and the vertical can be used for the lane and the horizontals are
% the actual position. Shift also with respect to the crossing of the
% bridge just below the traffic light, start point is left of bridge,
% negative to the left and other edge of importance is 340 pixels
% Second, the bridge has perspective, so there needs to be a callibration,
% by measuring the bridge from above and from the persepective a cubic
% equation is fit

% (190,210) are the positions of the origin
posRotated =[currentRows-210 currentCols-190]*[1;1i]*exp(-1i*(-12.5)*pi/180);

rotatedCols = real(posRotated);
rotatedRows = imag(posRotated);

% current lane is determined by the sign of rotatedRows, negative is lane
% 2, positive is lane 1
currentLane  = 1.5+sign(-rotatedRows)/2;
% % determine lanes based on the mask, it matches but not necessary with
% the rotation 
% currentLane             = 3-diag(mask8(currentCols,currentRows));

% Position in X over the bridge has to be callibrated to distance from edge
% of bridge ...
% Calibrate for position over the bridge.
% https://www.google.com/maps/place/High+Bridge+Evripos/@38.462794,23.5891122,59m/data=!3m1!1e3!4m5!3m4!1s0x14a1176be68d6a11:0x16bf37cb1c41f5f1!8m2!3d38.4448767!4d23.5908359
% approx 50 metres (from junctions) 35 metres over water
% Thus measuring distances in pixels and in metres it is possible to fit a
% cubic line. To make easier measurements, images are rotated -12.5 degrees
% so that the bridge is horizontal then the parameters to fit are
xx = [0 66  234  337];
yy = [0 6.6  25   50];
p  = polyfit(xx,yy,3);

avPosX =    p(1)*rotatedCols.^3+...
            p(2)*rotatedCols.^2+...
            p(3)*rotatedCols.^1+...
            p(4);

% Vertical is less crucial so it is only scaled to the centre of the
% bridge, 65 pixels = 12 metres
% avPosY =    rotatedRows*12/65;

% Areas have to be callibrated as well

currentBoxArea =    currentAreas.*((avPosX+50).^1)/100;


%%%********* unnecessary as the labels exist, keep but later remove
% Calibrate for weights  
% https://cars.lovetoknow.com/List_of_Car_Weights
% https://motorgearexpert.com/how-much-does-a-motorcycle-weigh/
% CAR           Average weight 1,500 kg
% MOTORCYCLE    average weight 180 kg + 1 person = 250 kg
% PERSON        average weight 70 kg
currentWeights= ( 1500* (currentBoxArea>=700) + ...
                250* ((currentBoxArea<700)&(currentBoxArea>=400)) + ...
                70*   (currentBoxArea<400) );      



%% Colours
currentRGB              = zeros(numCurrentObjects,3);
for counterBox          = 1:numCurrentObjects
    rr                  = round( bboxes(counterBox,2):bboxes(counterBox,2)+bboxes(counterBox,4));
    cc                  = round(bboxes(counterBox,1):bboxes(counterBox,1)+bboxes(counterBox,3));
    currentObject       = currentFrame(rr,cc,:);
    redC                = currentObject(:,:,1);
    greenC              = currentObject(:,:,2);
    blueC               = currentObject(:,:,3);
    % calculate histograms of the channels
    [yR,xR]             = hist(redC(:),0:0.01:1);
    [yG,xG]             = hist(greenC(:),0:0.01:1);
    [yB,xB]             = hist(blueC(:),0:0.01:1);
    % dampen the regions that are present in the bridge itself
    yR(9:53)           = 0.3*yR(9:53);
    yG(9:53)           = 0.3*yG(9:53);
    yB(9:53)           = 0.3*yB(9:53);
    yR(34:45)           = 0.1*yR(34:45);
    yG(34:45)           = 0.1*yG(34:45);
    yB(34:45)           = 0.1*yB(34:45);

    [~,maxR]             = max(yR);
    [~,maxG]             = max(yG);
    [~,maxB]             = max(yB);
    currentRGB(counterBox,1:3)          =round( 255*[ maxR maxG maxB]/100);


    % extend the labels
    currLabel            = char(labels(counterBox));
    %labels2{counterBox,1}   = char(strcat(string(labels(counterBox)),', x=',num2str(round(avPosX(counterBox))),", RGB=",num2str(currentRGB(counterBox,1:3))));
    labels2{counterBox,1}   = char(strcat(currLabel(1),', x=',num2str(round(avPosX(counterBox))),", RGB=",num2str(currentRGB(counterBox,1:3))));
    labels2{counterBox,1}   = char(strcat(currLabel(1),', x=',num2str(round(avPosX(counterBox)))));
%    currentRGB(counterBox,1:3)          = 255*squeeze(mode(mode(currentObject)))';
%     figure(10+counterBox)
%     subplot(321)
%     bar(xR,yR)
%     subplot(323)
%     bar(xG,yG)
%     subplot(325)
%     bar(xB,yB)
%     subplot(122)
%     imagesc(currentObject)
% ex
end

%%
%        temporalResults2=[temporalResults2;[round(currentPosX') round(currentPosY') repmat(k/videoHandle.FrameRate,[numCurrentObjects 1]) currentWeights' ]];
temporalResults        = [round(avPosX) (currentLane) repmat(currentTime,[numCurrentObjects 1]) currentWeights currentBoxArea currentRGB ];

% % time
% temporalResults{k2,1} = stepBetweenFrames*k/videoHandle.FrameRate;
% % num Objects
% temporalResults{k2,2} = numCurrentObjects;
% %temporalResults{k2,2} = sum(1-[segmentedObjects_P.onEdge]);
% % weight
% temporalResults{k2,3} = round(currentWeights);
% % position metres from left edge
% temporalResults{k2,4} = round(currentPosX);
% temporalResults{k2,5} = round(currentPosY);
% temporalResults{k2,6} = labels;
% 
% 
% % Area
% temporalResults{k2,7} = currentObjects;
% %     % position x pixels
% temporalResults{k2,8} = currentCentroids(1:2:end);
% %     % Position y pixels
% temporalResults{k2,9} = currentCentroids(2:2:end);





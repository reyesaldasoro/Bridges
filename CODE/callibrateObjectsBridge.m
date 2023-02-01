function [avPosX,avPosY]  = callibrateObjectsBridge(bboxes)

% Callibrate positions in pixels to metres along the bridge.

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
avPosY =    rotatedRows*12/65;

% Areas have to be callibrated as well
% currentBoxArea =    currentAreas.*((avPosX+50).^1)/100;
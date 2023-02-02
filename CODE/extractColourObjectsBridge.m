function [currentRGB]  = extractColourObjectsBridge(bboxes,currentFrame)

% number of current Objects
numCurrentObjects       = size(bboxes,1);
currentRGB              = zeros(numCurrentObjects,3);
for counterBox          = 1:numCurrentObjects
    rr                  = round(bboxes(counterBox,2):bboxes(counterBox,2)+bboxes(counterBox,4));
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
end


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
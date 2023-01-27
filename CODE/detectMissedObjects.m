function  MissedInFrame              = detectMissedObjects(currentFrame,medImagesum,bboxes,mask7)

%%
currFrameSum            = mask7(:,:,1).*sum(currentFrame,3);
currentMissedInFrame    = abs(currFrameSum- medImagesum);

%remove areas covered by bboxes
numCurrentObjects       = size(bboxes,1);

for counterBox          = 1:numCurrentObjects
    rr                  = round( bboxes(counterBox,2):bboxes(counterBox,2)+bboxes(counterBox,4));
    cc                  = round(bboxes(counterBox,1):bboxes(counterBox,1)+bboxes(counterBox,3));
    currentMissedInFrame(rr,cc) = 0;
end

%%
currentMissedInFrame  = (imfilter(currentMissedInFrame,fspecial("gaussian",5,3)))>0.5;


MissedInFrame                      = currentFrame;
MissedInFrame(:,:,1)               = MissedInFrame(:,:,1)+currentMissedInFrame*50;
MissedInFrame(MissedInFrame>255)   = 255;

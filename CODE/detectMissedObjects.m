function  [MissedInFrame,avPosX,avPosY,numMissed]      = detectMissedObjects(currentFrame,medImagesum,bboxes,mask7)

%%
[rows,cols,~]           = size(currentFrame);
currFrameSum            = mask7(:,:,1).*sum(currentFrame,3);
currentMissedInFrame0   = abs(currFrameSum- medImagesum);
currentMissedInFrame0b  = currentMissedInFrame0;
%remove areas covered by bboxes
numCurrentObjects       = size(bboxes,1);

for counterBox          = 1:numCurrentObjects
    rr                  = round(-4+ bboxes(counterBox,2):4+bboxes(counterBox,2)+bboxes(counterBox,4));
    cc                  = round(-4+ bboxes(counterBox,1):4+bboxes(counterBox,1)+bboxes(counterBox,3));
    rr(rr<1)            =[];
    cc(cc<1)            =[];
    rr(rr>=rows)            =[];
    cc(cc>=cols)            =[];
    try
    currentMissedInFrame0(rr,cc) = 0;
    catch
        qq=1;
    end
end

%%
currentMissedInFrame1  = imfilter(currentMissedInFrame0,fspecial("gaussian",5,3));
currentMissedInFrame2  = (currentMissedInFrame1)>0.4;
[currentMissedInFrame2L,numL] = bwlabel(currentMissedInFrame2);
currentMissedInFrame2P = regionprops(currentMissedInFrame2L);



% if only objects over bridge are required, then callibrate to find x
% position over the bridge
% for k=1:numel(regionsToKeep)
%     bboxes2(k,:)                  = currentMissedInFrame2P(regionsToKeep(k),:).BoundingBox;
% end
% %bboxes2 = bboxes2(:,[2 1 4 3]);
% [avPosX2,avPosY2]             = callibrateObjectsBridge(bboxes2);
if numL==0
    MissedInFrame                      = currentFrame;
    avPosX                              =[];
    avPosY                              =[];
    numMissed                           = 0;
else
    for k=1:numL
        bboxes3(k,:)                  = currentMissedInFrame2P(k,:).BoundingBox;
    end
    try
        [avPosX3,avPosY3]             = callibrateObjectsBridge(bboxes3);
    catch
        qq=1;
    end
    % only keep objects with more than 10 pixels AND between -5 and 55 in x
    regionsToKeep1          = find([currentMissedInFrame2P.Area]>10 );
    regionsToKeep2          = find((avPosX3>-1)&(avPosX3<46));
    regionsToKeep           = intersect(regionsToKeep1,regionsToKeep2);
    currentMissedInFrame3   = ismember(currentMissedInFrame2L,regionsToKeep);
    [~,numMissed]           = bwlabel(currentMissedInFrame3);
    avPosX                  = avPosX3(regionsToKeep);
    avPosY                  = avPosY3(regionsToKeep);

    MissedInFrame                      = currentFrame;
    try
        MissedInFrame(:,:,1)               = MissedInFrame(:,:,1)+currentMissedInFrame3*50;
    catch
        qq=1;
    end
    MissedInFrame(MissedInFrame>255)   = 255;

end

%%
% labels={'','','','','','','','','',''};
% detectedImg                 = insertObjectAnnotation(currentMissedInFrame0b,"Rectangle",bboxes,labels);
% 
% h0 = figure;
% h0.Position = [460  300  836  469];
% imagesc(detectedImg)
% h1=gca;
% h1.Position = [0 0 1 1];
%  axis off
% filename = 'Figures\Fig_7_yoloMissedDetection_4.png';
% print('-dpng','-r400',filename)


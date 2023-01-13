
clear 
close all
clc
%%
dir0 = ('C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\AlfredoCamara\');
dir_videos      = dir(strcat(dir0,'*.mov'));
currentVideo                                = strcat(dir0,dir_videos(14).name);



%BridgeVideo = strcat(dir0,'BridgeTraffic.mov');
%videoHandle    = VideoReader(BridgeVideo);
videoHandle                                 = VideoReader(currentVideo);
%%%%% Assuming that the frame rate is 60 frames per second  %%%%%
% To select all frames     stepBetweenFrames = 1
% To select one per second stepBetweenFrames = 60
%%
stepBetweenFrames = 100; 
%stepBetweenFrames = 15; 


[allFrames,medImage,stdImage]   = readVideoBridge(videoHandle,stepBetweenFrames);
[rows,cols,dims,numFrames] = size(allFrames);

   

%%
%classes = {'car','person','bus'};
%anchorBoxes = {[122,177;223,84;80,94];...
%               [132,197;123,184;180,194];...
%                [111,38;33,47;37,18]};
detector = yolov4ObjectDetector('csp-darknet53-coco');
disp(detector)
%%
% rr=90:180; cc=340:500;
rr=1:rows;cc=1:cols;

  img = allFrames(rr,cc,:,1)/255;
 [bboxes,scores,labels] = detect(detector,img,Threshold=0.3);
 detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes,labels);
 %detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes([14 22 23 24],:),labels([14 2 23 24]));
 figure
 imagesc(detectedImg)
%%
for k=1:numel(scores)
 detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes(k,:),labels(k));
 %detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes([14 22 23 24],:),labels([14 2 23 24]));
 figure(k+10)
 imshow(detectedImg)
end
% %%
% [bboxes2,scores2,labels2] = detect(detector,firstFrame.*repmat(uint8(q),[1 1 3]));
% detectedImg2 = insertObjectAnnotation(firstFrame,"Rectangle",bboxes2,labels2);
% figure
% imshow(detectedImg2)
%%
classesOfInterest = {'car','person','bus','truck','motorbike'};
 rr=90:300;
 cc=1:650;
for k =1:1:numFrames
    disp(k)
    img = allFrames(rr,cc,:,k)/255;
    [bboxes,scores,labels] = detect(detector,img);
    keepIndex = (labels=='car')|(labels=='person')|(labels=='bus')|(labels=='truck')|(labels=='motorbike');
    labels=labels(keepIndex);
    bboxes=bboxes(keepIndex,:);
    scores=scores(keepIndex);
    %remove objects that are not of interest
    detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes,labels);
    imagesc(detectedImg)
    pause(0.1)
    %drawnow
end
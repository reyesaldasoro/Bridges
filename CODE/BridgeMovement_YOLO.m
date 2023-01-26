
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
[rows,cols,dims,numFrames]      = size(allFrames);

%% Define a mask based on the stdImage

mask0                           = (mean(stdImage,3));
mask1                           = mask0/max(mask0(:));
mask2                           = graythresh(mask1);
mask3                           = mask1>(0.95*mask2);
mask4                           = imclose(mask3,ones(3,15));
%mask5 = (imopen(mask3, ones(7,7)));
mask5                           = imfill(imopen(mask4, ones(15,15)),'holes');
%mask5 = bwlabel(mask4);
%mask5b = regionprops(mask5,'area');
mask6                           = imdilate(mask5,strel('disk',7));
%mask6 = ismember(mask5,find([mask5b.Area]>5000));
mask7                           = repmat(mask6,[1 1 3]);
imagesc(mask7.*medImage/255)
% imagesc(mask3+mask6)

%% Load the detector
% csp works well, tiny does not 
detector                        = yolov4ObjectDetector('csp-darknet53-coco');
disp(detector)
% detector2                       = yolov4ObjectDetector('tiny-yolov4-coco');
% disp(detector2)

%% detect objects in one image
% rr=90:180; cc=340:500;
rr=1:rows;cc=1:cols;

currentFrame = mask7.*allFrames(rr,cc,:,1)/255;
[bboxes,scores,labels] = detect(detector,currentFrame,Threshold=0.3);
detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
figure
imagesc(detectedImg)
% [bboxes2,scores2,labels2] = detect(detector2,img);
% detectedImg2 = insertObjectAnnotation(img,"Rectangle",bboxes2,labels2);
% figure
% imagesc(detectedImg2)
%% display the segmented objects from the bboxes in separate figures
% for k=1:numel(scores)
%     detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes(k,:),labels(k));
%     %detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes([14 22 23 24],:),labels([14 2 23 24]));
%     figure(k+10)
%     imshow(detectedImg)
% end
% % %%
% % [bboxes2,scores2,labels2] = detect(detector,firstFrame.*repmat(uint8(q),[1 1 3]));
% % detectedImg2 = insertObjectAnnotation(firstFrame,"Rectangle",bboxes2,labels2);
% % figure
% % imshow(detectedImg2)
%% Define the classes of interest and if necessary region of interest
classesOfInterest = {'car','person','bus','truck','motorbike'};
% rr=90:300;
% cc=1:650;
rr=1:rows;
cc=1:cols;

for k =1:10:numFrames
    disp(k)
    currentFrame             = allFrames(rr,cc,:,k)/255;
    % Pass only the masked image as there is no interest other than the
    % areas with movement on the bridge.
    % lower the threshold to avoid losing some weaker detections
    [bboxes,scores,labels]  = detect(detector,mask7.*currentFrame,Threshold=0.25);
    [bboxes,scores,labels]  = cleanObjectsBridge(bboxes,scores,labels,rows,cols);
    detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
    imagesc(detectedImg)
    pause(0.05)
    %drawnow
end
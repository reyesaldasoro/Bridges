
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
%% First illustration a representative frame
h0 = figure;
h0.Position = [460  300  836  469];
imagesc(allFrames(rr,cc,:,12)/255)
h1=gca;
h1.Position = [0 0 1 1];
filename = 'Figures\Fig_0_representativeFrameB.png';
print('-dpng','-r400',filename)
%% Illustrate median 
h0 = figure;
h0.Position = [460  300  836  469];
imagesc(medImage/255)
h1=gca;
h1.Position = [0 0 1 1];
filename = 'Figures\Fig_0_medianImage.png';
print('-dpng','-r400',filename)
%% Illustrate standard deviation
h0 = figure;
h0.Position = [460  300  836  469];
imagesc(stdImage/25)
h1=gca;
h1.Position = [0 0 1 1];
filename = 'Figures\Fig_0_stdImage.png';
print('-dpng','-r400',filename)




%% Define a mask based on the stdImage
% Mask7 defines the area of interest, only over the bridge where there is
% movement, river and all else is discarded
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

% Mask8 is the watershed between one side of the bridge and the other
mask8                           = watershed(bwdist(1-mask6));

% imagesc(mask3+mask6)
%% illustrate mask

h0 = figure;
h0.Position = [460  300  836  469];
imagesc(0.5*(1-mask7)+allFrames(rr,cc,:,12)/255)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_1_maskActivityB.png';
print('-dpng','-r400',filename)




%% Load the detector
% csp works well, tiny does not 
detector                        = yolov4ObjectDetector('csp-darknet53-coco');
disp(detector)
% detector2                       = yolov4ObjectDetector('tiny-yolov4-coco');
% disp(detector2)

%% detect objects in one image without mask high threshold

currentFrame = allFrames(rr,cc,:,12)/255;
[bboxes,scores,labels] = detect(detector,currentFrame,Threshold=0.7);
detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
h0 = figure;
h0.Position = [460  300  836  469];
imagesc(detectedImg)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_2_yoloDetection_highThresB.png';
print('-dpng','-r400',filename)
%% detect objects in one image without mask high threshold

currentFrame = allFrames(rr,cc,:,12)/255;
[bboxes,scores,labels] = detect(detector,currentFrame,Threshold=0.1);
detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
h0 = figure;
h0.Position = [460  300  836  469];
imagesc(detectedImg)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_2_yoloDetection_lowThresB.png';
print('-dpng','-r400',filename)

%% detect objects in one image with mask
% rr=90:180; cc=340:500;
rr=1:rows;cc=1:cols;

currentFrame = allFrames(rr,cc,:,12)/255;
[bboxes,scores,labels] = detect(detector,mask7.*currentFrame,Threshold=0.2);
detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);

h0 = figure;
h0.Position = [460  300  836  469];
imagesc(detectedImg)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_3_yoloDetection_lowThresB_mask.png';
print('-dpng','-r400',filename)
%% detect objects in one image with mask and clean
% rr=90:180; cc=340:500;
rr=1:rows;cc=1:cols;

currentFrame = allFrames(rr,cc,:,12)/255;
[bboxes,scores,labels] = detect(detector,mask7.*currentFrame,Threshold=0.2);
[bboxes,scores,labels]  = cleanObjectsBridge(bboxes,scores,labels,rows,cols);
detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);

h0 = figure;
h0.Position = [460  300  836  469];
imagesc(detectedImg)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_4_yoloDetection_lowThresB_mask_clean.png';
print('-dpng','-r400',filename)



%% detect missed objects in one image 

currentFrame                = allFrames(rr,cc,:,12)/255;
[bboxes,scores,labels]      = detect(detector,mask7.*currentFrame,Threshold=0.6);
[bboxes,scores,labels]      = cleanObjectsBridge(bboxes,scores,labels,rows,cols);
[avPosX,avPosY]             = callibrateObjectsBridge(bboxes);

[MissedInFrame,avPosX]      = detectMissedObjects(currentFrame,medImagesum,bboxes,mask7);
%[temporalResults4,labels2,labels3]  = recordObjectsBridge(bboxes,labels,stepBetweenFrames*k/videoHandle.FrameRate,currentFrame,avPosX,avPosY);


detectedImg                 = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels3);

h0 = figure;
h0.Position = [460  300  836  469];
imagesc(detectedImg)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_7_yoloMissedDetection_1.png';
print('-dpng','-r400',filename)

h0 = figure;
h0.Position = [460  300  836  469];
imagesc(MissedInFrame)
h1=gca;
h1.Position = [0 0 1 1];

 axis off
filename = 'Figures\Fig_7_yoloMissedDetection_2.png';
print('-dpng','-r400',filename)


%%
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_5_yoloDetection_lowThresB_mask_clean_dist.png';
print('-dpng','-r400',filename)



%% illustrate callibration with a test image
[bboxes,scores,labels]      = detect(detector,testImage2,Threshold=0.2);
[bboxes,scores,labels]      = cleanObjectsBridge(bboxes,scores,labels,rows,cols);
[avPosX,avPosY,labels3]             = callibrateObjectsBridge(bboxes,labels);
[temporalResults4,labels2,labels3]  = recordObjectsBridge(bboxes,labels,stepBetweenFrames*k/videoHandle.FrameRate,currentFrame,avPosX,avPosY);


detectedImg                 = insertObjectAnnotation(testImage2,"Rectangle",bboxes,labels3);

h0 = figure;
h0.Position = [460  300  836  469];
imagesc(detectedImg)
h1=gca;
h1.Position = [0 0 1 1];
 axis off
filename = 'Figures\Fig_6_yoloDetection_callibration.png';
print('-dpng','-r400',filename)

     

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
% classesOfInterest = {'car','person','bus','truck','motorbike'};
% rr=90:300;
% cc=1:650;
rr=1:rows;
cc=1:cols;
temporalResults5=[];
medImagesum                 = mask6.* (sum(medImage/255,3));
h0 = figure;
h0.Position = [460  300  836  469];
hImage  = imagesc(allFrames(rr,cc,:,1)/255);
hFrames = text(50,50,'b','color','y');
hTime   = text(50,70,'a','color','y');
axis off
h1=gca;
h1.Position = [0 0 1 1];
clear F 


for k =1:1:numFrames
    disp(k)
    currentFrame             = allFrames(rr,cc,:,k)/255;
    % Pass only the masked image as there is no interest other than the
    % areas with movement on the bridge.
    % lower the threshold to avoid losing some weaker detections
    [bboxes,scores,labels]  = detect(detector,mask7.*currentFrame,Threshold=0.25);
    [bboxes,scores,labels]  = cleanObjectsBridge(bboxes,scores,labels,rows,cols);


    %[temporalResults4,labels2,labels3]  = recordObjectsBridge(bboxes,labels,stepBetweenFrames*k/videoHandle.FrameRate,currentFrame,avPosX,avPosY);


    % Use current Difference to detect objects that are missed by Yolo


    if ~isempty(labels)
        %[avPosX,avPosY]             = callibrateObjectsBridge(bboxes);        
        [avPosX,avPosY,labels3]             = callibrateObjectsBridge(bboxes,labels);
        [currentMissedInFrame,avPosX2]     = detectMissedObjects(currentFrame,medImagesum,bboxes,mask7);

        %[temporalResults4,labels2]      = recordObjectsBridge(bboxes,labels,stepBetweenFrames*k/videoHandle.FrameRate,currentFrame);
        %temporalResults5                = [temporalResults5;temporalResults4];
        currentMissedInFrame            = detectMissedObjects(currentFrame,medImagesum,bboxes,mask7);
        %detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
        %detectedImg = insertObjectAnnotation(currentMissedInFrame,"rectangle",bboxes,labels3,'color',0.6*[1 1 1],'LineWidth',1,'TextBoxOpacity',0.6,'FontSize',12,'font','arial','textcolor','white');
        detectedImg = insertObjectAnnotation(currentMissedInFrame,"rectangle",bboxes,labels3,'LineWidth',1,'TextBoxOpacity',0.2,'FontSize',12,'font','arial','textcolor','white');
        %imagesc(detectedImg)
        hImage.CData = detectedImg;
    else
        %imagesc(currentFrame)
        hImage.CData = currentFrame;
    end
    %input('')
    %pause(0.001)
    hTime.String    = strcat('Time:',32,32,32,num2str(stepBetweenFrames*k/videoHandle.FrameRate));
    hFrames.String  = strcat('Frame:',32,num2str(k));
    drawnow
    F(k)       = getframe(h0);
end

%%


%% Save movie as mp4
output_video = VideoWriter('traffic_2023_02_01_Yolo', 'MPEG-4');
open(output_video);
writeVideo(output_video,F);
close(output_video);


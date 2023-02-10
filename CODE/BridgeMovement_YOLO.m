
clear
close all
clc
%%
dir0 = ('C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\AlfredoCamara\');
dir_videos      = dir(strcat(dir0,'*.mov'));
currentVideo                                = strcat(dir0,dir_videos(14).name);

videoHandle                                 = VideoReader(currentVideo);
%% %%% Assuming that the frame rate is 60 frames per second  %%%%%
% To select all frames     stepBetweenFrames = 1
% To select one per second stepBetweenFrames = 60

%stepBetweenFrames = 100;
stepBetweenFrames = 15;


[allFrames,medImage,stdImage]   = readVideoBridge(videoHandle,stepBetweenFrames);
[rows,cols,dims,numFrames]      = size(allFrames);




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
%imagesc(mask7.*medImage/255)

% Mask8 is the watershed between one side of the bridge and the other
%mask8                           = watershed(bwdist(1-mask6));

% imagesc(mask3+mask6)



%% Load the detector
% csp works well, tiny does not 
detector                        = yolov4ObjectDetector('csp-darknet53-coco');
disp(detector)

%% Define the classes of interest and if necessary region of interest

temporalResults5=[];
medImagesum                 = mask6.* (sum(medImage/255,3));
h0 = figure;
h0.Position = [460  300  836  469];
hImage  = imagesc(allFrames(:,:,:,1)/255);
hFrames = text(50,50,'b','color','y');
hTime   = text(50,70,'a','color','y');
axis off
h1=gca;
h1.Position = [0 0 1 1];
clear F 


%%
temporalResults5=[];
%
for kThres = 0.5%:0.05:1
    for k =1%:50%:1:numFrames
        disp(k)
        currentFrame                                        = allFrames(:,:,:,k)/255;
        currentTime                                         = stepBetweenFrames*k/videoHandle.FrameRate;
        % Pure YOLO, no exclusions
        % lower the threshold to avoid losing some weaker detections, increase
        % threshold to improve accuracy
        [bboxes0,scores0,labels0]                           = detect(detector,currentFrame,Threshold=kThres);
        numObjDetected(k,1)                             = numel(labels0);
        % Pass only the masked image as there is no interest other than the
        % areas with movement on the bridge.

        [bboxes1,scores1,labels1]                           = detect(detector,mask7.*currentFrame,Threshold=kThres);
        numObjDetectedMask(k,1)                         = numel(labels1);
        [bboxes2,scores2,labels2,numObjRemoved(k,1)]    = objectsOfInterest(bboxes1,scores1,labels1);
        [bboxes3,scores3,labels3,numObjRemoved(k,2)]    = cleanOverlappingObjects(bboxes2,scores2,labels2,rows,cols);
        [bboxes4,scores4,labels4,numObjRemoved(k,3)]    = cleanObjectsBridge(bboxes3,scores3,labels3);
        [currMissedInFrame,avPosX2,avPosY2,numObjMissed(k,1)]  = detectMissedObjects(currentFrame,medImagesum,bboxes0,mask7);

        %[temporalResults4,labels2,labels3]  = recordObjectsBridge(bboxes,labels,stepBetweenFrames*k/videoHandle.FrameRate,currentFrame,avPosX,avPosY);


        % Use current Difference to detect objects that are missed by Yolo


        if ~isempty(labels)
            %[avPosX,avPosY,labels5,labels6]         = callibrateObjectsBridge(bboxes,labels);

            %[temporalResults0,temporalResults1]     = recordObjectsBridge(bboxes4,labels5,currentTime,k,currentFrame,avPosX,avPosY);

            %temporalResults5                        = trackObjectsBridge(temporalResults5,temporalResults1);
            %temporalResults5                        = [temporalResults5;temporalResults1];
            %         % remove the traffic light detected as a pedestrian
            %         bboxes(trafficLightConditions,:)  =[];
            %         labels3(trafficLightConditions,:)  =[];

            %detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
            %detectedImg = insertObjectAnnotation(currentMissedInFrame,"rectangle",bboxes,labels3,'color',0.6*[1 1 1],'LineWidth',1,'TextBoxOpacity',0.6,'FontSize',12,'font','arial','textcolor','white');
            detectedImg = insertObjectAnnotation(currMissedInFrame,"rectangle",bboxes0,labels0,'LineWidth',1,'TextBoxOpacity',0.2,'FontSize',12,'font','arial','textcolor','white');
            %imagesc(detectedImg)
            hImage.CData = detectedImg;
        else
            %imagesc(currentFrame)
            hImage.CData = currentFrame;
        end
        %input('')
        pause(0.1)
        hTime.String    = strcat('Time:',32,32,32,num2str(currentTime));
        hFrames.String  = strcat('Frame:',32,num2str(k));
        drawnow
        %F(k)       = getframe(h0);
    end
end
%%


%% Save movie as AVI
% Saving as mp4 loses some frames
output_video = VideoWriter('traffic_2023_02_01_Yolo_10B');
open(output_video);
writeVideo(output_video,F);
close(output_video);


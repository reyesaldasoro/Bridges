
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
% Define a mask based on the stdImage
[maskBridge,medImagesum] = defineMaskBridge(stdImage,medImage);


%% Load the detector
% csp works well, tiny does not 
detector                        = yolov4ObjectDetector('csp-darknet53-coco');
disp(detector)

%% Define the classes of interest and if necessary region of interest
h1 = figure(1);
h1.Position = [100  100  836  469];
h1Image  = imagesc(allFrames(:,:,:,1)/255);
h1Frames = text(50,50,'b','color','y');
h1Time   = text(50,70,'a','color','y');
axis off
h11=gca;
h11.Position = [0 0 1 1];


h2 = figure(2);
h2.Position = [100  200  836  469];
h2Image  = imagesc(allFrames(:,:,:,1)/255);
h2Frames = text(50,50,'b','color','y');
h2Time   = text(50,70,'a','color','y');
axis off
h21=gca;
h21.Position = [0 0 1 1];


h3 = figure(3);
h3.Position = [100  300  836  469];
h3Image  = imagesc(allFrames(:,:,:,1)/255);
h3Frames = text(50,50,'b','color','y');
h3Time   = text(50,70,'a','color','y');
axis off
h31=gca;
h31.Position = [0 0 1 1];


%%
temporalResults5=[];
clear F* 

%%
for kThres = 0.15  %:0.05:1
    for k= 86% 1:1:200%numFrames
        disp(k)
        currentFrame                                        = allFrames(:,:,:,k)/255;
        currentTime                                         = stepBetweenFrames*k/videoHandle.FrameRate;
        % Pure YOLO, no exclusions
        % lower the threshold to avoid losing some weaker detections, increase
        % threshold to improve accuracy
        [bboxes0,scores0,labels0]                       = detect(detector,currentFrame,Threshold=kThres);
        numObjDetected(k,1)                             = numel(labels0);
        % Pass only the masked image as there is no interest other than the
        % areas with movement on the bridge.

        [bboxes1,scores1,labels1]                       = detect(detector,maskBridge.*currentFrame,Threshold=kThres);
        numObjDetectedMask(k,1)                         = numel(labels1);
        [bboxes2,scores2,labels2,numObjRemoved(k,1)]    = objectsOfInterest(bboxes1,scores1,labels1);
        [bboxes3,scores3,labels3,numObjRemoved(k,2)]    = cleanOverlappingObjects(bboxes2,scores2,labels2,rows,cols);
        [bboxes4,scores4,labels4,numObjRemoved(k,3)]    = cleanObjectsBridge(bboxes3,scores3,labels3);
        [currMissedInFrame,avPosX2,avPosY2,numObjMissed(k,1)]  = detectMissedObjects(currentFrame,medImagesum,bboxes4,maskBridge);

        %[temporalResults4,labels2,labels3]  = recordObjectsBridge(bboxes,labels,stepBetweenFrames*k/videoHandle.FrameRate,currentFrame,avPosX,avPosY);


        % Use current Difference to detect objects that are missed by Yolo


        if ~isempty(labels)
            [avPosX,avPosY,labels5,labels6]         = callibrateObjectsBridge(bboxes4,labels4);

            %[temporalResults0,temporalResults1]     = recordObjectsBridge(bboxes4,labels5,currentTime,k,currentFrame,avPosX,avPosY);

            %temporalResults5                        = trackObjectsBridge(temporalResults5,temporalResults1);
            %temporalResults5                        = [temporalResults5;temporalResults1];
            %         % remove the traffic light detected as a pedestrian
            %         bboxes(trafficLightConditions,:)  =[];
            %         labels3(trafficLightConditions,:)  =[];

            %detectedImg = insertObjectAnnotation(currentFrame,"Rectangle",bboxes,labels);
            %detectedImg = insertObjectAnnotation(currentMissedInFrame,"rectangle",bboxes,labels3,'color',0.6*[1 1 1],'LineWidth',1,'TextBoxOpacity',0.6,'FontSize',12,'font','arial','textcolor','white');
            detectedImg1 = insertObjectAnnotation(currentFrame,"rectangle",bboxes0,labels0,'LineWidth',1,'TextBoxOpacity',0.2,'FontSize',12,'font','arial','textcolor','white');
            detectedImg2 = insertObjectAnnotation(currentFrame,"rectangle",bboxes1,labels1,'LineWidth',1,'TextBoxOpacity',0.2,'FontSize',12,'font','arial','textcolor','white');
            detectedImg3 = insertObjectAnnotation(currMissedInFrame,"rectangle",bboxes4,labels6,'LineWidth',1,'TextBoxOpacity',0.2,'FontSize',12,'font','arial','textcolor','white');
            %imagesc(detectedImg)
            h1Image.CData = detectedImg1;
            h2Image.CData = detectedImg2;
            h3Image.CData = detectedImg3;
        else
            %imagesc(currentFrame)
            h1Image.CData = currentFrame;
            h2Image.CData = currentFrame;
            h3Image.CData = currentFrame;
        end
        %input('')
        %pause(0.1)
        h1Time.String    = strcat('Time:',32,32,32,num2str(currentTime));
        h1Frames.String  = strcat('Frame:',32,num2str(k));
        h2Time.String    = strcat('Time:',32,32,32,num2str(currentTime));
        h2Frames.String  = strcat('Frame:',32,num2str(k));
        h3Time.String    = strcat('Time:',32,32,32,num2str(currentTime));
        h3Frames.String  = strcat('Frame:',32,num2str(k));
        drawnow
        F1(k)       = getframe(h1);
        F2(k)       = getframe(h2);
        F3(k)       = getframe(h3);
    end
end
%%


%% Save movie as AVI
% Saving as mp4 loses some frames
output_video = VideoWriter('traffic_2023_02_10_Yolo_1_200_h2');
open(output_video);
writeVideo(output_video,F3);
close(output_video);


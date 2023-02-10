

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
h0 = figure;
h0.Position = [460  300  836  469];
hImage  = imagesc(allFrames(:,:,:,1)/255);
hFrames = text(50,30,'b','color','y');
hTime   = text(50,50,'a','color','y');
hThres  = text(50,70,'a','color','y');
axis off
h1=gca;
h1.Position = [0 0 1 1];
clear F 


%%
temporalResults5=[];
% loop over thresholds to illustrate changes
for kThres = 0.05:0.05:1
    disp(kThres)
    for k =1:100%:1:numFrames
        disp(k)
        currentFrame                                        = allFrames(:,:,:,k)/255;
        currentTime                                         = stepBetweenFrames*k/videoHandle.FrameRate;
        % Pure YOLO, no exclusions
        % lower the threshold to avoid losing some weaker detections, increase
        % threshold to improve accuracy
        [bboxes0,scores0,labels0]                       = detect(detector,currentFrame,Threshold=kThres);
        numObjDetected(k,round(20*(kThres)))                             = numel(labels0);
        % Pass only the masked image as there is no interest other than the
        % areas with movement on the bridge.

        [bboxes1,scores1,labels1]                       = detect(detector,maskBridge.*currentFrame,Threshold=kThres);
        numObjDetectedMask(k,round(20*(kThres)))                         = numel(labels1);
        [bboxes2,scores2,labels2,numObjRemoved(k,1)]    = objectsOfInterest(bboxes1,scores1,labels1);
        [bboxes3,scores3,labels3,numObjRemoved(k,2)]    = cleanOverlappingObjects(bboxes2,scores2,labels2,rows,cols);
        [bboxes4,scores4,labels4,numObjRemoved(k,3)]    = cleanObjectsBridge(bboxes3,scores3,labels3);
        [currMissedInFrame,avPosX2,avPosY2,numObjMissed(k,round(20*(kThres)))]  = detectMissedObjects(currentFrame,medImagesum,bboxes0,maskBridge);

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
            %detectedImg = insertObjectAnnotation(currentFrame,"rectangle",bboxes1,labels1,'LineWidth',1,'TextBoxOpacity',0.2,'FontSize',12,'font','arial','textcolor','white');
            %imagesc(detectedImg)
            %hImage.CData = detectedImg;
        else
            %imagesc(currentFrame)
            %hImage.CData = currentFrame;
        end
        %input('')
        %pause(0.1)
        hTime.String    = strcat('Time:',32,32,32,32,32,32,32,32,32,num2str(currentTime,3));
        hFrames.String  = strcat('Frame:',32,32,32,32,32,32,32,num2str(k));
        hThres.String   = strcat('Threshold:',32,num2str(kThres));
        drawnow
        %F(k)       = getframe(h0);
        %filename = strcat('Figures2',filesep,'Fig_MaskThres_',num2str(100*kThres),'.png');
        %print('-dpng','-r300',filename)
    end
end


%% Display objects detected 30/100 frames

tt = 51:100;
%tt = 31:60;

h0 = gcf;
h0.Position = [100  300  836  469];
h1=gca;
h1.Position = [0.1 0.1 .8 .8];
yyaxis left
hLi1 = plot(0.05:0.05:0.95,sum(numObjDetected(tt,1:19)),'--*',0.05:0.05:0.95,sum(numObjDetectedMask(tt,1:19)),'-.x','LineWidth',2);grid on;axis tight
hLa1 =ylabel('Objects detected');

yyaxis right
hLi2 = plot(0.05:0.05:0.95,sum(numObjMissed(tt,1:19)),'-o','LineWidth',2);grid on;axis tight
hLa2 = ylabel('Objects Missed');
hLa3 = xlabel('Threshold');

h1.Position = [0.09 0.12 .82 .86];
%hLi1.LineWidth = [2 2];
%hLa2.LineWidth = 2;
hLa1.FontSize = 14;
hLa2.FontSize = 14;
hLa3.FontSize = 14;
%%

filename = strcat('Figures2',filesep,'Fig_Objects_Threshold_51_100.png');
print('-dpng','-r500',filename)
%%
save ('Figures2\Fig_Objects_Threshold','numObjDetected','numObjMissed','numObjDetectedMask')

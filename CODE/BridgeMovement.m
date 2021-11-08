
%% Clear all variables and close all figures
clear all
close all
clc
%% Prepare folders
if strcmp(filesep,'/')
    % Running in Mac
    cd ('~/Academic/GitHub/Bridges/CODE')
    dir0 = ('~/OneDrive - City, University of London/Acad/Research/AlfredoCamara/');
else
    % running in windows Alienware  

    cd('C:\Users\sbbk034\OneDrive - City, University of London\Documents\GitHub\Bridges\CODE')
    dir0 = ('C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\AlfredoCamara\');

end

%% Input from the separate frames
%dir0  = dir ('BridgeTraffic/Br*.png');
%numFrames = size(dir0,1);

%% Read data directly from a website ???
% MATLAB Support Package for IP Cameras 
% open Add-On Explorer and install
%cam = ipcam('https://v.angelcam.com/iframe?v=v40le5pnl5&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJkb21haW4iOiJvbG5lLmdyIiwiY2FtZXJhX2lkIjo1OTI0LCJleHAiOjE2MzQ4OTI0OTN9.Fbysjs3JHLANS8pSQ8a-JbsPjESb8HXVb7Fu9js1TXk');
%cam = inputvideo('https://www.youtube.com/watch?v=F3R97syoK40');

%cam = VideoReader('https://v.angelcam.com/iframe?v=v40le5pnl5&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJkb21haW4iOiJvbG5lLmdyIiwiY2FtZXJhX2lkIjo1OTI0LCJleHAiOjE2MzQ4OTI0OTN9.Fbysjs3JHLANS8pSQ8a-JbsPjESb8HXVb7Fu9js1TXk');


%preview(cam) %dislay the images
%% Alternative input from the video
[allFrames,medImage,stdImage] = readVideoBridge(strcat(dir0,'BridgeTraffic.mov'));
numFrames = size(allFrames,4);
%v=VideoReader('BridgeTraffic.mov');
%numFrames = v.NumFrames;
% firstFrame = read(v,1);
% [rows,cols,levs] = size(firstFrame);
% %% Read all the frames
% 
% allFrames(rows,cols,3,numFrames)=0;
% rChannel(rows,cols,numFrames)=0;
% gChannel(rows,cols,numFrames)=0;
% bChannel(rows,cols,numFrames)=0;
% 
% 
% for k=1:numFrames
%     disp(k)
%     % read the from the 
%     % tempImage = imread(strcat('BridgeTraffic/',dir0(k).name));
%     % Read from the video
%     currImage = read(v,k);
%     allFrames(:,:,:,k)=currImage;
%     rChannel(:,:,k) = currImage(:,:,1);
%     gChannel(:,:,k) = currImage(:,:,2);
%     bChannel(:,:,k) = currImage(:,:,3);
% end
% 
% 
% rChannelMed = median(rChannel,3);
% gChannelMed = median(gChannel,3);
% bChannelMed = median(bChannel,3);
% medImage(:,:,1) = rChannelMed;
% medImage(:,:,2) = gChannelMed;
% medImage(:,:,3) = bChannelMed;
% meanImage(:,:,1) = mean(rChannel,3);
% meanImage(:,:,2) = mean(gChannel,3);
% meanImage(:,:,3) = mean(bChannel,3);
% stdImage(:,:,1) = std(double(rChannel),[],3);
% stdImage(:,:,2) = std(double(gChannel),[],3);
% stdImage(:,:,3) = std(double(bChannel),[],3);
%%
    
% r=110;
% c=300;
% figure(5)
% plot(squeeze(rChannel(r,c,:)))
% hold on
% plot([1 numFrames] ,[medImage(r,c) medImage(r,c)]+0.5*stdImage(r,c))
% plot([1 numFrames] ,[medImage(r,c) medImage(r,c)])
% plot([1 numFrames] ,[medImage(r,c) medImage(r,c)]-0.5*stdImage(r,c))
% 
% hold off
%% Find the mask of the Bridge from std
 maskBridge = calculateBridgeMask(stdImage);

% maxStd          = max(stdImage(:));
% stdImageGray    = imfilter(rgb2gray(stdImage/maxStd),fspecial('Gaussian',15),'replicate');
% stdMaskT        = 1.5*graythresh(stdImageGray);
% %
% stdMask1        = bwlabel(imopen( imclose( (stdImageGray>stdMaskT),strel('disk',7)),strel('disk',7)));
% stdMask2        = regionprops(stdMask1,'Area');
% [~,maxReg]      = max([stdMask2.Area]);
% maskBridge      = ismember(stdMask1,maxReg);
% maskBridgeP     = regionprops(1-maskBridge,'orientation','ConvexHull');
% imagesc(maskBridge)
% 
%load('maskBridge2.mat')
%% find the main orientation of the bridge
%[finalBridge,finalMedImage,finalMask,finalLine]  = warpBridge(maskBridge,medImage,medImage);
k=1;
[finalBridge,finalMedImage,finalMask,finalCentralLine,finalStd] = warpBridge(maskBridge,medImage,allFrames(:,:,:,k),stdImage);

%%
load laneMasks
    currentDifference  = (abs(sum(finalBridge,3)- (sum(finalMedImage,3))));currentDifference=currentDifference/max(currentDifference(:));
    thresObject         = graythresh(currentDifference);
    
    currentThresholded  = (currentDifference>thresObject);
[segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks);
    
% 
% centralLineBridge   = bwmorph(bwmorph(maskBridge,'thin','inf'),'spur',35);
% [HT,thetaH,rhoT]    = hough(centralLineBridge);
% hPeaks              = houghpeaks(HT,1);
% lines               = houghlines(maskBridge,thetaH,rhoT,hPeaks,'FillGap',5,'MinLength',7);
% figure(4)
% hold off
% imagesc(repmat(1-imdilate(centralLineBridge,ones(3)),[1 1 3]).*(medImage/255))
% hold on
% xy = [lines(1).point1; lines(1).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
% % xy = [lines(2).point1; lines(2).point2];
% %    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
% % xy = [lines(3).point1; lines(3).point2];
% %    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','m');   
%    
%    hold off
%    
% avWidthPerColumn    =   sum((imrotate(maskBridge,-180+hPeaks(2))));
% baseColumns         = 1:numel(avWidthPerColumn);
% excludeColumns      = imdilate(avWidthPerColumn==0,ones(21));
% baseColumns(excludeColumns)=[];
% avWidthPerColumn(excludeColumns)=[];
% mdl                 = fitlm(baseColumns,avWidthPerColumn);
% initialWidth        = mdl.Fitted(1);
% finalWidth          = mdl.Fitted(end);
% %rotatedBridge       = (imrotate(medImage/255,-180+hPeaks(2)));
% %%
% 
% T                   =projective2d([1 -0.001 -0.0011; 0.194 1 0.001 ; 0 0 1]);
% 
% warpedBridge        = imwarp(medImage/255,(T));
% warpedMask          = imwarp(maskBridge,(T));
% warpedLine          = imwarp(centralLineBridge,T);
% figure(4)
% subplot(311)
% imagesc(medImage/255)
% subplot(312)
% imagesc(warpedBridge.*repmat(1-warpedLine,[1 1 3]))
% 
% avWidthPerColumnW    =   sum(warpedMask);
% %baseColumnsW         = 1:numel(avWidthPerColumnW);
% initialCol          = find(sum(warpedLine),1,'first');
% finalCol            = find(sum(warpedLine),1,'last');
% [~,centralRow]      = max(sum(warpedLine,2));
% baseColumnsW         = initialCol:finalCol;
% %excludeColumnsW      = imdilate(avWidthPerColumnW==0,ones(21));
% excludeColumnsW      = [1:initialCol finalCol:numel(avWidthPerColumnW)];
% %baseColumnsW(excludeColumnsW)=[];
% avWidthPerColumnW(excludeColumnsW)=[];
% widthMaskW              = median(avWidthPerColumnW);
% 
% finalBridge             = warpedBridge(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);
% subplot(313)
% imagesc(finalBridge)
% grid on
%%

% clear F
% 
% weights =[1300 1300 1100 1100 1400 1200 1100 1400 1200];
% carN ={'A','B','C','D','E','F','G','H','I','J'};
% 
%       U=  [ 0.7272046351     4.506912621   -2349.0397241;...
%             -1.721730931      2.380932561    2316.6460731;...
%              -3.77629198e-04  9.83714297e-4  1];
%      T=maketform('projective',U');
%% Arrange display
h0=figure(4);
h1      = subplot(121);
h11     = imagesc(allFrames(:,:,:,1)/255);

h2      = subplot(222);
h22     = imagesc(finalBridge);
    
h3      = subplot(224);
h33     = imagesc(segmentedObjects);
    drawnow

h0.Position = [200 200 1200 400];
h1.Position = [    0.03    0.10    0.28    0.86];

h2.Position = [    0.34    0.56    0.64    0.4];

h3.Position = [    0.34    0.10    0.64    0.4];

jet2=jet;jet2(1 ,:)=[0 0 0];colormap(jet2)

        
        
        


%%
for k=1750%1:10:numFrames%numFrames
    %
    %k=266;
    disp(k)
    [finalBridge]       = warpBridge(maskBridge,medImage,allFrames(:,:,:,k),stdImage);
    currentDifference   = (abs(sum(finalBridge,3)- (sum(finalMedImage,3))));currentDifference=currentDifference/max(currentDifference(:));
    thresObject         = graythresh(currentDifference);
    
    currentThresholded  = (currentDifference>thresObject);

    [segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks);
    %subplot(211)
    %imagesc(segmentedObjects)
    %subplot(212)
    %imagesc(finalBridge)
    
    h11.CData     = (allFrames(:,:,:,k)/255);
    h22.CData     = (finalBridge);
    h33.CData     = (segmentedObjects);
    
    drawnow
    
    
%     %       tempImage(:,:,1) =rChannel(:,:,k);
%     %       tempImage(:,:,2) =gChannel(:,:,k);
%     %       tempImage(:,:,3) =bChannel(:,:,k);
%     tempImage(:,:,1) =allFrames(:,:,1,k);
%     tempImage(:,:,2) =allFrames(:,:,2,k);
%     tempImage(:,:,3) =allFrames(:,:,3,k);
%     %
%     
%     currentThresholded1  = imopen((currentDifference>thresObject),ones(6,1));
%     currentThresholded2  = imopen((currentDifference>thresObject),ones(1,11));
%     
%     
%     imagesc(currentThresholded0+currentThresholded1+currentThresholded2);
%     
%     
%     %
%     gt1 = (tempImage(:,:,1)>(double(medImage(:,:,1))+2.0*stdImage(:,:,1)));
%     gt2 = (tempImage(:,:,2)>(double(medImage(:,:,2))+2.0*stdImage(:,:,2)));
%     gt3 = (tempImage(:,:,3)>(double(medImage(:,:,3))+2.0*stdImage(:,:,3)));
%     lt1 = (tempImage(:,:,1)<(double(medImage(:,:,1))-2.0*stdImage(:,:,1)));
%     lt2 = (tempImage(:,:,2)<(double(medImage(:,:,2))-2.0*stdImage(:,:,2)));
%     lt3 = (tempImage(:,:,3)<(double(medImage(:,:,3))-2.0*stdImage(:,:,3)));
%     
%     changeI0 = (lt1+lt2+lt3+gt1+gt2+gt3).*maskBridge;
%     changeI1 = bwmorph(changeI0,'clean');
%     
%     changeI2 = bwmorph(bwmorph(changeI1,'clean'),'majority');
%     %changeI3 = imclose(changeI2,strel('disk',7));
%     changeI3 = bwlabel(imclose(changeI2,strel('rectangle',[4 15])));
%     changeI3P = regionprops(changeI3,'Area');
%     
%     changeI4a  = ismember (changeI3,find(([changeI3P.Area]>60).*([changeI3P.Area]<1000)));
%     changeI4b  = imopen(ismember (changeI3,find([changeI3P.Area]>=1000)),strel('line',20,14));
%     
%     changeI5 =imdilate(zerocross((changeI4b+changeI4a)-0.5),ones(3));
%     tempImage2(:,:,k) = imfill(changeI4b+changeI4a,'holes');
%     tempImage(changeI5)=255;
%     [separateVehicles,numVeh] = bwlabel(tempImage2(:,:,k));
%     separateV_L = regionprops(separateVehicles,'centroid','Area');
%     separateV2 = zeros(size(separateVehicles));
%     medImage2 =medImage;
%     rangeR=-40:0;
%     rangeC=-3:3;
%     for k2 = 1:numVeh
%         separateV2 = separateV2+k2*imclose(separateVehicles==k2,ones(11));
%         tempC=round(separateV_L(k2).Centroid);
%         medImage2(tempC(2)+rangeR,tempC(1)+rangeC,1 )=255;
%         medImage2(tempC(2)+rangeR,tempC(1)+rangeC,2 )=0;
%         medImage2(tempC(2)+rangeR,tempC(1)+rangeC,3 )=0;
%     end
%     
%     %tempImage = imread(strcat('BridgeTraffic/',dir0(k).name));
%     %imagesc([tempImage.*uint8(repmat(changeI3,[1 1 3]));tempImage])
%     figure(11)
%     imagesc(tempImage/255)
%     pause(0.005)
%     figure(12)
%     
%     
%     
%     P2=imrotate(imtransform(uint8(imresize(tempImage,[1750 2333])),T,'XData',[1 rows],'YData',[1 cols]),-90);
%     imagesc(P2)
     
     
%     drawnow;
%     F(k) = getframe();
    %
end
%%
for k=1:10:300%numFrames
    disp(k)
P2=imrotate(imtransform(uint8(imresize(allFrames(:,:,:,k),[1750 2333])),T,'XData',[1 rows],'YData',[1 cols]),-90);
subplot(211)
imagesc(allFrames(:,:,:,k)/255)

subplot(212)
imagesc(P2)
%imagesc(allFrames(:,:,:,k)/255)
drawnow
    
end


%% Prepare a good figure
figure(2)
k=100;
h231=subplot(231);
imagesc(allFrames(:,:,:,k)/255)
title('(a) Representative Frame','fontsize',14)
axis off

h232=subplot(232);
imagesc(medImage(:,:,:)/255)
title('(b) Background','fontsize',14)
axis off

h233=subplot(233);
imagesc(stdImage(:,:,:)/25)
title('(c) Variation over time','fontsize',14)
axis off

h234=subplot(234);
imagesc(tempImage/255)
title('(d) Objects detected','fontsize',14)
axis off

h235=subplot(235);
imagesc(separateV2)
title('(e) Objects identified','fontsize',14)
for k2 = 1:numVeh
        tempC=round(separateV_L(k2).Centroid);
        text(tempC(1)-15,tempC(2)-35,carN{k2},'color','w','fontsize',9 );
end
axis off

h236=subplot(236);
imagesc(medImage2/255)
title('(f) Corresponding Weights','fontsize',14)
for k2 = 1:numVeh
        tempC=round(separateV_L(k2).Centroid);
        text(tempC(1)-45,tempC(2)-55,num2str(weights(k2)),'color','w','fontsize',9 );
end
axis off

%%
hWidth  = 0.31;
hHeight = 0.43; 
h231.Position=[0.02 0.52 hWidth hHeight];
h232.Position=[0.35 0.52 hWidth hHeight];
h233.Position=[0.68 0.52 hWidth hHeight];
h234.Position=[0.02 0.02 hWidth hHeight];
h235.Position=[0.35 0.02 hWidth hHeight];
h236.Position=[0.68 0.02 hWidth hHeight];


filename='CarDetectionBridge.png';

%print('-dpng','-r400',filename)


%%


    %% save the movie as a GIF
    [imGif,mapGif] = rgb2ind(F(1).cdata,256,'nodither');
    numFrames = size(F,2);

    imGif(1,1,1,numFrames) = 0;
    for k = 2:numFrames 
      imGif(:,:,1,k) = rgb2ind(F(k).cdata,mapGif,'nodither');
    end
    %%

    imwrite(imGif,mapGif,'BridgeMovement_6.gif',...
            'DelayTime',0,'LoopCount',inf) %g443800
        
        
        %%
        
 % <video data-html5-video="" muted="true" preload="metadata" src="blob:https://v.angelcam.com/e17069e6-05c0-4cf9-a596-97da1f65d39a"></video>
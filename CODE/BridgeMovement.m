
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
[allFrames,medImage,stdImage,videoHandle] = readVideoBridge(strcat(dir0,'BridgeTraffic.mov'));
numFrames = size(allFrames,4);

%% Find the mask of the Bridge from std
 maskBridge = calculateBridgeMask(stdImage);


%% find the main orientation of the bridge
%[finalBridge,finalMedImage,finalMask,finalLine]  = warpBridge(maskBridge,medImage,medImage);

[finalBridge,finalMedImage,finalMask,finalCentralLine,finalStd] = warpBridge(maskBridge,medImage,allFrames(:,:,:,1),stdImage);

%%
load laneMasks

    

toDisplay = 1;

%% Arrange display
if toDisplay ==1
    currentDifference  = (abs(sum(finalBridge,3)- (sum(finalMedImage,3))));currentDifference=currentDifference/max(currentDifference(:));
    thresObject         = graythresh(currentDifference);
    
    currentThresholded  = (currentDifference>thresObject);
    [segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks);
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
end

%%
k2=1;

% Iterate over the video, grab one frame per second
for k=videoHandle.FrameRate:videoHandle.FrameRate:numFrames%numFrames
    %

    disp(k)
    [finalBridge]       = warpBridge(maskBridge,medImage,allFrames(:,:,:,k),stdImage);
    currentDifference   = (abs(sum(finalBridge,3)- (sum(finalMedImage,3))));currentDifference=currentDifference/max(currentDifference(:));
    thresObject         = graythresh(currentDifference);
    
    currentThresholded  = (currentDifference>thresObject);

    [segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks);

    if toDisplay==1
        h11.CData     = (allFrames(:,:,:,k)/255);
        h22.CData     = (finalBridge);
        h33.CData     = (segmentedObjects);
        drawnow
        %     F(k2) = getframe();
    end
    currentObjects      = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).Area];
    currentCentroids    = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).Centroid];
    currentPosX         = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).positionX];
    currentPosY         = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).positionY];
    currentWeights      = [segmentedObjects_P([segmentedObjects_P.onEdge]==0).weight];
    currentTypeObj      = {segmentedObjects_P([segmentedObjects_P.onEdge]==0).typeObj};
    
    % time
    temporalResults{k2,1} = k/videoHandle.FrameRate;
    % num Objects
    temporalResults{k2,2} = sum(1-[segmentedObjects_P.onEdge]);
    % weight
    temporalResults{k2,3} = round(currentWeights);
    % position metres from left edge
    temporalResults{k2,4} = round(currentPosX);
    temporalResults{k2,5} = round(currentPosY);
    temporalResults{k2,6} = currentTypeObj;

    k2=k2+1;

    %     % Area
    %     temporalResults{k2,3} = currentObjects;
    %     % position x pixels
    %     temporalResults{k2,4} = currentCentroids(1:2:end);
    %     % Position y pixels
    %     temporalResults{k2,5} = currentCentroids(2:2:end);
end

%%
if toDisplay==1
    numTimePoints = size(temporalResults,1);
    for counterTimeP=1:numTimePoints
        
        
    end
end

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
        
        

  
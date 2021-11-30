
%% Clear all variables and close all figures
clear all
close all
clc

%% Data source

% https://olne.gr/el/evripos-bridge/evripos-bridge-live-stream
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
%% Detect Videos in Folder

dir_videos      = dir(strcat(dir0,'*.mov'));

%% Alternative input from the video
currentVideo                                = strcat(dir0,dir_videos(14).name);
videoHandle                                 = VideoReader(currentVideo);
%%%%% Assuming that the frame rate is 60 frames per second  %%%%%
% To select all frames     stepBetweenFrames = 1
% To select one per second stepBetweenFrames = 60

stepBetweenFrames = 60; 

%[allFrames,medImage,stdImage,videoHandle]  = readVideoBridge(strcat(dir0,'BridgeTraffic.mov'));
[allFrames,medImage,stdImage]   = readVideoBridge(videoHandle,stepBetweenFrames);
numFrames = size(allFrames,4);

%% Find the mask of the Bridge from std
 maskBridge = calculateBridgeMask(stdImage);


%% find the main orientation of the bridge
%[finalBridge,finalMedImage,finalMask,finalLine]  = warpBridge(maskBridge,medImage,medImage);

[finalBridge,finalMedImage,finalMask,finalCentralLine,finalStd,finalMetrics] = warpBridge(maskBridge,medImage,allFrames(:,:,:,1),stdImage);

imagesc(finalBridge)

%%
%load laneMasks
%load laneMasks_2021_11_19_1110
load laneMasks_2021_11_29_1124

% Scale laneMasks to current video
[newR,newC,newL]=size(finalBridge);

laneMasks.upper = imresize (laneMasks.upper,[newR newC]);
laneMasks.lower = imresize (laneMasks.lower,[newR newC]);
laneMasks.foot  = imresize (laneMasks.foot,[newR newC]);
    

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
clear temporalResults*

 
initialFrame            = stepBetweenFrames;
%selectRate              = 1 ;           
%stepFrames              = videoHandle.FrameRate * selectRate;
temporalResults2        = [];
% Iterate over the video, grab one frame 

%for k = initialFrame:stepBetweenFrames:numFrames   %)/videoHandle.FrameRate
for k = 1:numFrames   %)/videoHandle.FrameRate

%for k=stepFrames:stepBetweenFrames:numFrames   %numFrames
    %

    disp(k)
    [finalBridge]       = warpBridge2(allFrames(:,:,:,k),finalMetrics);
    currentDifference   = (abs(sum(finalBridge,3)- (sum(finalMedImage,3))));currentDifference=currentDifference/max(currentDifference(:));
    thresObject         = graythresh(currentDifference);
    
    currentThresholded  = (currentDifference>thresObject);

    [segmentedObjects,segmentedObjects_P] = segmentObjectsBridge(currentThresholded,laneMasks);

    if isempty(segmentedObjects_P)
        segmentedObjects(1,1)=1;
    end
    
    if toDisplay==1
        h11.CData     = (allFrames(:,:,:,k)/255);
        h22.CData     = (finalBridge);        
        h33.CData     = (segmentedObjects);
        drawnow
        F(k2)       = getframe(h0);
    end
    
    
    % only record if there are objects
    if ~isempty(segmentedObjects_P)
        
        currentObjects      = [segmentedObjects_P.Area];
        currentCentroids    = [segmentedObjects_P.Centroid];
        currentPosX         = [segmentedObjects_P.positionX];
        currentPosY         = [segmentedObjects_P.positionY];
        currentWeights      = [segmentedObjects_P.weight];
        
        currentTypeObj      = {segmentedObjects_P.typeObj};
        
        % Store in 2 ways, one a cell per time point,
        % one a single matrix with x,y,area,weight
        numCurrentObjects = numel(currentObjects);
        temporalResults2=[temporalResults2;[round(currentPosX') round(currentPosY') repmat(k/videoHandle.FrameRate,[numCurrentObjects 1]) currentWeights' ]];
        
        % time
        temporalResults{k2,1} = k/videoHandle.FrameRate;
        % num Objects
        temporalResults{k2,2} = numCurrentObjects;
        %temporalResults{k2,2} = sum(1-[segmentedObjects_P.onEdge]);
        % weight
        temporalResults{k2,3} = round(currentWeights);
        % position metres from left edge
        temporalResults{k2,4} = round(currentPosX);
        temporalResults{k2,5} = round(currentPosY);
        temporalResults{k2,6} = currentTypeObj;
        
        
        % Area
        temporalResults{k2,7} = currentObjects;
        %     % position x pixels
        temporalResults{k2,8} = currentCentroids(1:2:end);
        %     % Position y pixels
        temporalResults{k2,9} = currentCentroids(2:2:end);
    end
    k2=k2+1;

end
%% Assign labels to cars


selectLane2         = temporalResults2(:,2)==2;tilt = 0.15;
currentLane         = temporalResults2(selectLane2,:);
currentLane_tilt    = currentLane(:,3)+tilt*currentLane(:,1);
[a,b]               = sort(currentLane_tilt);
labelLane2          = 1+[0; cumsum(diff(a)>0.5)];
currentLane(b,5)    = labelLane2; 
temporalResults2(selectLane2,5)= currentLane(:,5);

selectLane3         = temporalResults2(:,2)==3; tilt=-0.16;
currentLane         = temporalResults2(selectLane3,:);
currentLane_tilt    = currentLane(:,3)+tilt*currentLane(:,1);
[a,b]               = sort(currentLane_tilt);
labelLane3          = 1+ max(labelLane2)+ [0; cumsum(diff(a)>0.5)];
currentLane(b,5)    = labelLane3; 

%temporalResults2(selectLane3,5)= labelLane3;
temporalResults2(selectLane3,5)= currentLane(:,5);

%% Save as .txt  files
% Create the folders
if  isempty(dir('traffic'))
    mkdir traffic
end
if isempty(dir(strcat('traffic',filesep,'record0')))
    mkdir (strcat('traffic',filesep,'record0'))
    mkdir (strcat('traffic',filesep,'record0_O'))
end
cars_going_right        = temporalResults2(temporalResults2(:,2)==3,:);
cars_going_left         = temporalResults2(temporalResults2(:,2)==2,:);
cars_going_right_labels = unique(cars_going_right(:,5));
cars_going_left_labels  = unique(cars_going_left(:,5));
num_cars_going_left     = numel(cars_going_left_labels);
num_cars_going_right    = numel(cars_going_right_labels);



%% Create the files
% first, files with the numbers 
file_Ncars0     = strcat('traffic',filesep,'record0',filesep,'Ncars_NLGV_NHGV_record0.txt');
file_Ncars0_O   = strcat('traffic',filesep,'record0_O',filesep,'Ncars_NLGV_NHGV_record0.txt');
writecell({num_cars_going_right;0;0},file_Ncars0)
writecell({num_cars_going_left;0;0},file_Ncars0_O)

% Now the files per car
for counter_right    = 1:num_cars_going_right
    clear data
    current_file    = strcat('traffic',filesep,'record0',filesep,'timexy_car',num2str(counter_right),'_record0.txt');
    current_car     = cars_going_right_labels(counter_right);
    current_car_t   = 1*cars_going_right(cars_going_right(:,5)==current_car,3);
    current_car_x   = cars_going_right(cars_going_right(:,5)==current_car,1);
    %data = [current_car_t current_car_x zeros(size(current_car_t))];
    for counter_steps = 1:  numel(current_car_t)
        
        data{counter_steps,1} = compose("%.2f",current_car_t(counter_steps));
        data{counter_steps,2} = current_car_x(counter_steps);
        data{counter_steps,3} = 0;
    end
    writecell(data,current_file,'Delimiter',' ')
end
for counter_left    = 1:num_cars_going_left
    clear data
    current_file    = strcat('traffic',filesep,'record0_O',filesep,'timexy_car',num2str(counter_left),'_record0.txt');
    current_car     = cars_going_left_labels(counter_left);
    current_car_t   = 1*cars_going_left(cars_going_left(:,5)==current_car,3);
    current_car_x   = cars_going_left(cars_going_left(:,5)==current_car,1);
    %data = [current_car_t current_car_x zeros(size(current_car_t))];
    %data{counter_left,1} =[current_car_t current_car_x zeros(size(current_car_t))];
    for counter_steps = 1:  numel(current_car_t)
        
        data{counter_steps,1} = compose("%.2f",current_car_t(counter_steps));
        data{counter_steps,2} = current_car_x(counter_steps);
        data{counter_steps,3} = 0;
    end
    writecell(data,current_file,'Delimiter',' ')
end



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
        
        

  

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
stepBetweenFrames = 15; 


%[allFrames,medImage,stdImage,videoHandle]  = readVideoBridge(strcat(dir0,'BridgeTraffic.mov'));
[allFrames,medImage,stdImage]   = readVideoBridge(videoHandle,stepBetweenFrames);
numFrames = size(allFrames,4);

%% Find the mask of the Bridge from std
 maskBridge = calculateBridgeMask(stdImage);


%% find the main orientation of the bridge
%[finalBridge,finalMedImage,finalMask,finalLine]  = warpBridge(maskBridge,medImage,medImage);

[finalBridge,finalMedImage,finalMask,finalCentralLine,finalStd,finalMetrics] = warpBridge(maskBridge,medImage,allFrames(:,:,:,1),stdImage);

imagesc(finalBridge)

% Explanation of warping
% http://graphics.cs.cmu.edu/courses/15-463/2006_fall/www/Lectures/warping.pdf

%%
%load laneMasks
%load laneMasks_2021_11_19_1110
%load laneMasks_2021_11_29_1124
load laneMasks_2021_11_30_1124b

% Scale laneMasks to current video
[newR,newC,newL]=size(finalBridge);

laneMasks.upper = imresize (laneMasks.upper,[newR newC]);
laneMasks.lower = imresize (laneMasks.lower,[newR newC]);
laneMasks.foot  = imresize (laneMasks.foot,[newR newC]);
    

toDisplay = 1;

%% Arrange display
if toDisplay ==1
    currentDifference  = (abs(sum(finalBridge,3)- (sum(finalMedImage,3))));
    currentDifference  = currentDifference/max(currentDifference(:));
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
clear F;

 
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
%        temporalResults2=[temporalResults2;[round(currentPosX') round(currentPosY') repmat(k/videoHandle.FrameRate,[numCurrentObjects 1]) currentWeights' ]];
        temporalResults2=[temporalResults2;[round(currentPosX') ([segmentedObjects_P.Lane]') repmat(stepBetweenFrames*k/videoHandle.FrameRate,[numCurrentObjects 1]) currentWeights' currentObjects' ]];
        
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
% Try with cluster


% k1=6501;
% k2=k1+1000;
% X=[currentLane(k1:k2,3),0.1*currentLane(k1:k2,1)];
% Z=linkage(X,'single');
% %figure(1)
% %dendrogram(Z)
% T = cluster(Z,'cutoff',0.5,'Criterion','distance');
%%


% May have issues with cars too close to each other
% Tilt so that a car is horizontal and then assign labels vertically
selectLane2         = temporalResults2(:,2)==2;tilt = 0.63;
currentLane         = temporalResults2(selectLane2,:);
currentLane_tilt    = currentLane(:,3)+tilt*currentLane(:,1);
plot(currentLane(:,3),currentLane(:,1),'.')
axis([0 100 -2 25])
%%
[a,b]               = sort(currentLane_tilt);
diffTilted          = diff(a);
labelLane2          = 1+[0; cumsum(diffTilted>0.36)];

% Clean the labels from 
% A) cases where there are only a few points per track
maxLabLane          = max(labelLane2);
[numLab,caseLab]    = hist(labelLane2,(1:maxLabLane));
medNumLab           = median(numLab(numLab>5));
% B) large labels, which are most likely two labels joined
numLab_stand        = numLab./medNumLab;
% iterate per label
newLabel=1;
for k=1:maxLabLane
    if numLab(k)<5
        % discard
        labelLane2 (labelLane2==caseLab(k))=nan;
    elseif numLab(k)>(1.7*medNumLab)
        % split
        largeLabel = find(labelLane2==caseLab(k));
        numel_LL =numel(largeLabel);
        for k2 = 1:medNumLab:numel_LL-1
            labelLane2 (largeLabel(k2:min(numel_LL,k2+medNumLab-1)))= newLabel;
            newLabel = newLabel+1;
        end
    else
        % none
        labelLane2 (labelLane2==caseLab(k))= newLabel;
        newLabel = newLabel+1;
    end  
end
% allocate label
currentLane(b,7)    = labelLane2;
temporalResults2(selectLane2,7)= currentLane(:,7);


selectLane3         = temporalResults2(:,2)==1; tilt=-0.16;
currentLane         = temporalResults2(selectLane3,:);
currentLane_tilt    = currentLane(:,3)+tilt*currentLane(:,1);
[a2,b2]               = sort(currentLane_tilt);
labelLane3          = 1+ max(labelLane3)+ [0; cumsum(diff(a2)>0.36)];

% Clean the labels from 
% A) cases where there are only a few points per track
maxLabLane          = max(labelLane3);
[numLab,caseLab]    = hist(labelLane3,(1:maxLabLane));
medNumLab           = median(numLab(numLab>5));
% B) large labels, which are most likely two labels joined
numLab_stand        = numLab./medNumLab;
% iterate per label
newLabel=1;
for k=1:maxLabLane
    if numLab(k)<5
        % discard
        labelLane3 (labelLane3==caseLab(k))=nan;
    elseif numLab(k)>(1.7*medNumLab)
        % split
        largeLabel = find(labelLane3==caseLab(k));
        numel_LL =numel(largeLabel);
        for k2 = 1:medNumLab:numel_LL-1
            labelLane3 (largeLabel(k2:min(numel_LL,k2+medNumLab-1)))= newLabel;
            newLabel = newLabel+1;
        end
    else
        % none
        labelLane3 (labelLane3==caseLab(k))= newLabel;
        newLabel = newLabel+1;
    end  
end



currentLane(b2,7)    = labelLane3; 

%temporalResults2(selectLane3,5)= labelLane3;
temporalResults2(selectLane3,7)= currentLane(:,7);

%% Save as .txt  files
% Create the folders
if  isempty(dir('traffic'))
    mkdir traffic
end
if isempty(dir(strcat('traffic',filesep,'record0')))
    mkdir (strcat('traffic',filesep,'record0'))
    mkdir (strcat('traffic',filesep,'record0_O'))
end

cars_going_right        = temporalResults2(temporalResults2(:,2)==1,:);
cars_going_left         = temporalResults2(temporalResults2(:,2)==2,:);
cars_going_right_labels = unique(cars_going_right(:,6));
cars_going_left_labels  = unique(cars_going_left(:,6));
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
    current_car_t   = 1*cars_going_right(cars_going_right(:,6)==current_car,3);
    current_car_x   = cars_going_right(cars_going_right(:,6)==current_car,1);
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
    current_car_t   = 1*cars_going_left(cars_going_left(:,6)==current_car,3);
    current_car_x   = cars_going_left(cars_going_left(:,6)==current_car,1);
    %data = [current_car_t current_car_x zeros(size(current_car_t))];
    %data{counter_left,1} =[current_car_t current_car_x zeros(size(current_car_t))];
    for counter_steps = 1:  numel(current_car_t)
        
        data{counter_steps,1} = compose("%.2f",current_car_t(counter_steps));
        data{counter_steps,2} = current_car_x(counter_steps);
        data{counter_steps,3} = 0;
    end
    writecell(data,current_file,'Delimiter',' ')
end



%% Save movie as mp4
output_video = VideoWriter('traffic_2021_12_01', 'MPEG-4');
open(output_video);
writeVideo(output_video,F);
close(output_video);

%% save the movie as a GIF only 100 frames as it is a bit long
[imGif,mapGif] = rgb2ind(F(1).cdata,256,'nodither');
%numFrames = size(F,2);

numFramesToProcess = 100;
imGif(1,1,1,numFramesToProcess) = 0;
for k = 2:numFramesToProcess
    imGif(:,:,1,k) = rgb2ind(F(k).cdata,mapGif,'nodither');
end
%%

imwrite(imGif,mapGif,'traffic_2021_12_01.gif',...
    'DelayTime',0,'LoopCount',inf) %g443800
        
        

  
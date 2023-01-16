
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

%% Define a mask based on the stdImage

mask0 = (mean(stdImage,3));
mask1 = mask0/max(mask0(:));
mask2 = graythresh(mask1);
mask3 = mask1>(0.95*mask2);
mask4 = imclose(mask3,ones(3,15));
%mask5 = (imopen(mask3, ones(7,7)));
mask5 = imfill(imopen(mask4, ones(15,15)),'holes');
%mask5 = bwlabel(mask4);
%mask5b = regionprops(mask5,'area');
mask6 = imdilate(mask5,strel('disk',7));
%mask6 = ismember(mask5,find([mask5b.Area]>5000));
mask7 = repmat(mask6,[1 1 3]);
imagesc(mask7.*medImage/255)
% imagesc(mask3+mask6)

%% Load the detector
detector = yolov4ObjectDetector('csp-darknet53-coco');
disp(detector)
%%
% rr=90:180; cc=340:500;
rr=1:rows;cc=1:cols;

img = mask7.*allFrames(rr,cc,:,1)/255;
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
rr=1:rows;
cc=1:cols;

for k =1:1:numFrames
    disp(k)
    %img                     = mask7.*allFrames(rr,cc,:,k)/255;
    img                     = allFrames(rr,cc,:,k)/255;
    % lower the threshold to avoid losing some weaker detections
    [bboxes,scores,labels]  = detect(detector,mask7.*img,Threshold=0.25);
    % remove all objects that are not of interest (umbrellas, boats, etc.)
    keepIndex               = (labels=='car')|(labels=='person')|(labels=='bus')|(labels=='truck')|(labels=='motorbike');
    labels                  = labels(keepIndex);
    bboxes                  = bboxes(keepIndex,:);
    scores                  = scores(keepIndex);
    keepIndex               = logical(ones(size(scores)));
    % with a lower threshold, there are cases where two labels are
    % detected for a single object, merge
    if size(bboxes,1)>1
        % there is overlap only if there are 2 or more objects
        [overlap,sizeROI]       = detectBoxesOverlap(bboxes,rows,cols);
        [obj1,obj2]             = ind2sub(size(overlap),find(overlap>0.5));
        for k2 = 1:numel(obj1)
            %process each overlap separately
            %disp(labels(obj1(k2)))
            %disp(labels(obj2(k2)))
            if labels(obj1(k2))==labels(obj2(k2))
                % same object, keep the first
                keepIndex(obj2(k2))   = 0;
            else
                % different objects person/motorcycle, car/truck, etc
                if      (labels(obj1(k2))=='person'&labels(obj2(k2))=='motorbike')
                    % keep the motorbike
                    keepIndex(obj1(k2))   = 0;
                elseif  (labels(obj2(k2))=='person'&labels(obj1(k2))=='motorbike')
                    % keep the motorbike
                    keepIndex(obj2(k2))   = 0;
                elseif  (labels(obj1(k2))=='car'&labels(obj2(k2))=='truck')
                    % keep depending on size of the box
                    if sizeROI(obj1(k2))>3000
                        % keep the truck
                        keepIndex(obj2(k2))   = 0;
                    else
                        % keep the car
                        keepIndex(obj1(k2))   = 0;
                    end
                elseif  (labels(obj1(k2))=='truck'&labels(obj2(k2))=='car')
                    if sizeROI(obj1(k2))>3000
                        % keep the truck
                        keepIndex(obj1(k2))   = 0;
                    else
                        % keep the car
                        keepIndex(obj2(k2))   = 0;
                    end
                elseif  (labels(obj1(k2))=='car'&labels(obj2(k2))=='motorbike')
                    % keep depending on size of the box
                    if sizeROI(obj1(k2))<300
                        % keep the motorbike
                        keepIndex(obj2(k2))   = 0;
                    else
                        % keep the car
                        keepIndex(obj1(k2))   = 0;
                    end
                elseif  (labels(obj1(k2))=='motorbike'&labels(obj2(k2))=='car')
                    if sizeROI(obj1(k2))<300
                        % keep the motorbike
                        keepIndex(obj2(k2))   = 0;
                    else
                        % keep the car
                        keepIndex(obj1(k2))   = 0;
                    end
                else
                    % bus and truck ?
                     keepIndex(obj2(k2))   = 0;
                    disp(labels(obj1(k2)))
                    disp(labels(obj2(k2)))
                    qqq=1;
                end
            end
        end

    end
    try
        labels                  = labels(keepIndex);
    catch
        qq=1;
    end
    bboxes                  = bboxes(keepIndex,:);
    scores                  = scores(keepIndex);
    detectedImg = insertObjectAnnotation(img,"Rectangle",bboxes,labels);
    imagesc(detectedImg)
    pause(0.05)
    %drawnow
end
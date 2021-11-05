function [allFrames,medImage,stdImage] = readVideoBridge(BridgeVideo)


%% Alternative input from the video
%v=VideoReader('BridgeTraffic.mov');
v=VideoReader(BridgeVideo);
try

    numFrames = v.NumFrames;
catch
    numFrames = v.Duration*v.FrameRate;
end
    
firstFrame = read(v,1);
[rows,cols,levs] = size(firstFrame);
%% Read all the frames

allFrames(rows,cols,3,numFrames)=0;
rChannel(rows,cols,numFrames)=0;
gChannel(rows,cols,numFrames)=0;
bChannel(rows,cols,numFrames)=0;


for k=1:numFrames
    disp(k)
    % read the from the 
    % tempImage = imread(strcat('BridgeTraffic/',dir0(k).name));
    % Read from the video
    currImage = read(v,k);
    allFrames(:,:,:,k)=currImage;
    rChannel(:,:,k) = currImage(:,:,1);
    gChannel(:,:,k) = currImage(:,:,2);
    bChannel(:,:,k) = currImage(:,:,3);
end


rChannelMed = median(rChannel,3);
gChannelMed = median(gChannel,3);
bChannelMed = median(bChannel,3);
medImage(:,:,1) = rChannelMed;
medImage(:,:,2) = gChannelMed;
medImage(:,:,3) = bChannelMed;
meanImage(:,:,1) = mean(rChannel,3);
meanImage(:,:,2) = mean(gChannel,3);
meanImage(:,:,3) = mean(bChannel,3);
stdImage(:,:,1) = std(double(rChannel),[],3);
stdImage(:,:,2) = std(double(gChannel),[],3);
stdImage(:,:,3) = std(double(bChannel),[],3);

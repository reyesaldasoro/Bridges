function [allFrames,medImage,stdImage] = readVideoBridge(BridgeVideo,stepBetweenFrames)


if ~exist('stepBetweenFrames','var')
    stepBetweenFrames = 1;
end

%% Alternative input from the video
%v=VideoReader('BridgeTraffic.mov');
if ~isa(BridgeVideo,'handle')
    v           = VideoReader(BridgeVideo);
else
    v           = BridgeVideo;
end
try
    numFrames   = floor(v.NumFrames                / stepBetweenFrames);
catch
    numFrames   = floor(v.Duration*v.FrameRate     / stepBetweenFrames);
end
    
firstFrame = read(v,1);
[rows,cols,levs] = size(firstFrame);
%% Read all the frames

initialFrame            = stepBetweenFrames;


allFrames(rows,cols,3,numFrames)=0;
rChannel(rows,cols,numFrames)=0;
gChannel(rows,cols,numFrames)=0;
bChannel(rows,cols,numFrames)=0;

% Reading whilst skipping frames slows down a lot, better the routine where
% all frames are read but only a few are stored
% %for %k=stepBetweenFrames:  stepBetweenFrames: numFrames
% for    k= 1 : numFrames
%     disp(k*stepBetweenFrames)
%     % read the from the 
%     % tempImage = imread(strcat('BridgeTraffic/',dir0(k).name));
%     % Read from the video
%     currImage = read(v,k*stepBetweenFrames);
%     allFrames(:,:,:,k)=currImage;
%     rChannel(:,:,k) = currImage(:,:,1);
%     gChannel(:,:,k) = currImage(:,:,2);
%     bChannel(:,:,k) = currImage(:,:,3);
% end


for    k= 1 : v.numFrames
    currImage = read(v,k);
%    disp(k)
     if mod(k,stepBetweenFrames)==0
         disp(k)
         %imagesc(currImage)
         %drawnow
%         % Read from the video
         k2=floor(k/stepBetweenFrames);
         allFrames(:,:,:,k2)=currImage;
         rChannel(:,:,k2) = currImage(:,:,1);
         gChannel(:,:,k2) = currImage(:,:,2);
         bChannel(:,:,k2) = currImage(:,:,3);
     end
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

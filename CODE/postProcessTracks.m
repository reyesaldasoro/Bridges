function [cummulativeResultsPost]  =postProcessTracks(cummulativeResults)
%% post process tracks to join broken ones
% first, check the span of the tracks
numTracksR          = max(cummulativeResults(:,13));
numTracksL          = min(cummulativeResults(:,13));
for kk=1:numTracksR
    TrackR          = cummulativeResults(cummulativeResults(:,13)==kk,:);
    if isempty(TrackR)
        spanTrackR(kk,1) = 0;
    else
        spanTrackR(kk,1)  = TrackR(end,1) - TrackR(1,1);
    end
end
for kk=-1:-1:numTracksL
    TrackL          = cummulativeResults(cummulativeResults(:,13)==kk,:);
    if isempty(TrackL)
        spanTrackL(-kk,1) = 0;
    else
        spanTrackL(-kk,1)  = -TrackL(end,1) + TrackL(1,1);
    end
%    spanTrackL(-kk,1)  = -TrackL(end,1) + TrackL(1,1);
end

%% Search to join, only forward right
cummulativeResultsPost = cummulativeResults;
for counterTrackR = 1: numTracksR
    clear qq
    % only join if smaller than 40
    if spanTrackR(counterTrackR)<43
        TrackR          = cummulativeResults(cummulativeResults(:,13)==counterTrackR,:);
        if ~isempty(TrackR)
            for counter2 = counterTrackR+1:numTracksR
                if spanTrackR(counter2)<43
                    TrackR2          = cummulativeResults(cummulativeResults(:,13)==counter2,:);
                    if ~isempty(TrackR2)
                        %try
                        qq(counter2,:) =TrackR2(1,[1 4]) - TrackR(end,[1 4]);
                        %catch
                        %    wwww=1;
                    end
                end
            end
            %
            if exist('qq','var')
                % do not consider anything negative (backwards) or zero
                qq(qq(:,1)<=0,:) = inf;
                qq(qq(:,2)<0,:) = inf;

                % maximum span between frames = 5
                qq(qq(:,2)>5,:) = inf;
                % maximum distance between points = 25 (half the bridge!)
                qq(qq(:,1)>15,:) = inf;
                [distLink,linkTrack] = min(sum(qq,2));
                if distLink<30
                    %merge trackR and trackR2
                    % TrackR2          = cummulativeResults(cummulativeResults(:,13)==linkTrack,:);
                    %disp([counterTrackR linkTrack])
                    indexTrackR2      = cummulativeResults(cummulativeResults(:,13)==linkTrack,12);
                    % assign parent
                    cummulativeResultsPost(indexTrackR2(1),11) = TrackR(end,12);
                    % assign track number
                    cummulativeResultsPost(indexTrackR2,13)    = TrackR(end,13);

                end
            end
        end
    end
end
%%

%% Search to join, only forward left

for counterTrackL = -1:-1:numTracksL
    clear qq
    % only join if smaller than 40
    if spanTrackL(-counterTrackL)<43
        TrackL          = cummulativeResults(cummulativeResults(:,13)==counterTrackL,:);
        if ~isempty(TrackL)
            for counter2 = counterTrackL-1:-1:numTracksL
                if spanTrackL(-counter2)<43
                    TrackL2          = cummulativeResults(cummulativeResults(:,13)==counter2,:);
                    if ~isempty(TrackL2)
                        %try
                        qq(-counter2,:) =TrackL2(1,[1 4]) - TrackL(end,[1 4]);
                        %catch
                        %    wwww=1;
                    end
                end
            end
            %
            if exist('qq','var')
                % do not consider anything negative (backwards) or zero
                qq(qq(:,1)>=0,:) = inf;
                qq(qq(:,2)<0,:) = inf;

                % maximum span between frames = 5
                qq(qq(:,2)>5,:) = inf;
                % maximum distance between points = 25 (half the bridge!)
                qq(qq(:,1)<-15,:) = inf;
                [distLink,linkTrack] = min(qq(:,2)-qq(:,1));
                if distLink<30
                    %merge TrackL and TrackL2
                     TrackL2          = cummulativeResults(cummulativeResults(:,13)==-linkTrack,:);
                    disp([counterTrackL linkTrack])
                    indexTrackL2      = cummulativeResults(cummulativeResults(:,13)==-linkTrack,12);
                    % assign parent
                    try
                    cummulativeResultsPost(indexTrackL2(1),11) = TrackL(end,12);
                    catch
                        www=1;
                    end
                    % assign track number
                    cummulativeResultsPost(indexTrackL2,13)    = TrackL(end,13);
                    % increase span
                    %spanTrackL(linkTrack)                       = 50;
                end
            end
        end
    end
end
%%




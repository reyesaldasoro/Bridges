function [cummulativeResults,labelsCurrent,currentResults]  = trackObjectsBridge(cummulativeResults,temporalResultsonBridge)
%% track objects from time t-1 to time t
% Cummulative results will have a record of each object at each time point
% 1  - position x (along the bridge
% 2  - position y (lane)
% 3  - Lane 1 towards the right, 2 towards the left
% 4  - time frame
% 5  - time in seconds
% 6  - label 1 person, 2 motorbike, 3 car, 4 truck, 5 bus
% 7-9- RGB of object 
% 10 - unique tag in frame - towards left + towards right
% 11 - parent
% 12 - unique number 
% 13 - track number




numCurrentCars                  = size(temporalResultsonBridge,1);
currentFrameN                   = temporalResultsonBridge(1,4);
if isempty(cummulativeResults)
    lastCar             = 0;
else
    lastCar             = cummulativeResults(end,12);
end
if (currentFrameN==1)
    cummulativeResults    = [[temporalResultsonBridge zeros(numCurrentCars,1) lastCar+(1:numCurrentCars)' zeros(numCurrentCars,1)]];
    % newLabels            = cummulativeResults(cummulativeResults(:,4)==currentFrameN,13);

else
    if (numCurrentCars>0)
        %% add unique ID per car
        cummulativeResults    = [cummulativeResults;[temporalResultsonBridge zeros(numCurrentCars,1) lastCar+(1:numCurrentCars)' zeros(numCurrentCars,1)]];

        %% track objects by matching t+1 with t, per lane per time

        previousFrame               = (cummulativeResults(:,4)==(currentFrameN-1));
        currentFrame                = (cummulativeResults(:,4)==(currentFrameN));

        %in previous frame
        vehiclesOnly                = cummulativeResults(:,6)>2;
        carsMovingRight             = cummulativeResults(:,3)==1;
        carsMovingLeft              = cummulativeResults(:,3)==2;
        carsRight_t                 = cummulativeResults(carsMovingRight&previousFrame&vehiclesOnly,:);
        carsLeft_t                  = cummulativeResults(carsMovingLeft &previousFrame&vehiclesOnly,:);

        %in current frame
        %vehiclesOnly                = temporalResults1(:,6)>1;
        %carsMovingRight             = temporalResults1(:,3)==1;
        %carsMovingLeft              = temporalResults1(:,3)==2;
        carsRight_t1                = cummulativeResults(carsMovingRight&currentFrame&vehiclesOnly,:);
        carsLeft_t1                 = cummulativeResults(carsMovingLeft&currentFrame&vehiclesOnly,:);
        %%


        % Match each car in each lane with previous
        clear matchL matchR

        % First cars towards the Left
        for k1 = 1:size(carsLeft_t1,1)
            distForward             = (carsLeft_t1(k1,1)-carsLeft_t(:,1));
            if isempty(distForward)
                % first appearance, assign a new number
                %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
            else
                % keep within mean+-3*std
                isMatch = find((distForward<0.1)&(distForward>-5),1,"last");
                if (isnan(isMatch))
                    % first appearance, assign a new number
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                elseif isempty(isMatch)
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                else
                    % allocate parent if it has not been previously
                    % allocated
                    try
                        parentToBeAllocated                          = carsLeft_t(isMatch,12);
                        if ~any(any(cummulativeResults(:,11)==parentToBeAllocated))
                            cummulativeResults( carsLeft_t1(k1,12) ,11 ) = parentToBeAllocated;
                            % allocate track
                            currTrack               = cummulativeResults(parentToBeAllocated,13);
                            if (currTrack~=0)
                                % track exists
                                cummulativeResults( carsLeft_t1(k1,12) ,13 ) = currTrack;
                            else
                                % new track, going left is negative
                                currTrack = min(cummulativeResults(:,13))-1;
                                cummulativeResults( carsLeft_t1(k1,12) ,13 )    = currTrack;
                                cummulativeResults( parentToBeAllocated,13 ) = currTrack;
                            end
                        end

                    catch
                        q=1;
                    end
                end
            end
        end
        % Cars towards the right
        for k1 = 1:size(carsRight_t1,1)
            distForward             = (-carsRight_t1(k1,1)+carsRight_t(:,1));
            %distForward             = (carsLeft_t1(k1,1)-carsLeft_t(:,1)+1);
            if isempty(distForward)
                % first appearance, assign a new number
                %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
            else
                isMatch = find((distForward<0.1)&(distForward>-5),1,"last");
                if (isnan(isMatch))
                    % first appearance, assign a new number
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                elseif isempty(isMatch)
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                else
                    % allocate parent
                    try
                        parentToBeAllocated                          = carsRight_t(isMatch,12);

                        if ~any(any(cummulativeResults(:,11)==parentToBeAllocated))

                            cummulativeResults( carsRight_t1(k1,12) ,11 ) = parentToBeAllocated;
                                         currTrack               = cummulativeResults(parentToBeAllocated,13);
                            if (currTrack~=0)
                                % track exists
                                cummulativeResults( carsRight_t1(k1,12) ,13 ) = currTrack;
                            else
                                % new track, going left is negative
                                currTrack = max(cummulativeResults(:,13))+1;
                                cummulativeResults( carsRight_t1(k1,12) ,13 )    = currTrack;
                                cummulativeResults( parentToBeAllocated,13 ) = currTrack;
                            end

                        end
                    catch
                        q=1;
                    end
                end
            end
        end
       % newLabels = cummulativeResults(cummulativeResults(:,4)==currentFrameN,13);
    else
       % newLabels = cummulativeResults(cummulativeResults(:,4)==currentFrameN,13);

        %numCurrentCars      = size(temporalResults1,1);
        %temporalResults5    = [temporalResults1 zeros(numCurrentCars,1) (1:numCurrentCars)'];
    end
end
%%
currentResults  = cummulativeResults(cummulativeResults(:,4)==currentFrameN,:);
for k=1:numCurrentCars
    if currentResults(k,13)~=0
        labelsCurrent{k,1}   =num2str(currentResults(k,13));
    else
        labelsCurrent{k,1}   ='';
    end
end
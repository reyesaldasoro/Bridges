function [temporalResults5]  = trackObjectsBridge(temporalResults5,temporalResults1)
%%
numCurrentCars                  = size(temporalResults1,1);
currentFrameN                   = temporalResults1(1,4);
if isempty(temporalResults5)
    lastCar = 0;
else
    lastCar = temporalResults5(end,12);
end
if (currentFrameN==1)
    temporalResults5    = [[temporalResults1 zeros(numCurrentCars,1) lastCar+(1:numCurrentCars)']];
else
    if (numCurrentCars>0)
        %% add unique ID per car
        temporalResults5    = [temporalResults5;[temporalResults1 zeros(numCurrentCars,1) lastCar+(1:numCurrentCars)']];

        %% track objects by matching t+1 with t, per lane per time

        previousFrame               = (temporalResults5(:,4)==(currentFrameN-1));
        currentFrame                = (temporalResults5(:,4)==(currentFrameN));

        %in previous frame
        vehiclesOnly                = temporalResults5(:,6)>2;
        carsMovingRight             = temporalResults5(:,3)==1;
        carsMovingLeft              = temporalResults5(:,3)==2;
        carsRight_t                 = temporalResults5(carsMovingRight&previousFrame&vehiclesOnly,:);
        carsLeft_t                  = temporalResults5(carsMovingLeft &previousFrame&vehiclesOnly,:);

        %in current frame
        %vehiclesOnly                = temporalResults1(:,6)>1;
        %carsMovingRight             = temporalResults1(:,3)==1;
        %carsMovingLeft              = temporalResults1(:,3)==2;
        carsRight_t1                = temporalResults5(carsMovingRight&currentFrame&vehiclesOnly,:);
        carsLeft_t1                 = temporalResults5(carsMovingLeft&currentFrame&vehiclesOnly,:);
        %%


        % Match each car in each lane with previous
        clear matchL matchR

        % First cars towards the Left
        for k1 = 1:size(carsLeft_t1,1)
            distForward             = (carsLeft_t1(k1,1)-carsLeft_t(:,1)+1);
            if isempty(distForward)
                % first appearance, assign a new number
                %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
            else
                isMatch = find(distForward<0,1,"last");
                if (isnan(isMatch))
                    % first appearance, assign a new number
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                elseif isempty(isMatch)
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                else
                    % allocate parent
                    try
                        temporalResults5( carsLeft_t1(k1,12) ,11 ) = carsLeft_t(isMatch,12);
                    catch
                        q=1;
                    end
                end
            end
        end
        % Cars towards the right
        for k1 = 1:size(carsRight_t1,1)
            distForward             = (-carsRight_t1(k1,1)+carsRight_t(:,1)+1);
            %distForward             = (carsLeft_t1(k1,1)-carsLeft_t(:,1)+1);
            if isempty(distForward)
                % first appearance, assign a new number
                %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
            else
                isMatch = find(distForward<0,1,"last");
                if (isnan(isMatch))
                    % first appearance, assign a new number
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                elseif isempty(isMatch)
                    %temporalResults5( carsLeft_t1(k1,12) ,11 ) = 1+max(temporalResults5(:,11));
                else
                    % allocate parent
                    try
                        temporalResults5( carsRight_t1(k1,12) ,11 ) = carsRight_t(isMatch,12);
                    catch
                        q=1;
                    end
                end
            end
        end






            %         try
            %             matchL(k1)          = find(distForward<0,1,"last");
            %         catch
            %             matchL(k1)          = nan;
            %         end

        %     for k1 = 1:size(carsLeft_t,1)
        %         distForward             = (carsLeft_t(k1,1)-carsLeft_t1(:,1));
        %         try
        %             matchL(k1)          = find(distForward>0,1);
        %         catch
        %             matchL(k1)          = nan;
        %         end
        %     end
        %     for k1 = 1:size(carsRight_t,1)
        %         distForward             = (-carsRight_t(k1,1)+carsRight_t1(:,1));
        %         try
        %             matchR(k1)          = find(distForward>0,1);
        %         catch
        %             matchR(k1)          = nan;
        %         end
        %     end
        %%


        %%

    else
        %numCurrentCars      = size(temporalResults1,1);
        %temporalResults5    = [temporalResults1 zeros(numCurrentCars,1) (1:numCurrentCars)'];
    end
end
%%
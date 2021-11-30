if toDisplay==1
    figure(10)
    clf
    h1=gca;
    % foot
    labelsObjects={'P','C','C'};
    coloursObjects={'P','b','k'};
    
    counterLane=1;
          selectLane      = temporalResults2(:,2)==counterLane;
        currentLane     = temporalResults2(selectLane,:);
        numObjects      = size(currentLane,1);
        hh(counterLane) =subplot(1,3,counterLane);
        for counterTimeP=1:numObjects
            text(currentLane(counterTimeP,1),currentLane(counterTimeP,3),labelsObjects{counterLane},'fontsize',5,'color','r')
        end
        %    subplot(131)
        axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])
        axis ij
        ylabel('Time [sec]')
        xlabel('Position [m]')
        grid on
    
    for counterLane = 2:3
        selectLane      = temporalResults2(:,2)==counterLane;
        currentLane     = temporalResults2(selectLane,:);
        numObjects      = size(currentLane,1);
        hh(counterLane) =subplot(1,3,counterLane);
        for counterTimeP=1:numObjects
            %             text(currentLane(counterTimeP,1),currentLane(counterTimeP,3),strcat(labelsObjects{counterLane},13,num2str(currentLane(counterTimeP,5))),'fontsize',6,'color',coloursObjects{counterLane})
            %  text(currentLane(counterTimeP,1),currentLane(counterTimeP,3),strcat(labelsObjects{counterLane}),'fontsize',6,'color',coloursObjects{counterLane})
            if currentLane(counterTimeP,4)==1500
                text(currentLane(counterTimeP,1),0.0065+currentLane(counterTimeP,3),...
                    'C','fontsize',5,'color','k')
                text(currentLane(counterTimeP,1),0.65+currentLane(counterTimeP,3),...
                    num2str(currentLane(counterTimeP,5)),'fontsize',5,'color','k')
                %               text(currentLane(counterTimeP,1),0.65+currentLane(counterTimeP,3),...
                %                   strcat('C',13,32,num2str(currentLane(counterTimeP,5))),...
                %                   'fontsize',5,'color',coloursObjects{counterLane})
            else
                text(currentLane(counterTimeP,1),0.0065+currentLane(counterTimeP,3),...
                    'M','fontsize',5,'color','b')
                text(currentLane(counterTimeP,1),0.65+currentLane(counterTimeP,3),...
                    num2str(currentLane(counterTimeP,5)),'fontsize',5,'color','b')
                
                %                             text(currentLane(counterTimeP,1),0.65+currentLane(counterTimeP,3),...
                %                   strcat('M',14,32,num2str(currentLane(counterTimeP,5))),...
                %                   'fontsize',5,'color',coloursObjects{counterLane})
            end
        end
        %    subplot(131)
        axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])
        axis ij
        ylabel('Time [sec]')
        xlabel('Position [m]')
        grid on
    end
    %     subplot(132)
    %     axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 numTimePoints+3])
    %     axis ij
    %     ylabel('Time [sec]')
    %     xlabel('Position [m]')
    %         grid on
    %     subplot(133)
    %     axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 numTimePoints+3])
    %     axis ij
    %     ylabel('Time [sec]')
    %     xlabel('Position [m]')
    %     grid on
end

h0=gcf;
h0.Position = [200 200 1200 400];
hh(1).Position = [    0.04    0.12    0.29    0.8];
hh(2).Position = [    0.37    0.12    0.29    0.8];
hh(3).Position = [    0.7    0.12    0.29    0.8];

hh(1).Title.String='(a)';% Pedestrians';
hh(2).Title.String='(b)';%Vehicles traveling to the left';
hh(3).Title.String='(c)';%Vehicles traveling to the right';
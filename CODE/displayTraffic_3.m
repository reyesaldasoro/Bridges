

    figure(9)
    clf
    h1=gca;

    numTimePoints = size(temporalResults,1);
    for counterTimeP=1:1:numTimePoints
        travelRight = temporalResults{counterTimeP,5}==2;
        travelLeft  = temporalResults{counterTimeP,5}==3;
        travelFoot  = temporalResults{counterTimeP,5}==1;
        subplot(131)
        text(temporalResults{counterTimeP,4}(travelFoot),counterTimeP+temporalResults{counterTimeP,5}(travelFoot)/3,temporalResults{counterTimeP,6}(travelFoot),'fontsize',6,'color','r')
        subplot(132)
        text(temporalResults{counterTimeP,4}(travelRight),counterTimeP+temporalResults{counterTimeP,5}(travelRight)/3,temporalResults{counterTimeP,6}(travelRight),'fontsize',8,'color','k')
        subplot(133)
        text(temporalResults{counterTimeP,4}(travelLeft),counterTimeP+temporalResults{counterTimeP,5}(travelLeft)/3,temporalResults{counterTimeP,6}(travelLeft),'fontsize',8,'color','b')
    end
    subplot(131)
    axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 numTimePoints+3])
    axis ij
    ylabel('Time [sec]')
    xlabel('Position [m]')
        grid on
    subplot(132)
    axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 numTimePoints+3])
    axis ij
    ylabel('Time [sec]')
    xlabel('Position [m]')
        grid on
    subplot(133)
    axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 numTimePoints+3])
    axis ij
    ylabel('Time [sec]')
    xlabel('Position [m]')
    grid on

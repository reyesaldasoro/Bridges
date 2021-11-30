if toDisplay==1
    figure(7)
    clf
    h1=gca;

    numTimePoints = size(temporalResults,1);
    for counterTimeP=1:numTimePoints
        travelRight = temporalResults{counterTimeP,5}==2;
        travelLeft  = temporalResults{counterTimeP,5}==3;
        travelFoot  = temporalResults{counterTimeP,5}==1;
        text(temporalResults{counterTimeP,4}(travelFoot),counterTimeP+temporalResults{counterTimeP,5}(travelFoot)/3,temporalResults{counterTimeP,6}(travelFoot),'fontsize',6,'color','r')
        text(temporalResults{counterTimeP,4}(travelRight),counterTimeP+temporalResults{counterTimeP,5}(travelRight)/3,temporalResults{counterTimeP,6}(travelRight),'fontsize',8,'color','k')
        text(temporalResults{counterTimeP,4}(travelLeft),counterTimeP+temporalResults{counterTimeP,5}(travelLeft)/3,temporalResults{counterTimeP,6}(travelLeft),'fontsize',8,'color','b')  
    end   
    axis([-5+min([(temporalResults{:,4})])  5+max([(temporalResults{:,4})]) 0 numTimePoints+3])
    axis ij
    ylabel('Time [sec]')
    xlabel('Position [m]')
end
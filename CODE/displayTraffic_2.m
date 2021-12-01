figure(11)

sideMargin = 2;
h1=subplot(121);
plot(temporalResults2(temporalResults2(:,2)==1,1),temporalResults2(temporalResults2(:,2)==1,3),'.')
        axis ij
        ylabel('Time [sec]')
        xlabel('Position [m]')
         axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])
      
h2=subplot(122);
plot(temporalResults2(temporalResults2(:,2)==2,1),temporalResults2(temporalResults2(:,2)==2,3),'.')
        axis ij
        ylabel('Time [sec]')
        xlabel('Position [m]')
         axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])
      
%%
h0=gcf;
h0.Position = [200 200 1200 600];
h1.Position = [0.05    0.12    0.44    0.8];
h2.Position = [0.54    0.12    0.44    0.8];


h1.Title.String='(a)';% Pedestrians';
h2.Title.String='(b)';%Vehicles traveling to the left';

filename='Fig_traffic_all.png';
print('-dpng','-r400',filename)
%%
upperL=700;
lowerL=760;
h1.YLim = [upperL lowerL];
h2.YLim = [upperL lowerL];


filename='Fig_traffic_zoom.png';
print('-dpng','-r400',filename)
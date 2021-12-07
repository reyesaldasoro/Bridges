figure(11)


cars_going_right        = temporalResults2(temporalResults2(:,2)==1,:);
cars_going_left         = temporalResults2(temporalResults2(:,2)==2,:);
cars_going_right_labels = unique(cars_going_right(:,6));
cars_going_left_labels  = unique(cars_going_left(:,6));
num_cars_going_left     = numel(cars_going_left_labels);
num_cars_going_right    = numel(cars_going_right_labels);

 colors_right            = 0.8*rand(num_cars_going_right,3);
 colors_right(colors_right>1)=1;
 colors_right(colors_right<0)=0;
 
 
 colors_left            = 0.8*rand(num_cars_going_left,3);
 colors_left(colors_left>1)=1;
 colors_left(colors_left<0)=0;

%colors_right=((1:num_cars_going_right)')/num_cars_going_right;
%colors_right(:,3) = (num_cars_going_right:-1:1)'/num_cars_going_right;
sideMargin = 2;
clf
h1=subplot(121);
hold on
for k=1:num_cars_going_right
    current_label = cars_going_right_labels(k);
    current_cars = cars_going_right(cars_going_right(:,6)==current_label,:);
    plot(current_cars(:,1),current_cars(:,3),'.','color',colors_right(k,:))
end
axis ij
ylabel('Time [sec]')
xlabel('Position [m]')
axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])


h2=subplot(122);
hold on
for k=1:num_cars_going_left
    current_label = cars_going_left_labels(k);
    current_cars = cars_going_left(cars_going_left(:,6)==current_label,:);
    plot(current_cars(:,1),current_cars(:,3),'.','color',colors_left(k,:))
end


% plot(cars_going_left(:,1),cars_going_left(:,3),'.')
axis ij
ylabel('Time [sec]')
xlabel('Position [m]')
axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])
      
%%
upperL=1;
lowerL=max(cars_going_left(end,3),cars_going_right(end,3));

h1.YLim = [upperL lowerL];
h2.YLim = [upperL lowerL];

h0=gcf;
h0.Position = [200 200 1200 600];
h1.Position = [0.05    0.12    0.44    0.8];
h2.Position = [0.54    0.12    0.44    0.8];


h1.Title.String='(a)';% Pedestrians';
h2.Title.String='(b)';%Vehicles traveling to the left';

filename='Fig_traffic_all.png';
print('-dpng','-r400',filename)
%%
%upperL=700;
%lowerL=760;

upperL=602;
lowerL=690;

h1.YLim = [upperL lowerL];
h2.YLim = [upperL lowerL];


filename='Fig_traffic_zoom.png';
print('-dpng','-r400',filename)


%%

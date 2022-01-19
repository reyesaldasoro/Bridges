figure(11)
clf

if ~exist('temporalResults2','var')
    load('temporalResults.mat')
end
if size(temporalResults2,2)==6
temporalResults2(:,7)=temporalResults2(:,6);
end

cars_going_right        = temporalResults2(temporalResults2(:,2)==1,:);
cars_going_left         = temporalResults2(temporalResults2(:,2)==2,:);
cars_going_right_labels = unique(cars_going_right(:,7));
cars_going_left_labels  = unique(cars_going_left(:,7));
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
h1=subplot(141);
hold on
for k=1:num_cars_going_right
    current_label = cars_going_right_labels(k);
    current_cars = cars_going_right(cars_going_right(:,7)==current_label,:);
    plot(current_cars(:,1),current_cars(:,3),':.','color',colors_right(k,:))
end
axis ij
ylabel('Time [sec]')
xlabel('Position [m]')
axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])


h2=subplot(142);
hold on
for k=1:num_cars_going_left
    current_label = cars_going_left_labels(k);
    current_cars = cars_going_left(cars_going_left(:,7)==current_label,:);
    plot(current_cars(:,1),current_cars(:,3),':.','color',colors_left(k,:))
end
% plot(cars_going_left(:,1),cars_going_left(:,3),'.')
axis ij
%ylabel('Time [sec]')
xlabel('Position [m]')
axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])
      
upperL=1;
lowerL=max(cars_going_left(end,3),cars_going_right(end,3));

h1.YLim = [upperL lowerL];
h2.YLim = [upperL lowerL];

h0=gcf;
h0.Position = [200 200 1200 600];



%filename='Fig_traffic_all.png';
%print('-dpng','-r400',filename)
%

h3=subplot(143);
hold on
for k=1:num_cars_going_right
    current_label = cars_going_right_labels(k);
    current_cars = cars_going_right(cars_going_right(:,7)==current_label,:);
    plot(current_cars(:,1),current_cars(:,3),':.','color',colors_right(k,:))
end
axis ij
%ylabel('Time [sec]')
xlabel('Position [m]')
axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])


h4=subplot(144);
hold on
for k=1:num_cars_going_left
    current_label = cars_going_left_labels(k);
    current_cars = cars_going_left(cars_going_left(:,7)==current_label,:);
    plot(current_cars(:,1),current_cars(:,3),':.','color',colors_left(k,:))
end
axis ij
axis([-sideMargin+min([(temporalResults{:,4})])  sideMargin+max([(temporalResults{:,4})]) 0 max(temporalResults2(:,3))+3])

%%
hWidth = 0.215;
h1.Position = [0.04    0.12    hWidth    0.8];
h2.Position = [0.285     0.12    hWidth    0.8];
h3.Position = [0.53    0.12    hWidth    0.8];
h4.Position = [0.775     0.12    hWidth    0.8];


h1.Title.String='(a)';% Pedestrians';
h2.Title.String='(b)';%Vehicles traveling to the left';
h3.Title.String='(c)';% Pedestrians';
h4.Title.String='(d)';%Vehicles traveling to the left';
h1.Title.FontSize =15;
h2.Title.FontSize =15;
h3.Title.FontSize =15;
h4.Title.FontSize =15;
%%
%upperL=700;
%lowerL=760;

%upperL=602;
%lowerL=690;

upperL=615;
lowerL=720;

h3.YLim = [upperL lowerL];

upperL=45;
lowerL=120;

h4.YLim = [upperL lowerL];

%%
filename='Fig_traffic_2022_01_10.png';
print('-dpng','-r400',filename)


%%

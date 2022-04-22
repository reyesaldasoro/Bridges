text(temporalResults2(:,3),temporalResults2(:,5),num2str(linspace(1,size(temporalResults2,1))))

%%
hold off
plot(temporalResults2(temporalResults2(:,2)==1,3),temporalResults2(temporalResults2(:,2)==1,5),'r.')
hold on
plot(temporalResults2(temporalResults2(:,2)==2,3),temporalResults2(temporalResults2(:,2)==2,5),'k.')
grid on
axis tight

%%
hold off
plot(temporalResults2(temporalResults2(:,2)==1,7),temporalResults2(temporalResults2(:,2)==1,5),'r.')
hold on
plot(temporalResults2(temporalResults2(:,2)==2,7),temporalResults2(temporalResults2(:,2)==2,5),'c.')
plot( medAreaL1(:,1),medAreaL1(:,2),'ro')
plot( medAreaL2(:,1),medAreaL2(:,2),'ko')


%%

clear medArea*
cars_going_right        = temporalResults2(temporalResults2(:,2)==1,:);
cars_going_left         = temporalResults2(temporalResults2(:,2)==2,:);

maxL1 = max(temporalResults2(temporalResults2(:,2)==1,7));
maxL2 = max(temporalResults2(temporalResults2(:,2)==2,7));

for k=1:maxL1
    medAreaL1(k,1) = k;
    medAreaL1(k,2) = round(median( cars_going_right(cars_going_right(:,7)==k,5)));
end
for k=1:maxL2
    medAreaL2(k,1) = k;
    medAreaL2(k,2) = round(median( cars_going_left(cars_going_left(:,7)==k,5)));
end

figure(1)
subplot(211)
hold off
plot( medAreaL1(:,1),medAreaL1(:,2),'rd')
hold on
plot(temporalResults2(temporalResults2(:,2)==1,7),temporalResults2(temporalResults2(:,2)==1,5),'g.')

axis tight;grid on

subplot(212)
hold off
plot(temporalResults2(temporalResults2(:,2)==2,7),temporalResults2(temporalResults2(:,2)==2,5),'c.')
hold on
plot( medAreaL2(:,1),medAreaL2(:,2),'ko')
axis tight;grid on

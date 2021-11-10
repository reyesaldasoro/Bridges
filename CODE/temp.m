q=17; 
imagesc(F(q).cdata)

temporalResults{q,5}
temporalResults{q,6}

%%
selectLane      = temporalResults2(:,2)==2;tilt = 0.15;
%selectLane      = temporalResults2(:,2)==3; tilt=-0.16;
currentLane     = temporalResults2(selectLane,:);
currentLane_tilt = currentLane(:,3)+tilt*currentLane(:,1);
[a,b]           = sort(currentLane_tilt);
currLabel       = [0; cumsum(diff(a)>0.5)];

qq=[currLabel currLabel currLabel ]/max(currLabel);

figure(21)
%plot(temporalResults2(selectT,1),temporalResults2(selectT,3)+0.13*temporalResults2(selectT,1),'ro');axis ij
plot(currentLane(:,1),currentLane(:,3)+tilt*currentLane(:,1),'o');axis ij
%plot(temporalResults2(selectT,3)-0.16*temporalResults2(selectT,1),'ro');axis ij
figure(22)
plot(currentLane(b,1),a,'r-o');axis ij
figure(23)
plot(cumsum(diff(a)>0.5),'r-o');
grid on
sum(diff(a)>0.5)
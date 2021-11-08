% Figure 2
h0=figure(2);
h1= subplot(131);
 imagesc(repmat(1-maskBridge,[1 1 3]).*(medImage/255))
 axis off
h2=  subplot(132);
imagesc(repmat(1-imdilate(centralLineBridge,ones(3)),[1 1 3]).*(medImage/255))
  axis off
h3 = subplot(133);
hold off
%imagesc(repmat(1-imdilate(centralLineBridge,ones(3)),[1 1 3]).*(medImage/255))
imagesc((medImage/255))
hold on
xy = [lines(1).point1; lines(1).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
axis off

h0.Position = [ 40 200 1100 250];
h1.Position = [0.01    0.05    0.32    0.84];
h2.Position = [0.34    0.05    0.32    0.84];
h3.Position = [0.67    0.05    0.32    0.84];
h1.Title.String ='(a)';
h1.Title.FontSize=16;
h2.Title.String ='(b)';
h2.Title.FontSize=16;
h3.Title.String ='(c)';
h3.Title.FontSize=16;   
   
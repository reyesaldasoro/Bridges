% Fig 1 Bridges

h0=figure(1);
h1= subplot(131);
 imagesc(allFrames(:,:,:,1)/255)
 axis off
h2=  subplot(132);
  imagesc(medImage/255)
  axis off
h3 = subplot(133);
  imagesc(stdImage/25)
    axis off
%
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
% imagesc(warpedBridge.*repmat(1-warpedLine,[1 1 3]))
% 
% avWidthPerColumnW    =   sum(warpedMask);
% %baseColumnsW         = 1:numel(avWidthPerColumnW);
% initialCol          = find(sum(warpedLine),1,'first');
% finalCol            = find(sum(warpedLine),1,'last');
% [~,centralRow]      = max(sum(warpedLine,2));
% baseColumnsW         = initialCol:finalCol;
% %excludeColumnsW      = imdilate(avWidthPerColumnW==0,ones(21));
% excludeColumnsW      = [1:initialCol finalCol:numel(avWidthPerColumnW)];
% %baseColumnsW(excludeColumnsW)=[];
% avWidthPerColumnW(excludeColumnsW)=[];
% widthMaskW              = median(avWidthPerColumnW);
% 
% finalBridge             = warpedBridge(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);
% subplot(313)
% imagesc(finalBridge)
% grid on

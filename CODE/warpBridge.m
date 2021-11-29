function [finalBridge,finalMedImage,finalMask,finalCentralLine,finalStd,finalMetrics] = warpBridge(maskBridge,medImage,currentImage,stdImage)


centralLineBridge   = bwmorph(bwmorph(maskBridge,'thin','inf'),'spur',15);
[HT,thetaH,rhoT]    = hough(centralLineBridge);
hPeaks              = houghpeaks(HT,1);
lines               = houghlines(maskBridge,thetaH,rhoT,hPeaks,'FillGap',5,'MinLength',7);
% figure(4)
% hold off
% imagesc(repmat(1-imdilate(centralLineBridge,ones(3)),[1 1 3]).*(medImage/255))
% hold on
% xy = [lines(1).point1; lines(1).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
% % xy = [lines(2).point1; lines(2).point2];
% %    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
% % xy = [lines(3).point1; lines(3).point2];
% %    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','m');   
%    
%    hold off
   
% avWidthPerColumn    =   sum((imrotate(maskBridge,-180+hPeaks(2))));
% baseColumns         = 1:numel(avWidthPerColumn);
% excludeColumns      = imdilate(avWidthPerColumn==0,ones(21));
% baseColumns(excludeColumns)=[];
% avWidthPerColumn(excludeColumns)=[];
% mdl                 = fitlm(baseColumns,avWidthPerColumn);
%initialWidth        = mdl.Fitted(1);
%finalWidth          = mdl.Fitted(end);
%rotatedBridge       = (imrotate(medImage/255,-180+hPeaks(2)));
%%
% Correction for video of 2017
%T                   = projective2d([1 -0.001 -0.0011; 0.194 1 0.001 ; 0 0 1]);
% Correction suitable for BridgeTraffic_2021_11_19_1110
%T                   = projective2d([1 -0.041 -0.0011; 0.194 1 0.001 ; 0 0 1]);
% Correction suitable for BridgeTraffic_2021_11_29_1124
T                   = projective2d([1 -0.031 -0.0011; 0.194 1 0.001 ; 0 0 1]);
warpedBridge        = imwarp(currentImage/255,(T));
warpedMedImage      = imwarp(medImage/255,(T));
warpedMask          = imwarp(maskBridge,(T));
warpedLine          = imwarp(centralLineBridge,T);
warpedStd           = imwarp(stdImage,T);
% figure(4)
% subplot(311)
% imagesc(medImage/255)
% subplot(312)
% imagesc(warpedBridge.*repmat(1-warpedLine,[1 1 3]))

%%
avWidthPerColumnW    =   sum(warpedMask);
%baseColumnsW         = 1:numel(avWidthPerColumnW);
initialCol          = find(sum(warpedLine),1,'first');
finalCol            = 30 +find(sum(warpedLine),1,'last');
[~,centralRow]      = max(sum(warpedLine,2));
%baseColumnsW         = initialCol:finalCol;
%excludeColumnsW      = imdilate(avWidthPerColumnW==0,ones(21));
excludeColumnsW      = [1:initialCol finalCol:numel(avWidthPerColumnW)];
%baseColumnsW(excludeColumnsW)=[];
avWidthPerColumnW(excludeColumnsW)=[];
widthMaskW              = median(avWidthPerColumnW);

finalBridge             = warpedBridge(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);
finalMedImage           = warpedMedImage(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);
finalMask               = warpedMask(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);
finalCentralLine        = warpedLine(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);
finalStd                = warpedStd(centralRow-widthMaskW:centralRow+widthMaskW,initialCol:finalCol,:);

finalMetrics.initialCol     = initialCol;
finalMetrics.finalCol     = finalCol;
finalMetrics.centralRow     = centralRow;
finalMetrics.widthMaskW     = widthMaskW;



% subplot(313)
% imagesc(finalBridge)
% grid on

function [finalBridge] = warpBridge2(currentImage,finalMetrics)

%%
% Correction for video of 2017
%T                   = projective2d([1 -0.001 -0.0011; 0.194 1 0.001 ; 0 0 1]);
% Correction suitable for BridgeTraffic_2021_11_19_1110
%T                   = projective2d([1 -0.041 -0.0011; 0.194 1 0.001 ; 0 0 1]);
% Correction suitable for BridgeTraffic_2021_11_29_1124
T                   = projective2d([1 -0.031 -0.0011; 0.194 1 0.001 ; 0 0 1]);
warpedBridge        = imwarp(currentImage/255,(T));

% figure(4)
% subplot(311)
% imagesc(medImage/255)
% subplot(312)
% imagesc(warpedBridge.*repmat(1-warpedLine,[1 1 3]))


finalBridge             = warpedBridge(finalMetrics.centralRow-finalMetrics.widthMaskW:finalMetrics.centralRow+finalMetrics.widthMaskW,finalMetrics.initialCol:finalMetrics.finalCol,:);



% subplot(313)
% imagesc(finalBridge)
% grid on

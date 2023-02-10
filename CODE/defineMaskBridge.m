function [mask7,medImagesum] = defineMaskBridge(stdImage,medImage)

%% Define a mask based on the stdImage
% Mask7 defines the area of interest, only over the bridge where there is
% movement, river and all else is discarded
mask0                           = (mean(stdImage,3));
mask1                           = mask0/max(mask0(:));
mask2                           = graythresh(mask1);
mask3                           = mask1>(0.95*mask2);
mask4                           = imclose(mask3,ones(3,15));
%mask5 = (imopen(mask3, ones(7,7)));
mask5                           = imfill(imopen(mask4, ones(15,15)),'holes');
%mask5 = bwlabel(mask4);
%mask5b = regionprops(mask5,'area');
mask6                           = imdilate(mask5,strel('disk',7));
%mask6 = ismember(mask5,find([mask5b.Area]>5000));
mask7                           = repmat(mask6,[1 1 3]);

% Mask8 is the watershed between one side of the bridge and the other
%mask8                           = watershed(bwdist(1-mask6));

% imagesc(mask3+mask6)

medImagesum                 = mask6.* (sum(medImage/255,3));
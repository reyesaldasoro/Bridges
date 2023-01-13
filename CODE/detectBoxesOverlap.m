function overlap = detectBoxesOverlap(bboxes,rows,cols)
%%
numBoxes = size(bboxes,1);
for k1=1:numBoxes-1
    ROI1 = zeros(rows,cols);

    cc1=round(bboxes(k1,1):bboxes(k1,1)+bboxes(k1,3));
    rr1=round(bboxes(k1,2):bboxes(k1,2)+bboxes(k1,4));
    ROI1(rr1,cc1)=1;
    for k2=k1+1:numBoxes
        ROI2 = zeros(rows,cols);
        cc2=round(bboxes(k2,1):bboxes(k2,1)+bboxes(k2,3));
        rr2=round(bboxes(k2,2):bboxes(k2,2)+bboxes(k2,4));
        ROI2(rr2,cc2)=1;
        ROI3 = ROI1+ROI2;
        overlap(k1,k2) =  sum(ROI3(:)==2)/ sum(ROI3(:)>=1);
    end
end
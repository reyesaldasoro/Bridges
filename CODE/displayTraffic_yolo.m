numTracksR = max(cummulativeResults(:,13));

figure

hold on
for kk=1:numTracksR
    numElementsTrack = sum(cummulativeResults(:,13)==kk);
    plot3(cummulativeResults(cummulativeResults(:,13)==kk,1),cummulativeResults(cummulativeResults(:,13)==kk,4),kk*ones(numElementsTrack))
end
hold off

axis ij
axis tight

numTracksL = min(cummulativeResults(:,13));

figure

hold on
for kk=-1:-1:numTracksL
    numElementsTrack = sum(cummulativeResults(:,13)==kk);
    plot3(cummulativeResults(cummulativeResults(:,13)==kk,1),cummulativeResults(cummulativeResults(:,13)==kk,4),kk*ones(numElementsTrack))
end
hold off
axis ij
axis tight

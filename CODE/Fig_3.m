h0=figure(3);
h1      = subplot(311);
h22     = imagesc(finalBridge);

h2      = subplot(312);
h22     = imagesc(finalBridge.*repmat(1-(segmentedObjects>0),[1 1 3]));

h3      = subplot(313);
h33     = imagesc(segmentedObjects);

    drawnow
    %%
h0.Position = [ 40 200 1100 320];
h1.Position = [0.04    0.67    0.95    0.29];
h2.Position = [0.04    0.35    0.95    0.29];
h3.Position = [0.04    0.03    0.95    0.29];
jet2=jet;jet2(1 ,:)=[0 0 0];colormap(jet2)
%%
h1.XTick=[];
h1.YTick=40;
h1.YTickLabel='(a)';
h1.FontSize =16;

h2.XTick=[];
h2.YTick=40;
h2.YTickLabel='(b)';
h2.FontSize =16;
h3.XTick=[];
h3.YTick=40;
h3.YTickLabel='(c)';
h3.FontSize =16;

       
    
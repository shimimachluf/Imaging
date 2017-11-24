function fringePhase(totAppData)

for i = 1 : length(totAppData)
    f = totAppData{i}.data.fits{9};
    y = f.yData;
    x0 = f.y0;
    x = [1:length(y)]+f.yStart-1;
    j = round(x0-0.9*f.TFhwY:x0+0.9*f.TFhwY);
    x1=x(j-f.yStart);
    y1=y(j-f.yStart);
    
    xx = [x1(1):0.1:x1(end)];
    y1 = spline(x1,y1,xx);
    x1 = xx;
    
    [xmin,ymin]=localmin(x1,y1,'cubic');
    [xmax,ymax]=localmin(x1,-y1,'cubic'); 
    ymax=-ymax;


%     figure; 
%     plot(x1, y1, 'b', xmin, ymin, 'or', xmax, ymax, 'og');
    totXMin{i} = xmin-x0;
    totYMin{i} = ymin;
    totXMax{i} = xmax-x0;
    totYMax{i} = ymax;
    
end

xmin_tot=cat(1,totXMin{:});
ymin_tot=cat(1,totYMin{:});
xmax_tot=cat(1,totXMax{:});
ymax_tot=cat(1,totYMax{:});

figure;
plot(xmin_tot, ymin_tot, 'or', xmax_tot, ymax_tot, 'og');

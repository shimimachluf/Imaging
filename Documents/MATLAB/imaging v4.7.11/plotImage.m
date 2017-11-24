
function plotImage(appData)

lineColor = 0.85;
colors = ['r', 'g', 'k', 'c'];

% setWinName(appData);
    
%
% plot the main 

[pic x0 y0] = appData.data.plots{appData.data.plotType}.getPic();
if appData.options.maxVal == 0
    pic = appData.data.plots{appData.data.plotType}.normalizePic(appData, pic);
else
    pic = pic/appData.options.maxVal;
end
[h w] = size(pic);
x = [1 : w];
y = [1 : h];
chipStart = appData.data.camera.chipStart;

xCenter = appData.data.fits{appData.data.fitType}.xCenter;
yCenter = appData.data.fits{appData.data.fitType}.yCenter;
xCenter = max(xCenter, x0);
yCenter = max(yCenter, y0);
xCenter = min(xCenter, x0+w-1-1);
yCenter = min(yCenter, y0+h-1-1);

mouseCenterX = round(appData.data.mouseCenterX / (appData.data.camera.xPixSz * 1000)) - x0;
mouseCenterY = round(appData.data.mouseCenterY / (appData.data.camera.yPixSz * 1000)) - y0;

% xSz = round(appData.data.fits{appData.data.fitType}.xUnitSize)*2;
% ySz = round(appData.data.fits{appData.data.fitType}.yUnitSize)*125; 
% if appData.data.fitType == appData.consts.fitTypes.onlyMaximum
%     xSz = min(xCenter-x0-10, w-(xCenter-x0)-10);
%     ySz = min(yCenter-y0-10, h-(yCenter-y0)-10);
% else
%     xSz = min(xSz, round(w/2-10));
%     ySz = min(ySz, round(h/2-10));
% end

[xFit, yFit] = appData.data.fits{appData.data.fitType}.getXYFitVectors(x+x0-1, y+y0-1);
[xData, yData] = appData.data.plots{appData.data.plotType}.getXYDataVectors(xCenter, yCenter, appData.options.avgWidth);
if appData.data.fPlotMouseCursor
    xLine = [1:xCenter-x0-round(w/10) xCenter-x0+round(w/10):w];
    yLine = [1:yCenter-y0-round(h/10) yCenter-y0+round(h/10):h];
    pic( [yCenter : yCenter+1] -y0+1, xLine) = ones(2, length(xLine)) * lineColor;  % a line at the center (x axis)
    pic(yLine, [xCenter : xCenter+1] -x0+1 ) = ones(length(yLine), 2) * lineColor; % a line at the center (y axis)
    % pic( [yCenter : yCenter+1] -y0+1, [1:xCenter-x0+1-xSz xCenter-x0+1+xSz:w]) = ones(2, w-2*xSz+1) * lineColor;
    % pic([1:yCenter-y0+1-ySz yCenter-y0+1+ySz:h], [xCenter : xCenter+1] -x0+1 ) = ones(h-2*ySz+1, 2) * lineColor;
    
%     try
        if mouseCenterX > 0 && mouseCenterX < w && mouseCenterY > 0 && mouseCenterY < h
            len = 10;
            xLine = [mouseCenterX-3*len : mouseCenterX-len mouseCenterX+len: mouseCenterX+3*len];
            xLine = xLine.*(xLine>0)+(xLine<=0);
            xLine = xLine.*(xLine<w)+w*(xLine>=w);
            
            yLine = [mouseCenterY-3*len : mouseCenterY-len mouseCenterY+len : mouseCenterY+3*len];
            yLine = yLine.*(yLine>0)+(yLine<=0);
            yLine = yLine.*(yLine<h)+h*(yLine>=h);
            
            pic( [mouseCenterY-1 : mouseCenterY+1] +1, xLine) = ones(3, length(xLine)) * lineColor;
            pic(yLine, [mouseCenterX-1 : mouseCenterX+1] +1 ) = ones(length(yLine), 3) * lineColor;
        end
%     catch ME
%     end
    
    pic = appData.data.plots{appData.data.plotType}.createSquare(appData, pic);
end

% height dependent plot
appData.data.imageHeight = appData.consts.maxplotSize;
appData.data.imageWidth = round(appData.consts.maxplotSize*(w / h));
if ( appData.data.imageWidth > appData.consts.maxplotSize )
    appData.data.imageWidth = appData.consts.maxplotSize;
    appData.data.imageHeight = round(appData.consts.maxplotSize*( h / w));
end

% % width dependent plot
% appData.data.imageHeight = round(appData.consts.maxplotSizeH);%*(h / w));
% appData.data.imageWidth = appData.consts.maxplotSizeH * (w / h);
% if ( appData.data.imageWidth > appData.consts.maxplotSize )
%     appData.data.imageWidth = appData.consts.maxplotSize;
%     appData.data.imageHeight = round(appData.consts.maxplotSize*( h / w));
% end

set(appData.ui.plot, 'Position', [5 5 appData.data.imageWidth appData.data.imageHeight]);
set(appData.ui.xPlot, 'Position', [5 5+appData.data.imageHeight+appData.consts.strHeight appData.data.imageWidth appData.consts.xyPlotsHeight]);
set(appData.ui.yPlot, 'Position', [5+appData.data.imageWidth+appData.consts.strHeight*1.5 5 appData.consts.xyPlotsHeight appData.data.imageHeight]);


% [pic x0 y0] = appData.data.plots{appData.data.plotType}.getPic();
% figure;
% imagesc(pic)
% axis image

figure(appData.ui.win);
% fh=figure;
set(appData.ui.win,'CurrentAxes',appData.ui.plot);
colormap(jet(256));
image( ([x(1) x(end)]+x0-1)*appData.data.camera.xPixSz * 1000, ...
    ([y(1) y(end)]+y0-1-chipStart+1)*appData.data.camera.yPixSz * 1000, pic*256);
% image( ([x(1) x(end)]+x0-1)*appData.data.camera.xPixSz * 1000, ...
%     ([y(1) y(end)]+y0-1-chipStart-1)*appData.data.camera.yPixSz * 1000, pic*256);
set( appData.ui.plot, 'XAxisLocation', 'top');
set( appData.ui.plot, 'YAxisLocation', 'right');
% axis image;


% set(gca, 'xticklabel', {}, 'yticklabel', {});
% pos = get(fh, 'position');
% sz = size(pic);
% set(fh, 'position', [pos(1) pos(2) pos(3) pos(3)*sz(1)/sz(2)]);
% set(gca, 'position', [0 0 1 1]);
% text(0.1,0.1, ['detuning: ' num2str(appData.save.saveParamVal) 'MHz']);
% text('units','pixels','position',[10 20],'fontsize',30, 'color', [1 1 1], ...
%     'string', ['detuning: ' num2str(appData.save.saveParamVal) 'MHz'])

% xlabel('Distance [mm]', 'FontSize', appData.consts.fontSize);
% ylabel('Optical Density', 'FontSize', appData.consts.fontSize);
% saveas(fh, ['/Users/ShimonMachluf/Documents/Presentations/2016-03 Okinawa/x_grad movie/pic' num2str(appData.save.picNo) '_det ' num2str(appData.save.saveParamVal) '.png']);%\\MAGSTORE\magstore\data\External\Data\ROI-
% close(fh);

%
% plot x plot
%
figure(appData.ui.win);
set(appData.ui.win,'CurrentAxes',appData.ui.xPlot);
plot((x+x0-1)*appData.data.camera.xPixSz * 1000, xData, 'b');
hold on
% create and plot the xFit vector
if ( length(xFit) == length(x) )
    for i = 1 : size(xFit, 1)
        plot((x+x0-1)*appData.data.camera.xPixSz * 1000, xFit(i, :), colors(i), 'LineWidth', 1);
    end
end
hold off
set( appData.ui.xPlot, 'XAxisLocation', 'top');
set( appData.ui.xPlot, 'YAxisLocation', 'right');
xlabel(appData.ui.xPlot, 'Distance [mm]', 'FontSize', appData.consts.fontSize);
ylabel(appData.ui.xPlot, 'Optical Density', 'FontSize', appData.consts.fontSize);
xtick = get(appData.ui.plot, 'XTick');
set(appData.ui.xPlot, 'XTick', xtick);%/(appData.data.camera.xPixSz * 1000)-xFit(1));%(ytick/(appData.data.camera.yPixSz* 1000)-yFit(1)+appData.data.camera.chipStart)
set(appData.ui.xPlot, 'XTickLabel', []);
set(appData.ui.xPlot, 'XLim', ([x(1) x(end)]+x0-1)*appData.data.camera.xPixSz * 1000);%[1 width]);
% ylim = get(appData.ui.xPlot, 'YLim');
set(appData.ui.xPlot, 'YLim', [min([xData yData]) max([xData yData])]);%[min([yData yFit 0]) ylim(2)]);

%
% plot y plot
%
figure(appData.ui.win);
set(appData.ui.win,'CurrentAxes',appData.ui.yPlot);
% appData.ui.yPlot = gca;
% plot(xData, fliplr(y), 'b');
plot(yData, fliplr(y-y0+1+chipStart+1)*appData.data.camera.yPixSz * 1000, 'b');
% y = [y(1):0.01:y(end)];
% appData.ui.yPlot = gca;
hold on
% create and plot they Fit vector
if ( length(yFit) == length(y) )
%     plot(xFit, fliplr(y), 'r');
    for i = 1 : size(yFit, 1)
%         plot((x+x0-1)*appData.data.camera.xPixSz * 1000, xFit(i, :), colors(i));
        plot(yFit(i, :), fliplr(y-y0+1+chipStart+1)*appData.data.camera.yPixSz * 1000,  colors(i), 'LineWidth', 1);
    end
end
hold off
set( appData.ui.yPlot, 'XAxisLocation', 'top');
set( appData.ui.yPlot, 'YAxisLocation', 'right');
ylabel(appData.ui.yPlot, 'Distance [mm]', 'FontSize', appData.consts.fontSize);
xlabel(appData.ui.yPlot, 'Optical Density', 'FontSize', appData.consts.fontSize);
ytick = get(appData.ui.plot, 'YTick');
% set(appData.ui.yPlot, 'YTick', fliplr(ytick));%fliplr(length(yFit)-(ytick/(appData.data.camera.yPixSz* 1000)-yFit(1)+appData.data.camera.chipStart)));
set(appData.ui.yPlot, 'YTickLabel', []);
set(appData.ui.yPlot, 'YLim', ([y(1) y(end)]-y0+1+chipStart+1)*appData.data.camera.yPixSz * 1000);%[1 length(yFit)]);%yFit(end)-yFit(1)]);
% xlim = get(appData.ui.yPlot, 'XLim');
set(appData.ui.yPlot, 'XLim', [min([xData yData]) max([xData yData])]);
set(appData.ui.yPlot, 'YTick', y(end)*appData.data.camera.yPixSz * 1000 - fliplr(ytick));


%
% plot results
%
figure(appData.ui.win);
% set(appData.ui.win,'CurrentAxes',appData.ui.tmp);
% cla(appData.ui.tmp, 'reset');
% set(appData.ui.tmp, 'XLim', [0 1]);
% set(appData.ui.tmp, 'YLim', [0 1]);

set(appData.ui.stFitResultsAtomNum, 'String','');
set(appData.ui.stFitResultsFitFunction, 'String', '');
set(appData.ui.stFitResults1, 'String', '');
set(appData.ui.stFitResults2, 'String', '');
appData.data.fits{appData.data.fitType}.plotFitResults(appData);

% print(appData.ui.win, 'D:\My Documents\Documents\PhD and Fellowships\PhD Research Proposal\pics\MOT_analysis.eps');
% print('-depsc2', '-opengl', ['-f' num2str(appData.ui.win)], '-r864', 'D:\My Documents\Documents\PhD and Fellowships\PhD Research Proposal\pics\MOT_analysis.eps');


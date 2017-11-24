
function heating(appData, tbReadPics_Callback, lbAvailableAnalyzing_Callback, pbAnalyze_Callback)

folderName = 'Dark Time [ms]-';
readDir = appData.analyze.readDir;
folders = dir([appData.analyze.readDir '\' folderName '*']);
if isempty(folders)
    warndlg('No heating measurement found, check folder', 'Warning', 'modal');
    return;
end

Tx = zeros(1, length(folders));
Ty = zeros(1, length(folders));
darkTime = zeros(1, length(folders));
for ( i = 1 : length(folders) )
    if ( ~folders(i).isdir )
        continue
     end
    dashIndex = find(folders(i).name == '-');
    darkTime(i) = str2double(folders(i).name(dashIndex+1:end)) / 1e6; %in seconds
    appData.analyze.readDir = [readDir '\' folders(i).name];
    set(appData.ui.etReadDir, 'String', appData.analyze.readDir);
    files=dir([appData.analyze.readDir '\data-*.mat']);
    nums = zeros(1, length(files));
    for ( j = 1 : length(files) )
        dotIndex = find(files(j).name == '.');
        dashIndex = find(files(j).name == '-');
        if ( length(dashIndex) == 1 )
            nums(j) = str2double(files(j).name(dashIndex(1)+1 : dotIndex(end)-1));
        else
            nums(j) = str2double(files(j).name(dashIndex(1)+1 : dashIndex(2)-1));
        end
    end
    nums = sort(nums);
    numsStr = mat2str(nums);

    set(appData.ui.etAnalyzePicNums, 'String', numsStr(2:end-1));
    set(appData.ui.tbReadPics, 'Value', 1);
    tbReadPics_Callback(appData.ui.tbReadPics, []);
    set(appData.ui.lbAvailableAnalyzing, 'Value', appData.consts.availableAnalyzing.temperature);
    lbAvailableAnalyzing_Callback(appData.ui.lbAvailableAnalyzing, []);
    [h res] = pbAnalyze_Callback(appData.ui.pbAnalyze, []);
    saveas(h, [readDir '\temperature-' num2str(darkTime(i)) '[s].fig'], 'fig');
    saveas(h, [readDir '\temperature-' num2str(darkTime(i)) '[s].png'], 'png');
    close(h);
    Tx(i) = res{1}(1);
    dTx(i) = res{1}(2);
    Ty(i) = res{1}(3);
    dTy(i) = res{1}(4);
    set(appData.ui.lbAvailableAnalyzing, 'Value', appData.consts.availableAnalyzing.atomNo);
    lbAvailableAnalyzing_Callback(appData.ui.lbAvailableAnalyzing, []);
    [h1 res1] = pbAnalyze_Callback(appData.ui.pbAnalyze, []);
    saveas(h1, [readDir '\atomnum-' num2str(darkTime(i)) '.fig'], 'fig');
    saveas(h1, [readDir '\atomnum-' num2str(darkTime(i)) '.png'], 'png');
    close(h1);
    AtomNum(i) = res1{1}(1);
    dAtomNum(i) = res1{1}(2);
end

weightsx = 1./dTx.^2;
weightsy = 1./dTy.^2;

% calculate and plot heatong
darkTime = darkTime-darkTime(1);
[resX gofX outX] = fit(darkTime', Tx', 'poly1', 'Weights',weightsx); %#ok<NASGU>
confX = confint(resX);
confX = (confX(2,:)-confX(1,:))/2;
[resY gofY outY] = fit(darkTime', Ty', 'poly1', 'Weights',weightsy); %#ok<NASGU>
confY = confint(resY);
confY = (confY(2,:)-confY(1,:))/2;

h = figure;
% plot(darkTime, Tx, 'ob');
errorbar( darkTime, Tx, dTx, 'ob');
hold on
% plot(tof2, resX.p1*tof2+resX.p2, 'c');
plot(resX, 'c');
% plot( darkTime, Ty, 'or');
errorbar( darkTime, Ty, dTy, 'or');
% plot(tof2, resY.p1*tof2+resY.p2, 'm');
plot(resY, 'm');
hold off

title('Heating calculations');
set(gca,'Ylabel',text('String', 'Temperature [\muK]'));
set(gca,'Xlabel',text('String', 'Dark Time [s]'));
set(gcf, 'Name', 'Heating Rate');
legend('off')

% text( darkTime(1)+0.1*darkTime(2), max([Tx, Ty]) * 0.9, {'fit function: ax + b'});
text( darkTime(1)+0.1*(darkTime(2)-darkTime(1)), max([Tx, Ty]) * 0.9, {'fit function: ax + b', ...
    ['in x direction (blue): ' num2str(resX.p1) 'x + ' num2str(resX.p2) ', R^2 = ' num2str(gofX.rsquare) ] ...
    ['       HR_x = ' num2str(resX.p1) ' +/- ' num2str(confX(1) ) ' \muK / s'] ...
    ['       T_{0x} = ' num2str(resX.p2) ' +/- ' num2str(confX(2)) ' \muK' ] ...
    ['in y direction (red):  ' num2str(resY.p1) 'x + ' num2str(resY.p2) ', R^2 = ' num2str(gofY.rsquare) ] ...
    ['       HR_y = ' num2str(resY.p1)    ' +/- ' num2str(confY(1)) ' \muK / s'] ...
    ['       T_{0y} = ' num2str(resY.p2) ' +/- ' num2str(confY(2)) ' \muK' ] });

saveas(h, [readDir '\heating.fig'], 'fig');
saveas(h, [readDir '\heating.png'], 'png');

h1 = figure;
errorbar( darkTime, AtomNum, dAtomNum, 'ob');

title('Atom Numbers');
set(gca,'Ylabel',text('String', 'Atom Num '));
set(gca,'Xlabel',text('String', 'Dark Time [s]'));
set(gcf, 'Name', 'Atom Num');
legend('off')

% text( darkTime(1)+0.1*darkTime(2), max([Tx, Ty]) * 0.9, {'fit function: ax + b'});
% text( darkTime(1)+0.1*(darkTime(2)-darkTime(1)), max([Tx, Ty]) * 0.9, {'fit function: ax + b', ...
%     ['in x direction (blue): ' num2str(resX.p1) 'x + ' num2str(resX.p2) ', R^2 = ' num2str(gofX.rsquare) ] ...
%     ['       HR_x = ' num2str(resX.p1) ' +/- ' num2str(confX(1) ) ' \muK / s'] ...
%     ['       T_{0x} = ' num2str(resX.p2) ' +/- ' num2str(confX(2)) ' \muK' ] ...
%     ['in y direction (red):  ' num2str(resY.p1) 'x + ' num2str(resY.p2) ', R^2 = ' num2str(gofY.rsquare) ] ...
%     ['       HR_y = ' num2str(resY.p1)    ' +/- ' num2str(confY(1)) ' \muK / s'] ...
%     ['       T_{0y} = ' num2str(resY.p2) ' +/- ' num2str(confY(2)) ' \muK' ] });

saveas(h1, [readDir '\AtomNum.fig'], 'fig');
saveas(h1, [readDir '\AtomNum.png'], 'png');


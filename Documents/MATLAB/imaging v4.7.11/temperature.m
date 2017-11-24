
function [graph Result] = temperature(totAppData)
if numel(totAppData) > 1
len = length(totAppData);
tof = zeros(1, len); %[sec]
sx = zeros(1, len); %[meter]
sy = zeros(1, len); %[meter]

fitType = totAppData{1}.data.fitType;

for ( i = 1 : len )
    if ( totAppData{i}.save.saveParam ~= totAppData{i}.consts.saveParams.TOF )
        warndlg({['The save parameter in data-' num2str( totAppData{i}.save.picNo) ' is not TOF (' num2str(totAppData{i}.consts.saveParams.TOF) ').']; ...
            ['It is:' num2str(totAppData{i}.save.saveParam) '.']} , 'Warning', 'modal');
    end
    tof(i) = totAppData{i}.save.saveParamVal;
    sx(i) = totAppData{i}.data.fits{ fitType }.xUnitSize;
    sy(i) = totAppData{i}.data.fits{ fitType }.yUnitSize;
end

tof = tof/(1000*1); % change to seconds
sx = sx  * totAppData{i}.data.camera.xPixSz; % change to meters
sy = sy  * totAppData{i}.data.camera.yPixSz; % change to meters

tof2 = tof.^2;
sx2 = sx.^2;
sy2 = sy.^2;

[resX gofX outX] = fit(tof2', sx2', 'poly1'); %#ok<NASGU>
if ( length(sx2) > 2 )
    confX = confint(resX);
    confX = (confX(2,:)-confX(1,:))/2;
end
[resY gofY outY] = fit(tof2', sy2', 'poly1'); %#ok<NASGU>
if ( length(sy2) > 2 )
    confY = confint(resY);
    confY = (confY(2,:)-confY(1,:))/2;
end

graph = figure( 'FileName', [totAppData{1}.save.saveDir '.fig']);
plot( tof2, sx2, 'ob');
hold on
% plot(tof2, resX.p1*tof2+resX.p2, 'c');
plot(resX, 'c');
plot( tof2, sy2, 'or');
% plot(tof2, resY.p1*tof2+resY.p2, 'm');
plot(resY, 'm');
hold off

title('Temperature calculations');
set(gca,'Ylabel',text('String', 'sigma^2 [m^2]'));
set(gca,'Xlabel',text('String', 'TOF^2 [sec^2]'));
set(gcf, 'Name', 'Temperature');
legend('off')

Tx = resX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;
Ty = resY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;

Result = [Tx Ty];

if numel(totAppData)>2
text( tof2(1)+0.1*tof2(2), max(sx2(len), sy2(len)) * 0.9, {'fit function: ax + b', ...
    ['in x direction (blue): ' num2str(resX.p1) 'x + ' num2str(resX.p2) ', R^2 = ' num2str(gofX.rsquare) ] ...
    ['       T_x = ' num2str(resX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ...
            ' +/- ' num2str(confX(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
    ['       \sigma_{0x} = ' num2str(sqrt(resX.p2)*1000) ' +/- ' num2str(confX(2)*1000) ' mm' ] ...
    ['in y direction (red):  ' num2str(resY.p1) 'x + ' num2str(resY.p2) ', R^2 = ' num2str(gofY.rsquare) ] ...
    ['       T_y = ' num2str(resY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6)  ...
            ' +/- ' num2str(confY(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
    ['       \sigma_{0y} = ' num2str(sqrt(resY.p2)*1000) ' +/- ' num2str(confX(2)*1000) ' mm' ] });
else
    text( tof2(1)+0.1*tof2(2), max(sx2(len), sy2(len)) * 0.9, {'fit function: ax + b', ...
    ['in x direction (blue): ' num2str(resX.p1) 'x + ' num2str(resX.p2) ', R^2 = ' num2str(gofX.rsquare) ] ...
    ['       T_x = ' num2str(resX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
    ['       \sigma_{0x} = ' num2str(sqrt(resX.p2)*1000)  ' mm' ] ...
    ['in y direction (red):  ' num2str(resY.p1) 'x + ' num2str(resY.p2) ', R^2 = ' num2str(gofY.rsquare) ] ...
    ['       T_y = ' num2str(resY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6)  ' \muK'] ...
    ['       \sigma_{0y} = ' num2str(sqrt(resY.p2)*1000) ' mm' ] });
end
else
     graph =[];
     Result = [];
end



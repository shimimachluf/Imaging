
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

tof = tof/(1000*1000); % change to seconds
sx = sx  * totAppData{i}.data.camera.xPixSz; % change to meters
sy = sy  * totAppData{i}.data.camera.yPixSz; % change to meters

tof2 = tof.^2;
sx2 = sx.^2;
sy2 = sy.^2;

newtof=[];
newsx=[];
newsy=[];
for i = 1:length(tof)
    if (numel(find(newtof==tof(i)))==0) 
        newtof = [newtof tof(i)]; 
        newsx(numel(newtof)) = mean(sx(find(tof==tof(i))));
        errorsx=std(sx(find(tof==tof(i))));
        newsy(numel(newtof)) = mean(sy(find(tof==tof(i))));
        errorsy=std(sy(find(tof==tof(i))));
    end
end

newtof2 = newtof.^2;
newsx2 = newsx.^2;
errorsx2 = 2*newsx*errorsx;
% weightsx=ones(size(errorsx2));
if ( errorsx2 == 0 )
    weightsx = errorsx2 + 1;
else
    weightsx = 1./errorsx2.^2;
end
newsy2 = newsy.^2;
errorsy2 = 2*newsy*errorsy;
if ( errorsy2 == 0 )
    weightsy = errorsy2 + 1;
else
    weightsy = 1./errorsy2.^2;
end
% weightsy=ones(size(errorsy2));
% weightsy = 1./errorsy2.^2;

if tof2(1) < tof2(end) 
    [resX gofX outX] = fit(tof2', sx2', 'poly1'); %#ok<NASGU>
    confX = confint(resX);
    confX = (confX(2,:)-confX(1,:))/2;
    [newresX newgofX newoutX] = fit(newtof2', newsx2', 'poly1', 'Weights',weightsx); %#ok<NASGU>
    newconfX = confint(newresX);
    newconfX = (newconfX(2,:)-newconfX(1,:))/2;
    % [resY gofY outY] = fit(tof2', sy2', 'poly1'); %#ok<NASGU>
    % confY = confint(resY);
    % confY = (confY(2,:)-confY(1,:))/2;
    [newresY newgofY newoutY] = fit(newtof2', newsy2', 'poly1', 'Weights',weightsy); %#ok<NASGU>
    newconfY = confint(newresY);
    newconfY = (newconfY(2,:)-newconfY(1,:))/2;

    graph = figure;
    % plot( tof2, sx2, 'ob');
    hold on
    % plot(tof2, resX.p1*tof2+resX.p2, 'c');
    errorbar( newtof2, newsx2,errorsx2,'ob');
    errorbar( newtof2, newsy2,errorsy2,'or');
    % plot(resX, 'c');
    plot(newresX, 'b');
    % plot( tof2, sy2, 'or');
    % plot(tof2, resY.p1*tof2+resY.p2, 'm');
    % plot(resY, 'm');
    plot(newresY, 'r');
    hold off

    title('Temperature calculations');
    set(gca,'Ylabel',text('String', '\sigma^2 [m^2]'));
    set(gca,'Xlabel',text('String', 'TOF^2 [sec^2]'));
    set(gcf, 'Name', 'Temperature');
    legend('off')

    % Tx = resX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;
    % Ty = resY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;
    newTx = newresX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;
    newTy = newresY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;
    newdTx = newconfX(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;
    newdTy = newconfY(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6;

    Result = [newTx newdTx newTy newdTy];

    %     text( tof2(1)+0.1*tof2(2), max(sx2(len), sy2(len)) * 0.5, {'fit function: ax + b', ...
        %     ['in x direction (blue): ' num2str(resX.p1) 'x + ' num2str(resX.p2) ', R^2 = ' num2str(gofX.rsquare) ] ...
        %     ['       T_x = ' num2str(resX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ...
        %             ' +/- ' num2str(confX(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
        %     ['       \sigma_{0x} = ' num2str(sqrt(resX.p2)*1000) ' +/- ' num2str(confX(2)*1000) ' mm' ] ...
        %     ['in y direction (red):  ' num2str(resY.p1) 'x + ' num2str(resY.p2) ', R^2 = ' num2str(gofY.rsquare) ] ...
        %     ['       T_y = ' num2str(resY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6)  ...
        %             ' +/- ' num2str(confY(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
        %     ['       \sigma_{0y} = ' num2str(sqrt(resY.p2)*1000) ' +/- ' num2str(confX(2)*1000) ' mm' ] });

        text( tof2(1)+0.1*tof2(2), max(sx2(len), sy2(len)) * 0.9, {'fit function: ax + b', ...
        ['in x direction (blue): ' num2str(newresX.p1) 'x + ' num2str(newresX.p2) ', R^2 = ' num2str(newgofX.rsquare) ] ...
        ['       T_x = ' num2str(newresX.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ...
                ' +/- ' num2str(newconfX(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
        ['       \sigma_{0x} = ' num2str(sqrt(newresX.p2)*1000) ' +/- ' num2str(newconfX(2)*1000) ' mm' ] ...
        ['in y direction (red):  ' num2str(newresY.p1) 'x + ' num2str(newresY.p2) ', R^2 = ' num2str(newgofY.rsquare) ] ...
        ['       T_y = ' num2str(newresY.p1 / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6)  ...
                ' +/- ' num2str(newconfY(1) / totAppData{1}.consts.Kb*totAppData{1}.consts.Mrb * 1e6) ' \muK'] ...
        ['       \sigma_{0y} = ' num2str(sqrt(newresY.p2)*1000) ' +/- ' num2str(newconfX(2)*1000) ' mm' ] });

else
     graph =[];
     Result = [];
end
else
     graph =[];
     Result = [];
end



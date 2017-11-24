
function dampedSineY(totAppData)

len = length(totAppData);
DT = zeros(1, len); %[sec]
y = zeros(1, len); %[meter]

fitType = totAppData{1}.data.fitType;

for ( i = 1 : len )
    if ( totAppData{i}.save.saveParam ~= totAppData{i}.consts.saveParams.darkTime )
        warndlg({['The save parameter in data-' num2str( totAppData{i}.save.picNo) ' is not Dark Time (' num2str(totAppData{i}.consts.saveParams.darkTime) ').']; ...
            ['It is:' num2str(totAppData{i}.save.saveParam) '.']} , 'Warning', 'modal');
    end
    DT(i) = totAppData{i}.save.saveParamVal;
    y(i) = totAppData{i}.data.fits{ fitType }.yCenter;
end

DT = DT/(1000*1000); % change to seconds
y = y  * totAppData{i}.data.camera.yPixSz; % change to meters

h = figure;
plot(DT, y, '.b');
xlabel('Dark Time [sec]');
ylabel('Y Position [mm] (from the chip)');
title('Damped Sine in Y direction calculations');
set(h, 'Name', 'Damped Sine in Y direction');

vars = {'A', '[lower uper]', 'x_0', '[lower uper]', '\tau', '[lower uper]', 'f', '[lower uper]', 'c', '[lower uper]'};
vals = {'1e-3', '0 10e-3', '0',  '-1 1', '10e-3',  '0 100e-3', '200', '100 300', '1e-3', '0 5e-3'};
options.Interpreter = 'tex';
options.Resize = 'on';
options.WindowStyle = 'normal';
vals = inputdlg(vars, 'Enter init. guess:', 1, vals, options);

while ( ~isempty(vals) )
%     close(h)
    clf(h)
%     h = figure;
    plot(DT, y, '.b');
    xlabel('Dark Time [sec]');
    ylabel('Y Position [mm] (from the chip)');
    title('Damped Sine in Y direction calculations');
    set(h, 'Name', 'Damped Sine in Y direction');
    
    for ( i = 1 : length(vals)/2 )
        initGuess(i) = eval(vals{2*i - 1}); %#ok<AGROW>
    end
    for ( i = 1  : length(vals)/2 )
        bounds(i, [1 2]) = eval([ '[' vals{2*i} ']' ]); %#ok<AGROW>
    end

    s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', initGuess, 'Lower', bounds(:, 1), 'Upper', bounds(:, 2));
    f = fittype('A*exp(-(x-x0)/T) * sin(2*pi*f*(x-x0)) + c', 'coefficients', {'A', 'x0', 'T', 'f', 'c'}, 'independent', 'x', 'dependent', 'y', 'options', s);
    [res gof out] = fit(DT', y', f); %#ok<NASGU>

    hold on
    plot(DT, res.A*exp(-(DT-res.x0)/res.T) .* sin(2*pi*res.f*(DT-res.x0)) + res.c, 'c');
    text( DT(2), max(y)*0.9, {'fit function: A*e^{-(t-t0)/\tau} * sin(2*pi*f*(t-t0)) + c', ...
        [num2str(res.A) 'e^{-(t-' num2str(res.x0) ')/' num2str(res.T) '} * sin(2*\pi*' num2str(res.f) '*(t-' num2str(res.x0) '))'], ...
        ['     + ' num2str(res.c) ', R^2 = ' num2str(gof.rsquare) ] , ...
        [], ...
        ['A = ' num2str(res.A*1e3) ' mm'], ...
        ['x_0 = ' num2str(res.x0*1e3) ' mm'], ...
        ['\tau = ' num2str(res.T*1e3) ' msec'], ...
        ['f = ' num2str(res.f) ' Hz'], ...
        ['c = ' num2str(res.c*1e3) ' mm']});
    hold off
    
    vals = inputdlg(vars, 'Enter init. guess:', 1, vals, options);
end















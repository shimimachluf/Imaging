function onlyPlot(appData)
%
% Plot image and results
%
try
    plotImage(appData);
catch ME
    msgbox({ME.message, ME.cause, 'file:', ME.stack.file, 'name:', ME.stack.name, 'line', num2str([ME.stack(:).line])}, ...
        'Cannot plot data!!!', 'error', 'modal');
end    
end
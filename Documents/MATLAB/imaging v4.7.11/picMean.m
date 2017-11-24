function appData = picMean(appData)

paramVals = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
[vals, ind, invInd] = unique(paramVals, 'stable');


% there are a few param values
if length(vals) > 1
    folder = [appData.analyze.readDir appData.slash 'averages'];
    [status,message,messageid] = mkdir(folder);
    if ~status
        errordlg('Cannot make ''averages'' folder', 'Error', 'modal');
        return
    end
end

for i = 1 : length(vals)
    pic = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.absorption}.pic));
    atoms = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withAtoms}.pic));
    back = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic));
    dark = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.dark}.pic));
    if isempty(pic)
        errordlg('There is no data in the files. Use f when reading the files.','Error', 'modal');
        return;
    end
    k = find(paramVals == vals(i));
    for ( j = 1 : length(k)) %length(appData.analyze.totAppData)  )
        pic = pic + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.absorption}.pic;
        atoms = atoms + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.withAtoms}.pic;
        back = back + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;
        dark = dark + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.dark}.pic;
    end
    pic = pic / length(k);
    atoms = atoms / length(k);
    back = back / length(k);
    dark = dark / length(k);
    appData = appData.data.plots{appData.consts.plotTypes.absorption}.setPic(appData, [ zeros(appData.data.camera.chipStart-1, size(pic, 2)) ;pic]);
    appData = appData.data.plots{appData.consts.plotTypes.withAtoms}.setPic(appData, atoms);
    appData = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.setPic(appData, back);
    appData = appData.data.plots{appData.consts.plotTypes.dark}.setPic(appData, dark);
    
    %                 appData.data.plots{1}.pic = pic;
    appData.data.fits = appData.consts.fitTypes.fits;
    appData = analyzeAndPlot(appData);
    
    if length(vals) > 1
        savedData = createSavedData(appData);  %#ok<NASGU>
        save([folder appData.slash 'data-' num2str(i) '-paramVal ' num2str(vals(i)) '.mat'], 'savedData', appData.consts.saveVersion);
    end
     
end

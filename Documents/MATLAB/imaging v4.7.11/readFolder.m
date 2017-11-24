function readFolder(appData)

allFolders = dir(appData.analyze.readDir);
allFolders = allFolders(cellfun(@(x) x==1,{allFolders(:).isdir}));

for j = 1 : length(allFolders)
    if strcmp(allFolders(j).name, '.') || allFolders(j).name(1) ~= '.'
        folder = [appData.analyze.readDir appData.slash allFolders(j).name appData.slash];
        files = dir([folder '*-timeframe.csv']);
        for i = 1 : length(files)
            dashIndex = find(files(i).name == '-');
            fileList(i, :) = files(i).name(1:dashIndex(2)-1); %#ok<AGROW>
        end
        
        for i = 1 : length(files)
            savedData = createSavedData(appData);
            savedData.save.picNo = i;
            savedData.save.commentStr = fileList(i, :);
            
            savedData.atoms = imread([folder fileList(i, :) '-absorption.pgm']);
            savedData.back = imread([folder fileList(i, :) '-light.pgm']);
            savedData.dark = imread([folder fileList(i, :) '-dark.pgm']);
            
            save([folder 'data-' num2str(i) '-' fileList(i, :)], 'savedData', appData.consts.saveVersion);
            savedData = [];
        end
    end
end

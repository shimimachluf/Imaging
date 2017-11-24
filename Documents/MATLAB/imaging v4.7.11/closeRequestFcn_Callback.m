
function closeRequestFcn_Callback(hObject, eventdata, dirName, fileName)
[fileName, pathName] = uiputfile([dirName '\' fileName]  , 'Save As:');
if pathName == 0
    delete(gcf);
    return
end
saveDataName = fullfile(pathName, fileName);
saveas(gcf, saveDataName);
delete(gcf);
end
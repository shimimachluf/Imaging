
function appData = timeframe_1(appData)
% function timeframe(appData)

if nargin == 0
    appData = [];
end


% create consts
if isempty(appData)
    appData.consts.defaultStrLVFile_Save = '\\MAGSTORE\magstore\data\External\timeframe.fra';
    appData.consts.defaultStrLVFile_Load = '\\MAGSTORE\magstore\data\External\timeframe_MATLAB.fra';
    appData.save.defaultDir = 'C:\Users\software\Documents\MATLAB\data';
    appData.save.saveDir=appData.save.defaultDir;
end

appData.consts.TF.winName = 'Timeframe';
appData.consts.TF.winXPos = 0.10;
appData.consts.TF.winYPos = 0.25;
appData.consts.TF.screenWidth = 0.80;
appData.consts.TF.screenHeight = 0.65;
appData.consts.TF.devices = 3;
appData.consts.TF.functions = 6;

appData.consts.TF.fontSize = 10;
appData.consts.TF.componentHeight = 22;

appData.consts.TF.columnName = {[] 'Comment' 'Time' 'Device' 'Value' 'Unit' 'Function' 'Variable'};
appData.consts.TF.colimnWidth = {25 200 100 150 150 100 100 150};

% application data

appData.TF.data = [];
appData.TF.tabNames = {};
appData.TF.devices = {};
appData.TF.functions = {};
appData.TF.columnFormat = {'logical' 'char' 'char' appData.TF.devices 'char''char' appData.TF.functions 'char'};
appData.TF.currentTab = 0;
appData.TF.currentCell = [0 0];

% local data
mem = {};

% create GUI

appData.TFui.win = figure('Visible', 'on', ... %'off', ...
    'Name', appData.consts.TF.winName, ...
    'Units', 'normalized', ...
    'Position', [appData.consts.TF.winXPos appData.consts.TF.winYPos appData.consts.TF.screenWidth appData.consts.TF.screenHeight], ...
    'Resize', 'on', ...
    'MenuBar', 'None', ...
    'Toolbar', 'None', ...
    'NumberTitle', 'off' , ...
    'HandleVisibility', 'callback');

appData.TFui.tgTimeframe = uitabgroup('Parent', appData.TFui.win, ...
    'Units', 'normalized', ...
    'Position', [0 0.05 1 0.95], ...
    'TabLocation', 'top', ...
    'SelectionChangedFcn', {@tgTimeframe_Callback});
appData.TFui.tabArr = uitab('Parent', appData.TFui.tgTimeframe, ...
    'Title', 'Empty tab', ...
    'Units', 'normalized');%, ...
%     'Position', [0 0 1 1]);
appData.TFui.tblArr = uitable(appData.TFui.tabArr, ...
    'Units', 'normalized', ...
    'Position', [0 0 1 1], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'ColumnWidth', {25 100 'auto'}, ...
    'ColumnEditable', true, ...
    'CellEditCallback', {@tblArr_CellEditCallback});

appData.TFui.pbLoadTF = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Load Timeframe', ...
    'Units', 'pixels', ...
    'Position', [5 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbLoadTF_Callback});
appData.TFui.pbSaveTF = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Save Timeframe', ...
    'Units', 'pixels', ...
    'Position', [110 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbSaveTF_Callback});
appData.TFui.pbSaveAsTF = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Save As...', ...
    'Units', 'pixels', ...
    'Position', [215 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbSaveTF_Callback});
appData.TFui.pbRemoveTab = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Remove Tab', ...
    'Units', 'pixels', ...
    'Position', [320 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbRemoveTab_Callback});
appData.TFui.pbAddTab = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Add Tab', ...
    'Units', 'pixels', ...
    'Position', [425 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbAddTab_Callback});
appData.TFui.pbRemoveLine = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Remove Line', ...
    'Units', 'pixels', ...
    'Position', [530 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbRemoveLine_Callback});
appData.TFui.pbAddLine = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Add Line', ...
    'Units', 'pixels', ...
    'Position', [635 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbAddLine_Callback});
appData.TFui.pbCut = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Cut', ...
    'Units', 'pixels', ...
    'Position', [740 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbCut_Callback});
appData.TFui.pbCopy = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Copy', ...
    'Units', 'pixels', ...
    'Position', [845 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbCopy_Callback});
appData.TFui.pbPaste = uicontrol(appData.TFui.win, ...
    'Style', 'pushbutton', ...
    'String', 'Paste', ...
    'Units', 'pixels', ...
    'Position', [950 5 100 appData.consts.TF.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.TF.fontSize, ...
    'Callback', {@pbPaste_Callback});



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tgTimeframe_Callback(object, eventdata) %#ok<INUSD>
tab = get(object, 'SelectedTab');
for i = 1 : length(appData.TF.tabNames)
    if strcmp(tab.Title, appData.TF.tabNames{i})
        appData.TF.currentTab = i;
        return;
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbLoadTF_Callback(object, eventdata) %#ok<INUSD>

% tf = readtable('timeframe_2.csv', 'delimiter', '\t', 'format', '%s%s%s%s%s%s%s','ReadVariableNames',false);
% tf = readtable('newTimeFrame copy.csv', 'delimiter', '\t', 'format', '%s%s%s%s%s%s%s','ReadVariableNames',false);


[FileName,PathName,FilterIndex] = uigetfile(appData.consts.defaultStrLVFile_Save, '*.fra');
if ~FileName
    return
end
tf = readtable([PathName FileName], 'FileType', 'text', 'delimiter', '\t', 'format', '%s%s%s%s%s%s%s','ReadVariableNames',false);

[nRow, nCol] = size(tf);
tmp = table2cell(tf);
appData.TF.data = {};
appData.TF.tabNames = {};
appData.TF.devices = unique(tmp(:,appData.consts.TF.devices))';
appData.TF.functions = unique(tmp(:,appData.consts.TF.functions))';
if isempty(appData.TF.devices{1})
    appData.TF.devices{1} = ' ';
end
if isempty(appData.TF.functions{1})
    appData.TF.functions{1} = ' ';
end
appData.TF.columnFormat = {'logical' 'char' 'char' appData.TF.devices 'char' 'char' appData.TF.functions 'char'};


lastInd = 1;
nTables = 0;
fExe = [];
for k = 1 : nRow+1
    if k == nRow+1 || isempty(tmp{k, 2})
        if k <= lastInd+1
            lastInd = k;
            continue
        end
        %create a new table
        nTables = nTables + 1;
        appData.TF.data{nTables} = cell(k-lastInd, nCol+1);
%         appData.TF.data{nTables} = cell(k-lastInd+1, nCol+1);
        
        if isempty(tmp{lastInd, 1})
            appData.TF.tabNames{nTables} = tmp{lastInd+1, 1};
            lastInd = lastInd+1;
        else
            appData.TF.tabNames{nTables} = tmp{lastInd, 1};
        end
        
        if ~isempty(tmp{lastInd, 2}) && tmp{lastInd, 2}(1) == '\'
            appData.TF.data{nTables}{1, 1} = false;
            appData.TF.data{nTables}{1, 3} = '\';%tmp{lastInd, 2}(2:end);
            fExe(nTables) = 0;
        else
            appData.TF.data{nTables}{1, 1} = true;
%             appData.TF.data{nTables}{1, 3} = tmp{lastInd, 2};
            fExe(nTables) = 1;
        end
        
        if strfind(appData.TF.tabNames{nTables}, 'TAB: ')
            tmpName = appData.TF.tabNames{nTables}(:)';
            appData.TF.tabNames{nTables} = tmpName(6:end);
%             lastInd = lastInd+1;
        end

%         appData.TF.data{nTables}{1, 1} = true;
        appData.TF.data{nTables}{1, 2} = appData.TF.tabNames{nTables};
        
        fFile = 1;
        for i = lastInd+fFile : k-1 
            if ~fExe(nTables)
                tmp{i,2} = tmp{i,2}(2:end);
            end
            
            if ~isempty(tmp{i, 2}) && tmp{i, 2}(1) == '\'
                appData.TF.data{nTables}{i-lastInd+2-fFile, 1} = false;
            else
                appData.TF.data{nTables}{i-lastInd+2-fFile, 1} = true;
            end
            for j = 2 : nCol+1
                appData.TF.data{nTables}{i-lastInd+2-fFile,j} = tmp{i, j-1};
            end
            
        end

        lastInd = k+1;

    else

    end
end

appData = updateTabs(appData, nTables);
for i = 1 : length(fExe)
   if ~fExe(i)
       appData.TFui.tblArr{i}.BackgroundColor = [0.75 0.75 0.75];
   end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbSaveTF_Callback(object, eventdata) %#ok<INUSL>

tf = table;
for i = 1 : length(appData.TF.data)
    [r, c] = size(appData.TF.data{i});
    tmp = appData.TF.data{i}(:, 2:c);
    tmp{1,1} = ['TAB: ' tmp{1,1}];
    if ~appData.TF.data{i}{1,1}
        for j = 1 : r
           tmp{j,2} = ['\' tmp{j,2}];
        end
    end
    tf(end+2:end+r+1,:) = cell2table(tmp);
    
end

if strcmp(object.String, appData.TFui.pbSaveAsTF.String)
    [FileName,PathName,FilterIndex] = uiputfile([appData.save.saveDir '\*.fra'], '*.fra');
    fName = [PathName FileName];
else
    fName = appData.consts.defaultStrLVFile_Load;
end

if fName
    writetable(tf, fName, 'FileType', 'text', 'delimiter', '\t', 'WriteVariableNames', false);
end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tblArr_CellSelectionCallback(object, eventdata) %#ok<INUSL>

appData.TF.currentCell = eventdata.Indices; 
if isempty(appData.TF.currentCell)
    appData.TF.currentCell = [0 0];
end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tblArr_CellEditCallback(object, eventdata) %#ok<INUSL>

r = eventdata.Indices(1);
c = eventdata.Indices(2);

% newED.Error = [];
% newED.Source = eventdata.Source;
% newED.EventName = eventdata.EventName;

if c == 1
    if r == 1
        if eventdata.NewData == 0
            object.BackgroundColor = [0.75 0.75 0.75];
        else
            object.BackgroundColor = [1 1 1; 0.9 0.9 0.9];
        end
    end
    appData.TF.data{appData.TF.currentTab}{r, 1} = eventdata.NewData;
    
    if eventdata.NewData == 1
        appData.TF.data{appData.TF.currentTab}{r, 3} = appData.TF.data{appData.TF.currentTab}{r, 3}(2:end);
    elseif eventdata.NewData == 0
        appData.TF.data{appData.TF.currentTab}{r, 3} = ['\' appData.TF.data{appData.TF.currentTab}{r, 3}];
    else
        errordlg('New data not 0 nor 1!', 'New Data Out Of Range', 'modal');
    end
    
%     colorgen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD>',text,'</TD></TR> </table></html>'];
%     appData.TFui.tblArr{appData.TF.currentTab}.Data{r, 3} = colorgen('#AAAAAA', appData.TF.data{appData.TF.currentTab}{r, 3});
    appData.TFui.tblArr{appData.TF.currentTab}.Data{r, 3} = appData.TF.data{appData.TF.currentTab}{r, 3};
    
    

elseif c == 3
    appData.TF.data{appData.TF.currentTab}{r, 3} = eventdata.NewData;
    if ~isempty(eventdata.NewData) && eventdata.NewData(1)=='\'
        appData.TF.data{appData.TF.currentTab}{r, 1} = false;
    else
        appData.TF.data{appData.TF.currentTab}{r, 1} = true;
    end
    appData.TFui.tblArr{appData.TF.currentTab}.Data{r, 1} = appData.TF.data{appData.TF.currentTab}{r, 1};

else
    appData.TF.data{appData.TF.currentTab}{r, c} = eventdata.NewData;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbRemoveTab_Callback(object, eventdata) %#ok<INUSL>

answer = inputdlg('Which Tab to remove?', 'Remove Tab', 1, {num2str(appData.TF.currentTab)});
if isempty(answer)
    return
end
tb = str2double(answer);
if isempty(tb) || tb<1
    errordlg('''Tab Number'' should be a positive number', 'Input Error', 'modal');
    return
end
if tb>length(appData.TF.tabNames)
    errordlg('''Tab Number'' too big, no such tab', 'Input Error', 'modal');
    return
end
    
data = appData.TF.data;
names = appData.TF.tabNames;
appData.TF.data = {};
appData.TF.tabNames = {};
ind = 1;
for i = 1 : length(data)
    if i ~= tb
        appData.TF.data{ind} = data{i};
        appData.TF.tabNames{ind} = names{i};
        ind = ind + 1;
    end
end

appData = updateTabs(appData, length(appData.TF.data));
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbAddTab_Callback(object, eventdata) %#ok<INUSL>

answer = inputdlg({'New Tab Name' 'New Tab Position'}, 'New Tab', 1, {'New Tab Name' num2str(appData.TF.currentTab)});  
tabName = answer{1};
tabPos = str2double(answer{2});
if isempty(tabPos) || tabPos < 1
    errordlg('''New Tab Position'' should be a positive number', 'Input Error', 'modal');
    return
end
if tabPos > length(appData.TF.tabNames)+1
    errordlg('''New Tab Position'' too big', 'Input Error', 'modal');
    return
end
    
data = appData.TF.data;
names = appData.TF.tabNames;
appData.TF.data = {};
appData.TF.tabNames = {};
ind = 1;
for i = 1 : length(data)+1
    if i ~= tabPos
        appData.TF.data{i} = data{ind};
        appData.TF.tabNames{i} = names{ind};
        ind = ind + 1;
    else
        appData.TF.data{i} = {false tabName [] [] [] [] [] []};
        appData.TF.tabNames{i} = tabName;
    end
end

appData = updateTabs(appData, length(appData.TF.data));
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbRemoveLine_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Which Line to remove?', 'Remove line', 1, {num2str(appData.TF.currentCell(:, 1)')});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln) > size(appData.TF.data{appData.TF.currentTab}, 1)
    errordlg('''Line Number'' too big, no such line', 'Input Error', 'modal');
    return
end

tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)-length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)
    if ~sum(i == ln)%i ~= ln(j)
        appData.TF.data{appData.TF.currentTab}(ind, :) = tbl(i,:);
        ind = ind + 1;
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbAddLine_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Where to add the new line?', 'Remove line', 1, {num2str(appData.TF.currentCell(1))});
if isempty(answer)
    return
end
% ln = str2double(answer);
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2 
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln)>size(appData.TF.data{appData.TF.currentTab},1)+1
    errordlg('Cannot add more than 1 line', 'Input Error', 'modal');
    return
end

tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)+length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)+length(ln)
    if ~sum(i == ln)%i ~= ln
        appData.TF.data{appData.TF.currentTab}(i,:) = tbl(ind,:);
        ind = ind + 1;
    else
        appData.TF.data{appData.TF.currentTab}(i,:) = {false [] '\' [] [] [] [] []};
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbCut_Callback(object, eventdata) %#ok<INUSL>

answer = inputdlg('Which Line to cut?', 'Remove line', 1, {num2str(appData.TF.currentCell(:, 1)')});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln) > size(appData.TF.data{appData.TF.currentTab}, 1)
    errordlg('''Line Number'' too big, no such line', 'Input Error', 'modal');
    return
end

tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)-length(ln), size(tbl,2));
mem = cell(length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)
    if ~sum(i == ln)%i ~= ln(j)
        appData.TF.data{appData.TF.currentTab}(ind, :) = tbl(i,:);
        ind = ind + 1;
    else
        mem(i-ind+1, :) = tbl(i,:);
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbCopy_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Which Line to copy?', 'Remove line', 1, {num2str(appData.TF.currentCell(:, 1)')});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln) > size(appData.TF.data{appData.TF.currentTab}, 1)
    errordlg('''Line Number'' too big, no such line', 'Input Error', 'modal');
    return
end

% tbl = appData.TF.data{appData.TF.currentTab};
% appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)-length(ln), size(tbl,2));
mem = cell(length(ln), size(appData.TF.data{appData.TF.currentTab},2));
ind = 1;
for i = 1 : size(appData.TF.data{appData.TF.currentTab}, 1)
    if sum(i == ln)%i ~= ln(j)
%         appData.TF.data{appData.TF.currentTab}(ind, :) = tbl(i,:);
%         ind = ind + 1;
%     else
        mem(ind, :) = appData.TF.data{appData.TF.currentTab}(i,:);
        ind = ind + 1;
    end
end

% appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbPaste_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Where to paste the new line?', 'Remove line', 1, {num2str(appData.TF.currentCell(1))});
if isempty(answer)
    return
end
% ln = str2double(answer);
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2 
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln)>size(appData.TF.data{appData.TF.currentTab},1)+1
    errordlg('Cannot add more than 1 line', 'Input Error', 'modal');
    return
end
if length(ln) > 1
    errordlg('Input only one number, for the first line', 'Input Error', 'modal');
    return
end

ln = [ln : ln+size(mem, 1)-1];
tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)+length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)+length(ln)
    if ~sum(i == ln)%i ~= ln
        appData.TF.data{appData.TF.currentTab}(i,:) = tbl(ind,:);
        ind = ind + 1;
    else
        appData.TF.data{appData.TF.currentTab}(i,:) = mem(i-ind+1, :);
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function appData = updateTabs(appData, nTables)

appData.TFui.tabArr = zeros(1, nTables);
appData.TFui.tblArr = cell(1, nTables);
appData.TFui.tgTimeframe = uitabgroup('Parent', appData.TFui.win, ...
    'Units', 'normalized', ...
    'Position', [0 0.05 1 0.95], ...
    'TabLocation', 'top', ...
    'SelectionChangedFcn', {@tgTimeframe_Callback});
for i = 1 : nTables
    appData.TFui.tabArr(i) = uitab('Parent', appData.TFui.tgTimeframe, ...
        'Title', appData.TF.tabNames{i}, ...
        'Units', 'normalized');
    appData.TFui.tblArr{i} = uitable(appData.TFui.tabArr(i), ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'ColumnWidth', appData.consts.TF.colimnWidth, ...
        'ColumnEditable', true, ...
        'ColumnName',appData.consts.TF.columnName, ...
        'ColumnFormat', appData.TF.columnFormat, ...
        'UserData', appData.TF.data{i}, ...
        'data', appData.TF.data{i}, ...
        'BackgroundColor', [1 1 1; 0.9 0.9 0.9], ...
        'CellEditCallback', {@tblArr_CellEditCallback}, ...
        'CellSelectionCallback', {@tblArr_CellSelectionCallback});
%     set(appData.TFui.tblArr{i}, 'data', appData.TF.data{i}, 'ColumnName',appData.consts.TF.columnName);
end

appData.TF.currentTab = 1;

end

end %end function timeframe



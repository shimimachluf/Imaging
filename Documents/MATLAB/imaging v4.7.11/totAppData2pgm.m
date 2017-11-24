
function totAppData2pgm(totAppData, ver, saveFolder)

if nargin < 2
    ver = 'ROI';
end
if nargin < 3
    saveFolder = [pwd totAppData{1}.slash 'converted pics'];
end

verInd = 0;
if strcmpi(ver, 'OD')
    verInd = 1;
elseif strcmpi(ver, 'ROI')
    verInd = 2;
else
    ['no such version: ' ver]
    return;
end

[status,message,messageid] = mkdir(saveFolder);
if ~status
    ['Cannot create directory: ' saveFolder]
    return
end

for i = 1 : length(totAppData)
    imwrite(totAppData{1}.data.plots{verInd}.pic, ...
        [saveFolder totAppData{i}.slash ver '-' num2str(totAppData{i}.save.picNo) '.pgm']);
end
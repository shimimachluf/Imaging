function fig2csv_1(path)

if nargin < 1
    path = 'C:\Data';
end
[FileName,PathName,FilterIndex] = uigetfile(path, '*.fig', 'MultiSelect', 'on');
if length(FileName) == 1 %isempty(FileName) || FileName == 0
    errordlg('No files were chosen', 'Error', 'modal');
    return
end

if iscell(FileName)
    numFiles = length(FileName);
else
    numFiles = 1;
    FileName = {FileName};    
end
for i = 1 : numFiles
    h = openfig([PathName FileName{i}]);
    x = h.Children.Children.XData;
    y = h.Children.Children.YData;
    xL = h.Children.XLabel.String;
    yL = h.Children.YLabel.String;
    close(h);
    fid = fopen([PathName FileName{i}(1:end-3) 'csv'], 'w');
    if fid == -1
        errordlg('cannot open csv file', 'Error', 'modal');
        return
    end
    fprintf(fid, '%s,\t%s\n', xL, yL);
    if fclose(fid) == -1
        errordlg('cannot close csv file', 'Error', 'modal');
        return
    end
    dlmwrite([PathName FileName{i}(1:end-3) 'csv'], [x; y]', '-append', 'delimiter', '\t');
end
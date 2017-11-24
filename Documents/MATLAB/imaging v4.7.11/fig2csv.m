function fig2csv(path)

if nargin < 1
    path = 'C:\Data';
end
[FileName,PathName,FilterIndex] = uigetfile(path, '*.fig', 'MultiSelect', 'on');
if isempty(FileName)
    errordlg('No files were choosen', 'Error', 'modal');
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
    nChild = length(h.Children);
    nLines = length(h.Children(nChild).Children);
    
    if nChild > 2
        errordlg(['Too many children in file: ' FileName{i}], 'Error', 'modal');
        close(h);
        break;
    elseif nChild == 2
        for j = nLines : -1 : 1 % the order of the lines and the legend is flipped a
            dataL{j} = h.Children(1).String{nLines-j+1};
        end
    else
        dataL = {};
    end
    
    x = cell(nLines, 1);
    y = cell(nLines, 1);
    xL = h.Children(nChild).XLabel.String;
    yL = h.Children(nChild).YLabel.String;
    for j = 1 : nLines
        x{j} = h.Children(nChild).Children(j).XData;
        y{j} = h.Children(nChild).Children(j).YData;
    end
    close(h);
    
    fid = fopen([PathName FileName{i}(1:end-3) 'csv'], 'w');
    if fid == -1
        errordlg('cannot open csv file', 'Error', 'modal');
        return
    end
    for j = 1 : nLines
        if nChild == 2
            fprintf(fid, '%s (%s)\t%s (%s)', xL, dataL{j}, yL, dataL{j});
        else
            fprintf(fid, '%s\t%s', xL, yL);
        end
        if j < nLines
            fprintf(fid, '\t');
        end
    end
    fprintf(fid, '\n');
%     if fclose(fid) == -1
%         errordlg('cannot close csv file', 'Error', 'modal');
%         return
%     end
    
    maxLen = length(x{1});
    for j = 2 : nLines
        if maxLen < length(x{j})
            maxLen = length(x{j});
        end
    end
    
%     tbl = ones(maxLen, nLines*2)*nan;
    tbl = ones(maxLen, nLines*2);
    for j = 1 : nLines
        tbl(1:length(x{j}), j*2-1) = x{j};
        tbl(1:length(x{j}), j*2) = y{j};
    end
    
    for k = 1 : maxLen
        for j = 1 : nLines
            if isnan(tbl(k, 2*j))
                fprintf(fid, ',');
            else
                fprintf(fid, '%f\t%f', tbl(k, 2*j-1:2*j));
            end
            if j < nLines
                fprintf(fid, '\t');
            end
        end
        fprintf(fid, '\n');
    end
    if fclose(fid) == -1
        errordlg('cannot close csv file', 'Error', 'modal');
        return
    end
    
%     dlmwrite([PathName FileName{i}(1:end-3) 'csv'], [x{1}; y{1}]', '-append', 'delimiter', ',');
%     for j = 2 : nLines
%         dlmwrite([PathName FileName{i}(1:end-3) 'csv'], [x{j}; y{j}]', ...
%             '-append', 'delimiter', ',', 'coffset', 2*(j-1), 'roffset', -length(x{j-1}));
%     end
end
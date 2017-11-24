
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function appData = analyzeAndPlot(appData)
% Analyze the absorption image
avgWidth = appData.options.avgWidth;%str2double(get(appData.ui.etAvgWidth, 'String'));
if ~isfield(appData.consts, 'maxAvgWidth')
    appData.consts.maxAvgWidth = 8;
end
% i = avgWidth+2;
% for (i = avgWidth+2 : 2 : avgWidth+appData.consts.maxAvgWidth)
try
    if ( appData.data.fits{appData.data.fitType}.atomsNo == -1  || ...
            (  strcmp(appData.consts.runVer, 'offline') && appData.options.plotSetting == appData.consts.plotSetting.last ))
        appData = appData.data.fits{appData.data.fitType}.analyze(appData);
        set(appData.ui.etAvgWidth, 'String', num2str(avgWidth));
        appData.options.avgWidth = avgWidth;
        %             break;
    end
catch ME
    %         if ( i == avgWidth+8 )
    msgbox({ME.message, ME.cause, 'file:', ME.stack.file, 'name:', ME.stack.name, 'line', num2str([ME.stack(:).line])}, ...
        'Cannot analyze data!!!', 'error', 'modal');
    appData.data.fitType = appData.consts.fitTypes.onlyMaximum;
    set(appData.ui.pmFitType, 'Value', appData.data.fitType);
    appData = appData.data.fits{appData.data.fitType}.analyze(appData);
    %         else
    %             set(appData.ui.etAvgWidth, 'String', num2str(i));
    %             appData.options.avgWidth = i;
    %
    %             tmpFitType = appData.data.fitType;
    %             appData.data.fitType = appData.consts.fitTypes.onlyMaximum;
    %             set(appData.ui.pmFitType, 'Value', appData.data.fitType);
    %             appData = appData.data.fits{appData.data.fitType}.analyze(appData);
    %             onlyPlot(appData);
    %             appData.data.fitType = tmpFitType;
    %             set(appData.ui.pmFitType, 'Value', appData.data.fitType);
    %         end
end
% end

if  appData.options.doPlot == 1
    % Plot image and results
    onlyPlot(appData);
end

%
% Saving
%
if ( appData.save.isSave == 1 ) && ~(appData.loop.isLoop && appData.loop.fFirstMeas )
    
    savedData = createSavedData(appData);  %#ok<NASGU>
    if strcmp(computer, 'MACI64')
        save([appData.save.saveDir '/data-' num2str(appData.save.picNo) appData.save.commentStr '.mat'], 'savedData', appData.consts.saveVersion);
    else
        save([appData.save.saveDir '\data-' num2str(appData.save.picNo) appData.save.commentStr '.mat'], 'savedData', appData.consts.saveVersion);
    end
    
    if ( strcmp(appData.consts.runVer, 'online') )
        [s, m, mid] = copyfile(appData.consts.defaultStrLVFile_Save, [appData.save.saveDir '\data-' num2str(appData.save.picNo) '.csv']); %#ok<NASGU>
        if ( s == 0)
            warndlg(['Cannot copy timeframe file: ' m], 'Warning', 'modal');
        end
    end
    
    set(appData.ui.win, 'Name', [appData.consts.winName num2str(appData.save.picNo) appData.save.commentStr]);
    appData.save.picNo = appData.save.picNo + 1;
    set(appData.ui.etPicNo, 'String', num2str(appData.save.picNo));
%     save([appData.save.saveDir '\data-' num2str(appData.save.picNo) appData.save.commentStr '.mat'], 'savedData', appData.consts.saveVersion);
end

end

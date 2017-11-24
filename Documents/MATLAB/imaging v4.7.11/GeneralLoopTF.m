classdef GeneralLoopTF < Measurement
    %GENERALLOOP_TF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % consts
%         GUI = 0; %% MUST be first
%         tmpObj = [];
        
%         appData = [];
        folderIcon = [];
        fontSize = -1;
        componentHeight = -1;
        fPause = 1;
        baseBaseFolder = '';
        saveFolder = '';
        
%         tmpSaveName = 'tmpGeneralLoop.mat';
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % ui controls
        win = -1;
        pbOpenReadDir = -1;
        etReadDir = -1;
        etNumIterations = -1;
        pmIterationsOrder = -1;
        pbOK = -1;
        pbCancel = -1;
        pbSave = -1;
        pbLoad = -1;
        tbEnableEdit = -1;
        pbAddLoop = -1;
        pbRemoveLastLoop = -1;
        
        pmASaveParam = [];
        etASaveParamVals = [];
        sANoElements = [];
        
        pALoops = [];
        pbAAddChannel = [];
        pbARemoveLastChannel = [];
        
%         pmMChangeTypes = {}; %2D cell array
%         pmMEventName = {};
%         pmMChannelName = {};     
%         pmMRumpNo = {};
%         etMVector = {};
        pmMTabs = {}; %2D cell array
        pmMLines = {};
        etMTime = {};
        etMDevice = {};
        etMValue = {};
        etMUnits = {};
        etMFunction = {};
        sMNoElements = {};
        sMElements = {};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % data
        runs = [];
        
        enableEdit = 1;
        noLoops = 1;
        pALoopsStartHeight = 0;
        noChannels = 1; % an array at the length of noLoops
        
%         MChangeTypes = {}; %2D cell array
%         MEventName = {};
%         MChannelName = {};     
%         MRumpNo = {};
%         MVector = {};
%         MVectorRFCommands = {};
%         MVectorStr = {};
        MTabs = {}; %2D cell array
        MLines = {};
%         MTime = {};
        MTimeStr = {};
        MDevice = {};
%         MValue = {};
        MValueStr = {};
        MUnits = {};
        MFunction = {};
        MNoElements = {};
        MVector = {}; %the 2D matrix of vectors of the STRINGS of the loop
        MfTimeValue = {}; % 2D matrix: un-initialized = 0, time = 1, value = 2
        
        saveParam = -1;
        saveParamStr = '';
        saveOtherParamStr = '';
%         saveParamStr = ''; %other param string
%         saveParam = -1; %value of popup menu
        saveAllParamStr = {}; %popup menu
        
%         changeTypes = {};
        tabsNames = {};
        ASaveParam = [];
        ASaveParamsStr = {};
        ASaveParamVals = {};
        ASaveParamValsStr = {};
        ASaveOtherParamStr = {''};
        ANoElements = {};
        
        
%         eventNames = '';
%         analogNames = '';
%         digitalNames = '';
%         RFNames = '';
        
    end
    
    
     methods ( Static = true )
        function o = create(appData)
            o = GeneralLoopTF(appData);
        end
     end
     
    methods        
        function obj = GeneralLoopTF(appData)
            % first line - MUST
%             obj = obj@Measurement(LVData.readLabview(appData.consts.defaultStrLVFile_Save));%appData.data.LVData);
%             obj = Measurement(appData.TF);
%             obj.appData = appData;
            
            obj.appData = appData;
            obj.baseBaseFolder = appData.save.saveDir;
            
            obj.noIterations = 1;
            obj.iterationsOrder = 1;            
            
            obj.fontSize = appData.consts.fontSize;
            obj.componentHeight = appData.consts.componentHeight;
            obj.folderIcon = imread('folder28.bmp');
            obj.saveFolder = appData.consts.loops.GenLoop.saveFolder;
            
%             obj.changeTypes = LVData.getTypes();
            obj.tabsNames = obj.appData.TF.tabNames;
            obj.saveParam = appData.consts.saveParams.default;
            obj.saveParamStr = appData.consts.saveParams.str;
            obj.saveOtherParamStr = appData.consts.saveOtherParamStr;
            
%             obj.eventNames = [];%obj.LVData.getEventsNames();
%             obj.analogNames = [];%obj.LVData.getAnalogNames();
%             obj.digitalNames = [];%obj.LVData.getDigitalNames();
%             obj.RFNames = [];%obj.LVData.getRFNames();
           
            % last line - MUST
            obj = obj.initialize(appData, 1);
%             obj.tmpObj = obj;
        end
        
        function obj = initialize(obj, appData, doWait)  %#ok<INUSL>
%             flag = 0;
            if nargin < 3
                doWait = 1;
%                 flag = 1;
            end
%             if doWait == -1
%                 flag = 1;
%             end
            if obj.enableEdit
                enableStr = 'on';
            else
                enableStr = 'off';
            end
            if obj.win == -1 || ~ishandle(obj.win)
                obj.win = figure('Visible', 'on', ...
                    'Name', 'General Loop', ...
                    'Units', 'Pixels', ...
                    'Position', [100 100 930 1000], ...
                    'Resize', 'off', ...
                    'MenuBar', 'None', ...
                    'Toolbar', 'None', ...
                    'NumberTitle', 'off' , ...  
                    'WindowStyle'      ,'normal', ...
                    'HandleVisibility', 'callback');
            end            
            
            obj.pbOpenReadDir = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', '', ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [5 5 30 30], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'CData', obj.folderIcon);      
            obj.etReadDir = uicontrol(obj.win, ...
                'Style', 'edit', ...
                'String', obj.baseBaseFolder, ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [40 5 355 obj.componentHeight+5], ...
                'BackgroundColor', 'white', ...
                'HorizontalAlignment', 'left', ...
                'FontSize', obj.fontSize); 
            obj.tbEnableEdit = uicontrol(obj.win, ...
                'Style', 'togglebutton', ...
                'String', 'Enable Edit', ...
                'Units', 'pixels', ...
                'Value', obj.enableEdit, ...
                'Position', [400 5 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize); 
            
            obj.pbOK = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [615 5 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize); 
            obj.pbCancel = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Units', 'pixels', ...
                'Position', [505 5 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize); 
            
            obj.pbSave = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', 'Save Loop', ...
                'Units', 'pixels', ...
                'Position', [5 40 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize); 
            obj.pbLoad = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', 'Load Loop', ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [110 40 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize);  

            st1 = uicontrol(obj.win, ...
                'Style', 'text', ...
                'String', 'Num Iterations:', ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [215 40 100 obj.componentHeight], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'HorizontalAlignment', 'left', ...
                'FontSize', obj.fontSize);  %#ok<NASGU>
            obj.etNumIterations = uicontrol(obj.win, ...
                'Style', 'edit', ...
                'String', '1', ... % num2str(obj.noIterations), ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [315 40 20 obj.componentHeight+5], ...
                'BackgroundColor', 'white', ...
                'HorizontalAlignment', 'left', ...
                'FontSize', obj.fontSize);            
            obj.pmIterationsOrder = uicontrol(obj.win, ...
                'Style', 'popupmenu', ...
                'String', {'Iterate Measurement' 'Iterate Loop' 'Random Iterations'}, ...
                'Value', obj.iterationsOrder, ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [340 47  150 20], ...
                'BackgroundColor', 'white', ...
                'HorizontalAlignment', 'left', ...
                'FontSize', obj.fontSize); 
            
            obj.pbAddLoop = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', 'Add Loop', ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [615 40 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize); 
            obj.pbRemoveLastLoop = uicontrol(obj.win, ...
                'Style', 'pushbutton', ...
                'String', 'Remove Last', ...
                'Units', 'pixels', ...
                'Enable', enableStr, ...
                'Position', [505 40 100 obj.componentHeight+5], ...
                'BackgroundColor', [0.8 0.8 0.8], ...
                'FontSize', obj.fontSize); 
            
            obj.pALoopsStartHeight = 0;
            for i = 1 : obj.noLoops
                panelTitle = '';
                if i == 1
                    panelTitle = 'Inner Loop';
                else
                    for j = obj.noLoops-i+2 : obj.noLoops
                        panelTitle = [panelTitle 'Outer ']; %#ok<AGROW>
                    end
                    panelTitle = [panelTitle 'Loop']; %#ok<AGROW>
                end
                loopHeaight = max( 2*(obj.componentHeight+5)+(2+4)*5, ... %components and spaces
                    (obj.noChannels(i)+1)*(obj.componentHeight+5)+(obj.noChannels(i)+4)*5);
                obj.pALoops(i) = uipanel('Parent', obj.win, ...
                    'Title', panelTitle, ...
                    'TitlePosition', 'lefttop', ...
                    'Units', 'pixels', ...
                    'Position', [5 70+obj.pALoopsStartHeight  920 loopHeaight], ... 
                    'BackgroundColor', [0.8 0.8 0.8], ...
                    'FontSize', obj.fontSize);
                obj.pALoopsStartHeight = obj.pALoopsStartHeight +loopHeaight;
                            
                st1 = uicontrol(obj.pALoops(i), ...
                    'Style', 'text', ...
                    'String', 'Save Param:', ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [5 5 90 obj.componentHeight], ...
                    'BackgroundColor', [0.8 0.8 0.8], ...
                    'HorizontalAlignment', 'left', ...
                    'FontSize', obj.fontSize);          %#ok<NASGU>
                obj.pmASaveParam(i) = uicontrol(obj.pALoops(i), ...
                    'Style', 'popupmenu', ...
                    'String', obj.saveParamStr, ...
                    'Value', obj.saveParam, ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [90 12  85 20], ...
                    'BackgroundColor', 'white', ...
                    'HorizontalAlignment', 'left', ...
                    'FontSize', obj.fontSize);
                st1 = uicontrol(obj.pALoops(i), ...
                    'Style', 'text', ...
                    'String', 'Param Vals:', ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [180 5 100 obj.componentHeight], ...
                    'BackgroundColor', [0.8 0.8 0.8], ...
                    'HorizontalAlignment', 'left', ...
                    'FontSize', obj.fontSize);          %#ok<NASGU>
                obj.etASaveParamVals(i) = uicontrol(obj.pALoops(i), ...
                    'Style', 'edit', ...
                    'String', '0', ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [260 5 80 obj.componentHeight+5], ...
                    'BackgroundColor', 'white', ...
                    'HorizontalAlignment', 'left', ...
                    'FontSize', obj.fontSize);
                obj.sANoElements(i) = uicontrol(obj.pALoops(i), ...
                    'Style', 'text', ...
                    'String', '0 Elements', ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [345 5 100 obj.componentHeight], ...
                    'BackgroundColor', [0.8 0.8 0.8], ...
                    'HorizontalAlignment', 'left', ...
                    'FontSize', obj.fontSize);
                
                obj.pbAAddChannel(i) = uicontrol(obj.pALoops(i), ...
                    'Style', 'pushbutton', ...
                    'String', 'Add Channel', ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [610 5 100 obj.componentHeight+5], ...
                    'BackgroundColor', [0.8 0.8 0.8], ...
                    'FontSize', obj.fontSize ); 
                obj.pbARemoveLastChannel(i) = uicontrol(obj.pALoops(i), ...
                    'Style', 'pushbutton', ...
                    'String', 'Remove Last', ...
                    'Units', 'pixels', ...
                    'Enable', enableStr, ...
                    'Position', [500 5 100 obj.componentHeight+5], ...
                    'BackgroundColor', [0.8 0.8 0.8], ...
                    'FontSize', obj.fontSize); 
                
                for j = 1 : obj.noChannels(i)
                    %%%%%%%%%%%%%%%%%%%%%%%
                    % add a line (change channel)  
                    channelHeight = 42 +(j-1)*30;
                    obj.pmMTabs{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'popupmenu', ...
                        'String', obj.tabsNames, ...
                        'Value', 1, ...
                        'Units', 'pixels', ...
                        'Enable', enableStr, ...
                        'Position', [5 channelHeight  120 20], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.pmMLines{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'popupmenu', ...
                        'String', 'Lines', ...
                        'Value', 1, ...
                        'Units', 'pixels', ...
                        'Enable', enableStr, ...
                        'Position', [130 channelHeight  75 20], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.etMTime{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'edit', ...
                        'String', 'empty', ...
                        'Units', 'pixels', ...
                        'Enable', enableStr, ...
                        'Position', [210 channelHeight-8 150 obj.componentHeight+6], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.etMDevice{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'edit', ...
                        'String', 'empty', ...
                        'Units', 'pixels', ...
                        'Enable', 'off', ...
                        'Position', [365 channelHeight-8 100 obj.componentHeight+6], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.etMValue{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'edit', ...
                        'String', 'empty', ...
                        'Units', 'pixels', ...
                        'Enable', enableStr, ...
                        'Position', [470 channelHeight-8 150 obj.componentHeight+6], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.etMUnits{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'edit', ...
                        'String', 'empty', ...
                        'Units', 'pixels', ...
                        'Enable', 'off', ...
                        'Position', [625 channelHeight-8 100 obj.componentHeight+6], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.etMFunction{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'edit', ...
                        'String', 'empty', ...
                        'Units', 'pixels', ...
                        'Enable', 'off', ...
                        'Position', [730 channelHeight-8 100 obj.componentHeight+6], ...
                        'BackgroundColor', 'white', ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.sMNoElements{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'text', ...
                        'String', '0', ...
                        'Units', 'pixels', ...
                        'Enable', enableStr, ...
                        'Position', [835 channelHeight-5 30 obj.componentHeight], ...
                        'BackgroundColor', [0.8 0.8 0.8], ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);
                    obj.sMElements{i}{j} = uicontrol(obj.pALoops(i), ...
                        'Style', 'text', ...
                        'String', 'elements', ...
                        'Units', 'pixels', ...
                        'Enable', enableStr, ...
                        'Position', [860 channelHeight-5 50 obj.componentHeight], ...
                        'BackgroundColor', [0.8 0.8 0.8], ...
                        'HorizontalAlignment', 'left', ...
                        'FontSize', obj.fontSize);

%                     set(obj.pmMChangeTypes{i}{j}, 'Callback', {@obj.pmMChangeTypes_Callback});
%                     set(obj.pmMEventName{i}{j}, 'Callback', {@obj.pmMEventName_Callback});
%                     set(obj.pmMChannelName{i}{j}, 'Callback', {@obj.pmMChannelName_Callback});  
%                     set(obj.etMVector{i}{j}, 'Callback', {@obj.etMVector_Callback});
%                     set(obj.pmMRumpNo{i}{j}, 'Callback', {@obj.pmMRumpNo_Callback}); 

                    set(obj.pmMTabs{i}{j}, 'Callback', {@obj.pmMTabs_Callback});
                    set(obj.pmMLines{i}{j}, 'Callback', {@obj.pmMLines_Callback});
                    set(obj.etMTime{i}{j}, 'Callback', {@obj.etMTime_Callback});  
                    set(obj.etMValue{i}{j}, 'Callback', {@obj.etMValue_Callback});
                end
                
            set(obj.pmASaveParam(i), 'Callback', {@obj.pmASaveParam_Callback});     
            set(obj.etASaveParamVals(i), 'Callback', {@obj.etASaveParamVals_Callback}); 
            set(obj.pbAAddChannel(i), 'Callback', {@obj.pbAAddChannel_Callback});
            set(obj.pbARemoveLastChannel(i), 'Callback', {@obj.pbARemoveLastChannel_Callback});
            
            end
            
            set(obj.pbOpenReadDir, 'Callback', {@obj.pbOpenReadDir_Callback});             
            set(obj.etReadDir, 'Callback', {@obj.etReadDir_Callback});          
            set(obj.etNumIterations, 'Callback', {@obj.etNumIterations_Callback});
            set(obj.pmIterationsOrder, 'Callback', {@obj.pmIterationsOrder_Callback});
            set(obj.pbOK, 'Callback', {@obj.pbOK_Callback});
            set(obj.pbCancel, 'Callback', {@obj.pbCancel_Callback});
            set(obj.pbSave, 'Callback', {@obj.pbSave_Callback});
            set(obj.pbLoad, 'Callback', {@obj.pbLoad_Callback});
            set(obj.tbEnableEdit, 'Callback', {@obj.tbEnableEdit_Callback});
            set(obj.pbAddLoop, 'Callback', {@obj.pbAddLoop_Callback});            
            set(obj.pbRemoveLastLoop, 'Callback', {@obj.pbRemoveLastLoop_Callback});     
%             set(obj.pmASaveParam, 'Callback', {@obj.pmASaveParam_Callback});     
%             set(obj.etASaveParamVals, 'Callback', {@obj.etASaveParamVals_Callback}); 
            
            minHeight = max(4*(2*(obj.componentHeight+5)+(2+4)*5), obj.pALoopsStartHeight); %min height of 3 panels
            set(obj.win, 'Position', [100 100 930 70+minHeight], 'MenuBar', 'None','Toolbar', 'None');
            guidata(obj.win, obj);
%             if obj.noIterations ~= -1 
                obj.updateGUI();
%             end
            set(obj.win, 'Visible', 'on');
          
            if  doWait == 1 && ishandle(obj.win)

                % Go into uiwait if the figure handle is still valid.
                % This is mostly the case during regular use.
                
%                 tmpObj = obj;                
%                 st = dbstack;

%                 uiwait(obj.win);
 
                obj.fPause = 1;
                guidata(obj.win, obj);
                while obj.fPause == 1
                    pause(1);
                    if  ishandle(obj.win)
                        obj = guidata(obj.win);
                    else
                        obj.fPause = 0;
                    end
                end
                    
                
                
                if  ishandle(obj.win)
                    obj = guidata(obj.win);
                    close(obj.win);
                    
                    if obj.noIterations ~= -1
                        obj.runs = 1:obj.noMeasurements/obj.noIterations;
                        obj.runs = obj.iterateVec(obj.runs, obj.iterationsOrder, []);
                        
                        obj.makeFolders(obj.baseBaseFolder, obj.noLoops);
                        
                    end
                else
                    obj.noIterations = -1;
                end
%                 if obj.noIterations == -1 && strcmp(st(2).name, 'imaging/lbMeasurementsList_KeyPressFcn')
%                     obj = tmpObj;
%                 end
                obj.win = -1;
            end
                       
        end
        
        function makeFolders(obj, baseFolder, loopInd)
            if loopInd == 1
                return
            end
            for i = 1 : length(obj.ASaveParamVals{loopInd})
                folders{i} = [baseFolder '\' obj.ASaveParamsStr{loopInd}{obj.ASaveParam(loopInd)} ' - ' ...
                    num2str(obj.ASaveParamVals{loopInd}(i))]; %#ok<AGROW>
            end
            for i = 1 : length(obj.ASaveParamVals{loopInd})
                [s,mess,messid] = mkdir(folders{i}); %#ok<NASGU,ASGLU>
                obj.makeFolders(folders{i}, loopInd-1)
            end
        end
        
        function obj = edit(obj, appData)
%             obj = guidata(obj.win);
            
            tmpObj = obj;
            obj.enableEdit = 0;
            obj = obj.initialize(appData, 1);
            if obj.noIterations == -1
                obj = tmpObj;
            end
            
%             guidata(obj.win, obj);
        end
                
        function [obj, newTFData] = next(obj, appData) 
%             obj = guidata(obj.win);

            if obj.position
                runInd = obj.runs(obj.position)-1;
                ind = zeros(1, obj.noLoops);
                for i = 1 : obj.noLoops
                    totMul = 1;
                    for j = 1 : obj.noLoops-i
                        totMul = totMul * length(obj.MVector{j}{1});
                    end
                    ind(i) = floor(runInd/totMul);
                    runInd = rem(runInd, totMul);
                end
                ind = fliplr(ind)+1;
                % change save param, param val and folder
                appData.save.saveOtherParamStr = obj.ASaveOtherParamStr{1};
                set(appData.ui.pmSaveParam, 'String', obj.ASaveParamsStr{1});
                set(appData.ui.pmSaveParam, 'Value', obj.ASaveParam(1));
                set(appData.ui.etParamVal, 'String', num2str(obj.ASaveParamVals{1}(ind(1))));
            end
            
            if obj.position == obj.noMeasurements
                newTFData = [];
                return
            end
            
            obj.position = obj.position + 1;
            
            runInd = obj.runs(obj.position)-1;
            ind = zeros(1, obj.noLoops);
            for i = 1 : obj.noLoops
                totMul = 1;
                for j = 1 : obj.noLoops-i
                    totMul = totMul * length(obj.MVector{j}{1});
                end
                ind(i) = floor(runInd/totMul);
                runInd = rem(runInd, totMul);
            end
            ind = fliplr(ind)+1;
            
            newTFData = obj.appData.TF.data;
%             str = obj.baseBaseFolder;
%             indS = strfind(str, '\');
%             if isempty(str2num(str(indS(end)+1)))
%                 obj.baseBaseFolder = [str(1:indS(end)) datestr(now,'HH_MM ') str(indS(end)+1:end)];
% %             else
% %                 obj.baseBaseFolder = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1+6:end)];
%             end
            obj.baseFolder = obj.baseBaseFolder;
            for i = obj.noLoops : -1 : 1
                if i > 1
                    obj.baseFolder = [obj.baseFolder '\' obj.ASaveParamsStr{i}{obj.ASaveParam(i)} ' - ' ...
                        num2str(obj.ASaveParamVals{i}(ind(i)))];
                end
                for j = 1 : obj.noChannels(i)
                    switch obj.MfTimeValue{i}{j}
                        case 1
                            column = obj.appData.consts.TF.time;
                        case 2
                            column = obj.appData.consts.TF.value;
                        otherwise
                            errordlg(['Flag of Time/Value is set to ' num2str(obj.MfTimeValue{i}{j})], 'Error', 'modal');
                            newTFData = [];
                            return                        
                    end
                    newTFData{obj.MTabs{i}{j}}(obj.MLines{i}{j}, column+1) = obj.MVector{i}{j}(ind(i));
%                     newLVData = newLVData.changeValue(type, event, channel, ramp, value );
                end
            end

%             % change save param, param val and folder
%             appData.save.saveOtherParamStr = obj.ASaveOtherParamStr{1};
%             set(appData.ui.pmSaveParam, 'String', obj.ASaveParamsStr{1});
%             set(appData.ui.pmSaveParam, 'Value', obj.ASaveParam(1));
%             set(appData.ui.etParamVal, 'String', num2str(obj.ASaveParamVals{1}(ind(1)))); 
%             set(appData.ui.etSaveDir, 'String', folder);
            
            obj.saveParamStr = ''; %other param string
            obj.saveParam = -1; %value of popup menu
            obj.saveAllParamStr = {}; %popup menu

%             guidata(obj.win, obj);
        end
        
        function str = getMeasStr(obj, appData)
%             obj = guidata(obj.win);
%             str = 'aa';
            str = [appData.consts.availableLoops.str{appData.consts.availableLoops.TFGeneralLoop}  ' (' obj.getCurrMeas() ')'];
%             guidata(obj.win, obj);
        end
    
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
        % callbacks
        function pbOpenReadDir_Callback(obj, object, eventdata)   %#ok<INUSL>
            dirName = uigetdir(get(obj.etReadDir, 'String'));
            if ( dirName ~= 0 )
                set(obj.etReadDir, 'String', dirName);
                obj.etReadDir_Callback(obj.etReadDir, eventdata);
            end
        end    
        
        function etReadDir_Callback(obj, object, eventdata)
            obj = guidata(obj.win);
%             obj.baseBaseFolder = get(object, 'String');
            str = get(object, 'String');
            ind = strfind(str, '\');
            if isempty(str2num(str(ind(end)+1)))
                obj.baseFolder = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1:end)];
            else
                obj.baseFolder = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1+6:end)];
            end
            set(object, 'String', obj.baseFolder);
            obj.baseBaseFolder = obj.baseFolder;
            guidata(obj.win, obj);
        end    
        
        function etNumIterations_Callback(obj, object, eventdata)
            obj = guidata(obj.win);
            val = str2double(get(object, 'String'));
            if ( isnan(val) || val <= 0 || floor(val) ~= val )
                set(object, 'String', '1');
                errordlg('Input must be positive integer','Error', 'modal');
            else
                obj.noIterations = val;
            end
            guidata(obj.win, obj);
        end
        
        function pmIterationsOrder_Callback(obj, object, eventdata) 
            obj = guidata(obj.win);
            obj.iterationsOrder = get(object, 'Value');
            guidata(obj.win, obj);
        end           
        
        function pmASaveParam_Callback(obj, object, eventdata) 
            obj = guidata(obj.win);
            i = obj.getPIndex(object, obj.pmASaveParam);
            obj.ASaveParam(i) = get(object, 'Value');%obj.pmASaveParam, 'Value');
            obj.ASaveParamsStr{i} = get(object, 'String');
            if ( obj.ASaveParam(i) == length(obj.ASaveParamsStr{i}) )
                param = inputdlg('Enter param name:', 'Other param input');
                if isempty(param)
                    return
                end
                obj.ASaveOtherParamStr(i) = param;
                obj.ASaveParamsStr{i} = {['O.P. - ' param{1}] obj.ASaveParamsStr{i}{2:end}};
                set(object, 'String', obj.ASaveParamsStr{i});
                obj.ASaveParam(i) = 1;
                set(object, 'Value', 1);
            end
            guidata(obj.win, obj);
        end  
        
        function etASaveParamVals_Callback(obj, object, eventdata) 
            obj = guidata(obj.win);
            i = obj.getPIndex(object, obj.etASaveParamVals);
            try
                vec = eval(get(object, 'String'));
                obj.ASaveParamVals{i} = vec;
                obj.ASaveParamValsStr{i} = get(object, 'String');
%                 obj.noMeasurements = length(vec);
                obj.ANoElements{i} = [num2str(length(vec)) ' elements'];
                set(obj.sANoElements(i), 'String', obj.ANoElements{i});
                guidata(obj.win, obj);
            catch ex %#ok<NASGU>
                set(object, 'String', '');
                errordlg('Input must be an array','Error', 'modal');
            end
        end    
        
        function pbSave_Callback(obj, object, eventdata) 
%             obj = guidata(obj.win);
            obj = obj.updateObj();
%             guidata(obj.win, obj);
%              [file path] = uigetfile([obj.baseFolder '\*.mat']);
            [file path] = uiputfile([obj.saveFolder '\*.mat']);
            if file == 0
                return
            end
%             o = obj; %#ok<NASGU>
            o.noLoops = obj.noLoops;
            o.noChannels = obj.noChannels;
            o.MTabs = obj.MTabs;
            o.MLines = obj.MLines;
            o.MTimeStr = obj.MTimeStr;
            o.MDevice = obj.MDevice;
            o.MValueStr = obj.MValueStr;
            o.MUnits = obj.MUnits;
            o.MFunction = obj.MFunction;
            o.MNoElements = obj.MNoElements;
            o.MVector = obj.MVector;
            o.MfTimeValue = obj.MfTimeValue;
            o.saveParam = obj.saveParam;
            o.saveParamStr = obj.saveParamStr;
            o.saveOtherParamStr = obj.saveOtherParamStr;
            o.saveAllParamStr = obj.saveAllParamStr;
            o.ASaveParam = obj.ASaveParam;
            o.ASaveParamsStr = obj.ASaveParamsStr;
            o.ASaveParamVals = obj.ASaveParamVals;
            o.ASaveParamValsStr = obj.ASaveParamValsStr;
            o.ASaveOtherParamStr = obj.ASaveOtherParamStr;
            o.ANoElements = obj.ANoElements;
            
%             o = obj.createSaveObj();             %#ok<NASGU>
            save([path file], 'o');
        end
        
        function pbLoad_Callback(obj, object, eventdata) 
            obj = guidata(obj.win);
%              [file path] = uigetfile([obj.baseFolder '\*.mat']);
             [file path] = uigetfile({'*.mat'}, 'Loop to load', obj.saveFolder);
             if file == 0
                 return
             end
%             o = obj.createLoadObj([path file]);
            load([path file]);
%             o.tmpObj = tmpO.o;
            
%             o.win = obj.win;
%             o.baseBaseFolder = obj.baseBaseFolder;
%             obj = o;
            
            obj.noLoops = o.noLoops;
            obj.noChannels = o.noChannels;
            obj.MTabs = o.MTabs;
            obj.MLines = o.MLines;
            obj.MTimeStr = o.MTimeStr;
            obj.MDevice = o.MDevice;
            obj.MValueStr = o.MValueStr;
            obj.MUnits = o.MUnits;
            obj.MFunction = o.MFunction;
            obj.MNoElements = o.MNoElements;
            obj.MVector = o.MVector;
            obj.MfTimeValue = o.MfTimeValue;
            obj.saveParam = o.saveParam;
            obj.saveParamStr = o.saveParamStr;
            obj.saveOtherParamStr = o.saveOtherParamStr;
            obj.saveAllParamStr = o.saveAllParamStr;
            obj.ASaveParam = o.ASaveParam;
            obj.ASaveParamsStr = o.ASaveParamsStr;
            obj.ASaveParamVals = o.ASaveParamVals;
            obj.ASaveParamValsStr = o.ASaveParamValsStr;
            obj.ASaveOtherParamStr = o.ASaveOtherParamStr;
            obj.ANoElements = o.ANoElements;
            
            guidata(obj.win, obj);
            obj.clearFigure(obj.win);
%             obj = obj.initialize([], 0);
            obj.updateGUI(obj);
%             guidata(obj.win, obj);
        end     
        
        function pbOK_Callback(obj, object, eventdata)
            obj = obj.updateObj();
            %             obj = guidata(obj.win);
            
            totElements = 1;
            for i = 1 : obj.noLoops
                for j = 1 : obj.noChannels(i)
%                     if length(obj.saveParamVals) ~= length(obj.MVector{i}{j})
                    if length(obj.ASaveParamVals{i}) ~= length(obj.MVector{i}{j})
                        errordlg('All vectors mast be at the same length','Error', 'modal');
                        return
                    end
                end
%                 if length(obj.MVector{1}{1}) ~= length(obj.MVector{i}{1})
%                     errordlg('All vectors mast be at the same length','Error', 'modal');
%                     return
%                 end
                totElements = totElements * length(obj.ASaveParamVals{i});
            end
%             if length(obj.saveParamVals) ~= totElements
%                 errordlg('All vectors mast be at the same length','Error', 'modal');
%                 return
%             end
            obj.noMeasurements = totElements*obj.noIterations;
            
%             obj.noIterations = -2;
%             guidata(obj.win, obj);
%             uiresume(obj.win);     
            obj.fPause = 0;
            guidata(obj.win, obj);
%             delete(obj.win);
%             obj.win = -1;    
%             o = obj; %#ok<NASGU>
%             save(obj.tmpSaveName, 'o');
        end
%         function closeWin_Callback(obj, object, eventdata)
%             obj.noIterations = -1;
%             guidata(obj.win, obj);
%         end

        function pbCancel_Callback(obj, object, eventdata)
            obj = guidata(obj.win);
            obj.noIterations = -1; 
            obj.fPause = 0;
            guidata(obj.win, obj);
%             uiresume(obj.win); 
%             delete(obj.win);
%             obj.win = -1;  
%             obj.tmpObj.noIterations = -1;
%             obj.tmpObj.win = -1;  
%             o = obj.tmpObj;
%             if isempty(o)
%                 o = obj; %#ok<NASGU>
%             end
%             save(obj.tmpSaveName, 'o');
        end       
        
        function tbEnableEdit_Callback(obj, object, eventdata) 
            obj = guidata(obj.win);
            obj.enableEdit = get(object, 'Value');
%             obj.clearFigure(obj.win);
            guidata(obj.win, obj);
            obj = obj.initialize([], 0); %#ok<NASGU>
        end     
        
        function pbAddLoop_Callback(obj, object, eventdata) 
            obj = guidata(obj.win);
            obj = obj.updateObj();
            obj.noLoops = obj.noLoops + 1;
            obj.noChannels = [obj.noChannels 1];
            guidata(obj.win, obj);
            obj.clearFigure(obj.win);
%             guidata(obj.win, obj);
%             obj = obj.initialize([], 0); %#ok<NASGU>
        end      
        
        function pbRemoveLastLoop_Callback(obj, object, eventdata)
            obj = guidata(obj.win);
            if obj.noLoops == 1
                return
            end
            obj.noLoops = obj.noLoops - 1;            
            obj.noChannels = obj.noChannels(1:end-1);
            guidata(obj.win, obj);
%             obj = obj.updateObj();
%             guidata(obj.win, obj);
            obj.clearFigure(obj.win);
%             obj = obj.initialize([], 0); %#ok<NASGU>
        end     
        
        function pbAAddChannel_Callback(obj,  object, eventdata)
            obj = guidata(obj.win);
            pIndex = obj.getPIndex(object, obj.pbAAddChannel);
%             for i = 1 : length(obj.pbAAddChannel)
%                 if object == obj.pbAAddChannel(i)
%                     pIndex = i;
%                     break;
%                 end
%             end
            obj = obj.updateObj();
            obj.noChannels(pIndex) = obj.noChannels(pIndex) + 1;
            guidata(obj.win, obj);
            obj.clearFigure(obj.win);
%             obj = obj.initialize([], 0); %#ok<NASGU>
        end    
        
        function pbARemoveLastChannel_Callback(obj,  object, eventdata) %#ok<*INUSD>
            obj = guidata(obj.win);
            pIndex = obj.getPIndex(object, obj.pbARemoveLastChannel);
%             for i = 1 : length(obj.pbARemoveLastChannel)
%                 if object == obj.pbARemoveLastChannel(i)
%                     pIndex = i;
%                     break;
%                 end
%             end
            if obj.noChannels(pIndex) == 1
                return
            end
            obj.noChannels(pIndex) = obj.noChannels(pIndex) - 1;
            guidata(obj.win, obj);
            obj = obj.updateObj();
            guidata(obj.win, obj);
            obj.clearFigure(obj.win);
%             obj = obj.initialize([], 0);
        end
        
        function pmMTabs_Callback(obj,  object, eventdata) %#ok<*INUSD>
            obj = guidata(obj.win);
            [i j] = getPCIndex(obj, object, obj.pmMTabs);
            obj.MTabs{i}{j} = get(object, 'Value');
            
            set(obj.pmMLines{i}{j}, 'String', num2cellArr(obj, size(obj.appData.TF.data{obj.MTabs{i}{j}}, 1)));
            set(obj.pmMLines{i}{j}, 'Value', 1);
            guidata(obj.win, obj);
            obj.pmMLines_Callback(obj.pmMLines{i}{j}, []);
            
%             guidata(obj.win, obj);
        end
        
        function pmMLines_Callback(obj,  object, eventdata) %#ok<*INUSD>
            obj = guidata(obj.win);
            [i, j] = getPCIndex(obj, object, obj.pmMLines);
            obj.MLines{i}{j} = get(object, 'Value');
            
            obj.MTimeStr{i}{j} = obj.appData.TF.data{obj.MTabs{i}{j}}{obj.MLines{i}{j}, obj.appData.consts.TF.time+1};
%             obj.MTime{i}{j} = [];
%             try
%                 obj.MTime{i}{j} = obj.evalStr(obj.MTimeStr{i}{j});
%             catch ex
%             end
            set(obj.etMTime{i}{j}, 'String', obj.MTimeStr{i}{j});
            obj.MDevice{i}{j} = obj.appData.TF.data{obj.MTabs{i}{j}}{obj.MLines{i}{j}, obj.appData.consts.TF.devices+1};
            set(obj.etMDevice{i}{j}, 'String', obj.MDevice{i}{j});
            obj.MValueStr{i}{j} = obj.appData.TF.data{obj.MTabs{i}{j}}{obj.MLines{i}{j}, obj.appData.consts.TF.value+1};
%             obj.MValue{i}{j} = [];
%             try
%                 obj.MValue{i}{j} = obj.evalStr(obj.MValueStr{i}{j});
%             catch ex
%             end
            set(obj.etMValue{i}{j}, 'String', obj.MValueStr{i}{j});
            obj.MUnits{i}{j} = obj.appData.TF.data{obj.MTabs{i}{j}}{obj.MLines{i}{j}, obj.appData.consts.TF.units+1};
            set(obj.etMUnits{i}{j}, 'String', obj.MUnits{i}{j});
            obj.MFunction{i}{j} = obj.appData.TF.data{obj.MTabs{i}{j}}{obj.MLines{i}{j}, obj.appData.consts.TF.functions+1};
            set(obj.etMFunction{i}{j}, 'String', obj.MFunction{i}{j});
            
            obj.MVector{i}{j} = []; %the 2D matrix of vectors of the STRINGS of the loop
            obj.MfTimeValue{i}{j} = 0;
            obj.MNoElements{i}{j} = 0;
            set(obj.sMNoElements{i}{j}, 'String', num2str(obj.MNoElements{i}{j}));
           
            guidata(obj.win, obj);
        end
        
        function etMTime_Callback(obj,  object, eventdata) %#ok<*INUSD>
            obj = guidata(obj.win);
            [i, j] = getPCIndex(obj, object, obj.etMTime);
            tmpStr = obj.MTimeStr{i}{j};
            obj.MTimeStr{i}{j} = get(object, 'String');
            
            if obj.MfTimeValue{i}{j} == 0 || obj.MfTimeValue{i}{j} == 1
                obj.MVector{i}{j} = obj.evalStr(obj.MTimeStr{i}{j});
                if isempty(obj.MVector{i}{j})
                    obj.MTimeStr{i}{j} = tmpStr;
                    set(object, 'String', obj.MTimeStr{i}{j});
                    errordlg('Wrong input. Not a vector.', 'Error', 'modal');
                else
                    if ~iscell(obj.MVector{i}{j}) %length(obj.MVector{i}{j}) <= 1
                        obj.MfTimeValue{i}{j} = 0;
                        obj.MNoElements{i}{j} = 0;
                        set(obj.sMNoElements{i}{j}, 'String', num2str(obj.MNoElements{i}{j}));
                    else
                        obj.MfTimeValue{i}{j} = 1;
                        obj.MNoElements{i}{j} = length(obj.MVector{i}{j});
                        set(obj.sMNoElements{i}{j}, 'String', num2str(obj.MNoElements{i}{j}));
                    end
                end
            else
                obj.MTimeStr{i}{j} = tmpStr;
                set(object, 'String', obj.MTimeStr{i}{j});
                errordlg('Cannot change Time and Value together', 'Error', 'modal');
            end
            
            guidata(obj.win, obj);
        end
        
        function etMValue_Callback(obj,  object, eventdata) %#ok<*INUSD>
            obj = guidata(obj.win);
            [i, j] = getPCIndex(obj, object, obj.etMValue);
            tmpStr = obj.MValueStr{i}{j};
            obj.MValueStr{i}{j} = get(object, 'String');
            
            if obj.MfTimeValue{i}{j} == 0 || obj.MfTimeValue{i}{j} == 2
                obj.MVector{i}{j} = obj.evalStr(obj.MValueStr{i}{j});
                if isempty(obj.MVector{i}{j}) 
                    obj.MValueStr{i}{j} = tmpStr;
                    set(object, 'String', obj.MValueStr{i}{j});
                    errordlg('Wrong input. Not a vector.', 'Error', 'modal');
                else
                    if ~iscell(obj.MVector{i}{j}) || length(obj.MVector{i}{j}) <= 1
                        obj.MfTimeValue{i}{j} = 0;
                        obj.MNoElements{i}{j} = 0;
                        set(obj.sMNoElements{i}{j}, 'String', num2str(obj.MNoElements{i}{j}));
                    else
                        obj.MfTimeValue{i}{j} = 2;
                        obj.MNoElements{i}{j} = length(obj.MVector{i}{j});
                        set(obj.sMNoElements{i}{j}, 'String', num2str(obj.MNoElements{i}{j}));
                    end
                end
            else
                obj.MValueStr{i}{j} = tmpStr;
                set(object, 'String', obj.MValueStr{i}{j});
                errordlg('Cannot change Time and Value together', 'Error', 'modal');
            end
            
            guidata(obj.win, obj);
        end
          
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = updateObj(obj) %createSaveObj(obj)
            %             o = obj;
            obj = guidata(obj.win);
            
            % clear obj
            obj.ASaveParam = [];
            obj.ASaveParamsStr = {};
            obj.ASaveParamVals = {};
            obj.ANoElements = {};
%             obj.MChangeTypes = {};
%             obj.MEventName = {};
%             obj.MChannelName = {};
%             obj.MRumpNo = {};
%             obj.MVectorRFCommands = {};
%             obj.MVector = {};
            obj.MTabs = {}; %2D cell array
            obj.MLines = {};
%             obj.MTime = {};
            obj.MTimeStr = {};
            obj.MDevice = {};
%             obj.MValue = {};
            obj.MValueStr = {};
            obj.MUnits = {};
            obj.MFunction = {};
            obj.MNoElements = {};
            obj.MVector = {}; %the 2D matrix of vectors of the STRINGS of the loop
%             obj.MfTimeValue = {}; %boolean 2D matrix: time = true, value = false

            obj.baseBaseFolder =  get(obj.etReadDir, 'String');
            obj.noIterations = str2double(get(obj.etNumIterations, 'String'));
            obj.enableEdit = get(obj.tbEnableEdit, 'Value');
            obj.iterationsOrder = get(obj.pmIterationsOrder, 'Value');
            for i = 1 : obj.noLoops
                obj.ASaveParam(i) = get(obj.pmASaveParam(i), 'Value');
                obj.ASaveParamsStr{i} = get(obj.pmASaveParam(i), 'String');
                obj.ASaveParamVals{i} = eval(get(obj.etASaveParamVals(i), 'String'));
                obj.ASaveParamValsStr{i} = get(obj.etASaveParamVals(i), 'String');
                obj.ANoElements{i} = get(obj.sANoElements(i), 'String');
                for j = 1 : obj.noChannels(i)
                    obj.MTabs{i}{j} = get(obj.pmMTabs{i}{j}, 'Value');
                    obj.MLines{i}{j} = get(obj.pmMLines{i}{j}, 'Value');
                    
%                     [obj.MTimeStr{i}{j}, obj.MTime{i}{j}] = obj.evalStr(obj.etMTime{i}{j}, get(obj.etMTime{i}{j}, 'String'), i, j);
                    obj.MTimeStr{i}{j} = get(obj.etMTime{i}{j}, 'String');
%                     obj.MTime{i}{j} = obj.evalStr(obj.MTimeStr{i}{j});
                    obj.MDevice{i}{j} = get(obj.etMDevice{i}{j}, 'String');
%                     [obj.MValueStr{i}{j}, obj.MValue{i}{j}] = obj.evalStr(obj.etMValue{i}{j}, get(obj.etMValue{i}{j}, 'String'), i, j);
                    obj.MValueStr{i}{j} = get(obj.etMValue{i}{j}, 'String');
%                     obj.MValue{i}{j} = obj.evalStr(obj.MValueStr{i}{j});
                    obj.MUnits{i}{j} = get(obj.etMUnits{i}{j}, 'String');
                    obj.MFunction{i}{j} = get(obj.etMFunction{i}{j}, 'String');
                    obj.MNoElements{i}{j} = str2double(get(obj.sMNoElements{i}{j}, 'String'));
                    obj.MVector{i}{j} = obj.evalStr(obj.MValueStr{i}{j}); %the 2D matrix of vectors of the STRINGS of the loop
%                     obj.MfTimeValue{i}{j} = 0;
%                     obj.MChangeTypes{i}{j} = get(obj.pmMChangeTypes{i}{j}, 'Value'); %2D cell array
%                     obj.MEventName{i}{j} = get(obj.pmMEventName{i}{j}, 'Value');
%                     obj.MChannelName{i}{j} = get(obj.pmMChannelName{i}{j}, 'Value');
%                     obj.MRumpNo{i}{j} = get(obj.pmMRumpNo{i}{j}, 'Value');
%                     
%                     [obj.MVectorRFCommands{i}{j} obj.MVector{i}{j}] = obj.evalStr(obj.etMVector{i}{j}, get(obj.etMVector{i}{j}, 'String'), i, j);
%                     obj.MVectorStr{i}{j} = get(obj.etMVector{i}{j}, 'String');
%                     obj.MNoElements{i}{j} = get(obj.sMNoElements{i}{j}, 'String');
                end
            end
            guidata(obj.win, obj);
        end
        
            
        function updateGUI(obj, o)
            obj = guidata(obj.win);
            if nargin < 2
                o = obj;
            end
            set(obj.etReadDir, 'String', num2str(o.baseBaseFolder));
            set(obj.etNumIterations, 'String', num2str(o.noIterations));
            set(obj.tbEnableEdit, 'Value', o.enableEdit);
            set(obj.pmIterationsOrder, 'Value', o.iterationsOrder);
            for i = 1 : length(o.MTabs)%o.noLoops
                set(obj.pmASaveParam(i), 'Value', o.ASaveParam(i)); 
                set(obj.pmASaveParam(i), 'String', o.ASaveParamsStr{i});
                set(obj.etASaveParamVals(i), 'String', o.ASaveParamValsStr{i});%vec2str(o.ASaveParamVals{i}));
                set(obj.sANoElements(i), 'String', o.ANoElements{i});
                for j = 1 : length(o.MTabs{i})%o.noChannels(i)
                    set(obj.pmMTabs{i}{j}, 'Value', o.MTabs{i}{j}); %2D cell array
                    obj.pmMTabs_Callback(obj.pmMTabs{i}{j});
                    set(obj.pmMLines{i}{j}, 'Value', o.MLines{i}{j});
                    obj.pmMLines_Callback(obj.pmMLines{i}{j});
                    set(obj.etMTime{i}{j}, 'String', o.MTimeStr{i}{j});
                    set(obj.etMDevice{i}{j}, 'String', o.MDevice{i}{j});
                    set(obj.etMValue{i}{j}, 'String', o.MValueStr{i}{j});
                    set(obj.etMUnits{i}{j}, 'String', o.MUnits{i}{j});
                    set(obj.etMFunction{i}{j}, 'String', o.MFunction{i}{j});
                    
%                     set(obj.pmMChangeTypes{i}{j}, 'Value', o.MChangeTypes{i}{j}); %2D cell array
%                     obj.pmMChangeTypes_Callback( obj.pmMChangeTypes{i}{j}, []);
%                     set(obj.pmMEventName{i}{j}, 'Value', o.MEventName{i}{j});
%                     set(obj.pmMChannelName{i}{j}, 'Value', o.MChannelName{i}{j});
%                     obj.pmMChannelName_Callback( obj.pmMChannelName{i}{j},  []);
%                     set(obj.pmMRumpNo{i}{j}, 'Value', o.MRumpNo{i}{j});
                    
%                     set(obj.etMVector{i}{j}, 'String', o.MVectorStr{i}{j});%[obj.MVectorRFCommands{i}{j} o.MVectorStr{i}{j}]);%vec2str(o.MVector{i}{j})]);
                    set(obj.sMNoElements{i}{j}, 'String', num2str(o.MNoElements{i}{j}));
                end
            end
            guidata(obj.win, obj);
        end
        
        function clearFigure(obj, fig)
%             obj = guidata(obj.win);
            obj.pALoops = [];
            obj.pmASaveParam = [];
            obj.etASaveParamVals = [];
            obj.sANoElements = [];
            
            obj.pbAAddChannel = [];
            obj.pbARemoveLastChannel = [];
%             obj.pmMChangeTypes = {}; %2D cell array
%             obj.pmMEventName = {};
%             obj.pmMChannelName = {};     
%             obj.pmMRumpNo = {};
%             obj.etMVector = {};
            obj.pmMTabs = {}; 
            obj.pmMLines = {};
            obj.etMTime = {};
            obj.etMDevice = {};
            obj.etMValue = {};
            obj.etMUnits = {};
            obj.etMFunction = {};            
            obj.sMNoElements = {};
            obj.sMElements = {};
            
            clf(fig, 'reset');
            guidata(obj.win, obj);
            obj = obj.initialize([], 0); %#ok<NASGU>
        end
        
        function [pIndex cIndex] = getPCIndex(obj, object, objectM) %#ok<MANU>
            pIndex = 0;
            cIndex = 0;
            for i = 1 : length(objectM)
                for j = 1 : length(objectM{i})
                    if object == objectM{i}{j}
                        pIndex = i;
                        cIndex = j;
                        break;
                    end
                end
            end
        end
        
        function [pIndex] = getPIndex(obj, object, objectA) %#ok<MANU>
            pIndex = 0;
            for i = 1 : length(objectA)
                if object == objectA(i)
                    pIndex = i;
                    break;
                end
            end
        end
       
%         function vec = evalStr(obj, str)
%             vec = {};
%             try
%                 arr = eval(str);
%                 vec = obj.num2cellArr(arr);
%             catch ex
%                 ind1 = findstr('[', str);
%                 ind2 = findstr(']', str);
%                 if isempty(ind1) && isempty(ind2)
%                     vec = str;
%                     return;
%                 end
%                 if isempty(ind1) || isempty(ind2) || length(ind1) > 1 || length(ind2) > 1
% %                     errordlg('Wrong input. Not a vector.', 'Error', 'modal');
%                     return;
%                 end
%                 arr = eval(str(ind1:ind2));
%                 vec = obj.num2cellArr(arr);
%                 for i = 1 : length(vec)
%                     vec{i} = [str(1:ind1-1) vec{i} str(ind2+1:end)];
%                 end
%             end
%         end
%         function [RFCommand, vec] = evalStr(obj, object, str, i, j)
%             RFCommand = str;
%             vec = [];
%             try
%                 vec = eval(str);
%             catch ex %#ok<NASGU>
% %                 if i ~= 0 %&& get(obj.pmMChangeTypes{i}{j}, 'Value') == obj.valueTypes.RFCommand
% %                     s=regexp( str, ' ', 'split');
% %                     flag = 0;
% %                     for k = 1 : length(s)
% %                         try
% %                             vec = eval([s{k:end}]);
% %                             flag = 1;
% %                             break;
% %                         catch ex %#ok<NASGU>
% %                             RFCommand = [RFCommand s{k} ' ']; %#ok<AGROW>
% %                         end
% %                     end
% %                     if flag == 0
% %                         set(object, 'String', '');
% %                         set(obj.sMNoElements{i}{j}, 'String','0 elements');
% %                         errordlg('Input must be an array','Error', 'modal');
% %                         return
% %                     end
% %                 else
% %                     set(object, 'String', '');
% %                     set(obj.sMNoElements{i}{j}, 'String','0 elements');
% %                     errordlg('Input must be an array','Error', 'modal');
% %                     return
% %                 end
%             end
%         end
        
%         function arr = num2cellArr(obj, num)
%             arr = cell(1, length(num));
%             if numel(num) == 1
%                 num = 1:num;
%             end
%             for i = 1 : length(num)
%                 arr{i} = num2str(num(i));
%             end
%         end
        
        
        
    end
    
    
    
end
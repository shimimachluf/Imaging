
classdef QuickLoop < Measurement
    %TOF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tab = -1;
        row = -1;
        col = -1;
        values = '';
        vecComamnds = {};
        saveParam = -1;
%         saveOtherParamStr = 'Other Param';
        saveParamStr = '';
        saveAllParamStr = {};
        saveParamVals = [];
        saveParamValsStr = 'empty';
        
        
    end
    
    
     methods ( Static = true )
        function o = create(appData)
            o = QuickLoop(appData);
        end
     end
     
    methods        
        function obj = QuickLoop(appData)
            % first line - MUST
%             obj = obj@Measurement(LVData.readLabview(appData.consts.defaultStrLVFile_Save));%appData.data.LVData);
%             
%             obj.type = obj.valueTypes.eventStartTime;
%             obj.event = obj.LVData.getEventIndex('Imaging');
%             obj.channel = -1;
%             obj.ramp = -1;
%             obj.newVal = -1;

            obj.appData = appData;
            obj.baseFolder = appData.save.saveDir;
            obj.tab = appData.TF.currentTab;
            cell = appData.TF.currentCell;
            if numel(cell) == 2
                obj.row = cell(1);
                obj.col = cell(2);
            else
               errordlg('Please choose only one cell', 'Error', 'modal');
%                obj = [];
               return
            end
            if ~(obj.col == appData.consts.TF.time+1 || obj.col == appData.consts.TF.value+1)
                errordlg('Please choose only Time or Value cell', 'Error', 'modal');
%                 obj = [];
                return
            end
                        
            obj.vecComamnds = {};
            obj.saveAllParamStr = appData.consts.saveParams.str;
            
            % last line - MUST
            obj = obj.initialize(appData);
        end
        
        function obj = initialize(obj, appData)           
            if obj.isInitialized == 0
%                 answer = measDlg({'Folder' 'Num Iterations' 'Imaging Time [ms]'  'Iterations Order'}, 'Time of Flight Measurements', [1 1 1 1]', ...
%                     {obj.baseFolder appData.consts.loops.TOF.noIterations appData.consts.loops.TOF.TOFTimes appData.consts.loops.iterationsStr}, ...
%                     appData.consts.loops.options, {'folder' 'edit' 'edit' 'popupmenu'}, {obj.baseFolder 0 0 1}); %#ok<*NBRAK>
                answer = measDlg({'Folder' 'Num Iterations' 'Values'  'Iterations Order' 'Save Param' 'Save Param Values', ...
                    'Tab Name (info)' 'Line Number (info)'}, 'Quick Scan', [1 1 1 1 1 1 1 1]', ...
                    {obj.baseFolder '1' obj.appData.TF.data{obj.tab}{obj.row, obj.col} appData.consts.loops.iterationsStr ...
                     obj.saveAllParamStr obj.saveParamValsStr obj.appData.TF.tabNames{obj.tab} num2str(obj.row)}, ...
                    appData.consts.loops.options, {'folder' 'edit' 'edit' 'popupmenu' 'popupmenu' 'edit' 'edit' 'edit'}, ...
                    {obj.baseFolder 0 0 1 1 0 0 0}); %#ok<*NBRAK>
%                 answer = measDlg({'Folder'}, 'Quick Scan', [1], {obj.baseFolder}, appData.consts.loops.options, {'folder'},{obj.baseFolder});
                obj.isInitialized = 1;
            else
                answer = measDlg({'Folder' 'Num Iterations' 'Values'  'Iterations Order' 'Save Param' 'Save Param Values' ...
                    'Tab Name (info)' 'Line Number (info)'}, 'Quick Scan', [1 1 1 1 1 1 1 1]', ...
                    {obj.baseFolder obj.noIterations obj.values obj.appData.consts.loops.iterationsStr ...
                    obj.saveAllParamStr obj.saveParamValsStr  obj.appData.TF.tabNames{obj.tab} num2str(obj.row)}, ...
                    appData.consts.loops.options, {'folder' 'edit' 'edit' 'popupmenu' 'popupmenu' 'edit' 'edit' 'edit'}, ...
                    {obj.baseFolder 0 0 1 obj.saveParam 0 0 0}); %#ok<*NBRAK>
            end
            if isempty(answer)
%                 obj = [];
                return
            end
%             str = answer{1};
%             ind = strfind(str, '\');
%             if isempty(str2num(str(ind(end)+1)))
%                 obj.baseFolder = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1:end)];
%             else
%                 obj.baseFolder = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1+6:end)];
%             end
            obj.baseFolder = answer{1};
            obj.noIterations = str2double(answer{2});
            obj.values = answer{3};
            obj.vecComamnds = obj.evalStr(answer{3});%eval([ '[' answer{3}  ']' ]);
            if isempty(obj.vecComamnds)
                errordlg('Input must be an array','Error', 'modal');
            end
            obj.iterationsOrder = answer{4};
            obj.saveParam = answer{5};
            if ( obj.saveParam == length(appData.consts.saveParams.str) )
                param = inputdlg('Enter param name:', 'Other param input');
                if ~isempty(param)
                    obj.saveParamStr = param{1};
                    obj.saveAllParamStr = {['O.P. - ' param{1}] obj.saveAllParamStr{2:end}};
%                     set(object, 'String', obj.saveAllParamStr);
                    obj.saveParam = 1;
%                     set(object, 'Value', 1);
                end
            else 
                obj.saveParamStr = obj.saveAllParamStr{obj.saveParam};
            end
%             obj.saveParamStr = '';
%             obj.saveOtherParamStr = '';
            
            if strcmp(answer{6}, 'empty')
                obj.saveParamValsStr = obj.values(strfind( obj.values, '['):strfind( obj.values, ']'));
                if isempty(obj.saveParamValsStr)
                    obj.saveParamValsStr = obj.values;
                end
                obj.saveParamVals = eval(obj.saveParamValsStr); 
            else
                obj.saveParamValsStr = answer{6};
                try
                    obj.saveParamVals = eval(answer{6});
                catch ex
                    errordlg('Input must be a numeric array','Error', 'modal');
                    return
                end
            end
            if isempty(obj.saveParamVals) %|| strcmp(obj.saveParamValsStr, 'empty')
                errordlg('Input must be an array','Error', 'modal');
            end
            
            if length(obj.saveParamVals) ~= length(obj.vecComamnds)
                errordlg('''Values'' and ''Save Param Values'' must have the same length','Error', 'modal');
            end
            
            [obj.vecComamnds, randVec] = obj.iterateVec(obj.vecComamnds, obj.iterationsOrder, []);
            obj.saveParamVals = obj.iterateVec(obj.saveParamVals, obj.iterationsOrder, randVec);
            
%             obj.imagingTimes = obj.trapReleaseTime + TOF*1e3;
            obj.noMeasurements = length(obj.vecComamnds);
            
        end
                
        function obj = edit(obj, appData)
%             tmpObj = obj;
%             obj.enableEdit = 0;
            obj = obj.initialize(appData);
%             if obj.noIterations == -1
%                 obj = tmpObj;
%             end
        end
        
        function [obj, newTFData] = next(obj, appData) 
            
            if obj.position
                % change save param, param val and folder 
                appData.save.saveOtherParamStr = obj.saveParamStr;
                set(appData.ui.pmSaveParam, 'String', obj.saveAllParamStr);
                set(appData.ui.pmSaveParam, 'Value', obj.saveParam);
                set(appData.ui.etParamVal, 'String', num2str(obj.saveParamVals(obj.position)));
            end
            
            if obj.position == obj.noMeasurements
                newTFData = [];
                return
            end
            
            
%             if obj.isFirstMeas
%                 obj.isFirstMeas = 0;
%                 obj.fFirstMeas = 1;
%                 newTFData = obj.appData.TF.data;
%                 return
%             end
%             
%             obj.fFirstMeas = 0;
            obj.position = obj.position + 1;
            
            newTFData = obj.appData.TF.data;
            newTFData{obj.tab}{obj.row, obj.col} = obj.vecComamnds{obj.position};
            
%             % change save param, param val and folder 
            
%             appData.save.saveOtherParamStr = obj.saveParamStr;
%             set(appData.ui.pmSaveParam, 'String', obj.saveAllParamStr);
%             set(appData.ui.pmSaveParam, 'Value', obj.saveParam);
%             set(appData.ui.etParamVal, 'String', num2str(obj.saveParamVals(obj.position)));
            
            
        end
        
        function str = getMeasStr(obj, appData)
            str = [ appData.consts.availableLoops.str{appData.consts.availableLoops.TFQuickLoop}  ' (' obj.getCurrMeas() ')'];
        end
    end
    
    
end


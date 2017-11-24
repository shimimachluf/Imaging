
classdef Measurement
    
    properties (SetAccess = public)
        appData = [];
        baseFolder = '';
        isInitialized = 0;
        
        noIterations = -1;
        iterationsOrder = -1;
        noMeasurements = -1;
        position = 0;
        
%         fFirstMeas = 1;
%         isFirstMeas = 1;
%         valueTypes = LVData.getTypes();
    end
    
    methods
%         function obj = Measurement(TFData)
%             obj.TFData = TFData;
%         end
        function [newVec, randVec] = iterateVec(obj, vec, itarationsOrder, randVec)
            if iscell(vec)
                newVec = cell([length(vec) obj.noIterations]);
            elseif isnumeric(vec)
                newVec = zeros([length(vec) obj.noIterations]);
            else
                errordlg('Vector is not cell nor numeric', 'Error', 'modal');
                newVec = [];
                return
            end
%             if obj.noIterations == 1
%                 newVec = vec';
%             end
            for i = 1 : obj.noIterations
                newVec(:, i) = vec';
            end
           
            switch itarationsOrder
                case 1 %iterate measurement
                    newVec = newVec';
                    newVec = newVec(:);
                case 2 % iterate loop
%                     LT = LT';
                    newVec = newVec(:);
                case 3 % random iterations
                    newVec = newVec(:);
                    if isempty(randVec)
                        randVec = randperm(length(newVec));
                    end
                    newVec = newVec(randVec);
            end
        end
        function currMeas = getCurrMeas(obj) %return string 'current measurement / total measurements'
            currMeas = [ num2str(obj.position) '/' num2str(obj.noMeasurements)];
        end
        function vec = evalStr(obj, str)
            vec = {};
            try
                arr = eval(str);
                vec = obj.num2cellArr(arr);
            catch ex
                ind1 = strfind( str, '[');
                ind2 = strfind( str, ']');
                if isempty(ind1) && isempty(ind2)
                    vec = str;
                    return;
                end
                if isempty(ind1) || isempty(ind2) || length(ind1) > 1 || length(ind2) > 1
%                     errordlg('Wrong input. Not a vector.', 'Error', 'modal');
                    return;
                end
                arr = eval(str(ind1:ind2));
                vec = obj.num2cellArr(arr);
                for i = 1 : length(vec)
                    vec{i} = [str(1:ind1-1) vec{i} str(ind2+1:end)];
                end
            end
        end
        function arr = num2cellArr(obj, num)
            arr = cell(1, length(num));
            if numel(num) == 1
                num = 1:num;
            end
            for i = 1 : length(num)
                arr{i} = num2str(num(i));
            end
        end
    end
    
    
    methods ( Abstract = true, Static = true )
        o = create(appData);
    end
    
    methods ( Abstract = true )
        obj = initialize(obj, appData);
        obj = edit(obj, appData);
        [obj, newTFData] = next(obj, appData);
        str = getMeasStr(obj, appData);
    end        
    
end
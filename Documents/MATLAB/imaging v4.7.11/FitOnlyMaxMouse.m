classdef FitOnlyMaxMouse < FitOnlyMax
    
    properties ( Constant = true )
        ID_1 = 'FitOnlyMaxMouse';
    end
%     properties ( SetAccess = private)
%         stdv = 0;
%     end
    
    methods
        function appData = analyze(obj, appData) % do the analysis
            [pic, x0, y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
            [h, w] = size(pic);
            
            %            %binning and max
                       binW = appData.options.avgWidth;
            %            binnedData = binning ( pic, binW*2+1);
            %            [maxes, indexes] = max(binnedData);                     % find maximum
            %            [maxValue, xPosMax] = max(maxes);
            %            yPosMax = indexes(xPosMax);
            
            obj.xCenter = round(appData.data.mouseCenterX / (appData.data.camera.xPixSz * 1000));% - x0;
            obj.yCenter = round(appData.data.mouseCenterY / (appData.data.camera.yPixSz * 1000));% - y0;
            obj.maxVal = mean(mean(pic([obj.yCenter-binW : obj.yCenter+binW] - y0+1, [obj.xCenter-binW : obj.xCenter+binW]-x0+1)));
            
%             % center
%             obj.xCenter = appData.data.mouseCenterX;%(binW*2+1) * (xPosMax ) + x0-binW;
%             obj.yCenter = appData.data.mouseCenterY;%(binW*2+1) * (yPosMax ) + y0-binW;
            
            % unit size
            obj.xUnitSize = w;
            obj.yUnitSize = h;
            
            obj.stdv = std(sqrt(pic(:).^2));
            
            % calc ROI size (use ROIUnits.m) - MUST be after fit
            [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
            
            obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
                [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);
            
            [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors(obj.xCenter, obj.yCenter, binW);
            
            obj.xData = xData;
            obj.xStart = x0;
            obj.yData = yData;
            obj.yStart = y0;
            
            % last
            % set ROI pic - MUST be after defining ROI
            appData.data.fits{appData.consts.fitTypes.onlyMaxMouse} = obj;
            appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
            %
            %            % last
            %            appData.data.fits{appData.consts.fitTypes.onlyMaximum} = obj;
        end
    end
    
end
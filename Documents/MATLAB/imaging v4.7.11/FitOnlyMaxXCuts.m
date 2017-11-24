classdef FitOnlyMaxXCuts < FitTypes
%FITONLYMAX Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'FitOnlyMaxXCuts';
   end
   properties ( SetAccess = protected)
       atomsNoXCuts = [];
       newCen = []; %pixels
       xSz = -1; %pixels, newCen-ySz : newCen+ySz-1
       NCuts = -1; %2*NCuts
       
       ROI = [];
       ROIshift = [];
       ROIref = [];
       atomsNoRef = -1;
       atomsRatio = -1;
   end

   methods 
       function appData = analyze(obj, appData) % do the analysis
           obj.xSz = 5; %pixels, newCen-xSz : newCen+xSz-1
           obj.NCuts = 5; %2*NCuts
           obj.ROIshift = [0 0 -0.08 0.01];
           
           [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
           [h w] = size(pic);
           %binning and max
           binW = appData.options.avgWidth;
           binnedData = binning ( pic, binW*2+1);
           [maxes, indexes] = max(binnedData);                     % find maximum
           [maxValue, xPosMax] = max(maxes);
           yPosMax = indexes(xPosMax);   
           obj.maxVal = maxValue;% / (appData.options.avgWidth*2)^2; %no need, already done in binning.m
           % center
           obj.xCenter = (binW*2+1) * (xPosMax ) + x0-binW;
           obj.yCenter = (binW*2+1) * (yPosMax ) + y0-binW; 
           % unit size
           obj.xUnitSize = w;
           obj.yUnitSize = h;   
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           obj.ROI = [appData.data.ROISizeX appData.data.ROISizeY appData.data.ROICenterX appData.data.ROICenterY];
           obj.ROIref = obj.ROI + obj.ROIshift;
           
           %main ROI
           appData.data.ROISizeX = obj.ROI(1);
           appData.data.ROISizeY = obj.ROI(2);
           appData.data.ROICenterX = obj.ROI(3);
           appData.data.ROICenterY = obj.ROI(4);
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);
           
           %ref ROI
           appData.data.ROISizeX = obj.ROIref(1);
           appData.data.ROISizeY = obj.ROIref(2);
           appData.data.ROICenterX = obj.ROIref(3);
           appData.data.ROICenterY = obj.ROIref(4);
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           obj.atomsNoRef = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);
           
           obj.atomsRatio = obj.atomsNo/obj.atomsNoRef;
           
           %return ROI to previous values
           appData.data.ROISizeX = obj.ROI(1);
           appData.data.ROISizeY = obj.ROI(2);
           appData.data.ROICenterX = obj.ROI(3);
           appData.data.ROICenterY = obj.ROI(4);
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           
%            obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
%                [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);
           
%            yCen = (obj.ROIBottom+obj.ROITop)/2;
           xCen = (obj.ROILeft+obj.ROIRight)/2;
           for i = 1 : 2*obj.NCuts
               obj.newCen(i) = xCen + 2*(i-obj.NCuts)*obj.xSz-obj.xSz;
               obj.atomsNoXCuts(i) = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
                   [obj.newCen(i)-obj.xSz : obj.newCen(i)+obj.xSz-1] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);
%                    [obj.ROILeft : obj.ROIRight] - x0+1, [obj.newCen(i)-obj.ySz : obj.newCen(i)+obj.ySz-1] - y0+1);
           end
           obj.atomsNoXCuts = obj.atomsNoXCuts / obj.atomsNoRef;
           
           [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors(obj.xCenter, obj.yCenter, binW);
           
           obj.xData = xData;
           obj.xStart = x0;
           obj.yData = yData;
           obj.yStart = y0;
           
           % last
           % set ROI pic - MUST be after defining ROI
           appData.data.fits{appData.consts.fitTypes.onlyMaxXCuts} = obj;
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
%            
%            % last 
%            appData.data.fits{appData.consts.fitTypes.onlyMaximum} = obj;
       end
       
       function normalizedROI = getNormalizedROI(obj, pic, x, y) % return normalized ROI (to the fitting constant)
           normalizedROI = pic(y, x);
       end
       
       function normalizedROI = getTheoreticalROI(obj, pic, x, y)
           normalizedROI = pic(y, x);
       end
       
       function normalizedPic = normalizePic(obj, pic)
           normalizedPic = pic/obj.maxVal;
       end
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
           xFit = zeros(size(x));
           yFit = zeros(size(y));
       end
       
       function  plotFitResults(obj, appData)  % plots the text
           [pic x0 y0] = appData.data.plots{appData.data.plotType}.getPic();
%            text( 10, 190, ['Atoms Num: ' num2str(obj.atomsNo/1e6) '*10^6'], 'fontSize', 20);
%            text( 50, 130, {['OD_ = ' num2str(obj.maxVal) ], ...
%                ['x_0 = ' num2str((obj.xCenter-x0+1) * appData.data.camera.xPixSz * 1000) ' mm'], ...
%                ['y_0 = ' num2str((obj.yCenter-y0+1) * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
%            text(50, 80, ['std = ' num2str(obj.stdv)], 'fontsize', 12);
            set(appData.ui.stFitResultsAtomNum, 'String',['Atoms Num: ' formatNum(obj.atomsNo, 'num')]);
            set(appData.ui.stFitResultsFitFunction, 'String', 'Fit Function: Only Max X-Cuts');
            set(appData.ui.stFitResults1, 'String', {['OD = ' num2str(obj.maxVal) ], ...
               ['x_0 = ' formatNum((obj.xCenter-x0+1) * appData.data.camera.xPixSz, 'dis')], ...
               ['y_0 = ' formatNum((obj.yCenter-y0+1) * appData.data.camera.yPixSz, 'dis')]});
       end
       
   end
end 

classdef Fit1DGaussianMouse < Fit1DGaussian
%FIT1DGAUSSIANMOUSE Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID_1 = 'Fit1DGaussianMouse';
   end
  

   methods 
       function appData = analyze(obj, appData) % do the analysis
           [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
           [h w] = size(pic);

            xCenter = round(appData.data.mouseCenterX/1000/appData.data.camera.xPixSz);%-x0;
            yCenter = round(appData.data.mouseCenterY/1000/appData.data.camera.yPixSz);%-y0;
            
            % fitting
            [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
            x = [1 : w] + x0-1;
            y = [1 : h] + y0-1;            
            [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', 'gauss1'); 
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', 'gauss1');  
%             xCenter = round(obj.xRes.b1);
%             yCenter = round(obj.yRes.b1);
            if ( xCenter<0 || yCenter<0)
                a=1;
            end
            
            [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.xRes.a1 obj.xRes.b1 obj.xRes.c1/sqrt(2)]);%[1 width/2 width/10]);
            f = fittype('Ax*exp(-(x-x0)^2/(2*sigmaX^2))', 'coefficients', {'Ax', 'x0', 'sigmaX'}, 'independent', 'x', 'dependent', 'y', 'options', s);
            [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', f); 
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.yRes.a1 obj.yRes.b1 obj.yRes.c1/sqrt(2)]);%[1 width/2 width/10]);
            f = fittype('Ay*exp(-(y-y0)^2/(2*sigmaY^2))', 'coefficients', {'Ay', 'y0', 'sigmaY'}, 'independent', 'y', 'dependent', 'x', 'options', s);
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', f); 
%             xCenter = round(obj.xRes.x0);
%             yCenter = round(obj.yRes.y0);            
            if ( xCenter<0 || yCenter<0)
                a=1;
            end
            
            [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.xRes.Ax obj.xRes.x0 obj.xRes.sigmaX 0], 'Lower', [0 -Inf 0 -Inf]);
            f = fittype('Ax*exp(-(x-x0)^2/(2*sigmaX^2))+Cx', 'coefficients', {'Ax', 'x0', 'sigmaX', 'Cx'}, 'independent', 'x', 'dependent', 'y', 'options', s);
            [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', f); 
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.yRes.Ay obj.yRes.y0 obj.yRes.sigmaY 0], 'Lower', [0 -Inf 0 -Inf]);
            f = fittype('Ay*exp(-(y-y0)^2/(2*sigmaY^2))+Cy', 'coefficients', {'Ay', 'y0', 'sigmaY', 'Cy'}, 'independent', 'y', 'dependent', 'x', 'options', s);
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', f); 

            
            %set fit params
            obj.xCenter = round(obj.xRes.x0); % should be indexes (integers)
            obj.yCenter= round(obj.yRes.y0);
%             obj.xCenter = xCenter;
%             obj.yCenter = yCenter;
            obj.xUnitSize = obj.xRes.sigmaX;
            obj.yUnitSize = obj.yRes.sigmaY;
            obj.maxVal = mean([obj.xRes.Ax obj.yRes.Ay]);
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           
           obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);            
            
           obj.xData = xData;
           obj.xStart = x0;
           obj.yData = yData;
           obj.yStart = y0;
           
           % last 
           appData.data.fits{appData.consts.fitTypes.oneDGaussianMouse} = obj;
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
       end
       
   end
end 

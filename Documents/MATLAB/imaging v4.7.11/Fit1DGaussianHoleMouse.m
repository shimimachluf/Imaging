classdef Fit1DGaussianHoleMouse < Fit1DGaussian
%FIT1DGAUSSIANMOUSE Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID_2 = 'Fit1DGaussianHoleMouse';
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
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', ...
                [obj.xRes.a1 obj.xRes.b1 obj.xRes.c1/sqrt(2) obj.xRes.a1/2 xCenter-x0 obj.xRes.c1/sqrt(2)/4]);
            f = fittype('Ax*exp(-(x-x0)^2/(2*sigmaX^2))-Ax2*exp(-(x-x02)^2/(2*sigmaX2^2))', 'coefficients', ...
                {'Ax', 'x0', 'sigmaX','Ax2', 'x02', 'sigmaX2'}, 'independent', 'x', 'dependent', 'y', 'options', s);
            [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', f); 
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', ...
                [obj.yRes.a1 obj.yRes.b1 obj.yRes.c1/sqrt(2) obj.yRes.a1/2 yCenter-y0 obj.yRes.c1/sqrt(2)/4]);
            f = fittype('Ay*exp(-(y-y0)^2/(2*sigmaY^2))-Ay2*exp(-(y-y02)^2/(2*sigmaY2^2))', 'coefficients', ...
                {'Ay', 'y0', 'sigmaY' 'Ay2', 'y02', 'sigmaY2'}, 'independent', 'y', 'dependent', 'x', 'options', s);
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', f); 
%             xCenter = round(obj.xRes.x0);
%             yCenter = round(obj.yRes.y0);            
            if ( xCenter<0 || yCenter<0)
                a=1;
            end
            
            [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', ...
                [obj.xRes.Ax obj.xRes.x0 obj.xRes.sigmaX obj.xRes.Ax2 obj.xRes.x02 obj.xRes.sigmaX2 0], ...
                'Lower', [0 -Inf 0 0 -Inf 0 -Inf]);
            f = fittype('Ax*exp(-(x-x0)^2/(2*sigmaX^2))-Ax2*exp(-(x-x02)^2/(2*sigmaX2^2))+Cx', 'coefficients', ...
                {'Ax', 'x0', 'sigmaX','Ax2', 'x02', 'sigmaX2', 'Cx'}, 'independent', 'x', 'dependent', 'y', 'options', s);
            [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', f); 
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', ...
                [obj.yRes.Ay obj.yRes.y0 obj.yRes.sigmaY obj.yRes.Ay2 obj.yRes.y02 obj.yRes.sigmaY2 0], ...
                'Lower', [0 -Inf 0 0 -Inf 0 -Inf]);
            f = fittype('Ay*exp(-(y-y0)^2/(2*sigmaY^2))-Ay2*exp(-(y-y02)^2/(2*sigmaY2^2))+Cy', 'coefficients', ...
                {'Ay', 'y0', 'sigmaY','Ay2', 'y02', 'sigmaY2', 'Cy'}, 'independent', 'y', 'dependent', 'x', 'options', s);
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', f); 

            
            %set fit params
%             obj.xCenter = round(obj.xRes.x0); % should be indexes (integers)
%             obj.yCenter= round(obj.yRes.y0);
            obj.xCenter = xCenter;
            obj.yCenter = yCenter;
            obj.xUnitSize = obj.xRes.sigmaX;
            obj.yUnitSize = obj.yRes.sigmaY;
            obj.maxVal = mean([obj.xRes.Ax obj.yRes.Ay]);
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft, obj.ROITop, obj.ROIRight, obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           
           obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1);            
            
           obj.xData = xData;
           obj.xStart = x0;
           obj.yData = yData;
           obj.yStart = y0;
           
           % last 
           appData.data.fits{appData.consts.fitTypes.oneDGaussianHoleMouse} = obj;
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
       end
       
       function [xFit, yFit] = getXYFitVectors(obj, x, y)
           xFit1 = obj.xRes.Ax * exp( -0.5 * (x-obj.xRes.x0).^2 / obj.xRes.sigmaX^2 ) + obj.xRes.Cx;
           xFit2 = xFit1-obj.xRes.Ax2 * exp( -0.5 * (x-obj.xRes.x02).^2 / obj.xRes.sigmaX2^2 );
           yFit1 = obj.yRes.Ay * exp( -0.5 * (y-obj.yRes.y0).^2 / obj.yRes.sigmaY^2 ) + obj.yRes.Cy;
           yFit2 = yFit1-obj.yRes.Ay2 * exp( -0.5 * (y-obj.yRes.y02).^2 / obj.yRes.sigmaY2^2 );
           
           xFit = [xFit1; xFit2];
           yFit = [yFit1; yFit2];
       end
       function  plotFitResults(obj, appData)  % plots the text 
%            chipStart = appData.data.camera.chipStart;
           set(appData.ui.stFitResultsAtomNum, 'String',['Atoms Num: ' formatNum(obj.atomsNo, 'num')]);
           set(appData.ui.stFitResultsFitFunction, 'String', ...
               'Fit Function: A_x * {\ite}^{-(x-x_0)^2 / 2\sigma_x^2} - A_{x,2} * {\ite}^{-(x-x_{0,2})^2 / 2\sigma_{x,2}^2} + C_x + f(y)');
           set(appData.ui.stFitResults1, 'String', {...
               ['A_x/A_{x,2} = ' num2str(obj.xRes.Ax) '/' num2str(obj.xRes.Ax2) ], ...
               ['x_0/x_{0,2} = ' formatNum((obj.xRes.x0) * appData.data.camera.xPixSz, 'dis', 1) ...
                    '/' formatNum((obj.xRes.x02) * appData.data.camera.xPixSz, 'dis', 1)], ...
               ['\sigma_x/\sigma_{x,2} = ' formatNum(obj.xRes.sigmaX * appData.data.camera.xPixSz, 'dis', 1) ...
                    '/' formatNum(obj.xRes.sigmaX2 * appData.data.camera.xPixSz, 'dis', 1)], ...
               ['C_x = ' num2str(obj.xRes.Cx)], ...
               ['R^2 = ' num2str(obj.xGof.rsquare)]});
                          
           set(appData.ui.stFitResults2, 'String', {...
               ['A_y/A_{y,2} = ' num2str(obj.yRes.Ay) '/' num2str(obj.yRes.Ay2)], ...
               ['y_0/y_{0,2} = ' formatNum((obj.yRes.y0) * appData.data.camera.yPixSz, 'dis', 1) ...
                    '/' formatNum((obj.yRes.y02) * appData.data.camera.yPixSz, 'dis', 1)], ...
               ['\sigma_y/\sigma_{y,2} = ' formatNum(obj.yRes.sigmaY * appData.data.camera.yPixSz, 'dis', 1) ...
                    '/' formatNum(obj.yRes.sigmaY2 * appData.data.camera.yPixSz, 'dis', 1)], ...
               ['C_y = ' num2str(obj.yRes.Cy)], ...
               ['R^2 = ' num2str(obj.yGof.rsquare)]});
       end
       
   end
end 

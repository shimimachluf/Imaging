classdef Fit21DGaussianOnlyY < FitTypes
%FIT21DGAUSSIANONLYY Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'Fit21DGaussianOnlyY';
   end
   properties (SetAccess = private )
%        xRes = [];
%        xGof = [];
%        xOutput = [];

        A1 = -1;
        y01 = -1;
        sigmaY1 = -1;
        A2 = -1;
        y02 = -1;
        sigmaY2 = -1;

       yRes = [];
       yGof = [];
       yOutput = [];
   end

   methods 
       function appData = analyze(obj, appData) % do the analysis
           [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
           [h w] = size(pic);
           %binning and max
           binnedData = binning ( pic, appData.options.avgWidth*2+1);
           [maxes, indexes] = max(binnedData);                     % find maximum
           [maxValue, xPosMax] = max(maxes);
           yPosMax = indexes(xPosMax);   
%            obj.maxVal = maxValue;% / (appData.options.avgWidth*2)^2; %no need, already done in binning.m
           % center
           xCenter = (appData.options.avgWidth*2+1) * (xPosMax ) + x0-appData.options.avgWidth;
           yCenter = (appData.options.avgWidth*2+1) * (yPosMax ) + y0-appData.options.avgWidth; 
%            obj.xCenter = appData.options.avgWidth*2 * (xPosMax - 0.5) + x0;
%            obj.yCenter = appData.options.avgWidth*2 * (yPosMax - 0.5) + y0; 
%            % unit size
%            obj.xUnitSize = w/2;
%            obj.yUnitSize = h/2;   

            % fitting
            [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
%             x = [1 : w] + x0-1;
            y = [1 : h] + y0-1;            
%             [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', 'gauss1'); 
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', 'gauss2', 'Lower', [0 0 0 0.01 0 0]);  
%             xCenter = round(obj.xRes.b1);
%             yCenter = round(obj.yRes.b1);
            obj.A1 = obj.yRes.a1;
            obj.y01 = obj.yRes.b1;
            obj.sigmaY1 = obj.yRes.c1/sqrt(2);
            obj.A2 = obj.yRes.a2;
            obj.y02 = obj.yRes.b2;
            obj.sigmaY2 = obj.yRes.c2/sqrt(2);
            
            
%             [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
% %             s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.xRes.a1 obj.xRes.b1 obj.xRes.c1/sqrt(2)]);%[1 width/2 width/10]);
% %             f = fittype('Ax*exp(-(x-x0)^2/(2*sigmaX^2))', 'coefficients', {'Ax', 'x0', 'sigmaX'}, 'independent', 'x', 'dependent', 'y', 'options', s);
% %             [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', f); 
%             s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.yRes.a1 obj.yRes.b1 obj.yRes.c1/sqrt(2)]);%[1 width/2 width/10]);
%             f = fittype('Ay*exp(-(y-y0)^2/(2*sigmaY^2))', 'coefficients', {'Ay', 'y0', 'sigmaY'}, 'independent', 'y', 'dependent', 'x', 'options', s);
%             [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', f); 
% %             xCenter = round(obj.xRes.x0);
%             yCenter = round(obj.yRes.y0);
%             
%             [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
% %             s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.xRes.Ax obj.xRes.x0 obj.xRes.sigmaX 0], 'Lower', [0 -Inf 0 -Inf]);
% %             f = fittype('Ax*exp(-(x-x0)^2/(2*sigmaX^2))+Cx', 'coefficients', {'Ax', 'x0', 'sigmaX', 'Cx'}, 'independent', 'x', 'dependent', 'y', 'options', s);
% %             [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', f); 
%             s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [obj.yRes.Ay obj.yRes.y0 obj.yRes.sigmaY 0], 'Lower', [0 -Inf 0 -Inf]);
%             f = fittype('Ay*exp(-(y-y0)^2/(2*sigmaY^2))+Cy', 'coefficients', {'Ay', 'y0', 'sigmaY', 'Cy'}, 'independent', 'y', 'dependent', 'x', 'options', s);
%             [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', f); 
            
            %set fit params
            obj.xCenter = round(xCenter); % should be indexes (integers)
            obj.yCenter= round(mean([obj.y01 obj.y02]));
            obj.xUnitSize = w;
            obj.yUnitSize = obj.sigmaY1;
            obj.maxVal = max([obj.A1 obj.A2]);
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           
           obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
           
           % last 
           appData.data.fits{appData.consts.fitTypes.twoOneDGaussianOnlyY} = obj;
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
       end
       
       function normalizedROI = getNormalizedROI(obj, pic, x, y) % return normalized ROI (to the fitting constant)
%            normalizedROI = pic(y, x) - obj.yRes.Cy;
           normalizedROI = pic(y, x);
       end
       
       function normalizedROI = getTheoreticalROI(obj, pic, x, y) %#ok<INUSL>
%            [X, Y] = meshgrid(x, y);
%            normalizedROI = mean([obj.xRes.Ax obj.yRes.Ay]) * exp( -0.5 * ((X-obj.xRes.x0).^2 / obj.xRes.sigmaX^2 + (Y-obj.yRes.y0).^2 / obj.yRes.sigmaY^2) );
            normalizedROI = pic(y, x);
       end
       
       function normalizedPic = normalizePic(obj, pic)
%            normalizedPic = (pic - obj.yRes.Cy)/obj.maxVal;
           normalizedPic = pic / mean([obj.A1 obj.A2]);% obj.maxVal;
       end
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
           xFit = zeros(size(x));
           yFit = feval(obj.yRes, y)';
%            yFit = obj.A1 * exp( -0.5 * (y-obj.y01).^2 / obj.sigmaY1^2 ) + obj.A2 * exp( -0.5 * (y-obj.y02).^2 / obj.sigmaY2^2 );% + obj.yRes.Cy;
       end
       
       function  plotFitResults(obj, appData)  % plots the text           
%            [pic x0 y0] = appData.data.plots{appData.data.plotType}.getPic();
           chipStart = appData.data.camera.chipStart;
%            text( 10, 190, ['Atoms Num: ' num2str(obj.atomsNo/1e6) '*10^6'], 'fontSize', 20);
%            text( 50, 140, {['x_0 = ' num2str((obj.xCenter-x0+1) * appData.data.camera.xPixSz * 1000) ' mm'], ...
%                ['y_0 = ' num2str((obj.yCenter-y0+1) * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
           text( 10, 190, ['Atoms Num: ' num2str(obj.atomsNo/1e6) '*10^6'], 'fontSize', 20);
           text( 10, 155, 'fit function = A_{y1} * {\ite}^{-(y-y_{01})^2 / 2\sigma_{y1}^2}+A_{y2} * {\ite}^{-(y-y_{02})^2 / 2\sigma_{y2}^2}', 'fontsize', 12);
%            text( 50, 80, {['A_x = ' num2str(obj.xRes.Ax)], ...
%                ['x_0 = ' num2str((obj.xRes.x0) * appData.data.camera.xPixSz * 1000) ' mm'], ...
%                ['\sigma_x = ' num2str(obj.xRes.sigmaX * appData.data.camera.xPixSz * 1000) ' mm'], ...
%                ['C_x = ' num2str(obj.xRes.Cx)], ...
%                ['R^2 = ' num2str(obj.xGof.rsquare)]}, ...
%                'fontsize', 12);
           text( 50, 100, {['A_{y1} = ' num2str(obj.A1)], ...
               ['y_{01} = ' num2str((obj.y01-chipStart) * appData.data.camera.yPixSz * 1000) ' mm'], ...
               ['\sigma_{y1} = ' num2str(obj.sigmaY1 * appData.data.camera.yPixSz * 1000) ' mm']}, ...
               'fontsize', 12);
           text( 220, 100, {['A_{y2} = ' num2str(obj.A2)], ...
               ['y_{02} = ' num2str((obj.y02-chipStart) * appData.data.camera.yPixSz * 1000) ' mm (from the chip)'], ...
               ['\sigma_{y2} = ' num2str(obj.sigmaY2 * appData.data.camera.yPixSz * 1000) ' mm']}, ...
               'fontsize', 12);           
           text( 50, 50, {['\Deltay/2 = ' num2str( abs(obj.y02-obj.y01)/2 * appData.data.camera.yPixSz * 1000) ' mm']}, ...
               'fontsize', 12);
       end
       
   end
end 

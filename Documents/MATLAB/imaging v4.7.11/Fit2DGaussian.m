classdef Fit2DGaussian < FitTypes
%FIT2DGAUSSIAN Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'Fit2DGaussian';
   end
   properties (SetAccess = protected )
       OD = -1;
       x0 = -1;
       y0 = -1;
       sigmaX = -1;
       sigmaY = -1;
       C = -1;
       
       fval = [];
       exitflag = [];
       output = [];
   end

   methods
       function appData = analyze(obj, appData) % do the analysis
           % 1D fit
           fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussian};
           if ( isempty( fitObj.xRes ) )
               tmpFitType = appData.data.fitType;
               appData.data.fitType = appData.consts.fitTypes.oneDGaussian;
               appData = appData.data.fits{appData.consts.fitTypes.oneDGaussian}.analyze(appData);
               fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussian};
               appData.data.fitType = tmpFitType;
           end
           
%            [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);  % the whole pic
           [pic x0 y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
           [h w] = size(pic);
           
           % 2D fit
           firstGuess = [0.5*(fitObj.xRes.Ax+fitObj.yRes.Ay) fitObj.xRes.x0 fitObj.yRes.y0 ...
               fitObj.xRes.sigmaX fitObj.yRes.sigmaY 0.5*(fitObj.xRes.Cx+fitObj.yRes.Cy)]; 
            binW = appData.options.avgWidth;
            if ( numel(pic) > 350^2 )
                binnedPic = binning(pic, binW);
                [h w] = size(binnedPic);
                [X, Y] = meshgrid([1 : binW : binW*w] +x0-1, [1 : binW : binW*h] +y0-1);% - appData.data.camera.chipStart);
%                 X = X(1:h, 1:w);
%                 Y = Y(1:h, 1:w);
                [fitRes, obj.fval, obj.exitflag, obj.output] = ...
                    fminsearch(@(p) fitGauss2D_scalar( p, X, Y, binnedPic), firstGuess, optimset('TolX',1e-4) );
            else
                [X, Y] = meshgrid([1  : w] +x0-1, [1  : h] +y0-1);
                [fitRes, obj.fval, obj.exitflag, obj.output] = ...
                    fminsearch(@(p) fitGauss2D_scalar( p, X, Y, pic), firstGuess, optimset('TolX',1e-4) );
            end
            
            % set 2D params
            obj.OD = fitRes(1);
            obj.x0 = fitRes(2);
            obj.y0 = fitRes(3);
            obj.sigmaX = fitRes(4);
            obj.sigmaY = fitRes(5);
            obj.C = fitRes(6);
            
            %set fit params
            obj.xCenter = round(obj.x0); % should be indexes (integers)
            obj.yCenter= round(obj.y0);
            obj.xUnitSize = obj.sigmaX;
            obj.yUnitSize = obj.sigmaY;
            obj.maxVal = obj.OD;
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
           [pic x0 y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData);
%            [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
           
            obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
%            obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
%                [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
           
            [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors(obj.xCenter, obj.yCenter, binW);

            obj.xData = xData;
            obj.xStart = x0;
            obj.yData = yData;
            obj.yStart = y0;

            % last
            appData.data.fits{appData.consts.fitTypes.twoDGaussian} = obj;
%            appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
       end
       
       function normalizedROI = getNormalizedROI(obj, pic, x, y) % return normalized ROI (to the fitting constant)
           normalizedROI = pic(y, x) - obj.C;
       end
       
       function normalizedROI = getTheoreticalROI(obj, pic, x, y)
           [X, Y] = meshgrid(x, y);
           normalizedROI = obj.OD * exp( -0.5 * ((X-obj.x0).^2 / obj.sigmaX^2 + (Y-obj.y0).^2 / obj.sigmaY^2) );
       end
       
       function normalizedPic = normalizePic(obj, pic)
           normalizedPic = (pic-obj.C)/obj.maxVal;
       end
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
           xFit = obj.OD * exp( -0.5 * (x-obj.x0).^2 / obj.sigmaX^2 ) + obj.C;
           yFit = obj.OD * exp( -0.5 * (y-obj.y0).^2 / obj.sigmaY^2 ) + obj.C;
       end
       
       function  plotFitResults(obj, appData)  % plots the text
           chipStart = appData.data.camera.chipStart;
           
%            text( 10, 190, ['Atoms Num: ' num2str(obj.atomsNo/1e6) '*10^6'], 'fontSize', 20);
%            text( 10, 160, 'fit function = A * {\ite}^{-(x-x_0)^2 / 2\sigma_x^2 - (y-y_0)^2 / 2\sigma_y^2} + C', 'fontsize', 12);
%            text( 50, 135, ['A = ' num2str(obj.OD)], 'fontsize', 12); 
%            text( 50, 100, {['x_0 = ' num2str(obj.x0 * appData.data.camera.xPixSz * 1000) ' mm'], ...
%                ['\sigma_x = ' num2str(obj.sigmaX * appData.data.camera.xPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
%            text( 200, 100, {['y_0 = ' num2str((obj.y0-chipStart) * appData.data.camera.yPixSz * 1000) ' mm (from the chip)'], ...                
%                ['\sigma_y = ' num2str(obj.sigmaY * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
%            text( 50, 65, ['C = ' num2str(obj.C)], 'fontsize', 12);
           set(appData.ui.stFitResultsAtomNum, 'String',['Atoms Num: ' formatNum(obj.atomsNo, 'num')]);
           set(appData.ui.stFitResultsFitFunction, 'String', 'Fit Function: A * {\ite}^{-(x-x_0)^2 / 2\sigma_x^2 - (y-y_0)^2 / 2\sigma_y^2} + C');
           set(appData.ui.stFitResults1, 'String', {['OD = ' num2str(obj.maxVal) ], ...
               ['x_0 = ' formatNum((obj.x0) * appData.data.camera.xPixSz, 'dis')], ...
               ['\sigma_x = ' formatNum(obj.sigmaX * appData.data.camera.xPixSz, 'dis')], ...
               ['C = ' num2str(obj.C)]});
           set(appData.ui.stFitResults2, 'String', {'', ...
               ['y_0 = ' formatNum((obj.y0) * appData.data.camera.yPixSz, 'dis')], ...
               ['\sigma_y = ' formatNum(obj.sigmaY * appData.data.camera.yPixSz, 'dis')], ...
               ''});
               
       end
   end
end 
      
function ret = fitGauss2D_matrix( p, X, Y, g ) %#ok<DEFNU>
% amp = p(1);
% cx = p(2);
% cy = p(3);
% wx = p(4);
% wy = p(5);
% C = p(6)
ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) + p(6) - g;
end
    
function ret = fitGauss2D_scalar( p, X, Y, g )
% amp = p(1);
% cx = p(2);
% cy = p(3);
% wx = p(4);
% wy = p(5);
% C = p(6)
ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) + p(6) - g;
ret = sum(sum(ret.^2));
end
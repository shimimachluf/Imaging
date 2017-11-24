classdef Fit2DGaussianHoleMouse < FitTypes
%FIT2DGAUSSIANHOLEMouse Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'Fit2DGaussianHoleMouse';
   end
   properties (SetAccess = private )
       OD = -1;
       x0 = -1;
       y0 = -1;
       sigmaX = -1;
       sigmaY = -1;
       C = -1;
       OD2 = -1;
       x02 = -1;
       y02 = -1;
       sigmaX2 = -1;
       sigmaY2 = -1;
       
       atomsNo2 = -1;
       
       fval = [];
       exitflag = [];
       output = [];
   end

   methods
       function appData = analyze(obj, appData) % do the analysis
           % 1D fit
           fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussianHoleMouse};
           if ( isempty( fitObj.xRes ) )
               tmpFitType = appData.data.fitType;
               appData.data.fitType = appData.consts.fitTypes.oneDGaussianHoleMouse;
               appData = appData.data.fits{appData.consts.fitTypes.oneDGaussianHoleMouse}.analyze(appData);
               fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussianHoleMouse};
               appData.data.fitType = tmpFitType;
           end
           
           [pic x0 y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
           [h w] = size(pic);
           
           % 2D fit
           firstGuess = [0.5*(fitObj.xRes.Ax+fitObj.yRes.Ay) fitObj.xRes.x0 fitObj.yRes.y0 ...
               fitObj.xRes.sigmaX fitObj.yRes.sigmaY 0.5*(fitObj.xRes.Cx+fitObj.yRes.Cy) ...
               0.5*(fitObj.xRes.Ax2+fitObj.yRes.Ay2) fitObj.xRes.x02 fitObj.yRes.y02 ...
               fitObj.xRes.sigmaX2 fitObj.yRes.sigmaY2]; 
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
            obj.OD2 = fitRes(7);
            obj.x02 = fitRes(8);
            obj.y02 = fitRes(9);
            obj.sigmaX2 = fitRes(10);
            obj.sigmaY2 = fitRes(11);
            
            %set fit params
            obj.xCenter = fitObj.xCenter; %round(obj.x0); % should be indexes (integers)
            obj.yCenter= fitObj.yCenter; %round(obj.y0);
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
           [h w] = size(pic);
           [X, Y] = meshgrid([1:w] +x0-1, [1:h] +y0-1);
           normalizedROI = obj.OD2 * exp( -0.5 * ((X-obj.x02).^2 / obj.sigmaX2^2 + (Y-obj.y02).^2 / obj.sigmaY2^2) );
           scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2); 
           obj.atomsNo2 = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * sum(sum(normalizedROI)) / scatcross);
           
           
           [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors(obj.xCenter, obj.yCenter, binW);

            obj.xData = xData;
            obj.xStart = x0;
            obj.yData = yData;
            obj.yStart = y0;

            % last
            appData.data.fits{appData.consts.fitTypes.twoDGaussianHoleMouse} = obj;
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
           xFit1 = obj.OD * exp( -0.5 * (x-obj.x0).^2 / obj.sigmaX^2 ) + obj.C;
           xFit2 = xFit1-obj.OD2 * exp( -0.5 * (x-obj.x02).^2 / obj.sigmaX2^2 );
           yFit1 = obj.OD * exp( -0.5 * (y-obj.y0).^2 / obj.sigmaY^2 ) + obj.C;
           yFit2 = yFit1-obj.OD2 * exp( -0.5 * (y-obj.y02).^2 / obj.sigmaY2^2 );
%            xFit1 = obj.xRes.Ax * exp( -0.5 * (x-obj.xRes.x0).^2 / obj.xRes.sigmaX^2 ) + obj.xRes.Cx;
%            xFit2 = xFit1-obj.xRes.Ax2 * exp( -0.5 * (x-obj.xRes.x02).^2 / obj.xRes.sigmaX2^2 );
%            yFit1 = obj.yRes.Ay * exp( -0.5 * (y-obj.yRes.y0).^2 / obj.yRes.sigmaY^2 ) + obj.yRes.Cy;
%            yFit2 = yFit1-obj.yRes.Ay2 * exp( -0.5 * (y-obj.yRes.y02).^2 / obj.yRes.sigmaY2^2 );
           
           xFit = [xFit1; xFit2];
           yFit = [yFit1; yFit2];
       end
       
       function  plotFitResults(obj, appData)  % plots the text
           chipStart = appData.data.camera.chipStart;
           
           set(appData.ui.stFitResultsAtomNum, 'String',['Atoms Num: ' formatNum(obj.atomsNo, 'num') ...
               ' (' formatNum(obj.atomsNo2, 'num') ')']);
           set(appData.ui.stFitResultsFitFunction, 'String', ...
               ['Fit Function: A * {\ite}^{-(x-x_0)^2 / 2\sigma_x^2 - (y-y_0)^2 / 2\sigma_y^2} - {\itf}(hole) + C']);
           set(appData.ui.stFitResults1, 'String', {...
               ['OD/OD_2 = ' num2str(obj.OD) '/' num2str(obj.OD2) ], ...
               ['x_0, x_{0,2} = ' formatNum((obj.x0) * appData.data.camera.xPixSz, 'dis', 1)...
                    '/' formatNum((obj.x02) * appData.data.camera.xPixSz, 'dis', 1)], ...
               ['\sigma_x/\sigma_{x,2} = ' formatNum(obj.sigmaX * appData.data.camera.xPixSz, 'dis', 1) ...
                    '/' formatNum(obj.sigmaX2 * appData.data.camera.xPixSz, 'dis', 1)], ...
               ['C = ' num2str(obj.C)]});
           set(appData.ui.stFitResults2, 'String', {'', ...
               ['y_0/y_{0,2} = ' formatNum((obj.y0) * appData.data.camera.yPixSz, 'dis', 1) ...
                    '/' formatNum((obj.y02) * appData.data.camera.yPixSz, 'dis', 1)], ...
               ['\sigma_y\sigma_{y,2} = ' formatNum(obj.sigmaY * appData.data.camera.yPixSz, 'dis', 1) ...
                    '/' formatNum(obj.sigmaY2 * appData.data.camera.yPixSz, 'dis', 1)], ...
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
% amp = p(7);
% cx = p(8);
% cy = p(9);
% wx = p(10);
% wy = p(11);
ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) ...
    - p(7)*( exp( -0.5 * (X - p(8)).^2./p(10).^2 - 0.5 * (Y - p(9)).^2./p(11).^2 ) ) ...
    + p(6) - g;
end
    
function ret = fitGauss2D_scalar( p, X, Y, g )
% amp = p(1);
% cx = p(2);
% cy = p(3);
% wx = p(4);
% wy = p(5);
% C = p(6)
% amp = p(7);
% cx = p(8);
% cy = p(9);
% wx = p(10);
% wy = p(11);
% ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) + p(6) - g;
ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) ...
    - p(7)*( exp( -0.5 * (X - p(8)).^2./p(10).^2 - 0.5 * (Y - p(9)).^2./p(11).^2 ) ) ...
    + p(6) - g;
ret = sum(sum(ret.^2));
end
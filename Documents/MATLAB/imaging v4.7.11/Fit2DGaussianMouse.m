classdef Fit2DGaussianMouse < Fit2DGaussian
%FIT2DGAUSSIANHOLEMouse Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID_1 = 'Fit2DGaussianMouse';
   end
   
   methods
       function appData = analyze(obj, appData) % do the analysis
           % 1D fit
           fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussianMouse};
           if ( isempty( fitObj.xRes ) )
               tmpFitType = appData.data.fitType;
               appData.data.fitType = appData.consts.fitTypes.oneDGaussianMouse;
               appData = appData.data.fits{appData.consts.fitTypes.oneDGaussianMouse}.analyze(appData);
               fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussianMouse};
               appData.data.fitType = tmpFitType;
           end
           
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
            obj.xCenter = fitObj.xCenter; %round(obj.x0); % should be indexes (integers)
            obj.yCenter = fitObj.yCenter; %round(obj.y0);
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
            appData.data.fits{appData.consts.fitTypes.twoDGaussianMouse} = obj;
%            appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
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
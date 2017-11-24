classdef FitSites < FitTypes
%FITSITES Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'FitSites';
   end
%    properties (Constant = true)
%       xStepR = 10;
%       yStepR = 4;
%       xStepD = -4;
%       yStepD = 10;
%    end
   properties (SetAccess = protected )
       OD = -1;
       x0 = -1;
       y0 = -1;
       sigmaX = -1;
       sigmaY = -1;
       C = -1;
       
%        fval = [];
%        exitflag = [];
%        output = [];
%        totFitRes = [];
       Nsites = [];
       
%        %load params
%        coords = []; %[x0 y0 w h
%        R = [];
%        Binv = [];
   end

   methods
       function appData = analyze(obj, appData) % do the analysis
           
           % get fite Sites Data
           fitObj = appData.data.fits{appData.consts.fitTypes.createSites};
           [coords, R, Binv] = fitObj.fitResParams();
           if ( isempty( Binv ) )
               errordlg('No Fit Sites data.', 'error', 'modal');
               return
           end

%            coords = fitObj.coords;
%            R = fitObj.R;
%            Binv = fitObj.Binv;

           [pic, x0, y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
           [h, w] = size(pic);
           if sum(coords == [x0 y0 w h]) ~= 4
               errordlg('ROI not as Fit Sites data.', 'error', 'modal');
               return
           end
           x0 = x0-1;
           y0 = y0-1;
           
%             R = double(reshape(cat(3,g{:}), w*h, size(fitResArr, 1)));
            A = double(reshape(pic(:),w*h, 1));
%             Binv = pinv(R'*R)*R';
            c = Binv*A;
%             obj.Nsites = c.*cellfun(@(x) sum(x(:)), g)'; % in OD units
            scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2);
            obj.Nsites = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * ...
                 c.*sum(R,1)' / scatcross); %sum(sum(normalizedROI)) / scatcross);
%              obj.Nsites
            
            % calc ROI size (use ROIUnits.m) - MUST be after fit
            [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
            appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
            [pic x0 y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData);
%            [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
           
            obj.atomsNo = sum(obj.Nsites);
%             obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
%                [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
           
            [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors(obj.xCenter, obj.yCenter, 0);

            obj.xData = xData;
            obj.xStart = x0;
            obj.yData = yData;
            obj.yStart = y0;

            % last
            appData.data.fits{appData.consts.fitTypes.sites} = obj;
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
           set(appData.ui.stFitResultsFitFunction, 'String', 'Fit Function: \Sigma A * {\ite}^{-(x-x_0)^2 / 2\sigma_x^2 - (y-y_0)^2 / 2\sigma_y^2}');
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

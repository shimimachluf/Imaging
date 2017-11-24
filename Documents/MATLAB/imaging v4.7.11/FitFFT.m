classdef FitFFT < FitTypes
%FITONLYMAX Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'FitFFT';
   end
   properties ( SetAccess = private)
       baseFit;
       k;
       xData_k;
   end

   methods 
       function appData = analyze(obj, appData) % do the analysis
            baseFitType = appData.consts.fitTypes.oneDBiModal;
            obj.baseFit = appData.data.fits{baseFitType};
            if ( isempty( obj.baseFit.xRes ) )
                tmpFitType = appData.data.fitType;
                appData.data.fitType = baseFitType;
                appData = appData.data.fits{baseFitType}.analyze(appData);
                obj.baseFit = appData.data.fits{baseFitType};
                appData.data.fitType = tmpFitType;
            end
            
            obj.atomsNo = obj.baseFit.atomsNo;
            obj.maxVal = obj.baseFit.maxVal;

            % the values are relative to the top/left corner of the image (no
            % chip start or ROI)
            obj.ROILeft = obj.baseFit.ROILeft;
            obj.ROIRight = obj.baseFit.ROIRight;
            obj.ROITop = obj.baseFit.ROITop;
            obj.ROIBottom = obj.baseFit.ROIBottom;

            obj.xCenter = obj.baseFit.xCenter; % should be indexes (integers)
            obj.yCenter= obj.baseFit.yCenter;

            obj.xUnitSize = obj.baseFit.xUnitSize;
            obj.yUnitSize = obj.baseFit.yUnitSize;
            
             % last
           % set ROI pic - MUST be after defining ROI
           if ( appData.consts.fitTypes.SG == appData.consts.fitTypes.FFT )
               appData.consts.fitTypes.FFT = appData.consts.fitTypes.SG+1;
           end
           appData.data.fits{appData.consts.fitTypes.FFT} = obj;
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, []);
%            
           
%            [obj.xData yData] = ...
%                         appData.data.plots{appData.consts.plotTypes.absorption }.getXYDataVectors( ...
%                         appData.data.fits{ baseFitType }.xCenter, appData.data.fits{ baseFitType }.yCenter, ...
%                         appData.options.avgWidth);
                    
             [obj.xData yData] =appData.data.plots{appData.data.plotType}.getXYDataVectors( ...
                 obj.baseFit.xCenter, obj.baseFit.yCenter, appData.options.avgWidth);
                    
            [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
            [h w] = size(pic);
            x = [1 : w];
            y = [1 : h];
            [xFit yFit] = obj.baseFit.getXYFitVectors(x+x0-1, y+y0-1);
            data = obj.xData - xFit(1, :);
            dx = appData.consts.cameras{appData.options.cameraType}.xPixSz;
            x = dx*[-w/2:w/2-1]; %dx*[-Nx/2:Nx/2-1];
            dk = 2*pi/dx/w; %2*pi/dx/Nx;
            obj.k = dk*[-w/2:w/2-1]; %dk*[-Nx/2:Nx/2-1];
            obj.xData_k = fftshift(fft(fftshift(data)));
            
%             len = length(k);
%             figure; 
%              plot(k(round(len/2):len), abs(obj.xData_k(round(len/2):len)));
             
           % last
           % set ROI pic - MUST be after defining ROI
           appData.data.fits{appData.consts.fitTypes.FFT} = obj;
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
%            
%            % last 
%            appData.data.fits{appData.consts.fitTypes.onlyMaximum} = obj;
       end
       
       function normalizedROI = getNormalizedROI(obj, pic, x, y) % return normalized ROI (to the fitting constant)
           normalizedROI = obj.baseFit.getNormalizedROI(pic, x, y);
       end
       
       function normalizedROI = getTheoreticalROI(obj, pic, x, y)
           normalizedROI = obj.baseFit.getTheoreticalROI(pic, x, y);
       end
       
       function normalizedPic = normalizePic(obj, pic)
           normalizedPic = obj.baseFit.normalizePic(pic);
       end
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
            [xFit yFit] = obj.baseFit.getXYFitVectors(x, y);
       end
       
       function  plotFitResults(obj, appData)  % plots the text
           obj.baseFit.plotFitResults(appData);
       end
       
   end
end 

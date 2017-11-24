classdef Fit4Gaussian < FitTypes
%FIT4GAUSSIANSummary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'Fit4Gaussian';
   end
   properties (SetAccess = private )
 
       Nsites = [];
       indMax = [];
       indMin = [];
       C = -1;
       
       yRes = [];
       yGof = [];
       yOutput = [];
   end
   
   methods
       function appData = analyze(obj, appData) % do the analysis
           plotResults = 1;
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

            % fitting
            [xData yData] = appData.data.plots{appData.data.plotType}.getAnalysisXYDataVectors(appData, xCenter, yCenter, appData.options.avgWidth);
%             x = [1 : w] + x0-1;
            y = [1 : h] + y0-1;            
            
%             [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', 'gauss2');
%             dif = max([obj.yRes.b1 obj.yRes.b2]) - min([obj.yRes.b1 obj.yRes.b2]);
%             if dif > 100
%                firstGuess = [...
%                    obj.yRes.a1 obj.yRes.b1 obj.yRes.c1 ...
%                    obj.yRes.a2 obj.yRes.b2 obj.yRes.c2 ...
%                    obj.yRes.a2 max([obj.yRes.b1 obj.yRes.b2])-dif/4 obj.yRes.c2 ...
%                    obj.yRes.a2 min([obj.yRes.b1 obj.yRes.b2])+dif/4 obj.yRes.c2];
%             else
%                 firstGuess = [...
%                    obj.yRes.a1 obj.yRes.b1 obj.yRes.c1 ...
%                    obj.yRes.a2 obj.yRes.b2 obj.yRes.c2 ...
%                    obj.yRes.a2 max([obj.yRes.b1 obj.yRes.b2])+dif obj.yRes.c2 ...
%                    obj.yRes.a2 min([obj.yRes.b1 obj.yRes.b2])-dif obj.yRes.c2];
%             end
%             
% %             [obj.xRes, obj.xGof, obj.xOutput] = fit(x', xData', 'gauss1'); 
%             [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', 'gauss4', ...
%                 'Lower', [0.02 0 5 0.02 0 5 0.02 0 5 0.02 0 5], ...
%                 'upper', [1 Inf 25 1 Inf 25 1 Inf 25 1 Inf 25], ...
%                 'StartPoint', firstGuess);  %[0.5 1280 11.5 0.4 1344 22 0.05 1225 15 0.08 1450 21]
            
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', 'gauss4', ...
                'Lower', [0.02 0 5 0.02 0 5 0.02 0 5 0.02 0 5], ...
                'upper', [1 Inf 25 1 Inf 25 1 Inf 25 1 Inf 25], ...
                'StartPoint', [0.5 1280 11.5 0.4 1344 22 0.05 1225 15 0.08 1450 21]);
            
            data = diff(feval(obj.yRes, y));
            obj.indMax = find(diff(sign(data))<0);
            obj.indMin = find(diff(sign(data))>0);
            obj.C = mean(mean(pic([1:obj.indMax(1)-(obj.indMin(1)-obj.indMax(1)) ...
                obj.indMax(4)+(obj.indMax(4)-obj.indMin(3)):end], :)));
            obj.Nsites(1) = sum(sum(-obj.C+pic(obj.indMax(1)-(obj.indMin(1)-obj.indMax(1)):obj.indMin(1),:)));
            obj.Nsites(2) = sum(sum(-obj.C+pic(obj.indMin(1):obj.indMin(2), :)));
            obj.Nsites(3) = sum(sum(-obj.C+pic(obj.indMin(2):obj.indMin(3), :)));
            obj.Nsites(4) = sum(sum(-obj.C+pic(obj.indMin(3) : obj.indMax(4)+(obj.indMax(4)-obj.indMin(3)),:)));
            
%             obj.indMax = obj.indMax + y0;
%             obj.indMin = obj.indMin + y0;
            
            %set fit params
            obj.xCenter = round(xCenter); % should be indexes (integers)
            obj.yCenter= round(obj.yRes.b1);
            obj.xUnitSize = obj.yRes.c1/sqrt(2);
            obj.yUnitSize = obj.yRes.c1/sqrt(2);
            obj.maxVal = max(obj.yRes.a1);
            scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2); 
            obj.Nsites = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * obj.Nsites / scatcross);   
%             [sum(obj.Nsites) obj.Nsites]
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           
           obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
           
           % last 
           appData.data.fits{appData.consts.fitTypes.fourGaussians} = obj;
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
           normalizedPic = pic / obj.maxVal;
       end
       
       function [xFit, yFit] = getXYFitVectors(obj, x, y)
           xFit = zeros(size(x));
           yFit = feval(obj.yRes, y)';
       end
       
       function  plotFitResults(obj, appData)  % plots the text           
           [pic x0 y0] = appData.data.plots{appData.data.plotType}.getPic();
           chipStart = appData.data.camera.chipStart;
%            text( 10, 190, ['Atoms Num: ' num2str(obj.atomsNo/1e6) '*10^6'], 'fontSize', 20);
%            text( 50, 140, {['x_0 = ' num2str((obj.xCenter-x0+1) * appData.data.camera.xPixSz * 1000) ' mm'], ...
%                ['y_0 = ' num2str((obj.yCenter-y0+1) * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
%            text( 10, 190, ['Atoms Num: ' num2str(obj.atomsNo/1e6) '*10^6'], 'fontSize', 20);
%            text( 10, 155, 'fit function = A_{y1} * {\ite}^{-(y-y_{01})^2 / 2\sigma_{y1}^2}+A_{y2} * {\ite}^{-(y-y_{02})^2 / 2\sigma_{y2}^2}', 'fontsize', 12);
% %            text( 50, 80, {['A_x = ' num2str(obj.xRes.Ax)], ...
% %                ['x_0 = ' num2str((obj.xRes.x0) * appData.data.camera.xPixSz * 1000) ' mm'], ...
% %                ['\sigma_x = ' num2str(obj.xRes.sigmaX * appData.data.camera.xPixSz * 1000) ' mm'], ...
% %                ['C_x = ' num2str(obj.xRes.Cx)], ...
% %                ['R^2 = ' num2str(obj.xGof.rsquare)]}, ...
% %                'fontsize', 12);
%            text( 50, 100, {['A_{y1} = ' num2str(obj.A1)], ...
%                ['y_{01} = ' num2str((obj.y01-chipStart) * appData.data.camera.yPixSz * 1000) ' mm'], ...
%                ['\sigma_{y1} = ' num2str(obj.sigmaY1 * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
%            text( 220, 100, {['A_{y2} = ' num2str(obj.A2)], ...
%                ['y_{02} = ' num2str((obj.y02-chipStart) * appData.data.camera.yPixSz * 1000) ' mm (from the chip)'], ...
%                ['\sigma_{y2} = ' num2str(obj.sigmaY2 * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);           
%            text( 50, 50, {['\Deltay/2 = ' num2str( abs(obj.y02-obj.y01)/2 * appData.data.camera.yPixSz * 1000) ' mm']}, ...
%                'fontsize', 12);
        set(appData.ui.stFitResultsAtomNum, 'String',['Atoms Num: ' formatNum(obj.atomsNo, 'num')]);
        set(appData.ui.stFitResults1, 'String', {...
            ['N_1 = ' formatNum(obj.Nsites(1), 'num') ], ...
            ['N_2 = ' formatNum(obj.Nsites(2), 'num')], ...
            ['N_3 = ' formatNum(obj.Nsites(3), 'num')], ...
            ['N_4 = ' formatNum(obj.Nsites(4), 'num')], ...
            ['N_{tot} = ' formatNum(sum(obj.Nsites), 'num')]});
        set(appData.ui.stFitResults2, 'String', { ...
            ['y_{01} = ' formatNum((obj.indMax(1)+y0-chipStart) * appData.data.camera.yPixSz, 'dis') ], ...
            ['y_{02} = ' formatNum((obj.indMax(2)+y0-chipStart) * appData.data.camera.yPixSz, 'dis')], ...
            ['y_{03} = ' formatNum((obj.indMax(3)+y0-chipStart) * appData.data.camera.yPixSz, 'dis')], ...
            ['y_{04} = ' formatNum((obj.indMax(4)+y0-chipStart) * appData.data.camera.yPixSz, 'dis')], ...
            ['']});
       end
       
   end
end 

function ret = fitGauss2D_scalar( p, X, Y, g )
% amp 1-4 = p(1:4);
% cy 1-4 = p(5:8);
% wy 1-4 = p(9:12);
% cx = p(13);
% wx = p(14);
% C = p(15)
ret = ...
    p(1)*( exp( -0.5 * (X - p(13)).^2./p(14).^2 - 0.5 * (Y - p(5)).^2./p(9).^2 ) ) + ...
    p(2)*( exp( -0.5 * (X - p(13)).^2./p(14).^2 - 0.5 * (Y - p(6)).^2./p(10).^2 ) ) + ...
    p(3)*( exp( -0.5 * (X - p(13)).^2./p(14).^2 - 0.5 * (Y - p(7)).^2./p(11).^2 ) ) + ...
    p(4)*( exp( -0.5 * (X - p(13)).^2./p(14).^2 - 0.5 * (Y - p(8)).^2./p(12).^2 ) ) + ...
    p(15) - g;
ret = sum(sum(ret.^2));
end

function ret = fitTF2D_scalar( p, X, Y, g )

%ampTF 1-4 = p(1:4);
%cy 1-4 = p(5:8);
%wTFy 1-4 = p(9:12);
%cx = p(13);
%wTFx = p(14);
% C = p(15)
ret = ...
    p(1)* max( 1 - ( (X-p(13))./(1*p(14)) ).^2 - ( (Y-p(5))./(1*p(9)) ).^2 , 0).^(3/2) + ...
    p(2)* max( 1 - ( (X-p(13))./(1*p(14)) ).^2 - ( (Y-p(6))./(1*p(10)) ).^2 , 0).^(3/2) + ...
    p(3)* max( 1 - ( (X-p(13))./(1*p(14)) ).^2 - ( (Y-p(7))./(1*p(11)) ).^2 , 0).^(3/2) + ...
    p(4)* max( 1 - ( (X-p(13))./(1*p(14)) ).^2 - ( (Y-p(8))./(1*p(12)) ).^2 , 0).^(3/2) + ...
    p(15) - g;
ret = sum(sum(ret.^2));

% %ampTF = p(1);
end

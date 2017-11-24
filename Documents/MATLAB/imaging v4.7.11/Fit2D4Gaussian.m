classdef Fit2D4Gaussian < FitTypes
%FIT2D4GAUSSIAN Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'Fit2D4Gaussian';
   end
   properties (SetAccess = private )
 
       A = -1*ones(1,4);
       x0 = -1*ones(1,4);
       y0 = -1*ones(1,4);
       sigmaX = -1*ones(1,4);
       sigmaY = -1*ones(1,4);
       C = -1;
       
       Nclouds = [];
       yRes = [];
       yGof = [];
       yOutput = [];
       fval = [];
       exitflag = [];
       output = [];
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
            [obj.yRes, obj.yGof, obj.yOutput] = fit(y', yData', 'gauss4', ...
                'Lower', [0.05 0 5 0.05 0 5 0.05 0 5 0.05 0 5], ...
                'upper', [1 Inf 25 1 Inf 25 1 Inf 25 1 Inf 25], ...
                'StartPoint', [0.5 1280 11.5 0.4 1344 22 0.05 1225 15 0.08 1450 21]);  
%             xCenter = round(obj.xRes.b1);
%             yCenter = round(obj.yRes.b1);
%             obj.A1 = obj.yRes.a1;
%             obj.y01 = obj.yRes.b1;
%             obj.sigmaY1 = obj.yRes.c1/sqrt(2);
%             obj.A2 = obj.yRes.a2;
%             obj.y02 = obj.yRes.b2;
%             obj.sigmaY2 = obj.yRes.c2/sqrt(2);
%             obj.yRes
            
            % 2D fit
%             firstGuess = [ ...
%                 obj.yRes.a1 xCenter obj.yRes.b1 obj.yRes.c1/sqrt(2) obj.yRes.c1/sqrt(2) ...
%                 obj.yRes.a2 xCenter obj.yRes.b2 obj.yRes.c2/sqrt(2) obj.yRes.c2/sqrt(2) ...
%                 obj.yRes.a3 xCenter obj.yRes.b3 obj.yRes.c3/sqrt(2) obj.yRes.c3/sqrt(2) ...
%                 obj.yRes.a4 xCenter obj.yRes.b4 obj.yRes.c4/sqrt(2) obj.yRes.c4/sqrt(2) ...
%                 0];
            firstGuess = [ ...
                obj.yRes.a1 obj.yRes.a2 obj.yRes.a3 obj.yRes.a4 ...
                obj.yRes.b1 obj.yRes.b2 obj.yRes.b3 obj.yRes.b4 ...
                obj.yRes.c1/sqrt(2) obj.yRes.c2/sqrt(2) obj.yRes.c3/sqrt(2) obj.yRes.c4/sqrt(2) ...
                xCenter obj.yRes.c1/sqrt(2) 0];
%             firstGuess = [ ...
%                 obj.yRes.a1 obj.yRes.a2 obj.yRes.a3 obj.yRes.a4 ...
%                 obj.yRes.b1 obj.yRes.b2 obj.yRes.b3 obj.yRes.b4 ...
%                 obj.yRes.c1/sqrt(2) obj.yRes.c2/sqrt(2) obj.yRes.c3/sqrt(2) obj.yRes.c4/sqrt(2) ...
%                 obj.yRes.c1/sqrt(2) obj.yRes.c1/sqrt(2) obj.yRes.c1/sqrt(2) obj.yRes.c1/sqrt(2) ...
%                 xCenter 0];
%             firstGuess = [ ... %for TF
%                 obj.yRes.a1 obj.yRes.a2 obj.yRes.a3 obj.yRes.a4 ...
%                 obj.yRes.b1 obj.yRes.b2 obj.yRes.b3 obj.yRes.b4 ...
%                 obj.yRes.c1/sqrt(2)*2.5 obj.yRes.c2/sqrt(2)*2.5 obj.yRes.c3/sqrt(2)*2.5 obj.yRes.c4/sqrt(2)*2.5 ...
%                 xCenter obj.yRes.c1/sqrt(2)*2.5 0];
            if plotResults
                ['starting... Pic no: ' num2str(appData.analyze.showPicNo)]
                [X, Y] = meshgrid([1  : w] +x0-1, [1  : h] +y0-1);
                ret1D = fitGauss2D_scalar( firstGuess, X, Y, pic )
                %             reshape(firstGuess(1:end-1), [5 4])'
                reshape([firstGuess 0], [4 4])'
                
                
                tic
            end
            % binning
            binW = appData.options.avgWidth;
            binnedPic = binning(pic, binW);
            [hB wB] = size(binnedPic);
            [X, Y] = meshgrid([1 : binW : binW*wB] +x0-1, [1 : binW : binW*hB] +y0-1);% - appData.data.camera.chipStart);
            [fitRes, obj.fval, obj.exitflag, obj.output] = ...
               fminsearch(@(p) fitGauss2D_scalar( p, X, Y, binnedPic), firstGuess, ...
               optimset('TolX',1e-6, 'MaxFunEvals', 1e5, 'MaxIter', 1e5));
            
           if plotResults
               toc
               [X, Y] = meshgrid([1  : w] +x0-1, [1  : h] +y0-1);
               retFR1 = fitGauss2D_scalar( fitRes, X, Y, pic )
               %            reshape(fitRes(1:end-1), [5 4])'
               reshape([fitRes 0], [4 4])'
               
               % no binning
%                tic
           end
%             fitRes = firstGuess;

%             [X, Y] = meshgrid([1  : w] +x0-1, [1  : h] +y0-1);
%             [fitRes, obj.fval, obj.exitflag, obj.output] = ...
%                fminsearch(@(p) fitGauss2D_scalar( p, X, Y, pic), firstGuess, ... %firstGuess, ...
%                optimset('TolX',1e-6, 'MaxFunEvals', 1e5, 'MaxIter', 1e5));
%            if plotResults
%                toc
%                retFR2 = fitGauss2D_scalar( fitRes, X, Y, pic )
%                %            reshape(fitRes(1:end-1), [5 4])'
%                reshape([fitRes 0], [4 4])'
%            end

           fitRes = firstGuess;
            [X, Y] = meshgrid([1  : w] +x0-1, [1  : h] +y0-1);
            obj.C = fitRes(end);
            for i =1 : length(obj.A)
                obj.A(i) = fitRes(i);
                obj.x0(i) = fitRes(13);
                obj.y0(i) = fitRes(i+4);
                obj.sigmaX(i) = fitRes(14);
                obj.sigmaY(i) = fitRes(i+8);
                
                obj.Nclouds(i) = sum(sum(obj.A(i) * ...
                    exp( -0.5 * (X-obj.x0(i)).^2 / obj.sigmaX(i)^2 - 0.5 * (Y-obj.y0(i)).^2 / obj.sigmaY(i)^2) ...
                    + obj.C));
%                 obj.A(i) = fitRes((i-1)*5+1);
%                 obj.x0(i) = fitRes((i-1)*5+2);
%                 obj.y0(i) = fitRes((i-1)*5+3);
%                 obj.sigmaX(i) = fitRes((i-1)*5+4);
%                 obj.sigmaY(i) = fitRes((i-1)*5+5);
            end
            
            
            %set fit params
            obj.xCenter = round(obj.x0(1)); % should be indexes (integers)
            obj.yCenter= round(obj.y0(1));
            obj.xUnitSize = obj.sigmaX(1);
            obj.yUnitSize = obj.sigmaY(1);
            obj.maxVal = max(obj.A);
            scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2); 
            obj.Nclouds = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * obj.Nclouds / scatcross);   
            [sum(obj.Nclouds) obj.Nclouds]
            %set fit params
%             obj.xCenter = round(xCenter); % should be indexes (integers)
%             obj.yCenter= round(mean([obj.y01 obj.y02]));
%             obj.xUnitSize = w;
%             obj.yUnitSize = obj.sigmaY1;
%             obj.maxVal = max([obj.A1 obj.A2]);
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           
           obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
           
           % last 
           appData.data.fits{appData.consts.fitTypes.four2DGaussians} = obj;
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
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
%            xFit = zeros(size(x));
           xFit = obj.A(1) * exp( -0.5 * (x-obj.x0(1)).^2 / obj.sigmaX(1)^2 ) + obj.C;
%            xFit = obj.A(1)* max(1-((x-obj.x0(1))./(1*obj.sigmaX(1)) ).^2 , 0).^(3/2) + obj.C;
           yFit1 = zeros(size(y));
           for i = 1 : length(obj.A)
              yFit1 = yFit1 + obj.A(i) * exp( -0.5 * (y-obj.y0(i)).^2 / obj.sigmaY(i)^2 );
%               yFit1 = yFit1 + obj.A(i)* max(1-((y-obj.y0(i))./(1*obj.sigmaY(i)) ).^2 , 0).^(3/2);
           end
           yFit1 = yFit1 + obj.C;
% yFit1 = feval(obj.fval, obj.fval.x01,y);
           yFit2 = feval(obj.yRes, y)';
           
           xFit = [xFit; xFit];
           yFit = [yFit2; yFit1];
%            yFit = feval(obj.yRes, y)';
%            yFit = obj.A1 * exp( -0.5 * (y-obj.y01).^2 / obj.sigmaY1^2 ) + obj.A2 * exp( -0.5 * (y-obj.y02).^2 / obj.sigmaY2^2 );% + obj.yRes.Cy;
       end
       
       function  plotFitResults(obj, appData)  % plots the text           
%            [pic x0 y0] = appData.data.plots{appData.data.plotType}.getPic();
%            chipStart = appData.data.camera.chipStart;
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

% % amp 1-4 = p(1:4);
% % cy 1-4 = p(5:8);
% % wy 1-4 = p(9:12);
% % cx = p(17);
% % wx = p(13:16);
% % C = p(18)
% ret = ...
%     p(1)*( exp( -0.5 * (X - p(17)).^2./p(13).^2 - 0.5 * (Y - p(5)).^2./p(9).^2 ) ) + ...
%     p(2)*( exp( -0.5 * (X - p(17)).^2./p(14).^2 - 0.5 * (Y - p(6)).^2./p(10).^2 ) ) + ...
%     p(3)*( exp( -0.5 * (X - p(17)).^2./p(15).^2 - 0.5 * (Y - p(7)).^2./p(11).^2 ) ) + ...
%     p(4)*( exp( -0.5 * (X - p(17)).^2./p(16).^2 - 0.5 * (Y - p(8)).^2./p(12).^2 ) ) + ...
%     p(18) - g;
% ret = sum(sum(ret.^2));

% % amp = p(1);
% % cx = p(2);
% % cy = p(3);
% % wx = p(4);
% % wy = p(5);
% % 4 times
% % C = p(end)
% ret = ...
%     p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) + ...
%     p(6)*( exp( -0.5 * (X - p(7)).^2./p(9).^2 - 0.5 * (Y - p(8)).^2./p(10).^2 ) ) + ...
%     p(11)*( exp( -0.5 * (X - p(12)).^2./p(14).^2 - 0.5 * (Y - p(13)).^2./p(15).^2 ) ) + ...
%     p(16)*( exp( -0.5 * (X - p(17)).^2./p(19).^2 - 0.5 * (Y - p(18)).^2./p(20).^2 ) ) + ...
%     p(21) - g;
% ret = sum(sum(ret.^2));
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
% %cx = p(2);
% %cy = p(3);
% %wTFx = p(4);
% %wTFy = p(5);
% % 4 times
% % C = p(end)
% ret = ...
%     p(1)* max( 1 - ( (X-p(2))./(1*p(4)) ).^2 - ( (Y-p(3))./(1*p(5)) ).^2 , 0).^(3/2) + ...
%     p(6)* max( 1 - ( (X-p(7))./(1*p(9)) ).^2 - ( (Y-p(8))./(1*p(10)) ).^2 , 0).^(3/2) + ...
%     p(11)* max( 1 - ( (X-p(12))./(1*p(14)) ).^2 - ( (Y-p(13))./(1*p(15)) ).^2 , 0).^(3/2) + ...
%     p(16)* max( 1 - ( (X-p(17))./(1*p(19)) ).^2 - ( (Y-p(18))./(1*p(20)) ).^2 , 0).^(3/2) + ...
%     p(21) - g;
% ret = sum(sum(ret.^2));
end

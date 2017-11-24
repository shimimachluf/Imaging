classdef FitSitesFull < FitTypes
%FITSITESFULL Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'FitSitesFull';
   end
   properties (Constant = true)
%        %square lattice
%        xStepR = 10;
%        yStepR = 4;
%        xStepD = -4;
%        yStepD = 10;
       
       %Hex lattice
       xStepR = 9;
       yStepR = 4;
       xStepD = 0;
       yStepD = 11;
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
       totFitRes = [];
       Nsites = [];
       
       
   end
   
   methods (Static)
       function [coords, R, Binv] = fitResParams(coords, R, Binv)
           %load params
           persistent Pcoords; 
           persistent PR;
           persistent PBinv;
           
           if nargin 
               Pcoords = coords;
               PR = R;
               PBinv = Binv;
           end
           
           coords = Pcoords;
           R = PR;
           Binv = PBinv;
       end
   end

   methods
       function appData = analyze(obj, appData) % do the analysis
           str1 = 'Cancel';
           str2 = 'Load';
           str3 = 'Create';
           btn = questdlg('Load an existing sites-data or create a new one?','Site Fitting',str1, str2, str3, str2);
           if strcmp(btn, str1)
               return
           elseif strcmp(btn, str2)
               [FileName,PathName,FilterIndex] = uigetfile([appData.save.saveDir appData.slash 'fitSites_Data.mat']);
               if FilterIndex == 0
                   return
               end
               load([PathName appData.slash FileName], 'Binv', 'R', 'coords');
%                obj.coords = coords; %[x0 y0 w h]
%                obj.R = R;
%                obj.Binv = Binv;
               obj.fitResParams(coords, R, Binv);
               
               % last
               appData.data.fits{appData.consts.fitTypes.createSites} = obj;
               return
           end
           
           
           [pic, x0, y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
           [h, w] = size(pic);
           coords = [x0 y0 w h];
           x0 = x0-1;
           y0 = y0-1;
           
%            % 1D fit (mouse)
%            fitObj = appData.data.fits{appData.consts.fitTypes.oneDGaussianMouse};
%            if ( isempty( fitObj.xRes ) )
%                errordlg('1D Gaussian Fit (mouse) does not exis. Do it first.', 'error', 'modal');
%                return
%            end
           
%            % 2D fit
%            firstGuess1 = [0.5*(fitObj.xRes.Ax+fitObj.yRes.Ay) fitObj.xRes.x0 fitObj.yRes.y0 ...
%                fitObj.xRes.sigmaX fitObj.yRes.sigmaY 0];%0.5*(fitObj.xRes.Cx+fitObj.yRes.Cy)]; % no constant 
%            %set one site size
%            xSiteSz1 = round(2*fitObj.xRes.sigmaX);
%            ySiteSz1 = round(2*fitObj.yRes.sigmaY);

           fitObj = appData.data.fits{appData.consts.fitTypes.onlyMaxMouse};
           if ( fitObj.maxVal == -1 )
               errordlg('Only Max Fit (mouse) does not exis. Do it first.', 'error', 'modal');
               return
           end
           
           xSiteSz = 5;
           ySiteSz = 3;
           xCen = round(appData.data.mouseCenterX / (appData.data.camera.xPixSz * 1000));% - x0;
           yCen = round(appData.data.mouseCenterY / (appData.data.camera.yPixSz * 1000));% - y0;
           firstGuess = [fitObj.maxVal xCen yCen xSiteSz/2 ySiteSz/2 0];

           x = [-xSiteSz  : xSiteSz] +xCen;
           y = [-ySiteSz  : ySiteSz] +yCen;
           [X, Y] = meshgrid(x, y);
           [fitRes, obj.fval, obj.exitflag, obj.output] = ...
               fminsearch(@(p) fitGauss2D_scalar( p, X, Y, pic(y-y0,x-x0)), firstGuess, ...
               optimset('TolX',1e-6, 'MaxFunEvals', 1e6, 'MaxIter', 1e6) );
            
            % set 2D params
            obj.OD = fitRes(1);
            obj.x0 = fitRes(2);
            obj.y0 = fitRes(3);
            obj.sigmaX = fitRes(4);
            obj.sigmaY = fitRes(5);
            obj.C = 0;%fitRes(6);
            
            %set fit params
            obj.xCenter = round(obj.x0); % should be indexes (integers)
            obj.yCenter= round(obj.y0);
            obj.xUnitSize = obj.sigmaX;
            obj.yUnitSize = obj.sigmaY;
            obj.maxVal = obj.OD;
            
            
%             j = 0;
            firstGuess = fitRes;
            ind = 0;
            fitResArr = zeros(1, length(firstGuess));
            for j = floor(-(obj.yCenter-y0)/obj.yStepD)-1 : ceil((h+y0-obj.yCenter)/obj.yStepD)+1
                for i = floor(-(obj.xCenter+j*obj.xStepD-x0)/obj.xStepR)-1 : ceil((w+x0-(obj.xCenter+j*obj.xStepD))/obj.xStepR)+1
                    oneSiteFit;
                    if ~isempty(fitRes)
                        ind = ind + 1;
                        fitResArr(ind, :) = fitRes; 
                        fitResArr(ind, 2:3) = fitResArr(ind, 2:3) -1;
%                         fitResArr1(ind, :) = [j i fitRes];
                    end
                end
            end
            
            [X, Y] = meshgrid(x0+[1:w]-1, y0+[1:h]-1);
            g1 = zeros(size(X));
            g_1 = cell(1, size(fitResArr, 1));
            for i = 1 : size(fitResArr, 1)
               g_1{i} = create2DGauss(fitResArr(i, :), X, Y);
               g1 = g1 + create2DGauss(fitResArr(i, :), X, Y);
            end
            
            if size(fitResArr, 1) <= 50
                [obj.totFitRes, obj.fval, obj.exitflag, obj.output] = ...
                    fminsearch(@(p) fitMany2DGauss( p, X, Y, pic), fitResArr, ...
                    optimset('TolX',1e-4));%, 'MaxFunEvals', 1e5, 'MaxIter', 1e5) );
                g_2 = cell(1, size(fitResArr, 1));
                g2 = zeros(size(X));
                for i = 1 : size(fitResArr, 1)
                    g_2{i} = create2DGauss(obj.totFitRes(i, :), X, Y);
                    g2 = g2 + create2DGauss(obj.totFitRes(i, :), X, Y);
                end
            else
                obj.totFitRes = fitResArr;
                g2 = g1;
            end
            
%             % to use the many fits solution
%             obj.totFitRes = fitResArr;
            
            
%             fitResArr
%             fitRes-fitResArr
%             fitRes
            saveFolder = [appData.analyze.readDir '_ROI ' num2str(appData.data.ROISizeX) ' ' ...
                num2str(appData.data.ROISizeY) ' ' num2str(appData.data.ROICenterX) ' ' num2str(appData.data.ROICenterY)];
            fHandle(1) = figure('FileName', [saveFolder appData.slash 'many fits.fig']); 
            imagesc(g1); title('many fits');
            for i = 1 : size(obj.totFitRes, 1)
                text(obj.totFitRes(i, 2)-x0, obj.totFitRes(i, 3)-y0, num2str(i));
            end
            fHandle(2) = figure('FileName', [saveFolder appData.slash '1 fit.fig']); 
            imagesc(g2); title('1 fit');
            for i = 1 : size(obj.totFitRes, 1)
                text(obj.totFitRes(i, 2)-x0, obj.totFitRes(i, 3)-y0, num2str(i));
            end
            fHandle(3) = figure('FileName', [saveFolder appData.slash 'diff (1-many).fig']); 
            imagesc(g2-g1); title('difference (1 fit - many fits)');
            fHandle(4) = figure('FileName', [saveFolder appData.slash 'pic.fig']); 
            imagesc(pic); title('pic')
            fHandle(5) = figure('FileName', [saveFolder appData.slash 'diff (pic-1).fig']); 
            imagesc(pic-g2); title(['difference (pic - 1 fit): ' num2str(sum(sum((pic-g2).^2)))]);
            fHandle(6) = figure('FileName', [saveFolder appData.slash 'diff (pic-many).fig']); 
            imagesc(pic-g1); title(['difference (pic - many fits): ' num2str(sum(sum((pic-g1).^2)))]);
            
            handle = warndlg('Waiting for fit inspection...','Waiting...','nonmodal');
            waitfor(handle);
%             close(fHandle(isvalid(fHandle)));
            
            str1 = 'Cancel';
            str2 = 'Many Fits';
            str3 = '1 Fit';
            btn = questdlg('Continue or Cancel current fit?','Site Fitting',str1, str2, str3, str1);
            if strcmp(btn, str1)
                close(fHandle(isvalid(fHandle)));
                return
            elseif strcmp(btn, str2)
                obj.totFitRes = fitResArr;
                g = g_1;
            else
                g = g_2;
            end
            
            R = double(reshape(cat(3,g{:}), w*h, size(obj.totFitRes, 1)));
            A = double(reshape(pic(:),w*h, 1));
            Binv = pinv(R'*R)*R';
            c = Binv*A;
%             obj.Nsites = c.*cellfun(@(x) sum(x(:)), g)'; % in OD units
            scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2);
            obj.Nsites = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * ...
                 c.*sum(R,1)' / scatcross); %sum(sum(normalizedROI)) / scatcross);   
            
%              [FileName,PathName,FilterIndex] = uiputfile([appData.save.saveDir appData.slash 'fitSites_Data.mat']);
%              if FilterIndex ~= 0
%                  totFitRes = obj.totFitRes;
%                  saveDir = appData.analyze.totAppData{1}.save.saveDir;
%                  picNums = cellfun(@(x) x.save.picNo, appData.analyze.totAppData);
%                  save([PathName appData.slash FileName], 'Binv', 'R', 'coords', 'totFitRes', 'g', 'saveDir', 'picNums');
% %                  return
%              end
            [status,message,messageid] = mkdir(saveFolder);
            if ~status
                errordlg('Cannot make ''saveFolder'' folder', 'Error', 'modal');
                return
            end
            for i = 1 : length(fHandle)
                if isvalid(fHandle(i))
                    saveas(fHandle(i), get(fHandle(i), 'FileName'));
                    close(fHandle(i));
                end
            end
%             close(fHandle(isvalid(fHandle)));
            totFitRes = obj.totFitRes;
            picNums = cellfun(@(x) x.save.picNo, appData.analyze.totAppData);
            saveDir = appData.analyze.totAppData{1}.save.saveDir;
            save([saveFolder appData.slash 'fitSites_Data (' btn ').mat'], ...
                'Binv', 'R', 'coords', 'totFitRes', 'g', 'saveDir', 'picNums');

             obj.fitResParams(coords, R, Binv);

            
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
            appData.data.fits{appData.consts.fitTypes.createSites} = obj;
%            appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
       
       
           function oneSiteFit
               xc = obj.xCenter + round(i*obj.xStepR + j*obj.xStepD);
               yc = obj.yCenter + round(i*obj.yStepR + j*obj.yStepD);
               if xc > w+x0 || xc < x0 || yc > h+y0 || yc < y0
                   fitRes = [];                  
                   return
               end
               x = [-xSiteSz  : xSiteSz] + xc;
               y = [-ySiteSz  : ySiteSz] + yc;
               
               x = x.*(x<=w+x0);
               x = x.*(x>=x0+1);
               x = x(x~=0);
               y = y.*(y<=h+y0);
               y = y.*(y>=y0+1);
               y = y(y~=0);
               
%                if ~isempty(fitRes)
%                    firstGuess = fitRes;
%                end
               firstGuess(2) = xc;
               firstGuess(3) = yc;
               
               [X, Y] = meshgrid(x, y);
%                [fitRes, obj.fval, obj.exitflag, obj.output] = ...
%                    fminsearch(@(p) fitGauss2D_scalar( p, X, Y, pic(y-y0,x-x0)), firstGuess, ...
%                    optimset('TolX',1e-8, 'TolFun', 1e-8, 'TolCon', 1e-8) );
               [fitRes, obj.fval, obj.exitflag, obj.output, lambda, grad, hessian] = ...
                   fmincon(@(p) fitGauss2D_scalar( p, X, Y, pic(y-y0,x-x0)), firstGuess, [], [], [], [], ...
                   [0 xc-xSiteSz yc-ySiteSz 0 0 -pi], [1 xc+xSiteSz yc+ySiteSz xSiteSz ySiteSz pi], [], ...
                   optimset('TolX',1e-8, 'TolFun', 1e-8, 'TolCon', 1e-8, 'Display', 'off') );
%                [i j xc yc 0 0; fitRes; fitRes1]
           end
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
      
function ret = fitGauss2D_matrix( p, X, Y, g ) %#ok<DEFNU>
% amp = p(1);
% cx = p(2);
% cy = p(3);
% wx = p(4);
% wy = p(5);
% C = p(6)
ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) - g; %+ p(6) - g;
end
    
function ret = fitGauss2D_scalar( p, X, Y, g )
% A = p(1);
% x0 = p(2);
% y0 = p(3);
% sigma_x = p(4);
% sigma_y = p(5);
% theta = p(6);
% % C = p(7);

Z = create2DGauss(p, X, Y);
ret = Z - g;

% ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) - g; %+ p(6) - g;

ret = sum(sum(ret.^2));
end

function ret = fitMany2DGauss(p, X, Y, g)
% p is an array of the gaussians

Z = zeros(size(X));
for i = 1 : size(p, 1)
    Z = Z + create2DGauss(p(i, :), X, Y);
end
ret = Z-g;
ret = sum(sum(ret.^2));
end

function Z = create2DGauss(p, X, Y)
% A = p(1);
% x0 = p(2);
% y0 = p(3);
% sigma_x = p(4);
% sigma_y = p(5);
% theta = p(6);
% % C = p(7);
% 
% a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
% b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
% c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;
% 
% Z = A*exp( - (a*(X-x0).^2 + 2*b*(X-x0).*(Y-y0) + c*(Y-y0).^2)) ;

Z = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) );
end
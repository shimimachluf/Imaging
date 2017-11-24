classdef FitSitesMask < FitTypes
%FITSITESMASK Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'FitSitesMask';
   end
   properties (Constant = true)
%        square lattice
%        xStepR = 87/9;
%        yStepR = 39/9;
%        xStepD = 39/9;
%        yStepD = -87/9;
       
       % Hex lattice
       xStepR = 87/9;%9;
       yStepR = 38/9;%4;
       xStepD = 74/9;%0;
       yStepD = -53/9;%11;
   end
   properties (SetAccess = protected )
       
       Nsites = [];
       siteCoords = [];
       
       
   end
   
  
   methods
       function appData = analyze(obj, appData) % do the analysis
          
           
           [pic, x0, y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
           [h, w] = size(pic);
           [absPic, abs_x0, abs_y0] = appData.data.plots{appData.consts.plotTypes.absorption}.getAnalysisPic(appData); % only ROI
           [absH, absW] = size(absPic);
%           coords = [x0 y0 w h];
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
%                errordlg('Only Max Fit (mouse) does not exis. Do it first.', 'error', 'modal');
%                return
               tmpFitType = appData.data.fitType;
               appData.data.fitType = appData.consts.fitTypes.onlyMaxMouse;
               appData = appData.data.fits{appData.consts.fitTypes.onlyMaxMouse}.analyze(appData);
               fitObj = appData.data.fits{appData.consts.fitTypes.onlyMaxMouse};
               appData.data.fitType = tmpFitType;
           end
           
           xSiteSz = 4;
           ySiteSz = 4;
           xCen = round(appData.data.mouseCenterX / (appData.data.camera.xPixSz * 1000));% - x0;
           yCen = round(appData.data.mouseCenterY / (appData.data.camera.yPixSz * 1000));% - y0;

%            %base initial center on a fit
%            firstGuess = [fitObj.maxVal xCen yCen xSiteSz/2 ySiteSz/2];
%            x = [-xSiteSz  : xSiteSz] +xCen;
%            y = [-ySiteSz  : ySiteSz] +yCen;
%            [X, Y] = meshgrid(x, y);
%            [fitRes, fval, exitflag, output] = ...
%                fminsearch(@(p) fitGauss2D_scalar( p, X, Y, pic(y-y0,x-x0)), firstGuess, ...
%                optimset('TolX',1e-6, 'MaxFunEvals', 1e6, 'MaxIter', 1e6) );
%            xCen = fitRes(2);
%            yCen = fitRes(3);
            
            obj.siteCoords = [];
            obj.Nsites = [];
            ind = 0;
            for j = floor(-(yCen-y0)/obj.yStepD)+20 :-1: ceil((h+y0-yCen)/obj.yStepD)-20
                for i = floor(-(xCen+j*obj.xStepD-x0)/obj.xStepR)-20 : ceil((w+x0-(xCen+j*obj.xStepD))/obj.xStepR)+20
%             for j = floor(-(yCen-y0)/obj.yStepD)-1 :-1: ceil((h+y0-yCen)/obj.yStepD)+1
%                 for i = floor(-(xCen+j*obj.xStepD-x0)/obj.xStepR)-1 : ceil((w+x0-(xCen+j*obj.xStepD))/obj.xStepR)+1
                    N = oneSiteSum;
                    if N
                        ind = ind + 1;
                        obj.Nsites(ind) = N; 
                        obj.siteCoords(ind, 1:2) = [xc yc];
                    end
                end
            end
            
%             %%% UNCOMMENT for checking
            
%             saveFolder = appData.analyze.readDir;
%             fHandle(1) = figure('FileName', [saveFolder '_mask.fig']);
%             pic(yCen-y0, xCen-x0+1) = 1;
%             col = max(max(pic));
%             for i = 1 : ind
%                 pic(obj.siteCoords(i, 2)-y0, obj.siteCoords(i, 1)-x0) = col;
%             end
%             image(pic/max(max(pic))*256); title('Mask');
%             imagesc(pic); title('Mask'); axis image
%             for i = 1 : ind
%                 text(obj.siteCoords(i, 1)-x0, obj.siteCoords(i, 2)-y0, num2str(i));
%             end
%             
%             %%% END

%             %%% UNCOMMENT the following part to Create the Mask and save the mask coords  
%             
%             saveFolder = appData.analyze.readDir;
%             fHandle(1) = figure('FileName', [saveFolder '_mask.fig']);
%             pic(yCen-y0, xCen-x0+1) = min(min(pic));
%             pic(1, 1) = max(max(pic))*1.15;
%             col = max(max(pic));
%             coords = zeros(ind+1, 5); %site index, ROI x coord, ROI y coord, Im x coord, Im y coord
%             coords(1,:) = [0, w, h, xCen, yCen ]; % line 0, Mask width, Mask hight, Mask xCen, Mask yCen 
%             for i = 1 : ind
%                 
%                 pic(obj.siteCoords(i, 2)-y0, obj.siteCoords(i, 1)-x0) = col;
%                 coords(i+1,:) = [i, obj.siteCoords(i, 1)-x0, obj.siteCoords(i, 2)-y0, obj.siteCoords(i, 1), obj.siteCoords(i, 2) ];
%                 if obj.siteCoords(i, 2)-y0-ySiteSz > 0 && obj.siteCoords(i, 1)-x0-xSiteSz > 0 && obj.siteCoords(i, 1)-x0+xSiteSz <= w && obj.siteCoords(i, 2)-y0+ySiteSz <= h
%                     pic(obj.siteCoords(i, 2)-y0-ySiteSz, obj.siteCoords(i, 1)-x0-xSiteSz:obj.siteCoords(i, 1)-x0+xSiteSz) = col;
%                     pic(obj.siteCoords(i, 2)-y0+ySiteSz, obj.siteCoords(i, 1)-x0-xSiteSz:obj.siteCoords(i, 1)-x0+xSiteSz) = col;
%                     pic(obj.siteCoords(i, 2)-y0-ySiteSz:obj.siteCoords(i, 2)-y0+ySiteSz, obj.siteCoords(i, 1)-x0-xSiteSz) = col;
%                     pic(obj.siteCoords(i, 2)-y0-ySiteSz:obj.siteCoords(i, 2)-y0+ySiteSz, obj.siteCoords(i, 1)-x0+xSiteSz) = col;
%                 end
%             end
%             colormap(jet(256));image(pic/max(max(pic))*256); title('Mask'); axis image
% %             imagesc(pic); title('Mask');
%             for i = 1 : ind
%                 text(obj.siteCoords(i, 1)-x0-1.5, obj.siteCoords(i, 2)-y0, num2str(i),'Color', [0 0 0],'FontSize',12);
% %                 text(obj.siteCoords(i, 1)-x0-5, obj.siteCoords(i, 2)-y0+1, 'O', 'FontSize',40);
%             end
%             csvwrite([saveFolder '_Mask_coords_x=' num2str(xCen) 'y=' num2str(yCen) '.csv'],coords)
% 
%             %%% END 

            % convert from OD to N
%             normalizedROI = fitObj.getNormalizedROI(pic, x, y);
           scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2); 
%            obj.Nsites = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * obj.Nsites / scatcross); 
           obj.Nsites = appData.data.camera.xPixSz * appData.data.camera.yPixSz * obj.Nsites / scatcross;   
%             obj.Nsites = obj.Nsites*1; %scatercross and pix size
            
            obj.maxVal = max(max(pic));
            % center
           obj.xCenter = round(xCen);
           obj.yCenter = round(yCen); 
           % unit size
           obj.xUnitSize = w;
           obj.yUnitSize = h; 
            
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
            appData.data.fits{appData.consts.fitTypes.createMaskedSites} = obj;
%            appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
       
        function N = oneSiteSum
               xc = round(xCen + i*obj.xStepR + j*obj.xStepD);
               yc = round(yCen + i*obj.yStepR + j*obj.yStepD);
%                if xc > w+x0-xSiteSz || xc <= x0+xSiteSz || yc > h+y0-ySiteSz || yc <= y0+ySiteSz
               if xc > w+x0 || xc <= x0 || yc > h+y0 || yc <= y0
                   N = 0;
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
               
%                N = sum(sum(pic(y-y0,x-x0)));
               N = sum(sum(absPic(y,x)));
        end
           
       
       end
       
       function normalizedROI = getNormalizedROI(obj, pic, x, y) % return normalized ROI (to the fitting constant)
           normalizedROI = pic(y, x);
       end
       
       function normalizedROI = getTheoreticalROI(obj, pic, x, y)
           [X, Y] = meshgrid(x, y);
           normalizedROI = pic(y, x);
       end
       
       function normalizedPic = normalizePic(obj, pic)
           normalizedPic = pic/obj.maxVal;
       end
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
           xFit = zeros(size(x));
           yFit = zeros(size(y));
       end
       
       function  plotFitResults(obj, appData)  % plots the text
           set(appData.ui.stFitResultsAtomNum, 'String',['Atoms Num: ' formatNum(obj.atomsNo, 'num')]);
%            set(appData.ui.stFitResultsFitFunction, 'String', 'Fit Function: \Sigma A * {\ite}^{-(x-x_0)^2 / 2\sigma_x^2 - (y-y_0)^2 / 2\sigma_y^2}');
           set(appData.ui.stFitResults1, 'String', {['OD = ' num2str(obj.maxVal) ], ...
               ['x_0 = ' formatNum((obj.xCenter) * appData.data.camera.xPixSz, 'dis')]});
           set(appData.ui.stFitResults2, 'String', {'', ...
               ['y_0 = ' formatNum((obj.yCenter) * appData.data.camera.yPixSz, 'dis')]});
               
       end
       
       function output = copyObject(input, output)
           C = metaclass(input);
           P = C.Properties;
           for k = 1:length(P)
               if ~P{k}.Dependent && ~P{k}.Constant
                   output.(P{k}.Name) = input.(P{k}.Name);
               end
           end
       end
   end
end 

function ret = fitGauss2D_scalar( p, X, Y, g )
% A = p(1);
% x0 = p(2);
% y0 = p(3);
% sigma_x = p(4);
% sigma_y = p(5);
% theta = p(6);
% % C = p(7);

% Z = create2DGauss(p, X, Y);
% ret = Z - g;

ret = p(1)*( exp( -0.5 * (X - p(2)).^2./p(4).^2 - 0.5 * (Y - p(3)).^2./p(5).^2 ) ) - g; %+ p(6) - g;

ret = sum(sum(ret.^2));
end

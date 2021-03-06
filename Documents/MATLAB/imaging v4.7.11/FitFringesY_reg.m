classdef FitFringesY < FitTypes
%FITFRINGESY Summary of this class goes here
%   Detailed explanation goes here

   properties ( Constant = true )
       ID = 'FitFringesY';
   end
   properties (SetAccess = private )
       res = [];
       gof = [];
       output = [];
       a = -1;
       x0 = -1;
       w = -1;
       c = -1;
       conf = [];
   end

   methods
       function appData = analyze(obj, appData) % do the analysis
           % 1D fit
           fitObj = appData.data.fits{appData.consts.fitTypes.twoDGaussian};
           if ( isempty( fitObj.fval ) )
               tmpFitType = appData.data.fitType;
               appData.data.fitType = appData.consts.fitTypes.twoDGaussian;
               appData = appData.data.fits{appData.consts.fitTypes.twoDGaussian}.analyze(appData);
               fitObj = appData.data.fits{appData.consts.fitTypes.twoDGaussian};
               appData.data.fitType = tmpFitType;
           end
           
           [pic x0 y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
           [h w] = size(pic);
           
           % fit
           [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors(...
               fitObj.xCenter, fitObj.yCenter, appData.options.avgWidth);
           xData = [1:length(yData)];
           
           firstGuess = [fitObj.OD*0.85, fitObj.C,  15, 0, 0.1, fitObj.sigmaY, fitObj.y0-y0];
           lower = [0 -0.1 0 -Inf 0 0 0 ];
           upper = [5 0.1 20 Inf 1 length(yData) length(yData) ];
%            firstGuess = [10, 0, 0.1];
%            lower = [ 0 -Inf 0  ];
%            upper = [ 20 Inf 1 ];
           fo = fitoptions('method','NonlinearLeastSquares','Robust','On', ...
               'DiffMinChange',1e-010,'DiffMaxChange',1e-005,'MaxFunEvals',1000, ...
               'MaxIter',1000,'TolFun',1e-010,'TolX',1e-010, 'Startpoint', firstGuess, ...
               'Lower', lower, 'Upper', upper);
            ft = fittype('a*exp(-(x-x0)^2/2/w^2)*(1+v*sin(2*pi/lambda*(x-x0)+phi))+c',...
                'dependent',{'y'},'independent',{'x'}, 'coefficients',{'a', 'c', 'lambda', 'phi', 'v', 'w', 'x0'});
            obj.a = fitObj.OD;
            obj.x0 = fitObj.y0-y0;
            obj.w = fitObj.sigmaY;            
            obj.c = fitObj.C;
%             ft = fittype([ num2str(obj.a) '*exp(-(x-' num2str(obj.x0) ')^2/2/' num2str(obj.w) '^2)*(1+v*sin(2*pi/lambda*(x-' num2str(obj.x0) ... 
%                 ')+phi))+' num2str(obj.c) ''], 'dependent',{'y'},'independent',{'x'}, 'coefficients',{ 'lambda', 'phi', 'v'});
           
           [obj.res, obj.gof, obj.output] = fit(xData',yData',ft,fo);
           conf = confint(obj.res);
           obj.conf = (conf(2,:)-conf(1,:))/2;          
           
           pxSz = appData.consts.cameras{appData.options.cameraType}.yPixSz;
%            h = figure;
%            plot(xData, yData,  '-b.');
%            hold on;
%            plot(obj.res);
%            hold off
%            set(gca, 'XTickLabel', get(gca, 'XTick')*pxSz*1000);
%            xlabel('y position [pixel]');
%            ylabel('OD');
%            title('fringes fit Y direction');
%            set(h, 'Name', 'fringes fit Y direction');
%            text( xData(2), max(yData)*0.5, {['fit function:'] ['   A*exp(-(x-x0)^2/2/\sigma^2) *(1+v*sin(2pix/\lambda+\phi))+C'], ...
%                [num2str(obj.res.a) 'exp(-(x-' num2str(obj.res.x0) ')^2/2/' num2str(obj.res.w) '^2) * '] ...
%                ['   (1+' num2str(obj.res.v) '*sin(2pix/' num2str(obj.res.lambda) '+' num2str(obj.res.phi) '))+' num2str(obj.res.c)], ...
%                ['R^2 = ' num2str(obj.gof.rsquare)] ...
%                ['A = ' num2str(obj.res.a) ' +/- ' num2str(conf(1))], ...
%                ['x_0 = ' num2str(obj.res.x0*pxSz*1000) ' +/- ' num2str(conf(7)*pxSz*1000) ' mm' ], ...
%                ['\sigma = ' num2str(obj.res.w*pxSz*1000) ' +/- ' num2str(conf(6)*pxSz*1000) ' mm' ], ...
%                ['v = ' num2str(obj.res.v) ' +/- ' num2str(conf(5)) ], ...
%                ['\lambda = ' num2str(obj.res.lambda*pxSz*1000) ' +/- ' num2str(conf(3)*pxSz*1000) ' mm' ], ...
%                ['\phi = ' num2str(mod(obj.res.phi, 2*pi)) ' +/- ' num2str(conf(4))], ...
%                ['C = ' num2str(obj.res.c) ' +/- ' num2str(conf(2)) ], ...
%                });
%            
%            vars = {'A', '[lower uper]', 'C', '[lower uper]', '\lambda', '[lower uper]', '\phi', '[lower uper]', ...
%                'v', '[lower uper]', '\sigma', '[lower uper]', 'x_0', '[lower uper]'};
%            vals = {num2str(firstGuess(1)), num2str([lower(1) upper(1)]), num2str(firstGuess(2)), num2str([lower(2) upper(2)]), ...
%                num2str(firstGuess(3)), num2str([lower(3) upper(3)]), num2str(firstGuess(4)), num2str([lower(4) upper(4)]), ...
%                num2str(firstGuess(5)), num2str([lower(5) upper(5)]), num2str(firstGuess(6)), num2str([lower(6) upper(6)]), ...
%                num2str(firstGuess(7)), num2str([lower(7) upper(7)])};
%            options.Interpreter = 'tex';
%            options.Resize = 'on';
%            options.WindowStyle = 'normal';
%            vals = inputdlg(vars, 'Enter init. guess:', 1, vals, options);
           
           while 0%( ~isempty(vals) )
               
               for ( i = 1 : length(vals)/2 )
                   firstGuess(i) = eval(vals{2*i - 1}); %#ok<AGROW>
                   t = eval([ '[' vals{2*i} ']' ]); %#ok<AGROW>
                   lower(i)  = t(1);
                   upper(i) = t(2);
               end
               
               fo = fitoptions('method','NonlinearLeastSquares','Robust','On', ...
                   'DiffMinChange',1e-010,'DiffMaxChange',1e-005,'MaxFunEvals',1000, ...
                   'MaxIter',1000,'TolFun',1e-010,'TolX',1e-010, 'Startpoint', firstGuess, ...
                   'Lower', lower, 'Upper', upper);
               ft = fittype('a*exp(-(x-x0)^2/2/w^2)*(1+v*sin(2*pi/lambda*(x-x0)+phi))+c',...
                   'dependent',{'y'},'independent',{'x'}, 'coefficients',{'a', 'c', 'lambda', 'phi', 'v', 'w', 'x0'});
               [obj.res, obj.gof, obj.output] = fit(xData',yData',ft,fo);
               conf = confint(obj.res);
               conf = (conf(2,:)-conf(1,:))/2;
%                obj.res.phi = mod(obj.res.phi, 2*pi);
               
               clf(h)
               figure(h);
               plot(xData, yData,  '-b.');
               hold on;
               plot(obj.res);
               hold off
               set(gca, 'XTickLabel', get(gca, 'XTick')*pxSz*1000);
               xlabel('y position [mm]');
               ylabel('OD');
               title('fringes fit Y direction');
               set(h, 'Name', 'fringes fit Y direction');
               text( xData(2), max(yData)*0.5, {['fit function:'] ['   A*exp(-(x-x0)^2/2/\sigma^2) *(1+v*sin(2pix/\lambda+\phi))+C'], ...
                   [num2str(obj.res.a) 'exp(-(x-' num2str(obj.res.x0) ')^2/2/' num2str(obj.res.w) '^2) * '] ...
                   ['   (1+' num2str(obj.res.v) '*sin(2pix/' num2str(obj.res.lambda) '+' num2str(obj.res.phi) '))+' num2str(obj.res.c)], ...
                   ['R^2 = ' num2str(obj.gof.rsquare)] ...
                   ['A = ' num2str(obj.res.a) ' +/- ' num2str(conf(1))], ...
                   ['x_0 = ' num2str(obj.res.x0*pxSz*1000) ' +/- ' num2str(conf(7)*pxSz*1000) ' mm' ], ...
                   ['\sigma = ' num2str(obj.res.w*pxSz*1000) ' +/- ' num2str(conf(6)*pxSz*1000) ' mm' ], ...
                   ['v = ' num2str(obj.res.v) ' +/- ' num2str(conf(5)) ], ...
                   ['\lambda = ' num2str(obj.res.lambda*pxSz*1000) ' +/- ' num2str(conf(3)*pxSz*1000) ' mm' ], ...
                   ['\phi = ' num2str(mod(obj.res.phi, 2*pi)) ' +/- ' num2str(conf(4))], ...
                   ['C = ' num2str(obj.res.c) ' +/- ' num2str(conf(2)) ], ...
                   });
               
               vals = inputdlg(vars, 'Enter init. guess:', 1, vals, options);
               
           end
%            close(h);
            
            %set fit params
            obj.xCenter = round(fitObj.x0); % should be indexes (integers)
            obj.yCenter= round(fitObj.y0);
            obj.xUnitSize = fitObj.sigmaX;
            obj.yUnitSize = fitObj.sigmaY;
            obj.maxVal = fitObj.OD;
           
           % calc ROI size (use ROIUnits.m) - MUST be after fit
           [obj.ROILeft obj.ROITop obj.ROIRight obj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, obj);
           appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
           [pic x0 y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData);
           
            obj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, obj, pic, ...
               [obj.ROILeft : obj.ROIRight] - x0+1, [obj.ROITop : obj.ROIBottom] - y0+1); 
           
            [xData yData] = appData.data.plots{appData.data.plotType }.getXYDataVectors( ...
                obj.xCenter, obj.yCenter, appData.options.avgWidth);

            obj.xData = xData;
            obj.xStart = x0;
            obj.yData = yData;
            obj.yStart = y0;

            % last
            appData.data.fits{appData.consts.fitTypes.fringesY} = obj;
       end
       
       function normalizedROI = getNormalizedROI(obj, pic, x, y) % return normalized ROI (to the fitting constant)
           normalizedROI = pic(y, x);
       end
       
       function normalizedROI = getTheoreticalROI(obj, pic, x, y)
           normalizedROI = pic(y, x);
       end
       
       function normalizedPic = normalizePic(obj, pic)
           normalizedPic = (pic)/obj.maxVal;
       end
       
       function [xFit yFit] = getXYFitVectors(obj, x, y)
           xFit = zeros(size(x));
           y = y-obj.yStart+1;
%            y = [y(1):0.01:y(end)];
           yFit =  obj.res.a*exp(-(y-obj.res.x0).^2/2/obj.res.w^2) .*  ...
               (1+obj.res.v*sin(2*pi*(y-obj.res.x0)/obj.res.lambda+obj.res.phi))+obj.res.c;
%            yFit =  obj.a*exp(-(y-obj.x0).^2/2/obj.w^2) .*  ...
%                (1+obj.res.v*sin(2*pi*(y-obj.x0)/obj.res.lambda+obj.res.phi))+obj.c;
       end
       
       function  plotFitResults(obj, appData)  % plots the text
           
           text(10, 190, ['\lambda = ' num2str(obj.res.lambda*appData.consts.cameras{appData.options.cameraType}.yPixSz*1e6)  ...
               ' +/- ' num2str(obj.conf(3)*appData.consts.cameras{appData.options.cameraType}.yPixSz*1e6) ' [\mum]']);
           text(10, 170, ['\phi = ' num2str(mod(obj.res.phi, 2*pi)) ' +/- ' num2str(obj.conf(4) )]);
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
       end
   end
end 
      
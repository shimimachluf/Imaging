classdef FitSitesMask_PSF < FitSitesMask
    %FITSITESMASK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties ( Constant = true )
        ID_1 = 'FitSitesMask_PSF';
    end
    properties (SetAccess = protected)
        PSF = [ 0.0499    0.0380    0.0378;
                0.0441    0.6602    0.0441;
                0.0378    0.0380    0.0499];
        fullMask = [];
        NSitesMat = [];
        NSitesMatDeconv = [];
        NSitesDeconv = [];
    end
    
    
    methods
        function appData = analyze(obj, appData) % do the analysis
            %            appData = obj.analyze@FitSitesMask(appData);
            %            obj=appData.data.fits{appData.consts.fitTypes.createMaskedSites};
            
            
            fitObj = appData.data.fits{appData.consts.fitTypes.createMaskedSites};
            if ( isempty( fitObj.Nsites ) )
                tmpFitType = appData.data.fitType;
                appData.data.fitType = appData.consts.fitTypes.createMaskedSites;
                appData = appData.data.fits{appData.consts.fitTypes.createMaskedSites}.analyze(appData);
                fitObj = appData.data.fits{appData.consts.fitTypes.createMaskedSites};
                appData.data.fitType = tmpFitType;
            end
            obj = copyObject(fitObj, obj);
            %            obj.Nsites = fitObj.Nsites;
            %            obj.siteCoords = fitObj.siteCoords;
            
            
            [pic, x0, y0] = appData.data.plots{appData.consts.plotTypes.ROI}.getAnalysisPic(appData); % only ROI
            [h, w] = size(pic);
            [absPic, abs_x0, abs_y0] = appData.data.plots{appData.consts.plotTypes.absorption}.getAnalysisPic(appData); % only ROI
            [absH, absW] = size(absPic);
            %           coords = [x0 y0 w h];
            x0 = x0-1;
            y0 = y0-1;
            
            xCoord = obj.siteCoords(:,1) - x0;
            yCoord = obj.siteCoords(:,2) - y0;
            
            dxCoord = diff(xCoord);
            firstLnInd = [1; find(dxCoord<0)+1];
            lnsLen = diff([firstLnInd; length(xCoord)+1]);
            maxLnLen = max(lnsLen);
            maxLnInds = find(lnsLen==maxLnLen);
            obj.fullMask = zeros(length(lnsLen), maxLnLen);
            
            
            % convert mask to square matrix
            if max(diff(maxLnInds)) > 1
                errordlg('Longest lines are not together. Define manually!', 'Error', 'modal');
                return
            end
            
            obj.fullMask(maxLnInds, :) = ...
                repmat(firstLnInd(maxLnInds),1, maxLnLen)+repmat([0:maxLnLen-1], 2,1);
            
            firstInd = 1;
            for i = maxLnInds(1)-1 : -1 : 1
                firstInd = ...
                    find(xCoord(obj.fullMask(i+1, firstInd+[0:lnsLen(i+1)-1])) > xCoord(firstLnInd(i)), 1)-1;
                firstInd = firstInd + length(find(obj.fullMask(i+1, 1:firstInd) == 0));
                obj.fullMask(i, firstInd+[0:lnsLen(i)-1]) = firstLnInd(i)+[0:lnsLen(i)-1];
            end
            
            firstInd = 1;
            for i = maxLnInds(end)+1 : length(lnsLen)
                firstInd = ...
                    find(xCoord(obj.fullMask(i-1, firstInd+[0:lnsLen(i-1)-1])) > xCoord(firstLnInd(i)), 1);
                firstInd = firstInd + length(find(obj.fullMask(i-1, 1:firstInd) == 0));
                obj.fullMask(i, firstInd+[0:lnsLen(i)-1]) = firstLnInd(i)+[0:lnsLen(i)-1];
            end
            
            % do deconv
            tmp = [0 obj.Nsites];
            obj.NSitesMat = tmp(obj.fullMask+1);
            obj.NSitesMatDeconv = deconvlucy(obj.NSitesMat, obj.PSF);
            [B, I] = sort(obj.fullMask(:));
            obj.NSitesDeconv = obj.NSitesMatDeconv(I(B>0));
            
            % last
            appData.data.fits{appData.consts.fitTypes.createMaskedSitesPSF} = obj;
            
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

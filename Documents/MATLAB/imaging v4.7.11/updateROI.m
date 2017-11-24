function appData = updateROI(appData)
% [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
[pic x0 y0] = appData.data.plots{appData.consts.plotTypes.absorption}.getAnalysisPic(appData);
for ( i = 1 : length(appData.data.fits) )
    fitObj = appData.data.fits{i};
    
    if ( fitObj.atomsNo ~= -1 )
       [fitObj.ROILeft fitObj.ROITop fitObj.ROIRight fitObj.ROIBottom] = appData.data.ROITypes{appData.data.ROIUnits}.getROICoords(appData, fitObj);
       fitObj.atomsNo = appData.options.calcs{appData.options.calcAtomsNo}.calcAtomsNo(appData, fitObj, pic, ...
           [fitObj.ROILeft : fitObj.ROIRight] - x0+1, [fitObj.ROITop : fitObj.ROIBottom] - y0+1);  %#ok<*NBRAK>
       appData.data.fits{i} = fitObj;
    end
end
appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, pic);
end
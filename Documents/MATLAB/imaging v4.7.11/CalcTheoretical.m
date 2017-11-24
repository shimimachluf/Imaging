
classdef CalcTheoretical < CalcAtomsNo
%CALCREAL Summary of this class goes here
%   Detailed explanation goes here

   properties
   end

   methods 
       function atomsNo = calcAtomsNo(obj, appData, fitObj, pic, x, y)
           [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
           normalizedROI = fitObj.getTheoreticalROI(pic, x, y+y0);
           scatcross = appData.consts.scatcross0 * 1/(1+(appData.options.detuning*1e6*2/appData.consts.linew)^2); 
           atomsNo = round(appData.data.camera.xPixSz * appData.data.camera.yPixSz * sum(sum(normalizedROI)) / scatcross);   
       end
   end
end 
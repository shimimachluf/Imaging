function savedData = createSavedData(appData)
savedData.consts = appData.consts;
savedData.data = appData.data;
savedData.options = appData.options;
savedData.save = appData.save;

% if ( appData.analyze.isReadPic == 0 )
%     savedData.data.picNo = appData.save.picNo;
%     savedData.data.saveParam = appData.save.saveParam;
%     savedData.data.saveParamVal = appData.save.saveParamVal;
% else
%     savedData.data.picNo = appData.data.picNo;
%     savedData.data.saveParam = appData.data.saveParam;
%     savedData.data.saveParamVal = appData.data.saveParamVal;
% end

savedData.atoms = uint16(savedData.data.plots{appData.consts.plotTypes.withAtoms}.getPic());
savedData.back = uint16(savedData.data.plots{appData.consts.plotTypes.withoutAtoms}.getPic());
savedData.dark = uint16(savedData.data.plots{appData.consts.plotTypes.dark}.getPic());
savedData.data.plots = [];

% savedData.refImagesBinv = appData.analyze.refImagesBinv;
% savedData.refImagesR = appData.analyze.refImagesR;
% savedData.backgroundMask = appData.analyze.backgroundMask;
savedData.refImagesFolder = appData.analyze.refImagesFolder;
savedData.refImagesNums = appData.analyze.refImagesNums;
end

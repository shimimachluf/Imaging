function newAppData = createAppData(savedData, appData) 
    newAppData = appData;
%     if ( isfield(appData, 'oldAppData') )
%         newAppData.oldAppData = appData.oldAppData;
%     else
%         newAppData.oldAppData = appData;
%     end

%     newAppData.consts = savedData.consts;
    newAppData.data = savedData.data;
    newAppData.options = savedData.options;
    newAppData.options.doPlot = 1;
    newAppData.save = savedData.save; 
    
    %
    % Create absorption image
    %
    atoms = double(savedData.atoms);
    back = double(savedData.back);
    dark = double(savedData.dark);
   

    atoms2 = atoms;%- dark;                                           % subtract the dark background from the atom pic
    atoms2 = atoms2 .* ( ~(atoms2<0));                               % set all pixelvalues<0 to 0
    
    % fringe removal
%     load('/Users/ShimonMachluf/Documents/MATLAB/imaging/refimages.mat');
%     load('/Users/ShimonMachluf/Documents/MATLAB/imaging/bgmask.mat');
%     back = fringeremoval({atoms}, refimages, bgmask, 'svd');
    
%     back2 =  back - dark;                                            % subtract the dark background from the background pic
%     back2 = back2 .* ( ~(back2<0));                                  % set all pixelvalues<0 to 0
    % do fringe removal
    switch appData.options.plotSetting
        case appData.consts.plotSetting.defaults % saved settings
%             appData.options.doFR = newAppData.options.doFR;
            set(newAppData.ui.cbDoFR, 'Value', newAppData.options.doFR);
        case appData.consts.plotSetting.last
            newAppData.options.doFR = get(newAppData.ui.cbDoFR, 'Value');
    end
    if appData.options.plotSetting == appData.consts.plotSetting.last && ...
            appData.options.doFR && ~isempty(newAppData.analyze.refImagesBinv)
        if numel(newAppData.analyze.backgroundMask) ~= numel(atoms2)
            errordlg('Fringe Removal: different num elements', 'error', 'modal');
            backRef = back;%true(size(back));
            back2 = back - dark;% subtract the dark background from the background pic
            back2 = back2 .* ( ~(back2<0));
            atoms2 = atoms - dark;                                           % subtract the dark background from the atom pic
            atoms2 = atoms2 .* ( ~(atoms2<0));
        else
%             if isfield(savedData, 'refImagesBinv')
%                 newAppData.analyze.refImagesBinv = savedData.refImagesBinv;
%                 newAppData.analyze.refImagesR = savedData.refImagesR;
%                 newAppData.analyze.backgroundMask = savedData.backgroundMask;
%                 newAppData.analyze.refImagesFolder = savedData.refImagesFolder;
%                 newAppData.analyze.refImagesNums = savedData.refImagesNums;
%             else
                newAppData.analyze.refImagesBinv = appData.analyze.refImagesBinv;
                newAppData.analyze.refImagesR = appData.analyze.refImagesR;
                newAppData.analyze.backgroundMask = appData.analyze.backgroundMask;
                newAppData.analyze.refImagesFolder = appData.analyze.refImagesFolder;
                newAppData.analyze.refImagesNums = appData.analyze.refImagesNums;
                newAppData.analyze.refImages = [];%appData.analyze.refImages;
%             end
            
            A = double(reshape(atoms2,...(:)-dark(:),
                numel(newAppData.analyze.backgroundMask),1));
            %         k = find(appData.analyze.backgroundMask(:)==1);
            coeff = newAppData.analyze.refImagesBinv*A(newAppData.analyze.backgroundMask(:));
            backRef = reshape(newAppData.analyze.refImagesR*(coeff),size(newAppData.analyze.backgroundMask));
            %         back1 = fringeremoval(back - dark, appData.analyze.refImagesBinv, appData.analyze.backgroundMask, 'svd');
            back2 = backRef;% - dark;% subtract the dark background from the background pic
            back2 = back2 .* ( ~(back2<0));
            
            
%             absorption = log( (back2 + 1)./ (atoms2 + 1)  );
%             coeff = coeff*(1-mean(absorption(newAppData.analyze.backgroundMask(:))));
%             backRef = reshape(newAppData.analyze.refImagesR*coeff,size(newAppData.analyze.backgroundMask));
%             back2 = backRef;
%             back2 = back2 .* ( ~(back2<0));

%             firstGuess = coeff;
%             for i = 1 : size(appData.analyze.refImages,1)
%                 refIm(:,:,i) = appData.analyze.backgroundMask .* ...
%                     squeeze(appData.analyze.refImages(i,:,:));
%             end
%             [fitRes, fval, exitflag, output] = ...
%                 fminsearch_1(@(p) fitFR_scalar(p, refIm, atoms2, appData.analyze.backgroundMask), ...
%                 firstGuess, optimset('TolFun',sum(sum(appData.analyze.backgroundMask))*0.5e-4, 'TolX', 1) );
%             
%             coeff = fitRes;
%             backRef = reshape(appData.analyze.refImagesR*(coeff),size(appData.analyze.backgroundMask));
%             back2 = backRef;% - appData.data.plots{appData.consts.plotTypes.dark}.pic;% subtract the dark background from the background pic
%             back2 = back2 .* ( ~(back2<0));
            
        end
    else
        backRef = back;
        back2 =  back - dark;
        back2 = back2 .* ( ~(back2<0));
        atoms2 = atoms - dark;                                           % subtract the dark background from the atom pic
        atoms2 = atoms2 .* ( ~(atoms2<0));
    end         
    absorption = log( (back2 + 1)./ (atoms2 + 1)  );
    
    newAppData.data.plots = newAppData.consts.plotTypes.plots;
    newAppData = newAppData.data.plots{newAppData.consts.plotTypes.withAtoms}.setPic(newAppData, atoms);
    newAppData = newAppData.data.plots{newAppData.consts.plotTypes.withoutAtoms}.setPic(newAppData, back);
    newAppData = newAppData.data.plots{newAppData.consts.plotTypes.FR}.setPic(newAppData, backRef);
    newAppData = newAppData.data.plots{newAppData.consts.plotTypes.absorption}.setPic(newAppData, absorption);
    newAppData = newAppData.data.plots{newAppData.consts.plotTypes.dark}.setPic(newAppData, dark);
%     newAppData = newAppData.data.plots{newAppData.consts.plotTypes.ROI}.setPic(newAppData, absorption);

    %
    % Set Pic data in the figure
    %
    
    % TODO: add option for saved or previos plot settings
    if ~isfield(appData.consts, 'plotSetting')
        appData.options.plotSetting = get(newAppData.ui.pmPlotSetting, 'Value');
        appData.consts.plotSetting.str = {'Default Setting', 'Last Setting'};
        appData.consts.plotSetting.defaults = 1;
        appData.consts.plotSetting.last = 2;
        appData.consts.plotSetting.default = 2;
    end
    switch appData.options.plotSetting
        case appData.consts.plotSetting.defaults % saved settings
            set(newAppData.ui.pmFitType, 'Value', newAppData.data.fitType);
            set(newAppData.ui.pmPlotType, 'Value', newAppData.data.plotType);
            set(newAppData.ui.pmROIUnits, 'Value', newAppData.data.ROIUnits);
            set(newAppData.ui.etROISizeX, 'String', num2str(newAppData.data.ROISizeX));
            set(newAppData.ui.etROISizeY, 'String', num2str(newAppData.data.ROISizeY));
            set(newAppData.ui.etROICenterX, 'String', num2str(newAppData.data.ROICenterX));
            set(newAppData.ui.etROICenterY, 'String', num2str(newAppData.data.ROICenterY));
            
            set(newAppData.ui.etCenterX, 'String', num2str(newAppData.data.mouseCenterX));
            set(newAppData.ui.etCenterY, 'String', num2str(newAppData.data.mouseCenterY));
            set(newAppData.ui.cbPlotCursor, 'Value', newAppData.data.fPlotMouseCursor);
            
            set(newAppData.ui.pmCalcAtomsNo, 'Value', newAppData.options.calcAtomsNo);
            set(newAppData.ui.etAvgWidth, 'String', num2str(newAppData.options.avgWidth));
            set(newAppData.ui.etMaxVal, 'String', num2str(newAppData.options.maxVal));

%             set(newAppData.ui.etSaveDir, 'String', newAppData.save.saveDir);
            
        case appData.consts.plotSetting.last
            newAppData.data.fitType = get(newAppData.ui.pmFitType, 'Value');
            newAppData.data.plotType = get(newAppData.ui.pmPlotType, 'Value');
            newAppData.data.ROIUnits = get(newAppData.ui.pmROIUnits, 'Value');
            newAppData.data.ROISizeX = str2double(get(newAppData.ui.etROISizeX, 'String'));
            newAppData.data.ROISizeY = str2double(get(newAppData.ui.etROISizeY, 'String'));
            newAppData.data.ROICenterX = str2double(get(newAppData.ui.etROICenterX, 'String'));
            newAppData.data.ROICenterY = str2double(get(newAppData.ui.etROICenterY, 'String'));
            
            newAppData.data.mouseCenterX = str2double(get(newAppData.ui.etCenterX, 'String'));
            newAppData.data.mouseCenterY = str2double(get(newAppData.ui.etCenterY, 'String'));
            newAppData.data.fPlotMouseCursor = get(newAppData.ui.cbPlotCursor, 'Value');

            newAppData.options.calcAtomsNo = get(newAppData.ui.pmCalcAtomsNo, 'Value');
            newAppData.options.avgWidth = str2double(get(newAppData.ui.etAvgWidth, 'String'));
            newAppData.options.maxVal = str2double(get(newAppData.ui.etMaxVal, 'String'));
            
            newAppData.data.fits = appData.consts.fitTypes.fits;

            newAppData.save.saveDir = get(newAppData.ui.etSaveDir, 'String');

    end
    tmpPlotType = newAppData.data.plotType;
    newAppData.data.plotType = newAppData.consts.plotTypes.absorption;
    newAppData = newAppData.data.plots{newAppData.consts.plotTypes.ROI}.setPic(newAppData, absorption);
    newAppData.data.plotType = tmpPlotType;
%     newAppData = newAppData.data.plots{newAppData.consts.plotTypes.ROI}.setPic(newAppData, absorption);
    
    set(newAppData.ui.pmCameraType, 'Value', newAppData.options.cameraType);
    set(newAppData.ui.etDetuning, 'String', num2str(newAppData.options.detuning));
    set(newAppData.ui.etAvgWidth, 'String', num2str(newAppData.options.avgWidth));
    newAppData.options.plotSetting = appData.options.plotSetting;
    set(newAppData.ui.pmPlotSetting, 'Value', newAppData.options.plotSetting);

    set(newAppData.ui.etSaveDir, 'String', newAppData.save.saveDir);
    set(newAppData.ui.etComment, 'String', newAppData.save.commentStr(2:end));
    set(newAppData.ui.etPicNo, 'String', num2str(newAppData.save.picNo));
    newAppData.save.isSave = appData.save.isSave;
    set(newAppData.ui.tbSave, 'Value', newAppData.save.isSave);
    set(newAppData.ui.pmSaveParam, 'Value', newAppData.save.saveParam);
    if ~isempty(newAppData.save.saveOtherParamStr)
        set(newAppData.ui.pmSaveParam, 'String', {['O.P. - ' newAppData.save.saveOtherParamStr{:}] ...
            newAppData.consts.saveParams.str{2:end}});
    else
        set(newAppData.ui.pmSaveParam, 'String', newAppData.consts.saveParams.str);
    end
    set(newAppData.ui.etParamVal, 'String', num2str(newAppData.save.saveParamVal));

    newAppData.consts.winName = appData.consts.winName;
    set(appData.ui.win, 'Name', [newAppData.consts.winName num2str(newAppData.save.picNo) newAppData.save.commentStr]);
    
    newAppData.consts.runVer = 'offline';
end

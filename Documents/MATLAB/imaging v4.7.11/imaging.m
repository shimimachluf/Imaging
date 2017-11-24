
function imaging(runVer)

if nargin == 0
    imaging('offline');
    imaging('online');%, 'noFTP');
    return
end
% if nargin == 1 
%     if (strcmp(runVer, 'FTP') || strcmp(runVer, 'FTP') )
%         imaging('offline', runVer);
%         imaging('online', runVer);
%     else
%         imaging(runVer, 'FTP');
%     end
%     return
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defining consts
%
appData.consts.vertion = '4.7.11';
appData.consts. saveVersion = '-v7';
appData.consts.runVer = runVer;

if strcmp(computer, 'MACI64')
    appData.slash = '/';
else
    appData.slash = '\';
end

appData.consts.Mrb = 1.44e-25; 
appData.consts.Kb = 1.38e-23; 
% appData.consts.detun = 1e6;%          %  off resonance detuning
appData.consts.wavelength = 780e-9;                      %  [m]
appData.consts.linew = 6.065e6;%     %  [Hz]   
                                                    % line width of the Rb87 cooling transition: Lambda = 2*pi*linew
appData.consts.scatcross0 = 3*appData.consts.wavelength^2/2/pi;   % scattering cross section for Rb87 in m^2
% appData.consts.scatcross = appData.consts.scatcross0;      %  resonant imaging 
% appData.consts.defaultDetuning = 0;
% consts.scatcross = scatcross0 * 1/(1+(detun*2/linew)^2);   % off resonance scattering cross section


appData.consts.winName = 'Imaging Analysis: Picture ';% num2str(handles.data.num)];
appData.consts.screenWidth = 1280;%1400;%1280;
appData.consts.screenHeight = 800;%780;
appData.consts.strHeight = 20;
appData.consts.fontSize = 10;
appData.consts.fontSizeResults = 12;
appData.consts.fontSizeResultsLarge = 20;
appData.consts.componentHeight = 22;
appData.consts.folderIcon = imread('folder28.bmp');

% height dependent plot
appData.consts.maxplotSize = round(appData.consts.screenHeight*0.75);
appData.consts.xyPlotsHeight = round(appData.consts.screenHeight-(5+appData.consts.maxplotSize+appData.consts.strHeight*2.5));
%Width dependent plot
% appData.consts.maxplotSize = appData.consts.screenWidth-140;%round(appData.consts.screenWidth*0.5);
% appData.consts.maxplotSizeH = appData.consts.screenHeight-310-140-(5+appData.consts.strHeight*2);
% appData.consts.xyPlotsHeight = round(appData.consts.screenWidth-500-(5+appData.consts.maxplotSize+appData.consts.strHeight*2.5));
% appData.consts.xyPlotsHeight = 140;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create consts
appData = createConsts(appData);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defining data
%

appData.data.isRun = 0;
appData.data.date = datestr(now);
appData.data.fitType = appData.consts.fitTypes.default;
appData.data.fits = appData.consts.fitTypes.fits;
appData.data.plotType = appData.consts.plotTypes.default;
appData.data.plots = appData.consts.plotTypes.plots;

appData.data.ROIUnits = appData.consts.ROIUnits.default;
appData.data.ROITypes = appData.consts.ROIUnits.ROITypes;
appData.data.ROISizeX = appData.consts.ROIUnits.defaultSizeX;
appData.data.ROISizeY = appData.consts.ROIUnits.defaultSizeY;
appData.data.ROICenterX = appData.consts.ROIUnits.defaultCenX;
appData.data.ROICenterY = appData.consts.ROIUnits.defaultCenY;

appData.data.mouseCenterX = 0;
appData.data.mouseCenterY = 0;
appData.data.fPlotMouseCursor = 1;

appData.data.xPosMaxBack = 0;
appData.data.yPosMaxBack = 0;

appData.data.camera = appData.consts.cameras{appData.consts.cameraTypes.default};%{appData.data.cameraType};
appData.data.plotWidth = round(appData.consts.maxplotSize*(appData.data.camera.width / appData.data.camera.height));
appData.data.plotHeight = appData.consts.maxplotSize;
if ( appData.data.plotWidth > appData.consts.maxplotSize )
    appData.data.plotWidth = appData.consts.maxplotSize;
    appData.data.plotHeight = round(appData.consts.maxplotSize*( appData.data.camera.height / appData.data.camera.width));
end

appData.options.calcAtomsNo = appData.consts.calcAtomsNo.default;
appData.options.calcs = appData.consts.calcAtomsNo.calcs;
appData.options.plotSetting = appData.consts.plotSetting.default;
appData.options.cameraType = appData.consts.cameraTypes.default;
appData.options.avgWidth = appData.consts.defaultAvgWidth;
appData.options.detuning = appData.consts.defaultDetuning;
appData.options.doPlot = appData.consts.defaultDoPlot;
appData.options.doFR = 0;
appData.options.maxVal = 0;

if strcmp(runVer, 'online')
    appData.save.defaultDir = [appData.save.defaultDir datestr(now,'yyyy-mm-dd ddd')];%'C:\Documents and Settings\broot\Desktop\shimi';
    [status,message,messageid] = mkdir(appData.save.defaultDir); %#ok<NASGU>
end
appData.save.saveDir=appData.save.defaultDir;
appData.save.saveParam = appData.consts.saveParams.default;
appData.save.saveParamVal = appData.consts.saveParamValDefault;
appData.save.saveOtherParamStr = appData.consts.saveOtherParamStr;
appData.save.commentStr = appData.consts.commentStr;
appData.save.isSave = 0;
appData.save.picNo = 1;

appData.loop.isLoop = 0;
appData.loop.measurementsList = {};
appData.loop.measurements = [];
appData.loop.fFirstMeas = 1;

appData.monitoring.currentMonitoring = [];
appData.monitoring.onlySavedPics = 0;
appData.monitoring.isMonitoring = 1;
appData.monitoring.monitoringData = zeros(0, length(appData.consts.availableMonitoring.str));

appData.analyze.currentAnalyzing = [];
appData.analyze.showPicNo = 1;
appData.analyze.isReadPic = 0;
appData.analyze.readDir = appData.save.defaultDir;
appData.analyze.totAppData = 0;
% appData.analyze.refImages = {};
appData.analyze.refImagesBinv = [];
appData.analyze.refImagesR = [];
appData.analyze.backgroundMask = [];
appData.analyze.refImagesFolder = '';
appData.analyze.refImagesNums = [];
% persistent refImagesBinv;
% persistent refImagesR;
% persistent backgroundMask;
% persistent refImagesFolder;
% persistent refImagesNums;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% defining components
%

appData.ui.win = figure('Visible', 'off', ...
    'Name', appData.consts.winName, ...
    'Units', 'Pixels', ...
    'Position', [appData.consts.winXPos appData.consts.winYPos appData.consts.screenWidth appData.consts.screenHeight], ...
    'Resize', 'on', ...
    'MenuBar', 'None', ...
    'Toolbar', 'None', ...
    'NumberTitle', 'off' , ...
    'color', 'white', ...
    'HandleVisibility', 'callback');%, ...
%      'DeleteFcn', {@closewin_Callback},...
%     'ResizeFcn', @win_resize);

% creating axes
%%%%%%%%
appData.ui.plot = axes('Parent', appData.ui.win, ...
    'Units', 'pixels', ...
    'Position', [5 5 appData.data.plotWidth appData.data.plotHeight], ...
    'HandleVisibility', 'callback', ...
    'XAxisLocation', 'top', ...
    'YAxisLocation', 'right');
appData.ui.xPlot = axes('Parent', appData.ui.win, ...
    'Units', 'pixels', ...
    'Position', [5 5+appData.data.plotHeight+appData.consts.strHeight appData.data.plotWidth appData.consts.xyPlotsHeight], ...
    'HandleVisibility', 'callback', ...
    'XTickLabel', '', ...
    'XAxisLocation', 'top', ...
    'YAxisLocation', 'right');
xlabel(appData.ui.xPlot, 'Distance [mm]', 'FontSize', appData.consts.fontSize);
ylabel(appData.ui.xPlot, 'Optical Density', 'FontSize', appData.consts.fontSize);
appData.ui.yPlot = axes('Parent', appData.ui.win, ...
    'Units', 'pixels', ...
    'Position', [5+appData.data.plotWidth+appData.consts.strHeight 5 appData.consts.xyPlotsHeight appData.data.plotHeight], ...
    'HandleVisibility', 'callback', ...
    'YTickLabel', '', ...
    'XAxisLocation', 'top', ...
    'YAxisLocation', 'right');
ylabel(appData.ui.yPlot, 'Distance [mm]', 'FontSize', appData.consts.fontSize);
xlabel(appData.ui.yPlot, 'Optical Density', 'FontSize', appData.consts.fontSize);

% creating panel - Plotting and Fitting
%%%%%%%%%%%%%%%%%%%%

appData.ui.pPlotFit = uipanel('Parent', appData.ui.win, ...
    'Title', 'Plotting and Fitting', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [640 630 225 150], ... %[5 appData.consts.screenHeight-300 225 150], ...%[640 630 225 150], ... 
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);

appData.ui.st11 = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'text', ...
    'String', 'ROI Size:', ...
    'Units', 'pixels', ...
    'Position', [5 5 80 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etROISizeX = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'edit', ...
    'String', num2str(appData.data.ROISizeX), ...
    'Units', 'pixels', ...
    'Position', [80 5 30 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etROISizeX_Callback}); 
appData.ui.etROISizeY = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'edit', ...
    'String', num2str(appData.data.ROISizeY), ...
    'Units', 'pixels', ...
    'Position', [110 5 30 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etROISizeY_Callback}); 
appData.ui.etROICenterX = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'edit', ...
    'String', num2str(appData.data.ROICenterX), ...
    'Units', 'pixels', ...
    'Position', [140 5 40 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etROICenterX_Callback}); 
appData.ui.etROICenterY = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'edit', ...
    'String', num2str(appData.data.ROICenterY), ...
    'Units', 'pixels', ...
    'Position', [180 5 40 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etROICenterY_Callback}); 

appData.ui.st12 = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'text', ...
    'String', 'ROI Units:', ...
    'Units', 'pixels', ...
    'Position', [5 40 80 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.pmROIUnits = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.ROIUnits.str, ...
    'Value', appData.data.ROIUnits, ...
    'Units', 'pixels', ...
    'Position', [80 45  140 20], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmROIUnits_Callback}); 

appData.ui.st13 = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'text', ...
    'String', 'Plot Type:', ...
    'Units', 'pixels', ...
    'Position', [5 70 80 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.pmPlotType = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.plotTypes.str, ...
    'Value', appData.data.plotType, ...
    'Units', 'pixels', ...
    'Position', [80 75  140 appData.consts.componentHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmPlotType_Callback}); 

appData.ui.st14 = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'text', ...
    'String', 'Fit Type:', ...
    'Units', 'pixels', ...
    'Position', [5 100 80 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.pmFitType = uicontrol(appData.ui.pPlotFit, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.fitTypes.str, ...
    'Value', appData.data.fitType, ...
    'Units', 'pixels', ...
    'Position', [80 105  140 appData.consts.componentHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmFitType_Callback}); 

% creating panel - mouse controls
%%%%%%%%%%%%%%%%%%%%

appData.ui.pMouse = uipanel('Parent', appData.ui.win, ...
    'Title', 'Mouse Controls', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [790 535 175 90], ...%[410 appData.consts.screenHeight-145-90 175 90], ...%[790 535 175 90], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);

appData.ui.etCenterX = uicontrol(appData.ui.pMouse, ...
    'Style', 'edit', ...
    'String', num2str(appData.data.mouseCenterX), ...
    'Units', 'pixels', ...
    'Position', [5 5 40 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etCenterX_Callback}); 
appData.ui.etCenterY = uicontrol(appData.ui.pMouse, ...
    'Style', 'edit', ...
    'String', num2str(appData.data.mouseCenterY), ...
    'Units', 'pixels', ...
    'Position', [45 5 40 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etCenterY_Callback}); 
appData.ui.cbPlotCursor = uicontrol(appData.ui.pMouse, ...  
    'Style', 'checkbox', ...
    'String', 'Plot Cursor', ...
    'Max', 1, ...
    'Min', 0, ...
    'Value', appData.data.fPlotMouseCursor, ...
    'Units', 'pixels', ...
    'Position', [90 5 80 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
     'Callback', {@cbPlotCursor_Callback});

appData.ui.pbSetCenter = uicontrol(appData.ui.pMouse, ...
    'Style', 'pushbutton', ...
    'String', 'Set Center', ...
    'Units', 'pixels', ...
    'Position', [5 35 80 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbSetCenter_Callback});
appData.ui.tbSetROI = uicontrol(appData.ui.pMouse, ...
    'Style', 'togglebutton', ...
    'Value', 0, ...
    'String', 'Set ROI', ...
    'Units', 'pixels', ...
    'Position', [90 35 80 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbSetROI_Callback});

% creating panel - Timeframe
%%%%%%%%%%%%%%%%%%%%

appData.ui.pTimeframe = uipanel('Parent', appData.ui.win, ...
    'Title', 'Timeframe', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [965 535 130 90], ...%[410+175 appData.consts.screenHeight-145-90 130 90], ...%[965 535 130 90], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);

% appData.ui.pbOpenTF = uicontrol(appData.ui.pTimeframe, ...
%     'Style', 'pushbutton', ...
%     'String', 'Open Timeframe', ...
%     'Units', 'pixels', ...
%     'Position', [5 5 100 25], ...
%     'BackgroundColor', [0.8 0.8 0.8], ...
%     'FontSize', appData.consts.fontSize, ...    
%     'Callback', {@pbOpenTF_Callback});

% creating panel - Options
%%%%%%%%%%%%%%%%%%%%

appData.ui.pOption = uipanel('Parent', appData.ui.win, ...
    'Title', 'Options', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [780+140 550-90 355 75], ...%[405+5 appData.consts.screenHeight-145-90-75 355 75], ...%[780+140 550-90 355 75], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);


appData.ui.pmCalcAtomsNo = uicontrol(appData.ui.pOption, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.calcAtomsNo.str, ...
    'Value', appData.options.calcAtomsNo, ...
    'Units', 'pixels', ...
    'Position', [5 5 90 appData.consts.componentHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmCalcAtomsNo_Callback}); 
appData.ui.tbReanalyze = uicontrol(appData.ui.pOption, ...
    'Style', 'togglebutton', ...
    'String', 'Re-Analyze', ...
    'Units', 'pixels', ...
    'Position', [90 5 80 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@tbReanalyze_Callback}); 
appData.ui.pmPlotSetting = uicontrol(appData.ui.pOption, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.plotSetting.str, ...
    'Value', appData.options.plotSetting, ...
    'Units', 'pixels', ...
    'Position', [165 5 100 appData.consts.componentHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmPlotSetting_Callback}); 
appData.ui.pmCameraType = uicontrol(appData.ui.pOption, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.cameraTypes.str, ...
    'Value', appData.options.cameraType, ...
    'Units', 'pixels', ...
    'Position', [255 5 100 appData.consts.componentHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmCameraType_Callback}); 


appData.ui.st21 = uicontrol(appData.ui.pOption, ...
    'Style', 'text', ...
    'String', {'Detuning' '(MHz):'}, ...
    'Units', 'pixels', ...
    'Position', [5 35 50 appData.consts.componentHeight*1.25], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etDetuning = uicontrol(appData.ui.pOption, ...
    'Style', 'edit', ...
    'String', num2str(appData.options.detuning), ...
    'Units', 'pixels', ...
    'Position', [55 35 35 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etDetuning_Callback}); 
appData.ui.st22 = uicontrol(appData.ui.pOption, ...
    'Style', 'text', ...
    'String', {'Avg. Width' '(half):'}, ...
    'Units', 'pixels', ...
    'Position', [95 35 60 appData.consts.componentHeight*1.25], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etAvgWidth = uicontrol(appData.ui.pOption, ...
    'Style', 'edit', ...
    'String', num2str(appData.options.avgWidth), ...
    'Units', 'pixels', ...
    'Position', [155 35 35 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etAvgWidth_Callback}); 
appData.ui.cbDoPlot = uicontrol(appData.ui.pOption, ...
    'Style', 'checkbox', ...
    'String', 'Update plots', ...
    'Max', 1, ...
    'Min', 0, ...
    'Value', appData.options.doPlot, ...
    'Units', 'pixels', ...
    'Position', [190 45 100 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
     'Callback', {@cbDoPlot_Callback});
 appData.ui.cbDoFR = uicontrol(appData.ui.pOption, ...
    'Style', 'checkbox', ...
    'String', 'Do FR', ...
    'Max', 1, ...
    'Min', 0, ...
    'Value', appData.options.doFR, ...
    'Units', 'pixels', ...
    'Position', [190 25 60 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
     'Callback', {@cbDoFR_Callback});
 appData.ui.pbLoadFR = uicontrol(appData.ui.pOption, ...
    'Style', 'pushbutton', ...
    'String', 'Load FR', ...
    'Units', 'pixels', ...
    'Position', [250 25 50 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbLoadFR_Callback});
%  appData.ui.pbCompareFiles = uicontrol(appData.ui.pOption, ...
%     'Style', 'pushbutton', ...
%     'String', 'Compare', ...
%     'Units', 'pixels', ...
%     'Position', [285 35 65 appData.consts.componentHeight+5], ...
%     'BackgroundColor', [0.8 0.8 0.8], ...
%     'FontSize', appData.consts.fontSize, ...    
%     'Callback', {@pbCompareFiles_Callback}); 
appData.ui.st23 = uicontrol(appData.ui.pOption, ...
    'Style', 'text', ...
    'String', {'Max' 'Val'}, ...
    'Units', 'pixels', ...
    'Position', [300 35 40 appData.consts.componentHeight*1.25], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etMaxVal = uicontrol(appData.ui.pOption, ...
    'Style', 'edit', ...
    'String', num2str(appData.options.maxVal), ...
    'Units', 'pixels', ...
    'Position', [325 35 25 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etMaxVal_Callback}); 

% creating panel - Loop Options
%%%%%%%%%%%%%%%%%%%%%

appData.ui.pLoop = uipanel('Parent', appData.ui.win, ...
    'Title', 'Loop', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [790 95-90 485 85], ...%[405+485+5 appData.consts.screenHeight-220-85 485 85], ...%[790 95-90 485 85], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);


appData.ui.pmAvailableLoops = uicontrol(appData.ui.pLoop, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.availableLoops.str, ...
    'Value', 1, ...
    'Units', 'pixels', ...
    'Position', [5 13 130 20], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmAvailableLoops_Callback}); 

appData.ui.pbAddMeasurement = uicontrol(appData.ui.pLoop, ...
    'Style', 'pushbutton', ...
    'String', 'Add', ...
    'Units', 'pixels', ...
    'Position', [140 5 60 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'center', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pbAddMeasurement_Callback});  

appData.ui.lbMeasurementsList = uicontrol(appData.ui.pLoop, ...
    'Style', 'listbox', ...
    'String', '', ...
    'Min', 0, ...
    'Max', 1, ...
    'Units', 'pixels', ...
    'Position', [205 5 135 60], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'KeyPressFcn', {@lbMeasurementsList_KeyPressFcn});

appData.ui.tbLoop = uicontrol(appData.ui.pLoop, ...
    'Style', 'togglebutton', ...
    'String', 'Loop On/Off', ...
    'Value', appData.loop.isLoop, ...
    'Units', 'pixels', ...
    'Position', [350 10 125 50], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbLoop_Callback}); 


% creating panel - Save Options
%%%%%%%%%%%%%%%%%%%%%

appData.ui.pSave = uipanel('Parent', appData.ui.win, ...
    'Title', 'Save', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [790 180-90 485 145], ...%[410 appData.consts.screenHeight-145 485 145], ...%[790 180-90 485 145], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);

appData.ui.st41 = uicontrol(appData.ui.pSave, ...
    'Style', 'text', ...
    'String', 'Save Param:', ...
    'Units', 'pixels', ...
    'Position', [5 5 90 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.pmSaveParam = uicontrol(appData.ui.pSave, ...
    'Style', 'popupmenu', ...
    'String', appData.consts.saveParams.str, ...
    'Value', appData.save.saveParam, ...
    'Units', 'pixels', ...
    'Position', [105 10 90 appData.consts.componentHeight], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pmSaveParam_Callback}); 
appData.ui.st42 = uicontrol(appData.ui.pSave, ...
    'Style', 'text', ...
    'String', 'Param Val:', ...
    'Units', 'pixels', ...
    'Position', [200 5 90 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etParamVal = uicontrol(appData.ui.pSave, ...
    'Style', 'edit', ...
    'String', num2str(appData.save.saveParamVal), ...
    'Units', 'pixels', ...
    'Position', [275 5 65 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etParamVal_Callback});

appData.ui.st43 = uicontrol(appData.ui.pSave, ...
    'Style', 'text', ...
    'String', 'File Comment:', ...
    'Units', 'pixels', ...
    'Position', [5 35 100 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etComment = uicontrol(appData.ui.pSave, ...
    'Style', 'edit', ...
    'String', appData.consts.commentStr, ...
    'Units', 'pixels', ...
    'Position', [105 35 235 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etComment_Callback}); 

appData.ui.pbOpenSaveDir = uicontrol(appData.ui.pSave, ...
    'Style', 'pushbutton', ...
    'String', '', ...
    'Units', 'pixels', ...
    'Position', [5 65 30 30], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'CData', appData.consts.folderIcon, ...
    'Callback', {@pbOpenSaveDir_Callback}); 
appData.ui.st44 = uicontrol(appData.ui.pSave, ...
    'Style', 'text', ...
    'String', 'Pic. No.:', ...
    'Units', 'pixels', ...
    'Position', [40 65 60 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etPicNo = uicontrol(appData.ui.pSave, ...
    'Style', 'edit', ...
    'String', num2str(appData.save.picNo), ...
    'Units', 'pixels', ...
    'Position', [105 65 50 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etPicNo_Callback}); 
appData.ui.sPicNo = uicontrol(appData.ui.pSave, ...
    'Style', 'slider', ...
    'Max', 2, ...
    'Min', 0, ...
    'SliderStep', [0.5 0.5], ...
    'Value', 1, ...
    'Units', 'pixels', ...
    'Position', [155 65 20 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Callback', {@sPicNo_Callback}); 
appData.ui.pbSaveCurrent = uicontrol(appData.ui.pSave, ...
    'Style', 'pushbutton', ...
    'String', 'Save Current Pic.', ...
    'Units', 'pixels', ...
    'Position', [180 65 160 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'center', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@pbSaveCurrent_Callback});  

appData.ui.tbSave = uicontrol(appData.ui.pSave, ...
    'Style', 'togglebutton', ...
    'String', 'Save All', ...
    'Value', appData.save.isSave, ...
    'Units', 'pixels', ...
    'Position', [350 10 125 75], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbSave_Callback}); 

appData.ui.etSaveDir = uicontrol(appData.ui.pSave, ...
    'Style', 'edit', ...
    'String', appData.save.saveDir, ...
    'Units', 'pixels', ...
    'Position', [5 97 485-10 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etSaveDir_Callback}); 


% creating panel - Fit Results
%%%%%%%%%%%%%%%%%%%%

appData.ui.pFitResults = uipanel('Parent', appData.ui.win, ...
    'Title', 'Fit Results', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [790 325-90 485 220], ...%[405+485+5 appData.consts.screenHeight-220 485 220], ...%[790 325-90 485 220], ...% [790 325 485 305], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);
appData.ui.stFitResultsAtomNum = uibutton(appData.ui.pFitResults, ...
    'Style', 'text', ...
    'String', 'Atoms Num: 12,345,678*10^9', ...
    'Units', 'pixels', ...
    'Position', [5 175 475 25], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSizeResultsLarge);
appData.ui.stFitResultsFitFunction = uibutton(appData.ui.pFitResults, ...
    'Style', 'text', ...
    'String', {'Fit Function: '}, ...
    'Units', 'pixels', ...
    'Position', [5 125 475 45], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSizeResults);
appData.ui.stFitResults1 = uibutton(appData.ui.pFitResults, ...
    'Style', 'text', ...
    'String', '', ...
    'Units', 'pixels', ...
    'Position', [5 5 200 115], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSizeResults);
appData.ui.stFitResults2 = uibutton(appData.ui.pFitResults, ...
    'Style', 'text', ...
    'String', '', ...
    'Units', 'pixels', ...
    'Position', [210 5 270 115], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSizeResults);

% Run Button
%%%%%%%%%%%%%%%%%%%%
            
appData.ui.tbRun = uicontrol(appData.ui.win, ...
    'Style', 'togglebutton', ...
    'String', 'Run', ...
    'Value', appData.data.isRun, ...
    'Units', 'pixels', ...
    'Position', [790 550-90 125 75], ...%[405+355+5 appData.consts.screenHeight-145-90-75 125 75], ...%[790 550-90 125 75], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbRun_Callback});


% creating panel - Monitoring
%%%%%%%%%%%%%%%%%%%%

appData.ui.pMonitoring = uipanel('Parent', appData.ui.win, ...
    'Title', 'Monitoring', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [1095 535 180 90], ...% [410+175+130 appData.consts.screenHeight-145-90 180 90], ...%[1095 535 180 90], ...% [790 325 485 305], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);

appData.ui.lbAvailableMonitoring = uicontrol(appData.ui.pMonitoring, ...
    'Style', 'listbox', ...
    'String', appData.consts.availableMonitoring.str, ...
    'Max', length(appData.consts.availableMonitoring.str), ...
    'Value', appData.monitoring.currentMonitoring, ...
    'Units', 'pixels', ...
    'Position', [5 5 110 appData.consts.componentHeight*2+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@lbAvailableMonitoring_Callback}); 
appData.ui.cbOnlySavedPics = uicontrol(appData.ui.pMonitoring, ...
    'Style', 'checkbox', ...
    'String', 'Only Saved Pics', ...
    'Max', 1, ...
    'Min', 0, ...
    'Value', appData.monitoring.onlySavedPics, ...
    'Units', 'pixels', ...
    'Position', [5 55 110 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
     'Callback', {@cbOnlySavedPics_Callback});
appData.ui.tbMonitoringOnOff = uicontrol(appData.ui.pMonitoring, ...
    'Style', 'togglebutton', ...
    'String', 'On/Off', ...
    'Value', appData.monitoring.isMonitoring, ...
    'Units', 'pixels', ...
    'Position', [117 2 60 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbMonitoringOnOff_Callback}); 
appData.ui.pbMonitoringSave = uicontrol(appData.ui.pMonitoring, ...
    'Style', 'pushbutton', ...
    'String', 'Save', ...
    'Units', 'pixels', ...
    'Position', [120 30 55 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbMonitoringSave_Callback}); 
appData.ui.pbMonitoringShow = uicontrol(appData.ui.pMonitoring, ...
    'Style', 'pushbutton', ...
    'String', 'Show', ...
    'Units', 'pixels', ...
    'Position', [120 55 55 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbMonitoringShow_Callback}); 



% creating panel - Analyze Options
%%%%%%%%%%%%%%%%%%%%

appData.ui.pAnalyze = uipanel('Parent', appData.ui.win, ...
    'Title', 'Analyze Options', ...
    'TitlePosition', 'lefttop', ...
    'Units', 'pixels', ...
    'Position', [870 630 405 150], ...%[5 appData.consts.screenHeight-150 405 150], ...%[870 630 405 150], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize);

appData.ui.st81 = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'text', ...
    'String', {'Analyze' 'Data:'}, ...
    'Units', 'pixels', ...
    'Position', [5 5 55 appData.consts.componentHeight*2+15], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.lbAvailableAnalyzing = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'listbox', ...
    'String', appData.consts.availableAnalyzing.str, ...
    'Max', length(appData.consts.availableAnalyzing.str), ...
    'Value', appData.analyze.currentAnalyzing, ...
    'Units', 'pixels', ...
    'Position', [60 5 135 appData.consts.componentHeight*2+15], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@lbAvailableAnalyzing_Callback}); 
appData.ui.pbSaveToWorkspace = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'pushbutton', ...
    'String', 'Save to WS', ...
    'Units', 'pixels', ...
    'Position', [200 5 65 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbSaveToWorkspace_Callback}); 
appData.ui.pbClearFR = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'pushbutton', ...
    'String', 'Clear FR', ...
    'Units', 'pixels', ...
    'Position', [270 5 60 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbClearFR_Callback}); 
appData.ui.pbSaveFR = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'pushbutton', ...
    'String', 'Save FR', ...
    'Units', 'pixels', ...
    'Position', [335 5 65 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbSaveFR_Callback});
appData.ui.pbAnalyze = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'pushbutton', ...
    'String', 'Analyze', ...
    'Units', 'pixels', ...
    'Position', [200 35 65 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbAnalyze_Callback}); 
appData.ui.pbClearTotappData = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'pushbutton', ...
    'String', 'Clear Data', ...
    'Units', 'pixels', ...
    'Position', [270 35 60 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@pbClearTotAppData_Callback}); 
appData.ui.tbReadPics = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'togglebutton', ...
    'String', 'Read Pics', ...
    'Units', 'pixels', ...
    'Position', [335 35 65 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbReadPics_Callback}); 

appData.ui.st82 = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'text', ...
    'String', 'Pic No:', ...
    'Units', 'pixels', ...
    'Position', [5 65 50 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etShowPicNo = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'edit', ...
    'String', num2str(appData.analyze.showPicNo), ...
    'Units', 'pixels', ...
    'Position', [55 65 40 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etShowPicNo_Callback}); 
appData.ui.sShowPicNo = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'slider', ...
    'Max', 2, ...
    'Min', 0, ...
    'SliderStep', [0.5 0.5], ...
    'Value', 1, ...
    'Units', 'pixels', ...
    'Position', [90 65 20 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'Callback', {@sShowPicNo_Callback}); 
appData.ui.tbReadPic = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'togglebutton', ...
    'String', 'Read Pic', ...
    'Value', appData.analyze.isReadPic, ...
    'Units', 'pixels', ...
    'Position', [115 65 75 appData.consts.componentHeight+5], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'FontSize', appData.consts.fontSize, ...    
    'Callback', {@tbReadPic_Callback}); 
appData.ui.st83 = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'text', ...
    'String', 'Pics Nums:', ...
    'Units', 'pixels', ...
    'Position', [200 65 85 appData.consts.componentHeight], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize); 
appData.ui.etAnalyzePicNums = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'edit', ...
    'String', '', ...
    'Units', 'pixels', ...
    'Position', [280 65 120 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etAnalyzePicNums_Callback}); 



appData.ui.pbOpenReadDir = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'pushbutton', ...
    'String', '', ...
    'Units', 'pixels', ...
    'Position', [5 95 30 30], ...
    'BackgroundColor', [0.8 0.8 0.8], ...
    'CData', appData.consts.folderIcon, ...
    'Callback', {@pbOpenReadDir_Callback}); 
appData.ui.etReadDir = uicontrol(appData.ui.pAnalyze, ...
    'Style', 'edit', ...
    'String', appData.analyze.readDir, ...
    'Units', 'pixels', ...
    'Position', [40 97 360 appData.consts.componentHeight+5], ...
    'BackgroundColor', 'white', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', appData.consts.fontSize, ...
    'Callback', {@etReadDir_Callback}); 


%
% Create Timeframe
%
if strcmp(runVer, 'online')
    
    appData.consts.TF.winName = 'Timeframe';
    appData.consts.TF.winXPos = 0.10;
    appData.consts.TF.winYPos = 0.25;
    appData.consts.TF.screenWidth = 0.81;
    appData.consts.TF.screenHeight = 0.65;
    appData.consts.TF.comment = 1;
    appData.consts.TF.time = 2;
    appData.consts.TF.devices = 3;
    appData.consts.TF.value = 4;
    appData.consts.TF.units = 5;
    appData.consts.TF.functions = 6;
    appData.consts.TF.variable = 7;
    
    appData.consts.TF.fontSize = 10;
    appData.consts.TF.componentHeight = 22;
    
    appData.consts.TF.columnName = {[] 'Comment' 'Time' 'Device' 'Value' 'Unit' 'Function' 'Variable'};
    appData.consts.TF.colimnWidth = {25 200 100 150 150 100 100 150};
    
    appData.consts.TF.arbFuncStr = 'Arb. Func.';
    appData.consts.TF.emptyDeviceStr = 'Empty';
    appData.consts.TF.rampFuncStr = 'ramp';
%     appData.consts.TF.arbFunc_start = '-ArbFunc_start';
%     appData.consts.TF.arbFunc_end = '-ArbFunc_end';
   
    
    % application data
    
    appData.TF.data = [];
    appData.TF.lastData = [];
    appData.TF.firstData = [];
    appData.TF.tabNames = {};
    appData.TF.devices = {};
    appData.TF.functions = {};
    appData.TF.columnFormat = {'logical' 'char' 'char' appData.TF.devices 'char''char' appData.TF.functions 'char'};
    appData.TF.currentTab = 0;
    appData.TF.currentCell = [0 0];
    
    
    % local data
    mem = {};
    
    % create GUI
    
    appData.TFui.win = figure('Visible', 'off', ...
        'Name', appData.consts.TF.winName, ...
        'Units', 'normalized', ...
        'Position', [appData.consts.TF.winXPos appData.consts.TF.winYPos appData.consts.TF.screenWidth appData.consts.TF.screenHeight], ...
        'Resize', 'on', ...
        'MenuBar', 'None', ...
        'Toolbar', 'None', ...
        'NumberTitle', 'off' , ...
        'HandleVisibility', 'callback');
    
    appData.TFui.tgTimeframe = uitabgroup('Parent', appData.TFui.win, ...
        'Units', 'normalized', ...
        'Position', [0 0.05 1 0.95], ...
        'TabLocation', 'top', ...
        'SelectionChangedFcn', {@tgTimeframe_Callback});
    appData.TFui.tabArr = uitab('Parent', appData.TFui.tgTimeframe, ...
        'Title', 'Empty tab', ...
        'Units', 'normalized');%, ...
    %     'Position', [0 0 1 1]);
    appData.TFui.tblArr = uitable(appData.TFui.tabArr, ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'ColumnWidth', {25 100 'auto'}, ...
        'ColumnEditable', true, ...
        'CellEditCallback', {@tblArr_CellEditCallback});
    
    appData.TFui.pbLoadTF = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Load Timeframe', ...
        'Units', 'pixels', ...
        'Position', [5 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbLoadTF_Callback});
    appData.TFui.pbSaveTF = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Save Timeframe', ...
        'Units', 'pixels', ...
        'Position', [110 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbSaveTF_Callback});
    appData.TFui.pbSaveAsTF = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Save As...', ...
        'Units', 'pixels', ...
        'Position', [215 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbSaveTF_Callback});
    appData.TFui.pbRemoveTab = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Remove Tab', ...
        'Units', 'pixels', ...
        'Position', [320 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbRemoveTab_Callback});
    appData.TFui.pbAddTab = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Add Tab', ...
        'Units', 'pixels', ...
        'Position', [425 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbAddTab_Callback});
    appData.TFui.pbRemoveLine = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Remove Line', ...
        'Units', 'pixels', ...
        'Position', [530 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbRemoveLine_Callback});
    appData.TFui.pbAddLine = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Add Line', ...
        'Units', 'pixels', ...
        'Position', [635 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbAddLine_Callback});
    appData.TFui.pbCut = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Cut', ...
        'Units', 'pixels', ...
        'Position', [740 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbCut_Callback});
    appData.TFui.pbCopy = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Copy', ...
        'Units', 'pixels', ...
        'Position', [845 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbCopy_Callback});
    appData.TFui.pbPaste = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Paste', ...
        'Units', 'pixels', ...
        'Position', [950 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbPaste_Callback});
    appData.TFui.pbQuickLoop = uicontrol(appData.TFui.win, ...
        'Style', 'pushbutton', ...
        'String', 'Quick Loop', ...
        'Units', 'pixels', ...
        'Position', [1055 5 100 appData.consts.TF.componentHeight+5], ...
        'BackgroundColor', [0.8 0.8 0.8], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'Callback', {@pbQuickLoop_Callback});
end

% last commands
if strcmp(runVer, 'online')
    set(appData.ui.pAnalyze, 'Visible', 'off');
    appData.consts.winName = 'Imaging Analysis (Online): Picture ';
elseif strcmp(runVer, 'offline')
    set(appData.ui.tbRun, 'Visible', 'off');
    set(appData.ui.pLoop, 'Visible', 'off');
    set(appData.ui.pMonitoring, 'Visible', 'off');
    appData.consts.winName = 'Imaging Analysis (Offline): Picture ';
else
    errordlg('Function input incorrect', 'Error', 'modal');
    return
end
set(appData.ui.win, 'Name', appData.consts.winName);
set(appData.ui.win, 'Visible', 'on');
if strcmp(runVer, 'online')
    pbLoadTF_Callback(appData.TFui.pbLoadTF, []);
    set(appData.TFui.win, 'Visible', 'on');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callbacks
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbSetROI_Callback(object, eventdata) %#ok<INUSD>
    
    if ( get(object, 'Value') == 0 )
        return;
    end

    [x, y] = ginput(2);
    [pic, x0, y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
    [h, w] = size(pic);
    
    appData.data.ROISizeX = (diff(x)/2);
    appData.data.ROISizeY = (diff(y)/2);
    appData.data.ROICenterX = mean(x);
    appData.data.ROICenterY = mean(y);
    
    set(appData.ui.etROISizeX, 'String', num2str(appData.data.ROISizeX));
    set(appData.ui.etROISizeY, 'String', num2str(appData.data.ROISizeY));
    set(appData.ui.etROICenterX, 'String', num2str(appData.data.ROICenterX));
    set(appData.ui.etROICenterY, 'String', num2str(appData.data.ROICenterY));
    
%     appData.data.ROISizeX = sz;
    appData = updateROI(appData);
    onlyPlot(appData);
    
    set(object, 'Value', 0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbSetCenter_Callback(object, eventdata) %#ok<INUSD>

    [x, y] = ginput(1);
    
    [pic x0 y0] = appData.data.plots{appData.data.plotType}.getAnalysisPic(appData);
    [h w] = size(pic);
    appData.data.mouseCenterX = x;
    appData.data.mouseCenterY = y;
    
    set(appData.ui.etCenterX, 'String', num2str(appData.data.mouseCenterX));
    set(appData.ui.etCenterY, 'String', num2str(appData.data.mouseCenterY));
    
    onlyPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cbPlotCursor_Callback(object, eventdata) %#ok<INUSD>
    appData.data.fPlotMouseCursor = object.Value;
    onlyPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etCenterX_Callback(object, eventdata) %#ok<INUSD>
    sz = str2double(get(object, 'String'));
    if isnan(sz) || sz<= 0
        set(object, 'String', num2str(appData.data.ROISizeX));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.data.mouseCenterX = sz;
        onlyPlot(appData);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etCenterY_Callback(object, eventdata) %#ok<INUSD>
    sz = str2double(get(object, 'String'));
    if isnan(sz) || sz<= 0
        set(object, 'String', num2str(appData.data.ROISizeX));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.data.mouseCenterY = sz;
        onlyPlot(appData);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etROISizeX_Callback(object, eventdata) %#ok<*DEFNU,INUSD>
    sz = str2double(get(object, 'String'));
    if isnan(sz) || sz<= 0
        set(object, 'String', num2str(appData.data.ROISizeX));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.data.ROISizeX = sz;
        appData = updateROI(appData);
        onlyPlot(appData);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etROISizeY_Callback(object, eventdata) %#ok<INUSD>
    sz = str2double(get(object, 'String'));
    if isnan(sz) || sz<= 0
        set(object, 'String', num2str(appData.data.ROISizeY));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.data.ROISizeY = sz;
        appData = updateROI(appData);
        onlyPlot(appData);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etROICenterX_Callback(object, eventdata) %#ok<INUSD>
    sz = str2double(get(object, 'String'));
    if isnan(sz) || sz< 0
        set(object, 'String', num2str(appData.data.ROICenterX));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.data.ROICenterX = sz;
        appData = updateROI(appData);
        onlyPlot(appData);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etROICenterY_Callback(object, eventdata) %#ok<INUSD>
    sz = str2double(get(object, 'String'));
    if isnan(sz) || sz< 0
        set(object, 'String', num2str(appData.data.ROICenterY));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.data.ROICenterY = sz;
        appData = updateROI(appData);
        onlyPlot(appData);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmROIUnits_Callback(object, eventdata) %#ok<INUSD
    appData.data.ROIUnits = get(object, 'Value');
    appData = updateROI(appData);
    onlyPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmFitType_Callback(object, eventdata) %#ok<INUSD>    
    appData.data.fitType = get(object, 'Value');
    if ( appData.save.isSave == 1 )
        appData.save.picNo = appData.save.picNo - 1;
    end
    appData = analyzeAndPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmPlotType_Callback(object, eventdata) %#ok<INUSD>
    appData.data.plotType = get(object, 'Value');
    onlyPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmCalcAtomsNo_Callback(object, eventdata) %#ok<INUSD>
    appData.options.calcAtomsNo = get(object, 'Value');
    appData = updateROI(appData);
    onlyPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbReanalyze_Callback(object, eventdata) %#ok<INUSD>    
    if (get(object, 'Value') == 0)
        return
    end
    appData.data.fits = appData.consts.fitTypes.fits;
    if ( appData.save.isSave == 1 )
        appData.save.picNo = appData.save.picNo - 1;
    end
    appData = analyzeAndPlot(appData);
    set(object, 'Value', 0);
end

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmPlotSetting_Callback(object, eventdata) %#ok<INUSD>
    appData.options.plotSetting = get(object, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmCameraType_Callback(object, eventdata) %#ok<INUSD>
    appData.options.cameraType = get(object, 'Value');
    appData.data.camera = appData.consts.cameras{appData.options.cameraType};
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etDetuning_Callback(object, eventdata) %#ok<INUSD>
    det = str2double(get(object, 'String'));
    if isnan(det)
        set(object, 'String', num2str(appData.options.detuning));
        errordlg('Input must be a  number','Error', 'modal');
    else
        appData.options.detuning = det;
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etAvgWidth_Callback(object, eventdata) %#ok<INUSD>
    avg = str2double(get(object, 'String'));
    if isnan(avg) || avg < 0 || floor(avg) ~= avg  
        set(object, 'String', num2str(appData.options.avgWidth));
        errordlg('Input must be a positive integer','Error', 'modal');
    else
        appData.options.avgWidth = avg;
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cbDoPlot_Callback(object, eventdata) %#ok<INUSD>
    appData.options.doPlot = get(object, 'Value');
    if appData.options.doPlot == 1
        % Plot image and results
        onlyPlot(appData)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cbDoFR_Callback(object, eventdata) %#ok<INUSD>
    appData.options.doFR = get(object, 'Value');
    
    if appData.options.doFR && isempty(appData.analyze.refImagesBinv)
            errordlg('No reference images','Error', 'modal');
    end
    
    atoms = appData.data.plots{appData.consts.plotTypes.withAtoms}.pic;
    atoms1 = atoms;% - appData.data.plots{appData.consts.plotTypes.dark}.pic; % subtract the dark background from the atom pic
    atoms1 = atoms1 .* ( ~(atoms1<0));                                                   % set all pixelvalues<0 to 0
    
    % do fringe removal
    if appData.options.doFR && ~isempty(appData.analyze.refImagesBinv)
        if numel(appData.analyze.backgroundMask) ~= numel(atoms1)
            errordlg('Fringe Removal: different num elements', 'error', 'modal');
            backRef = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;%true(size(back));
            back1 = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic - ...
                appData.data.plots{appData.consts.plotTypes.dark}.pic;% subtract the dark background from the background pic
            back1 = back1 .* ( ~(back1<0));
            atoms1 = atoms - appData.data.plots{appData.consts.plotTypes.dark}.pic; % subtract the dark background from the atom pic
            atoms1 = atoms1 .* ( ~(atoms1<0));
        else
%             A = ones(sum(appData.analyze.backgroundMask(:)), 2);
%             A(:,2) = double(atoms1(appData.analyze.backgroundMask(:)));
%             coeff2 = appData.analyze.refImagesBinv*A;
%             backRef2 = reshape(ones(size(appData.analyze.refImagesR))*coeff2(:,1) ...
%                     + appData.analyze.refImagesR*coeff2(:,2), ...
%                 size(appData.analyze.backgroundMask));
            
%             atoms1 = atoms1+1e2;
            A = double(reshape(atoms1, ...(:)-appData.data.plots{appData.consts.plotTypes.dark}.pic(:), ...
                numel(appData.analyze.backgroundMask),1));
            coeff = appData.analyze.refImagesBinv*A(appData.analyze.backgroundMask(:));
            backRef = reshape(appData.analyze.refImagesR*(coeff),size(appData.analyze.backgroundMask));

            % LU decomposition
%             lower.LT = true; 
%             upper.UT = true;
%             b = appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:)' ...
%                 * A(appData.analyze.backgroundMask(:));
%             coeff = linsolve(appData.analyze.U,...
%                 linsolve(appData.analyze.L,b(appData.analyze.p,:),lower),upper);
%             backRef = reshape(appData.analyze.refImagesR*coeff,size(appData.analyze.backgroundMask));
            
            back1 = backRef;% - appData.data.plots{appData.consts.plotTypes.dark}.pic;% subtract the dark background from the background pic
            back1 = back1 .* ( ~(back1<0));
            
            absorption = log( (back1 + 1)./ (atoms1 + 1)  );
% %             coeff = coeff*(1-mean(absorption(appData.analyze.backgroundMask(:))));
% %             backRef = reshape(appData.analyze.refImagesR*coeff,size(appData.analyze.backgroundMask));
%             backRef = backRef*(1-mean(absorption(appData.analyze.backgroundMask(:))));
%             back1 = backRef;
%             back1 = back1 .* ( ~(back1<0));

            
%             firstGuess = coeff;
%             for i = 1 : size(appData.analyze.refImages,1)
%                 refIm(:,:,i) = appData.analyze.backgroundMask .* ...
%                     squeeze(appData.analyze.refImages(i,:,:));
%             end
%             [fitRes, fval, exitflag, output] = ...
%                 fminsearch_1(@(p) fitFR_scalar(p, refIm, atoms1, appData.analyze.backgroundMask), ...
%                 firstGuess, optimset('TolFun',sum(sum(appData.analyze.backgroundMask))*0.5e-4, 'TolX', 1) );
%             
%             coeff = fitRes;
%             backRef = reshape(appData.analyze.refImagesR*(coeff),size(appData.analyze.backgroundMask));
%             back1 = backRef;% - appData.data.plots{appData.consts.plotTypes.dark}.pic;% subtract the dark background from the background pic
%             back1 = back1 .* ( ~(back1<0));
        end
    else
        backRef = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;%true(size(back));
        back1 = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic - appData.data.plots{appData.consts.plotTypes.dark}.pic;% subtract the dark background from the background pic
        back1 = back1 .* ( ~(back1<0));
        atoms1 = atoms - appData.data.plots{appData.consts.plotTypes.dark}.pic; % subtract the dark background from the atom pic
        atoms1 = atoms1 .* ( ~(atoms1<0));
    end                                                     % set all pixelvalues<0 to 0
    absorption = log( (back1 + 1)./ (atoms1 + 1)  );% set all pixelvalues=0 to 1 and divide pics
%     absorption = log( (back1 + (back1==0))./ (atoms1 + (atoms1==0))  );
    
    appData = appData.data.plots{appData.consts.plotTypes.absorption}.setPic(appData, absorption);
    appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, absorption);
%     appData = appData.data.plots{appData.consts.plotTypes.withAtoms}.setPic(appData, atoms);
%     appData = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.setPic(appData, back);
    appData = appData.data.plots{appData.consts.plotTypes.FR}.setPic(appData, backRef);
%     appData = appData.data.plots{appData.consts.plotTypes.dark}.setPic(appData, dark);

    appData = analyzeAndPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbLoadFR_Callback(object, eventdata) %#ok<INUSD>
    [FileName,PathName,FilterIndex] = uigetfile([appData.save.saveDir appData.slash 'FR_Data.mat']);
    if FilterIndex == 0
        errordlg('No reference images','Error', 'modal');
    else
        load([PathName appData.slash FileName], 'refImagesBinv' , 'refImagesR', ...
            'backgroundMask', 'refImagesFolder', 'refImagesNums');
        appData.analyze.refImagesBinv = refImagesBinv;
        appData.analyze.refImagesR = refImagesR;
        appData.analyze.backgroundMask = backgroundMask;
        appData.analyze.refImagesFolder = refImagesFolder;
        appData.analyze.refImagesNums = refImagesNums;
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etMaxVal_Callback(object, eventdata) %#ok<INUSD>
    
    maxVal = str2double(get(object, 'String'));
    if isnan(maxVal) || maxVal < 0 
        set(object, 'String', num2str(appData.options.avgWidth));
        errordlg('Input must be a positive number','Error', 'modal');
    else
        appData.options.maxVal = maxVal;
        onlyPlot(appData);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmAvailableLoops_Callback(object, eventdata)  %#ok<INUSD>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbMeasurementsList_KeyPressFcn (object, eventdata)  %#ok<INUSL>
    val = get(appData.ui.lbMeasurementsList, 'Value');
    if isempty(val)
        return
    end
    switch(eventdata.Key)
        case 'return'
            meas = appData.loop.measurements{val}.edit(appData);
            appData.loop.measurements{val} = meas;  
        case 'removeFirst'
            set(appData.ui.lbMeasurementsList, 'Value', 1);
            appData.loop.measurementsList = get(appData.ui.lbMeasurementsList, 'String');
            appData.loop.measurementsList =  {appData.loop.measurementsList{2:end}}; %#ok<CCAT1>
            appData.loop.measurements = {appData.loop.measurements{2:end}}; %#ok<CCAT1>
            if val > length(appData.loop.measurementsList) && val > 1
                val = val-1;
            elseif isempty(appData.loop.measurementsList)
                val = [];
            end
            set(appData.ui.lbMeasurementsList, 'Value', val);
            set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
        case 'delete'
            appData.loop.measurementsList = get(appData.ui.lbMeasurementsList, 'String');
            appData.loop.measurementsList = {appData.loop.measurementsList{1:val-1} appData.loop.measurementsList{val+1:end}};
            appData.loop.measurements =  {appData.loop.measurements{1:val-1} appData.loop.measurements{val+1:end}};
            if val > length(appData.loop.measurementsList) && val > 1
                val = val-1;
            elseif isempty(appData.loop.measurementsList)
                val = [];
                set(appData.ui.tbLoop, 'Value', 0)
                tbLoop_Callback(appData.ui.tbLoop, []) ;
                appData.TF.data = appData.TF.firstData;
                pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
            end
            set(appData.ui.lbMeasurementsList, 'Value', val);
            set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbAddMeasurement_Callback(object, eventdata) %#ok<INUSD>
    appData.TF.firstData = appData.TF.data;

    val = get(appData.ui.pmAvailableLoops, 'Value');  
    h = appData.consts.availableLoops.createFncs{val};
    meas = h(appData);
    
    if isempty(meas) || meas.noIterations == -1
        return
    end
    appData.loop.measurements{length(appData.loop.measurements)+1} = meas;  
    
    appData.loop.measurementsList = get(appData.ui.lbMeasurementsList, 'String');
    appData.loop.measurementsList{length(appData.loop.measurementsList)+1} = meas.getMeasStr(appData);

    set(appData.ui.lbMeasurementsList, 'Value', 1);    
    set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbLoop_Callback(object, eventdata) 
    appData.loop.isLoop = get(object, 'Value');
    if ( appData.loop.isLoop == 0 )
        set(appData.ui.tbSave, 'Value', 0);
        tbSave_Callback(appData.ui.tbSave, eventdata)
        return
    end    
    if isempty(get(appData.ui.lbMeasurementsList, 'String'))
        warndlg('Measurements list is empty.', 'Warning', 'modal');
        set(appData.ui.tbLoop, 'Value', 0)
        tbLoop_Callback(object, eventdata);
        return
    end
    set(appData.ui.tbSave, 'Value', 1);
    tbSave_Callback(appData.ui.tbSave, eventdata);
    if appData.loop.measurements{1}.position == 0
        [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
        appData.loop.fFirstMeas = 1;
        pmSaveParam_Callback(appData.ui.pmSaveParam, []);
        etParamVal_Callback(appData.ui.etParamVal, []);
    end
    
    set(appData.ui.etSaveDir, 'String', appData.loop.measurements{1}.baseFolder);
    if isa(appData.loop.measurements{1}, 'QuickLoop')
        ed.Style = 'edit';
    elseif isa(appData.loop.measurements{1}, 'GeneralLoopTF')
        ed = [];
    else
        warndlg('Unrecognized Loop class.', 'Warning', 'modal');
        set(appData.ui.tbLoop, 'Value', 0)
        tbLoop_Callback(object, eventdata);
        return
    end
    etSaveDir_Callback(appData.ui.etSaveDir, ed);
    appData.loop.measurements{1}.baseFolder = appData.save.saveDir;
    pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
    appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
    set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pmSaveParam_Callback(object, eventdata) %#ok<INUSD>
    appData.save.saveParam = get(object, 'Value');
    otherParam = appData.consts.saveParams.otherParam;
    if ( appData.save.saveParam == otherParam )
        param = inputdlg('Enter param name:', 'Other param input');
        set(appData.ui.pmSaveParam, 'String', {appData.consts.saveParams.str{1:end-1} ['O.P. - ' param{1}]});
        appData.save.saveOtherParamStr = param;        
    else    
        set(appData.ui.pmSaveParam, 'String', appData.consts.saveParams.str);
        appData.save.saveOtherParamStr = appData.consts.saveOtherParamStr;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etParamVal_Callback(object, eventdata) %#ok<INUSD>
    val = str2double(get(object, 'String'));
    if isnan(val)
        set(object, 'String', num2str(appData.save.saveParamVal));
        errordlg('Input must be a number','Error', 'modal');
    else
        appData.save.saveParamVal = val;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etComment_Callback(object, eventdata) %#ok<INUSD>
    appData.save.commentStr = get(object, 'String');
    if ( ~isempty(appData.save.commentStr) )
        appData.save.commentStr = ['-' appData.save.commentStr];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbOpenSaveDir_Callback(object, eventdata)   %#ok<INUSL>
    dirName = uigetdir(get(appData.ui.etSaveDir, 'String'));
    if ( dirName ~= 0 )
        set(appData.ui.etSaveDir, 'String', dirName);
        etSaveDir_Callback(appData.ui.etSaveDir, []);%eventdata)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbSaveCurrent_Callback(object, eventdata) %#ok<INUSD>
    if ( appData.analyze.isReadPic == 1 )
        picNo = appData.save.picNo;
    elseif ( appData.save.isSave == 1 && appData.analyze.isReadPic == 0 )
        picNo = appData.save.picNo - 1;
    else
        picNo = appData.save.picNo;
    end
    
    savedData = createSavedData(appData);  %#ok<NASGU>
     if strcmp(computer, 'MACI64')
         save([appData.save.saveDir '/data-' num2str(picNo) appData.save.commentStr '.mat'], 'savedData', appData.consts.saveVersion);
     else
         save([appData.save.saveDir '\data-' num2str(picNo) appData.save.commentStr '.mat'], 'savedData', appData.consts.saveVersion);
     end
    
        
    if ( strcmp(appData.consts.runVer, 'online') )
        [s m mid] = copyfile(appData.consts.defaultStrLVFile_Save, [appData.save.saveDir '\data-' num2str(picNo) '.csv']); %#ok<NASGU>
        if ( s == 0 )
            warndlg(['Cannot copy timeframe file: ' m], 'Warning', 'modal');
        end
    end
    
    set(appData.ui.win, 'Name', [appData.consts.winName num2str(appData.save.picNo) appData.save.commentStr]);
    
    if ( appData.analyze.isReadPic == 0)
        appData.save.picNo = picNo + 1;
        set(appData.ui.etPicNo, 'String', num2str(appData.save.picNo));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etPicNo_Callback(object, eventdata) %#ok<INUSD>
    val = str2double(get(object, 'String'));
    if ( isnan(val) || val <= 0 || floor(val) ~= val )
        set(object, 'String', num2str(appData.save.picNo));
        errordlg('Input must be positive integer','Error', 'modal');
    else
        appData.save.picNo = val;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sPicNo_Callback(object, eventdata) %#ok<INUSD>
    val = get(object, 'Value');
    if ( val == 0 )
        if ( appData.save.picNo > 1 )
            appData.save.picNo = appData.save.picNo - 1;
        end
    elseif ( val == 2 )
        appData.save.picNo = appData.save.picNo + 1;
    end
    set(appData.ui.etPicNo, 'String', num2str(appData.save.picNo));
    set(object, 'Value', 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbSave_Callback(object, eventdata) %#ok<INUSD>
    appData.save.isSave  = get(object, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etSaveDir_Callback(object, eventdata) %#ok<INUSD>
    str = get(object, 'String');
    ind = strfind(str, '\');
%     appData.save.saveDir
    if length(ind) > 2 && length(str) > ind(end)+1 && ~isempty(eventdata)
        if isempty(str2num(str(ind(end)+1)))
            appData.save.saveDir = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1:end)];
        else
            appData.save.saveDir = [str(1:ind(end)) datestr(now,'HH_MM ') str(ind(end)+1+6:end)];
        end
    else
        appData.save.saveDir = str;
    end
            
    [s, mess, messid] = mkdir(appData.save.saveDir); %#ok<NASGU>
    if ( s == 0 )
        warndlg(['Cannot open/create directory: ' mess], 'Warning', 'modal');
    else
        set(object, 'String', appData.save.saveDir);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbRun_Callback(object, eventdata)  

appData.data.isRun  = get(object, 'Value');

if ( appData.data.isRun == 0 )
    return
end

picPause = 0.5;
isLastTFData = 0;
isNewMeasurement = 0;
% saftyPause = 1;
% i = 1; %safety
while ( appData.data.isRun == 1 )%&& i < 2 )   
    %
    % read atoms, backgraund and dark images
    %
    
    fileName = [appData.data.camera.dir appData.slash appData.data.camera.fileName  ...
        num2str(appData.data.camera.firstImageNo) '.' appData.data.camera.fileFormat];
    fid = fopen(fileName);
    while ( fid  == -1 && appData.data.isRun == 1)
        pause(picPause);
        fid = fopen(fileName);
    end
    if ( appData.data.isRun == 0 )
        return
    end
    fclose(fid);
%     %
%     % Loop: first thing to write the file
%     %
%     if ( appData.loop.isLoop == 1 && ~appData.loop.fFirstMeas )
%         if isempty(appData.loop.measurements)
%             warndlg('No More Measurements.', 'Warning', 'modal');
%             set(appData.ui.tbLoop, 'Value', 0)
%             tbLoop_Callback(appData.ui.tbLoop, eventdata);
%             continue
%         end
%         
%         % get next measurement
%         appData.TF.lastData = appData.TF.data;
%         [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
%         
%         if isempty(appData.TF.data)
%              lbMeasurementsList_KeyPressFcn(appData.ui.lbMeasurementsList, struct('Key', 'removeFirst'));
%                  
%             if  isempty(appData.loop.measurements)         % TODO : move that part to after saving (so the last pic will be saved)       
%                 isLastTFData = 1;
%             else
%                 isNewMeasurement = 1;
%                 % start next measuremdent
%                 [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
%                 pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
%                 appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
%                 set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
%             end
%         else
% %             set(appData.ui.etSaveDir, 'String', appData.loop.measurements{1}.baseFolder);
% %             ed.Style = 'edit';
% %             etSaveDir_Callback(appData.ui.etSaveDir, ed);
%             pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
%             appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
%             set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
%         end
%     
%     end
%     %
%     % End Loop: continue with reading pics
%     %
    pause(picPause);
    atoms = rot90( double(appData.data.camera.fileReadFunction(appData, appData.data.camera.firstImageNo)), ...
        appData.data.camera.rotate / 90);
    delete(fileName);
   
    fileName = [appData.data.camera.dir appData.slash appData.data.camera.fileName ...
        num2str(appData.data.camera.secondImageNo) '.' appData.data.camera.fileFormat];
    fid = fopen(fileName);
    while ( fid  == -1 && appData.data.isRun == 1)
        pause(picPause);
        fid = fopen(fileName);
    end
    if ( appData.data.isRun == 0 )
        return
    end
    fclose(fid);
    pause(picPause);
    back = rot90( double(appData.data.camera.fileReadFunction(appData, appData.data.camera.secondImageNo)), ...
        appData.data.camera.rotate / 90);
    delete(fileName);
    
    fileName = [appData.data.camera.dir appData.slash appData.data.camera.fileName  ...
        num2str(appData.data.camera.darkImageNo) '.' appData.data.camera.fileFormat];
    fid = fopen(fileName);
    while ( fid  == -1 && appData.data.isRun == 1)
        pause(picPause);
        fid = fopen(fileName);
    end
    if ( appData.data.isRun == 0 )
        return
    end
    fclose(fid); 
    pause(picPause);
    dark = rot90( double(appData.data.camera.fileReadFunction(appData, appData.data.camera.darkImageNo)), ...
        appData.data.camera.rotate / 90);
    delete(fileName);
    
        
    %
    % Initialize data
    %

    appData.data.xPosMaxBack = 0;
    appData.data.yPosMaxBack = 0;
    
    appData.data.date = datestr(now);
    
    appData.data.fits = appData.consts.fitTypes.fits;
    appData.data.plots = appData.consts.plotTypes.plots;
    %
    
    % Create absorption image
    % 
    
    atoms1 = atoms;% - dark; % subtract the dark background from the atom pic
    atoms1 = atoms1 .* ( ~(atoms1<0));                                                   % set all pixelvalues<0 to 0
    
    % do fringe removal
    if appData.options.doFR && isempty(appData.analyze.refImagesBinv)
        errordlg('No reference images','Error', 'modal');
    end
    if appData.options.doFR && ~isempty(appData.analyze.refImagesBinv)
        if numel(appData.analyze.backgroundMask) ~= numel(atoms1)
            errordlg('Fringe Removal: different num elements', 'error', 'modal');
            backRef = back;%true(size(back));
            back1 = back - dark;% subtract the dark background from the background pic
            back1 = back1 .* ( ~(back1<0));
            atoms1 = atoms - dark; % subtract the dark background from the atom pic
            atoms1 = atoms1 .* ( ~(atoms1<0));
        else
            A = double(reshape(atoms(:), ...-dark(:),...
                numel(appData.analyze.backgroundMask),1));
            %         k = find(appData.analyze.backgroundMask(:)==1);
            c = appData.analyze.refImagesBinv*A(appData.analyze.backgroundMask(:));
            backRef = reshape(appData.analyze.refImagesR*c,size(appData.analyze.backgroundMask));
            %         back1 = fringeremoval(back - dark, appData.analyze.refImagesBinv, appData.analyze.backgroundMask, 'svd');
            back1 = backRef;% - dark;% subtract the dark background from the background pic
            back1 = back1 .* ( ~(back1<0));
        end
        
    else
        backRef = back;%true(size(back));
        back1 = back - dark;% subtract the dark background from the background pic
        back1 = back1 .* ( ~(back1<0));
        atoms1 = atoms - dark; % subtract the dark background from the atom pic
        atoms1 = atoms1 .* ( ~(atoms1<0));
    end                                                     % set all pixelvalues<0 to 0
    absorption = log( (back1 + 1)./ (atoms1 + 1)  );% set all pixelvalues=0 to 1 and divide pics
    
    appData = appData.data.plots{appData.consts.plotTypes.absorption}.setPic(appData, absorption);
    appData = appData.data.plots{appData.consts.plotTypes.ROI}.setPic(appData, absorption);
    appData = appData.data.plots{appData.consts.plotTypes.withAtoms}.setPic(appData, atoms);
    appData = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.setPic(appData, back);
    appData = appData.data.plots{appData.consts.plotTypes.FR}.setPic(appData, backRef);
    appData = appData.data.plots{appData.consts.plotTypes.dark}.setPic(appData, dark);
    
    %
    % Smoothing
    %
    
    %
    % Analyze and Plot
    %
    appData = analyzeAndPlot(appData);
    
    
    %
    % Loop
    %
    if ( appData.loop.isLoop == 1 && ~appData.loop.fFirstMeas && ~isLastTFData && ~isNewMeasurement)
        if isempty(appData.loop.measurements)
            warndlg('No More Measurements.', 'Warning', 'modal');
            set(appData.ui.tbLoop, 'Value', 0)
            tbLoop_Callback(appData.ui.tbLoop, eventdata);
            continue
        end
        
        %for GeneralLoop
        set(appData.ui.etSaveDir, 'String', appData.loop.measurements{1}.baseFolder);
        etSaveDir_Callback(appData.ui.etSaveDir, []);
%         set(appData.ui.etSaveDir, 'String', appData.loop.measurements{1}.baseFolder);
%         if isa(appData.loop.measurements{1}, 'QuickLoop')
%             ed.Style = 'edit';
%         elseif isa(appData.loop.measurements{1}, 'GeneralLoopTF')
%             ed = [];
%         else
%             warndlg('Unrecognized Loop class.', 'Warning', 'modal');
%             set(appData.ui.tbLoop, 'Value', 0)
%             tbLoop_Callback(object, eventdata);
%             return
%         end
%         etSaveDir_Callback(appData.ui.etSaveDir, ed);
        
        % get next measurement
        appData.TF.lastData = appData.TF.data;
        [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
        
        if isempty(appData.TF.data)
             lbMeasurementsList_KeyPressFcn(appData.ui.lbMeasurementsList, struct('Key', 'removeFirst'));
                 
            if  isempty(appData.loop.measurements)         % TODO : move that part to after saving (so the last pic will be saved)       
                isLastTFData = 1;
            else
                isNewMeasurement = 1;
%                 % start next measuremdent
%                 [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
%                 pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
%                 appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
%                 set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
            end
        else
            pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
            appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
            set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
        end
    
    end
    
    if ( appData.loop.isLoop == 1 && appData.loop.fFirstMeas )
%         if appData.loop.fFirstMeas == 1
%             appData.loop.fFirstMeas = 2;
%         else
            appData.loop.fFirstMeas = 0;
            appData.TF.lastData = appData.TF.data;
            [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
            pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
            appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
            set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
%         end
    end
    
    if ( appData.loop.isLoop == 1 )
%         etSaveDir_Callback(appData.ui.etSaveDir, []);
        pmSaveParam_Callback(appData.ui.pmSaveParam, []);
        etParamVal_Callback(appData.ui.etParamVal, []);
    end
    if isNewMeasurement 
        if isNewMeasurement == 1
            isNewMeasurement = 2;
            
            % start next measuremdent
            [appData.loop.measurements{1}, appData.TF.data] = appData.loop.measurements{1}.next(appData);
            pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
            appData.loop.measurementsList{1} = appData.loop.measurements{1}.getMeasStr(appData);
            set(appData.ui.lbMeasurementsList, 'String', appData.loop.measurementsList);
        else
            
            appData.loop.fFirstMeas = 1;    
            isNewMeasurement = 0;
            pmSaveParam_Callback(appData.ui.pmSaveParam, []);
            etParamVal_Callback(appData.ui.etParamVal, []);
            set(appData.ui.etSaveDir, 'String', appData.loop.measurements{1}.baseFolder);
            ed.Style = 'edit';
            etSaveDir_Callback(appData.ui.etSaveDir, ed);
            appData.loop.measurements{1}.baseFolder = appData.save.saveDir;
        end
    end
    if isLastTFData
        if isLastTFData == 1
            isLastTFData = 2;
        else
            isLastTFData = 0;
            set(appData.ui.tbLoop, 'Value', 0);
            tbLoop_Callback(appData.ui.tbLoop, []);
            
            appData.TF.data = appData.TF.firstData;
            pbSaveTF_Callback(appData.TFui.pbSaveTF, []);
        end
        
    end
%     % save timeframe.csv into a tmp file
%     [s, m, mid] = copyfile(appData.consts.defaultStrLVFile_Save, appData.consts.defaultStrLVFile_SaveLast); %#ok<NASGU>
%     if ( s == 0)
%         warndlg(['Cannot copy timeframe file: ' m], 'Warning', 'modal');
%     end
    
    set(appData.ui.etComment, 'String', appData.consts.commentStr);
    appData.save.commentStr = appData.consts.commentStr;
    
    %
    % Monitoring
    %
    if appData.monitoring.isMonitoring && ...
            ((appData.monitoring.onlySavedPics && appData.save.isSave) || ~appData.monitoring.onlySavedPics)
        appData.monitoring.monitoringData(end+1, appData.consts.availableMonitoring.atomNum) = ...
            appData.data.fits{appData.data.fitType}.atomsNo;
        appData.monitoring.monitoringData(end, appData.consts.availableMonitoring.OD) = ...
            appData.data.fits{appData.data.fitType}.maxVal;
        appData.monitoring.monitoringData(end, appData.consts.availableMonitoring.xPos) = ...
            appData.data.fits{appData.data.fitType}.xCenter;
        appData.monitoring.monitoringData(end, appData.consts.availableMonitoring.yPos) = ...
            appData.data.fits{appData.data.fitType}.yCenter;
        appData.monitoring.monitoringData(end, appData.consts.availableMonitoring.xWidth) = ...
            appData.data.fits{appData.data.fitType}.xUnitSize;
        appData.monitoring.monitoringData(end, appData.consts.availableMonitoring.yWidth) = ...
            appData.data.fits{appData.data.fitType}.yUnitSize;
    end
    

    
%     pause(saftyPause*4);
%     i=i+1;
%     set(object, 'Value', 0); % stop running
end %while

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbMonitoringSave_Callback(object, eventdata) %#ok<INUSD>
export2wsdlg({'Monitoring Data:'}, {'monitoringData'}, {appData.monitoring.monitoringData});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbMonitoringOnOff_Callback(object, eventdata) %#ok<INUSD>
appData.monitoring.isMonitoring = get(object, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cbOnlySavedPics_Callback(object, eventdata) %#ok<INUSD>
appData.monitoring.onlySavedPics = get(object, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbAvailableMonitoring_Callback(object, eventdata) %#ok<INUSD>
appData.monitoring.currentMonitoring = get(object, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbMonitoringShow_Callback(object, eventdata) %#ok<INUSD>
for i = 1 : length(appData.monitoring.currentMonitoring)
    figure;
    plot(appData.monitoring.monitoringData(:,i));
    xlabel('Pic Num');
    ylabel(appData.consts.availableMonitoring.str{i});
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lbAvailableAnalyzing_Callback(object, eventdata) %#ok<INUSD>
    appData.analyze.currentAnalyzing = get(object, 'Value');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbSaveToWorkspace_Callback(object, eventdata) %#ok<INUSD>
    export2wsdlg({'All Pics:'}, {'totAppData'}, {appData.analyze.totAppData});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbClearFR_Callback(object, eventdata) %#ok<INUSD>
    appData.analyze.refImagesBinv = [];
    appData.analyze.refImagesR = [];
    appData.analyze.backgroundMask = [];
    appData.analyze.refImagesFolder = '';
    appData.analyze.refImagesNums = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbSaveFR_Callback(object, eventdata) %#ok<INUSD>
    [FileName,PathName,FilterIndex] = uiputfile([appData.save.saveDir appData.slash 'FR_Data.mat']);
    if FilterIndex == 0
        return
    end
    
    refImagesBinv = appData.analyze.refImagesBinv;
    refImagesR = appData.analyze.refImagesR;
    backgroundMask = appData.analyze.backgroundMask;
    refImagesFolder = appData.analyze.refImagesFolder;
    refImagesNums = appData.analyze.refImagesNums;
    save([PathName appData.slash FileName], 'refImagesBinv' , 'refImagesR', ...
        'backgroundMask', 'refImagesFolder', 'refImagesNums', '-v7.3');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbClearTotAppData_Callback(object, eventdata) %#ok<INUSD>
    appData.analyze.totAppData = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbAnalyze_Callback(object, eventdata) %#ok<INUSD>
    appData = analyzeMeasurement(appData, eventdata);
    return
    for ( i = 1 : length(appData.analyze.currentAnalyzing) ) %#ok<*NO4LP>
        switch appData.analyze.currentAnalyzing(i)
            case appData.consts.availableAnalyzing.temperature
                temperature(appData.analyze.totAppData);
            case appData.consts.availableAnalyzing.heating
                heating(appData, @tbReadPics_Callback, @lbAvailableAnalyzing_Callback, @pbAnalyze_Callback);             
            case appData.consts.availableAnalyzing.gravity 
                gravity(appData.analyze.totAppData);
            case appData.consts.availableAnalyzing.lifeTime1 
                lifeTime1(appData.analyze.totAppData);
            case appData.consts.availableAnalyzing.lifeTime2 
                lifeTime2(appData.analyze.totAppData);
            case appData.consts.availableAnalyzing.dampedSine 
                dampedSineY(appData.analyze.totAppData);
            case appData.consts.availableAnalyzing.atomNo 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNo; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val, N);
                xlabel('Param Value');
                ylabel('Atoms Number');
                case appData.consts.availableAnalyzing.OD 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.maxVal; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val, N);
                xlabel('Param Value');
                ylabel('Max Val');
            case appData.consts.availableAnalyzing.xPos 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
%                     xPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.xCenter ...
%                         * appData.analyze.totAppData{j}.data.camera.xPixSz *1000; %#ok<AGROW>
                    xPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.x0 ...
                        * appData.analyze.totAppData{j}.data.camera.xPixSz *1000; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val, xPos);
                xlabel('Param Value');
                ylabel('X Position [mm]');
            case appData.consts.availableAnalyzing.yPos 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
%                     if isfield(appData.analyze.totAppData{j}.data.fits{ fitType }, 'y0')
                        yPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.y0 ...
                            * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
%                     else
%                         yPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.yCenter ...
%                             * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
%                     end
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val, yPos);
                xlabel('Param Value');
                ylabel('Y Position [mm]');
            case appData.consts.availableAnalyzing.sizeX 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    szX(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.xUnitSize ...
                        * appData.analyze.totAppData{j}.data.camera.xPixSz *1000; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val, szX);
                xlabel('Param Value');
                ylabel('Size X [mm]');
            case appData.consts.availableAnalyzing.sizeY 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    szY(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.yUnitSize ...
                        * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val, szY);
                xlabel('Param Value');
                ylabel('Size Y [mm]');
            case appData.consts.availableAnalyzing.deltaY_2 
                 fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    Delta_Y2(j) = 0.5*abs(appData.analyze.totAppData{j}.data.fits{ fitType }.y02-appData.analyze.totAppData{j}.data.fits{ fitType }.y01)...
                        * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val,  Delta_Y2);
                xlabel('Param Value');
                ylabel('\Deltay/2  [mm]');
            case appData.consts.availableAnalyzing.picMean
                pic = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.absorption}.pic));
                atoms = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withAtoms}.pic));
                back = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic));
                dark = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.dark}.pic));
                if isempty(pic)
                     errordlg('There is no data in the files. Use f when reading the files.','Error', 'modal'); 
                     continue;
                end
                for ( j = 1 : length(appData.analyze.totAppData)  )
                    pic = pic + appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.absorption}.pic;
                    atoms = atoms + appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.withAtoms}.pic;
                    back = back + appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;
                    dark = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.dark}.pic));
                end
                pic = pic / length(appData.analyze.totAppData);
                atoms = atoms / length(appData.analyze.totAppData);
                back = back / length(appData.analyze.totAppData);
                dark = dark / length(appData.analyze.totAppData);
%                  figure;
%                  colormap(jet(256));
%                 image( ([x(1) x(end)]+x0-1)*appData.data.camera.xPixSz * 1000, ...
%                     ([y(1) y(end)]+y0-1-chipStart-1)*appData.data.camera.yPixSz * 1000, pic*256);
%                 imagesc( pic*256);
%                  xlabel('px');
%                  ylabel('px');
                appData = appData.data.plots{appData.consts.plotTypes.absorption}.setPic(appData, [ zeros(appData.data.camera.chipStart-1, size(pic, 2)) ;pic]);
                appData = appData.data.plots{appData.consts.plotTypes.withAtoms}.setPic(appData, atoms);
                appData = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.setPic(appData, back);
                appData = appData.data.plots{appData.consts.plotTypes.dark}.setPic(appData, dark);
             
%                 appData.data.plots{1}.pic = pic;
                appData.data.fits = appData.consts.fitTypes.fits;
                appData = analyzeAndPlot(appData);
            case appData.consts.availableAnalyzing.SG
                 fitType = appData.analyze.totAppData{1}.data.fitType;
                 N=[];
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.mF1*100; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
%                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
%                 hh = figure('CloseRequestFcn', {@closeRequestFcn_Callback, appData.analyze.readDir, 'SG.fig'});
%                 plot(val, N, 'o');
%                 xlabel(xlabelstr{get(appData.ui.pmSaveParam, 'Value')});
%                 ylabel('mF=1 Percentage [%]');
%                 saveas(hh, [appData.analyze.readDir '\SG_tmp.fig']);
%                 plotSG({appData.analyze.readDir})
                plotSG(val, N, appData.analyze.readDir);
            case appData.consts.availableAnalyzing.mF1
                 fitType = appData.analyze.totAppData{1}.data.fitType;
                 N=[];
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.mF1*100; %#ok<AGROW>
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '.fig']);
                plot(val,  N, 'o');
%                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
%                 xlabel(xlabelstr{appData.analyze.totAppData{1}.save.saveParamVal});
                xlabel('Param Value');
                ylabel('mF1 [%] ');
%                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
%                 hh = figure('CloseRequestFcn', {@closeRequestFcn_Callback, appData.analyze.readDir, 'SG.fig'});
%                 plot(val, N, 'o');
%                 xlabel(xlabelstr{get(appData.ui.pmSaveParam, 'Value')});
%                 ylabel('mF=1 Percentage [%]');
%                 saveas(hh, [appData.analyze.readDir '\SG_tmp.fig']);
%                 plotSG({appData.analyze.readDir})
%                 plotSG(val, N, appData.analyze.readDir);
            case appData.consts.availableAnalyzing.SGyPos 
                fitType = appData.analyze.totAppData{1}.data.fitType;
                for ( j= 1 : length(appData.analyze.totAppData)  )
%                     if isfield(appData.analyze.totAppData{j}.data.fits{ fitType }, 'y0')
                    switch fitType
                        case appData.consts.fitTypes.SG
                            yPos1(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.y01 ...
                                * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
                            yPos2(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.y02 ...
                                * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
                        case appData.consts.fitTypes.twoDGaussian
                            yPos1(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.y0 ...
                                * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
                            yPos2(j) = yPos1(j);
                    end
%                     else
%                         yPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.yCenter ...
%                             * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
%                     end
                    val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
                end
                val = val*1e-3;
                if ( min(val) == max(val) )
                    for ( j= 1 : length(appData.analyze.totAppData)  )
                        val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                    end
                end
                s1 = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [0.02 1.51 0 70 0]);
                s2 = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [0.01 2.06 0 100 0]);
                f1 = fittype('a*sin(2*pi*f*(x - p))+c+d*x', 'coefficients', {'a', 'c', 'd', 'f',  'p'}, 'independent', 'x', 'dependent', 'y', 'options', s1);
                f2 = fittype('a*sin(2*pi*f*(x - p))+c+d*x', 'coefficients', {'a', 'c', 'd', 'f',  'p'}, 'independent', 'x', 'dependent', 'y', 'options', s2);
                [out1.res, out1.gof, out1.output] = fit(val', yPos1', f1);
                [out2.res, out2.gof, out2.output] = fit(val', yPos2', f2);
                
                 [path, name, ext] = fileparts(appData.analyze.totAppData{1}.save.saveDir);
                 export2wsdlg({'mF=1:' 'mF=2:'}, {[name '_mF1'] [name '_mF2']}, {out1 out2});
                 
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '_mF1.fig']);
                plot(out1.res, 'r', val, yPos1, 'ob');     
                title(['mF=1, (' name ')'], 'interpreter', 'none');
                xlabel('time [ms]');
                ylabel('Y Position [mm]');
                legend({['mF=1, (' name ')'],['fit mF=1, (' name ')']},'interpreter', 'none');
                figure( 'FileName', [appData.analyze.totAppData{1}.save.saveDir '_mF2.fig']);
                plot(out2.res, 'b', val, yPos2, 'or');                
                title(['mF=2, (' name ')'], 'interpreter', 'none');
                xlabel('time [ms]');
                ylabel('Y Position [mm]');
                legend({['mF=2, (' name ')'], ['fit mF=2, (' name ')']},'interpreter', 'none');
                
%                 [path, name, ext] = fileparts(appData.analyze.totAppData{1}.save.saveDir);
%                 export2wsdlg({'mF=1:' 'mF=2:'}, {[name '_mF1'] [name '_mF2']}, {out1 out2});
                                    
            case appData.consts.availableAnalyzing.FFT
                fitType = appData.analyze.totAppData{1}.data.fitType;
                w = length(abs(appData.data.fits{fitType}.xData_k));
                data_k = zeros(length(appData.analyze.totAppData), w);
                k = appData.data.fits{fitType}.k;
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    data_k(j, :) = appData.data.fits{fitType}.xData_k;
                end
                figure('FileName', [appData.analyze.totAppData{1}.save.saveDir '-fft.fig']); 
                plot(k(round(w/2):w), sqrt(sum(abs(data_k(:, round(w/2):w)).^2,1)));
                
                
            case appData.consts.availableAnalyzing.oneDstd
                fitType = appData.analyze.totAppData{1}.data.fitType;
                [pic x0 y0] = appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.absorption }.getPic();
                [h w] = size(pic);
                data = zeros(length(appData.analyze.totAppData), w);
                fits = zeros(length(appData.analyze.totAppData), w);
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    [xData yData] = ...
                        appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.absorption }.getXYDataVectors(...
                        appData.analyze.totAppData{j}.data.fits{ fitType }.xCenter, appData.analyze.totAppData{j}.data.fits{ fitType }.yCenter, ...
                        appData.analyze.totAppData{j}.options.avgWidth);
                    [pic x0 y0] = appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.absorption }.getPic();
                    [h w] = size(pic);
                    x = [1 : w];
                    y = [1 : h];
                    [xFit yFit] = appData.analyze.totAppData{j}.data.fits{appData.data.fitType}.getXYFitVectors(x+x0-1, y+y0-1);
                    
                    data(j, :) = xData;
                    fits(j, :) = xFit(1,:);
                end
                figure('FileName', [appData.analyze.totAppData{1}.save.saveDir ' - data.fig']);
                imagesc(data);
                title('X Data');
                figure('FileName', [appData.analyze.totAppData{1}.save.saveDir ' - fits.fig']);
                imagesc(fits);
                title('X Fits');
                export2wsdlg({'Data:', 'Fits:'}, {'data', 'fits'}, {data, fits});
                
            case appData.consts.availableAnalyzing.g2
                [n, g2, dN2] = cloudstat(appData.analyze.totAppData, ...
                    appData.analyze.totAppData{1}.data.camera.xPixSz*1e6, ...
                    2*appData.analyze.totAppData{1}.options.avgWidth+1, ...
                    0, 0); 
                figure;
                imagesc(n);
                figure;
                imagesc(g2);
                figure;
                imagesc(dN2);
            otherwise
                errordlg({'Not a known Value in \"imaging.m/pbSaveToWorkspace_Callback\".' ['appData.analyze.currentAnalyzing(' num2str(i)  ...
                    ') is: ' num2str(appData.data.fitType)]},'Error', 'modal'); 
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbReadPics_Callback(object, eventdata) 
    if ( get(object, 'Value') == 0 )
%         'cancel'
        return;
    end
    
    appData.analyze.readDir = get(appData.ui.etReadDir, 'String');
    tmpReadDir = appData.analyze.readDir;
    tmpIsReadPic = appData.analyze.isReadPic;
    appData.analyze.totAppData = [];
    evalStr = get(appData.ui.etAnalyzePicNums, 'String');
    if strcmp(evalStr, 'ams')
        readFolder(appData);
        set(object, 'Value', 0);
        return
    end
    
    doAnalyze = 0;
    if strcmpi(evalStr(end-2:end), '-ra') % analyze recursively 
        pathStr = genpath(appData.analyze.readDir);
        sepLocs = strfind(pathStr, pathsep);
        loc1 = [1 sepLocs(1:end-1)+1];
        loc2 = sepLocs(1:end)-1;
        pathFolders = arrayfun(@(a,b) pathStr(a:b), loc1, loc2, 'UniformOutput', false);
        evalStr(end-2:end) = 'all';
        doAnalyze = 1;
    else
        pathFolders{1} = appData.analyze.readDir;
    end
    
    for k = 1 : length(pathFolders)
        appData.analyze.readDir = pathFolders{k};
        appData.analyze.totAppData = [];
        files = [];
        analyzePicNums = [];
        if strcmpi(evalStr(end-2:end), 'all') || strcmpi(evalStr(end-2:end), '--r')
            if strcmpi(evalStr(end-2:end), 'all')
                files = dir([appData.analyze.readDir appData.slash 'data-*.mat']);
            else
                files = subdir([appData.analyze.readDir appData.slash 'data-*.mat']);
            end
            for ( j = 1 : length(files) )
                dotIndex = find(files(j).name == '.', 1, 'last');
                dashIndex = find(files(j).name == '-', 1, 'last');
                num = str2double(files(j).name(dashIndex(1)+1 : dotIndex(end)-1));

                files(j).dir = fileparts(files(j).name);
                if isempty(files(j).dir)
                    files(j).dir = appData.analyze.readDir;
                end
                files(j).num = num;
                analyzePicNums(j) = num;
            end
           if isempty(files)
%                errordlg('Empty folder.','Error', 'modal');
               continue
           end
        end
        
        [analyzePicNums,I] = sort(analyzePicNums);
        files = files(I);
        

    %     firstInd = 1;
        if ( strcmpi(evalStr(1:2), 'FR') )
            if( strcmpi(evalStr(3), 'i') )
    %             analyzePicNums = eval([ '[' evalStr(4:end)  ']' ]);
                invBG = true;
                firstInd = 4;
            else
    %             analyzePicNums = eval([ '[' evalStr(3:end)  ']' ]);
                invBG = false;
                firstInd = 3;
            end
            fullEval = 2;
        elseif ( strcmpi(evalStr(1), 'f') )%evalStr(1) == 'f' )
    %         analyzePicNums = eval([ '[' evalStr(2:end)  ']' ]);
            fullEval = 1;
            firstInd = 2;
        else
    %         analyzePicNums = eval([ '[' evalStr  ']' ]);
            fullEval = 0;
            firstInd = 1;
        end
        if isempty(files)
            nums = eval([ '[' evalStr(firstInd:end)  ']' ]);
            analyzePicNums = nums;
            files = dir([appData.analyze.readDir appData.slash 'data-' ...
                num2str(nums(1)) '.mat']);
            if isempty(files)
                files = dir([appData.analyze.readDir appData.slash 'data-' ...
                    num2str(nums(1)) '-*.mat']);
            end
                    
            for j = 2 : length(nums)
%                 nums(j)
                files(j) = dir([appData.analyze.readDir appData.slash 'data-' ...
                    num2str(nums(j)) '.mat']);
                if isempty(files(j))
                    files(j) = dir([appData.analyze.readDir appData.slash 'data-' ...
                        num2str(nums(j)) '-*.mat']);
                end
            end
            for j = 1 : length(nums)
                files(j).num = nums(j);
                files(j).dir = appData.analyze.readDir;
            end
        end
        if isempty(files)
            errordlg('Input must be an array','Error', 'modal');
        end

        refImages = cell(1, length(files));
        totAppData = cell(1, length(files) );
%         tmpIsReadPic = appData.analyze.isReadPic;
        appData.analyze.isReadPic = 1;
        set(appData.ui.tbReadPic, 'Value', appData.analyze.isReadPic);
        for ( i = 1 : length(files) )
    %         i
            if ( get(object, 'Value') == 0 )
                doAnalyze = 0;
                break
            end
            num = files(i).num;
    %         appData.analyze.readPic = fileparts(files(i).name);
    %         set(appData.ui.etReadDir, 'String', appData.analyze.readPic);
            set(appData.ui.etReadDir, 'String', files(i).dir);
            set(appData.ui.etShowPicNo, 'String', num2str(num));
            etShowPicNo_Callback(appData.ui.etShowPicNo, eventdata);

            %sometimes is needed to show each picture
            pause(0.05);

            if fullEval == 2 && i == 1
    %             refImages = cell(1, length(analyzePicNums));
                appData.analyze.refImagesFolder = appData.analyze.readDir;
                appData.analyze.refImagesNums = analyzePicNums;

                appData.analyze.backgroundMask = true(size(appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic));
                [ROIy, ROIx] = size(appData.data.plots{appData.consts.plotTypes.ROI}.pic);
%                 appData.analyze.backgroundMask(1) = false;
                appData.analyze.backgroundMask(appData.data.plots{appData.consts.plotTypes.ROI}.yStart+[1:ROIy]-1, ...
                    appData.data.plots{appData.consts.plotTypes.ROI}.xStart+[1:ROIx]-1) = false;

                if invBG
                    appData.analyze.backgroundMask = ~appData.analyze.backgroundMask;
                end
                
                appData.analyze.refImages = [];
            end

            totAppData{i} = appData;
            totAppData{i}.analyze = [];
            totAppData{i}.oldAppData = [];
            if ( fullEval == 0 ) %regulat analysis, don't save images
                totAppData{i}.data.plots = appData.consts.plotTypes.plots;
                totAppData{i}.TF.data = [];
                totAppData{i}.TF.lastData = [];
                totAppData{i}.TF.firstData = [];
            elseif fullEval == 2 %fringe removal analysis, save without atoms images
                totAppData{i}.data.plots = appData.consts.plotTypes.plots;
                totAppData{i}.TF.data = [];
                totAppData{i}.TF.lastData = [];
                totAppData{i}.TF.firstData = [];

                refImages{i} = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;% - ...
%                     appData.data.plots{appData.consts.plotTypes.dark}.pic;
%                 refImages_{i} = refImages{i} .* ~(refImages{i}<0);
%                 refImages_{i} = refImages_{i} + 1;
    %             totAppData{i}.data.plots{appData.consts.plotTypes.withoutAtoms} = ...
    %                 appData.data.plots{appData.consts.plotTypes.withoutAtoms};
    
%                 appData.analyze.refImages(i,:,:) = refImages{i};%(appData.analyze.backgroundMask);
            end
        end
        
        if fullEval == 2
            
            % adding an image with constant value to the database of images
            refImages{end+1} = ones(size(appData.data.plots{appData.consts.plotTypes.withoutAtoms}.pic));
%         [X Y] = meshgrid(1:size(refImages{end}, 2), 1:size(refImages{end}, 1));
%         refImages{end+1} = X./max(max(X))-0.5;
%         refImages{end+1} = Y./max(max(Y))-0.5;
%             appData.analyze.refImages(end+1,:,:) = refImages{end};%(appData.analyze.backgroundMask);

            if numel(appData.analyze.backgroundMask) == numel(refImages{1})
                appData.analyze.refImagesR = ...
                    double(reshape(cat(3,refImages{:}),numel(appData.analyze.backgroundMask),...
                    length(refImages)));
%                     1+length(appData.analyze.refImagesNums)));
                
%                 appData.analyze.refImagesBinv = ...
%                     pinv(appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:)' ...
%                         * appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:)) ...
%                     * appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:)';
                appData.analyze.refImagesBinv = ...
                    pinv(appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:), 1e-10);
                % LU decomposition
%                 [appData.analyze.L,appData.analyze.U,appData.analyze.p] = ...
%                     lu(appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:)' ...
%                         * appData.analyze.refImagesR(appData.analyze.backgroundMask(:),:), ...
%                         'vector');
            else
                errordlg('num elements change', 'Error', 'modal');
            end
        end

        appData.analyze.totAppData = totAppData;
        
        if doAnalyze %do analysis, '-ra' used
            slashIndex = find(appData.analyze.readDir == appData.slash, 1, 'last');
            pbAnalyze_Callback(appData.ui.pbAnalyze, appData.analyze.readDir(slashIndex+1:end))
        end

    end
    appData.analyze.isReadPic = tmpIsReadPic;
    set(appData.ui.tbReadPic, 'Value', appData.analyze.isReadPic);
    appData.analyze.readDir = tmpReadDir;
    set(appData.ui.etReadDir, 'String', appData.analyze.readDir);
%     set(appData.ui.etReadDir, 'String', tmpReadDir);
%     appData.analyze.readPic = tmpReadDir;
    
    set(object, 'Value', 0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etShowPicNo_Callback(object, eventdata) 
    val = str2double(get(object, 'String'));
    if ( isnan(val) || val <= 0 || floor(val) ~= val )
        set(object, 'String', num2str(appData.analyze.showPicNo));
        errordlg('Input must be positive integer','Error', 'modal');
    else
        appData.analyze.showPicNo = val;
        tbReadPic_Callback(appData.ui.tbReadPic, eventdata);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sShowPicNo_Callback(object, eventdata) 
    val = get(object, 'Value');
    if ( val == 0 )
        if ( appData.analyze.showPicNo > 1 )
            appData.analyze.showPicNo = appData.analyze.showPicNo - 1;
        else
            return
        end
    elseif ( val == 2 )
        appData.analyze.showPicNo = appData.analyze.showPicNo + 1;
    end
    set(appData.ui.etShowPicNo, 'String', num2str(appData.analyze.showPicNo));
    set(object, 'Value', 1);
    tbReadPic_Callback(appData.ui.tbReadPic, eventdata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tbReadPic_Callback(object, eventdata) %#ok<INUSD>
    appData.analyze.isReadPic = get(object, 'Value');
    
    if ( appData.analyze.isReadPic == 0 )
        return
    end
    
    comment = [];
    fileName = dir([ appData.analyze.readDir appData.slash 'data-' num2str(appData.analyze.showPicNo) '-*.mat']);
    fileName = [fileName.name];

    if ( size(fileName, 1) > 1 )
        fileName = strtrim(fileName(1, :));
    end
    if ( isempty(fileName) )
        fileName = ls([get(appData.ui.etReadDir, 'String') appData.slash ...
            'data-' num2str(appData.analyze.showPicNo) '.mat']);
%         fileName = ls([appData.analyze.readDir appData.slash 'data-' num2str(appData.analyze.showPicNo) '.mat']);
        if ( isempty(fileName) )
            warndlg({'File doesnt exist:', [appData.analyze.readDir appData.slash 'data-' num2str(appData.analyze.showPicNo) '.mat']}, 'Warning', 'modal');
            return
        end
    else        
        dotIndex = find(fileName == '.');
        dashIndex = find(fileName == '-');
        comment = fileName(dashIndex(2):dotIndex(end)-1);
    end
    
    if strcmp(computer, 'MACI64')
        if strcmp(fileName(1), '/')
            load([ fileName(1:end-1)], 'savedData');
        else
            load([appData.analyze.readDir appData.slash fileName], 'savedData');
        end
    else
%         load([appData.analyze.readDir appData.slash fileName], 'savedData');
        load([get(appData.ui.etReadDir, 'String') appData.slash fileName], 'savedData');
    end
    
    if ( ~isempty(comment) )
        savedData.save.commentStr = comment;
    end
    if (length(appData.data.fits) > length(savedData.data.fits) )    
        savedData.consts.fitTypes = appData.consts.fitTypes;
        for j=length(savedData.data.fits)+1 : length(appData.data.fits) 
            savedData.data.fits{j} = appData.consts.fitTypes.fits{j};
        end        
    end
    if (length(appData.consts.availableAnalyzing.str) > length(savedData.consts.availableAnalyzing.str) )
        savedData.consts.availableAnalyzing = appData.consts.availableAnalyzing;
    end
    appData = createAppData(savedData, appData);
    appData = analyzeAndPlot(appData);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etAnalyzePicNums_Callback(object, eventdata) %#ok<INUSD>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbOpenReadDir_Callback(object, eventdata)  %#ok<INUSL>
    dirName = uigetdir(get(appData.ui.etReadDir, 'String'));
    if ( dirName ~= 0 )
        set(appData.ui.etReadDir, 'String', dirName);
        etReadDir_Callback(appData.ui.etReadDir, eventdata)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function etReadDir_Callback(object, eventdata) %#ok<INUSD>
    appData.analyze.readDir = get(object, 'String');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Timeframe callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tgTimeframe_Callback(object, eventdata) %#ok<INUSD>
tab = get(object, 'SelectedTab');
for i = 1 : length(appData.TF.tabNames)
    if strcmp(tab.Title, appData.TF.tabNames{i})
        appData.TF.currentTab = i;
        return;
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbLoadTF_Callback(object, eventdata) %#ok<INUSD>

if isempty(eventdata)
    PathName = [];
    FileName = appData.consts.defaultStrLVFile_Save;
else %uigetfile(appData.consts.defaultStrLVFile_Save);
    [FileName,PathName,FilterIndex] = uigetfile({'*.fra;*.csv'}, 'TimeFrame-file to load', appData.consts.defaultStrLVFile_Save);
end
if sum(~FileName) || (isempty(PathName) && strcmp(computer, 'MACI64'))
    return
end
set(appData.TFui.win, 'Name', [appData.consts.TF.winName ': ' FileName]);
tf = readtable([PathName FileName], 'FileType', 'text', 'delimiter', '\t', 'format', '%s%s%s%s%s%s%s','ReadVariableNames',false);
[nRow, nCol] = size(tf);

i1 = 0;
for i = 1 : nRow
    if i+i1 > nRow
        break
    end
    
    if strcmp(tf.Var1(i), appData.consts.TF.arbFuncStr)
        %remove comment from previous line
        str = tf.Var2(i-1);
        str = str{1};
        tf.Var2(i-1) = {str(2:end)}; 
    
        % remove lines
        while strcmp(tf.Var1(i), appData.consts.TF.arbFuncStr)
            tf(i,:) = [];
            i1 = i1+1;
        end
    end
end

[nRow, nCol] = size(tf);
tmp = table2cell(tf);
appData.TF.data = {};
appData.TF.tabNames = {};
appData.TF.devices = unique(tmp(:,appData.consts.TF.devices))';
appData.TF.functions = unique(tmp(:,appData.consts.TF.functions))';
if isempty(appData.TF.devices{1})
    appData.TF.devices{1} = ' ';
end
if isempty(appData.TF.functions{1})
    appData.TF.functions{1} = ' ';
end
appData.TF.functions = [appData.TF.functions appData.consts.TF.arbFuncStr];
appData.TF.columnFormat = {'logical' 'char' 'char' appData.TF.devices 'char' 'char' appData.TF.functions 'char'};


lastInd = 1;
nTables = 0;
fExe = [];
for k = 1 : nRow+1
    if k == nRow+1 || isempty(tmp{k, 2})
        if k <= lastInd+1
            lastInd = k;
            continue
        end
        %create a new table
        nTables = nTables + 1;
        appData.TF.data{nTables} = cell(k-lastInd, nCol+1);
        
        if isempty(tmp{lastInd, 1})
            appData.TF.tabNames{nTables} = tmp{lastInd+1, 1};
            lastInd = lastInd+1;
        else
            appData.TF.tabNames{nTables} = tmp{lastInd, 1};
        end
        
        if ~isempty(tmp{lastInd, 2}) && tmp{lastInd, 2}(1) == '\'
            appData.TF.data{nTables}{1, 1} = false;
            appData.TF.data{nTables}{1, 3} = '\';
            fExe(nTables) = 0;
        else
            appData.TF.data{nTables}{1, 1} = true;
            fExe(nTables) = 1;
        end
        
        if strfind(appData.TF.tabNames{nTables}, 'TAB: ')
            tmpName = appData.TF.tabNames{nTables}(:)';
            appData.TF.tabNames{nTables} = tmpName(6:end);
        end

        appData.TF.data{nTables}{1, 2} = appData.TF.tabNames{nTables};
        
        fFile = 1;
        for i = lastInd+fFile : k-1 
            if ~fExe(nTables)
                tmp{i,2} = tmp{i,2}(2:end);
            end
            
            if ~isempty(tmp{i, 2}) && tmp{i, 2}(1) == '\'
                appData.TF.data{nTables}{i-lastInd+2-fFile, 1} = false;
            else
                appData.TF.data{nTables}{i-lastInd+2-fFile, 1} = true;
            end
            for j = 2 : nCol+1
                appData.TF.data{nTables}{i-lastInd+2-fFile,j} = tmp{i, j-1};
            end
            
        end

        lastInd = k+1;

    else

    end
end

appData = updateTabs(appData, nTables);
for i = 1 : length(fExe)
   if ~fExe(i)
       appData.TFui.tblArr{i}.BackgroundColor = [0.75 0.75 0.75];
   end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbSaveTF_Callback(object, eventdata) %#ok<INUSL>

tf = table;
for i = 1 : length(appData.TF.data)
    [r, c] = size(appData.TF.data{i});
    tmp = appData.TF.data{i}(:, 2:c);
    tmp{1,1} = ['TAB: ' tmp{1,1}];
    if ~appData.TF.data{i}{1,1}
        for j = 1 : r
           tmp{j,appData.consts.TF.time} = ['\' tmp{j,appData.consts.TF.time}];
        end
    end
    j1 = 0;
    tmp_=tmp;
    for j0 = 1 : r
%         if j0 == 41
%             j0
%         end
       if appData.TF.data{i}{j0,1} && ...
               strcmp(tmp{j0+j1, appData.consts.TF.functions}, appData.consts.TF.arbFuncStr)
           
           t0 = str2double(tmp{j0+j1, appData.consts.TF.time});
           valStr = tmp{j0+j1, appData.consts.TF.value};
           indEq = strfind(valStr, '=');
           indSt = strfind(valStr, '{');
           indEnd = strfind(valStr, '}');
           
           func = valStr(1:indSt-1);
           var = valStr(indSt+1:indEq-1);
           t = eval(['[' valStr(indEq+1:indEnd-1) ']' ]);
           dt = [diff([t0 t0+t])];
           t0_ = [t0 diff([t0 t0+t])];
           
           tmp( ((j0+1):r) +j1+length(t)+1,:) = tmp(((j0+1):r)+j1,:);
           tmp( (j0+j1+1):(j0+j1+length(t)+1),:) = cell(length(t)+1, c-1);
           
           % comment the Arb Func line
           tmp{j0+j1,appData.consts.TF.time} = ['\' tmp{j0+j1,appData.consts.TF.time}];
           
           for k = 1 : length(t)
               % add comment appData.consts.TF.arbFuncStr
               tmp{j0+j1+k, appData.consts.TF.comment} = appData.consts.TF.arbFuncStr;
               tmp{j0+j1+k, appData.consts.TF.time} = num2str(t0_(k));
               tmp{j0+j1+k, appData.consts.TF.devices} = tmp{j0+j1, appData.consts.TF.devices};
               tmp{j0+j1+k, appData.consts.TF.value} = num2str(eval(strrep(func, var, num2str(t(k)))));
               if ( dt(k) == 0 )
                   tmp{j0+j1+k, appData.consts.TF.functions} = 'step';
                   tmp{j0+j1+k, appData.consts.TF.variable} = '';                  
               else
                   tmp{j0+j1+k, appData.consts.TF.functions} = appData.consts.TF.rampFuncStr;
                   tmp{j0+j1+k, appData.consts.TF.variable} = num2str(dt(k));
               end
           end
           j1 = j1+length(t)+1;
           % add extra line to bring back the time (use 'Empty' device)
           tmp{j0+j1, appData.consts.TF.comment} = appData.consts.TF.arbFuncStr;
           tmp{j0+j1, appData.consts.TF.time} = num2str(-sum(dt(1:end-1)));
           tmp{j0+j1, appData.consts.TF.devices} = appData.consts.TF.emptyDeviceStr;
           tmp{j0+j1, appData.consts.TF.value} = '0';
           tmp{j0+j1, appData.consts.TF.functions} = 'step';
           
       end
    end
    tf(end+2:end+r+j1+1,:) = cell2table(tmp);
    
end

%global cycle time
% totTime = tf(3,4).tmp4{1};
totTimesStr = '0';
for i = 1 : size(tf, 1)-1
   tmpStr =  tf(i,2).tmp2{1};
   if isempty(tmpStr) || strcmp(tmpStr, 'External') || strcmp(tmpStr, '0') || tmpStr(1) == '\'
       continue;
   end
   totTimesStr = strcat(totTimesStr, ['+' num2str(tmpStr)]);
end
tf(end,2).tmp2{1} = [tf(3,4).tmp4{1} '-(' totTimesStr ')'];


fName1 = [];
if strcmp(object.String, appData.TFui.pbSaveAsTF.String)
    [FileName,PathName,FilterIndex] = uiputfile([appData.save.saveDir '\*.fra'], '*.fra');
    fName = [PathName FileName];
else
    fName = appData.consts.defaultStrLVFile_Load;
    fName1 = appData.consts.defaultStrLVFile_Save;
end

if fName
    writetable(tf, fName, 'FileType', 'text', 'delimiter', '\t', 'WriteVariableNames', false);
end
if fName1
    writetable(tf, fName1, 'FileType', 'text', 'delimiter', '\t', 'WriteVariableNames', false);
end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tblArr_CellSelectionCallback(object, eventdata) %#ok<INUSL>

appData.TF.currentCell = eventdata.Indices; 
if isempty(appData.TF.currentCell)
    appData.TF.currentCell = [0 0];
end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tblArr_CellEditCallback(object, eventdata) %#ok<INUSL>

r = eventdata.Indices(1);
c = eventdata.Indices(2);

if c == 1
    if r == 1
        if eventdata.NewData == 0
            object.BackgroundColor = [0.75 0.75 0.75];
        else
            object.BackgroundColor = [1 1 1; 0.9 0.9 0.9];
        end
    end
    appData.TF.data{appData.TF.currentTab}{r, 1} = eventdata.NewData;
    
    if eventdata.NewData == 1
        appData.TF.data{appData.TF.currentTab}{r, 3} = appData.TF.data{appData.TF.currentTab}{r, 3}(2:end);
    elseif eventdata.NewData == 0
        appData.TF.data{appData.TF.currentTab}{r, 3} = ['\' appData.TF.data{appData.TF.currentTab}{r, 3}];
    else
        errordlg('New data not 0 nor 1!', 'New Data Out Of Range', 'modal');
    end
    appData.TFui.tblArr{appData.TF.currentTab}.Data{r, 3} = appData.TF.data{appData.TF.currentTab}{r, 3};
    
    

elseif c == 3
    appData.TF.data{appData.TF.currentTab}{r, 3} = eventdata.NewData;
    if ~isempty(eventdata.NewData) && eventdata.NewData(1)=='\'
        appData.TF.data{appData.TF.currentTab}{r, 1} = false;
    else
        appData.TF.data{appData.TF.currentTab}{r, 1} = true;
    end
    appData.TFui.tblArr{appData.TF.currentTab}.Data{r, 1} = appData.TF.data{appData.TF.currentTab}{r, 1};

else
    appData.TF.data{appData.TF.currentTab}{r, c} = eventdata.NewData;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbRemoveTab_Callback(object, eventdata) %#ok<INUSL>

answer = inputdlg('Which Tab to remove?', 'Remove Tab', 1, {num2str(appData.TF.currentTab)});
if isempty(answer)
    return
end
tb = str2double(answer);
if isempty(tb) || tb<1
    errordlg('''Tab Number'' should be a positive number', 'Input Error', 'modal');
    return
end
if tb>length(appData.TF.tabNames)
    errordlg('''Tab Number'' too big, no such tab', 'Input Error', 'modal');
    return
end
    
data = appData.TF.data;
names = appData.TF.tabNames;
appData.TF.data = {};
appData.TF.tabNames = {};
ind = 1;
for i = 1 : length(data)
    if i ~= tb
        appData.TF.data{ind} = data{i};
        appData.TF.tabNames{ind} = names{i};
        ind = ind + 1;
    end
end

appData = updateTabs(appData, length(appData.TF.data));
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbAddTab_Callback(object, eventdata) %#ok<INUSL>

answer = inputdlg({'New Tab Name' 'New Tab Position'}, 'New Tab', 1, {'New Tab Name' num2str(appData.TF.currentTab)});  
tabName = answer{1};
tabPos = str2double(answer{2});
if isempty(tabPos) || tabPos < 1
    errordlg('''New Tab Position'' should be a positive number', 'Input Error', 'modal');
    return
end
if tabPos > length(appData.TF.tabNames)+1
    errordlg('''New Tab Position'' too big', 'Input Error', 'modal');
    return
end
    
data = appData.TF.data;
names = appData.TF.tabNames;
appData.TF.data = {};
appData.TF.tabNames = {};
ind = 1;
for i = 1 : length(data)+1
    if i ~= tabPos
        appData.TF.data{i} = data{ind};
        appData.TF.tabNames{i} = names{ind};
        ind = ind + 1;
    else
        appData.TF.data{i} = {false tabName [] [] [] [] [] []};
        appData.TF.tabNames{i} = tabName;
    end
end

appData = updateTabs(appData, length(appData.TF.data));
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbRemoveLine_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Which Line to remove?', 'Remove line', 1, {num2str(appData.TF.currentCell(:, 1)')});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln) > size(appData.TF.data{appData.TF.currentTab}, 1)
    errordlg('''Line Number'' too big, no such line', 'Input Error', 'modal');
    return
end

tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)-length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)
    if ~sum(i == ln)%i ~= ln(j)
        appData.TF.data{appData.TF.currentTab}(ind, :) = tbl(i,:);
        ind = ind + 1;
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbAddLine_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Where to add the new line?', 'Remove line', 1, {num2str(appData.TF.currentCell(1))});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2 
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln)>size(appData.TF.data{appData.TF.currentTab},1)+1
    errordlg('Cannot add more than 1 line', 'Input Error', 'modal');
    return
end

tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)+length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)+length(ln)
    if ~sum(i == ln)
        appData.TF.data{appData.TF.currentTab}(i,:) = tbl(ind,:);
        ind = ind + 1;
    else
        appData.TF.data{appData.TF.currentTab}(i,:) = {false [] '\' [] [] [] [] []};
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbCut_Callback(object, eventdata) %#ok<INUSL>

answer = inputdlg('Which Line to cut?', 'Remove line', 1, {num2str(appData.TF.currentCell(:, 1)')});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln) > size(appData.TF.data{appData.TF.currentTab}, 1)
    errordlg('''Line Number'' too big, no such line', 'Input Error', 'modal');
    return
end

tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)-length(ln), size(tbl,2));
mem = cell(length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)
    if ~sum(i == ln)
        appData.TF.data{appData.TF.currentTab}(ind, :) = tbl(i,:);
        ind = ind + 1;
    else
        mem(i-ind+1, :) = tbl(i,:);
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbCopy_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Which Line to copy?', 'Remove line', 1, {num2str(appData.TF.currentCell(:, 1)')});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln) > size(appData.TF.data{appData.TF.currentTab}, 1)
    errordlg('''Line Number'' too big, no such line', 'Input Error', 'modal');
    return
end

mem = cell(length(ln), size(appData.TF.data{appData.TF.currentTab},2));
ind = 1;
for i = 1 : size(appData.TF.data{appData.TF.currentTab}, 1)
    if sum(i == ln)
        mem(ind, :) = appData.TF.data{appData.TF.currentTab}(i,:);
        ind = ind + 1;
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbPaste_Callback(object, eventdata) %#ok<INUSL>
    
answer = inputdlg('Where to paste the new line?', 'Remove line', 1, {num2str(appData.TF.currentCell(1))});
if isempty(answer)
    return
end
ln = str2num(answer{1});
if isempty(ln) || min(ln)<2 
    errordlg('''Line Number'' should be a number larger than 1', 'Input Error', 'modal');
    return
end
if max(ln)>size(appData.TF.data{appData.TF.currentTab},1)+1
    errordlg('Cannot add more than 1 line', 'Input Error', 'modal');
    return
end
if length(ln) > 1
    errordlg('Input only one number, for the first line', 'Input Error', 'modal');
    return
end

ln = [ln : ln+size(mem, 1)-1];
tbl = appData.TF.data{appData.TF.currentTab};
appData.TF.data{appData.TF.currentTab} = cell(size(tbl,1)+length(ln), size(tbl,2));
ind = 1;
for i = 1 : size(tbl, 1)+length(ln)
    if ~sum(i == ln)
        appData.TF.data{appData.TF.currentTab}(i,:) = tbl(ind,:);
        ind = ind + 1;
    else
        appData.TF.data{appData.TF.currentTab}(i,:) = mem(i-ind+1, :);
    end
end

appData.TFui.tblArr{appData.TF.currentTab}.Data = appData.TF.data{appData.TF.currentTab};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pbQuickLoop_Callback(object, eventdata) %#ok<INUSL>
set(appData.ui.pmAvailableLoops, 'Value', appData.consts.availableLoops.TFQuickLoop);
pbAddMeasurement_Callback(appData.ui.pmAvailableLoops, []) %#ok<INUSD>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function appData = updateTabs(appData, nTables)

appData.TFui.tabArr = zeros(1, nTables);
appData.TFui.tblArr = cell(1, nTables);
appData.TFui.tgTimeframe = uitabgroup('Parent', appData.TFui.win, ...
    'Units', 'normalized', ...
    'Position', [0 0.05 1 0.95], ...
    'TabLocation', 'top', ...
    'SelectionChangedFcn', {@tgTimeframe_Callback});
for i = 1 : nTables
    appData.TFui.tabArr(i) = uitab('Parent', appData.TFui.tgTimeframe, ...
        'Title',  appData.TF.tabNames{i}, ...
        'Units', 'normalized');
    appData.TFui.tblArr{i} = uitable(appData.TFui.tabArr(i), ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1], ...
        'FontSize', appData.consts.TF.fontSize, ...
        'ColumnWidth', appData.consts.TF.colimnWidth, ...
        'ColumnEditable', true, ...
        'ColumnName',appData.consts.TF.columnName, ...
        'ColumnFormat', appData.TF.columnFormat, ...
        'UserData', appData.TF.data{i}, ...
        'data', appData.TF.data{i}, ...
        'BackgroundColor', [1 1 1; 0.9 0.9 0.9], ...
        'CellEditCallback', {@tblArr_CellEditCallback}, ...
        'CellSelectionCallback', {@tblArr_CellSelectionCallback});
end

appData.TF.currentTab = 1;

end


end
% end imaging function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



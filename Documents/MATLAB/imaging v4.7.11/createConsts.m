
function appData = createConsts(appData)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defaults 

appData.consts.plotTypes.default = 1;
appData.consts.ROIUnits.default = 3;
appData.consts.ROIUnits.defaultSizeX = 0.025;
appData.consts.ROIUnits.defaultSizeY = 0.04;
appData.consts.ROIUnits.defaultCenX = 0.435;
appData.consts.ROIUnits.defaultCenY = 0.16;
appData.consts.calcAtomsNo.default = 1;
appData.consts.plotSetting.default = 2;
appData.consts.saveParams.default = 1;
appData.consts.saveParamValDefault = 0;

appData.consts.defaultAvgWidth = 2; %on each side
appData.consts.maxAvgWidth = 8;
appData.save.defaultDir = 'C:\Data\';
% appData.save.defaultDir = ['F:\My Documents\Experimental\' datestr(now, 29)];%'C:\Documents and Settings\broot\Desktop\shimi';
appData.consts.defaultStrLVFile_Save = '\\MAGSTORE\magstore\data\External\timeframe_template.fra';%timeframe.csv'; %'D:\My Documents\MATLAB\lv data.txt';
appData.consts.defaultStrLVFile_SaveLast = '\\MAGSTORE\magstore\data\External\timeframe_Last.csv';
appData.consts.defaultStrLVFile_Load = '\\MAGSTORE\magstore\data\External\timeframe_MATLAB.fra'; %'D:\My Documents\MATLAB\lv data.txt';
appData.consts.defaultDetuning = 0;
appData.consts.defaultDoPlot = 1;

appData.consts.winXPos = 1;
appData.consts.winYPos = 65;
% appData.consts.ftpAddress = '132.72.8.2';
% appData.consts.ftpDir = 'LabViewProjects/Ramp_Integration/Interface39.5/TXT/';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loops
appData.consts.availableLoops.str = {'Quick Loop' 'Gen. Loop'};%{'Gen. Loop' 'TOF', 'LT' 'SG'};%, 'Heating', 'SG'};
appData.consts.availableLoops.TFQuickLoop = 1;
appData.consts.availableLoops.TFGeneralLoop = 2;
% appData.consts.availableLoops.generalLoop = 1;
% appData.consts.availableLoops.TOF = 2;
% appData.consts.availableLoops.LT = 3;
% % appData.consts.availableLoops.heating = 4;
% appData.consts.availableLoops.SG = 4;
appData.consts.availableLoops.createFncs = {@QuickLoop.create, @GeneralLoopTF.create};%{@GeneralLoop.create, @TOF.create, @LT.create, @SternGerlach.create};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loops defaults
appData.consts.loops.iterationsStr = {'Iterate Measurement' 'Iterate Loop' 'Random Iterations'};
appData.consts.loops.options = struct('Interpreter', 'tex', 'WindowStyle', 'normal', 'Resize', 'off');

% appData.consts.loops.TOF.noIterations = '1';
% appData.consts.loops.TOF.TOFTimes = '3:1:15';
% 
% appData.consts.loops.LT.noIterations = '1';
% appData.consts.loops.LT.LTTimes = '[0:1:20]*1e3';
% 
% appData.consts.loops.SG.noIterations = '1';
% appData.consts.loops.SG.SGTimes = '[0:1:20]*1e3';
% appData.consts.loops.SG.RFRampNo = 15;
% appData.consts.loops.SG.RFRampNo = 18;

appData.consts.loops.GenLoop.saveFolder = 'F:\My Documents\Experimental\Loops';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cameras

appData.consts.cameraTypes.str = {'Andor', 'IDS - main', 'IDS - second', 'prosilica',  'prosilica-c', 'AMS'};
appData.consts.cameraTypes.andor = 1;
appData.consts.cameraTypes.idsMain = 2;
appData.consts.cameraTypes.idsSecond = 3;
appData.consts.cameraTypes.prosilica = 4;
appData.consts.cameraTypes.prosilicaC= 5;
appData.consts.cameraTypes.AMS= 6;
appData.consts.cameraTypes.default = 6;

appData.consts.cameras{appData.consts.cameraTypes.andor}.string = 'Andor';
appData.consts.cameras{appData.consts.cameraTypes.andor}.dir = 'C:\Documents and Settings\broot\Desktop\shimi';
appData.consts.cameras{appData.consts.cameraTypes.andor}.fileName = 'tmpPic';
appData.consts.cameras{appData.consts.cameraTypes.andor}.fileFormat = 'i32';
appData.consts.cameras{appData.consts.cameraTypes.andor}.fileReadFunction = @andorReadFunction;
appData.consts.cameras{appData.consts.cameraTypes.andor}.darkPicStr = 'andorDark.bmp';
appData.consts.cameras{appData.consts.cameraTypes.andor}.magnification = 500/150;%3/5;
appData.consts.cameras{appData.consts.cameraTypes.andor}.xPixSz = ...
    16e-6 / appData.consts.cameras{appData.consts.cameraTypes.andor}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.andor}.yPixSz = ...
    16e-6 / appData.consts.cameras{appData.consts.cameraTypes.andor}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.andor}.width = 512;
appData.consts.cameras{appData.consts.cameraTypes.andor}.height = 512;
appData.consts.cameras{appData.consts.cameraTypes.andor}.rotate = 90;
appData.consts.cameras{appData.consts.cameraTypes.andor}.bits = 14;
appData.consts.cameras{appData.consts.cameraTypes.andor}.chipStart = 1;
appData.consts.cameras{appData.consts.cameraTypes.andor}.firstImageNo = 1;
appData.consts.cameras{appData.consts.cameraTypes.andor}.secondImageNo = 2;


appData.consts.cameras{appData.consts.cameraTypes.idsMain}.string = 'IDS - main';
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.dir =  '/Volumes/MacHD/Links/Documents/MATLAB/imaging v4.6.4_AMS';%'C:\Program Files\IDS\uEye\Samples'; %'D:\My Documents\MATLAB\imaging v4.3';%
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.fileName = 'uEye_Image_';
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.fileFormat = 'bmp';
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.fileReadFunction = @idsReadFunction;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.darkPicStr = 'dark.bmp';
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.magnification = 300/200;%100/300;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.xPixSz = ...
    6e-6 / appData.consts.cameras{appData.consts.cameraTypes.idsMain}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.yPixSz = ...
    6e-6 / appData.consts.cameras{appData.consts.cameraTypes.idsMain}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.width = 480;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.height = 752;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.rotate = 90;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.bits = 8;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.chipStart = 40;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.firstImageNo = 1;
appData.consts.cameras{appData.consts.cameraTypes.idsMain}.secondImageNo = 2;
% consts.cameras{consts.cameraTypes.ids} = ids;

appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.string = 'IDS - second';
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.dir = 'C:\Program Files\IDS\uEye\Samples';%'F:\Jonathan\Documents\MATLAB\';
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.fileName = 'uEye_Image_';
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.fileFormat = 'bmp';
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.fileReadFunction = @idsReadFunction;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.darkPicStr = 'dark.bmp';
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.magnification = 1/2.55;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.xPixSz = ...
    6e-6 / appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.yPixSz = ...
    6e-6 / appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.width = 480;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.height = 752;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.rotate = 90;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.bits = 8;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.chipStart = 135;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.firstImageNo = 1;
appData.consts.cameras{appData.consts.cameraTypes.idsSecond}.secondImageNo = 2;
% consts.cameras{consts.cameraTypes.ids} = ids;

appData.consts.cameras{appData.consts.cameraTypes.prosilica}.string = 'prosilica';
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.dir = 'C:\Program Files\Prosilica';
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.fileName = 'snap';
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.fileFormat = 'tiff';
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.fileReadFunction = @prosilicaReadFunction;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.darkPicStr = 'dark.bmp';
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.magnification = 300/200;%100/300;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.xPixSz = ...
    3.45e-6 / appData.consts.cameras{appData.consts.cameraTypes.prosilica}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.yPixSz = ...
    3.45e-6 / appData.consts.cameras{appData.consts.cameraTypes.prosilica}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.width = 2448;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.height = 1050;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.rotate = 0;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.bits = 16;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.chipStart =102;%was 131 before hight calibration
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.firstImageNo = 0;
appData.consts.cameras{appData.consts.cameraTypes.prosilica}.secondImageNo = 1;

appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.string = 'prosilica-c';
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.dir = 'C:\Documents and Settings\broot\Desktop\shimi\prosilica';
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.fileName = 'snap';
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.fileFormat = 'tiff';
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.fileReadFunction = @prosilicaCReadFunction;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.darkPicStr = 'dark.bmp';
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.magnification = 3.27;%100/300;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.xPixSz = ...
    3.45e-6 / appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.yPixSz = ...
    3.45e-6 / appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.magnification;
% appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.width = 480;
% appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.height = 752;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.rotate = 90;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.bits = 16;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.chipStart = 1;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.firstImageNo = 1;
appData.consts.cameras{appData.consts.cameraTypes.prosilicaC}.secondImageNo = 2;

appData.consts.cameras{appData.consts.cameraTypes.AMS}.string = 'AMS';
appData.consts.cameras{appData.consts.cameraTypes.AMS}.dir = '\\MAGSTORE\magstore\data\External';
% appData.consts.cameras{appData.consts.cameraTypes.AMS}.dir = '.';
appData.consts.cameras{appData.consts.cameraTypes.AMS}.fileName = 'pic';
appData.consts.cameras{appData.consts.cameraTypes.AMS}.fileFormat = 'pgm';
appData.consts.cameras{appData.consts.cameraTypes.AMS}.fileReadFunction = @AMSReadFunction;
% appData.consts.cameras{appData.consts.cameraTypes.AMS}.darkPicStr = 'Dark.bmp';
appData.consts.cameras{appData.consts.cameraTypes.AMS}.magnification = 13;%500/150;%3/5;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.xPixSz = ...
    13e-6 / appData.consts.cameras{appData.consts.cameraTypes.AMS}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.yPixSz = ...
    13e-6 / appData.consts.cameras{appData.consts.cameraTypes.AMS}.magnification;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.width = 1024;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.height = 376;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.rotate = 0;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.bits = 16;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.chipStart = 1;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.firstImageNo = 1;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.secondImageNo = 2;
appData.consts.cameras{appData.consts.cameraTypes.AMS}.darkImageNo = 3;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

appData.consts.calcAtomsNo.str = {'Real', 'Theoretical', 'Theoretical - Full'};
appData.consts.calcAtomsNo.real = 1;
appData.consts.calcAtomsNo.theoretical = 2;
appData.consts.calcAtomsNo.theoreticalFull = 3;
appData.consts.calcAtomsNo.calcs = { CalcReal CalcTheoretical CalcTheoreticalFull};%, Theoretical};
appData.consts.plotSetting.str = {'Default Setting', 'Last Setting'};
appData.consts.plotSetting.defaults = 1;
appData.consts.plotSetting.last = 2;


appData.consts.fitTypes.default = 24;
appData.consts.fitTypes.str = {'Only Maximum (mouse)', '1D Gaussian (mouse)', '2D Gaussian (mouse)', ...
    '1D Gauss+Hole (mouse)', '2D Gauss+Hole (mouse)', ...
    'Only Maximum', '1D Gaussian', '1D Gaussian (Only Y)', '2-1D Gaussian (Only Y)', '2D Gaussian', ...
    '1D TF', '1D TF (Only Y)', '2D TF', '1D BiModal', '2D BiModal', 'Stern-Gerlach', 'FFT', 'Fringes (only Y)', 'XY Cut', ...
    'Create Fit Sites', 'Fit Sites', 'Create Mask Sites', 'Create Mask Sites (PSF)', 'Only Max (Norm)', '4 2D Gauss.', '4 1D Gauss.', 'Only Max Y-Cuts', ...
    'Only Max X-Cuts'};%, '2 1D Gaussians'};
appData.consts.fitTypes.onlyMaxMouse = 1;
appData.consts.fitTypes.oneDGaussianMouse = 2;
appData.consts.fitTypes.twoDGaussianMouse = 3;
appData.consts.fitTypes.oneDGaussianHoleMouse = 4;
appData.consts.fitTypes.twoDGaussianHoleMouse = 5;
appData.consts.fitTypes.onlyMaximum = 6;
appData.consts.fitTypes.oneDGaussian = 7;
appData.consts.fitTypes.oneDGaussianOnlyY = 8;
appData.consts.fitTypes.twoOneDGaussianOnlyY = 9;
appData.consts.fitTypes.twoDGaussian = 10;
appData.consts.fitTypes.oneDTF = 11;
appData.consts.fitTypes.oneDTFOnlyY = 12;
appData.consts.fitTypes.twoDTF = 13;
appData.consts.fitTypes.oneDBiModal = 14;
appData.consts.fitTypes.twoDBiModal = 15;
appData.consts.fitTypes.SG = 16;
appData.consts.fitTypes.FFT = 17;
appData.consts.fitTypes.fringesY = 18;
appData.consts.fitTypes.XYCut = 19;
appData.consts.fitTypes.createSites = 20;
appData.consts.fitTypes.sites = 21;
appData.consts.fitTypes.createMaskedSites = 22;
appData.consts.fitTypes.createMaskedSitesPSF = 23;
appData.consts.fitTypes.onlyMaxNorm = 24;
appData.consts.fitTypes.four2DGaussians = 25;
appData.consts.fitTypes.fourGaussians = 26;
appData.consts.fitTypes.onlyMaxYCuts = 27;
appData.consts.fitTypes.onlyMaxXCuts = 28;
appData.consts.fitTypes.fits = {FitOnlyMaxMouse, Fit1DGaussianMouse, Fit2DGaussianMouse, Fit1DGaussianHoleMouse, ...
    Fit2DGaussianHoleMouse, FitOnlyMax, Fit1DGaussian, Fit1DGaussianOnlyY, ...
    Fit21DGaussianOnlyY, Fit2DGaussian, FitThomasFermi1D, FitThomasFermi1DOnlyY, FitThomasFermi2D, ...
    FitBiModal1D, FitBiModal2D, FitSternGerlach, FitFFT, FitFringesY, FitXYCut, FitSitesFull, FitSites,...
    FitSitesMask, FitSitesMask_PSF, FitOnlyMaxNorm, Fit2D4Gaussian, Fit4Gaussian, FitOnlyMaxYCuts, FitOnlyMaxXCuts};%, Fit21DGaussian};

appData.consts.plotTypes.str = {'Absorption', 'ROI', 'With Atoms', 'Without Atoms', 'Fringe Removal Ref' ,'Dark'};
appData.consts.plotTypes.absorption = 1;
appData.consts.plotTypes.ROI = 2;
appData.consts.plotTypes.withAtoms = 3;
appData.consts.plotTypes.withoutAtoms = 4;
appData.consts.plotTypes.FR = 5;
appData.consts.plotTypes.dark = 6;
appData.consts.plotTypes.plots = {Absorption, ROI, WithAtoms, WithoutAtoms, FringeRemovalRef, Dark};

appData.consts.ROIUnits.str = {'Sigma (Sx Sy)', 'mm (Sx Sy)', 'Size [mm] (Sx Sy Cx Cy)'};
appData.consts.ROIUnits.sigma = 1;
appData.consts.ROIUnits.mm = 2;
appData.consts.ROIUnits.size = 3;
appData.consts.ROIUnits.ROITypes = {Sigma, MM, Size};

appData.consts.availableMonitoring.str = {'Atoms Num.', 'OD', 'X Position', 'Y Position', 'X Width', 'Y Width'}; % when adding, change appData.monitoring.monitoringData size
appData.consts.availableMonitoring.atomNum = 1;
appData.consts.availableMonitoring.OD = 2;
appData.consts.availableMonitoring.xPos = 3;
appData.consts.availableMonitoring.yPos = 4;
appData.consts.availableMonitoring.xWidth = 5;
appData.consts.availableMonitoring.yWidth = 6;

appData.consts.saveParams.str = {'Other...', 'Red Detuning [MHz]', 'Blue Detuning [MHz]', 'Probe Detuning [MHz]', 'Lens Voltage [V]', ...
    'Z Wire [A]', ...
    'TOF [ms]', 'Dark Time [ms]', 'Pulse Time [ms]', 'X-Bias', 'RF freq [MHz]','Osc time [ms]', ...
    'time [ms]', 'time [us]', 'current [A]', 'voltage [V]', 'frequency [Mhz]', 'frequency [kHz]', 'Other Param'};
appData.consts.saveParams.other = 1;
appData.consts.saveParams.RedDet = 2;
appData.consts.saveParams.BlueDet = 3;
appData.consts.saveParams.ProbeDet = 4;
appData.consts.saveParams.LensV = 5;
appData.consts.saveParams.ZWire = 6;
appData.consts.saveParams.TOF = 7;
appData.consts.saveParams.darkTime = 8;
appData.consts.saveParams.pulseTime = 9;
appData.consts.saveParams.XBias = 10;
appData.consts.saveParams.RFfreq = 11;
appData.consts.saveParams.OscTime = 12;
appData.consts.saveParams.time_ms = 13;
appData.consts.saveParams.time_us = 14;
appData.consts.saveParams.current_A = 15;
appData.consts.saveParams.voltage_V = 16;
appData.consts.saveParams.frequency_MHz = 17;
appData.consts.saveParams.frequency_kHz = 18;
appData.consts.saveParams.otherParam = 19; %ALWAYS the last
appData.consts.saveOtherParamStr = '';
appData.consts.commentStr = '';

appData.consts.availableAnalyzing.str = {'Temperature', 'Heating', 'Gravity', 'Life Time (1 exp)', 'Life Time (2 exp)', 'Damped Sine (y)', ...
    'Atom No', 'Atom No (hole)', 'OD', 'OD (hole)' 'X Position', 'Y Position', 'Size X', 'Size Y', 'Delta_y', 'Pic Mean','SG', 'mF1', 'SG Y Position', 'FFT', '1D STD', 'g2', 'lambda', 'phi', ...
    'Visibility', 'Norm Atom No (hole)', 'Atom No (Per Site)', 'Atom No (Per Site, PSF)', 'Lorentzian Fit (Per Site)', 'Trap Bottom and Temp Fit (Per Site)', 'Lorentzian Fit', ...
    'Trap Bottom and Temp Fit' '2 ROI Atom No (Normalized Fit)' 'Only Max Y-Cuts' 'Only Max X-Cuts'};
appData.consts.availableAnalyzing.temperature = 1;
appData.consts.availableAnalyzing.heating = 2;
appData.consts.availableAnalyzing.gravity = 3;
appData.consts.availableAnalyzing.lifeTime1 = 4;
appData.consts.availableAnalyzing.lifeTime2 = 5;
appData.consts.availableAnalyzing.dampedSine = 6;
appData.consts.availableAnalyzing.atomNo = 7;
appData.consts.availableAnalyzing.atomNo2 = 8;
appData.consts.availableAnalyzing.OD = 9;
appData.consts.availableAnalyzing.OD2 = 10;
appData.consts.availableAnalyzing.xPos = 11;
appData.consts.availableAnalyzing.yPos = 12;
appData.consts.availableAnalyzing.sizeX = 13;
appData.consts.availableAnalyzing.sizeY = 14;
appData.consts.availableAnalyzing.deltaY_2 = 15;
appData.consts.availableAnalyzing.picMean = 16;
appData.consts.availableAnalyzing.SG = 17;
appData.consts.availableAnalyzing.mF1 = 18;
appData.consts.availableAnalyzing.SGyPos = 19;
appData.consts.availableAnalyzing.FFT = 20;
appData.consts.availableAnalyzing.oneDstd = 21;
appData.consts.availableAnalyzing.g2 = 22;
appData.consts.availableAnalyzing.lambda = 23;
appData.consts.availableAnalyzing.phi = 24;
appData.consts.availableAnalyzing.visibility = 25;
appData.consts.availableAnalyzing.normAtomNo = 26;
appData.consts.availableAnalyzing.atomNoPerSite = 27;
appData.consts.availableAnalyzing.atomNoPerSite_PSF = 28;
appData.consts.availableAnalyzing.LorentzFitPerSite = 29;
appData.consts.availableAnalyzing.TrapBottomFitPerSite = 30;
appData.consts.availableAnalyzing.LorentzFit = 31;
appData.consts.availableAnalyzing.TrapBottomFit = 32;
appData.consts.availableAnalyzing.twoROIAtomNo = 33;
appData.consts.availableAnalyzing.onlyMaxYCuts = 34;
appData.consts.availableAnalyzing.onlyMaxXCuts = 35;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file = idsReadFunction(appData, num)
if ( strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.idsMain}) ~= 1 && ...
        strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.idsSecond}) ~= 1 )
    warndlg('Trying to read IDS file.', 'Warning', 'nonmodal');
end
fileName = [appData.data.camera.dir appData.slash appData.data.camera.fileName  num2str(num) '.' appData.data.camera.fileFormat];
file = imread(fileName, appData.data.camera.fileFormat);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file = AMSReadFunction(appData, num)
if ( strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.AMS}) ~= 1 && ...
        strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.AMS}) ~= 1 )
    warndlg('Trying to read AMS file.', 'Warning', 'nonmodal');
end
fileName = [appData.data.camera.dir appData.slash appData.data.camera.fileName  num2str(num) '.' appData.data.camera.fileFormat];
file = imread(fileName, appData.data.camera.fileFormat);
if (size(size(file),2) == 3)
    file = rgb2gray(file);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file = prosilicaReadFunction(appData, num)
if ( strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.prosilica}) ~= 1 )
    warndlg('Trying to read Prosilica file.', 'Warning', 'nonmodal');
end
fileName = [appData.data.camera.dir '\' appData.data.camera.fileName  num2str(num) '.' appData.data.camera.fileFormat];
file = imread(fileName, appData.data.camera.fileFormat)/2^4;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file = prosilicaCReadFunction(appData, num)
if ( strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.prosilicaC}) ~= 1 )
    warndlg('Trying to read Prosilica-c file.', 'Warning', 'nonmodal');
end
fileName = [appData.data.camera.dir '\' appData.data.camera.fileName  num2str(num) '.' appData.data.camera.fileFormat];
file = imread(fileName, appData.data.camera.fileFormat);
file=file(:,:,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function file = andorReadFunction(appData, num)
if ( strcmp(appData.data.camera.string, appData.consts.cameraTypes.str{appData.consts.cameraTypes.andor}) ~= 1)
    warndlg('Trying to read ANdor file.', 'Warning', 'nonmodal');
end
fileName = [appData.data.camera.dir '\' appData.data.camera.fileName  num2str(num) '.' appData.data.camera.fileFormat];
% file = imread(fileName);
fid = fopen(fileName);
file = fread(fid, [512 512], 'uint32');
fclose(fid);
end


end




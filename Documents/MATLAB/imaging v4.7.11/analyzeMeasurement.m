function appData = analyzeMeasurement(appData, folder)

saveFolder = appData.analyze.readDir;
% saveFolder = appData.analyze.totAppData{1}.save.saveDir;

for ( i = 1 : length(appData.analyze.currentAnalyzing) ) %#ok<*NO4LP>
    if isempty(appData.analyze.totAppData{i}.save.saveOtherParamStr)
        xlabelStr = appData.analyze.totAppData{i}.consts.saveParams.str{appData.analyze.totAppData{i}.save.saveParam};
    else
        xlabelStr = appData.analyze.totAppData{i}.save.saveOtherParamStr;
        if iscell(xlabelStr)
            xlabelStr = xlabelStr{:};
        end
    end
    switch appData.analyze.currentAnalyzing(i)
        case appData.consts.availableAnalyzing.temperature
            %                 [graphs(i) results{i}]  = temperature2(appData.analyze.totAppData);
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
%             [B, I] = sort(val);
            [val, I] = sort(val);
%             I = 1:length(val);
            figure( 'FileName', [saveFolder '_atomNo.fig']);
            plot(val, N(I));
            xlabel(xlabelStr);
            ylabel('Atoms Number');
        case appData.consts.availableAnalyzing.atomNo2
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNo2; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_atomNo(hole).fig']);
            [val, I] = sort(val);
            plot(val, N(I));
            xlabel(xlabelStr);
            ylabel('Atoms Number (hole)');
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
            figure( 'FileName', [saveFolder '_OD.fig']);
            [val, I] = sort(val);
            plot(val, N(I));
            xlabel(xlabelStr);
            ylabel('Max Val');
        case appData.consts.availableAnalyzing.OD2
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.OD2; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_OD(hole).fig']);
            [val, I] = sort(val);
            plot(val, N(I));
            xlabel(xlabelStr);
            ylabel('OD (hole)');
        case appData.consts.availableAnalyzing.xPos
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                %                     xPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.xCenter ...
                %                         * appData.analyze.totAppData{j}.data.camera.xPixSz *1000; %#ok<AGROW>
                xPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.xCenter ...
                    * appData.analyze.totAppData{j}.data.camera.xPixSz *1000; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_xPos.fig']);
            [val, I] = sort(val);
            plot(val, xPos(I));
            xlabel(xlabelStr);
            ylabel('X Position [mm]');
        case appData.consts.availableAnalyzing.yPos
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                %                     if isfield(appData.analyze.totAppData{j}.data.fits{ fitType }, 'y0')
                yPos(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.yCenter ...
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
            figure( 'FileName', [saveFolder '_yPos.fig']);
            [val, I] = sort(val);
            plot(val, yPos(I));
            xlabel(xlabelStr);
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
            figure( 'FileName', [saveFolder '_sizeX.fig']);
            [val, I] = sort(val);
            plot(val, szX(I));
            xlabel(xlabelStr);
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
            figure( 'FileName', [saveFolder '_sizeY.fig']);
            [val, I] = sort(val);
            plot(val, szY(I));
            xlabel(xlabelStr);
            ylabel('Size Y [mm]');
        case appData.consts.availableAnalyzing.deltaY_2
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                Delta_Y2(j) = 0.5*abs(appData.analyze.totAppData{j}.data.fits{ fitType }.y02-appData.analyze.totAppData{j}.data.fits{ fitType }.y01)...
                    * appData.analyze.totAppData{j}.data.camera.yPixSz *1000; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
             if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_deltaY.fig']);
            [val, I] = sort(val);
            plot(val,  Delta_Y2(I));
            xlabel(xlabelStr);
            ylabel('\Deltay/2  [mm]');
        case appData.consts.availableAnalyzing.picMean
            paramVals = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            [vals, ind, invInd] = unique(paramVals, 'stable');
            
            % there are a few param values
            if length(vals) > 1
                str1 = 'Global';
                str2 = 'By Value';
                btn = questdlg('Do global averaging or by ''Param Value''?','Pic Averaging',str1, str2, str1);
                if strcmp(btn, str1)
                    vals = 0;
                    paramVals = zeros(1, length(appData.analyze.totAppData));
                else %strcmp(btn, str2)
                    folder = [appData.analyze.readDir appData.slash 'averages'];
                    [status,message,messageid] = mkdir(folder);
                    if ~status
                        errordlg('Cannot make ''averages'' folder', 'Error', 'modal');
                        return
                    end
                end
            end
            
            for i = 1 : length(vals)
                pic = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.absorption}.pic));
                atoms = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withAtoms}.pic));
                back = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic));
                dark = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.dark}.pic));
                if isempty(pic)
                    errordlg('There is no data in the files. Use f when reading the files.','Error', 'modal');
                    return;
                end
                k = find(paramVals == vals(i));
                for ( j = 1 : length(k)) %length(appData.analyze.totAppData)  )
                    pic = pic + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.absorption}.pic;
                    atoms = atoms + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.withAtoms}.pic;
                    back = back + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;
                    dark = dark + appData.analyze.totAppData{k(j)}.data.plots{appData.consts.plotTypes.dark}.pic;
                end
                pic = pic / length(k);
                atoms = atoms / length(k);
                back = back / length(k);
                dark = dark / length(k);
                appData = appData.data.plots{appData.consts.plotTypes.absorption}.setPic(appData, [ zeros(appData.data.camera.chipStart-1, size(pic, 2)) ;pic]);
                appData = appData.data.plots{appData.consts.plotTypes.withAtoms}.setPic(appData, atoms);
                appData = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.setPic(appData, back);
                appData = appData.data.plots{appData.consts.plotTypes.dark}.setPic(appData, dark);
                
                %                 appData.data.plots{1}.pic = pic;
                appData.data.fits = appData.consts.fitTypes.fits;
                appData = analyzeAndPlot(appData);
                
                if length(vals) > 1
                    savedData = createSavedData(appData);  %#ok<NASGU>
                    savedData.save.saveParamVal = vals(i);
                    save([folder appData.slash 'data-' num2str(appData.analyze.totAppData{ind(i)}.save.picNo) ...
                        '-paramVal ' num2str(vals(i)) '.mat'], 'savedData', appData.consts.saveVersion);
                end
                
            end
%             pic = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.absorption}.pic));
%             atoms = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withAtoms}.pic));
%             back = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic));
%             dark = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.dark}.pic));
%             if isempty(pic)
%                 errordlg('There is no data in the files. Use f when reading the files.','Error', 'modal');
%                 continue;
%             end
%             for ( j = 1 : length(appData.analyze.totAppData)  )
%                 pic = pic + appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.absorption}.pic;
%                 atoms = atoms + appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.withAtoms}.pic;
%                 back = back + appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.withoutAtoms}.pic;
%                 dark = zeros(size(appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.dark}.pic));
%             end
%             pic = pic / length(appData.analyze.totAppData);
%             atoms = atoms / length(appData.analyze.totAppData);
%             back = back / length(appData.analyze.totAppData);
%             dark = dark / length(appData.analyze.totAppData);
%             appData = appData.data.plots{appData.consts.plotTypes.absorption}.setPic(appData, [ zeros(appData.data.camera.chipStart-1, size(pic, 2)) ;pic]);
%             appData = appData.data.plots{appData.consts.plotTypes.withAtoms}.setPic(appData, atoms);
%             appData = appData.data.plots{appData.consts.plotTypes.withoutAtoms}.setPic(appData, back);
%             appData = appData.data.plots{appData.consts.plotTypes.dark}.setPic(appData, dark);
%             
%             %                 appData.data.plots{1}.pic = pic;
%             appData.data.fits = appData.consts.fitTypes.fits;
%             appData = analyzeAndPlot(appData);

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
            figure( 'FileName', [saveFolder '_mF1.fig']);
            plot(val,  N, 'o');
            %                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
            %                 xlabel(xlabelstr{appData.analyze.totAppData{1}.save.saveParamVal});
            xlabel(xlabelStr);
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
            
            [path, name, ext] = fileparts(saveFolder);
            export2wsdlg({'mF=1:' 'mF=2:'}, {[name '_mF1'] [name '_mF2']}, {out1 out2});
            
            figure( 'FileName', [saveFolder '_mF1.fig']);
            plot(out1.res, 'r', val, yPos1, 'ob');
            title(['mF=1, (' name ')'], 'interpreter', 'none');
            xlabel('time [ms]');
            ylabel('Y Position [mm]');
            legend({['mF=1, (' name ')'],['fit mF=1, (' name ')']},'interpreter', 'none');
            figure( 'FileName', [saveFolder '_mF2.fig']);
            plot(out2.res, 'b', val, yPos2, 'or');
            title(['mF=2, (' name ')'], 'interpreter', 'none');
            xlabel('time [ms]');
            ylabel('Y Position [mm]');
            legend({['mF=2, (' name ')'], ['fit mF=2, (' name ')']},'interpreter', 'none');
            
            %                 [path, name, ext] = fileparts(saveFolder);
            %                 export2wsdlg({'mF=1:' 'mF=2:'}, {[name '_mF1'] [name '_mF2']}, {out1 out2});
            
        case appData.consts.availableAnalyzing.FFT
            fitType = appData.analyze.totAppData{1}.data.fitType;
            w = length(abs(appData.data.fits{fitType}.xData_k));
            data_k = zeros(length(appData.analyze.totAppData), w);
            k = appData.data.fits{fitType}.k;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                data_k(j, :) = appData.data.fits{fitType}.xData_k;
            end
            figure('FileName', [saveFolder '_fft.fig']);
            plot(k(round(w/2):w), sqrt(sum(abs(data_k(:, round(w/2):w)).^2,1)));
            
            %                 [pic x0 y0] = appData.analyze.totAppData{1}.data.plots{appData.consts.plotTypes.absorption }.getPic();
            %                 [h w] = size(pic);
            %                 data_k = zeros(length(appData.analyze.totAppData), w);
            %                 for ( j= 1 : length(appData.analyze.totAppData)  )
            %                     [xData yData] = ...
            %                         appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.absorption }.getXYDataVectors(...
            %                         appData.analyze.totAppData{j}.data.fits{ fitType }.xCenter, appData.analyze.totAppData{j}.data.fits{ fitType }.yCenter, ...
            %                         appData.analyze.totAppData{j}.options.avgWidth);
            %                     [pic x0 y0] = appData.analyze.totAppData{j}.data.plots{appData.consts.plotTypes.absorption }.getPic();
            %                     [h w] = size(pic);
            %                     x = [1 : w];
            %                     y = [1 : h];
            %                     [xFit yFit] = appData.data.fits{appData.data.fitType}.getXYFitVectors(x+x0-1, y+y0-1);
            %                     data = xData-xFit(1, :);
            %                     dx = appData.analyze.totAppData{j}.consts.cameras{appData.analyze.totAppData{j}.options.cameraType}.xPixSz;
            %                     x = dx*[-w/2:w/2-1]; %dx*[-Nx/2:Nx/2-1];
            %                     dk = 2*pi/dx/w; %2*pi/dx/Nx;
            %                     k = dk*[-w/2:w/2-1]; %dk*[-Nx/2:Nx/2-1];
            %                     data_k(j, :)=fftshift(fft(fftshift(data)));
            % %                     figure; plot(k, abs(data_k(j, :)));
            %                 end
            %                 figure('FileName', [saveFolder '-fft.fig']);
            %                 plot(k, sqrt(sum(abs(data_k).^2,1)));
            
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
            figure('FileName', [saveFolder '_1DSTD_data.fig']);
            imagesc(data);
            title('X Data');
            figure('FileName', [saveFolder '_1DSTD_its.fig']);
            imagesc(fits);
            title('X Fits');
            export2wsdlg({'Data:', 'Fits:'}, {'data', 'fits'}, {data, fits});
            %                 figure('FileName', [saveFolder ' - std_1.fig']);
            %                 plot(std(data, 1));
            %                 title('std(data, 1)');
            %                 figure('FileName', [saveFolder ' - std_2.fig']);
            %                 plot(std(data, 1)./mean(data, 1));
            %                 title('std(data, 1)./mean(data, 1)');
            %                 figure('FileName', [saveFolder ' - std_3.fig']);
            %                 plot(std(data, 1)./xFit(1, :));
            %                 title('std(data, 1)./xFit(1, :)');
            
        case appData.consts.availableAnalyzing.g2
            [n, g2, dN2] = cloudstat(appData.analyze.totAppData, ...
                appData.analyze.totAppData{1}.data.camera.xPixSz*1e6, ...
                2*appData.analyze.totAppData{1}.options.avgWidth+1, ...
                0, 0); % photonSN,normn);
            figure; 
            plot(mean(n), diag(dN2));
%             figure;
%             imagesc(n);
%             figure;
%             imagesc(g2);
%             figure;
%             imagesc(dN2);
        case appData.consts.availableAnalyzing.lambda
            fitType = appData.analyze.totAppData{1}.data.fitType;
            lambda=[];
            for ( j= 1 : length(appData.analyze.totAppData)  )
                lambda(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.res.lambda* ...
                    appData.analyze.totAppData{j}.consts.cameras{appData.analyze.totAppData{j}.options.cameraType}.yPixSz*1e6; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_lambda.fig']);
            [val, I] = sort(val);
            plot(val,  lambda(I), 'o');
            %                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
            %                 xlabel(xlabelstr{appData.analyze.totAppData{1}.save.saveParamVal});
            xlabel(xlabelStr);
            ylabel('\lambda [\mum] ');
        case appData.consts.availableAnalyzing.phi
            fitType = appData.analyze.totAppData{1}.data.fitType;
            phi=[];
            for ( j= 1 : length(appData.analyze.totAppData)  )
                phi(j) = mod(appData.analyze.totAppData{j}.data.fits{ fitType }.res.phi, 2*pi); %#ok<AGROW>
                OD(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.maxVal;%#ok<AGROW>
                err(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.conf(4) ;%#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_phi.fig']);
            [val, I] = sort(val);
            errorbar(val,  phi(I), err(I), 'o');
%             figure;
%             errorbar(val, phi, err, 'o');
%             plot( phi, 'o');
            %                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
            %                 xlabel(xlabelstr{appData.analyze.totAppData{1}.save.saveParamVal});
            xlabel(xlabelStr);
            ylabel('phi [rad] ');
            figure( 'FileName', [saveFolder '_phi_polar.fig']);
            polar(phi, OD, 'o');
         case appData.consts.availableAnalyzing.visibility
            fitType = appData.analyze.totAppData{1}.data.fitType;
            v=[];
            for ( j= 1 : length(appData.analyze.totAppData)  )
                v(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.res.v; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_visibility.fig']);
            [val, I] = sort(val);
            plot(val, v(I), 'o');
%             plot(v, 'o');
            %                 xlabelstr =   get(appData.ui.pmSaveParam, 'String');
            %                 xlabel(xlabelstr{appData.analyze.totAppData{1}.save.saveParamVal});
            xlabel(xlabelStr);
            ylabel('visibility ');
        case appData.consts.availableAnalyzing.normAtomNo            
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNo; %#ok<AGROW>
                Nref(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNoRef; %#ok<AGROW>
                R(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsRatio; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_normAtomNo.fig']);
            [val, I] = sort(val);
            [hAx,hLine1,hLine2] = plotyy(val, [N(I); Nref(I)], val, R(I));
            hLine2.Color = [0 0.55 0];
            set(hAx(2), 'YColor', [0 0.55 0]);
            xlabel(xlabelStr);
            ylabel(hAx(1), 'Atoms Number');
            ylabel(hAx(2), 'Normalized Atom Number');
        case appData.consts.availableAnalyzing.atomNoPerSite
            fitType = appData.analyze.totAppData{1}.data.fitType;
            val = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            for j = 1 : length(appData.analyze.totAppData{1}.data.fits{fitType}.Nsites)
                Nsites(j,:) = cellfun(@(x) x.data.fits{fitType}.Nsites(j), appData.analyze.totAppData);
            end
%             for ( j= 1 : length(appData.analyze.totAppData)  )
%                 N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNo; %#ok<AGROW>
%                 Nref(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNoRef; %#ok<AGROW>
%                 R(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsRatio; %#ok<AGROW>
%                 val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
%             end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_atomNoPerSite.fig']);
            plot(val, Nsites);
            xlabel(xlabelStr);
            ylabel('Atoms Number (per site)');
            
        case appData.consts.availableAnalyzing.atomNoPerSite_PSF
            fitType = appData.analyze.totAppData{1}.data.fitType;
            val = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            for j = 1 : length(appData.analyze.totAppData{1}.data.fits{fitType}.NSitesDeconv)
                NSitesDeconv(j,:) = cellfun(@(x) x.data.fits{fitType}.NSitesDeconv(j), appData.analyze.totAppData);
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            figure( 'FileName', [saveFolder '_atomNoPerSite.fig']);
            plot(val, NSitesDeconv);
            xlabel(xlabelStr);
            ylabel('Atoms Number (per site)');
            
        case appData.consts.availableAnalyzing.LorentzFitPerSite
            saveFolderTmp = [saveFolder '_ROI ' num2str(appData.data.ROISizeX) ' ' ...
                num2str(appData.data.ROISizeY) ' ' num2str(appData.data.ROICenterX) ' ' num2str(appData.data.ROICenterY)];
            [status,message,messageid] = mkdir(saveFolderTmp);
            if ~status
                errordlg('Cannot make ''saveFolder'' folder', 'Error', 'modal');
                return
            end
            
            fitType = appData.analyze.totAppData{1}.data.fitType;
            val = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            for j = 1 : length(appData.analyze.totAppData{1}.data.fits{fitType}.Nsites)
                Nsites(j,:) = cellfun(@(x) x.data.fits{fitType}.Nsites(j), appData.analyze.totAppData);
            end
            
%             LorentzFitPerSite(val, Nsites, saveFolfer);
            for i = 1 : size(Nsites, 1)
                N = Nsites(i, :);
                
                s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [-0.5*mean(N(1:20)) mean(N(1:20)) 7 0]);%[1 width/2 width/10]);
                f = fittype('a/pi*(w/2)/((w/2)^2+(x-x0)^2)+c', 'coefficients', {'a', 'c', 'w', 'x0'}, ...
                    'independent', 'x', 'dependent', 'y', 'options', s);
                [res{i}, gof{i}, output{i}] = fit(val', N', f);
                
                h = figure('FileName', [saveFolderTmp appData.slash 'LorentzFit_Site-' num2str(i) '.fig']);
                plot(res{i}, val, N);
                title(['Lorentzian Fit: Site ' num2str(i) '  v']);
                xlabel(xlabelStr);
                ylabel(['Atoms Number (site ' num2str(i) ')']);
                legend('off');
                conf = confint(res{i});
                text(min(val), mean(N), {'width:' [num2str(res{i}.w) ' (' num2str(conf(1, 3)) ', ' num2str(conf(2, 3)) ')']});
                saveas(h, get(h, 'FileName'));
                close(h);
            end
            
%             vecSites = [4 7 8 9 13 14 17 18];
%             vecSites = [1 3:5 7:20];
            vecSites = [1:size(Nsites, 1)];
            C = cellfun(@(x) x.c, res);
            W = cellfun(@(x) x.w, res);
            conf = cellfun(@(x) confint(x), res, 'UniformOutput', 0);
            Werr = cellfun(@(x) (x(2,3)-x(1,3))/2, conf);
            
            h = figure('FileName', [saveFolderTmp appData.slash 'LorentzFit_widths.fig']);
            errorbar(vecSites, W(vecSites), Werr(vecSites), 'o', 'linewidth', 2);
            xlabel('Site Index');
            ylabel('Lorentzian Width');
            saveas(h, get(h, 'FileName'));
            h = figure('FileName', [saveFolderTmp appData.slash 'LorentzFit_atomNo.fig']);
            plot((vecSites), C(vecSites), 'o', 'linewidth', 2);
            xlabel('Site Index');
            ylabel('Atom Number (per site)');
            saveas(h, get(h, 'FileName'));
            h = figure('FileName', [saveFolderTmp appData.slash 'LorentzFit_widthsVsN.fig']);
            errorbar(C(vecSites), W(vecSites), Werr(vecSites), 'o', 'linewidth', 2)
            xlabel('Atom Number (per site)');
            ylabel('Lorentzian Width');
            saveas(h, get(h, 'FileName'));
            
            save([saveFolderTmp appData.slash 'LorentzFits_Data.mat'], 'res', 'gof', 'output');
            
%             [FileName,PathName,FilterIndex] = uiputfile([saveFolder appData.slash 'LorentzFits_Data.mat']);
%             if FilterIndex ~= 0
%                 save([PathName appData.slash FileName], 'res', 'gof', 'output');
%             end
            
        case appData.consts.availableAnalyzing.TrapBottomFitPerSite
            saveFolderTmp = [saveFolder '_ROI ' num2str(appData.data.ROISizeX) ' ' ...
                num2str(appData.data.ROISizeY) ' ' num2str(appData.data.ROICenterX) ' ' num2str(appData.data.ROICenterY)];
            [status,message,messageid] = mkdir(saveFolderTmp);
            if ~status
                errordlg('Cannot make ''saveFolder'' folder', 'Error', 'modal');
                return
            end
            
            fitType = appData.analyze.totAppData{1}.data.fitType;
            val = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            for j = 1 : length(appData.analyze.totAppData{1}.data.fits{fitType}.Nsites)
                Nsites(j,:) = cellfun(@(x) x.data.fits{fitType}.Nsites(j), appData.analyze.totAppData);
            end
            
             val = 1e6*val;
%             LorentzFitPerSite(val, Nsites, saveFolfer);
            for i = 1 : size(Nsites, 1)
                N = -Nsites(i, :);
                
                s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [0.1 0.6e6 30 -mean(N(1:10))]);%[1 width/2 width/10]);
                f = fittype('a*heaviside(x-x0).*(x-x0).^0.5.*exp(-2*1e-34*2*pi*(x-x0)/1.38e-23/T/1e-6)-C', ...
                    'coefficients', {'a', 'x0', 'T', 'C'}, ...
                    'independent', 'x', 'dependent', 'y', 'options', s);
                try
                    [res{i}, gof{i}, output{i}] = fit(val', N', f);
                catch EX
                    i
                    EX
                    continue
                end
                
                h = figure('FileName', [saveFolderTmp appData.slash 'TrapBottomFit_Site-' num2str(i) '.fig']);
                plot(res{i}, val, N);
                title(['Trap Bottom and Temperature Fit: Site ' num2str(i) '  v']);
                xlabel(xlabelStr);
                ylabel(['Atoms Number (site ' num2str(i) ')']);
                legend('off');
                conf = confint(res{i});
                text(min(val), 0, {'Temp.:' [num2str(res{i}.T) ' (' num2str(conf(1, 3)) ', ' num2str(conf(2, 3)) ')'], ...
                    'Trap Bottom.:' [num2str(res{i}.x0) ' (' num2str(conf(1, 2)) ', ' num2str(conf(2, 2)) ')'], ...
                    'Atom Num::' [num2str(res{i}.C) ' (' num2str(conf(1, 4)) ', ' num2str(conf(2, 4)) ')']});
                saveas(h, get(h, 'FileName'));
                close(h);
            end
            
            vecRes = ~cellfun(@(x) isempty(x), res);
            res = res(vecRes);
            vecSites = 1:size(Nsites, 1);
            vecSites = vecSites(vecRes);
            C = cellfun(@(x) x.C, res);
            T = cellfun(@(x) x.T, res);
            x0 = cellfun(@(x) x.x0, res);
            conf = cellfun(@(x) confint(x), res, 'UniformOutput', 0);
            Cerr = cellfun(@(x) (x(2,4)-x(1,4))/2, conf);
            Terr = cellfun(@(x) (x(2,3)-x(1,3))/2, conf);
            x0err = cellfun(@(x) (x(2,2)-x(1,2))/2, conf);
%             
            h = figure('FileName', [saveFolderTmp appData.slash 'TrapBottomFit_AtomNo.fig']);
            errorbar(vecSites, C, Cerr, 'o', 'linewidth', 2);
            xlabel('Site Index');
            ylabel('Atom Number (per site)');
            saveas(h, get(h, 'FileName'));
            h = figure('FileName', [saveFolderTmp appData.slash 'TrapBottomFit_Temp.fig']);
            errorbar(vecSites, T, Terr, 'o', 'linewidth', 2);
            xlabel('Site Index');
            ylabel('Temperature (per site) [\muK]');
            saveas(h, get(h, 'FileName'));
            h = figure('FileName', [saveFolderTmp appData.slash 'TrapBottomFit_TrapBottom.fig']);
            errorbar(vecSites, x0, x0err, 'o', 'linewidth', 2);
            xlabel('Site Index');
            ylabel('Trap Bottom (per site) [Hz]');
            saveas(h, get(h, 'FileName'));
%             h = figure('FileName', [saveFolderTmp appData.slash 'LorentzFit_widthsVsN.fig']);
%             errorbar(C(vecSites), W(vecSites), Werr(vecSites), 'o', 'linewidth', 2)
%             xlabel('Atom Number (per site)');
%             ylabel('Lorentzian Width');
%             saveas(h, get(h, 'FileName'));
            
            save([saveFolderTmp appData.slash 'TrapBottomFits_Data.mat'], 'res', 'gof', 'output');
%             
            
        case appData.consts.availableAnalyzing.LorentzFit
            fitType = appData.analyze.totAppData{1}.data.fitType;
            
                val = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            if fitType == appData.consts.fitTypes.onlyMaxNorm
                N = cellfun(@(x) x.data.fits{ fitType }.atomsRatio, appData.analyze.totAppData);
                s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [-50 5 10 -4]);%[1 wi
            else
                N = cellfun(@(x) x.data.fits{ fitType }.atomsNo, appData.analyze.totAppData);
                s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [-1e5 20e3 5 0]);%[1 width/2 width/10]);
            end
            f = fittype('a/pi*(w/2)/((w/2)^2+(x-x0)^2)+c', 'coefficients', {'a', 'c', 'w', 'x0'}, ...
                'independent', 'x', 'dependent', 'y', 'options', s);
            [res, gof, output] = fit(val', N', f);
            
            h = figure('FileName', [saveFolder '_LorentzFit.fig']);
            [val, I] = sort(val);
            plot(res, val, N(I));
            title(['Lorentzian Fit']);
            xlabel(xlabelStr);
            if fitType == appData.consts.fitTypes.onlyMaxNorm
                ylabel(['Norm Atoms']);
            else
                ylabel(['Atoms']);
            end
            legend('off');
            conf = confint(res);
            text(min(val), mean(N), {'width:' [num2str(res.w) ' (' num2str(conf(1, 3)) ', ' num2str(conf(2, 3)) ')']});
            
        case appData.consts.availableAnalyzing.TrapBottomFit
           
            fitType = appData.analyze.totAppData{1}.data.fitType;
            val = cellfun(@(x) x.save.saveParamVal, appData.analyze.totAppData);
            N = cellfun(@(x) x.data.fits{ fitType }.atomsNo, appData.analyze.totAppData);
            
            val = 1e3*val;
            N = -N;
            s = fitoptions('Method','NonlinearLeastSquares', 'Startpoint', [1e-3 2.1e6 30 -mean(N(1:5))]);%[1 width/2 width/10]);
            f = fittype('a*heaviside(x-x0).*(x-x0).^0.5.*exp(-2*1e-34*2*pi*(x-x0)/1.38e-23/T/1e-6)-C', ...
                'coefficients', {'a', 'x0', 'T', 'C'}, ...
                'independent', 'x', 'dependent', 'y', 'options', s);
            try
                [res, gof, output] = fit(val', N', f);
            catch EX
                i
                EX
                continue
            end
            
            h = figure('FileName', [saveFolder '_TrapBottomFitfig']);
            [val, I] = sort(val);
            plot(res, val, N(I));
            title(['Trap Bottom and Temperature Fit']);
            xlabel(xlabelStr);
            ylabel(['Atoms Number']);
            legend('off');
            conf = confint(res);
            text(min(val), mean(N), {'Temp.:' [num2str(res.T) ' (' num2str(conf(1, 3)) ', ' num2str(conf(2, 3)) ')'], ...
                'Trap Bottom.:' [num2str(res.x0) ' (' num2str(conf(1, 2)) ', ' num2str(conf(2, 2)) ')'], ...
                'Atom Num::' [num2str(res.C) ' (' num2str(conf(1, 4)) ', ' num2str(conf(2, 4)) ')']});
            
        case appData.consts.availableAnalyzing.twoROIAtomNo
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                N(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNo; %#ok<AGROW>
                Nref(j) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNoRef; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            [val, I] = sort(val);
            figure( 'FileName', [saveFolder '_TwoROIAtomNo.fig']);
            plot(val, [N(I); Nref(I)]);
            xlabel(xlabelStr);
            ylabel('Atoms Number');
            
        case appData.consts.availableAnalyzing.onlyMaxYCuts
            fitType = appData.analyze.totAppData{1}.data.fitType;
            for ( j= 1 : length(appData.analyze.totAppData)  )
                N(j, :) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNoYCuts; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            [val, I] = sort(val);
            figure( 'FileName', [saveFolder '_atomsNoYCuts.fig']);
            plot(val, N(I,:));
            xlabel(xlabelStr);
            ylabel('Atoms Number Y-Cuts');
        case appData.consts.availableAnalyzing.onlyMaxXCuts
            fitType = appData.analyze.totAppData{1}.data.fitType;
            clear N val
            for ( j= 1 : length(appData.analyze.totAppData)  )
                N(j, :) = appData.analyze.totAppData{j}.data.fits{ fitType }.atomsNoXCuts; %#ok<AGROW>
                val(j) = appData.analyze.totAppData{j}.save.saveParamVal; %#ok<AGROW>
            end
            if ( min(val) == max(val) )
                for ( j= 1 : length(appData.analyze.totAppData)  )
                    val(j) = appData.analyze.totAppData{j}.save.picNo; %#ok<AGROW>
                end
            end
            [val, I] = sort(val);
            figure( 'FileName', [saveFolder '_atomsNoXCuts.fig']);
            plot(val, N(I,:));
            hold on
            plot(val, sum(N, 2)/size(N,2), 'k', 'linewidth', 3)
            hold off
            xlabel(xlabelStr);
            ylabel('Atoms Number X-Cuts');
        otherwise
            errordlg({'Not a known Value in \"imaging.m/pbSaveToWorkspace_Callback\".' ['appData.analyze.currentAnalyzing(' num2str(i)  ...
                ') is: ' num2str(appData.data.fitType)]},'Error', 'modal');
    end
    if ischar(folder)
       ttl = get(gca, 'title');  
       title(gca, [ttl.String ' (folder: ' folder ')  .']);
    end
end


% function closeFig_callback(obj, eventdata)
%     
% % figFile = ls(obj.FileName);
% fid = fopen(obj.FileName);
% if ( fid  ~= -1 )
%     fclose(fid);
%    csvwrite([obj.FileName(1:end-3) 'csv'], [obj.Children.Children.XData; obj.Children.Children.XData]');
% end
%     
% delete(obj)
% end
% end
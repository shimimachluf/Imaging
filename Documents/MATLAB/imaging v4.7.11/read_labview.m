function LVData=read_labview(filename)

%filename='C:\Ramon\RawData\Labview_data_to_load.txt';
fileID=fopen(filename,'r');
i=1;
RFC=1; % RF Counter

while feof(fileID)==0  
    rawData{i}=fgetl(fileID); %#ok<*AGROW>
    i=i+1;
end
fclose(fileID);
i = 1;
while i <= length(rawData)
    if isempty(rawData{i})
        i = i+1;
        continue;
    end
    line=textscan(rawData{i}, '%s', 'delimiter',',');
    Data = [];
    for j=1:size(line{1,1},1)
        Data{j}=line{1,1}{j,1};
    end
    switch Data{1}
        case {'EN'}
%             'Event Num.';
            Event_Num=str2double(Data{2});
            Events=struct('index',num2cell(0:Event_Num-1),'Event_Start',{'NaN'},'Execute_Event','NaN',...
                    'Name','NaN','Analog_Channels',cell(1),'Digital_Channels',cell(1));
        case {'AP'}
%             'Analog Prop.';
            Analog_Properties(str2double(Data{2})+1).Shtut=str2double(Data{3});
            Analog_Properties(str2double(Data{2})+1).Channel=str2double(Data{2});
            Analog_Properties(str2double(Data{2})+1).Polling=str2double(Data{4});
            Analog_Properties(str2double(Data{2})+1).Shift=str2double(Data{5});
            Analog_Properties(str2double(Data{2})+1).Scale=str2double(Data{6});
            Analog_Properties(str2double(Data{2})+1).Start_Value=str2double(Data{7});
            Analog_Properties(str2double(Data{2})+1).Min=str2double(Data{8});
            Analog_Properties(str2double(Data{2})+1).Max=str2double(Data{9});
            Analog_Properties(str2double(Data{2})+1).Name=Data{10};
        case {'DP'}
%             'Digital Prop.';
            Digital_Properties(str2double(Data{2})+1).Channel=str2double(Data(2));
            Digital_Properties(str2double(Data{2})+1).Shtut=str2double(Data(3));
            Digital_Properties(str2double(Data{2})+1).Name=Data{4};
        case {'EV'}
%             'Events Prop.';
            Events(str2double(Data{2})+1).Event_Start=str2double(Data{3});
            Events(str2double(Data{2})+1).Execute_Event=str2double(Data{4});
            Events(str2double(Data{2})+1).Name=Data{5};
        case {'AR'}
%             'Analog Ramp';
            A_Ramp = [];
            exec = str2double(Data{5});
            for j=1:str2double(Data{4})
                line=textscan(rawData{i+j}, '%s', 'delimiter',',');
                Data = [];
                for k=1:size(line{1,1},1)
                    Data{k}=line{1,1}{k,1};
                end
                A_Ramp(j).Execute = exec;
                A_Ramp(j).Start = str2double(Data{5});
                A_Ramp(j).Rise = str2double(Data{6});
                A_Ramp(j).Value = str2double(Data{7});
%                 A_Ramp(j).String = rawData{i+j};
            end % Ramp=(execute,Start,Rise,Value)
            
            Events(str2double(Data{2})+1).Analog_Channels{str2double(Data{3})+1}=A_Ramp;
             if ~isempty(j)
                i=i+j;
            end
        case {'DR'}
%             'Digital Ramp';
            D_Ramp = [];
            exec = str2double(Data{5});
            for j=1:str2double(Data{4})                 
                line=textscan(rawData{i+j}, '%s', 'delimiter',',');
                Data = [];
                for k=1:size(line{1,1},1)
                    Data{k}=line{1,1}{k,1};
                end
                D_Ramp (j).Execute = exec;
                D_Ramp(j).Start = str2double(Data{5});
                D_Ramp(j).Value = str2double(Data{6});
%                 D_Ramp(j).String = rawData{i+j};
            end % Ramp=(execute,Start,Value)
            Events(str2double(Data{2})+1).Digital_Channels{str2double(Data{3})+1}=D_Ramp;
            if ~isempty(j)
                i=i+j;
            end
        case {'TS'}
%             'RF Ramp';
            RF_Ramp.blabla=str2double(Data{2});
            RF_Ramp.ramp_index=str2double(Data{3});
            RF_Ramp.ramp_num=str2double(Data{4});
            RF_Ramp.blabla2=str2double(Data{5});
            RF_Ramp.GPIB=Data{6};
            RF_Ramp.Command=Data{7};
            %RF_Ramp.Ag33250=str2double(Data{2});
            %RF_Ramp.Amplitude_units=str2double(Data{3});
            %RF_Ramp.Offset=str2double(Data{4});
            %RF_Ramp.Frequency_Deviation=str2double(Data{5});
            %RF_Ramp.Carrier_Frequency=str2double(Data{6});
            %RF_Ramp.Amplitude=str2double(Data{7});
            %RF_Ramp.Shtut=str2double(Data{8});
            RF_Ramp.Start_Time = -1;
        case {'TT'}
%                  RF_Ramp.Data(RFC).blabla = str2double(Data{2});
%                  RF_Ramp.Data(RFC).Index = str2double(Data{3});
%                  RF_Ramp.Data(RFC).Time_milli_sec=str2double(Data{4});
%                  RF_Ramp.Data(RFC).String = Data{5};
                        RF_Ramp.Data(RFC).Index = str2double(Data{2});
                        RF_Ramp.Data(RFC).Time_milli_sec=str2double(Data{3});
                        RF_Ramp.Data(RFC).String = Data{4};
%                  RF_Ramp.Data(RFC).String = rawData{i};
                
                 if ( RF_Ramp.Start_Time == -1 )
                    RF_Ramp.Start_Time = RF_Ramp.Data(1).Time_milli_sec;
                 end
                RFC=RFC+1;
        case {'AO'}
%             'AOM Prop.';
            AOM_Properties(str2double(Data{3})+1).Channel=str2double(Data{3});
            AOM_Properties(str2double(Data{3})+1).Shtut=str2double(Data{2});
            AOM_Properties(str2double(Data{3})+1).Start_Value=str2double(Data{4});
            AOM_Properties(str2double(Data{3})+1).Min=str2double(Data{5});
            AOM_Properties(str2double(Data{3})+1).Max=str2double(Data{6});
            AOM_Properties(str2double(Data{3})+1).Name=Data{7};
        case {'DD','AD',';;'}%'TT',
            'Other';
        otherwise
            'Otherwise' %#ok<NOPRT>
    end
    i = i+1;
end
% i
LVData.Events=Events;
LVData.Analog_Properties=Analog_Properties;
LVData.Digital_Properties=Digital_Properties;
LVData.AOM_Properties=AOM_Properties;
LVData.Filename=filename;
LVData.RF_Ramp=RF_Ramp;
end

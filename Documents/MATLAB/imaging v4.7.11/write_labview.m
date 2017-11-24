function write_labview(LVData,output_filename)

output=fopen(output_filename,'wt+');

fprintf(output,['EN,     ' num2str(size(LVData.Events,2)) ',\n']);
fprintf(output,';;, Analog Channels Properties \n');
fprintf(output,';;,    Pos, Number, Polling,  Scale ,  Shift , Start Value ,Max Value ,Min Value   , Name \n');

for i=1:size(LVData.Analog_Properties,2)
fprintf(output,['AP,','%7.0f,','%7.0f,','%7.0f,',' %8.6f, ','%8.6f, ','%8.6f, ','%8.6f, ','%8.6f,','%s,\n'],...
                LVData.Analog_Properties(1,i).Channel,...
                LVData.Analog_Properties(1,i).Shtut,...
                LVData.Analog_Properties(1,i).Polling,...
                LVData.Analog_Properties(1,i).Shift,...
                LVData.Analog_Properties(1,i).Scale,...
                LVData.Analog_Properties(1,i).Start_Value,...
                LVData.Analog_Properties(1,i).Min,...
                LVData.Analog_Properties(1,i).Max,...
                LVData.Analog_Properties(1,i).Name);
end

for i=1:size(LVData.AOM_Properties,2)
    fprintf(output,['AO,','%7.0f,','%7.0f, ','%8.6f,','%10.6f,','%11.6f,','%s,\n'],...
        LVData.AOM_Properties(1,i).Channel,...
        LVData.AOM_Properties(1,i).Shtut,...
        LVData.AOM_Properties(1,i).Start_Value,...
        LVData.AOM_Properties(1,i).Min,...
        LVData.AOM_Properties(1,i).Max,...
        LVData.AOM_Properties(1,i).Name);
end

fprintf(output,';;, Digital Channels Properties \n');
fprintf(output,';;,    Pos , Number,     Name \n');

for i=1:size(LVData.Digital_Properties,2)
    fprintf(output,['DP,','%7.0f,','%7.0f,','%s,\n'],...
        LVData.Digital_Properties(1,i).Channel,...
        LVData.Digital_Properties(1,i).Shtut,...
        LVData.Digital_Properties(1,i).Name);  
end

fprintf(output,';;, Events Properties \n');
fprintf(output,';;,    Number,  Start Time, On/Off,    Name  \n');

for i=1:size(LVData.Events,2)
fprintf(output,['EV,','%7.0f,','%16.0f,','%7.0f,','%s,\n'],...
    LVData.Events(1,i).index,...
    LVData.Events(1,i).Event_Start,...
    LVData.Events(1,i).Execute_Event,...
    LVData.Events(1,i).Name);
end

fprintf(output,';;,   Event,Channel,  Ramp,  On/Off   Start ,         Rise,     Value  \n');

for i=1:size(LVData.Events,2)
        for j=1:size(LVData.Events(1,i).Analog_Channels,2)
            if ~isempty(LVData.Events(1,i).Analog_Channels{1,j})
                fprintf(output,['AR,','%7.0f,','%7.0f,','%7.0f,','%7.0f\n'],...
                    LVData.Events(1,i).index,...
                    j-1,...
                    size(LVData.Events(1,i).Analog_Channels{1,j},2),...
                    LVData.Events(1,i).Analog_Channels{1,j}(1).Execute);
                
                for k=1:size(LVData.Events(1,i).Analog_Channels{1,j},2)
                    fprintf(output,['AD,','%7.0f,','%7.0f,','%7.0f,','%15.0f,','%15.0f, ','%8.6f, \n'],...
                    LVData.Events(1,i).index,...
                    j-1,...
                    k-1,...
                    LVData.Events(1,i).Analog_Channels{1,j}(k).Start,...
                    LVData.Events(1,i).Analog_Channels{1,j}(k).Rise,...
                    LVData.Events(1,i).Analog_Channels{1,j}(k).Value);
                end
            else
                fprintf(output,['AR,','%7.0f,','%7.0f,','%7.0f,','%7.0f\n'],...
                    LVData.Events(1,i).index,...
                    j-1,...
                    0,...
                    0);
            end
        end
        
        for j=1:size(LVData.Events(1,i).Digital_Channels,2)    
            if ~isempty(LVData.Events(1,i).Digital_Channels{1,j})
                fprintf(output,['DR,','%7.0f,','%7.0f,','%7.0f,','%7.0f\n'],...
                    LVData.Events(1,i).index,...
                    j-1,...
                    size(LVData.Events(1,i).Digital_Channels{1,j},2),...
                    LVData.Events(1,i).Digital_Channels{1,j}(1).Execute);
                 
                for k=1:size(LVData.Events(1,i).Digital_Channels{1,j},2)
                    fprintf(output,['DD,','%7.0f,','%7.0f,','%7.0f,','%15.0f,','%7.0f\n'],...
                    LVData.Events(1,i).index,...
                    j-1,...
                    k-1,...
                    LVData.Events(1,i).Digital_Channels{1,j}(k).Start,...
                    LVData.Events(1,i).Digital_Channels{1,j}(k).Value);
                end
            else
                fprintf(output,['DR,','%7.0f,','%7.0f,','%7.0f,','%7.0f\n'],...
                    LVData.Events(1,i).index,...
                    j-1,...
                    0,...
                    0);
            end
        end
end

fprintf(output,['TS,','%7.0f,','%7.0f,','%7.0f,','%7.0f,',  '%s,','%s\n'],...
    LVData.RF_Ramp.blabla,...
    LVData.RF_Ramp.ramp_index,...
    LVData.RF_Ramp.ramp_num,...
    LVData.RF_Ramp.blabla2,...
    LVData.RF_Ramp.GPIB,...
    LVData.RF_Ramp.Command);

for i=1:size(LVData.RF_Ramp.Data,2)
% %     fprintf(output, [LVData.RF_Ramp.Data(1,i).String '\n']);
%     fprintf(output,['TT,','%7.0f, ','%6.0f,','%7.0f,','%s\n'],...
%         LVData.RF_Ramp.Data(1,i).blabla,...
%         LVData.RF_Ramp.Data(1,i).Index,...
%         LVData.RF_Ramp.Data(1,i).Time_milli_sec,...
%         LVData.RF_Ramp.Data(1,i).String);
                fprintf(output,['TT,','%7.0f, ','%7.0f, ','%s\n'],...
                    LVData.RF_Ramp.Data(1,i).Index,...
                    LVData.RF_Ramp.Data(1,i).Time_milli_sec,...
                    LVData.RF_Ramp.Data(1,i).String);
end
fclose(output);
end






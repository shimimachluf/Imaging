function Visualization(Experiment_data)


%Experiment_data=read_labview('C:\Program Files\MATLAB\R2008a\work\Ramon_v2\Pic\081027.txt');


%Initial configuration
Display_Analog=[999 0 1]; %default channels, 999 is the code for the RF ramp
Display_Digital=[];
checkbox_analog=[];
checkbox_digital=[];
Channels_Ordering=Initialize_Channels(Experiment_data,Display_Analog,Display_Digital);
scrsz = get(0,'ScreenSize');
zoom_start=2.0095;
zoom_end=2.0112;
zoom_size=zoom_end-zoom_start;
font_size=8;
Timeline_axes=[0.01 0.7 0.98 0.28];
Zoom_axes=[0.15 0.05 0.49 0.6];
Tab_position=[0.65 0.15 0.34 0.5];
Button_position=[0.73 0.05 0.05 0.05];

fig=figure('Position',[scrsz(4)*0.05 scrsz(3)*0.05 scrsz(3)/1.05 scrsz(4)/1.2],'Name','Channel Data','NumberTitle','off','Toolbar','figure');%,'Menubar','none');

h(1)=axes('Parent',fig,'Position',Timeline_axes,'XLim',[0 60]*10^6,'XTick',[0 1 2 3 4 5 6]*10^7,'XTickLabel',[0 10 20 30 40 50 60],'XMinorTick','on','FontSize',font_size,'FontName','Gill Sans MT','YTickLabel',[],'YTick',[],'Layer','top');
h(2)=axes('Parent',fig,'Position',Zoom_axes,'XLim',[0 60]*10^6,'YTick',[],'YTickLabel',[],'Layer','top','FontName','Gill Sans MT');
set(h(2),'XGrid','on')
%ylabel(h(2),'FontName','Gill Sans MT');

dcm_obj = datacursormode(fig);
set(dcm_obj,'UpdateFcn',@SelectPoint)

hbutton=uicontrol(...
    'Parent',fig,...
    'String','Plot',...
    'Units','normalized',...
    'Style','pushbutton',...
    'Position',Button_position,...
    'Callback',@button);

htab=uitabpanel(...
    'Parent',fig,...
    'Style','lefttop',...
    'Units','normalized',...
    'Position',Tab_position,...
    'FrameBackgroundColor',[0.4314,0.5882,0.8431],...
    'FrameBorderType','etchedin',...
    'Title',{'Analog Channels','Digital Channels','Measure'},...
    'PanelHeights',[1,1],...
    'HorizontalAlignment','left',...
    'FontWeight','bold',...
    'TitleBackgroundColor',[0.9255 0.9490 0.9765],...
    'TitleForegroundColor',[0.1294,0.3647,0.8510],...
    'PanelBackgroundColor',[0.9 0.9 1],... %[0.7725,0.8431,0.9608]
    'PanelBorderType','line',...
    'CreateFcn',@CreateTab);
    
DisplayChannels;

function DisplayChannels

xlimit1=get(h(1),'XLim');
xlimit2=get(h(2),'XLim');
cla(h(1))
cla(h(2))

if size(Channels_Ordering.Ordering,2)>0
    Channels_Number=size(Channels_Ordering.Ordering,2);
    YLabels=cell(1,Channels_Number);
else
    Channels_Number=0.5;
    YLabels=[];
end

set(h(1),'XLim',xlimit1,'YLim',[0 Channels_Number]);
set(h(2),'XLim',xlimit2,'YLim',[0 Channels_Number]);
YTicks=[];
axes_position.Events=get(h(1),'Position');
axes_position.Zoom=get(h(2),'Position');
spread=0;
X_Ticks=[];
hold all
for i=1:Channels_Number
    if strcmp(Channels_Ordering.Ordering{1,i},'A') %If Analog Channel
        Name=Channels_Ordering.Analog{1,Channels_Ordering.Ordering{2,i}+1};
        Name_List{spread+1}=regexprep(Name,'^AP_','');
        after_sort=sortrows(cell2mat(Experiment_data.Analog_Properties.(Name).Ramps(:,2:3)),1);
        YLabels{i}=regexprep(Name,'^AP_((\d)|(\d\d))_','A\($1\) ');
        %YLabels{i}=Name;
        YTicks(i)=spread+.5;
        y1=after_sort(:,1);
        X_Ticks=union(X_Ticks,y1);
        y2=after_sort(:,2);
        old_values=[y1,y2];
        scaling=(max(y2)+0.05*max(y2));
       
        y2=y2/scaling+spread;
        axes(h(2));
        y2=[spread;y2;spread];
        y1=[0;y1;6*10^7];

        spread=spread+1;

        fill(y1,y2,[0.7725,0.8431,0.9608],'Marker','.','MarkerEdgeColor',[1 0 0],'MarkerSize',14,'Parent',h(2),'UserData',{old_values,scaling,spread});%,'ButtonDownFcn',@SelectPoint)

        axes(h(1));
        hold all

        fill(y1,y2,[0.7725,0.8431,0.9608])

    elseif strcmp(Channels_Ordering.Ordering{1,i},'D') %If Digital Channel
        
        Name=Channels_Ordering.Digital{1,Channels_Ordering.Ordering{2,i}+1};
        Name_List{spread+1}=regexprep(Name,'^DP_','');
        after_sort=sortrows(cell2mat(Experiment_data.Digital_Properties.(Name).Ramps(:,2:3)),1);
        YLabels{i}=regexprep(Name,'^DP_((\d)|(\d\d))_','D\($1\) ');
        %YLabels{i}=Name;
        YTicks(i)=spread+.5;
        y1=after_sort(:,1);
        X_Ticks=union(X_Ticks,y1);
        y2=after_sort(:,2);
        old_values=[y1,y2];
        scaling=(max(y2)+0.05*max(y2));
        y2=y2/scaling +spread;
        y2=[spread;y2;spread];
        y1=[0;y1;6*10^7];
        spread=spread+1;
        axes(h(2));
        hold all
        fill(y1,y2,[0.7725,0.8431,0.9608],'Marker','.','MarkerEdgeColor',[1 0 0],'MarkerSize',14,'Parent',h(2),'UserData',{old_values,scaling,spread});%,'ButtonDownFcn',@SelectPoint)
        axes(h(1));
        hold all
        fill(y1,y2,[0.7725,0.8431,0.9608])

    elseif strcmp(Channels_Ordering.Ordering{1,i},'RF') %If RF ramp
        RFRamp=cell(size(Experiment_data.RF_Ramp.Data,2),2);
        RF_Counter=1;
        RFRamp_Counter=1;
        while RF_Counter<=size(Experiment_data.RF_Ramp.Data,2)
            if RF_Counter==1
                RFRamp{RFRamp_Counter,1}=Experiment_data.RF_Ramp.Start_Time;
                RFRamp{RFRamp_Counter,2}=0;
                RFRamp_Counter=RFRamp_Counter+1;
                RFRamp{RFRamp_Counter,1}=Experiment_data.RF_Ramp.Start_Time;
                RFRamp{RFRamp_Counter,2}=Experiment_data.RF_Ramp.Amplitude;
            elseif Experiment_data.RF_Ramp.Data(1,RF_Counter).Amplitude>0
                RFRamp{RFRamp_Counter,1}=Experiment_data.RF_Ramp.Data(1,RF_Counter).Time_micro_sec;
                RFRamp{RFRamp_Counter,2}=RFRamp{RFRamp_Counter-1,2}; 
                RFRamp_Counter=RFRamp_Counter+1;
                RFRamp{RFRamp_Counter,1}=Experiment_data.RF_Ramp.Data(1,RF_Counter).Time_micro_sec;
                RFRamp{RFRamp_Counter,2}=Experiment_data.RF_Ramp.Data(1,RF_Counter).Amplitude; 
            else
                RF_Counter=RF_Counter+9999;
                RFRamp{RFRamp_Counter,1}=RFRamp{RFRamp_Counter-1,1};
                RFRamp{RFRamp_Counter,2}=0;
            end
            RFRamp_Counter=RFRamp_Counter+1;
            RF_Counter=RF_Counter+1;
        end
        after_sort=sortrows(cell2mat(RFRamp(:,1:2)),1);
        YLabels{i}='RF Ramp';
        YTicks(i)=spread+.5;
        y1=after_sort(:,1);
        X_Ticks=union(X_Ticks,y1);
        y2=after_sort(:,2);
        old_values=[y1,y2];
        scaling=(max(y2)+0.05*max(y2));
        y2=y2/scaling+spread;  
        y2=[spread;y2;spread];
        y1=[0;y1;6*10^7];
        spread=spread+1;
        axes(h(2));
        hold all
        fill(y1,y2,[0.7725,0.8431,0.9608],'Marker','.','MarkerEdgeColor',[1 0 0],'MarkerSize',14,'Parent',h(2),'UserData',{old_values,scaling,spread});%,'ButtonDownFcn',@SelectPoint)
        axes(h(1));
        hold all
        fill(y1,y2,[0.7725,0.8431,0.9608])
    end
    if get(h(1),'UserData')
        yellow_square=get(h(1),'UserData');
        set(yellow_square,'FaceColor','y','EdgeColor','r');
    end
end

set(h(2),'UserData',X_Ticks);
ZoomTicks;
set(h(2),'YTickLabel',YLabels,'YTick',YTicks,'fontsize',8,'fontweight','b');
zoom_handle=zoom(h(1));
set(zoom_handle,'Motion','horizontal','ActionPostCallback',{@zoomcallback,h});

if get(h(1),'UserData')
        yellow_square=get(h(1),'UserData');
        set(yellow_square,'FaceColor','none','EdgeColor','none');
        Yellow_Box=get(yellow_square,'Position');
        annotate=annotation('rectangle','Units','normalized','Position',Yellow_Box,'FaceColor','y','FaceAlpha',0.2,'EdgeColor','r','ButtonDownFcn',@Move_zoom);
        set(h(1),'UserData',annotate);
end

pan_handle=pan;
set(pan_handle,'Motion','horizontal','ActionPostCallback',{@pancallbackpost,h});%,'ActionPreCallback',{@pancallback,h});
setAllowAxesPan(pan_handle,h(1),0)
hold off

if get(h(1),'UserData')
        yellow_square=get(h(1),'UserData');
        set(yellow_square,'FaceColor','y','EdgeColor','r');
end
end

function txt=SelectPoint(empt,event_obj)

pos = get(event_obj,'Position');
a=get(event_obj);
b=get(a.Target);
scaling=b.UserData{2};
spread=b.UserData{3};
Time=regexprep(num2str(pos(1)),'(\d\d\d)(\d\d\d)$',',$1,$2');
txt = {['Time [s]: ',Time],...
	['Amplitude: ',num2str((pos(2)-spread+1)*scaling)]};
end

function ZoomTicks
zoom_size=get(h(2),'XLim');
zoompanel=zoom_size(2)-zoom_size(1);
good_spacing=0.3;
X_Ticks=get(h(2),'UserData');
X_Ticks=sort(X_Ticks);
tick_counter=0;
X_Ticks_difference=diff(X_Ticks);
Good_Ticks=[];
for i=1:size(X_Ticks_difference,1)
    tick_counter=tick_counter+X_Ticks_difference(i);
    if tick_counter>zoompanel*good_spacing
        Good_Ticks=union(Good_Ticks,[X_Ticks(i) X_Ticks(i+1)]);
        tick_counter=0;
    end
end
set(h(2),'XTick',Good_Ticks)
end

function pancallbackpost(obj,evd,all_handles)
    if evd.Axes==all_handles(2)
        Yellow_Box(all_handles(2));
    end
    ZoomTicks;
end

function zoomcallback(obj,evd,axes_handles,zoom_handle)
    Yellow_Box(evd.Axes);
    ZoomTicks;
end

function box_pos=Yellow_Box(axes_origin)

ZoomNewLim = get(axes_origin,'XLim');
set(h(1),'XLim',[0 6]*10^7);
set(h(2),'XLim',ZoomNewLim);

if get(h(1),'UserData')
        yellow_square=get(h(1),'UserData');
        set(yellow_square,'FaceColor','none','EdgeColor','none');
end

Timeline_size=get(h(1),'Position');
Timeline_Limits=Timeline_size(3);
LimitSize=Timeline_Limits/(6*10^7);
box_pos=[Timeline_size(1)+ZoomNewLim(1)*LimitSize Timeline_size(2) (ZoomNewLim(2)-ZoomNewLim(1))*LimitSize Timeline_size(4)];
annotate=annotation('rectangle','Units','normalized','Position',box_pos,'FaceColor','y','FaceAlpha',0.2,'EdgeColor','r');
set(h(1),'UserData',annotate);
end

function CreateTab(htab,evdt,hpanel,hstatus)
    for chk_index=1:size(Channels_Ordering.Analog,2)

    checkbox_analog(chk_index)=uicontrol(...
                                'Parent',hpanel(1),...
                                'Units','normalized',...
                                'Position',[.01,.98-chk_index*0.04,.5,.04],...
                                'BackgroundColor',get(hpanel(2),'BackgroundColor'),...
                                'HorizontalAlignment','left',...
                                'Style','checkbox',...
                                'FontSize',9,...
                                'FontName','Gill Sans MT',...
                                'String',regexprep(Channels_Ordering.Analog{1,chk_index},'^AP_((\d)|(\d\d))_','$1\. '),...
                                'Value',Channels_Ordering.Analog{3,chk_index},...
                                'UserData','Analog',...
                                'Callback',{@checkbox_callback,chk_index});
    
    end
    
    RF_index=size(Channels_Ordering.Analog,2)+1;
    checkbox_analog(RF_index)=uicontrol(...
                                'Parent',hpanel(1),...
                                'Units','normalized',...
                                'Position',[.567,.94,.3,.04],...
                                'BackgroundColor',get(hpanel(2),'BackgroundColor'),...
                                'HorizontalAlignment','left',...
                                'Style','checkbox',...
                                'FontSize',9,...
                                'FontName','Gill Sans MT',...
                                'String','RF Ramp',...
                                'Value',Channels_Ordering.RF{3,1},...
                                'UserData','RF',...
                                'Callback',{@checkbox_callback,chk_index});

    for chk_index=1:size(Channels_Ordering.Digital,2)
    displace=chk_index-mod(chk_index,27);
    checkbox_digital(chk_index)=uicontrol(...
                                'Parent',hpanel(2),...
                                'Units','normalized',...
                                'Position',[.01+displace*0.021,.98-(mod(chk_index,27)+displace/27)*0.037,.6-(displace/27)*0.18,.04],...
                                'BackgroundColor',get(hpanel(2),'BackgroundColor'),...
                                'HorizontalAlignment','left',...
                                'Style','checkbox',...
                                'FontSize',9,...
                                'FontName','Gill Sans MT',...
                                'String',regexprep(Channels_Ordering.Digital{1,chk_index},'^DP_((\d)|(\d\d))_','$1\. '),...
                                'Value',Channels_Ordering.Digital{3,chk_index},...
                                'UserData','Digital',...
                                'Callback',{@checkbox_callback,chk_index});
              
    end
    uicontrol(...
      'Parent',hpanel(3),...
      'Units','normalized',...
      'Position',[.1,.1,.9,.8],...
      'BackgroundColor',get(hpanel(2),'BackgroundColor'),...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',('Measurment Options'));
  
    clear_button_Analog=uicontrol(...
            'Parent',hpanel(1),...
            'String','Clear All',...
            'Units','normalized',...
            'Style','pushbutton',...
            'UserData','Analog',...
            'Position',[0.65 0.01 0.3 0.1],...
            'Callback',@Clear_All_Channels);
        
    clear_button_Digital=uicontrol(...
            'Parent',hpanel(2),...
            'String','Clear All',...
            'Units','normalized',...
            'Style','pushbutton',...
            'UserData','Digital',...
            'Position',[0.65 0.01 0.3 0.1],...
            'Callback',@Clear_All_Channels);
end

function Channels_Data=Initialize_Channels(Experiment_Dat,Analog_Disp,Digital_Disp)

Digital_Names=fieldnames(Experiment_Dat.digitalProperties);
Analog_Names=fieldnames(Experiment_Dat.analogProperties);

Channels_Display.Analog=cell(3,size(Analog_Names,1)); %{Name,Channel}
Channels_Display.Digital=cell(3,size(Digital_Names,1)); %{Name,Channel}
Channels_Display.RF=cell(3,1);

for i=1:size(Channels_Display.Analog,2)
    Name=Analog_Names(i);
    Name=Name{1,1};
    Channels_Display.Analog{1,i}=Name;
    Channels_Display.Analog{2,i}=Experiment_Dat.analogProperties.(Name).Channel;
    Channels_Display.Analog{3,i}=0;
end

for i=1:size(Channels_Display.Digital,2)
    Name=Digital_Names(i);
    Name=Name{1,1};
    Channels_Display.Digital{1,i}=Name;
    Channels_Display.Digital{2,i}=Experiment_Dat.digitalProperties.(Name).Channel;  
    Channels_Display.Digital{3,i}=0;
end

Channels_Display.RF{1,1}='RF';
Channels_Display.RF{2,1}=999;

for i=1:size(Analog_Disp,2)+size(Digital_Disp,2)
    for j=1:size(Analog_Disp,2)
        if Analog_Disp(j)==999
            Channels_Display.Ordering{1,j}='RF';
            Channels_Display.Ordering{2,j}=999;
            Channels_Display.RF{3,1}=1;
        else
            Channels_Display.Ordering{1,j}='A';
            Channels_Display.Ordering{2,j}=Analog_Disp(j);
            Channels_Display.Analog{3,Analog_Disp(j)+1}=1;
        end
    end
    for k=size(Analog_Disp,2)+1:size(Analog_Disp,2)+size(Digital_Disp,2)
        Channels_Display.Ordering{1,k}='D';
        Channels_Display.Ordering{2,k}=Digital_Disp(k-size(Analog_Disp,2));
        Channels_Display.Digital{3,Digital_Disp(k-size(Analog_Disp,2))+1}=1;
    end
end
Channels_Data=Channels_Display;
end

function Clear_All_Channels(hObject, eventdata, handles)
    
if strcmp(get(hObject,'UserData'),'Analog')
    for i=1:size(checkbox_analog,2)
        
        if get(checkbox_analog(i),'Value')
            set(checkbox_analog(i),'Value',0);
            checkbox_callback(checkbox_analog(i),eventdata,i)
        end
    end
elseif strcmp(get(hObject,'UserData'),'Digital')
    for i=1:size(checkbox_digital,2)
        if get(checkbox_digital(i),'Value')
            set(checkbox_digital(i),'Value',0);
            checkbox_callback(checkbox_digital(i),eventdata,i)
        end
    end
elseif strcmp(get(hObject,'UserData'),'RF')
    if get(checkbox_analog(i),'Value')
            set(checkbox_analog(i),'Value',0);
            checkbox_callback(checkbox_digital(i),eventdata,i)
    end
end
end

function checkbox_callback(hObject,eventdata,index)

type=get(hObject,'UserData');
if strcmp(type,'Analog')
    Channels_Ordering.Analog{3,index}=get(hObject,'Value');
    if get(hObject,'Value')==1
       chnsize=size(Channels_Ordering.Ordering,2);
       Channels_Ordering.Ordering{1,chnsize+1}='A';
       Channels_Ordering.Ordering{2,chnsize+1}=index-1;
    elseif get(hObject,'Value')==0
        j=1;
        while j<=size(Channels_Ordering.Ordering,2)
           if (Channels_Ordering.Ordering{2,j}==index-1) && (strcmp(Channels_Ordering.Ordering{1,j},'A'));
               Channels_Ordering.Ordering(:,j)=[];
           end
           j=j+1;
        end
    end
elseif strcmp(type,'Digital')
    Channels_Ordering.Digital{3,index}=get(hObject,'Value');
    if get(hObject,'Value')==1
        chnsize=size(Channels_Ordering.Ordering,2);
        Channels_Ordering.Ordering{1,chnsize+1}='D';
        Channels_Ordering.Ordering{2,chnsize+1}=index-1;
    elseif get(hObject,'Value')==0
        j=1;
        while j<=size(Channels_Ordering.Ordering,2)
            if (Channels_Ordering.Ordering{2,j}==index-1) && (strcmp(Channels_Ordering.Ordering{1,j},'D'));
                Channels_Ordering.Ordering(:,j)=[];
            end
            j=j+1;
        end
    end
elseif strcmp(type,'RF')
    Channels_Ordering.RF{3,1}=get(hObject,'Value');
    if get(hObject,'Value')==1
        chnsize=size(Channels_Ordering.Ordering,2);
        Channels_Ordering.Ordering{1,chnsize+1}='RF';
        Channels_Ordering.Ordering{2,chnsize+1}=999;
    elseif get(hObject,'Value')==0
        j=1;
        while j<=size(Channels_Ordering.Ordering,2)
            if (Channels_Ordering.Ordering{2,j}==999) && (strcmp(Channels_Ordering.Ordering{1,j},'RF'));
                Channels_Ordering.Ordering(:,j)=[];
            end
            j=j+1;
        end
    end
end  
end

function button(hObject, eventdata, handles)
DisplayChannels;
end
end

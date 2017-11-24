function Compare_Data=compare_labview(file1,file2)
global output 

%file1='C:\Ramon\RawData\Labview_data.txt';
%file2='C:\Ramon\RawData\Labview_data.txt';
%file2='C:\Ramon\RawData\Labview_data_to_load.txt';
output_filename='\compare_output.txt';

output=fopen(output_filename,'wt+');

if isstruct(file1)
    struct_1=file1;
else
    struct_1=read_labview(file1);
end

if isstruct(file2)
    struct_2=file2;
else
    struct_2=read_labview(file2);
end


[comp,string]=isitgood(struct_1,struct_2,'Start',0);

fclose(output);

fileinfo=dir(output_filename);

if fileinfo.bytes~=0
    output=fopen(output_filename,'r+');
    i=1;
    while feof(output)==0

        tline=fgetl(output);
        line=textscan(tline, '%s', 'delimiter','>');
        for j=1:size(line{1,1},1)
            Compare_Data{i,j}=line{1,1}{j,1};
        end
        i=i+1;
    end
    fclose(output);
else
    Compare_Data=1;
end

end


function [comparison,String]=isitgood(structure1,structure2,String,comparison)
global output 

fieldnames_1=fieldnames(structure1);
fieldnames_2=fieldnames(structure2);

if size(fieldnames_1,1)==size(fieldnames_2,1)
   first_struct=999;
   last_struct=0;
   for ui=1:size(fieldnames_1,1)
        Name=fieldnames_1(ui);
        Name=Name{1,1};
       if isstruct(structure1(1,1).(Name))
           if first_struct==999
               first_struct=ui;
           end
           last_struct=ui;
       end
   end
    
    
    if size(structure1)==size(structure2)
        for k=1:size(structure1,1)
            for l=1:size(structure1,2)
    
    for i=1:size(fieldnames_1,1)
        
        Name_1=fieldnames_1(i);
        Name_2=fieldnames_2(i);
        
        Name_1=Name_1{1,1};
        Name_2=Name_2{1,1};
        
        if strcmp(Name_1,Name_2)
            

            if isstruct(structure1(k,l).(Name_1)) && isstruct(structure2(k,l).(Name_2))
                
                if i==first_struct %&& size(regexp(String,'->','match'),2)==comparison
                    [comparison,String]=isitgood(structure1(k,l).(Name_1),structure2(k,l).(Name_2),[String '>' Name_1],comparison+1);
                    
                else
                    [comparison,String]=isitgood(structure1(k,l).(Name_1),structure2(k,l).(Name_2),[regexprep(String,'[^>]*$','') Name_1],comparison); %[regexprep(String,'[^>]*$','') Name_1]
                    
                    
                end
                if i==last_struct
                        comparison=comparison-1;
                        String=regexprep(String,'>[^>]*$','');
                        %fprintf(output,'\n');
                end
            elseif isnumeric(structure1(k,l).(Name_1)) && isnumeric(structure2(k,l).(Name_2))
                if structure1(k,l).(Name_1)~=structure2(k,l).(Name_2)
                    fprintf(output,[String,'>',Name_1,'>Mismatch','>numeric>', num2str(structure1(k,l).(Name_1)), '>', num2str(structure2(k,l).(Name_2)),'\n']);
                    %comparison=0;
                    
                end
            elseif iscell(structure1(k,l).(Name_1)) && iscell(structure2(k,l).(Name_2))
                if size(structure1(k,l).(Name_1))==size(structure2(k,l).(Name_2))
                    for i=1:size(structure1(k,l).(Name_1),1)
                        for j=1:size(structure1(k,l).(Name_1),2)
                            if ~isequal(structure1(k,l).(Name_1){i,j}, structure2(k,l).(Name_2){i,j})
                                fprintf(output,[String,'>',Name_1,'>Mismatch','>cell>', num2str(i), '>',num2str(j),'>',num2str(structure1(k,l).(Name_1){i,j}) '>' num2str(structure2(k,l).(Name_2){i,j}),'\n' ]);
                                %comparison=0;
                            end
                        end
                    end
                end
            elseif ischar(structure1(k,l).(Name_1)) && ischar(structure2(k,l).(Name_2))
                if ~strcmp(structure1(k,l).(Name_1),structure2(k,l).(Name_2))
                    fprintf(output,[String,'>',Name_1,'>Mismatch','>string>',structure1(k,l).(Name_1),'>',structure2(k,l).(Name_2),'\n']);
                    %comparison=0;
                end
                
            else
                '(what next?)'
            end
            
            
            
        end
        
    end
        
            end
        end
    end
else
    fprintf(output,'[Not sames number of fields]');
end

end

subjects = unique(Sleep_table.SubjectIndex);
subject_names =  fieldnames(Sleep_Struct);
print_folder = 'C:\Users\scro2778\Documents\GitHub\RBD-Sleep-Detection\data\features\HR Graphs';

for i=1:length(subjects)
   sub_idx = ismember(Sleep_table.SubjectIndex,subjects(i));
   
   sub_rem_idx = sub_idx & ismember(Sleep_table.AnnotatedSleepStage,5);
   sub_n3_idx = sub_idx & ismember(Sleep_table.AnnotatedSleepStage,3);
   sub_n2_idx = sub_idx & ismember(Sleep_table.AnnotatedSleepStage,2);
   
   
   f1 = figure;
   scatter(Sleep_table.RMSSD(sub_n2_idx),Sleep_table.nHF(sub_n2_idx));
   hold on;
   scatter(Sleep_table.RMSSD(sub_n3_idx),Sleep_table.nHF(sub_n3_idx),'c');
   scatter(Sleep_table.RMSSD(sub_rem_idx),Sleep_table.nHF(sub_rem_idx),'r');
   hold off;   
   titlename = [cell2mat(subject_names(i)),'_nHF_Vs_RMSSD'];
   title(titlename, 'Interpreter', 'none');
   ylabel('nHF');
   xlabel('RMSSD');
   legend({'N2','N3','REM'});
   saveas(f1,strcat(print_folder,'\',titlename),'png');   
    
   f2 = figure;
   scatter(Sleep_table.LFHF(sub_n2_idx),Sleep_table.RR(sub_n2_idx));
   hold on;
   scatter(Sleep_table.LFHF(sub_n3_idx),Sleep_table.RR(sub_n3_idx),'c');
   scatter(Sleep_table.LFHF(sub_rem_idx),Sleep_table.RR(sub_rem_idx),'r');
   hold off;   
   titlename = [cell2mat(subject_names(i)),'_RR_Vs_LFHF'];
   title(titlename, 'Interpreter', 'none');
   ylabel('RR');
   xlabel('LFHF');
   legend({'N2','N3','REM'});   
   saveas(f2,strcat(print_folder,'\',titlename),'png');   

   f3 = figure;
   scatter(Sleep_table.nLF(sub_n2_idx),Sleep_table.nHF(sub_n2_idx));
   hold on;
   scatter(Sleep_table.nLF(sub_n3_idx),Sleep_table.nHF(sub_n3_idx),'c');
   scatter(Sleep_table.nLF(sub_rem_idx),Sleep_table.nHF(sub_rem_idx),'r');
   hold off;   
   titlename = [cell2mat(subject_names(i)),'_nHF_Vs_nLF'];
   title(titlename, 'Interpreter', 'none');
   ylabel('nHF');
   xlabel('nLF');
   legend({'N2','N3','REM'});      
   saveas(f3,strcat(print_folder,'\',titlename),'png');   
   
   close all;
   
end
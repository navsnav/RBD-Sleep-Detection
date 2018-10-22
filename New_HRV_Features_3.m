
subjects = unique(Sleep_table.SubjectIndex);
subject_names =  fieldnames(Sleep_Struct);
print_folder = 'C:\Users\scro2778\Documents\GitHub\RBD-Sleep-Detection\data\features\HR Graphs';

for i=1:length(subjects)
   sub_idx = ismember(Sleep_table.SubjectIndex,subjects(i));
   
   sub_rem_idx = sub_idx & ismember(Sleep_table.AnnotatedSleepStage,5);
   sub_n3_idx = sub_idx & ismember(Sleep_table.AnnotatedSleepStage,3);
   sub_n2_idx = sub_idx & ismember(Sleep_table.AnnotatedSleepStage,2);
   
   STD_RR_REM(i) = std(Sleep_table.RR(sub_rem_idx));
   STD_RR_N3(i) = std(Sleep_table.RR(sub_n3_idx));
   STD_RR_N2(i) = std(Sleep_table.RR(sub_n2_idx));
   
   AI(i) = mean(Sleep_table.EMG_AtoniaIndex(sub_rem_idx));
   
   STD_RR_Index_REMN2(i) = (STD_RR_REM(i) - STD_RR_N2(i));
   STD_RR_Index_REMN3(i) = (STD_RR_REM(i) - STD_RR_N3(i));
   RBD_Condition(i) = all(Sleep_table.SubjectCondition(sub_idx)==5);
  
end

%% Set range to 0-1

STD_RR_REM_norm = STD_RR_REM - min(STD_RR_REM); 
STD_RR_REM_norm = STD_RR_REM_norm / max(STD_RR_REM_norm); 

STD_RR_N3_norm = STD_RR_N3 - min(STD_RR_N3); 
STD_RR_N3_norm = STD_RR_N3_norm / max(STD_RR_N3_norm); 

STD_RR_N2_norm = STD_RR_N2 - min(STD_RR_N2); 
STD_RR_N2_norm = STD_RR_N2_norm / max(STD_RR_N2_norm); 

STD_RR_Index_REMN2_norm = STD_RR_Index_REMN2 - min(STD_RR_Index_REMN2);  
STD_RR_Index_REMN2_norm = STD_RR_Index_REMN2_norm / max(STD_RR_Index_REMN2_norm); 

STD_RR_Index_REMN3_norm = STD_RR_Index_REMN3 - min(STD_RR_Index_REMN3);  
STD_RR_Index_REMN3_norm = STD_RR_Index_REMN3_norm / max(STD_RR_Index_REMN3_norm); 
%% Atonia Absence Index
% 
% ai_idx = AI<0.9;
% 
% figure, plot([AI(~ai_idx);STD_RR_N2_norm(~ai_idx)],'b');
% hold on;
% plot([AI(ai_idx);STD_RR_N2_norm(ai_idx)],'r');

%% RBD and Absence of Atonia

rbd_ai_idx = RBD_Condition & AI<0.9; %This index is RBD subjects with lack of atonia
tp_idx = rbd_ai_idx;
rbd_hi_ai_idx = RBD_Condition & AI>=0.9; %This index is RBD subjects with atonia
fn_idx = rbd_hi_ai_idx;
hc_ai_idx = ~RBD_Condition & AI<0.9; %This index is HC subjects with lack of atonia
fp_idx = hc_ai_idx;
hc_hi_ai_idx = ~RBD_Condition & AI>=0.9; %This index is RBD subjects with atonia
tn_idx = hc_hi_ai_idx;

sum(fn_idx & STD_RR_REM_norm>0.3);
sum(fp_idx & STD_RR_REM_norm<0.3)

% figure, plot([AI(rbd_ai_idx);STD_RR_Index_REMN2_norm(rbd_ai_idx)],'r');
% hold on;
% plot([AI(rbd_hi_ai_idx);STD_RR_Index_REMN2_norm(rbd_hi_ai_idx)],'b');
% hold on;
% plot([AI(hc_hi_ai_idx);STD_RR_Index_REMN2_norm(hc_hi_ai_idx)],'c');
% hold on;
% plot([AI(hc_ai_idx);STD_RR_Index_REMN2_norm(hc_ai_idx)],'m');
%%



print_scatter_hrv(RBD_Condition,STD_RR_Index_REMN2_norm,AI,'STD_RR_Index_REMN2',print_folder);
print_scatter_hrv(RBD_Condition,STD_RR_Index_REMN3_norm,AI,'STD_RR_Index_REMN3',print_folder);
print_scatter_hrv(RBD_Condition,STD_RR_REM_norm,AI,'STD_RR_REM',print_folder);
print_scatter_hrv(RBD_Condition,STD_RR_N2_norm,AI,'STD_RR_N2',print_folder);
print_scatter_hrv(RBD_Condition,STD_RR_N3_norm,AI,'STD_RR_N3',print_folder);


%%
% 
% figure;
% subplot(2,1,1);
% plot([AI(rbd_hi_ai_idx);STD_RR_Index_REMN2_norm(rbd_hi_ai_idx)],'r');
% hold on;
% plot([AI(hc_ai_idx);STD_RR_Index_REMN2_norm(hc_ai_idx)],'b');
% subplot(2,1,2);
% plot([AI(rbd_ai_idx);STD_RR_Index_REMN2_norm(rbd_ai_idx)],'r');
% hold on;
% plot([AI(hc_hi_ai_idx);STD_RR_Index_REMN2_norm(hc_hi_ai_idx)],'b');



%% functions
function print_scatter_hrv(rbd_group,hrv_feat,ai_feat,label,print_folder)
    tp_idx = rbd_group & ai_feat<0.9; %This index is RBD subjects with lack of atonia
    fn_idx = rbd_group & ai_feat>=0.9; %This index is RBD subjects with atonia
    fp_idx = ~rbd_group & ai_feat<0.9; %This index is HC subjects with lack of atonia
    tn_idx = ~rbd_group & ai_feat>=0.9; %This index is RBD subjects with atonia

    fig_t=figure;
    scatter(ai_feat(tp_idx),hrv_feat(tp_idx));
    hold on;
    scatter(ai_feat(fn_idx),hrv_feat(fn_idx));
    scatter(ai_feat(tn_idx),hrv_feat(tn_idx),'x');
    scatter(ai_feat(fp_idx),hrv_feat(fp_idx),'x');
    legend({'TP (RBD)','FN (RBD)','TN (HC)','FP (HC)'},'Location','northwest');
    title([label,' Vs Atonia Index (REM)'],'Interpreter','none');
    xlabel('Atonia Index');
    ylabel(label,'Interpreter','none');
    xlim([-0.05,1.05]);
    ylim([-0.05,1.05]);    
    
    saveas(fig_t,strcat(print_folder,'\',label),'png');    
end
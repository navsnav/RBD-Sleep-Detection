function print_results(Sleep,Yhat_Results,states,print_figures,print_folder,display_flag)

num_subjects = unique(Sleep(:,1));

%% Generate for each Subject the Sleep Staging Performance (acc/sensi/speci/preci/recall/F1/Cohen)
for i=1:length(num_subjects)
    for j=1:length(states)
        
        subject_idx = ismember(Sleep(:,1),num_subjects(i));
        [acc, sensi, speci, prec, recall, f1] = process_classification_results(Yhat_Results(subject_idx)==states(j), Sleep(subject_idx,7)==states(j));
        Accuracy(j,i) = acc;
        Sensitivity(j,i) = sensi;
        Specificity(j,i) = speci;
        Precision(j,i) = prec;
        Recall(j,i) = recall;
        F1(j,i) = f1;
        %            if sum(Yhat_Results(subject_idx)==states(j))==0
        %               display([num2str(i),'&',num2str(j),' state found in subject']);
        %            end
        
        ConfMat_SS_REM_Summary = confusionmat(Yhat_Results(subject_idx)==states(j), Sleep(subject_idx,7)==states(j), 'order', [0 1]);
        kappa = kappa_result(ConfMat_SS_REM_Summary);
        CohenKappa(j,i) = kappa;
    end
    rbd(i) = all(Sleep(subject_idx,6)==5);
    
end

%% Generate Performance Table for all subjects
table_name='Summary_SS_Detection_Performance_Table';
[T1, T2]= print_performance_table(table_name,Accuracy,Sensitivity,Specificity,Precision,Recall,F1,CohenKappa,states,print_figures,print_folder);
%% Generate Performance Table for all RBD Participants
table_name='Summary_SS_Detection_Performance_Table_RBD';
[T3, T4] = print_performance_table(table_name,Accuracy(:,rbd),Sensitivity(:,rbd),Specificity(:,rbd),Precision(:,rbd),Recall(:,rbd),F1(:,rbd),CohenKappa(:,rbd),states,print_figures,print_folder);
%% Generate Performance Table for all HC Participants
table_name='Summary_SS_Detection_Performance_Table_HC';
[T5, T6] = print_performance_table(table_name,Accuracy(:,~rbd),Sensitivity(:,~rbd),Specificity(:,~rbd),Precision(:,~rbd),Recall(:,~rbd),F1(:,~rbd),CohenKappa(:,~rbd),states,print_figures,print_folder);

if display_flag
    disp('Automatic Sleep Stage Summary:');
    disp(T1);
end


end
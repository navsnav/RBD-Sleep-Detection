function [All_T, REM_T] = print_performance_table(table_name,Accuracy,Sensitivity,Specificity,Precision,Recall,F1,CohenKappa,states,print_figures,print_folder)

acc_mu = nanmean(Accuracy');
acc_rho = nanstd(Accuracy');
sensi_mu = nanmean(Sensitivity');
sensi_rho = nanstd(Sensitivity');
speci_mu = nanmean(Specificity');
speci_rho = nanstd(Specificity');
preci_mu = nanmean(Precision');
preci_rho = nanstd(Precision');
recall_mu = nanmean(Recall');
recall_rho = nanstd(Recall');
f1_mu = nanmean(F1');
f1_rho = nanstd(F1');
kappa_mu = nanmean(CohenKappa');
kappa_rho = nanstd(CohenKappa');

for i=1:length(states)
    overall_performance(:,:,i) = [acc_mu(i),acc_rho(i);sensi_mu(i),sensi_rho(i);speci_mu(i),speci_rho(i);preci_mu(i),preci_rho(i);recall_mu(i),recall_rho(i);f1_mu(i),f1_rho(i);kappa_mu(i),kappa_rho(i)];
end
repplusminus = repmat(char(177),7,1);
op_t = table([num2str(overall_performance(:,1,1),2),repplusminus,num2str(overall_performance(:,2,1),2)],...
    [num2str(overall_performance(:,1,2),2),repplusminus,num2str(overall_performance(:,2,2),2)],...
    [num2str(overall_performance(:,1,3),2),repplusminus,num2str(overall_performance(:,2,3),2)],...
    [num2str(overall_performance(:,1,4),2),repplusminus,num2str(overall_performance(:,2,4),2)],...
    [num2str(overall_performance(:,1,5),2),repplusminus,num2str(overall_performance(:,2,5),2)],...
    'RowNames',{'Accuracy','Sensitivity','Specificity','Precision','Recall','F1','Kappa'},...
    'VariableNames',{'W','N1','N2','N3','REM'});

All_T = op_t;
for i=1:size(overall_performance,1)
    for j=1:size(overall_performance,3)
        Data_op_t{i,j} =  op_t{i,j};
    end
end

if (print_figures)
    fig_sleep_staging_all = figure;
    All_T = uitable(fig_sleep_staging_all,'Data', Data_op_t,'ColumnName',op_t.Properties.VariableNames,...
        'RowName',op_t.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    saveas(fig_sleep_staging_all,strcat(print_folder,'\',table_name),'png');
end
All_T = op_t;

Row_Names = {'Accuracy','Sensitivity','Specificity','Precision','Recall','F1','Kappa'};
T2 = table(overall_performance(:,1),overall_performance(:,2),'RowNames',Row_Names,'VariableNames',{'Mean','Std'});

if (print_figures)
    fig_perf_all = figure;
    uitable('Data',T2{:,:},'ColumnName',T2.Properties.VariableNames,...
        'RowName',T2.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    saveas(fig_perf_all,strcat(print_folder,'\',['REM_',table_name]),'png');
end

REM_T = T2;

end
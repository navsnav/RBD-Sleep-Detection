function print_annotated_vs_auto(EMG_Table_Names,EMG_feats,rbd,EMG_Metric,EMG_Auto_Metric,print_figures,print_folder)


for q=1:length(EMG_feats)

    feat_name = cell2mat(EMG_Table_Names(EMG_feats(q)));

    fig_num(q) = figure;
    R = corrcoef(EMG_Metric(:,q),EMG_Auto_Metric(:,q),'rows','pairwise');
    plot(EMG_Metric(~rbd,q),EMG_Auto_Metric(~rbd,q),'bo');
    hold on;
    max_val = ceil(max(EMG_Metric(:,q)));
    plot(EMG_Metric(rbd,q),EMG_Auto_Metric(rbd,q),'ro');
    plot(0:max_val/10:max_val,0:max_val/10:max_val,'k--');
    % plot(ones(1,11)*0.9,0:0.1:1,'k--');
    title([feat_name,' Comparison (Correlation Coeff: ',num2str(R(1,2),3),')'], 'Interpreter', 'none');
    xlabel([feat_name,' (Annotated Sleep Staging)'], 'Interpreter', 'none');
    ylabel([feat_name,' (Automatic Sleep Staging)'], 'Interpreter', 'none');
    xlim([0 max_val]);
    ylim([0 max_val]);
    legend({'HC','RBD'},'Location','northwest');

    if (print_figures), saveas(fig_num(q),strcat(print_folder,'\',['Summary_All_',feat_name,'_Actual_Vs_Manual']),'epsc'), end  
    if (print_figures), saveas(fig_num(q),strcat(print_folder,'\',['Summary_All_',feat_name,'_Actual_Vs_Manual']),'fig'), end  
    
    
end

    feat_name = 'Motor Activity';
    
    dur_idx = find(strcmp(EMG_Table_Names(EMG_feats),'MAD_Dur'));
    per_idx = find(strcmp(EMG_Table_Names(EMG_feats),'MAD_Per'));

    fig_num(q+1) = figure;
    R = corrcoef(max(EMG_Metric(:,dur_idx),EMG_Metric(:,per_idx)),max(EMG_Auto_Metric(:,dur_idx),EMG_Auto_Metric(:,per_idx)),'rows','pairwise');
    plot(max(EMG_Metric(~rbd,dur_idx),EMG_Metric(~rbd,per_idx)),max(EMG_Auto_Metric(~rbd,dur_idx),EMG_Auto_Metric(~rbd,per_idx)),'bo');
    hold on;
    max_val = ceil(max(EMG_Metric(:,dur_idx)));
%     plot(EMG_Metric(rbd,q),EMG_Auto_Metric(rbd,q),'ro');
    plot(max(EMG_Metric(rbd,dur_idx),EMG_Metric(rbd,per_idx)),max(EMG_Auto_Metric(rbd,dur_idx),EMG_Auto_Metric(rbd,per_idx)),'ro');
    
    plot(0:max_val/10:max_val,0:max_val/10:max_val,'k--');
    % plot(ones(1,11)*0.9,0:0.1:1,'k--');
    title([feat_name,' Comparison (Correlation Coeff: ',num2str(R(1,2),3),')'], 'Interpreter', 'none');
    xlabel([feat_name,' (Annotated Sleep Staging)'], 'Interpreter', 'none');
    ylabel([feat_name,' (Automatic Sleep Staging)'], 'Interpreter', 'none');
    xlim([0 max_val]);
    ylim([0 max_val]);
    legend({'HC','RBD'},'Location','northwest');

    if (print_figures), saveas(fig_num(q+1),strcat(print_folder,'\',['Summary_All_',feat_name,'Max_Actual_Vs_Manual']),'epsc'), end  
    if (print_figures), saveas(fig_num(q+1),strcat(print_folder,'\',['Summary_All_',feat_name,'Max_Actual_Vs_Manual']),'fig'), end  
    


end
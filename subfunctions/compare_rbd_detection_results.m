function compare_rbd_detection_results(EMG_Metric,EMG_est_Yhat_Results,EMG_Yhat_Results,EMG_Table_Names,EMG_feats,rbd_group,label_name,print_figures,print_folder)
%New Features
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(EMG_Yhat_Results==1, rbd_group==1);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Yhat_Results==1, rbd_group==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD}];
%Established Features
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD]  = process_classification_results2(EMG_est_Yhat_Results==1, rbd_group==1);
ConfMat_RBD_Class_Summary = confusionmat(EMG_est_Yhat_Results==1, rbd_group==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];
%Atonia Index
ai_idx = find(strcmp(EMG_Table_Names(EMG_feats),'AI_REM'));
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(EMG_Metric(:,ai_idx)<0.9, [rbd_group==1]);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Metric(:,ai_idx)<0.9, rbd_group==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];
%Stream
stream_idx = find(strcmp(EMG_Table_Names(EMG_feats),'Stream'));
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(EMG_Metric(:,stream_idx)>30, [rbd_group==1]);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Metric(:,stream_idx)>30, rbd_group==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];

%Motor Activity
mad_dur_idx = find(strcmp(EMG_Table_Names(EMG_feats),'MAD_Dur'));
mad_per_idx = find(strcmp(EMG_Table_Names(EMG_feats),'MAD_Per'));
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(max(EMG_Metric(:,mad_dur_idx),EMG_Metric(:,mad_per_idx))>0.10, [rbd_group==1]);
ConfMat_RBD_Class_Summary = confusionmat(max(EMG_Metric(:,mad_dur_idx),EMG_Metric(:,mad_per_idx))>0.10, rbd_group==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];

%%
rbd_d_anno_tab = cell2table(rbd_d_anno_data,'VariableNames',{'Accuracy','Sensitivity','Specificity','Precision','Recall','F1','Kappa'},...
    'RowNames',{['MAD (',label_name,')'],['Stream (',label_name,')'],['Atonia Index (',label_name,')'],['Established Metrics (',label_name,')'],['New Features (',label_name,')']});

fig_rbd_d_annotated = figure('units','normalized','outerposition',[0 0 1 1]);

uitable(fig_rbd_d_annotated,'Data', rbd_d_anno_data,'ColumnName',rbd_d_anno_tab.Properties.VariableNames,...
'RowName',rbd_d_anno_tab.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);                
                
if (print_figures), saveas(fig_rbd_d_annotated,strcat(pwd,print_folder,['Summary_RBD_Detection_,',label_name,'_Table_All']),'png'), end

end
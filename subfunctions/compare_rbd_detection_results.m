function compare_rbd_detection_results(EMG_Metric,EMG_Table_Est,EMG_Table_New,EMG_est_Yhat_Results,EMG_Yhat_Results,label_name,print_figures,print_folder,display_flag)
% This function generates the performance of RBD detection using 
% established techniques and new ones
%
% Inputs:
%  EMG_Metric  - matrix with metrics for each participant 
%  EMG_Table_Est - EMG metric table with established features (includes
%                  RBD status)
%  EMG_Table_New - EMG metric table with new features (includes RBD status)
%  EMG_est_Yhat_Results   - RBD detection results using esablished metrics
%                           in a random forest 
%  EMG_Yhat_Results  - RBD detection results using new metrics/methods
%  EMG_Table_Names - Feature names for the columns generated from Calculate_EMG_Values_table() 
%  EMG_feats - Features indicies used for metrics
%  rbd_group - Participant class (0: HC, 1: RBD)
%  label_name - Label inidcating source of sleep staging (Auto/Manual)
%  print_figures - flag to save figures
%  print_folder - folder name to save figures in
%  display_flag - flag to display figures
% --
% RBD Sleep Detection Toolbox, version 1.0, November 2018
% Released under the GNU General Public License
%
% Copyright (C) 2018  Navin Cooray
% Institute of Biomedical Engineering
% Department of Engineering Science
% University of Oxford
% navin.cooray@eng.ox.ac.uk
%
%
% Referencing this work
% Navin Cooray, Fernando Andreotti, Christine Lo, Mkael Symmonds, Michele T.M. Hu, & Maarten De % Vos (in review). Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis. Clinical Neurophysiology.
%
% Last updated : 15-10-2018
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%

[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(EMG_Yhat_Results==1, EMG_Table_New.RBD==1);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Yhat_Results==1, EMG_Table_New.RBD==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD}];
%Established Features
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD]  = process_classification_results2(EMG_est_Yhat_Results==1, EMG_Table_Est.RBD==1);
ConfMat_RBD_Class_Summary = confusionmat(EMG_est_Yhat_Results==1, EMG_Table_Est.RBD==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];
%Atonia Index
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(EMG_Metric.AI_REM<0.9, EMG_Metric.RBD);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Metric.AI_REM<0.9, EMG_Metric.RBD, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];
%Stream
[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(EMG_Metric.Stream>30, EMG_Metric.RBD);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Metric.Stream>30, EMG_Metric.RBD, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];

%Motor Activity

[accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD] = process_classification_results2(max(EMG_Metric.MAD_Dur,EMG_Metric.MAD_Per)>0.10, EMG_Metric.RBD);
ConfMat_RBD_Class_Summary = confusionmat(max(EMG_Metric.MAD_Dur,EMG_Metric.MAD_Per)>0.10, EMG_Metric.RBD, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data = [{accRBD, sensiRBD, speciRBD, precRBD, recallRBD, f1RBD, kappaRBD};rbd_d_anno_data];

%%
rbd_d_anno_tab = cell2table(rbd_d_anno_data,'VariableNames',{'Accuracy','Sensitivity','Specificity','Precision','Recall','F1','Kappa'},...
    'RowNames',{['MAD (',label_name,')'],['Stream (',label_name,')'],['Atonia Index (',label_name,')'],['Established Metrics (',label_name,')'],['New Features (',label_name,')']});

          
if (print_figures)
    fig_rbd_d_annotated = figure('units','normalized','outerposition',[0 0 1 1]);

    uitable(fig_rbd_d_annotated,'Data', rbd_d_anno_data,'ColumnName',rbd_d_anno_tab.Properties.VariableNames,...
    'RowName',rbd_d_anno_tab.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);                

    saveas(fig_rbd_d_annotated,strcat(print_folder,'\',['Summary_RBD_Detection_,',label_name,'_Table_All']),'png');
end

if display_flag
   disp(['RBD Detection Summary (',label_name,'):']);
   disp(rbd_d_anno_tab); 
end

end
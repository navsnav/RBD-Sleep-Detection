function compare_rbd_detection_results(EMG_Metric,RBD_Yhat,label_name,print_figures,print_folder,display_flag)
% This function generates the performance of RBD detection using
% established techniques and new ones
%
% Inputs:
%  EMG_Metric  - Table with metrics for each participant
%  RBD_Yhat   - RBD detection results using metrics
%               in a random forest (each column represents
%               a new set of results)
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
%New Features
rbd_d_anno_data=[];
cell_names = {}; 

%Motor Activity
acc_metrics = process_classification_results(max(EMG_Metric.MAD_Dur,EMG_Metric.MAD_Per)>0.10, [EMG_Metric.RBD==1]);
ConfMat_RBD_Class_Summary = confusionmat(max(EMG_Metric.MAD_Dur,EMG_Metric.MAD_Per)>0.10, EMG_Metric.RBD==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data(end+1,:) = [acc_metrics, kappaRBD];

%Stream
acc_metrics = process_classification_results(EMG_Metric.Stream>30, [EMG_Metric.RBD==1]);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Metric.Stream>30, EMG_Metric.RBD==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data(end+1,:) = [acc_metrics, kappaRBD];

%Atonia Index
acc_metrics = process_classification_results(EMG_Metric.AI_REM<0.9, [EMG_Metric.RBD==1]);
ConfMat_RBD_Class_Summary = confusionmat(EMG_Metric.AI_REM<0.9, EMG_Metric.RBD==1, 'order', [0 1]);
kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
rbd_d_anno_data(end+1,:) = [acc_metrics, kappaRBD];

cell_names = [['MAD (',label_name,')'],['Stream (',label_name,')'],['Atonia Index (',label_name,')'],cell_names];


for i=1:size(RBD_Yhat,2)
    acc_metrics = process_classification_results(table2array(RBD_Yhat(:,i))==1, EMG_Metric.RBD==1);
    ConfMat_RBD_Class_Summary = confusionmat(table2array(RBD_Yhat(:,i))==1, EMG_Metric.RBD==1, 'order', [0 1]);
    kappaRBD = kappa_result(ConfMat_RBD_Class_Summary);
    rbd_d_anno_data(end+1,:) = [acc_metrics, kappaRBD];
    % ['Established Metrics (',label_name,')'],['New Features (',label_name,')']
    cell_names{end+1} = [cell2mat(RBD_Yhat.Properties.VariableNames(i)),' (',label_name,')'];
end





%%

rbd_d_anno_tab = array2table(rbd_d_anno_data,'VariableNames',{'Accuracy','Sensitivity','Specificity','Precision','Recall','F1','Kappa'},...
    'RowNames',cell_names);


if (print_figures)
    fig_rbd_d_annotated = figure('units','normalized','outerposition',[0 0 1 1]);
    
    uitable(fig_rbd_d_annotated,'Data', rbd_d_anno_data,'ColumnName',rbd_d_anno_tab.Properties.VariableNames,...
        'RowName',rbd_d_anno_tab.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
    
    saveas(fig_rbd_d_annotated,strcat(print_folder,'\',['Summary_RBD_Detection_',label_name,'_Table_All']),'png');
end

if display_flag
    disp(['RBD Detection Summary (',label_name,'):']);
    disp(rbd_d_anno_tab);
end

end
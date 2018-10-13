function [All_T, REM_T] = print_performance_table(table_name,Accuracy,Sensitivity,Specificity,Precision,Recall,F1,CohenKappa,states,print_figures,print_folder)
% This function generated performance table based on performance measures
%
% Inputs:
%  table_name    - name of table to be saved
%  Accuracy   - Accuracy results for each subject
%  Sensitivity - Sensitivity results for each subject
%  Specificity - Specificity results for each subject
%  Precision - Precision results for each subject
%  Recall - Recall results for each subject
%  F1  - F1 results for each subject
%  CohenKappa - CohenKappa results for each subject
%  states - sleep stages to be included in table
%  print_figures - flag to print/save table
%  print_folder - folder to save table
%
% Outputs:
%  All_T - Table with results for all states
%  REM_T - Table with results for only REM
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
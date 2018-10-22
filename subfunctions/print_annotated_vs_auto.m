function print_annotated_vs_auto(EMG_Table_Names,EMG_feats,EMG_Metric,EMG_Auto_Metric,print_figures,print_folder)
% This function plots the RBD metrics derived from manually annotated 
% and automatically classified sleep 
%
% Inputs:
%  EMG_Table_Names    - names of metrics 
%  EMG_feats   - index of metrics
%  EMG_Metric  - Table of RBD metrics
%  EMG_Auto_Metric  - Table of RBD metrics derivied from automatically
%                     classified sleep stages
%  print_figures  - flag to print/save figures
%  print_folder  -  folder to save figures
% 
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

rbd = EMG_Metric.RBD==1;

for p=1:length(EMG_feats)
    q = EMG_feats(p);
    feat_name = cell2mat(EMG_Table_Names(q));

    fig_num(p) = figure;
    R = corrcoef(table2array(EMG_Metric(:,q)),table2array(EMG_Auto_Metric(:,q)),'rows','pairwise');
    plot(table2array(EMG_Metric(~rbd,q)),table2array(EMG_Auto_Metric(~rbd,q)),'bo');
    hold on;
    max_val = ceil(max(table2array(EMG_Metric(:,q))));
    plot(table2array(EMG_Metric(rbd,q)),table2array(EMG_Auto_Metric(rbd,q)),'ro');
    plot(0:max_val/10:max_val,0:max_val/10:max_val,'k--');
    % plot(ones(1,11)*0.9,0:0.1:1,'k--');
    title([feat_name,' Comparison (Correlation Coeff: ',num2str(R(1,2),3),')'], 'Interpreter', 'none');
    xlabel([feat_name,' (Annotated Sleep Staging)'], 'Interpreter', 'none');
    ylabel([feat_name,' (Automatic Sleep Staging)'], 'Interpreter', 'none');
    xlim([0 max_val]);
    ylim([0 max_val]);
    legend({'HC','RBD'},'Location','northwest');

    if (print_figures), saveas(fig_num(p),strcat(print_folder,'\',['Summary_All_',feat_name,'_Actual_Vs_Manual']),'epsc'), end  
    if (print_figures), saveas(fig_num(p),strcat(print_folder,'\',['Summary_All_',feat_name,'_Actual_Vs_Manual']),'fig'), end  
    
    
end

    feat_name = 'Motor Activity';
    
    dur_idx = find(strcmp(EMG_Table_Names(EMG_feats),'MAD_Dur'));
    per_idx = find(strcmp(EMG_Table_Names(EMG_feats),'MAD_Per'));

    fig_num(q+1) = figure;
    R = corrcoef(max(table2array(EMG_Metric(:,dur_idx)),table2array(EMG_Metric(:,per_idx))),max(table2array(EMG_Auto_Metric(:,dur_idx)),table2array(EMG_Auto_Metric(:,per_idx))),'rows','pairwise');
    plot(max(table2array(EMG_Metric(~rbd,dur_idx)),table2array(EMG_Metric(~rbd,per_idx))),max(table2array(EMG_Auto_Metric(~rbd,dur_idx)),table2array(EMG_Auto_Metric(~rbd,per_idx))),'bo');
    hold on;
    max_val = ceil(max(table2array(EMG_Metric(:,dur_idx))));
%     plot(EMG_Metric(rbd,q),EMG_Auto_Metric(rbd,q),'ro');
    plot(max(table2array(EMG_Metric(rbd,dur_idx)),table2array(EMG_Metric(rbd,per_idx))),max(table2array(EMG_Auto_Metric(rbd,dur_idx)),table2array(EMG_Auto_Metric(rbd,per_idx))),'ro');
    
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
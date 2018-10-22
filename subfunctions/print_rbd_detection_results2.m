function    print_rbd_detection_results2(results_f_est,results_f_new,results_f_ecg,name1,name2,name3,tablename,print_figures,print_folder)
% This function compares rbd detection perforance between 2 sets of results
% and produces a table.
%
% Inputs:
%  results_f_est - 1st set of results with mean in first column and
%                  standard  deviation in the 2nd column. In the following
%                  row order: 'Accuracy','Sensitivity','Specificity','Precision','Recall','F1'
%  results_f_new - 2nd set of results, same as above. 
%  name1 - text name of 1st set of results
%  name2 - text name of 2nd set of results
%  tablename - name of table
%  print_figures - flag to print/save table
%  print_folder -  folder where table is saved
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
%% RBD Detection table (annotated)

overall_performance_rbd_est = [mean(results_f_est,1);std(results_f_est,1)];
overall_performance_rbd_new = [mean(results_f_new,1);std(results_f_new,1)];
overall_performance_rbd_ecg = [mean(results_f_ecg,1);std(results_f_ecg,1)];

op_t_rbd__est_cell = {[num2str(overall_performance_rbd_est(1,1),2),repmat('±',1,1),num2str(overall_performance_rbd_est(2,1),2)],...
[num2str(overall_performance_rbd_est(1,2),2),repmat('±',1,1),num2str(overall_performance_rbd_est(2,2),2)],...
[num2str(overall_performance_rbd_est(1,3),2),repmat('±',1,1),num2str(overall_performance_rbd_est(2,3),2)],...
[num2str(overall_performance_rbd_est(1,4),2),repmat('±',1,1),num2str(overall_performance_rbd_est(2,4),2)],...
[num2str(overall_performance_rbd_est(1,5),2),repmat('±',1,1),num2str(overall_performance_rbd_est(2,5),2)],...
[num2str(overall_performance_rbd_est(1,6),2),repmat('±',1,1),num2str(overall_performance_rbd_est(2,6),2)]};

op_t_rbd_new_cell = {[num2str(overall_performance_rbd_new(1,1),2),repmat('±',1,1),num2str(overall_performance_rbd_new(2,1),2)],...
[num2str(overall_performance_rbd_new(1,2),2),repmat('±',1,1),num2str(overall_performance_rbd_new(2,2),2)],...
[num2str(overall_performance_rbd_new(1,3),2),repmat('±',1,1),num2str(overall_performance_rbd_new(2,3),2)],...
[num2str(overall_performance_rbd_new(1,4),2),repmat('±',1,1),num2str(overall_performance_rbd_new(2,4),2)],...
[num2str(overall_performance_rbd_new(1,5),2),repmat('±',1,1),num2str(overall_performance_rbd_new(2,5),2)],...
[num2str(overall_performance_rbd_new(1,6),2),repmat('±',1,1),num2str(overall_performance_rbd_new(2,6),2)]};

op_t_rbd_ecg_cell = {[num2str(overall_performance_rbd_ecg(1,1),2),repmat('±',1,1),num2str(overall_performance_rbd_ecg(2,1),2)],...
[num2str(overall_performance_rbd_ecg(1,2),2),repmat('±',1,1),num2str(overall_performance_rbd_ecg(2,2),2)],...
[num2str(overall_performance_rbd_ecg(1,3),2),repmat('±',1,1),num2str(overall_performance_rbd_ecg(2,3),2)],...
[num2str(overall_performance_rbd_ecg(1,4),2),repmat('±',1,1),num2str(overall_performance_rbd_ecg(2,4),2)],...
[num2str(overall_performance_rbd_ecg(1,5),2),repmat('±',1,1),num2str(overall_performance_rbd_ecg(2,5),2)],...
[num2str(overall_performance_rbd_ecg(1,6),2),repmat('±',1,1),num2str(overall_performance_rbd_ecg(2,6),2)]};

op_t_rbd_det = cell2table([op_t_rbd__est_cell;op_t_rbd_new_cell;op_t_rbd_ecg_cell],'VariableNames',{'Accuracy','Sensitivity','Specificity','Precision','Recall','F1'},...
    'RowNames',{name1,name2,name3});

fig_rbd_det = figure('units','normalized','outerposition',[0 0 1 1]);

uitable(fig_rbd_det,'Data', [op_t_rbd__est_cell;op_t_rbd_new_cell;op_t_rbd_ecg_cell],'ColumnName',op_t_rbd_det.Properties.VariableNames,...
'RowName',op_t_rbd_det.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
if (print_figures), saveas(fig_rbd_det,strcat(print_folder,'\',tablename),'png'), end

end
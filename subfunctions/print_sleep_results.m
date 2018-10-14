function rbd = print_sleep_results(Sleep,Yhat_Results,rbd,states,print_figures,print_folder)
% This function generates performance tables for sleep staging for all
% subjects and also separate tables for RBD participants and healthy
% controls
%
% Inputs:
%  Sleep    - number of eggs
%  Yhat_Results   - weight of butter (in g)
%
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
num_subjects = unique(Sleep(:,1));

%% Generate for each Subject the Sleep Staging Performance (acc/sensi/speci/preci/recall/F1/Cohen)
for i=1:length(num_subjects)
    for j=1:length(states)

        subject_idx = ismember(Sleep(:,1),num_subjects(i));
        [acc, sensi, speci, prec, recall, f1] = process_classification_results2(Yhat_Results(subject_idx)==states(j), Sleep(subject_idx,7)==states(j));        
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
% rbd(i) = all(Sleep(subject_idx,6)==5);

end

%% Generate Performance Table for all subjects
table_name='Summary_SS_Detection_Performance_Table';
print_performance_table(table_name,Accuracy,Sensitivity,Specificity,Precision,Recall,F1,CohenKappa,states,print_figures,print_folder);
%% Generate Performance Table for all RBD Participants
table_name='Summary_SS_Detection_Performance_Table_RBD';
print_performance_table(table_name,Accuracy(:,rbd),Sensitivity(:,rbd),Specificity(:,rbd),Precision(:,rbd),Recall(:,rbd),F1(:,rbd),CohenKappa(:,rbd),states,print_figures,print_folder);
%% Generate Performance Table for all HC Participants
table_name='Summary_SS_Detection_Performance_Table_HC';
print_performance_table(table_name,Accuracy(:,~rbd),Sensitivity(:,~rbd),Specificity(:,~rbd),Precision(:,~rbd),Recall(:,~rbd),F1(:,~rbd),CohenKappa(:,~rbd),states,print_figures,print_folder);

%% REM Results
rem_perf_grp = figure;
subplot(2,3,1);
boxplot([Accuracy(5,:)]',rbd);
title('Accuracy');
xticklabels({'HC','RBD'});
ylim([-0.05,1.05]);
subplot(2,3,2);
boxplot([Sensitivity(5,:)]',rbd);
title('Sensitivity');
xticklabels({'HC','RBD'});
ylim([-0.05,1.05]);
subplot(2,3,3);
boxplot([Specificity(5,:)]',rbd);
title('Specificity');
xticklabels({'HC','RBD'});
ylim([-0.05,1.05]);
subplot(2,3,4);
boxplot([Precision(5,:)]',rbd);
title('Precision');
xticklabels({'HC','RBD'});
ylim([-0.05,1.05]);
subplot(2,3,5);
boxplot([F1(5,:)]',rbd);
title('F1');
xticklabels({'HC','RBD'});
ylim([-0.05,1.05]);
subplot(2,3,6);
boxplot([CohenKappa(5,:)]',rbd);
title('Kappa');
xticklabels({'HC','RBD'});
ylim([-0.05,1.05]);
if (print_figures), saveas(rem_perf_grp,strcat(pwd,print_folder,'Summary_REM_Detection_Performance_GroupBox_'),'png'), end



end
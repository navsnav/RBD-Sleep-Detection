function    All_Confusion = print_confusion_mats(Sleep,Sleep_Struct,Yhat,print_figures,print_folder)
% This function combines all individial subject confusion matrices for
% sleep staging and generates figures for comparison of automated and
% annoated sleep staging (hypnograms) 
%
% Inputs:
%  Sleep    - Matrix with all features for every epoch
%  Sleep_Struct   - Structure with all features for every epoch, includes
%                   subject names
%  Yhat - Results of automated sleep staging for each epoch
%  print_figures - flag to print/save figures of results
%  print_folder - folder to save figures
% Outputs:
%  All_Confusion - summated confusion matrix of all subjects
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
Subject = fieldnames((Sleep_Struct));   


for i=1:length(num_subjects)

    sub_idx = ismember(Sleep(:,1),num_subjects(i)); 

    [acc(i), sensi(i), speci(i), prec(i), recall(i), f1(i)] = process_classification_results(Yhat(sub_idx)==5, Sleep(sub_idx,7)==5);

    ConfMat1{i} = confusionmat(Yhat(sub_idx), Sleep(sub_idx,7), 'order', [0 1 2 3 5]);
    ConfMat3{i} = confusionmat(Yhat(sub_idx)==5, Sleep(sub_idx,7)==5, 'order', [0 1]);
    kappa(i) = kappa_result(ConfMat3{i});    
    conf_mat = ConfMat1{i}; 
    %total number of stages
    n = sum(sum(conf_mat,2)); 
    %number of agreements
    n_a = sum(sum(eye(size(conf_mat)).*conf_mat)); 
    %numberof agreement due to chance
    agree_chance = (sum(conf_mat,1)./n)*(sum(conf_mat,2)./n)*n;     
    kappa_SS(i) = (n_a-agree_chance)/(n-agree_chance);          
    %% Generate Figures
    % Confusion Matrix
  
    generate_confmat(ConfMat1{i},Subject{i},print_figures,print_folder);
    
    %Hypnograms
    fig_1 = figure;
    a(1) = subplot(2,1,1);
    plot(Sleep(sub_idx,7));
    title(['Annotated Test Sequence: ',Subject{i}], 'Interpreter', 'none');
    ylabel('Sleep Stage');
    xlabel('Epoch #');
    ylim([-0.5 6]);
    set(gca,'YTick',[0 1 2 3 5 6])
    set(gca,'YTickLabel',{'W','N1','N2','N3','R','M'})    
    a(2) = subplot(2,1,2);
    plot(Yhat(sub_idx),'r');
    title(['RF Classification (Accuracy:  ',num2str(acc(i),'%1.2f'),' Sensitivity:  ',num2str(sensi(i),'%1.2f'),' Specificity:  ',num2str(speci(i),'%1.2f'),')']);
    ylabel('Sleep Stage');
    xlabel('Epoch #');
    ylim([-0.5 6]);
    set(gca,'YTick',[0 1 2 3 5 6])
    set(gca,'YTickLabel',{'W','N1','N2','N3','R','M'})
    linkaxes(a,'x');
    if (print_figures), saveas(fig_1,strcat(print_folder,'\','RF_Hyp_Comparison_',Subject{i}),'epsc'), end

    fig_1b = figure;
    h1a = plot(Sleep(sub_idx,7),'DisplayName','Hypnogram','LineWidth',2);
    title(['Annotated Test Sequence: ',Subject{i}], 'Interpreter', 'none');
    ylabel('Sleep Stage');
    xlabel('Epoch #');
    ylim([-0.5 6]);
    set(gca,'YTick',[0 1 2 3 5 6])
    set(gca,'YTickLabel',{'W','N1','N2','N3','R','M'})   
    hold on;
    h2a = plot(Yhat(sub_idx),'r','DisplayName','RF Result','LineWidth',1);
    if (print_figures), saveas(fig_1b,strcat(print_folder,'\','RF_Hyp_AlignComp_',Subject{i}),'epsc'), end
%%
    T_results = process_classification_results_table(Yhat(sub_idx),Sleep(sub_idx,7));

    fig_t = figure;
    uitable('Data',T_results{:,:},'ColumnName',T_results.Properties.VariableNames,...
    'RowName',T_results.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);

    if (print_figures), saveas(fig_t,strcat(print_folder,'\','All_Sleep_Stage_Performance_Table_',Subject{i}),'png'), end


end
% Print Combined Confusion Matrix
    Summary_ConfMat = confusionmat(Yhat, Sleep(:,7), 'order', [0 1 2 3 5]);
    generate_confmat(Summary_ConfMat,'Summary',print_figures,print_folder);
% Print RBD Combined Confusion Matrix
    rbd_idx = Sleep(:,6)==5; 
    RBD_ConfMat = confusionmat(Yhat(rbd_idx), Sleep(rbd_idx,7), 'order', [0 1 2 3 5]);
    generate_confmat(RBD_ConfMat,'RBD_Summary',print_figures,print_folder);
% Print HC Combined Confusion Matrix
    HC_ConfMat = confusionmat(Yhat(~rbd_idx), Sleep(~rbd_idx,7), 'order', [0 1 2 3 5]);
    generate_confmat(HC_ConfMat,'HC_Summary',print_figures,print_folder);
    
    All_Confusion = ConfMat1;
end


function    All_Confusion = print_confusion_mats(Sleep,Sleep_Struct,Yhat,rbd,print_figures,print_folder)

num_subjects = unique(Sleep(:,1));
Subject = fieldnames((Sleep_Struct));   


for i=1:length(num_subjects)

    sub_idx = ismember(Sleep(:,1),num_subjects(i)); 

    [acc(i), sensi(i), speci(i), prec(i), recall(i), f1(i)] = process_classification_results2(Yhat(sub_idx)==5, Sleep(sub_idx,7)==5);

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


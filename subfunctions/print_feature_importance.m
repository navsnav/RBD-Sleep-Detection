function print_feature_importance(EMG_importance_Results,order_idx,EMG_Table_Names,EMG_feats,titlename,xname,print_figures,print_folder)


EMG_Importance_Acc = squeeze(EMG_importance_Results(:,order_idx,:));

mu_EMG_Importance_Acc = mean(EMG_Importance_Acc,2);
[B,I] = sort(mu_EMG_Importance_Acc,'ascend');
fignum = figure;
hbar = barh(B,'stacked','r');
set(gca,'TickLabelInterpreter', 'none');
x = get(hbar,'XData');
yticks(x);
yticklabels(EMG_Table_Names(EMG_feats(I)));
title(titlename);
xlabel(xname);
if (print_figures), saveas(fignum,strcat(print_folder,'\',titlename),'png'), end

end
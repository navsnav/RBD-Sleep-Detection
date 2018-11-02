function T = process_classification_results_table(Yhat, Ytst)
%This function produces recall, prevision and F1 score for all sleep stages

        Stages = [0,1,2,3,5];

for i=1:length(Stages)
    
        Ytst_Stage = Ytst == Stages(i);
        Yhat_Stage = Yhat == Stages(i);

        
        TP = Yhat_Stage(Ytst_Stage == 1);
        TP =  length(TP(TP == 1));
        
        FP = Yhat_Stage(Ytst_Stage == 0);
        FP = length(FP(FP == 1));
        
        FN = Yhat_Stage(Ytst_Stage == 1);
        FN = length(FN(FN==0));
        
        TN = Yhat_Stage(Ytst_Stage == 0);
        TN = length(TN(TN==0));
        
        sensi(i) = TP/(TP+FN); 
        speci(i) = TN/(FP+TN);
        acc(i) = numel(find(Yhat_Stage==Ytst_Stage))/length(Ytst_Stage);
        prec(i) = TP/(TP+FP);
        recall(i) = TP/(TP+FN);
        f1(i) = 2*((recall(i)*prec(i))/(recall(i)+prec(i)));
        ppv = TP/(TP+FP);
        
        ConfMat = confusionmat(Yhat_Stage, Ytst_Stage, 'order', [0 1]);
        kappa(i) = kappa_result(ConfMat);
    
end
        Accuracy = acc';
        Sensitivity = sensi';
        Specificity = speci';
        CohenKappa =  kappa';
        Precision = prec';
        Recall = recall';
        F1 = f1';
        
        Stage_Names = {'Wake';'N1';'N2';'N3';'REM'};
        T = table(Accuracy,Sensitivity,Specificity,CohenKappa,Precision,Recall,F1,'RowNames',Stage_Names);        
        
end      
function [acc, sensi, speci, prec, recall, f1, ppv] = process_classification_results2(Yhat, Ytst)
%This function produces recall, prevision and F1 score

        TP = Yhat(Ytst == 1);
        TP =  length(TP(TP == 1));
        
        FP = Yhat(Ytst == 0);
        FP = length(FP(FP == 1));
        
        FN = Yhat(Ytst == 1);
        FN = length(FN(FN==0));
        
        TN = Yhat(Ytst == 0);
        TN = length(TN(TN==0));
        
        sensi = TP/(TP+FN); 
        speci = TN/(FP+TN);
        acc = numel(find(Yhat==Ytst))/length(Ytst);
        prec = TP/(TP+FP);
        recall = TP/(TP+FN);
        f1 = 2*((recall*prec)/(recall+prec));
        ppv = TP/(TP+FP);
end      
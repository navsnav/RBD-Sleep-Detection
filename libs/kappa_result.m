function [kappa] = kappa_result(conf_mat)
%This function produces kappa results for a given confusion matrix

    %total number of stages
    n = sum(sum(conf_mat,2)); 
    %number of agreements
    n_a = sum(sum(eye(size(conf_mat)).*conf_mat)); 
    %numberof agreement due to chance
    agree_chance = (sum(conf_mat,1)./n)*(sum(conf_mat,2)./n)*n; 
    
    kappa = (n_a-agree_chance)/(n-agree_chance);
        
end      
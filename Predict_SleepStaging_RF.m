function [Yhat,votes] = Predict_SleepStaging_RF(rf,Xtst)
% Input:
%       rf: Trained Random Forest Model from TreeBagger.
%       Xtst: Test set using same features used for training rf model.
% Output:
%       Yhat: Results of sleep staging from trained rf model.   
%       votes: Percentage of votes for each stage.

    [Yhat,votes] = predict(rf,Xtst);       
    Yhat = str2num(cell2mat(Yhat));

end

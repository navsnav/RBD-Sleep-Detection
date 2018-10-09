function [EMG_Yhat,EMG_votes] = Predict_RBDDetection_RF(emg_rf,EMG_Xtst)
% Input:
%       rf: Trained Random Forest Model from TreeBagger.
%       Xtst: Test set using same features used for training rf model.
% Output:
%       Yhat: Results of sleep staging from trained rf model.   
%       votes: Percentage of votes for each stage.

    [EMG_Yhat,EMG_votes] = predict(emg_rf,EMG_Xtst);       
    EMG_Yhat = str2num(cell2mat(EMG_Yhat));

end

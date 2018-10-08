function [EMG_Yhat,EMG_votes]  = Predict_RBD_Detection(rf,Sleep_table)

    EMG_Xtst=table2array(Sleep_table);
    %Predict using all emg features for annotated Sleep Staging
    [EMG_Yhat,EMG_votes]  = predict(rf,EMG_Xtst);  
    EMG_Yhat = str2num(cell2mat(EMG_Yhat));
end

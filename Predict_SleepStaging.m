function [Yhat,votes] = Predict_SleepStaging(rf,Xtst)


[Yhat,votes] = predict(rf,Xtst);       
Yhat = str2num(cell2mat(Yhat));

end

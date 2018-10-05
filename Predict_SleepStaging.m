function [Yhat,votes] = Predict_SleepStaging(rf,Xtst)


[Yhat,votes] = predict(rf,Xtst);       


end

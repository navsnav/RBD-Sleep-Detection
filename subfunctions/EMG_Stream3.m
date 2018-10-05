function Stream_score = EMG_Stream3(data_signal1, hyp,fs,data_collection_start)
% Input:
%       data_signal1:           1D array of the EMG signal
%       hyp:                    hypnogram for recording
%       fs:                     data_signal1 sampling rate
%       data_collection_start:  time at which recording starts (s)
% Output:
%       Stream_score:   STREAM scores derived from algorithm    

REM_var = [];
NREM_var = [];
for i = 1:length(hyp)
   hyp_start_time = hyp(i,2);
   REM_epoch = hyp(i,1) == 5;
   NREM_epoch = hyp(i,1) == 1| hyp(i,1)==2 | hyp(i,1)== 3 | hyp(i,1)==4;
   time_diff = hyp_start_time - data_collection_start;
   EMG_epochs = data_signal1(time_diff*fs+1:(time_diff+30)*fs);

    if REM_epoch
        EMG_epochs_i = EMG_epochs;
        EMG_miniepochs = buffer(EMG_epochs_i,3*fs)';
        EMG_var = var(EMG_miniepochs,0,2);
        REM_var = [REM_var;EMG_var];
    elseif NREM_epoch
        EMG_epochs_i = EMG_epochs;    
        EMG_miniepochs = buffer(EMG_epochs_i,3*fs)';
        EMG_var = var(EMG_miniepochs,0,2);
        NREM_var = [NREM_var;EMG_var];
        
    end   
    
end
Stream_t = 4*prctile(NREM_var,5);

Stream_score  = sum(REM_var>Stream_t)/length(REM_var)*100;


end

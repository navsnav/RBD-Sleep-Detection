function Stream_score = EMG_Stream_Sleep(Sleep_feat, hyp)
REM_var = [];
NREM_var = [];


for i = 1:length(hyp)
   REM_epoch = hyp(i,1) == 5;
   NREM_epoch = hyp(i,1) == 1| hyp(i,1)==2 | hyp(i,1)== 3 | hyp(i,1)==4;

    if REM_epoch

        EMG_var = Sleep_feat(i);
        REM_var = [REM_var;EMG_var];
    elseif NREM_epoch
        EMG_var = Sleep_feat(i);
        NREM_var = [NREM_var;EMG_var];
        
    end   
    
end
Stream_t = 4*prctile(NREM_var,5);

Stream_score  = sum(REM_var>Stream_t)/length(REM_var)*100;


end

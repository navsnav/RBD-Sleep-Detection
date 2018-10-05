function MAE_epoch = Find_MAE(AC_Act_Delta_30s,EMG_Baseline_min,fs,min_mae_dur,mae_iei,madt)
% Input:
%       AC_Act_Delta_30s: Activity signal as defined by Frandsen et al.
%       EMG_Baseline_min: EMG Baseline as defined by Frandsen et al.
%       fs: sampling rate
%       min_mae_dur:  min motor activity duration (s)
%       mae_iei: max inter motor acticvity interval (s)
%       madt: motor activity threshold 
% Output:
%       MAE_epoch: Motor acticity detection 
%           -1st column:  motor acticity duration in seconds in epoch
%           -2nd column:  motor acticity as a percentage of epoch  

MAE_epoch = zeros(size(EMG_Baseline_min));



for i=1:size(AC_Act_Delta_30s,1)
    
    
    num_mae = AC_Act_Delta_30s(i,:)>(madt*EMG_Baseline_min(i));
    
    AC_Act_Delta_3s = buffer(AC_Act_Delta_30s(i,:),3*fs)';
    num_mae_3s = buffer(num_mae,3*fs)';
    
    for j=1:size(AC_Act_Delta_3s,1);
    
        diff_num_mae_3s = diff(num_mae_3s(j,:));
        % If beginning is above threshold
        if num_mae_3s(j,1) == 1
            start_mae = [true,diff_num_mae_3s==1];            
        else
            start_mae = [false,diff_num_mae_3s==1];
        end
        %If end if above threshold
        if num_mae_3s(j,end) == 1
            end_mae = [diff_num_mae_3s==-1,true];            
        else 
            end_mae = [diff_num_mae_3s==-1,false];            
        end
        
        %% Min duration 
        start_mae_idx = find(start_mae);
        end_mae_idx = find(end_mae);        
        min_mae_samp = floor(min_mae_dur*fs);        
        mae_dur = end_mae_idx-start_mae_idx;
        % Remove MAE below Min Duration
        for k=1:length(mae_dur)
            if mae_dur(k) < min_mae_samp
                start_mae(start_mae_idx(k)) = false;
                end_mae(end_mae_idx(k)) = false;
            end
        end
        
        %% Inter-event Interval
        
        start_mae_idx = find(start_mae);
        end_mae_idx = find(end_mae);        
        min_mae_int = floor(mae_iei*fs);     
        
        % Check how many intervals there are
        if length(start_mae_idx)>1            
            mae_int_dur = diff(start_mae_idx);
            % Remove MAE below Min Duration
            for k=1:length(mae_int_dur)
                if mae_int_dur(k) < min_mae_int
                    start_mae(start_mae_idx(k+1)) = false; %Merge, but removing 2nd start
                    end_mae(end_mae_idx(k)) = false; % Merge by removing 1st end
                end
            end        
        end
        
        start_mae_idx = find(start_mae);
        end_mae_idx = find(end_mae);  
        
        mae_dur_time_3s(j) = sum((end_mae_idx - start_mae_idx)/fs);
        mae_dur_thresh_3s(j) = mae_dur_time_3s(j) > 1.5;
        
    end
    % Metric for percentage of MAE in epochs
    mae_dur_time_epoch(i) = sum(mae_dur_time_3s);
    
    % Metric for percentage of 3s miniepochs > 50% MAE
    mae_dur_thresh_epoch(i) = sum(mae_dur_thresh_3s)/length(mae_dur_thresh_3s);
    
    
end

MAE_epoch = [mae_dur_time_epoch;mae_dur_thresh_epoch]';

% Percentage of time 

end
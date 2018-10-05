% (c) Athanasios Tsanas, October 2012
%       last updated 2 March 2016
% (c) Navin Cooray, May 2017
%       last updated May 2017

%% Version 1 
% Implement original code with 30s averages
% function to process an EEG & EOG signal

function [features, features_struct_30s,features_struct] = FeatExtract_EEGEOG_mini(eeg_data_signal,eog_data_signal,fs,epoch_time,feature_time)
% function to process EEG and EOG signal for feature extraction
% Input:
%       eeg_data_signal: 1D vector of the EEG signal with all epochs
%       eog_data_signal: 1D vector of the EOG signal with all epochs
%       fs: sampling frequency
%       epoch_time: The time length of each epoch for feature extraction (s)
%       feature_time: Calculate features within each epoch for this period of time (s) 
% Output:
%       features:   matrix with all features for recording for each epoch
%       features_struct_30s:   Structure with subject and feature extracted for each signal for every epoch_time (s)   
%       features_struct:   Structure with subject and feature extracted for each signal for every feature_time (s) 

%% Step 3: Main part of the function - get some good features!
% Break down signal into 1s mini-epochs
mini_epoch_s = feature_time;
K = mini_epoch_s*fs;
eeg_signal_epoched = buffer(eeg_data_signal, K); % signal segments with length K
eog_signal_epoched = buffer(eog_data_signal, K); % signal segments with length K

% signal_epoched3s = buffer(data_signal1f, 3*fs, 2*fs); % signal segments with length 3K and overlapping K length segments on each side of the centred K segment

N = size(eeg_signal_epoched,2);

for i = 1:N  
    tic
    x = eeg_signal_epoched(:,i); % this is a part of the signal (1 sec segment)
    y = eog_signal_epoched(:,i);
 
  
    
%% Cross Correlation    
    features_struct.EEGEOG_CrossCorrelation(i,1) = max(abs(xcorr(x,y)));
    
%%  Correlation coefficients P values   
    [R,P] = corrcoef(x,y);
    features_struct.EEGEOG_CrossCorrelationPVal(i,1) = P(2,1);

%% Coherence    

    [Cxy,f] = mscohere(x,y,hamming(fs/2),[],[],fs);
    features_struct.EEGEOG_MSCoherence(i,1) = max(Cxy);
    
%% Spindles
    spindle_frequency_range = 11:16;
    alg_used = 'a7';
    fs_spin = 100;
    x2 = resample(x, fs_spin, fs);
    
    [detected_spindles, begins, ends] = spindle_estimation_FHN2015(x2, fs_spin, spindle_frequency_range, alg_used);
    features_struct.EEG_NumSpindles(i,1) = length(begins);
    

 
end % end of main function
% putvar(features_struct);
% disp('Finished the main function');


%%Use selected features
Snames = fieldnames(features_struct);
features = [];

%% Create moving average of EOG signal 1s
% for x = 1:numel(Snames)    
%     feature_field = features_struct.(Snames{x});
%     clear temp_features;    
%     windowSize = mini_epoch_s*fs;
%     A = ones(1,windowSize)/windowSize;    
%     temp_features = filtfilt(A,1,feature_field);
%     features = [features,temp_features];    
% end

%% Create 30s average for each epoch
%% Epoch length 
% epoch_time = 1;
for x = 1:numel(Snames)   
    feature_field = features_struct.(Snames{x});
    clear temp_features;    
    num_miniepochs = epoch_time/(K/fs);    
    for y = 1:(size(feature_field,1)/num_miniepochs)
        
        temp_features(y,:) = mean(feature_field((y-1)*num_miniepochs+1:y*num_miniepochs,:),1); 
    end
    features_struct_30s.(Snames{x}) = temp_features;                
    features = [features,temp_features];
    
    
end



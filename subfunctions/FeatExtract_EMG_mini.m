% (c) Athanasios Tsanas, October 2012
%       last updated 2 March 2016
% (c) Navin Cooray, July 2016
%       last updated 18 July 2016

%% Version 1 
% Implement original code with 30s averages, calculate Atonia Index for
% each epoch


function [features, features_struct_30s, EMG,features_struct] = FeatExtract_EMG_mini(data_signal1, fs,epoch_time, hyp)
% function to process an EMG signal for feature extraction
% Input:
%       data_signal1 is a 1D vector of the EMG signal with all epochs
%       fs: sampling frequency
%       epoch_time: The time length of each epoch for feature extraction (s)
%       feature_time: Calculate features within each epoch for this period of time (s) 
% Output:
%       features:   matrix with all features for recording for each epoch
%       features_struct_30s:   Structure with subject and feature extracted for each signal for every epoch_time (s)   
%       EMG:   EMG signal   
%       features_struct:   Structure with subject and feature extracted for each signal for every feature_time (s) 

% %Ensure EOG signal is calibrated to microvolts
Factor = 1;
if max(data_signal1) > 10   
    Factor = 1;
else
    %MilliVolts, change to micro
    data_signal1 = data_signal1*1000;
    Factor = 1000;
end

%% Setting defaults and pre-requisites for the algorithms

if(nargin<2) || isempty(fs)
    fs = 512;
end

%% Step 1: Design Filters

fs_prefilt = fs;


d2 = fdesign.notch('N,F0,Q,Ap',2,50,10,1,fs_prefilt);
Notchfilter = design(d2);
d3 = fdesign.notch('N,F0,Q,Ap',2,60,10,1,fs_prefilt);
Notchfilter2 = design(d3);
% fvtool(Notchfilter);


lp = fdesign.lowpass('N,Fp,Fst',100,95,100,fs_prefilt);
LPfilter = design(lp);
% fvtool(LPfilter);
% fvt = fvtool(LPfilter);

hp = fdesign.highpass('N,Fst,Fp',100,1,10,fs_prefilt);
HPfilter = design(hp);

%% Step 2: Filter Signal through low pass, high pass and notch filter

dataLP = filtfilt(LPfilter.Numerator,1,data_signal1);
dataHP = filtfilt(HPfilter.Numerator,1,dataLP);
dataNotchHPLP = filter(Notchfilter, dataHP);
dataNotchHPLP = filter(Notchfilter2, dataNotchHPLP);


%% Substitute PreFiltered Signal with original
EMG = dataNotchHPLP;
fs_emg = fs_prefilt;

%%

time_diff = hyp(1,2); 
% derive features that align with hypnogram 
start_align_emg = EMG(time_diff*fs+1:end);
EMG = start_align_emg;

%% Remove excess signal from end

time_diff_hyp = hyp(end,2) - hyp(1,2); 
total_samples = (time_diff_hyp*fs)+30*fs;
end_align_emg = EMG(1:(total_samples));
EMG = end_align_emg;


%% Atonia Index Feature

%Rectify Amplitude
EMG_rect = abs(EMG);

%Calculate Mean amplitude over 1second for EMG signal between with hypnogram annotations 
EMG_avg_amp = zeros(length(EMG_rect)/fs_emg,1);
for r=1:length(EMG_avg_amp)
    EMG_avg_amp(r) = mean(EMG_rect((r-1)*fs_emg+1:(r-1)*fs_emg+fs_emg));
end
fs_avg = 1;
%% Calculate Moving Minimum
% calculate window length (60s)
window = 60;
% Ferri et al 2010
% Long enough to allow reliable estimation of minimum noise level and shirt
% enough to allow a variable adjustment of this correction throughout night

%EMG_mov_min = movingmeanmin(EMG_avg_amp,window,[],[]);
EMG_mov_min = 0;
%% Substract Moving Minimum

EMG_avg_amp_corr = EMG_avg_amp - EMG_mov_min';

%% Determine if EMG signal is in micro and milli volts
if max(EMG_avg_amp_corr) > 10   
    %Microvolts
    EMG_avg_amp_corr_micro = EMG_avg_amp_corr;
else
    %MilliVolts, change to micro
    EMG_avg_amp_corr_micro = EMG_avg_amp_corr*1000;
%     display('EMG in millivolts');
end

%% Step 3: Main part of the function - get some good features!
% Break down signal into 30s mini-epochs
mini_epoch_s =30;


K = mini_epoch_s*fs_emg; %Check K is the same
EMG_rect_signal_epoched = buffer(EMG_rect, K); % signal segments with length K
EMG_signal_epoched = buffer(EMG, K); % signal segments with length K
if mod(length(EMG),K)> 0
   EMG_rect_signal_epoched(:,end) = []; 
   EMG_signal_epoched(:,end) = [];   
end
EMG_n = reshape(EMG_signal_epoched,numel(EMG_signal_epoched),1);

bin_val = 0.5:1:20;

num_epochs_30s = size(EMG_signal_epoched,2);

K = mini_epoch_s*fs_avg;
signal_epoched = buffer(EMG_avg_amp_corr_micro(1:30*num_epochs_30s*fs_avg), K); % signal segments with length K

AI = zeros(num_epochs_30s,1);
for i = 1:num_epochs_30s  
    tic
    x = signal_epoched(:,i); % this is a part of the signal (1 sec segment)
     %Class amplitudes into bins
    [N,~]=hist(x,bin_val);
    N_percent = N/sum(N)*100;
    AI(i) = N_percent(1)/(100-N_percent(2));    

    %% Atonia Index 
    features_struct.EMG_AtoniaIndex(i,1) = AI(i);   
    
    %% EMG Energy - Liang at al. 2012
    % Mean value of the absolute amplitude of total data points in an epoch
     x2 = EMG_rect_signal_epoched(:,i); % this is a part of the signal (1 sec segment)
     features_struct.EMG_Energy(i,1) = mean(x2);   

    %% EMG fractal exponent - Krakovska et al. 2011
    x3 = EMG_signal_epoched(:,i); 
    NFFT = 2^nextpow2(length(x3));
    [pxx, fxx] = periodogram(x3,hann(length(x3)),NFFT,fs);
    
    fxx_rng_idx = fxx<=100 & fxx>=10;
    fxx_rng = fxx(fxx_rng_idx);
    pxx_rng = pxx(fxx_rng_idx);

    
    log_pow = log(pxx_rng);
    log_freq = log(fxx_rng);
    s1 = -1*(log_freq\log_pow);
    features_struct.EMG_fractal_exponent(i,1) = s1;   
    
    % EMG Absolute Gamma Power - Krakovska et al. 2011
    gamma_pow = bandpower(pxx,fxx,[30 50],'psd');
    features_struct.EMG_gamma_power(i,1) = gamma_pow;    
    
    % EMG Relative Power - Charbonnier et al. 2012
    low_EMG_pow = bandpower(pxx,fxx,[12.5 32],'psd'); %12.5-32Hz
    total_EMG_pow =  bandpower(pxx,fxx,[8 32],'psd'); %8-32Hz
    EMG_rel_pow = low_EMG_pow/total_EMG_pow;   
    features_struct.EMG_Rel_Power(i,1) = EMG_rel_pow;    
    
    % EMG 25th Percentile - Charbonnier et al. 2012
    features_struct.EMG_Per75(i,1) = prctile(x3,75);    

    % EMG Entropy - Charbonnier et al. 2012
    features_struct.EMG_Entropy(i,1) = entropy(x3);    
    
    % EMG Spectral Edge - Charbonnier et al. 2012    
    Pdist = cumsum(pxx);
    power = 0;  
    f_idx = 1;
    while power < Pdist(end)*0.95
        power = sum(pxx(1:f_idx));
        f_idx=f_idx+1;
    end
    if f_idx > length(fxx)
       f95 = fxx(end);  
    else
        f95 = fxx(f_idx);    
    end    
    features_struct.EMG_SpectralEdgeFrequency(i,1) = f95;  
    
    
end % end of main function

%% MAI (Frandsen et al.)

AC_Act = buffer(EMG_n,51,50)';

AC_Act_Min = min(AC_Act,[],2);
AC_Act_Max = max(AC_Act,[],2);
AC_Act_Delta = AC_Act_Max - AC_Act_Min;

AC_Act_Delta_30s = buffer(AC_Act_Delta,fs_emg*epoch_time)';

AC_Act_Med = median(AC_Act_Delta_30s,2);

EMG_Baseline =  buffer(AC_Act_Med,121,120,100+zeros(120,1));
EMG_Baseline_min = min(EMG_Baseline,[],1)';
% EMG_Baseline_min = EMG_Baseline_min(61:end);

min_mae_dur = 0.3;
mae_iei = 0.5;
madt = 4;

MAE_epoch = Find_MAE(AC_Act_Delta_30s,EMG_Baseline_min,fs,min_mae_dur,mae_iei,madt);

features_struct.EMG_Motor_Activity_Amp = AC_Act_Med;
features_struct.EMG_Motor_Activity_Baseline = EMG_Baseline_min;
features_struct.EMG_Motor_Activity_Dur = MAE_epoch(:,1);
features_struct.EMG_Motor_Activity_Thresh = MAE_epoch(:,2);


%% Create 30s average for each epoch
%% Epoch length 
% epoch_time = 1;
Snames = fieldnames(features_struct);
features = [];
for x = 1:numel(Snames)    
    feature_field = features_struct.(Snames{x});
    clear temp_features;    
    num_miniepochs = epoch_time/(mini_epoch_s);    
    for y = 1:(size(feature_field,1)/num_miniepochs)              
        temp_features(y,:) = mean(feature_field((y-1)*num_miniepochs+1:y*num_miniepochs,:),1); 
    end
    features_struct_30s.(Snames{x}) = temp_features;            
    features = [features,temp_features];    
end

%% Step 3: Main part of the function - get some good features!
% Break down signal into 30s mini-epochs

mini_epoch_s =10;
K = mini_epoch_s*fs;
signal_epoched = buffer(EMG(1:30*num_epochs_30s*fs), K); % signal segments with length K


num_epochs_10s = size(signal_epoched,2);
for i = 1:num_epochs_10s  
    x = signal_epoched(:,i); % this is a part of the signal (1 sec segment)
    NFFT = 2^nextpow2(length(x));
    % Use a time-based extracting window (filtering)
    [pxx fxx] = periodogram(x,hann(length(x)),NFFT,fs);
    pow = bandpower(pxx,fxx,[10 50],'psd');    
    
    % EMG Absolute Power 
    features_struct.EMG_Abs_Power(i,1) = pow;   

     % EMG Variance 
    features_struct.EMG_Variance(i,1) = var(x); 
    
     % EMG Std Dev 
    features_struct.EMG_std(i,1) = std(x);    
    
end


%% Use selected features
Snames = fieldnames(features_struct);
num_features = size(features,2)+1;
for x = num_features:numel(Snames)    
    feature_field = features_struct.(Snames{x});
    clear temp_features;    
    num_miniepochs = epoch_time/(mini_epoch_s);    
    for y = 1:(size(feature_field,1)/num_miniepochs)              
        temp_features(y,:) = mean(feature_field((y-1)*num_miniepochs+1:y*num_miniepochs,:),1); 
        features_struct_30s.(Snames{x}) = temp_features(y,:);        
    end
    features_struct_30s.(Snames{x}) = temp_features;                
    features = [features,temp_features];
end

% features =AI';

% %% Kempfner - sEMG Activity
% 
% 
% Mb= 1280;
% Ma = 128;
% 
% wb = blackman(Mb);
% wb = wb/sum(wb);
% wa = blackman(Ma);
% wa = wa/sum(wa);
% 
% yb = filter(wb,1,abs(EMG));
% 
% ya = filter(wa,1,abs(EMG));
% 
% mini_epoch_t = 3;
% mini_epoch_pts = 3*fs;
% 
% %ensure features are derived for entirety of signal (remove excess)
% num_mini_epochs = floor(length(EMG)/mini_epoch_pts);
% 
% yb = yb(1:num_mini_epochs*mini_epoch_pts);
% ya = ya(1:num_mini_epochs*mini_epoch_pts);
% 
% Xref_data = reshape(yb,mini_epoch_pts,num_mini_epochs)';
% 
% Xref_data = padarray(Xref_data,5,'symmetric','both');
% 
% Xtest_data = reshape(ya,mini_epoch_pts,num_mini_epochs)';
% 
% 
% for i=1:size(Xtest_data,1)
%     Xref_i = i+5;
%     min_Xref = min(min(Xref_data(Xref_i-5:Xref_i+5,:)));
%     rho(i) = mean(Xtest_data(i,:))/min_Xref;   
%     
% end
% 
% features_struct.sEMG_Activity = rho';
% features_struct_30s.sEMG_Activity = rho';



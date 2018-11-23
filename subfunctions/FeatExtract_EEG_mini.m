function [features, features_struct_30s,eeg_data_signal,features_struct] = FeatExtract_EEG_mini(data_signal1, fs,epoch_time,feature_time)
% function to process an EEG signal for feature extraction
% Input:
%       data_signal1 is a 1D vector of the EEG signal with all epochs
%       fs: sampling frequency
%       epoch_time: The time length of each epoch for feature extraction (s)
%       feature_time: Calculate features within each epoch for this period of time (s) 
% Output:
%       features:   matrix with all features for recording for each
%                   epoch
%       features_struct_30s:   Structure with subject and feature extracted for each signal for every epoch_time (s)   
%       eeg_data_signal:   EEG signal   
%       features_struct:   Structure with subject and feature extracted for each signal for every feature_time (s)  
% --
% RBD Sleep Detection Toolbox, version 1.0, November 2018
% Released under the GNU General Public License
%
% Copyright (C) 2018  Navin Cooray
% Institute of Biomedical Engineering
% Department of Engineering Science
% University of Oxford
% navin.cooray@eng.ox.ac.uk
%
%
% Referencing this work
% Navin Cooray, Fernando Andreotti, Christine Lo, Mkael Symmonds, Michele T.M. Hu, & Maarten De % Vos (in review). Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis. Clinical Neurophysiology.
%
% Last updated : 15-10-2018
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Ensure EEG signal is calibrated to microvolts
Factor = 1;
if max(data_signal1) > 10   
    Factor = 1;
else
    %MilliVolts, change to micro
    data_signal1 = data_signal1*1000;
    Factor = 1000;
end

%% Step 1: Preprocess 

data_signal1f = data_signal1;



%% Step 2: Filter




%% Design Band pass filter in several frequency bands ****
% Define cut-off frequency vector, to cut the lower frequencies             -> i.e. cut-off1
Fc1 = [0.5 4 8 12 15 8 10 30];
% Define cut-off frequency vector, to cut the higher frequencies            -> i.e. cut-off2
Fc2 = [4 8 12 15 30 10 12 50];

Bandnames = {};
for bi = 1:length(Fc1)
    if Fc1(bi) > 1
    Bandnames{bi} = ['_',num2str(Fc1(bi)),'_to_',num2str(Fc2(bi)),'Hz'];
    else
    Bandnames{bi} = ['_','0_5','_to_',num2str(Fc2(bi)),'Hz'];    
    end
end

filt_order = 100;
% Design the bandpass filters with the above specifications
for j = 1:length(Fc1)
    d(j) = fdesign.bandpass('n,fc1,fc2',filt_order,Fc1(j),Fc2(j),fs);
    BPfilter(j) = design(d(j));
    BPfilter_numerator(:,j) = BPfilter(j).Numerator;
    %fvtool(BPfilter(j)); %useful for de-bugging -> check the band-pass zone
end

%% Step 3: Main part of the function - get some good features!
% Break down signal into 1s mini-epochs
mini_epoch_s = feature_time;
K = mini_epoch_s*fs;
signal_epoched = buffer(data_signal1f, K); % signal segments with length K
% signal_epoched3s = buffer(data_signal1f, 3*fs, 2*fs); % signal segments with length 3K and overlapping K length segments on each side of the centred K segment

N = size(signal_epoched,2);

%% Get a sense of awake status in terms of frequency and amplitude
%This version of the code does not use awake periods in the feature
%extraction process
max_abs_rest_amplitude = 0;
mean_abs_rest_amplitude = 0;

x = data_signal1f(3:5*fs);
% Use a time-based extracting window (filtering)
Dwindow = hann(length(x)); %Use Hanning window
%Dwindow = gausswin(length(x)); Dwindow3s = gausswin(length(x3s));%experiment with Gaussian window
xW = x.*Dwindow; %segmented signal (in time)

% Classical Fourier analysis: 1 second window analysis
NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
mag_x = fft(xW,NFFT)/length(x);
freq_x = fs/2*linspace(0,1,NFFT/2+1);
% %     Plot single-sided amplitude spectrum.
%     figure; plot(freq_x,2*abs(mag_x(1:NFFT/2+1))) 
%     title('Single-Sided Amplitude Spectrum of x(t)')
%     xlabel('Frequency (Hz)'); ylabel('|X(f)|')
Fourier_magnitude = 2*abs(mag_x(1:NFFT/2+1));
% Awake_Max_Fourier_magnitude = max(Fourier_magnitude);
Awake_Max_Fourier_magnitude=0;

for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
%     Awake_Fourier_features1sec(j) = mean(Fourier_magnitude((floor(Fc1(j))+1):floor((Fc2(j))+1)));
    Awake_Fourier_features1sec(j) = 0;
end

[pxx fxx] = periodogram(x,hann(length(x)),NFFT,fs);

[MaxPow MaxPowIdx] = max(pxx);
% Awake_MaxPowFreq = fxx(MaxPowIdx);
Awake_MaxPowFreq = 0;

% Awake_MeanFreq = sum(fxx.*pxx)/sum(pxx);
Awake_MeanFreq =0;
if isnan(Awake_MeanFreq)
    Awake_MeanFreq = 0;
end

% Awake_PSD = bandpower(x,fs,[1 45]);
Awake_PSD=0;

%% 
for i = 1:N  
    x = signal_epoched(:,i); % this is a part of the signal (1 sec segment)   
   
    % Use a time-based extracting window (filtering)
    Dwindow = hann(length(x)); %Use Hanning window
    %Dwindow = gausswin(length(x)); Dwindow3s = gausswin(length(x3s));%experiment with Gaussian window
    xW = x.*Dwindow; %segmented signal (in time)

    % zero mean the data -- BAD IDEA! We need to account for amplitude changes, e.g. to detect K-complexes
    % x = x - mean(x); x3s = x3s - mean(x3s);   
  
    % Classical Fourier analysis: 1 second window analysis
    NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
    mag_x = fft(xW,NFFT)/length(x);
    freq_x = fs/2*linspace(0,1,NFFT/2+1);
% %     Plot single-sided amplitude spectrum.
%     figure; plot(freq_x,2*abs(mag_x(1:NFFT/2+1))) 
%     title('Single-Sided Amplitude Spectrum of x(t)')
%     xlabel('Frequency (Hz)'); ylabel('|X(f)|')
    Fourier_magnitude = 2*abs(mag_x(1:NFFT/2+1));    
    
    [pxx fxx] = periodogram(x,hann(length(x)),NFFT,fs);   
    %Freqeuncy resolution = fs/NFFT
    
    %% Peak Power Freq
    [MaxPow MaxPowIdx] = max(pxx);
    MaxPowFreq = fxx(MaxPowIdx);
    features_struct.EEG_PeakPowerFreq(i,1) =  MaxPowFreq - Awake_MaxPowFreq;  

    %% Mean Frequency
    % Defined in Liang et al 2012
    meanFreq = sum(fxx.*pxx)/sum(pxx);    
    if isnan(meanFreq)
        meanFreq = 0;
    end 
    features_struct.EEG_MeanFrequency(i,1) = meanFreq - Awake_MeanFreq ;  

    %% Median Frequency
    % Defined in Kempfner 2010
    Pdist = cumsum(pxx);
    medianPow = Pdist(end)/2;     
    
    power = 0;  
    f_idx = 1;
    while power < medianPow
        power = sum(pxx(1:f_idx));
        f_idx=f_idx+1;
    end
    fc = fxx(f_idx);    
    features_struct.EEG_MedianFrequency(i,1) = fc;  

    %% Spectral Entropy
    
    NormPsd = pxx/Pdist(end);
    SpectralEntropy = -sum(NormPsd.*log(NormPsd));    
    if isnan(SpectralEntropy)
        SpectralEntropy = 0;
    end    
    features_struct.EEG_SpectralEntropy(i,1) = SpectralEntropy;  

    %% Spectral Edge Frequency
    % defined in Imtiaz et al 2014
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
    features_struct.EEG_SpectralEdgeFrequency(i,1) = f95; 

%     % Lajnef et al. Journal of Neuroscience Methods (2015) inspired features 
%%    Permuatation Entropy
    features_struct.EEG_Permutation_entropy(i,1) = petropy(x,10,1,'order');        
    
%% Kurtosis
    % Set kurtosis flag to 0 to allow for bias
    kurt_flag = 0;    
    kurt_val = kurtosis(x, kurt_flag);
    if isnan(kurt_val)
        kurt_val = 0;
    end    
    features_struct.EEG_Kurtosis(i,1) = kurt_val;  

    
%% Relative Spectral Power   
    % As defined in Khalighi et al 2013
    %RSP
    PSDdelta = bandpower(x,fs,[1 4]);
    PSDtheta = bandpower(x,fs,[4 8]);
    PSDalpha = bandpower(x,fs,[8 13]);
    PSDbeta = bandpower(x,fs,[13 30]);
    PSDgamma = bandpower(x,fs,[30 45]);
    
    PSDtotal = PSDdelta+PSDtheta+PSDalpha+PSDbeta+PSDgamma;   
    
    RSPdelta = PSDdelta/PSDtotal;
    if isnan(RSPdelta)
        RSPdelta = 0;
    end    
    features_struct.EEG_RSPdelta(i,1) = RSPdelta;    
    
    RSPtheta = PSDtheta/PSDtotal;
    if isnan(RSPtheta)
        RSPtheta = 0;
    end      
    features_struct.EEG_RSPtheta(i,1) = RSPtheta;    
 
    RSPalpha = PSDalpha/PSDtotal;
    if isnan(RSPalpha)
        RSPalpha = 0;
    end       
    features_struct.EEG_RSPalpha(i,1) = RSPalpha; 
    
    RSPbeta = PSDbeta/PSDtotal;
    if isnan(RSPbeta)
        RSPbeta = 0;
    end         
    features_struct.EEG_RSPbeta(i,1) = RSPbeta;
    
    RSPgamma =  PSDgamma/PSDtotal;
     if isnan(RSPgamma)
        RSPgamma = 0;
    end     
    features_struct.EEG_RSPgamma(i,1) = RSPgamma;

%% Percentiles          
    %Percentile 75    
    features_struct.EEG_Per75(i,1) = prctile(x,75);
    
    %Percentile 25    
    features_struct.EEG_Per25(i,1) = prctile(x,25);    
    
    %Percentile Difference    
    features_struct.EEG_PerDiff(i,1) = features_struct.EEG_Per75(i,1)-features_struct.EEG_Per25(i,1);     

%% Zero crossing rate    
    
    mean_val = mean(x);    
    features_struct.EEG_ZeroCrossingRate(i,1) = sum(abs(diff(x>mean_val)))/length(x);

%% Variance

    features_struct.EEG_x_variance(i,1) = var(x); 
    

%% Amplitude

    features_struct.EEG_Amax(i,1) = max(abs(x)) - max_abs_rest_amplitude;
    features_struct.EEG_Amean(i,1) = mean(abs(x)) - mean_abs_rest_amplitude;
    features_struct.EEG_Astd(i,1) = std(abs(x) - mean_abs_rest_amplitude);

%% Standard AR coefficients (Steve Roberts)
    AR = aryule(x, 10);
%     features_struct.EEG_AR1(i,1) = AR(1); %Always equal to 1
    features_struct.EEG_AR2(i,1) = AR(2);
    features_struct.EEG_AR3(i,1) = AR(3);
    features_struct.EEG_AR4(i,1) = AR(4);
    features_struct.EEG_AR5(i,1) = AR(5);
    features_struct.EEG_AR6(i,1) = AR(6);
    features_struct.EEG_AR7(i,1) = AR(7);
    features_struct.EEG_AR8(i,1) = AR(8);
    features_struct.EEG_AR9(i,1) = AR(9);
    features_struct.EEG_AR10(i,1) = AR(10);
    features_struct.EEG_AR11(i,1) = AR(11);

%% Max Frequency
    % Classical Fourier analysis: 1 second window analysis
    NFFT = 2^nextpow2(length(x)); % Next power of 2 from length of y
    mag_x = fft(xW,NFFT)/length(x);
    freq_x = fs/2*linspace(0,1,NFFT/2+1);
%     % Plot single-sided amplitude spectrum.
%     figure; plot(freq_x,2*abs(mag_x(1:NFFT/2+1))) 
%     title('Single-Sided Amplitude Spectrum of x(t)')
%     xlabel('Frequency (Hz)'); ylabel('|X(f)|')
    Fourier_magnitude = 2*abs(mag_x(1:NFFT/2+1));
    for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
        structname = strcat('EEG_Fourier_Magnitude',Bandnames{j});
        features_struct.(structname)(i,1) = mean(Fourier_magnitude((floor(Fc1(j))+1):floor((Fc2(j))+1)))-Awake_Fourier_features1sec(j);
    end    
    features_struct.EEG_Fourier_Magnitude_max(i,1) = max(Fourier_magnitude)-Awake_Max_Fourier_magnitude; % detect frequency with maximum spectral amplitude

%% Hjorth

% %     addpath('C:\Users\scro2778\Documents\MATLAB\SignalProcessing\Biosig2.88\NaN\inst')
%     % Mariani et al., Med Biol Computing (2012) inspired features ++EEGLab features
    [hjorth_f1, hjorth_f2, hjorth_f3] = hjorth(x, 0); % Hjorth features per 1 second, also repeat for 'smoothed' 3 sec version

    features_struct.EEG_hjorth1(i,1) = hjorth_f1;
    features_struct.EEG_hjorth2(i,1) = hjorth_f2;
    features_struct.EEG_hjorth3(i,1) = hjorth_f3;

%% Time Domain Properties

    [tdp_f1, tdp_f2] = tdp(x,10);    
    for j=1:length(tdp_f1)
        structname = strcat('EEG_tdpf1_',num2str(j));
        features_struct.(structname)(i,1) = tdp_f1(j);
        structname = strcat('EEG_tdpf2_',num2str(j));
        features_struct.(structname)(i,1) = tdp_f2(j);
    end   
% %     rmpath('C:\Users\scro2778\Documents\MATLAB\SignalProcessing\Biosig2.88\NaN\inst')

%% Square Energy Operator

    features_struct.EEG_mean_SEOx(i,1) = mean(x.^2);
    features_struct.EEG_std_SEOx(i,1) = std(x.^2);

%% Teager Kaiser Energy Operator
    
    features_struct.EEG_mean_TKEOx(i,1) = mean(TKEO(x));
    features_struct.EEG_std_TKEOx(i,1) = std(TKEO(x));

%% Variance
    features_struct.EEG_x_variance(i,1) = var(x);    
    
%% Coastline

    features_struct.EEG_Coastline(i,1) = sum(abs(diff(x)));
    features_struct.EEG_MaxCoastline(i,1) = features_struct.EEG_Coastline(i,1); %Find max/min outside loop   
    features_struct.EEG_MinCoastline(i,1) = features_struct.EEG_Coastline(i,1); 
    

    
 
end % end of main function

% Work on frequency bands: bandpass the signal 
for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
    clear dataBP
    % Compute the energies of each signal and each band
%         dataBP = filter(BPfilter(j),data_signal1);
    dataBP = filtfilt(BPfilter_numerator(:,j), 1, data_signal1f);
    xsq = dataBP.^2; xsq = xsq/max(xsq); % for each band the signal is squared and normalized to lie between 0 and 1 (according to Mariani et al., 2012)
    structname = strcat('EEG_Ratios',Bandnames{j});
    features_struct.(structname)(:,1) = (mean(buffer(xsq, 2*K, 1*K)) - mean(buffer(xsq, 64*K, 63*K)))./mean(buffer(xsq, 64*K, 63*K));
end

% Calcualte SEO Band Pass Mean for each band
for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
    clear dataBP
    % Compute the energies of each signal and each band
    dataBP = filtfilt(BPfilter_numerator(:,j), 1, data_signal1f);
    sig_segm = buffer(dataBP,K);
    for t = 1:N        
        % energy features for the BP signal
        structname = strcat('EEG_sig_SEO_BPmean',Bandnames{j});
        features_struct.(structname)(t,1) = mean(sig_segm(:,t).^2); 
    end    
end

% Calcualte SEO Band Pass StdDev for each band
for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
    clear dataBP
    % Compute the energies of each signal and each band
    dataBP = filtfilt(BPfilter_numerator(:,j), 1, data_signal1f);
    sig_segm = buffer(dataBP,K);
    for t = 1:N        
        % energy features for the BP signal
        structname = strcat('EEG_sig_SEO_BPstd',Bandnames{j});
        features_struct.(structname)(t,1) = std(sig_segm(:,t).^2); 

    end    
end

% Calcualte TKEO Band Pass Mean for each band
for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
    clear dataBP
    % Compute the energies of each signal and each band
    dataBP = filtfilt(BPfilter_numerator(:,j), 1, data_signal1f);
    sig_segm = buffer(dataBP,K);
    for t = 1:N        
        % energy features for the BP signal
        structname = strcat('EEG_sig_TKEO_BPmean',Bandnames{j});
        features_struct.(structname)(t,1) = mean(TKEO(sig_segm(:,t)));
    end    
end

% Calcualte TKEO Band Pass Std for each band
for j = 1:length(BPfilter) % work on each of the appropriate bands in the filter-bank
    clear dataBP
    % Compute the energies of each signal and each band
    dataBP = filtfilt(BPfilter_numerator(:,j), 1, data_signal1f);
    sig_segm = buffer(dataBP,K);
    for t = 1:N        
        % energy features for the BP signal
        structname = strcat('EEG_sig_TKEO_BPstd',Bandnames{j});
        features_struct.(structname)(t,1) = std(TKEO(sig_segm(:,t)));
    end    
end

%% Change in Variance

features_struct.EEG_Dx_variance = [0; diff(features_struct.EEG_x_variance)];

% putvar(features_struct);
% disp('Finished the main function');

%% 3s mini epoch feature extraction
% Future work

%% Create moving average of EEG signal 

%%Use selected features
Snames = fieldnames(features_struct);
features = [];


%% Create 30s mean value for each mini-epoch

for x = 1:numel(Snames)    
    feature_field = features_struct.(Snames{x});
    clear temp_features;
    
%     windowSize = 1*fs;
%     A = ones(1,windowSize)/windowSize;    
%     temp_features(x,:) = filtfilt(A,1,feature_field);
    
    num_miniepochs_30s = epoch_time/(K/fs);
    
    for y = 1:(size(feature_field,1)/num_miniepochs_30s)
       if  strcmp(Snames{x},'EEG_MaxCoastline') %Maximum feature within epoch
        temp_features(y,:) = max(feature_field((y-1)*num_miniepochs_30s+1:y*num_miniepochs_30s,:));
       elseif strcmp(Snames{x},'EEG_MinCoastline')  %Min feature within epoch
        temp_features(y,:) = min(feature_field((y-1)*num_miniepochs_30s+1:y*num_miniepochs_30s,:));                   
       else%Mean value of feature within epoch
        temp_features(y,:) = mean(feature_field((y-1)*num_miniepochs_30s+1:y*num_miniepochs_30s,:),1); 
       end
    end
    features_struct_30s.(Snames{x}) = temp_features;    
    features = [features,temp_features];
    
end

eeg_data_signal = data_signal1f;
% putvar(features_struct);



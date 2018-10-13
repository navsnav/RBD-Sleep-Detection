function [features, features_struct_30s,eog_data_signal,features_struct] = FeatExtract_EOG_mini(data_signal1, fs,epoch_time,feature_time)
% function to process an EOG signal for feature extraction
% Input:
%       data_signal1 is a 1D vector of the EOG signal with all epochs
%       fs: sampling frequency
%       epoch_time: The time length of each epoch for feature extraction (s)
%       feature_time: Calculate features within each epoch for this period of time (s) 
% Output:
%       features:   matrix with all features for recording for each
%                   epoch
%       features_struct_30s:   Structure with subject and feature extracted for each signal for every epoch_time (s)   
%       eog_data_signal:   EOG signal   
%       features_struct:   Structure with subject and feature extracted for each signal for every feature_time (s)  
%
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

%% Ensure EOG signal is calibrated to microvolts
Factor = 1;
if max(data_signal1) > 10   
    Factor = 1;
else
    %MilliVolts, change to micro
    data_signal1 = data_signal1*1000;
    Factor = 1000;
end


%% Step 1: Resample (downsample at 128 Hz, i.e. reduced sampling frequency)
% resampling done externally
% new_fs = 512; data_signal1 = resample(data_signal1, new_fs, fs);
% fs = new_fs;

%%        *** Band pass the signal in several frequency bands ****
% Define cut-off frequency vector, to cut the lower frequencies             -> i.e. cut-off1

%% Step 2: Low pass the data (avoid frequencies close to the mains 50 Hz)

data_signal1f = data_signal1;

%  dataBP = filter(BPfilter(j),data_signal1);
% data_signal1f = filtfilt(BPfilter_numerator(:,1), 1, data_signal1f);

%% Substract Mean
% data_signal1f = data_signal1f - mean(data_signal1f);

%% Get a sense of awake status in terms of frequency and amplitude
% max_abs_rest_amplitude = max(abs(data_signal1f(3:5*fs)));
% mean_abs_rest_amplitude = mean(abs(data_signal1f(3:5*fs)));
max_abs_rest_amplitude = 0;
mean_abs_rest_amplitude = 0;

%% Step 3: Main part of the function - get some good features!
% Break down signal into 1s mini-epochs
mini_epoch_s =feature_time;
K = mini_epoch_s*fs;
signal_epoched = buffer(data_signal1f, K); % signal segments with length K

N = size(signal_epoched,2);
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
    Fourier_magnitude = 2*abs(mag_x(1:NFFT/2+1));
  
    % Lajnef et al. Journal of Neuroscience Methods (2015) inspired features
%% Permuatation Entropy
    features_struct.EOG_Permutation_entropy(i,1) = petropy(x,10,1,'order');
   
%% Kurtosis
    % Set kurtosis flag to 0 to allow for bias
    kurt_flag = 0; 
    features_struct.EOG_Kurtosis(i,1) = kurtosis(x, kurt_flag);    
    
%% Percentile 75    
    features_struct.EOG_Per75(i,1) = prctile(x,75);
    
%% Percentile 25    
    features_struct.EOG_Per25(i,1) = prctile(x,25);    
    
%% Percentile Difference    
    features_struct.EOG_PerDiff(i,1) = features_struct.EOG_Per75(i,1)-features_struct.EOG_Per25(i,1);  
    
%% Variance    
    features_struct.EOG_Variance(i,1) = var(x);
   
%% Power Ratios (0-4Hz & 0-30Hz)    
    PR_total = 0;
    PR_4 = 0;
    %Find closest frequency bin closest to 30Hz for non-overlapping epoch
    dif = abs(freq_x-30);
    idx = find(dif == min(dif));    
    for z=1:idx        
       PR_total = PR_total + Fourier_magnitude(z);       
    end    
    dif = abs(freq_x-4 );
    idx = find(dif == min(dif));    
    %Find closest frequency bin closest to 4Hz for non-overlapping epoch
    for z=1:idx        
       PR_4 = PR_4 + Fourier_magnitude(z);       
    end    
    features_struct.EOG_Power_ratio4(i,1) = PR_4/PR_total;
    
   
%% Yetton inspired features
    plotting = 0;
%     [peakOne,peakTwo]=featureExtractTime_amplitude2peak(x,plotting); %yetton
    [peakOne,peakTwo] = feature_amplitude2peak(x); 
    
    % Max Peak
    features_struct.EOG_MaxPeak(i,1) = peakOne.peak-max_abs_rest_amplitude; %yetton
    % Peak Prominence
    features_struct.EOG_PeakProminence(i,1) = peakOne.prom; %yetton
    % Peak Width
    features_struct.EOG_PeakWidth(i,1) = peakOne.width; %yetton
    % Rise
    features_struct.EOG_Rise(i,1) = peakOne.riseSlope; %yetton
    % Fall
    features_struct.EOG_Fall(i,1) = peakOne.fallSlope; %yetton
    % Max Peak 2 
    features_struct.EOG_MaxPeak2(i,1) = peakTwo.peak-max_abs_rest_amplitude; %yetton
    
    %-2--Neg Cross-Corellation------
    % Autocorrelation 
    crossCor = xcorr(x);
    [peakVal,~] = findpeaks(crossCor);
    if isempty(peakVal)
        peakXcor = 0;
    else
        peakXcor = max(peakVal);
        
    end
    features_struct.EOG_Autocorr(i,1) = peakXcor;  
     
    %-3--Wavelet----------------
%     features_struct.EOG_Wavelet(i,1) = featureExtractNonLinear_haar(x,plotting);     %yetton
    
    [A1,D1]=dwt(x,'haar');
    [A2,D2]=dwt(A1,'haar');
    [A3,D3]=dwt(A2,'haar');
    [A4,D4]=dwt(A3,'haar');
    
    Theta=idwt([],D4,'haar');
    Theta=idwt(Theta,[],'haar');
    Theta=idwt(Theta,[],'haar');
    Theta=idwt(Theta,[],'haar');
    
    features_struct.EOG_Wavelet(i,1) = max(abs(Theta));
     
    % Non-linear energy (TKEO)  
%     features_struct.EOG_NonLinear(i,1) = featureExtractTime_nonLinearEnergy(x);     %yetton
    eog_tkeo = TKEO(x);
    features_struct.EOG_NonLinear(i,1) = mean(eog_tkeo(2:end-2));   
    
    % Coastline  
%     features_struct.EOG_Coastline(i,1) = featureExtractTime_coastline(x); %yetton
    features_struct.EOG_Coastline(i,1) = sum(abs(x(2:end) - x(1:(end-1))));
    
    
    features_struct.EOG_MaxCoastline(i,1) = features_struct.EOG_Coastline(i,1); %Find max outside of loop   
    features_struct.EOG_MinCoastline(i,1) = features_struct.EOG_Coastline(i,1); %Find min outosude of loop   

        
    % Frequency Skewness 
    features_struct.EOG_Skewness(i,1) = skewness(Fourier_magnitude);     
    
    %% Max Rate of change (dx)  
    features_struct.EOG_Dx(i,1) = max(abs(diff(x)));
    features_struct.EOG_MaxDx(i,1) = max(abs(diff(x)));      
    
end % end of main function
% putvar(features_struct);
% disp('Finished the main function');

%% Change in Variance 
features_struct.EOG_Dx_variance = [0; diff(features_struct.EOG_Variance)]; 



%%Use selected features
Snames = fieldnames(features_struct);
features = [];

%% Create moving average of EOG signal 1s
% for x = 1:numel(Snames)    
%     feature_field = features_struct.EOG_(Snames{x});
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
       if  strcmp(Snames{x},'MaxDx') || strcmp(Snames{x},'MaxCoastline') %Maximum feature within epoch
        temp_features(y,:) = max(feature_field((y-1)*num_miniepochs+1:y*num_miniepochs,:)); 
       elseif strcmp(Snames{x},'MinCoastline')  %Min feature within epoch
        temp_features(y,:) = min(feature_field((y-1)*num_miniepochs+1:y*num_miniepochs,:));                   
       else%Mean value of feature within epoch
        temp_features(y,:) = mean(feature_field((y-1)*num_miniepochs+1:y*num_miniepochs,:),1); 
       end
    end
    features_struct_30s.(Snames{x}) = temp_features;    
    features = [features,temp_features];    
end
eog_data_signal=data_signal1f;
% putvar(features_struct);



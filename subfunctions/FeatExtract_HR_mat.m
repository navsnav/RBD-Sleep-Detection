function   [feats, features_struct, hr_data] = FeatExtract_HR_mat(hr_signal, fs,epoch_time, hyp,data_collection_start) %external function

signal = reshape(hr_signal',fs*epoch_time,numel(hr_signal)/(fs*epoch_time));

NFEAT = 53; % number of features used
NFEAT_hrv = 47;
% Narrow BP
Fhigh = 5;  % highpass frequency [Hz]
Flow = 45;   % low pass frequency [Hz]
Nbut = 10;     % order of Butterworth filter
d_bp= design(fdesign.bandpass('N,F3dB1,F3dB2',Nbut,Fhigh,Flow,fs),'butter');
[b_bp,a_bp] = tf(d_bp);

if size(signal,1)<size(signal,2), signal = signal'; end % make sure it's column vector
signalraw =  signal;

%% Preprocessing
signal = filtfilt(b_bp,a_bp,signal);             % filtering narrow
signal = detrend(signal);                        % detrending (optional)
signal = signal - mean(signal(:));
signal = signal./std(signal(:));                     % standardizing

%% Get Features

fetbag = {};
feat_hrv = [];
feats = [];
%     parfor n = 1:nseg
for n=1:size(signal,2)
    % Get signal of interest
    sig_seg = signal(:,n);

    % QRS detect
    [qrsseg,featqrs] = multi_qrsdetect(sig_seg,fs,['s_' num2str(n)]);

    % HRV features
    if length(qrsseg{end})>5 % if too few detections, returns zeros
        try
            feat_basic=HRV_features(sig_seg,qrsseg{end}./fs,fs);
            feat_hrv = [feat_basic];

%                 feats_poincare = get_poincare(qrsseg{end}./fs,fs);
%                 feat_hrv = [feat_basic, feats_poincare];
            feat_hrv(~isreal(feat_hrv)|isnan(feat_hrv)|isinf(feat_hrv)) = 0; % removing not numbers
        catch
            warning('Some HRV code failed.')
            feat_hrv = zeros(1,NFEAT_hrv);
        end
    else
        disp('Skipping HRV analysis due to shortage of peaks..')
        feat_hrv = zeros(1,NFEAT_hrv);
    end

    % Heart Rate features
    HRbpm = median(60./(diff(qrsseg{end})));
    %obvious cases: tachycardia ( > 100 beats per minute (bpm) in adults)
    feat_tachy = normcdf(HRbpm,120,20); % sampling from normal CDF
    %See e.g.   x = 10:10:200; p = normcdf(x,120,20); plot(x,p)

    %obvious cases: bradycardia ( < 60 bpm in adults)
    feat_brady = 1-normcdf(HRbpm,60,20);

    % SQI metrics
%         feats_sqi = ecgsqi(sig_seg,qrsseg,fs);
    feats_sqi=[];
    % Features on residual
%         featsres = residualfeats(sig_segraw,fs,qrsseg{end});
    featsres=[];
    % Morphological features
%         feats_morph = morphofeatures(sig_segraw,fs,qrsseg,[fname '_s' num2str(n)]);
    feats_morph=[];

    feat_fer=[featqrs,feat_tachy,feat_brady,double(feats_sqi),featsres,feats_morph];
    feat_fer(~isreal(feat_fer)|isnan(feat_fer)|isinf(feat_fer)) = 0; % removing not numbers

    % Save features to table for training
    feats = [feats;feat_hrv,feat_fer];
%     fetbag{n} = [hyp(n),feats];
end

names = {'sample_AFEv' 'meanRR' 'medianRR' 'SDNN' 'RMSSD' 'SDSD' 'NN50' 'pNN50' 'LFpeak' 'HFpeak' 'totalpower' 'LFpower' ...
    'HFpower' 'nLF' 'nHF' 'LFHF' 'PoincareSD1' 'PoincareSD2' 'SampEn' 'ApEn'  ...
    'RR' 'DET' 'ENTR' 'L' 'TKEO1'  'DAFa2' 'LZ' ...
    'Clvl1' 'Clvl2' 'Clvl3' 'Clvl4' 'Clvl5' 'Clvl6' 'Clvl7' 'Clvl8' 'Clvl9' ...
    'Clvl10' 'Dlvl1' 'Dlvl2' 'Dlvl3' 'Dlvl4' ...
    'Dlvl5' 'Dlvl6' 'Dlvl7' 'Dlvl8' 'Dlvl9' 'Dlvl10'};
names = [names 'amp_varsqi' 'amp_stdsqi' 'amp_mean'];
names = [names 'tachy' 'brady'];


allfeats = array2table(feats, 'VariableNames',names);
features_struct = table2struct(allfeats);
hr_data = reshape(signal,numel(signal),1);

    
end
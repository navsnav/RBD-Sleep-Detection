function prepare_capslpdb(filename,outputfolder)
cd(filename)
fls = dir('*.edf');
fls = arrayfun(@(x) x.name,fls,'UniformOutput',false);
genderage = readtable('gender-age.csv');
CLASSES = {'W','S1','S2','S3','R'};

for f = 1:length(fls)
    disp(fls{f})
    
    % Ignoring following recordings:
    % brux1 EMG fs (100Hz) < 200Hz
    % 8: n16 has no EOG or EMG
    % 11: n4 has no EOG or EMG (EOG sin, tib sin)
    % 4: n12 EMG fs (100Hz) < 200Hz
    % 15: n8 has no EMG
    if regexp(fls{f},'(brux1|n4|n8|n12|n16)')
        sprintf('Skipping %s due to inconsistencies', fls{f})
        continue
    end
    
    % Loading data
    [hdr, record] = edfread(fls{f});
    idxrow = strcmpi(genderage.Pathology,fls{f}(1:end-4));
    patinfo.gender = genderage.Gender{idxrow};
    patinfo.age = genderage.Age(idxrow);
    patinfo.ch_orig = cell(2,3);
    patinfo.fs_orig = nan(2,3);
    patinfo.fs = 200;
    patinfo.classes = CLASSES;
    patinfo.chlabels = {'EEG','EOG','EMG'};
    %% Getting EEG
    idxeeg = find(~cellfun(@isempty, regexp(hdr.label,'C4-A1|C4A1')));
    if isempty(idxeeg)
        idxeeg = find(~cellfun(@isempty, regexp(hdr.label,'C3-A2|C3A2')));
    end
    if isempty(idxeeg)
        idxeeg = find(~cellfun(@isempty, regexp(hdr.label,'(C4)')));
        idxeeg = [idxeeg,find(~cellfun(@isempty, regexp(hdr.label,'(A1)')))];
    end
    
    % sanity check for multiple channels
    if length(idxeeg)>1
        eeg = diff(record(idxeeg,:))';
    elseif length(idxeeg)== 1
        eeg = record(idxeeg,:)';
    else
        warning('Skipping record, no EEG')
        continue
    end
    % Getting fs
    fseeg = hdr.frequency(idxeeg);
    if length(fseeg)>1
        if fseeg(1) ~= fseeg(2)
            error('Different fs for EEG!?')
        end
    end
    if any(fseeg < 100), error('Low sampling frequency?'), end
    for l = 1:length(idxeeg)
        patinfo.ch_orig(l,1) = cellstr(hdr.label(idxeeg(l)));
        patinfo.fs_orig(l,1) = fseeg(l);
    end
    clear fseeg idxeeg l
    %% Getting EOG
    idxeog = find(~cellfun(@isempty, regexp(hdr.label,'(ROC-LOC|EOG dx|ROCLOC)')));
    if isempty(idxeog)
        idxeog = find(~cellfun(@isempty, regexp(hdr.label,'(ROC|EOG-R|ROC-A2)')));
        idxeog = [idxeog,find(~cellfun(@isempty, regexp(hdr.label,'(LOC|EOG-L|LOC-A1)')))];
    end
    
    % sanity check for multiple channels
    if length(idxeog)>1
        eog = diff(record(idxeog,:))';
    elseif length(idxeog)== 1
        eog = record(idxeog,:)';
    else
        warning('Skipping record, no EOG')
        continue
    end
    
    % Getting fs
    fseog = hdr.frequency(idxeog);
    if length(fseog)>1
        if fseog(1) ~= fseog(2)
            error('Different fs for EOG!?')
        end
    end
    if any(fseog < 100), error('Low sampling frequency?'), end
    for l = 1:length(idxeog)
        patinfo.ch_orig(l,2) = cellstr(hdr.label(idxeog(l)));
        patinfo.fs_orig(l,2) = fseog(l);
    end
    clear fseog idxeog l
    %% Getting EMG
    idxemg = find(~cellfun(@isempty, regexp(hdr.label,'(EMG1-EMG2|EMG-EMG|CHIN-CHIN)')));
    if isempty(idxemg)
        idxemg = find(~cellfun(@isempty, regexp(hdr.label,'CHIN|EMG','match')));
    end
    
    % sanity check for multiple channels
    if length(idxemg)>1
        emg = diff(record(idxemg,:))';
    elseif length(idxemg)== 1
        emg = record(idxemg,:)';
    else
        warning('Skipping record, no EOG')
        continue
    end
    
    % Getting fs
    fsemg = hdr.frequency(idxemg);
    if length(fsemg)>1
        if fsemg(1) ~= fsemg(2)
            error('Different fs for EOG!?')
        end
    end
    if any(fsemg < 100), error('Low sampling frequency?'), end
    for l = 1:length(idxemg)
        patinfo.ch_orig(l,3) = cellstr(hdr.label(idxemg(l)));
        patinfo.fs_orig(l,3) = fsemg(l);
    end
    clear fsemg idxemg l
    clear record info idxrow
    
    %% Resampling signals
    fss = patinfo.fs_orig(1,:);
    
    
    %% Preprocessing Filter coefficiens
    % Resampling to 100 Hz
    eeg = resample(eeg,patinfo.fs,fss(1));
    eog = resample(eog,patinfo.fs,fss(2));
    emg = resample(emg,patinfo.fs,fss(3));
    clear fss
    
    Nfir = 500;
    % Preprocessing filters
    b_band = fir1(Nfir,[0.3 40].*2/patinfo.fs,'bandpass'); % bandpass
    eeg = filtfilt(b_band,1,eeg);
    b_band = fir1(Nfir,[0.3 40].*2/patinfo.fs,'bandpass'); % bandpass
    eog = filtfilt(b_band,1,eog);
    clear b_band
    
    % Preprocessing filters
    pwrline1 = 50; %Hz
    b_notch1 = fir1(Nfir,[(pwrline1-1) (pwrline1+1)].*2/patinfo.fs,'stop');
    pwrline2 = 60; %Hz
    b_notch2 = fir1(Nfir,[(pwrline2-1) (pwrline2+1)].*2/patinfo.fs,'stop');
    b_band = fir1(Nfir,10.*2/patinfo.fs,'high'); % bandpass
    emg = filtfilt(b_notch1,1,emg);
    emg = filtfilt(b_notch2,1,emg);
    emg = filtfilt(b_band,1,emg);
    

    
    % cut to shortest signal
    rem = find(eeg(end:-1:1) ~= 0,1,'first');
    if (length(eeg) - rem)/patinfo.fs/60/60 < 5 % less than five hours available
        warning('This looks fishy, wrong fs? Skipping..')
        continue
    end
    eeg(end-rem:end) = [];
    rem = find(eog(end:-1:1) ~= 0,1,'first');
    if (length(eog) - rem)/patinfo.fs/60/60 < 5 % less than five hours available
        warning('This looks fishy, wrong fs? Skipping..')
        continue
    end
    eog(end-rem:end) = [];
    rem = find(emg(end:-1:1) ~= 0,1,'first');
    if (length(emg) - rem)/patinfo.fs/60/60 < 5 % less than five hours available
        warning('This looks fishy, wrong fs? Skipping..')
        continue
    end
    emg(end-rem:end) = [];
    % merging elements into matrix
    len = min([length(eeg),length(eog),length(emg)]);
    signals = [eeg(1:len),eog(1:len),emg(1:len)]';
    % Standardizing signals
    for s=1:3
        signals(:,s) = signals(:,s) - nanmean(signals(:,s));
        signals(:,s) = signals(:,s)./nanstd(signals(:,s));
    end
    
    
    
    clear eeg eog emg len rem
    %% Figuring out annotations
    infotxt = loadtxt([fls{f}(1:end-4) '.txt']);
    try
        anntm = datetime(infotxt.Timehhmmss,'InputFormat','HH:mm:ss');
    catch
        try
            anntm = datetime(cellstr(infotxt.Timehhmmss),'InputFormat','HH.mm.ss');
        catch
            try   % imnsonia ones dont have second column
                anntm = datetime(cellstr(infotxt.Position),'InputFormat','HH:mm:ss');
            catch
                anntm = datetime(cellstr(infotxt.Position),'InputFormat','HH.mm.ss');
            end
            
        end
    end
    
    recstart = datetime(hdr.starttime,'InputFormat','HH.mm.ss');
    
    % convert labels for neural networks
    stage = infotxt.SleepStage;
    stage = cellstr(stage);
    stage(cellfun(@(x) strcmp(x,'S4'), stage)) = {'S3'}; % converting to AASM annotation
    stage(cellfun(@(x) strcmp(x,'REM'), stage)) = {'R'}; % converting to AASM annotation
    rem = ~cellfun(@(x) ismember(x,CLASSES),stage); % remove S4 and MT
    stage(rem) = [];
    anntm(rem) = [];
    
    % in case annotation started after midnight
    for s = 1:length(stage)
        if seconds(anntm(s)-recstart) < 0
            anntm(s) = anntm(s)+1;
        end
    end
    
    lastsamp = (seconds(anntm(end)-recstart)+30)*patinfo.fs+1;
    signals(:,lastsamp:end) = [];
    data = zeros(length(stage)-1,30*patinfo.fs,3);
    labels = zeros(length(stage)-1,5);
    epoch = zeros(length(labels),1);
    for s = 1:(length(labels)-1)
        try
            startsamp = seconds(anntm(s)-recstart)*patinfo.fs;
            if startsamp == 0
                startsamp = 1;
            end
            epoch(s) = round(startsamp/patinfo.fs);
            data(s,:,:) = signals(:,startsamp:startsamp+30*patinfo.fs-1)';
            labels(s,:) = ismember(CLASSES,stage(s));
        catch
            if (startsamp+30*patinfo.fs-1) > size(signals,2)
                continue
            end
        end
    end
    
    if any(isnan(data))
        error('NaNs')
    end
    idx = ~any(labels,2);  %rows
    labels(idx,:) = [];
    data(idx,:,:) = [];
    epoch(idx,:) = [];
    if size(data,1) ~= size(labels,1)
        error('Different length for recording..')
    end
    
    if ~exist(outputfolder, 'dir')
       mkdir(outputfolder);
    end     
    %Saving results
    save([outputfolder,'\',fls{f}(1:end-3),'mat'],'data','labels','patinfo','epoch')
    clear infotxt startsamp lastsamp recstart stage anntm rem data labels patinfo signals r
end
end
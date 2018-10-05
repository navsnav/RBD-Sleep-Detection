function [All_Sleep, Sleep_Struct, All_Sleep_T] = ExtractFeatures_mat(dbpath,signals_for_processing)
  % Copyright (c) 2018, Navin Cooray (University of Oxford)
  % All rights reserved.
  %
  % Redistribution and use in source and binary forms, with or without
  % modification, are permitted provided that the following conditions are
  % met:
  %
  % 1. Redistributions of source code must retain the above copyright
  %    notice, this list of conditions and the following disclaimer.
  %
  % 2. Redistributions in binary form must reproduce the above copyright
  %    notice, this list of conditions and the following disclaimer in the
  %    documentation and/or other materials provided with the distribution.
  %
  % 3. Neither the name of the University of Oxford nor the names of its
  %    contributors may be used to endorse or promote products derived
  %    from this software without specific prior written permission.
  %
  % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  % "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  % LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  % A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  % HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  % SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  % LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  % DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  % THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  % (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  % OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  %	Contact: navsnav@gmail.com
  %	Originally written by Navin Cooray 19-Sept-2018
  
% Main function to extract features from multichannel PSG recordings
% 
% Input:
%       dbpath:     Path to directory containing recordings. Recordings are
%       individual .mat files for each subject containing the following variables:
%       - data:     matrix of epoched signals with dimensions (#EPOCH, EPOCH_LENGTH, CHANNELS)
%       - labels:  annotation for each epoch containing sleep stages in format (#EPOCH, 5) with 
%       sleep stages coded as [W,R,N1,N2,N3]
%       - patinfo: information on patient data such as sampling frequency, age and gender.
%       signals_for_processing: Cell string array, with signal names for
%                               feature extraction eg {'EEG','EOG',EMG'}
% Output:
%       All_Sleep:      matrix with all features for all recordings for each
%                       specified epoch
%       Sleep_Struct:   Structure for each subject and feature extracted for each signal and epoch   
%       All_Sleep_T:    Table with all features for all recordings for each specified epoch     
%



%% Input check
% Dealing with different OS
slashchar = char('/'*isunix + '\'*(~isunix));
if ~strcmp(dbpath(end),slashchar)
    dbpath = [dbpath slashchar];
end
mainpath = (strrep(which(mfilename),['preparation' slashchar mfilename '.m'],''));
addpath(genpath([mainpath(1:end-length(mfilename)-2) 'subfunctions' slashchar])) % add subfunctions folder to path

% default values for input arguments

fs=200;
EEG_CHAN = 1;
EOG_CHAN = 2;
EMG_CHAN = 3;
epoch_time = 30;
All_Sleep = [];
All_Sleep_T = table;

%% Main loop
fls = dir([dbpath '*.mat']);
fls = arrayfun(@(x) x.name,fls,'UniformOutput',false);

for f=1:length(fls)
    % Loading recording
    load([dbpath fls{f}]);
%%

    hyp_cap = labels;
    hyp = zeros(size(hyp_cap,1),1);
    
    W_col = find(ismember(patinfo.classes,'W'));
    N1_col = find(ismember(patinfo.classes,'S1'));
    N2_col = find(ismember(patinfo.classes,'S2'));
    N3_col = find(ismember(patinfo.classes,'S3'));
    R_col = find(ismember(patinfo.classes,'R'));
    
    W_idx = find(labels(:,W_col));
    N1_idx =  find(labels(:,N1_col));
    N2_idx =  find(labels(:,N2_col));
    N3_idx =  find(labels(:,N3_col));
    R_idx = find(labels(:,R_col));
    
    hyp(W_idx) = 0;
    hyp(N1_idx) = 1;
    hyp(N2_idx) = 2;
    hyp(N3_idx) = 3;
    hyp(R_idx) = 5;    
    
    hyp(:,2) = linspace(0,(size(hyp,1)-1)*30,size(hyp,1));
%%    
    K = length(hyp);
    
    Sleep = ones(K,1)*f; % subject_index
    Sleep(:,2) = patinfo.age; % age
    Sleep(:,3) = strcmpi('M',patinfo.gender); % gender
    Sleep(:,7) = hyp(:,1); % main response variable
    Sleep(:,8) = ones(K,1)*(hyp(end,2) - hyp(1,2))/3600; % sleep duration
    Sleep(:,9) = hyp(:,2); % sleep duration
    Sleep(:,10) = 0; % time hypnogram starts
   
    % ==============
    aaa = char(fls{f});
    s1 = regexp(aaa, '[1-9]'); 
    name_category{f} = aaa(1:s1(1)-1);
    subject = aaa(1:end-4);   
    subject = strrep(subject,'-','_');
    % depending on the subject category, populate the 6th column
    switch (name_category{f})
        case 'n' % normal
            Sleep(:,6) = 0; % normal
            
        case 'nfle' % nocturnal frontal lobe epilepsy
            Sleep(:,6) = 1;            
            
        case 'brux' % Bruxism
            Sleep(:,6) = 2; % normal

        case 'ins' % insomnia
            Sleep(:,6) = 3; % normal
            
        case 'narco' % narcolepsy
            Sleep(:,6) = 4; % normal
            
        case 'rbd' % RBD
            Sleep(:,6) = 5; % normal  
            
        case 'SS' % HC
            Sleep(:,6) = 0; % normal 
            
        case 'Patient_N' % RBD
            Sleep(:,6) = 5; % normal             
            
        otherwise % problem!
            Sleep(:,6) = -1; % check out if we get that
    end
 %%
     Sleep_names = {};
     Sleep_names = { ...
        'SubjectIndex',...
        'Age',...
        'Sex',...
        'Spare',...
        'filenname',...
        'SubjectCondition',...
        'AnnotatedSleepStage',...
        'SleepDuration',...
        'AbsoluteTiming_s',...
        'TimePersonWentToBed'}; 
    
    for j = 1:length(signals_for_processing)
    
    % Remove NaNs
    data(any(any(isnan(data),3),2),:,:) = [];

    switch char(signals_for_processing(j))
        case {'EEG'}    
        feature_time = 10;            
        EEG_CHAN = find(strcmp(cellstr(patinfo.chlabels), char(signals_for_processing(j))));   
        data_signal = squeeze(data(:,:,EEG_CHAN))';
        data_signal = reshape(data_signal,numel(data_signal),1);
        % Extracting EEG features
        [eeg_feats, features_struct_30s,eeg_data_signal,features_struct] = FeatExtract_EEG_mini(data_signal, fs,epoch_time,feature_time); 
        Sleep_Struct.(subject).EEG = features_struct_30s;
        EEGSnamesSubjects = fieldnames(features_struct_30s)';    
        Sleep_names(length(Sleep_names)+1:length(Sleep_names)+length(EEGSnamesSubjects)) = EEGSnamesSubjects;    

        case {'EOG'}    
        EOG_CHAN = find(strcmp(cellstr(patinfo.chlabels), char(signals_for_processing(j))));            
        % Extracting EOG features
        feature_time = 10;         
        data_signal = squeeze(data(:,:,EOG_CHAN))';
        data_signal = reshape(data_signal,numel(data_signal),1);        
        [eog_feats, features_struct_30s,eog_data_signal,features_struct] = FeatExtract_EOG_mini(data_signal, fs,epoch_time,feature_time); 
        Sleep_Struct.(subject).EOG = features_struct_30s;
        EOGSnamesSubjects = fieldnames(features_struct_30s)';    
        Sleep_names(length(Sleep_names)+1:length(Sleep_names)+length(EOGSnamesSubjects)) = EOGSnamesSubjects;    
        
        case {'EMG'}    
        EMG_CHAN = find(strcmp(cellstr(patinfo.chlabels), char(signals_for_processing(j))));            
            % Extracting EMG features
        data_signal = squeeze(data(:,:,EMG_CHAN))';
        data_signal = reshape(data_signal,numel(data_signal),1);             
        [emg_feats, features_struct_30s, emg_data_signal,features_struct] = FeatExtract_EMG_mini(data_signal, fs,epoch_time, hyp);
        Sleep_Struct.(subject).EMG = features_struct_30s;
        EMGSnamesSubjects = fieldnames(features_struct_30s)';    
        Sleep_names(length(Sleep_names)+1:length(Sleep_names)+length(EMGSnamesSubjects)) = EMGSnamesSubjects;    

        case {'EEG-EOG'}    
    %     Extracting EEG/EOG features
        feature_time = 10;            
        [eeg_eog_feats, features_struct_30s,features_struct] = FeatExtract_EEGEOG_mini(eeg_data_signal,eog_data_signal,fs,epoch_time,feature_time);        
        Sleep_Struct.(subject).EEGEOG = features_struct_30s;
        EEGEOGSnamesSubjects = fieldnames(features_struct_30s)';    
        Sleep_names(length(Sleep_names)+1:length(Sleep_names)+length(EEGEOGSnamesSubjects)) = EEGEOGSnamesSubjects;    

        otherwise
        warning(['Signal ' char(signals_for_processing(j)) ' not found!']);    
    end

    %% labels
    
%     save(['features_' fls{f}],'Sleep')
    end
    % Add hours from start [c = hyp(:,2) c(1) = hyp(1,2)]
    time_from_start = (hyp(:,2)-hyp(1,2))./3600;
    time_from_end = flipud((hyp(:,2)-hyp(1,2))./3600);
    Sleep_Struct.(subject).HoursRec = time_from_start;    
    Sleep_Struct.(subject).HoursFromEnd = time_from_end;    

    
    Sleep_Struct.(subject).Hypnogram = hyp;    

    Sleep_names(length(Sleep_names)+1) = {'HoursRec'};
    Sleep_names(length(Sleep_names)+1) = {'HoursFromEnd'};    
    
    % Combining features into one patient table
    Ttmp = [eeg_feats,eog_feats];
    Ttmp2 = [emg_feats,eeg_eog_feats];
    Sleep = [Sleep,Ttmp,Ttmp2,time_from_start,time_from_end];
    
    Sleep_T = array2table(Sleep, 'VariableNames',Sleep_names);
    
    All_Sleep_T = [All_Sleep_T;Sleep_T];
    All_Sleep = [All_Sleep;Sleep];
    
    clear data epoch labels patinfo Ttmp Ttmp2 emg_feats eeg_feats eog_feats eeg_eog_feats feattab
    
    

end

end

%% Add paths
addpath(strcat(pwd,'\libs\'));
addpath(strcat(pwd,'\subfunctions\'));
addpath(strcat(pwd,'\dataprep\'));

%% Attain PSG Signals
% There are several options to get PSG signals
% (A) A folder containing all mat files of all PSG signals
% (B) A folder containing all edf files and annotations
% (C) Download files eg using CAP sleep database
% (D) Load Feature.mat file

%% (A) Extract PSG Signals - Use this section if you have a dataset of mat files with hypnogram datasets
% current_dir = pwd;
% data_folder = 'I:\Data\Combined_MASS_JR_CAP_HR';
% signals_for_processing = {'EEG','EOG','EMG','EEG-EOG'};
% [Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing)
% cd(current_dir);
% save('Features.mat','Sleep','Sleep_Struct','Sleep_table');

%% (B) Extract PSG Signals  - Use this section if you have a folder of edf files with annotations
% current_dir = pwd;
% data_folder = 'I:\Data\CAP Sleep Database';
% outputfolder = [current_dir,'\data'];
% prepare_capslpdb(data_folder,outputfolder);

%% (C) Download PSG Signals  - Use this section to download example edf files and annotations as a test
% current_dir = pwd;
% outputfolder = [current_dir,'\data'];
% % The following data will be downloaded from the CAPS database from
% % physionet
% list_of_files = {
%     'n1';
%     'n2';
%     'n3';
%     'n10';
%     'n5'
%     'rbd1';
%     'rbd2';
%     'rbd3';
%     'rbd4';
%     'rbd5'};
% 
% download_CAP_EDF_Annotations(outputfolder,list_of_files);
% data_folder = outputfolder;
% 
% prepare_capslpdb(data_folder,outputfolder);
%% (D) Load Data
filename = 'Features.mat';
load ([pwd,'\data\',filename]);

%% Preprocess

%% Preprocess Data 
SS_Features =[11:144]; % Features used for sleep staging
EMG_feats = [3,7,8,9,10,11,15,17,32,33]; %AI ratios + N3% + SleepEff + Fractal Exponenet Ratios (REM:N2/N3)
EMG_est_feats = [3,7,8,9]; %AI, MAD_Dur, MAD_Per, Stream

% Preprocess Sleep Staging Features
[Sleep_table_Pre] = RBD_RF_Preprocess(Sleep_table,[0,5],SS_Features);

%% Load Trained Sleep Classifier & RBD Detection

load Sleep_Staging_RF.mat
load RBD_Detection_RF.mat

%% Predict Sleep Staging

[a,b] = Predict_SleepStaging(ss_rf,Sleep_table_Pre(:,11:end));

Sleep_table_automatic = Sleep_table_Pre;
Sleep_table_automatic.AnnotatedSleepStage = a; %Automatic sleep staging


%% Show Results - Sleep Staging

print_results(Sleep,a,[0,1,2,3,5],0,pwd,1);

%% RBD Detection Preprocess - Manual Annotation

EMG_Table = Calculate_EMG_Values_table(Sleep_table_Pre);
% Preprocess Data
[EMG_Table_Pre] = RBD_RF_Preprocess(EMG_Table,[],EMG_feats);

%% Predict RBD Detection - Manual & Established Metrics

[a,b] = Predict_RBD_Detection(rbd_est_rf_manual_ss,EMG_Table_Pre(:,EMG_est_feats));


%% Predict RBD Detection - Manual & New Metrics

[c,d] = Predict_RBD_Detection(rbd_new_rf_manual_ss,EMG_Table_Pre(:,EMG_feats));


%% Show Results - RBD Detection (Annotated)
label_name = 'Annotated';
compare_rbd_detection_results(table2array(EMG_Table),a,c,EMG_Table.Properties.VariableNames,EMG_feats,EMG_Table.RBD,label_name,0,pwd,1);

%% RBD Detection Preprocess - Automatic Annotation

EMG_Table = Calculate_EMG_Values_table(Sleep_table_automatic);
% Preprocess Data
[EMG_Table_Pre] = RBD_RF_Preprocess(EMG_Table,[],EMG_feats);

%% Predict RBD Detection - Automatic & Established Metrics

[a,b] = Predict_RBD_Detection(rbd_est_rf_manual_ss,EMG_Table_Pre(:,EMG_est_feats));


%% Predict RBD Detection - Automatic & New Metrics

[c,d] = Predict_RBD_Detection(rbd_new_rf_manual_ss,EMG_Table_Pre(:,EMG_feats));


%% Show Results - RBD Detection (Automatic)
label_name = 'Automatic';
compare_rbd_detection_results(table2array(EMG_Table),a,c,EMG_Table.Properties.VariableNames,EMG_feats,EMG_Table.RBD,label_name,0,pwd,1);



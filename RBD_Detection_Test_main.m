% Code to test new data on previously trained models for sleep staging and RBD detection 

%% Add paths
addpath(strcat(pwd,'\libs\'));
addpath(strcat(pwd,'\subfunctions\'));
addpath(strcat(pwd,'\dataprep\'));

%% Attain PSG Signals
% There are several options to get PSG signals
% (A) A folder containing all edf files and annotations
% (B) Download files eg using CAP sleep database
% (C) A folder containing all mat files of all PSG signals
% (D) Load Features matrix

%% (A) Extract PSG Signals  - Use this section if you have a folder of edf files with annotations
% current_dir = pwd;
% data_folder = 'I:\Data\CAP Sleep Database';
% outputfolder = [current_dir,'\data'];
% prepare_capslpdb(data_folder,outputfolder);

%% (B) Download PSG Signals  - Use this section to download example edf files and annotations as a test
% current_dir = pwd;
% cd('../');
% outputfolder = [pwd,'\data'];
% cd(current_dir);
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

%% (C) Extract PSG Signals - Use this section if you have a dataset of mat files with hypnogram datasets
% signals_for_processing = {'EEG','EOG','EMG','EEG-EOG'};
% disp(['Extracting Features:',signals_for_processing]);
% % Generate Features
% [Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing);
% cd(data_folder);
% save('Features.mat','Sleep','Sleep_Struct','Sleep_table');
% cd(current_dir);
% disp('Feature Extraction Complete and Saved');

%% (D) 
current_dir = pwd;
data_folder = 'C:\Users\scro2778\Documents\GitHub\data';
cd(data_folder);
filename = 'Features.mat';
load(filename);
cd(current_dir);

%% Load Trained Sleep Staging
% File location of trained RF
ss_rf_filename = 'Sleep_Staging_RF.mat';
load(ss_rf_filename);

%% Load Trained RBD Detection
% File location of trained RF
rbd_rf_filename = 'RBD_Detection_RF.mat';
load(rbd_rf_filename);

%% Parameters for generating results
view_results = 1; %Produce Graphs/figures
print_figures= 1; %Save Graphs/figures
display_flag = 1; %Display results in command window
save_data = 1; %Save Data
outfilename = 'RBD_Detection_Results'; %Filename/Folder to be created

%% Preprocess Data 
SS_Features = find(ismember(Sleep_table.Properties.VariableNames,ss_rf.PredictorNames));
EMG_est_feats = find(ismember(EMG_Table.Properties.VariableNames,rbd_est_rf.PredictorNames));
EMG_feats = find(ismember(EMG_Table.Properties.VariableNames,rbd_new_rf.PredictorNames));


% Preprocess Sleep Staging Features
disp('Precprocessing Features...');
[Sleep_table_Pre] = RBD_RF_Preprocess(Sleep_table,[0,5],SS_Features);
disp('Precprocessing Complete.');

%% Cross Fold Indexing
Sleep = table2array(Sleep_table_Pre);
Sleep_tst = Sleep_table_Pre(:,SS_Features);
[patients,ia,ic] = unique(Sleep_table_Pre.SubjectIndex);
rbd_group = Sleep(ia,6)==5;


%% Test Trained Sleep Staging

[Yhat,votes] = Predict_SleepStaging_RF(ss_rf,Sleep_tst);

%% Test Trained RBD Detection

EMG_Table = Calculate_EMG_Values_table(Sleep_table_Pre);

% Preprocess Data
[EMG_Table_Est] = RBD_RF_Preprocess(EMG_Table,[],EMG_est_feats);
EMG_Table_Est_Tst = EMG_Table_Est(:,2:end);
[EMG_Table_New] = RBD_RF_Preprocess(EMG_Table,[],EMG_feats);
EMG_Table_New_Tst = EMG_Table_New(:,2:end);

%Matlab Trees

[EMG_est_Yhat,EMG_est_votes] = Predict_RBDDetection_RF(rbd_est_rf,EMG_Table_Est_Tst);
[EMG_new_Yhat,EMG_new_votes] = Predict_RBDDetection_RF(rbd_new_rf,EMG_Table_New_Tst);


%% Display Results

%% Print Annotated Vs Automatic RBD Metrics
%% Print RBD Detection Results
print_folder = '';
if (view_results)
   %Compare RBD Detection (annotated)
   label_name = 'Annotated';
   compare_rbd_detection_results(table2array(EMG_Table),EMG_est_Yhat,EMG_new_Yhat,EMG_Table.Properties.VariableNames,EMG_feats,rbd_group,label_name,0,print_folder,display_flag);
   label_name = 'Automated';
   compare_rbd_detection_results(EMG_Auto_Metric,EMG_Auto_est_Yhat_Results,EMG_Auto_Yhat_Results,EMG_Table_Names,EMG_feats,rbd_group,label_name,print_figures,print_folder,display_flag);
end



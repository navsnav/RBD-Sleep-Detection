% Code to test new data on previously trained models for sleep staging and RBD detection 

%% Add paths
slashchar = char('/'*isunix + '\'*(~isunix));
main_dir = (strrep(which(mfilename),['preparation' slashchar mfilename '.m'],''));
main_dir = main_dir(1:end-length(mfilename)-2);

addpath(genpath([main_dir, 'libs', slashchar])) % add external libraries folder to path
addpath(genpath([main_dir, 'subfunctions', slashchar])) % add subfunctions folder to path
addpath(genpath([main_dir, 'dataprep', slashchar])) % add data preparation folder to path
addpath(genpath([main_dir, 'classifiers', slashchar])) % add classifiers folder to path

%% Attain PSG Signals
% There are several options to get PSG signals
% (A) A folder containing all edf files and annotations
% (B) Download files eg using CAP sleep database
% (C) A folder containing all 'prepared' mat files of all PSG signals 
% (D) Load Features matrix saved from ExtractFeatures

%% (A) Extract PSG Signals  - Use this section if you have a folder of edf files with annotations
% data_folder = 'I:\Data\CAP Sleep Database'; %Choose file location
% outputfolder = [current_dir,'\data'];
% prepare_capslpdb(data_folder,outputfolder);

%% (B) Download PSG Signals  - Use this section to download example edf files and annotations as a test
cd(main_dir);
data_folder = [main_dir, 'data', slashchar];

% The following data will be downloaded from the CAPS database from
% physionet
list_of_files = {
    'n1';
    'n2';
    'n3';
    'n10';
    'n5'
    'rbd1';
    'rbd2';
    'rbd3';
    'rbd4';
    'rbd5'};

download_CAP_EDF_Annotations(data_folder,list_of_files);
%Prepare mat files with PSG signals and annotations
prepare_capslpdb(data_folder,data_folder);

%% (C) Extract PSG Signals - Use this section if you have a dataset of mat files with hypnogram datasets
cd(main_dir);
signals_for_processing = {'EEG','EOG','EMG','EEG-EOG'};
disp(['Extracting Features:',signals_for_processing]);
% Generate Features
[Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing);

feature_folder = [data_folder, 'features', slashchar];
% Create a destination directory if it doesn't exist
if exist(output_folder, 'dir') ~= 7
    fprintf('WARNING: Features directory does not exist. Creating new directory ...\n\n');
    mkdir(output_folder);
end
cd(feature_folder);
save('Features.mat','Sleep','Sleep_Struct','Sleep_table');
disp('Feature Extraction Complete and Saved');
cd(current_dir);

%% (D) Load Features matrix saved from ExtractFeatures
% current_dir = pwd;
% data_folder = 'C:\Users\scro2778\Documents\GitHub\data\features';
% cd(data_folder);
% filename = 'Features.mat';
% load(filename);
% cd(current_dir);

%% Load Trained Sleep Staging
% File location of trained RF
ss_rf_filename = [pwd,'\data\','Sleep_Staging_RF.mat'];
load(ss_rf_filename);

%% Load Trained RBD Detection
% File location of trained RF
rbd_rf_filename = [pwd,'\data\','RBD_Detection_RF.mat'];
load(rbd_rf_filename);

%% Parameters for generating results
view_results = 1; %Produce Graphs/figures
print_figures= 0; %Save Graphs/figures
print_folder = '';
display_flag = 1; %Display results in command window
save_data = 1; %Save Data

%% Preprocess Data 
%Ensure features in trained RF model match features from Data
SS_Features = find(ismember(Sleep_table.Properties.VariableNames,ss_rf.PredictorNames));

% Preprocess Sleep Staging Features
disp('Precprocessing Features...');
[Sleep_table_Pre] = RBD_RF_Preprocess(Sleep_table,[0,5],SS_Features);
disp('Precprocessing Complete.');
Sleep = table2array(Sleep_table_Pre);
Sleep_tst = Sleep_table_Pre(:,SS_Features);
[patients,ia,ic] = unique(Sleep_table_Pre.SubjectIndex);
rbd_group = Sleep(ia,6)==5;

%% Test Automated Sleep Staging
disp('Testing Autoamted Sleep Staging...');
[Yhat,votes] = Predict_SleepStaging_RF(ss_rf,Sleep_tst);
disp('Sleep Staging Complete.');

%% Show Results - Sleep Staging - working
states = [0,1,2,3,5];
print_results(Sleep,Yhat,states,print_figures,print_folder,display_flag);

%% Test RBD Detection - Using Manually Annotated Sleep Staging

EMG_Table = Calculate_EMG_Values_table(Sleep_table_Pre); %Calculate Features
%Ensure features in trained RF model match features from Data
EMG_est_feats = find(ismember(EMG_Table.Properties.VariableNames,rbd_est_rf.PredictorNames));
EMG_feats = find(ismember(EMG_Table.Properties.VariableNames,rbd_new_rf.PredictorNames));

% Preprocess Data
[EMG_Table_Est] = RBD_RF_Preprocess(EMG_Table,[],EMG_est_feats);
EMG_Table_Est_Tst = EMG_Table_Est(:,3:end); %Remove Subject Index and Diagnosis 
[EMG_Table_New] = RBD_RF_Preprocess(EMG_Table,[],EMG_feats);
EMG_Table_New_Tst = EMG_Table_New(:,3:end);%Remove Subject Index and Diagnosis 

%Matlab Trees

[EMG_est_Yhat,EMG_est_votes] = Predict_RBDDetection_RF(rbd_est_rf,EMG_Table_Est_Tst);
[EMG_new_Yhat,EMG_new_votes] = Predict_RBDDetection_RF(rbd_new_rf,EMG_Table_New_Tst);

%% Test RBD Detection - Using Automatic Sleep Staging
Auto_Sleep_table_Pre = Sleep_table_Pre;
% Replace annotated sleep staging with automated sleep staging.
Auto_Sleep_table_Pre.AnnotatedSleepStage = Yhat;
Auto_EMG_Table = Calculate_EMG_Values_table(Auto_Sleep_table_Pre); %Calculate Features

%Ensure features in trained RF model match features from Data
Auto_EMG_est_feats = find(ismember(Auto_EMG_Table.Properties.VariableNames,rbd_est_rf.PredictorNames));
Auto_EMG_feats = find(ismember(Auto_EMG_Table.Properties.VariableNames,rbd_new_rf.PredictorNames));

% Preprocess Data
[Auto_EMG_Table_Est] = RBD_RF_Preprocess(Auto_EMG_Table,[],EMG_est_feats);
Auto_EMG_Table_Est_Tst = Auto_EMG_Table_Est(:,3:end); %Remove Subject Index and Diagnosis 
[Auto_EMG_Table_New] = RBD_RF_Preprocess(Auto_EMG_Table,[],EMG_feats);
Auto_EMG_Table_New_Tst = Auto_EMG_Table_New(:,3:end); %Remove Subject Index and Diagnosis 

%Matlab Trees

[Auto_EMG_est_Yhat,Auto_EMG_est_votes] = Predict_RBDDetection_RF(rbd_est_rf,Auto_EMG_Table_Est_Tst);
[Auto_EMG_new_Yhat,Auto_EMG_new_votes] = Predict_RBDDetection_RF(rbd_new_rf,Auto_EMG_Table_New_Tst);

%% Display RBD Detection Results

if (view_results)
   %Compare RBD Detection (annotated)
   label_name = 'Annotated';
   compare_rbd_detection_results(table2array(EMG_Table),EMG_est_Yhat,EMG_new_Yhat,EMG_Table.Properties.VariableNames,EMG_feats,rbd_group,label_name,print_figures,print_folder,display_flag);
   label_name = 'Automated';
   compare_rbd_detection_results(table2array(Auto_EMG_Table),Auto_EMG_est_Yhat,Auto_EMG_new_Yhat,Auto_EMG_Table.Properties.VariableNames,EMG_feats,rbd_group,label_name,print_figures,print_folder,display_flag);
end



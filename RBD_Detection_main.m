% Main code to run algorithms to perform feature extraction ->
% train/test/evaluation automated sleep staging while also assessing RBD
% Detection

%% Add paths
addpath(strcat(pwd,'\libs\'));
addpath(strcat(pwd,'\subfunctions\'));
addpath(strcat(pwd,'\dataprep\'));

%% Attain PSG Signals
% There are several options to get PSG signals
% (A) A folder containing all mat files of all PSG signals
% (B) A folder containing all edf files and annotations
% (C) Download files eg using CAP sleep database

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
current_dir = pwd;
cd('../');
outputfolder = [pwd,'\data'];
cd(current_dir);
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

download_CAP_EDF_Annotations(outputfolder,list_of_files);
data_folder = outputfolder;

prepare_capslpdb(data_folder,outputfolder);


%% Generate Features
signals_for_processing = {'EEG','EOG','EMG','EEG-EOG'};
disp(['Extracting Features:',signals_for_processing]);
[Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing);
cd(data_folder);
save('Features.mat','Sleep','Sleep_Struct','Sleep_table');
cd(current_dir);
disp('Feature Extraction Complete and Saved');

%% Balance RBD & HC Cohort if needed

% [patients,ia,ic] = unique(Sleep_table.SubjectIndex);
% remove_idx = ismember(Sleep_table.SubjectIndex,patients(1:5));
% Sleep_table(remove_idx,:) = [];

%% Parameters for generating results
view_results = 1; %Produce Graphs/figures
print_figures= 1; %Save Graphs/figures
display_flag = 1; %Diplay results on command window
save_data = 1; %Save Data
outfilename = 'RBD_Detection_Results'; %Filename/Folder to be created

%% Preprocess Data 
SS_Features =[11:144]; % Features used for sleep staging
EMG_feats = [3,7,8,9,10,11,15,17,32,33]; %AI ratios + N3% + SleepEff + Fractal Exponenet Ratios (REM:N2/N3)
EMG_est_feats = [3,7,8,9]; %AI, MAD_Dur, MAD_Per, Stream

% Preprocess Sleep Staging Features
disp('Precprocessing Features...');
[Sleep_table_Pre] = RBD_RF_Preprocess(Sleep_table,[0,5],SS_Features);
disp('Precprocessing Complete.');

% Random Forest paramters
n_trees = 500;    

%% Cross Fold Indexing
Sleep = table2array(Sleep_table_Pre);
[patients,ia,ic] = unique(Sleep_table_Pre.SubjectIndex);
rbd_group = Sleep(ia,6)==5;

folds = ceil(log2(length(rbd_group))/5)*5; %find appropriate number of folds
indices = crossvalind('Kfold',rbd_group, folds);

%% Train Sleep Staging
%Matlab Trees
ss_rf               = TreeBagger(n_trees,Sleep(:,SS_Features),Sleep(:,7),'OOBPredictorImportance','on'); 
ss_rf_importance    =  ss_rf.OOBPermutedPredictorDeltaError';
save('Sleep_Staging_RF.mat','ss_rf');

%% Train RBD Detection

EMG_Table = Calculate_EMG_Values_table(Sleep_table_Pre);
% Preprocess Data
[EMG_Table_Pre] = RBD_RF_Preprocess(EMG_Table,[],EMG_feats);
%Matlab Trees
rbd_new_rf_ss = TreeBagger(n_trees,EMG_Table_Pre(:,EMG_feats),EMG_Table_Pre(:,2),'OOBPredictorImportance','on'); 
rbd_est_rf_ss = TreeBagger(n_trees,EMG_Table_Pre(:,EMG_est_feats),EMG_Table_Pre(:,2),'OOBPredictorImportance','on'); 
save('RBD_Detection_RF.mat','rbd_est_rf','rbd_new_rf');


%% RBD Detection
% Apply cross fold validation for automated sleep staging followed by RBD
% detection using established metrics and new metrics

[Auto_SS_Results,RBD_New_Results,EMG_Est_Results,EMG_Auto_New_Results,EMG_Auto_Est_Results,All_Confusion] = RBD_Detection(Sleep_table_Pre,Sleep_Struct,rbd_group,indices,folds,SS_Features,EMG_est_feats,EMG_feats,n_trees,view_results,print_figures,save_data,outfilename,display_flag);






% Main code to run algorithms to perform feature extraction ->
% train/test/evaluation automated sleep staging while also assessing RBD
% Detection

%% Add paths
addpath(strcat(pwd,'\libs\'));

%% Generate Features
current_dir = pwd;
data_folder = 'I:\Data\Combined_MASS_JR_CAP_HR';
signals_for_processing = {'EEG','EOG','EMG','EEG-EOG'};
[Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing)
cd(current_dir);
save('Features.mat','Sleep','Sleep_Struct','Sleep_table');

%% Balance RBD & HC Cohort if needed

%% Parameters for results
view_results = 1; %Produce Graphs/figures
print_figures= 1; %Save Graphs/figures
save_data = 1; %Save Data
outfilename = 'RBD_Detection_Results'; %Filename/Folder to be created

%% Preprocess Data 
SS_Features =[11:29,31:141]; % Features used for sleep staging

EMG_feats = [3,7,8,9,10,11,15,17,32,33]; %AI ratios + N3% + SleepEff + Fractal Exponenet Ratios (REM:N2/N3)
EMG_est_feats = [3,7,8,9]; %AI, MAD_Dur, MAD_Per, Stream

% Preprocess Sleep Staging Features
[Sleep_table_Pre] = RBD_RF_Preprocess(Sleep_table,[0,5],SS_Features);

% Random Forest paramters
n_trees = 500;    

%% Cross Fold Indexing
Sleep = table2array(Sleep_table_Pre);
[patients,ia,ic] = unique(Sleep_table_Pre.SubjectIndex);
rbd_group = Sleep(ia,6)==5;

folds = 10;
indices = crossvalind('Kfold',rbd_group, folds);

%% RBD Detection
% Apply cross fold validation for automated sleep staging followed by RBD
% detection using established metrics and new metrics

[Auto_SS_Results,RBD_New_Results,EMG_Est_Results,EMG_Auto_New_Results,EMG_Auto_Est_Results,All_Confusion] = RBD_Detection(Sleep_table_Pre,Sleep_Struct,rbd_group,indices,folds,Features,SS_Features,EMG_est_feats,EMG_feats,n_trees,view_results,print_figures,save_data,outfilename);







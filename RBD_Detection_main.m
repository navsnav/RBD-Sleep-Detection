% Main code to run algorithms to perform feature extraction ->
% train/test cross-fold evaluation for automated sleep staging while also assessing RBD
% Detection

%% Add paths
slashchar = char('/'*isunix + '\'*(~isunix));
main_dir = strrep(which(mfilename),[mfilename '.m'],'');

addpath(genpath([main_dir, 'libs', slashchar])) % add external libraries folder to path
addpath(genpath([main_dir, 'subfunctions', slashchar])) % add subfunctions folder to path
addpath(genpath([main_dir, 'dataprep', slashchar])) % add data preparation folder to path
addpath(genpath([main_dir, 'models', slashchar])) % add classifiers folder to path


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
% %Prepare mat files with PSG signals and annotations
% prepare_capslpdb(outputfolder,outputfolder);

%% (C) Extract PSG Signals - Use this section if you have a dataset of mat files with hypnogram datasets
% cd('../');
% data_folder = [pwd,'\data'];
% cd(current_dir);
% signals_for_processing = {'EEG','EOG','EMG','EEG-EOG'};
% disp(['Extracting Features:',signals_for_processing]);
% % Generate Features
% [Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing);
% 
% cd('../');
% output_folder = [pwd,'\data\features'];
% % Create a destination directory if it doesn't exist
% if exist(output_folder, 'dir') ~= 7
%     fprintf('WARNING: Features directory does not exist. Creating new directory ...\n\n');
%     mkdir(output_folder);
% end
% cd(output_folder);
% save('Features.mat','Sleep','Sleep_Struct','Sleep_table');
% disp('Feature Extraction Complete and Saved');
% cd(current_dir);

%% (D) Load Features matrix saved from ExtractFeatures
current_dir = pwd;
data_folder = [main_dir, 'data', slashchar, 'features', slashchar];
cd(data_folder);
filename = 'Features_demo.mat';
load(filename);
cd(current_dir);
%% Balance RBD & HC Cohort if needed

[patients,ia,ic] = unique(Sleep_table.SubjectIndex);

%% Parameters for generating results
outfilename = 'RBD_Detection_Results_50trees_22_10_2018'; %Filename/Folder to be created
view_results = 1; %Produce Graphs/figures
print_figures= 1; %Save Graphs/figures
print_folder = [data_folder, 'Graphs_', outfilename, slashchar];
display_flag = 1; %Diplay results on command window
save_data = 1; %Save Data

%% Preprocess Data 
SS_Features = [11:144]; % Features used for sleep staging
EMG_feats = [3,7,8,9,10,11,15,17,32,33]; %AI ratios + N3% + SleepEff + Fractal Exponenet Ratios (REM:N2/N3)
EMG_est_feats = [3,7,8,9]; %AI, MAD_Dur, MAD_Per, Stream

% Preprocess Sleep Staging Features
disp('Precprocessing Features...');
[Sleep_table_Pre] = RBD_RF_Preprocess(Sleep_table,[0,5],SS_Features);
disp('Precprocessing Complete.');

% Random Forest paramters
n_trees = 50;  %Paper used 500 trees (done to save time/space)

%% Cross Fold Indexing
Sleep = table2array(Sleep_table_Pre);
[patients,ia,ic] = unique(Sleep_table_Pre.SubjectIndex);
rbd_group = Sleep(ia,6)==5;

folds = ceil(log2(length(rbd_group))/5)*5; %find appropriate number of folds
indices = crossvalind('Kfold',rbd_group, folds);

%% RBD Detection
% Apply cross fold validation for automated sleep staging followed by RBD
% detection using established metrics and new metrics
disp(['Initiating ',num2str(folds),' fold cross validation with ',num2str(n_trees),' trees.']);
[Auto_SS_Results,RBD_New_Results,EMG_Est_Results,EMG_Auto_New_Results,EMG_Auto_Est_Results,All_Confusion] = RBD_Detection(Sleep_table_Pre,Sleep_Struct,rbd_group,indices,folds,SS_Features,EMG_est_feats,EMG_feats,n_trees,view_results,print_figures,print_folder,save_data,outfilename,display_flag);
% [Auto_SS_Results,RBD_New_Results,EMG_Est_Results,EMG_Auto_New_Results,EMG_Auto_Est_Results,All_Confusion] = RBD_Detection2(Sleep_table_Pre,Sleep_Struct,rbd_group,indices,folds,SS_Features,EMG_est_feats,EMG_feats,ECG_feats,n_trees,view_results,print_figures,print_folder,save_data,outfilename,display_flag);






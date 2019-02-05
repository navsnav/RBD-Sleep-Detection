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
current_dir = pwd;
data_folder = 'I:\Data\Combined_MASS_JR_CAP_HR';
cd(current_dir);
signals_for_processing = {'EEG','EOG','EMG','EEG-EOG','ECG'};
disp(['Extracting Features:',signals_for_processing]);
% Generate Features
[Sleep, Sleep_Struct, Sleep_table] = ExtractFeatures_mat(data_folder,signals_for_processing);

output_folder = [pwd,'\data\features'];
% Create a destination directory if it doesn't exist
if exist(output_folder, 'dir') ~= 7
    fprintf('WARNING: Features directory does not exist. Creating new directory ...\n\n');
    mkdir(output_folder);
end
cd(output_folder);
save('Features_with_ECG_23_11_2018.mat','Sleep','Sleep_Struct','Sleep_table');
disp('Feature Extraction Complete and Saved');
cd(current_dir);

%% (D) Load Features matrix saved from ExtractFeatures
current_dir = pwd;
data_folder = [main_dir, 'data', slashchar, 'features', slashchar];
cd(data_folder);
filename = 'Features_with_ECG_23_11_2018.mat';
load(filename);
cd(current_dir);
%% Balance RBD & HC Cohort if needed

[patients,ia,ic] = unique(Sleep_table.SubjectIndex);

% rmv_idx = ismember(Sleep_table.SubjectIndex,patients(1:5));
rmv_idx = ismember(Sleep_table.SubjectIndex,patients([37,38,39,90,92,94,101,105,107,109,111]));

Sleep(rmv_idx,:) = [];
Sleep_table(rmv_idx,:) = [];
subject_names = fieldnames(Sleep_Struct);
Sleep_Struct_Old = Sleep_Struct;
% Sleep_Struct = rmfield(Sleep_Struct,subject_names(1:5));
 Sleep_Struct = rmfield(Sleep_Struct,subject_names([37,38,39,90,92,94,101,105,107,109,111]));

%% Parameters for generating results
close all
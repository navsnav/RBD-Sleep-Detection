function [Yhat_Results,EMG_Yhat_Results,EMG_est_Yhat_Results,EMG_Auto_Yhat_Results,EMG_Auto_est_Yhat_Results,All_Confusion] = RBD_Detection(Sleep_table_Pre,Sleep_Struct,rbd_group,indices,folds,SS_Features,EMG_est_feats,EMG_feats,n_trees,view_results,print_figures,print_folder,save_data,outfilename,display_flag)
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
% Input:
%       Sleep_table_Pre:    Sleep table with all features and subjects (preprocessed to have no nans/infs).
%       Sleep_Struct: 	Structure containing all features and feature names
%       rbd_group:      Participant condition/diagnosis (0: Healthy control, 1: RBD participant).
%       indices:        Indicised for cross-fold validation for sleep staging and RBD detection.
%       folds:          Number of folds for cross-fold validation
%       SS_Features:    Features indicies to be used for automated sleep staging
%       EMG_est_feats:  Indicies of Established EMG features in RBD detection
%       EMG_feats:      Indicies of features to compare for RBD detection
%       n_trees:        Number of trees for Random Forest training
%       view_results:   Flag for displaying results (0: no, 1: yes).
%       print_figures:  Flag for saving figures (0: no, 1: yes).
%       save_data:      Save data and results in mat format
%       outfilename:    Filename for saved data
% Output:
%       Yhat_Results:           Automated sleep staging results.
%       EMG_Yhat_Results:       RBD Detection results using new features.
%       EMG_Yhat_Results:       RBD Detection results using new
%                               features and manually annoated sleep
%                               stages.
%       EMG_est_Yhat_Results:   RBD Detection results using established
%                               features and manually annoated sleep
%                               stages.
%       EMG_Auto_Yhat_Results:  RBD Detection results using new
%                               features and automated sleep staging.
%       EMG_Auto_est_Yhat_Results:   RBD Detection results using established
%                               features and automated sleep staging.
%       All_Confusion:          Confusion matrices of automated sleep staging.

Sleep_table = Sleep_table_Pre;
Save_Data_Name = outfilename;

if print_figures, mkdir(print_folder), end


Sleep = table2array(Sleep_table);
[patients,ia,ic] = unique(Sleep_table.SubjectIndex);

%%

%% Initialise

Yhat_Results =[];
Yhat_REM_Results = [];
votes_Results = [];
votes_REM_Results = [];
importance_Results = [];
EMG_importance_Results = [];
EMG_est_importance_Results = [];
importance_Results_REM = [];

Yhat_Results = zeros(size(Sleep,1),1);
votes_Results = zeros(size(Sleep,1),5);
% EMG_Metric = zeros(size(rbd_group,1),length(EMG_feats));
EMG_Metric = table;
EMG_Yhat_Results = ones(size(rbd_group,1),1)*-1;
EMG_votes_Results = zeros(size(rbd_group,1),2);
EMG_est_Yhat_Results = ones(size(rbd_group,1),1)*-1;
EMG_est_votes_Results = zeros(size(rbd_group,1),2);
%EMG_Auto_Metric = zeros(size(rbd_group,1),length(EMG_feats));
EMG_Auto_Metric = table;
EMG_Auto_Yhat_Results = ones(size(rbd_group,1),1)*-1;
EMG_Auto_votes_Results = zeros(size(rbd_group,1),2);
EMG_Auto_est_Yhat_Results = ones(size(rbd_group,1),1)*-1;
EMG_Auto_est_votes_Results = zeros(size(rbd_group,1),2);
RBD_Yhat= table;
RBD_Auto_Yhat = table;
results_f_est = zeros(folds,6);
results_f_new = zeros(folds,6);
results_f_est_auto = zeros(folds,6);
results_f_new_auto= zeros(folds,6);

for out=1:folds
    disp(['Fold: ',num2str(out)]);
    PatientTest = (indices==out); %patient id for testing
    PatientTrain = (indices~=out);%patient id for training
    
    PatientTest_idx = ismember(Sleep(:,1),patients(PatientTest)); %patient index for testing
    PatientTrain_idx = ismember(Sleep(:,1),patients(PatientTrain)); %patient index for training
    
    %% Train set (Sleep Staging % RBD Detection)
    Xtrn = Sleep_table_Pre(PatientTrain_idx,:);
    Ytrn = table2array(Sleep_table_Pre(PatientTrain_idx,7));
    
    %% Testing set (Sleep Staging & RBD Detection)
    Xtst = Sleep(PatientTest_idx,SS_Features);
    Ytst = Sleep(PatientTest_idx,7);
    tst_condition = Sleep(PatientTest_idx,6);
    
    %% Train Sleep Stage RF
    
    % Configure  parameters
    %     predict_all=true;
    %     extra_options.predict_all = predict_all;
    %     extra_options.importance = 1; %(0 = (Default) Don't, 1=calculate)
    %     mtry = floor(sqrt(length(SS_Features))); %number of features used to creates trees
    %     rf = classRF_train(Xtrn, Ytrn,n_trees,mtry,extra_options);
    
    %Matlab Trees
    
    [rf,rf_importance] = Train_SleepStaging_RF(n_trees,Xtrn,SS_Features,Ytrn);
    
    %% Train RBD Detection RF from annotated sleep stages (training set)
    
    EMG_Table = Calculate_EMG_Values_table(Xtrn);
    % Preprocess Data
    %     [EMG_Table_Pre] = RBD_RF_Preprocess(EMG_Table,[],EMG_feats);
    EMG_Table_Pre = EMG_Table;
    % Training Set for RBD Detection
    EMG_Ytrn = table2array(EMG_Table_Pre(:,2));
    
    %     emg_mtry = round(sqrt(length(EMG_feats)));
    %     emg_est_mtry = round(sqrt(length(EMG_est_feats)));
    % Train RF for RBD Detection using Annotated Sleep Staging
    %     emg_rf = classRF_train(EMG_Xtrn, EMG_Ytrn,n_trees,emg_mtry,extra_options); %train on all emg feats
    %     emg_est_rf = classRF_train(EMG_est_Xtrn, EMG_Ytrn,n_trees,emg_est_mtry,extra_options); %train on all established emg feats
    
    % Matlab Trees
    %Train Established Feats RF
    [emg_est_rf,emg_est_rf_importance] = Train_RBDDetection_RF(n_trees,EMG_Table,EMG_est_feats,EMG_Ytrn);
    %Train New Feats RF
    [emg_rf,emg_rf_importance] = Train_RBDDetection_RF(n_trees,EMG_Table,EMG_feats,EMG_Ytrn);
    
    
    %% Test Sleep Staging
    
    %[Yhat votes predict_val] = classRF_predict(Xtst,rf,extra_options);
    
    % Matlab Trees
    [Yhat,votes] = Predict_SleepStaging_RF(rf,Xtst);
    
    %% Test RBD Detection using Annotated Sleep Staging
    
    % Generate Test values based on annoated Sleep Staging
    EMG_Annotated_Test_Table = Calculate_EMG_Values_table(Sleep_table_Pre(PatientTest_idx,:));
    EMG_Xtst=table2array(EMG_Annotated_Test_Table(:,EMG_feats));
    EMG_est_Xtst=table2array(EMG_Annotated_Test_Table(:,EMG_est_feats));
    EMG_Ytst = table2array(EMG_Annotated_Test_Table(:,2));
    
    %Predict using all emg features for annotated Sleep Staging
    %     [EMG_Yhat EMG_votes EMG_predict_val] = classRF_predict(EMG_Xtst,emg_rf,extra_options);
    [EMG_Yhat,EMG_votes] = Predict_RBDDetection_RF(emg_rf,EMG_Xtst,'New_Features');
    
    %Predict using all established emg features for annotated Sleep Staging
    %     [EMG_est_Yhat EMG_est_votes EMG_est_predict_val] = classRF_predict(EMG_est_Xtst,emg_est_rf,extra_options);
    [EMG_est_Yhat,EMG_est_votes] = Predict_RBDDetection_RF(emg_est_rf,EMG_est_Xtst,'Established_Metrics');
    
    %% Test RBD Detection using Automatic Sleep Staging
    
    Sleep_table_automatic = Sleep_table_Pre(PatientTest_idx,:);
    Sleep_table_automatic.AnnotatedSleepStage = Yhat; %Automatic sleep staging
    
    % Generate Test values based on automatic classified Sleep Staging
    EMG_Auto_Test_Table = Calculate_EMG_Values_table(Sleep_table_automatic);
    
    EMG_Auto_Xtst=table2array(EMG_Auto_Test_Table(:,EMG_feats));
    EMG_Auto_est_Xtst=table2array(EMG_Auto_Test_Table(:,EMG_est_feats));
    EMG_Auto_Ytst = table2array(EMG_Auto_Test_Table(:,2));
    
    % Train RF for RBD Detection using Automatic Sleep Staging
    %Predict using all emg featres for automatically annoated Sleep Staging
    %     [EMG_Auto_Yhat EMG_Auto_votes EMG_Auto_predict_val] = classRF_predict(EMG_Auto_Xtst,emg_rf,extra_options);
    [EMG_Auto_Yhat,EMG_Auto_votes] = Predict_RBDDetection_RF(emg_rf,EMG_Auto_Xtst,'New_Features');
    
    %Predict using all established emg featres for automatically annoated Sleep Staging
    %     [EMG_Auto_est_Yhat EMG_Auto_est_votes EMG_Auto_est_predict_val] = classRF_predict(EMG_Auto_est_Xtst,emg_est_rf,extra_options);
    [EMG_Auto_est_Yhat,EMG_Auto_est_votes] = Predict_RBDDetection_RF(emg_est_rf,EMG_Auto_est_Xtst,'Established_Metrics');
    
    %% Store Results
    % Automated Sleep Staging
    Yhat_Results(PatientTest_idx) =  Yhat;
    votes_Results(PatientTest_idx,:) = votes;
    importance_Results(:,:,out) = [rf_importance];
    % RBD Detection using Annoated Sleep Staging
    EMG_Yhat_Results(PatientTest) = table2array(EMG_Yhat);
    EMG_votes_Results(PatientTest,:) = EMG_votes;
    EMG_est_Yhat_Results(PatientTest) = table2array(EMG_est_Yhat);
    EMG_est_votes_Results(PatientTest,:) = EMG_est_votes;
    EMG_Metric = [EMG_Metric;EMG_Annotated_Test_Table];
    
    EMG_importance_Results(:,:,out) = [emg_rf_importance];
    EMG_est_importance_Results(:,:,out) = [emg_est_rf_importance];
    % RBD Detection using Automatic Sleep Staging
    EMG_Auto_Yhat_Results(PatientTest) = table2array(EMG_Auto_Yhat);
    EMG_Auto_votes_Results(PatientTest,:) = EMG_Auto_votes;
    EMG_Auto_est_Yhat_Results(PatientTest) = table2array(EMG_Auto_est_Yhat);
    EMG_Auto_est_votes_Results(PatientTest,:) = EMG_Auto_est_votes;
    EMG_Auto_Metric = [EMG_Auto_Metric;EMG_Auto_Test_Table];
    
    RBD_Yhat = [RBD_Yhat;[EMG_Yhat,EMG_est_Yhat]];
    RBD_Auto_Yhat = [RBD_Auto_Yhat ;[EMG_Auto_Yhat,EMG_Auto_est_Yhat]];
    
    %% RBD Detection Results
    
    results_f_est(out,:)  = process_classification_results(table2array(EMG_est_Yhat)==1, rbd_group(PatientTest)==1);
    
    results_f_new(out,:)  = process_classification_results(table2array(EMG_Yhat)==1, rbd_group(PatientTest)==1);
    
    results_f_est_auto(out,:) = process_classification_results(table2array(EMG_Auto_est_Yhat)==1, rbd_group(PatientTest)==1);
    
    results_f_new_auto(out,:) = process_classification_results(table2array(EMG_Auto_Yhat)==1, rbd_group(PatientTest)==1);
    
end

%% Save Data
Sleep_names = Sleep_table.Properties.VariableNames;
EMG_Table_Names = EMG_Table.Properties.VariableNames;



%% Print Sleep Stage Results
states = [0,1,2,3,5];
if (view_results)
    %Print Sleep Staging Results
    print_results(Sleep,Yhat_Results,states,print_figures,print_folder,display_flag);
end

%% Print RBD Detection Results
if (view_results)
    %Print Comparison of RBD Detection (Annotated)
    rbd_detect_name1 = 'Established Metrics (Annotated)';
    rbd_detect_name2 = 'New Features (Annotated)';
    tablename = 'Summary_RBD_Detection_Annotated';
    print_rbd_detection_results(results_f_est,results_f_new,rbd_detect_name1,rbd_detect_name2,tablename,print_figures,print_folder);
    %Print Comparison of RBD Detection (Automated)
    rbd_detect_name1 = 'Established Metrics (Automated)';
    rbd_detect_name2 = 'New Features (Automated)';
    tablename = 'Summary_RBD_Detection_Automated';
    print_rbd_detection_results(results_f_est_auto,results_f_new_auto,rbd_detect_name1,rbd_detect_name2,tablename,print_figures,print_folder);
    %Compare RBD Detection (annotated)
    label_name = 'Annotated';
    compare_rbd_detection_results(EMG_Metric,RBD_Yhat,label_name,print_figures,print_folder,display_flag);
    label_name = 'Automated';
    compare_rbd_detection_results(EMG_Auto_Metric,RBD_Auto_Yhat,label_name,print_figures,print_folder,display_flag);
end


%% Print Feature Importance Results
if (view_results)
    %RBD Importance (Gini)
    order_idx = size(EMG_importance_Results,2); %Mean Decrease in Gini
    titlename = 'Feature Importance - Mean Decrease in Gini Index';
    xname = 'Mean Decrease in Gini Index (Importance)';
    print_feature_importance(EMG_importance_Results,order_idx,EMG_Table_Names,EMG_feats,titlename,xname,print_figures,print_folder);
end

%% Print Annotated Vs Automatic RBD Metrics
if (view_results)
    print_annotated_vs_auto(EMG_Table_Names,EMG_feats,EMG_Metric,EMG_Auto_Metric,print_figures,print_folder);
end

%% Print Confusion Matrices/Hypnograms
if (view_results)
    All_Confusion = print_confusion_mats(Sleep,Sleep_Struct,Yhat_Results,print_figures,print_folder);
end

%%
if (save_data),save(strcat(print_folder,'\',Save_Data_Name,'.mat'),'Sleep','Sleep_table','Sleep_Struct',...
        'Sleep_names','Yhat_Results',...
        'votes_Results',...
        'importance_Results','SS_Features',...
        'EMG_importance_Results','EMG_Yhat_Results','EMG_votes_Results',...
        'EMG_est_Yhat_Results','EMG_Auto_Yhat_Results','EMG_Auto_est_Yhat_Results',...
        'EMG_est_feats','EMG_feats','EMG_Auto_Metric','EMG_Metric','EMG_Table_Names',...
        'results_f_est','results_f_new','results_f_est_auto','results_f_new_auto','All_Confusion');
end



end
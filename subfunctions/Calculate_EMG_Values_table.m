function EMG_Table = Calculate_EMG_Values_table(Sleep_table)
% This function generate EMG metrics from extracted features
%
% Inputs:
%  Sleep_table : Table structure for features (for every epoch and participant)
%                that contains the following variables: 
%                   -EMG_AtoniaIndex
%                   -EMG_Motor_Activity_Dur
%                   -EMG_Motor_Activity_Thresh
%                   -EMG_Variance
%                   -EMG_fractal_exponent
% Ouput: 
%   EMG_Table : Table structure that contains metrics for each subjects:
%                   -RBD: Subject is RBD Participant (1) or not (0)                    
%                   -AI_REM: Atonia Index (REM)
%                   -AI_N3: Atonia Index (N3)
%                   -AI_N2: Atonia Index (N2)
%                   -AI_W: Atonia Index (W)
%                   -MAD_Dur: Motor Activity Detection (Duration)
%                   -MAD_Per: Motor Activity Detection (Percent) 
%                   -Stream: STREAM value
%                   -AI_Ratio_REM_N2: Atonia Index ratio N2/REM
%                   -AI_Ratio_REM_N3: Atonia Index ratio N3/REM
%                   -AI_Ratio_REM_W: Atonia Index ratio W/REM
%                   -ratio_w: Ratio of Wake epochs
%                   -ratio_n2: Ratio of N2 epochs
%                   -ratio_n3: Ratio of N3 epochs
%                   -ratio_rem: Ratio of REM epochs
%                   -Sleep_Eff: Sleep efficiency
%                   -REM_Latency: REM sleep latency 
%                   -REM_Num_Periods: Number of REM periods
%                   -AI_REM_75: Atonia Index (REM) 75th Percentile 
%                   -AI_N3_75: Atonia Index (N3) 75th Percentile 
%                   -AI_N2_75: Atonia Index (N2) 75th Percentile 
%                   -AI_W_75: Atonia Index (W) 75th Percentile 
%                   -AI_REM_25: Atonia Index (REM) 25th Percentile 
%                   -AI_N3_25: Atonia Index (N3) 25th Percentile 
%                   -AI_N2_25: Atonia Index (N2) 25th Percentile 
%                   -AI_W_25: Atonia Index (W) 25th Percentile 
%                   -Fractal_Exp_REM: Fractal Exponent (REM)
%                   -Fractal_Exp_REM_75: Fractal Exponent (REM), 75th
%                   -Fractal_Exp_N3: Fractal Exponent (N3)
%                   -Fractal_Exp_N3_75: Fractal Exponent (N3), 75th
%                   -Fractal_Exp_N2: Fractal Exponent (N2)
%                   -Fractal_Exp_N2_75: Fractal Exponent (N2), 75th
% --
% RBD Sleep Detection Toolbox, version 1.0, November 2018
% Released under the GNU General Public License
%
% Copyright (C) 2018  Navin Cooray
% Institute of Biomedical Engineering
% Department of Engineering Science
% University of Oxford
% navin.cooray@eng.ox.ac.uk
%
%
% Referencing this work
% Navin Cooray, Fernando Andreotti, Christine Lo, Mkael Symmonds, Michele T.M. Hu, & Maarten De % Vos (in review). Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis. Clinical Neurophysiology.
%
% Last updated : 15-10-2018
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License

    Subject = unique(Sleep_table.SubjectIndex);
    
    T = array2table(Subject,'VariableNames',{'SubjectIndex'});
    warning('off', 'MATLAB:table:RowsAddedNewVars')
    
    Sleep = table2array(Sleep_table);
    hyp = Sleep_table.AnnotatedSleepStage;
    condition = Sleep_table.SubjectCondition;
    
    feat_num = find(strcmp(Sleep_table.Properties.VariableNames,'EMG_AtoniaIndex'));
    MAD_Dur_feat = find(strcmp(Sleep_table.Properties.VariableNames,'EMG_Motor_Activity_Dur'));
    MAD_Per_feat = find(strcmp(Sleep_table.Properties.VariableNames,'EMG_Motor_Activity_Thresh'));
    Var_feat = find(strcmp(Sleep_table.Properties.VariableNames,'EMG_Variance'));
    Fractal_Exp_feat = find(strcmp(Sleep_table.Properties.VariableNames,'EMG_fractal_exponent'));    
    
    for i=1:length(Subject)
%        T.Subject(i) = Subjects(i);
       subject_idx = ismember(Sleep(:,1),Subject(i));
       sub_actual_rem_idx = subject_idx & ismember(hyp,5);
       sub_actual_n3_idx = subject_idx & ismember(hyp,[3,4]);
       sub_actual_n2_idx = subject_idx & ismember(hyp,2);
       sub_actual_n1_idx = subject_idx & ismember(hyp,1);
       sub_actual_w_idx = subject_idx & ismember(hyp,0);
       
       sub_hyp_idx = find(Sleep(:,1)==Subject(i));     

       T.RBD(i) = all(condition(subject_idx)); %2
       
       T.AI_REM(i) = mean(Sleep(sub_actual_rem_idx,feat_num)); %3
       T.AI_N3(i) = mean(Sleep(sub_actual_n3_idx,feat_num));%4
       T.AI_N2(i) = mean(Sleep(sub_actual_n2_idx,feat_num)); %5
       T.AI_W(i) = mean(Sleep(sub_actual_w_idx,feat_num)); %6

       T.MAD_Dur(i) = mean(Sleep(sub_actual_rem_idx,MAD_Dur_feat))/30; %7

       T.MAD_Per(i) = mean(Sleep(sub_actual_rem_idx,MAD_Per_feat)); %8
              
       T.Stream(i) = EMG_Stream_Sleep(Sleep(subject_idx,Var_feat), hyp(sub_hyp_idx)); %9       
       
       T.AI_Ratio_REM_N2(i) = T.AI_N2(i)/T.AI_REM(i); %10
       T.AI_Ratio_REM_N3(i) = T.AI_N3(i)/T.AI_REM(i); %11
       T.AI_Ratio_REM_W(i) = T.AI_W(i)/T.AI_REM(i); %12
       
       num_w_epochs = sum(sub_actual_w_idx);
       num_n1_epochs = sum(sub_actual_n1_idx);       
       num_n2_epochs = sum(sub_actual_n2_idx);
       num_n3_epochs = sum(sub_actual_n3_idx);
       num_rem_epochs = sum(sub_actual_rem_idx);
       num_epochs = sum(subject_idx);
       
       T.ratio_w(i) = num_w_epochs/num_epochs; %13
       T.ratio_n2(i) = num_n2_epochs/num_epochs; %14
       T.ratio_n3(i) = num_n3_epochs/num_epochs; %15
       T.ratio_rem(i) = num_rem_epochs/num_epochs; %16      
       
       % Sleep Efficiency
       num_sleep_states = num_n1_epochs+num_n2_epochs+num_n3_epochs+num_rem_epochs;
       T.Sleep_Eff(i) = num_sleep_states/num_epochs; %17
       
       % REM Sleep Latency
       first_rem_sub = find(sub_actual_rem_idx,1);
       first_epoch_sub = find(subject_idx,1);
       if isempty(first_rem_sub)
            first_rem_sub = find(flipud(subject_idx),1); %find last instance of sleep
       end
       T.REM_Latency(i) = ((first_rem_sub-first_epoch_sub)*30)/60; %min %18
              
       % REM Sleep Periods
       a = sub_actual_rem_idx;
       b = diff(sub_actual_rem_idx);
       c = find(b);
       d = diff([0;c]);
       type = d(b(c) == -1 & a(c) == 1);
       T.REM_Num_Periods(i) = numel(type);  %19        
              
       T.AI_REM_75(i) = prctile(Sleep(sub_actual_rem_idx,feat_num),75); %20
       T.AI_N3_75(i) = prctile(Sleep(sub_actual_n3_idx,feat_num),75);%21
       T.AI_N2_75(i) = prctile(Sleep(sub_actual_n2_idx,feat_num),75); %22
       T.AI_W_75(i) = prctile(Sleep(sub_actual_w_idx,feat_num),75);   %23
       
       T.AI_REM_25(i) = prctile(Sleep(sub_actual_rem_idx,feat_num),25); %24
       T.AI_N3_25(i) = prctile(Sleep(sub_actual_n3_idx,feat_num),25); %25
       T.AI_N2_25(i) = prctile(Sleep(sub_actual_n2_idx,feat_num),25); %26
       T.AI_W_25(i) = prctile(Sleep(sub_actual_w_idx,feat_num),25); %27     
       
%        % EMG Activity
%        sEMG = Sleep_Cell{i}.EMG.sEMG_Activity; 
%        sEMG_epoch = reshape(sEMG,[10,length(sEMG)/10])';
%        
%        struct_actual_rem_idx = ismember(Sleep_Cell{i}.Hypnogram(:,1),5);
%        struct_actual_n3_idx = ismember(Sleep_Cell{i}.Hypnogram(:,1),[3,4]);
%        struct_actual_n2_idx = ismember(Sleep_Cell{i}.Hypnogram(:,1),2);
%        struct_actual_n1_idx = ismember(Sleep_Cell{i}.Hypnogram(:,1),1);
%        struct_actual_w_idx = ismember(Sleep_Cell{i}.Hypnogram(:,1),0);       
%        
%        sEMG_REM = sEMG_epoch(struct_actual_rem_idx,:);
%        sEMG_N2 = sEMG_epoch(struct_actual_n2_idx,:);
%        sEMG_N3 = sEMG_epoch(struct_actual_n3_idx,:);
%        sEMG_W = sEMG_epoch(struct_actual_w_idx,:);       
%              
%        T.Rho_REM_mean(i) = mean(sEMG_REM(:));
%        T.Rho_N2_mean(i) = mean(sEMG_N2(:));
%        T.Rho_N3_mean(i) = mean(sEMG_N3(:));  
%        sEMG_W_new = sEMG_W(:);
%        sEMG_W_new = sEMG_W_new(~isinf(sEMG_W_new));
%        T.Rho_W_mean(i) = nanmean(sEMG_W_new);     
%        
%        T.Rho_REM_75(i) = prctile(sEMG_REM(:),75);
%        T.Rho_REM_25(i) = prctile(sEMG_REM(:),25);       
%        T.Rho_N2_75(i) =  prctile(sEMG_N2(:),75);
%        T.Rho_N2_25(i) = prctile(sEMG_N2(:),25);       
%        T.Rho_N3_75(i) =  prctile(sEMG_N3(:),75);
%        T.Rho_N3_25(i) = prctile(sEMG_N3(:),25);       
%        T.Rho_W_75(i) =  prctile(sEMG_W(:),75);
%        T.Rho_W_25(i) = prctile(sEMG_W(:),25);

        % Fractal Exponent
       T.Fractal_Exp_REM(i) = mean(Sleep(sub_actual_rem_idx,Fractal_Exp_feat)); %28
       T.Fractal_Exp_REM_75(i) = prctile(Sleep(sub_actual_rem_idx,Fractal_Exp_feat),75); %29
       
       T.Fractal_Exp_N3(i) = mean(Sleep(sub_actual_n3_idx,Fractal_Exp_feat)); %30
       T.Fractal_Exp_N2(i) = mean(Sleep(sub_actual_n2_idx,Fractal_Exp_feat)); %31    
       
       T.Fractal_Exp_Ratio_N3_REM(i) = mean(Sleep(sub_actual_n3_idx,Fractal_Exp_feat)); %32
       T.Fractal_Exp_Ratio_N2_REM(i) = mean(Sleep(sub_actual_n2_idx,Fractal_Exp_feat)); %33           

    end
    
    EMG_Table = T;

end


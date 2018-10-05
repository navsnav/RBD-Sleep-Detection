function EMG_Table = Calculate_EMG_Values_table(Sleep_table)%,hyp,condition,feat_num,MAD_Dur_feat,MAD_Per_feat,Var_feat,Fractal_Exp_feat)
    % Generate EMG metrics from extracted features

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
    
%     T = table(Subjects,RBD',AI_REM',AI_N3',AI_N2',AI_W',CAP_HC_Actual_MAD_Dur',CAP_HC_Actual_MAD_Per'...
%         ,Stream_score',AI_Ratio_REM_N2',AI_Ratio_REM_N3',AI_Ratio_REM_W',epoch_ratio_w',epoch_ratio_n2'...
%         ,epoch_ratio_n3',epoch_ratio_rem');
%     T.Properties.VariableNames = {'Subject','RBD','AI_REM','AI_N3','AI_N2','AI_W','MAD_Dur','MAD_Per'...
%         ,'STREAM','AI_Ratio_R_N2','AI_Ratio_R_N3','AI_Ratio_R_W','W_ratio','N2_ratio','N3_ratio','R_ratio'};    

    EMG_Table = T;

end


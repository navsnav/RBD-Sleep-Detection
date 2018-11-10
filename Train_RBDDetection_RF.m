function [emg_rf,emg_rf_importance] = Train_RBDDetection_RF(n_trees,EMG_Table,EMG_feats,EMG_Ytrn)
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
% Input: (n_trees,Sleep,SS_Features,hyp)
%       n_trees: Number of trees to train random forest.
%       EMG_Table: Features/Data used to train rf model.
%       EMG_feats: Specific features within EMG_Table used to train rf model.
%       EMG_Ytrn: RBD Diagnosis Annotated sleep staging to train rf model. 
% Output:
%       emg_rf: Trained random forest model.   
%       emg_rf_importance: Feature importance values for each feature.

    emg_rf = TreeBagger(n_trees,EMG_Table(:,EMG_feats),EMG_Ytrn,'OOBPredictorImportance','on'); 
    emg_rf_importance = [emg_rf.OOBPermutedPredictorDeltaError',emg_rf.DeltaCriterionDecisionSplit'];

end
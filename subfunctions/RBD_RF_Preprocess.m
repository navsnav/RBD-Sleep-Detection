function [Sleep_table_Pre,removed_idx] = RBD_RF_Preprocess(Sleep_table,patient_codes,Features)
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
%       Sleep_table:    Sleep table with all features and subjects.
%       patient_codes: 	Include subject codes included in this array eg
%                       [0,5].
%       Features:       Features to be included for pre-processing.
% Output:
%       Sleep_table_Pre:    Preprocessed table to remove nans/inf 
%                           for all included patients codes.
  
  
Sleep = table2array(Sleep_table);

%% Include all subjects with following patient codes
if ~isempty(patient_codes)
    if isnan(patient_codes)
        Patient_idx = find(isnan(Sleep(:,6)));    
    else
        Patient_idx = ismember(Sleep(:,6),patient_codes);
    end
    OldSleep = Sleep(Patient_idx,:);
else
    OldSleep = Sleep;    
end
unique_patients = unique(OldSleep(:,1));
c = ismember(OldSleep(:,1),unique_patients);
index = find(c);
Sleep = OldSleep(index,:);


%% Find NANs and remove
[row, col] = find(isnan(Sleep(:,Features)));
Sleep(unique(row),:) = [];

%% Find Movement (7,9,6) and Unscored epochs and remove

[rowMov, colMov] = find(Sleep(:,7)==7 | Sleep(:,7)==9 | Sleep(:,7)==6);
Sleep(unique(rowMov),:) = [];

[rowUns, colUns] = find(Sleep(:,7)==-1);
Sleep(unique(rowUns),:) = [];


%% Find inf and remove
[rowInf, colInf] = find(isinf(Sleep(:,Features)));
Sleep(unique(rowInf),:) = [];

%% Convert Sleep Stages to AASM (A,N1,N2,N3 & REM)
[rowSWS colSWS] = find(Sleep(:,7)==4);
Sleep(rowSWS,7) = 3;

%% If all indicies of a subject are removed provide warning

if ~all(ismember(unique_patients,unique(Sleep(:,1))))
   warning('Entire Subject Removed due to inf/NAN'); 
end

removed_idx = [row;rowInf];

%%

Sleep_table_Pre  = array2table(Sleep,...
                    'VariableNames',Sleep_table.Properties.VariableNames);
end
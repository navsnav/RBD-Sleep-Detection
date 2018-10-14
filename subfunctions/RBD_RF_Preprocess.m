function [Sleep_table_Pre,removed_idx] = RBD_RF_Preprocess(Sleep_table,patient_codes,Features)
% This function pre-processes a feature able to remove rows with NaNs/infs
% and sleep stages that might not considered (movement/artifacts)
%
% Input:
%       Sleep_table:    Sleep table with all features and subjects.
%       patient_codes: 	Include subject codes included in this array eg
%                       [0,5].
%       Features:       Features to be included for pre-processing.
% Output:
%       Sleep_table_Pre:    Preprocessed table to remove nans/inf 
%                           for all included patients codes.
%
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
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
  
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
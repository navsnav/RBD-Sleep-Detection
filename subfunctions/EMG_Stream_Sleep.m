function Stream_score = EMG_Stream_Sleep(Sleep_var, hyp)
% This function makes omelettes
%
% Inputs:
%  Sleep_var    - Variance of EMG signal
%  hyp   - The annotated hypnogram for each epoch 
%
% Output:
%  Stream_score: STREAM value as defined by Burns et al
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
REM_var = [];
NREM_var = [];


for i = 1:length(hyp)
   REM_epoch = hyp(i,1) == 5;
   NREM_epoch = hyp(i,1) == 1| hyp(i,1)==2 | hyp(i,1)== 3 | hyp(i,1)==4;

    if REM_epoch

        EMG_var = Sleep_var(i);
        REM_var = [REM_var;EMG_var];
    elseif NREM_epoch
        EMG_var = Sleep_var(i);
        NREM_var = [NREM_var;EMG_var];
        
    end   
    
end
Stream_t = 4*prctile(NREM_var,5);

Stream_score  = sum(REM_var>Stream_t)/length(REM_var)*100;


end

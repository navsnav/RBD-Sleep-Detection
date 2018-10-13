function [Yhat,votes] = Predict_SleepStaging_RF(rf,Xtst)
% This function makes omelettes
%
% Input:
%       rf: Trained Random Forest Model from TreeBagger.
%       Xtst: Test set using same features used for training rf model.
% Output:
%       Yhat: Results of sleep staging from trained rf model.   
%       votes: Percentage of votes for each stage.
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


    [Yhat,votes] = predict(rf,Xtst);       
    Yhat = str2num(cell2mat(Yhat));

end

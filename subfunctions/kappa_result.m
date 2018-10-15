function [kappa] = kappa_result(conf_mat)
% This function produces kappa results for a given confusion matrix
%
% Inputs:
%  conf_mat - confusion matrix
%
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

    %total number of stages
    n = sum(sum(conf_mat,2)); 
    %number of agreements
    n_a = sum(sum(eye(size(conf_mat)).*conf_mat)); 
    %numberof agreement due to chance
    agree_chance = (sum(conf_mat,1)./n)*(sum(conf_mat,2)./n)*n; 
    
    kappa = (n_a-agree_chance)/(n-agree_chance);
        
end      
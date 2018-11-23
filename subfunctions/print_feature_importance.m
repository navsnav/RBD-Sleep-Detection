function print_feature_importance(EMG_importance_Results,order_idx,EMG_Table_Names,EMG_feats,titlename,xname,print_figures,print_folder)
% This function calcualtes the feature importance and generates a figure
% to depict results
%
% Inputs:
%  EMG_importance_Results    - Matrix providing importance measure for each
%                              feature
%  order_idx   - order of importance for each feature
%  EMG_Table_Names - names of features
%  EMG_feats - index of features
%  titlename - name of figure to be saved
%  xname - xlabel for figure
%  print_figures - flag to save/print figure
%  print_folder - folder to save figure
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

EMG_Importance_Acc = squeeze(EMG_importance_Results(:,order_idx,:));

mu_EMG_Importance_Acc = mean(EMG_Importance_Acc,2);
[B,I] = sort(mu_EMG_Importance_Acc,'ascend');
fignum = figure;
hold on;
for i=1:length(B)
    hbar = barh(i,B(i),'stacked');
    if mod(i,2) == 0
        set(hbar,'FaceColor',[0,114/256,189/256]);        
    else
        set(hbar,'FaceColor',[191/256,74/256,74/256]);                
    end
    
end
% hbar = barh(B,'stacked','r');
set(gca,'TickLabelInterpreter', 'none');
x = 1:length(B);
yticks(x);
yticklabels(EMG_Table_Names(EMG_feats(I)));
title(titlename);
xlabel(xname);
if (print_figures)
    saveas(fignum,strcat(print_folder,'\',titlename),'png');
    saveas(fignum,strcat(print_folder,'\',titlename),'fig');
    
end

end
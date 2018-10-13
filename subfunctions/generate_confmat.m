function generate_confmat(ConfMat1,Subject,print_figures,print_folder)
% This function makes a confusion matrix plot/figure
%
% Inputs:
%  ConfMat1    - confusion matrix in array format
%  Subject   - string of subject name
%  print_figures - flag to print and save figure
%  print_folder - folder to save figures
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

% Generate confusion matrix
    fig_num = figure;
    imagesc(0:4,0:4,ConfMat1)  
    colormap(flipud(gray))
    %   format_figure
    title(['Sleep stage Classifications - Subject ',Subject], 'Interpreter', 'none');
    xlabel('Annotated Sleep Staging');
    ylabel('Automated Sleep Staging');
    set(gca,'XTick',[0 1 2 3 4]);
    set(gca,'YTick',[0 1 2 3 4]);
    set(gca,'XTickLabel',{'W','N1','N2','N3','R'})
    set(gca,'YTickLabel',{'W','N1','N2','N3','R'})
    
%     colormap([flipud(white); 1 1 1])
    for k = 1:5
        for j = 1:5
            if k == j
               text(k-1, j-1, num2str(ConfMat1(j,k)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize',16,'Color','white')                           
            else
                text(k-1, j-1, num2str(ConfMat1(j,k)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize',16)            
            end
        end
    end
    
    xt =[-0.5,0.5,1.5,2.5,3.5,4.5,5.5];
    xl = get(gca,'xlim');
    line(repmat(xt(2:end-1),2,1),repmat(xl(:),1,length(xt)-2),'color','black')
    yt = [-0.5,0.5,1.5,2.5,3.5,4.5,5.5];
    yl = get(gca,'ylim');
    line(repmat(yl(:),1,length(yt)-2),repmat(yt(2:end-1),2,1),'color','black')
        
    if (print_figures),saveas(fig_num,strcat(print_folder,'\','RF_NormConfusionMat_',Subject),'epsc'),end  
  
end
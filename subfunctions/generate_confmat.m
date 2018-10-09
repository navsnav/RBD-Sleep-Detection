function generate_confmat(ConfMat1,Subject,print_figures,print_folder)
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
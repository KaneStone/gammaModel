function [] = addLabels(fsize,tit,xlab,ylab)
    
    set(gca,'fontsize',fsize);
    title(tit,'fontsize',fsize+4);    
    xlabel(xlab,'fontsize',fsize+1);
    ylabel(ylab,'fontsize',fsize+1);
    
end

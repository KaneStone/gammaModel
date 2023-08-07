function [fig] = createfig(size,on)
%creates my usual figure window
%on is a logical
switch size
    case 'small'
        fig = figure;
        set(fig,'color','white','position',[100 100 860 540],'Visible',on);
    case 'medium' 
        fig = figure;
        set(fig,'color','white','position',[100 100 1000 700],'Visible',on);
    case 'large'
        fig = figure;
        set(fig,'color','white','position',[100 100 1000 900],'Visible',on);
    case 'largeportrait'
        fig = figure;
        set(fig,'color','white','position',[100 100 900 1400],'Visible',on);
    case 'largelandscape'
        fig = figure;
        set(fig,'color','white','position',[100 100 1400 900],'Visible',on);
    case 'largesquare'
        fig = figure;
        set(fig,'color','white','position',[100 100 1200 1200],'Visible',on);
    case 'large23'
        fig = figure;
        set(fig,'color','white','position',[100 100 1800 1200],'Visible',on);    
    case 'medium23'
        fig = figure;
        set(fig,'color','white','position',[100 100 1350 900],'Visible',on);    
    case 'small12'
        fig = figure;
        set(fig,'color','white','position',[100 100 1350 500],'Visible',on);    
    case 'large32'
        fig = figure;
        set(fig,'color','white','position',[100 100 1200 1200],'Visible',on);            
end
    
end
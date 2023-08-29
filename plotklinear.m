function [] = plotklinear(inputs,g,gk,T_limit)

% plot gammas
titles = {'clono2+hcl','clono2+h2o','hocl+hcl','hobr+hcl'};
fields = fieldnames(g);
if inputs.plotgamma
    createfig('medium','on')
    t = tiledlayout(2,2);
    title(t,['Gamma, case = ',inputs.rcase,', ',inputs.ratioext,', ',inputs.radext],'fontsize',22,'fontweight','bold')
    for i = 1:length(fields)
        nexttile;

        plot(T_limit,gk.(fields{i}),'LineWidth',inputs.linewidth); set(gca,'Yscale','log');
        hold on;
        plot(T_limit,g.(fields{i}),'LineWidth',inputs.linewidth); set(gca,'Yscale','log');
        
        if i == 1
            lh = legend('Linearize H','Linearize gamma');        
            set(lh,'box','off','fontsize',18)
        end

        addLabels(18,titles{i},'Temperature','Reaction probability');
        ylim([1e-8 1])
        set(gca,'ytick',[10^-8,10^-6,10^-4,10^-2,10^0]);
       
    end
    outdir = [inputs.outdir,'gamma/'];
    filename = ['linearmethods_Gamma_compare_',inputs.rcase,'_',inputs.ratioext,'_',inputs.radext];
    savefigure(outdir,filename,1,0,0,0);
end

end
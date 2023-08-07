function [] = plotGAMMA(inputs,g,ah,vis_h2so4,T_limit)

% plot gammas
if inputs.plotgamma
    createfig('medium','on')

    plot(T_limit,g.prob_cnt_hcl,'LineWidth',inputs.linewidth); set(gca,'Yscale','log');
    hold on;
    plot(T_limit,g.prob_cnt_h2o,'LineWidth',inputs.linewidth); set(gca,'Yscale','log');
    plot(T_limit,g.gprob_hocl_hcl,'LineWidth',inputs.linewidth); set(gca,'Yscale','log');
    plot(T_limit,g.gprob_hobr_hcl,'LineWidth',inputs.linewidth); set(gca,'Yscale','log');
    lh = legend('clono2+hcl','clono2+h2o','hocl+hcl','hobr+hcl');        
    set(lh,'box','off','fontsize',20)
    
    addLabels(inputs.fontsize,['Gamma, case = ',inputs.rcase,', ',inputs.ratioext,', ',inputs.radext],'Temperature','Reaction probability');
    ylim([1e-8 1])

    outdir = [inputs.outdir,'gamma/'];
    filename = ['Gamma_compare_',inputs.rcase,'_',inputs.ratioext,'_',inputs.radext];
    savefigure(outdir,filename,1,0,0,0);
end

% plot acidity and viscosity
if inputs.plotacidity
    createfig('medium','on')

    plot(T_limit,ah,'LineWidth',inputs.linewidth); set(gca,'Yscale','log');    
    set(gca,'fontsize',20)
    set(lh,'box','off','fontsize',20)
    ylabel('acidity [H+] mol/L','fontsize',22)
    yyaxis right
    hold on
    plot(T_limit,vis_h2so4,'LineWidth',inputs.linewidth); set(gca,'Yscale','log');     
    addLabels(inputs.fontsize,['ah and vish2so4, case = ',inputs.rcase,', ',inputs.ratioext,', ',inputs.radext],'Temperature','Viscosity (cP)');
    
    outdir = [inputs.outdir,'acidvis/'];
    filename = ['aH_vis_compare_',inputs.rcase,'_',inputs.ratioext,'_',inputs.radext];
    savefigure(outdir,filename,1,0,0,0);
end

end
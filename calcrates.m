function [ah,g,vis_h2so4] = calcrates(inputs,wt,Min,Hin,SAD_Tbin,molar_h2so4,T_limit,T_limiti,aw,pHCl_Tbin,pCLONO2_Tbin,HOClterm1,HOClterm2,HOBrterm1,HOBrterm2,wt_acidity,wt_viscosity)

% for quick rates calc;
k=1.38066e-23;
hobrnd = 1./k*1e-6.*1e-12.*7000./210;
clono2nd = 1./k*1e-6.*8e-10.*7000./210;
hclnd = 1./k*1e-6.*2e-9.*7000./210;


wtacid = wt_acidity;
wtvis = wt_viscosity;
% control, dilution, hex with wt change, hex without weight change, hex with weight change
    
aconst    = 169.5 + wtvis.*(5.18 - wtvis.*(.0825 - 3.27e-3.*wtvis));
tzero     = 144.11 + wtvis.*(.166 - wtvis.*(.015 - 2.18e-4.*wtvis));
vis_h2so4 = aconst./(T_limit.^1.43) .* exp( 448./(T_limit - tzero) );

term1 = 60.51;
term2 = .095.*wtacid;
wrk   = wtacid.*wtacid;
term3 = .0077.*wrk;
term4 = 1.61e-5.*wtacid.*wrk;
term5 = (1.76 + 2.52e-4 .* wrk) .* sqrt(T_limit);
term6 = -805.89 + (253.05.*(wtacid.^.076));
term7 = sqrt(T_limit);
ah    = exp( term1 - term2 + term3 - term4 - term5 + term6./term7);

wrk = .25.*.1e-6;

%% CLONO2 + H2O and CLONO2 + HCL
sf = 1;
R =8.31;
av_clono2 = (8.*R.*T_limit.*1000./(pi*98)).^.5 .* 100;

molarcat = molar_h2so4;

Mcat = Min;
C_cnt         = 1474.*sqrt(T_limit); % no
S_cnt         = .306 + 24.*T_limiti; % no
term1         = exp( -S_cnt.*molarcat); % no
H_cnt         = 1.6e-6 .* exp( 4710.*T_limiti ).*term1; % no
D_cnt         = 5.e-8.*T_limit ./ vis_h2so4; % no
k_h           = 1.22e12.*exp( -6200.*T_limiti ); % no
k_h2o         = 1.95e10.*exp( -2800.*T_limiti ); % no
k_hydr        = (k_h2o + k_h.*ah).*aw; % no
k_hcl         = 7.9e11.*ah.*D_cnt.*Mcat; % maybe
rdl_cnt       = sqrt( D_cnt./(k_hydr + k_hcl) ); % no
term1         = 1./tanh(inputs.rad_sulf./rdl_cnt ); % no
term2         = rdl_cnt./inputs.rad_sulf; % no
f_cnt         = term1 - term2; % no

T_limit2 = T_limit;
pHCl_atm2 = pHCl_Tbin;
pCNT_atm2 = pCLONO2_Tbin;

term1         = 4.*H_cnt*.082.*T_limit2;
term2         = sqrt( D_cnt.*k_hydr );
Gamma_b_h2o   = term1.*term2./C_cnt;
term1         = sqrt( 1 + k_hcl./k_hydr );
Gamma_cnt_rxn = f_cnt.*Gamma_b_h2o.*term1;
Gamma_b_hcl   = Gamma_cnt_rxn.*k_hcl./(k_hcl + k_hydr);
term1         = exp( -1374.*T_limiti );
Gamma_s       = 66.12.*H_cnt.*Mcat.*term1;

term1      = .612.*(Gamma_s+Gamma_b_hcl).*pCNT_atm2./pHCl_atm2;
Fhcl       = 1./(1 + term1);

Gamma_s_prime     = Fhcl.*Gamma_s;
Gamma_b_hcl_prime = Fhcl.*Gamma_b_hcl;
term1         = Gamma_cnt_rxn.*k_hydr;
term2         = k_hcl + k_hydr;
Gamma_b       = Gamma_b_hcl_prime + (term1./term2);
term1         = 1 ./ (Gamma_s_prime + Gamma_b);
gprob_cnt     = 1 ./ (1 + term1);
term1         = Gamma_s_prime + Gamma_b_hcl_prime;
term2         = Gamma_s_prime + Gamma_b;
g.prob_cnt_hcl = gprob_cnt .* term1./term2;
g.prob_cnt_h2o = gprob_cnt - g.prob_cnt_hcl;

test1 = wrk.*av_clono2.*g.prob_cnt_hcl.*clono2nd; 

%% HOCL + HCl
D_hocl          = 6.4e-8.*T_limit./vis_h2so4;
k_hocl_hcl      = 1.25e9.*ah.*D_hocl.*Mcat;
C_hocl          = 2009.*sqrt(T_limit);
S_hocl          = .0776 + 59.18.*T_limiti;
term1           = exp( -S_hocl.*molarcat );
H_hocl          = 1.91e-6 .* exp( 5862.4.*T_limiti ).*term1 .* HOClterm1 + HOClterm2;
term1           = 4.*H_hocl.*.082.*T_limit;
term2           = sqrt( D_hocl.*k_hocl_hcl );
Gamma_hocl_rxn  = term1.*term2./C_hocl;
rdl_hocl        = sqrt( D_hocl./k_hocl_hcl );
term1           = 1./tanh( inputs.rad_sulf./rdl_hocl );
term2           = rdl_hocl./inputs.rad_sulf;
f_hocl          = term1 - term2;

term1           = 1 ./ (f_hocl.*Gamma_hocl_rxn.*Fhcl);
g.gprob_hocl_hcl  = 1 ./ (1. + term1);


% HOBR + HCL

% !-----------------------------------------------------------------------
% !         ... HOBr + HCl(liq) =  BrCl + H2O  Sulfate Aerosol Reaction
% !-----------------------------------------------------------------------
% !-----------------------------------------------------------------------
% !       ... Radius sulfate set (from sad module)
% !           Set min radius to 0.01 microns (1e-6 cm)
% !           Typical radius is 0.1 microns (1e-5 cm)
% !           f_hobr may go negative under if not set.
% !-----------------------------------------------------------------------
C_hobr          = 1477.*sqrt(T_limit);
D_hobr          = 9.e-9;
% !-----------------------------------------------------------------------
% !         ...  Taken from Waschewsky and Abbat
% !            Dave Hanson (PC) suggested we divide this rc by eight to agree
% !            with his data (Hanson, 108, D8, 4239, JGR, 2003).
% !            k1=k2*Mhcl for gamma(HOBr)
% !-----------------------------------------------------------------------
k_wasch         = .125 .* exp( .542*wt - 6440*T_limiti + 10.3);
  % This needs to be fixed
  % k walsch goes to zero as they assume H_hobr increases with increasing
  % acidity
% !-----------------------------------------------------------------------
% !         ... Taken from Hanson 2002.
% !-----------------------------------------------------------------------
H_hobr          = exp( -9.86 + 5427*T_limiti ).*HOBrterm1 + HOBrterm2;
k_dl            = repmat(7.5e14.*D_hobr.*2,[1,length(T_limit)]);%             ! or  7.5e14*D *(2nm)
M_hobr = 1e-12.*H_hobr;
% !-----------------------------------------------------------------------
% !      ... If k_wasch is GE than the diffusion limit...
% !-----------------------------------------------------------------------

kind = k_wasch >= k_dl;
k_hobr_hcl = NaN(size(H_hobr));
k_hobr_hcl(kind)   = k_dl(kind) .* Mcat(kind);
k_hobr_hcl(~kind)   = k_wasch(~kind) .* Mcat(~kind);                 

term1           = 4.*H_hobr.*.082.*T_limit;
term2           = sqrt( D_hobr.*k_hobr_hcl );
tmp             = inputs.rad_sulf./term2;
Gamma_hobr_rxn  = term1.*term2./C_hobr;
rdl_hobr        = sqrt( D_hobr./k_hobr_hcl );              
term1           = 1./tanh( inputs.rad_sulf./rdl_hobr );             
term2           = rdl_hobr./inputs.rad_sulf;
f_hobr          = term1 - term2;

term1              = 1 ./ (f_hobr.*Gamma_hobr_rxn);
g.gprob_hobr_hcl = 1 ./ (1 + term1);

test = wrk.*av_clono2.*g.gprob_hobr_hcl.*hobrnd; 



end
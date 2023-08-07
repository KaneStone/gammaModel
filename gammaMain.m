
% GAMMA model based on Shi et al and Doug Kinnison's implimentation in WACCM
% change case methid in BCinputs
clear variables
 
inputs = BCinputs;

%% Read in ancil data
[T_limit,pH2O_Tbin,pCLONO2_Tbin,pHCl_Tbin,SAD_Tbin] = readdata(inputs);

%% begin calculating gammas

% calculate water acticity (aw)
wt_e0 = 18.452406985;
wt_e1 = 3505.1578807;
wt_e2 = 330918.55082;
wt_e3 = 12725068.262;

T_limiti = 1./T_limit;
pzero_h2o = exp(wt_e0 - T_limiti .* (wt_e1 + T_limiti .* (wt_e2 - T_limiti .* wt_e3)));
aw = pH2O_Tbin ./ pzero_h2o;

% h2so4 molality (mol/kg)
awcon = awconstants(aw);

y1 = awcon.a1.*(aw.^awcon.b1) + awcon.c1.*aw + awcon.d1;
y2 = awcon.a2.*(aw.^awcon.b2) + awcon.c2.*aw + awcon.d2;

m_h2so4 = y1 + ((T_limit - 190) .* (y2 - y1)) / 70;

% density of h2so4/water (g/l)
wrk = T_limit.*T_limit;
z1 =  .12364  - 5.6e-7.*wrk;
z2 = -.02954  + 1.814e-7.*wrk;
z3 =  2.343e-3 - T_limit.*1.487e-6 - 1.324e-8.*wrk;

den_h2so4 = 1 + m_h2so4.*(z1 + z2.*sqrt(m_h2so4) + z3.*m_h2so4);

org_fraction = 1./(1./inputs.orgsulfratio + 1);
sulf_fraction = 1-org_fraction;

% weight percent h2so4
wt = 9800 .* m_h2so4 ./ (98 .* m_h2so4 + 1000);

% weight percent h2so4 after organics addition
wt_withorg = 1 ./ (1./ wt + inputs.orgsulfratio./100);

% weight percent of organics
wt_org = wt_withorg .* inputs.orgsulfratio;

% weight percent of water
wt_water = 100 - wt_withorg - wt_org;

% mole fraction of organics in aerosol
x_organic = wt_org ./ (wt_org + (wt_water .* 116.16/18) + (wt_withorg .* 116.16/98));

% mole fraction of h2so4/water in aerosol
x_h2so4water = 1 - x_organic;

%% update values dependent on case

% base values for acidity, viscosity, and molarity h2so4 (mol/l)
wt_acidity = wt;
wt_viscocity = wt;
molar_h2so4 = den_h2so4.*wt./9.8; %mol/l

switch inputs.rcase    
    case 'oldwt'        
        wt = wt_withorg;
        wt_acidity = wt_withorg;
        wt_viscocity = wt_withorg;        
        x_h2so4   = wt ./ (wt + (wt_water .* 98./18) + (wt_org .* 98./116));
        molar_h2so4 = den_h2so4.*wt./9.8; %mol/l
    case 'newwt'
        x_h2so4   = wt_withorg ./ (wt_withorg + (wt_water .* 98./18) + (wt_org .* 98./116));
    case 'newwtWithacidity'
        wt_acidity = wt_withorg;
        x_h2so4   = wt_withorg ./ (wt_withorg + (wt_water .* 98./18) + (wt_org .* 98./116));
        %molar_h2so4 = den_h2so4.*wt_withorg./9.8; %mol/l
    case 'newwtWithviscosity'
        wt_viscocity = wt_withorg;
        x_h2so4   = wt_withorg ./ (wt_withorg + (wt_water .* 98./18) + (wt_org .* 98./116));
    case 'newwtWithacidvis'
        wt_viscocity = wt_withorg;
        wt_acidity = wt_withorg;
        x_h2so4   = wt_withorg ./ (wt_withorg + (wt_water .* 98./18) + (wt_org .* 98./116));
    case 'correctedKa'
        wt_viscocity = wt;
        wt_acidity = wt;
        x_h2so4 = wt ./ (wt + (100 - wt) .* 98 ./ 18);
    case 'correctedKaWithacidvis'
        wt_viscocity = wt_withorg;
        wt_acidity = wt_withorg;
        x_h2so4 = wt ./ (wt + (100 - wt) .* 98 ./ 18);
    otherwise
        x_h2so4 = wt ./ (wt + (100 - wt) .* 98 ./ 18); % mole fraction
end

% Shi et al calculation of Henry's constant for HCl
term1 = .094 - x_h2so4 .* (.61 - 1.2 * x_h2so4);
term2 = (8515 - 10718 .* (x_h2so4.^.7)).*T_limiti;
H_hcl_h2so4 = term1 .* exp( -8.68 + term2); %(mol / l / atm)
M_hcl_h2so4 = H_hcl_h2so4.*pHCl_Tbin; %(mol/l/atm * atm) = mol/l

% calculating HCL Henry's coefficient in hexanoic acid

hex_smoothing_strat = exp(28.986 - 33.458./(T_limit/100) - 18.135 .* log(T_limit/100)); % fraction
hex_smoothing_strat = 1./(1./hex_smoothing_strat -1); % ratio

Ka = 10^5.9;
Mm_hex = 116.16;
hex_den = (-5.0083e-7 * T_limit.^2 - 5.2309e-4 .* T_limit + 1.1238) * 1000; %(from Ghatee et al. 2013 [may not be applicable]) dx.doi.org/10.1021/ie3018675

%calculating molarity in mol/L at 1 atm
molarity = hex_smoothing_strat .* 1./Mm_hex .* hex_den; % molarity at 1 atm
H_hcl_hex = molarity.*Ka;
M_hcl_hex = H_hcl_hex.*pHCl_Tbin; %(mol/l/atm * atm) = mol/l

%% H values dependent on case
% base case M value
M_total = M_hcl_h2so4;

% updating H and M terms based on case
switch inputs.rcase
    case 'normal'
        H_total = H_hcl_h2so4;
        M_total = M_hcl_h2so4;
        HOBrterm1 = 1;
        HOBrterm2 = 0;
        HOClterm1 = 1;
        HOClterm2 = 0;                
    case 'linearizeH'
                
        H_total = H_hcl_h2so4.*x_h2so4water + H_hcl_hex.*x_organic;
        M_total = M_hcl_h2so4.*x_h2so4water + M_hcl_hex.*x_organic;        
        HOBrterm1 = x_h2so4water;
        HOBrterm2 = repmat(5e8.*(1-x_h2so4water),[1,length(T_limit)]);
        HOClterm1 = x_h2so4water;
        HOClterm2 = 1e6*(1-x_h2so4water);                
        
    case 'hexanoicNOWT'
                
        H_total = H_hcl_hex;
        M_total = M_hcl_hex;        
        HOBrterm1 = 1;
        HOBrterm2 = 0;
        HOClterm1 = 1;
        HOClterm2 = 0;                
                
    case 'oldwt'
                
        H_total = H_hcl_h2so4;
        M_total = M_hcl_h2so4;        
        HOBrterm1 = 1;
        HOBrterm2 = 0;
        HOClterm1 = 1;
        HOClterm2 = 0;                
        
    case {'correctedKa','correctedKaWithacidvis'}
        
        % recalculating H based on ah 
        term1 = 60.51;
        term2 = .095.*wt_withorg;
        wrk   = wt_withorg.*wt_withorg;
        term3 = .0077.*wrk;
        term4 = 1.61e-5.*wt_withorg.*wrk;
        term5 = (1.76 + 2.52e-4 .* wrk) .* sqrt(T_limit);
        term6 = -805.89 + (253.05.*(wt_withorg.^.076));
        term7 = sqrt(T_limit);
        ah    = exp( term1 - term2 + term3 - term4 - term5 + term6./term7);

        H_hcl_hex = molarity.*(1+Ka./ah);
        M_hcl_hex = H_hcl_hex.*pHCl_Tbin; %(mol/l/atm * atm) = mol/l
        
        H_total = H_hcl_h2so4.*x_h2so4water + H_hcl_hex.*x_organic;
        M_total = M_hcl_h2so4.*x_h2so4water + M_hcl_hex.*x_organic;
        HOBrterm1 = 1;
        HOBrterm2 = 0;
        HOClterm1 = 1;
        HOClterm2 = 0;        
    case {'newwt','newwtWithacidity','newwtWithviscosity','newwtWithacidvis'}
                
        H_total = H_hcl_h2so4;
        M_total = M_hcl_h2so4;        
        HOBrterm1 = 1;
        HOBrterm2 = 0;
        HOClterm1 = 1;
        HOClterm2 = 0;                            
end

%% calculate rates
[ah,g,vis_h2so4] = calcrates(inputs,wt,M_total,H_total,SAD_Tbin,molar_h2so4,...
    T_limit,T_limiti,aw,pHCl_Tbin,pCLONO2_Tbin,HOClterm1,...
    HOClterm2,HOBrterm1,HOBrterm2,wt_acidity,wt_viscocity);

%% plot gammas, acidity nd viscosity
plotGAMMA(inputs,g,ah,vis_h2so4,T_limit)

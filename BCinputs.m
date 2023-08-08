function inputs = BCinputs

% ancil date directory. Based of CARMA 2020 model output for control run.

inputs.directory = 'input/'; %change input directory here if needed.
%inputs.directory = '/Volumes/ExternalOne/work/data/Bushfire/CESM/finalensembles/SD/control/alldata/temp/';   

inputs.rcase = 'normal'; 
% Below is a list of the different cases that are currently implemented
%normal (Regular Shi et al calculation - no organics)
%hexanoicNOWT (Nature paper Solubility run)
%linearizeH (linearize H values using mole fraction of sulfur/water and %organics in aerosols)
%oldwt (Dilution case in Nature paper)
%newwt (Dilution case but wt change ONLY effects HCl solubility)
%newwtWithacidity (Dilution case but wt ONLY change effects HCl solubility, acidity, and viscosity)
%newwtWithviscosity (Dilution case but wt ONLY change effects HCl solubility and viscosity)
%newwtWithacidvis (Dilution case but wt ONLY change effects HCl and viscosity)
%correctedKa (linearizeH case but Ka of HCl in organics is corrected by wt corrected ah)
%correctedKaWithacidvis (Same as corrected Ka, but wt change also effects acidity and viscosity)

%% inputs for model parameters
inputs.preslev = 70; %hPa;
inputs.timeperiod = 1:53; % weeks used because of old control run had output in weeks.
inputs.lats = [-90, -40]; % latitudes to extract temperature based bin data.

%% physical constants
inputs.avg = 6.023e23;
inputs.mma = 28.97; % g/mol

%% inputs for gamma calculations
inputs.rad_sulf = 1e-5; %cm radius of aerosols (1e-5 is used in Shi et al) % changing this will change the gammas!
inputs.orgsulfratio = 5; % ratio of organics to sulfate in aerosols

%% plotting inputs
inputs.plotgamma = 1;
inputs.plotacidity = 1;
inputs.outdir = 'output/'; % update plot output directory here
%inputs.outdir = '/Users/kanestone/Dropbox (MIT)/Work_Share/MITWork/BushfireChemistry/2023update/DiagnosticPlots/
inputs.fontsize = 18;
inputs.linewidth = 2;
%% output extensions
inputs.radext = ['radius=',num2str(inputs.rad_sulf)];
switch inputs.rcase 
    case {'normal','hexanoicNOWT'}
        inputs.ratioext = ['orgsulfRatio=','NA'];
    otherwise
        inputs.ratioext = ['orgsulfRatio=',num2str(inputs.orgsulfratio)];
end

%% adding and creating paths paths if needed
addpath('plottingCode/');

if strcmp(inputs.outdir,'output/')
    if ~exist('output/gamma')
        mkdir output/gamma
    end
    if ~exist('output/acidvis')
        mkdir output/acidvis
    end
end

end


function [T_limit,pH2O_Tbin,pCLONO2_Tbin,pHCl_Tbin,SAD_Tbin] = readdata(inputs)

%% Read in folder of files
data = readinBfolder([inputs.directory],'*.nc',1);
% need to interpolate over bad data points here.
T2 = data.data.T;
temp = squeeze(T2(9,16,:));
vars = {'HCL','CLONO2','H2O','HOCL','T','SAD_SULFC'};
for i = 1:length(vars)
    
    diff1 = diff(temp);
    badind = find(diff1 < -15)+1;
    for l = 1:length(badind)
        data.data.(vars{i})(:,:,badind(l)) = mean(cat(3,data.data.(vars{i})(:,:,badind(l)-1),data.data.(vars{i})(:,:,badind(l)+1)),3,'omitnan');
        data.data.T(:,:,badind(l)) = mean(cat(3,data.data.T(:,:,badind(l)-1),data.data.T(:,:,badind(l)+1)),3,'omitnan');                
    end

    [dataout.(vars{i}),~,rpres] = calculatePressureAltitudeSE(vars{i},data,1:40);
    
end

[~,presind] = min(abs(rpres - inputs.preslev.*100));
latind = data.data.lat > inputs.lats(1) & data.data.lat < inputs.lats(2);

pH2O = dataout.H2O.regrid .* dataout.H2O.pressureregrid ./ 100;
pH2O_atlevel = squeeze(pH2O(latind,presind,inputs.timeperiod)); % 18.5 km
pHCl = dataout.HCL.regrid .* dataout.HCL.pressureregrid ./ 100 ./ 1013.25;
pHCl_atlevel = squeeze(pHCl(latind,presind,inputs.timeperiod)); % 18.5 km
% HCl_atlevel = squeeze(dataout.HCL.regrid(latind,presind,inputs.timeperiod)); % 18.5 km
pCLONO2 = dataout.CLONO2.regrid .* dataout.CLONO2.pressureregrid ./ 100 ./ 1013.25;
pCLONO2_atlevel = squeeze(pCLONO2(latind,presind,inputs.timeperiod)); % 18.5 km
% CLONO2_atlevel = squeeze(dataout.CLONO2.regrid(latind,presind,inputs.timeperiod)); % 18.5 km
% pHOCL = dataout.HOCL.regrid .* dataout.HOCL.pressureregrid ./ 100 ./ 1013.25;
% pHOCL_atlevel = squeeze(pHOCL(latind,presind,inputs.timeperiod)); % 18.5 km
% HOCL_atlevel = squeeze(dataout.HOCL.regrid(latind,presind,inputs.timeperiod)); % 18.5 km
T_atlevel = squeeze(dataout.T.regrid(latind,presind,inputs.timeperiod)); % 18.5 km
SAD_atlevel = squeeze(dataout.SAD_SULFC.regrid(latind,presind,inputs.timeperiod)); % 18.5 km

% air density (currently not used
ad = squeeze(dataout.H2O.pressureregrid(latind,presind,inputs.timeperiod))./T_atlevel*287.04; %kg/mm2
ad.*1./(inputs.mma.*inputs.avg.*1e3);

%% binning data in 1 debree temperature bins
T_limit = 180:320;

T_atlevel(:,:,28) = NaN;

for i = 1:length(T_limit)
  pH2O_Tbin(i) = mean(pH2O_atlevel(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5),'omitnan');
  pHCl_Tbin(i) = mean(pHCl_atlevel(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5),'omitnan');
  %HCl_Tbin(i) = nanmean(HCl_atlevel(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5));
  pCLONO2_Tbin(i) = mean(pCLONO2_atlevel(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5),'omitnan');
  %CLONO2_Tbin(i) = nanmean(CLONO2_atlevel(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5));
  SAD_Tbin(i) = mean(SAD_atlevel(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5),'omitnan');
  %ad_Tbin(i) = nanmean(ad(T_atlevel > T_limit(i)-.5 & T_atlevel < T_limit(i)+.5));
end

end
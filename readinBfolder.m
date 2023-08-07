function data = readinBfolder(directory,ext,flength)

files = dir([directory,ext]);
wacrun = 0;
switch ext
case '*.nc'
    for i = 1:flength
        [data(i).info,data(i).data,data(i).attributes] = Read_in_netcdf([directory,files(i).name]);
        if isfield(data(i).data,'date')   
            data(i).data.years = CCMI_years(data(i).data.date,wacrun)';      
        elseif isfield(data(i).data,'ccmi_year')   
            data(i).data.years = data(i).data.ccmi_year;      
        elseif isfield(data(i).data,'time')
            data(i).data.date = calculatenetCDFdate(data(i).attributes.time.units,data(i).attributes.time.calendar,data(i).data.time,wacrun);
            data(i).data.years = year(data(i).data.date);
%             if wacrun
%                 data(i).data.years = circshift(data(i).data.years,[0,1]);
%             end
        end           
    end    
end
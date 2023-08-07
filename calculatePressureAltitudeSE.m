function [data2,altgrid,rpres] = calculatePressureAltitudeSE(vartemp,data,altgrid)

    %data is upside down
inputs = 1;
    %% calculate pressure and altitude
    sz = size(data(1).data.(vartemp));
    szint = [sz(1),sz(2)+1,sz(3)];
    hyam = permute(repmat(data(1).data.hyam,1,sz(1),sz(3)),[2,1,3]);
    hybm = permute(repmat(data(1).data.hybm,1,sz(1),sz(3)),[2,1,3]);
    hyai = permute(repmat(data(1).data.hyai,1,szint(1),szint(3)),[2,1,3]);
    hybi = permute(repmat(data(1).data.hybi,1,szint(1),szint(3)),[2,1,3]);
    P0 = repmat(data(1).data.P0,sz);
    P0int = repmat(data(1).data.P0,szint);
    
    hb = 0;
    
    rpres = [1000;825.40417;681.29205;562.34131;464.15887;383.11868;...
        316.22775;261.01572;215.44347;177.82794;146.77992;121.15276;100;...
        82.540421;68.129204;56.234131;46.415890;38.311867;31.622776;26.101572;...
        21.544348;17.782795;14.677993;12.115276;10;8.2540417;6.8129206;...
        5.6234131;4.6415887;3.8311868;3.1622777;2.6101573;2.1544347;...
        1.7782794;1.4677993;1.2115277].*100;
    
    
    for i = 1:length(data)

        data2(i).pressure = hyam .* P0 + hybm .* permute(repmat(data(i).data.PS,1,1,sz(2)),[1,3,2]);        
        
        data2(i).pressureint = hyai .* P0int + hybi .* permute(repmat(data(i).data.PS,1,1,szint(2)),[1,3,2]);        
                
        % hypsometric
        for k = 1:size(data2(i).pressure,2)-1              
            if k == size(data2(i).pressure,2)-1                
                data(i).alt2(:,sz(2),:) = (287.*273./9.81).*log(101325./squeeze(data2(i).pressure(:,k,:)));    
                data(i).alt2(:,k,:) = (287.*squeeze(data(i).data.T(:,k,:))./9.81).*log(squeeze(data2(i).pressure(:,k+1,:))./squeeze(data2(i).pressure(:,k,:)));
            else                
                data(i).alt2(:,k,:) = (287.*squeeze(data(i).data.T(:,k,:)./9.81)).*log(squeeze(data2(i).pressure(:,k+1,:))./squeeze(data2(i).pressure(:,k,:)));
            end
        end
        for k = size(data2(i).pressure,2):-1:1
            if  k == size(data2(i).pressure,2)                
                data2(i).altitude(:,k,:) = data(i).alt2(:,k,:);
            else                
                data2(i).altitude(:,k,:) = data2(i).altitude(:,k+1,:)+data(i).alt2(:,k,:);
            end
        end       
        
        switch vartemp                                    
            case 'k_AEROD3_v'
                data2.(vartemp) = data.data.(vartemp)./data.alt2.*1000;%.*(675/750).^2.27;                                    
        end
        
        %data2(i).conc = vmr2conc(data(i).data.(vartemp),data(i).data.T,data2(i).pressure);   
        k=1.38066e-23;
        data2(i).conc = 1./k*1e-6.*data(i).data.(vartemp).*data2(i).pressure./data(i).data.T;
        
        % calculate Potential Temperature
        data2(i).Pt = data(i).data.T.*(1000./(data2(i).pressure./100)).^.287;
    end
    
    %% interp onto regular pressure grid
    for i = 1:length(data)
        for k = 1:sz(1)              
            data2(i).regPresconcregrid(k,:,:) = intRegPres(squeeze(data2(i).conc(k,:,:)),squeeze(data2(i).pressure(k,:,:)),rpres);                        
            data2(i).regPresregrid(k,:,:) = intRegPres(squeeze(data(i).data.(vartemp)(k,:,:)),squeeze(data2(i).pressure(k,:,:)),rpres);                        
        end
    end
    
    %% interp onto regular altitude grid

    for k = 1:length(data)
        for i = 1:sz(1)
            for j = 1:sz(3)                
                data2(k).regrid(i,:,j) = interp1(squeeze(data2(k).altitude(i,:,j))./1000,squeeze(data(k).data.(vartemp)(i,:,j)),altgrid);
                data2(k).concregrid(i,:,j) = interp1(squeeze(data2(k).altitude(i,:,j))./1000,squeeze(data2(k).conc(i,:,j)),altgrid);
                data2(k).pressureregrid(i,:,j) = exp(interp1(squeeze(data2(k).altitude(i,:,j))./1000,log(squeeze(data2(k).pressure(i,:,j))),altgrid));                                                                    
                data2(k).Tregrid(i,:,j) = exp(interp1(squeeze(data2(k).altitude(i,:,j))./1000,log(squeeze(data(k).data.T(i,:,j))),altgrid));                                                                    
            end
        end
    end
    
    %% interp onto regular potential temperature grid
    ptemp = [300:20:600];
    for k = 1:length(data)
        for i = 1:sz(1)
            for j = 1:sz(3)                
                data2(k).Potregrid(i,:,j) = interp1(squeeze( data2(k).Pt(i,:,j)),squeeze(data(k).data.(vartemp)(i,:,j)),ptemp);
                data2(k).Potconcregrid(i,:,j) = interp1(squeeze( data2(k).Pt(i,:,j)),squeeze(data2(k).conc(i,:,j)),ptemp);
                data2(k).Potpressureregrid(i,:,j) = exp(interp1(squeeze( data2(k).Pt(i,:,j)),log(squeeze(data2(k).pressure(i,:,j))),ptemp));                                                                    
            end
        end
    end
    
end
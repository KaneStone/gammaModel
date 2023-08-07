function [] = savefigure(filedir,filename,pdf,eps,png,meta)

    % pdf, png, and meta are logicals
    % png and meta will produce there own folders
    % meta code is broken at the moment, so always set to 0   
    %% print png
    if png
        if ~exist([filedir,'png'],'file')
            mkdir([filedir,'png'])
        end
        exportgraphics(gcf,[filedir,'png/',filename,'.png']);
    end
    
    %% print pdf
    if pdf
        
        exportgraphics(gcf,[filedir,filename,'.pdf'])
    end

    if eps
        print([filedir,filename,'.eps'],'-depsc','-painters');
        %exportgraphics(gcf,[filedir,filename,'.pdf'])
    end

    %% creating metadata    
    if meta
        if ~exist([filedir,'metadata'],'file')
            mkdir([filedir,'metadata'])
        end
        S = dbstack('-completenames');
        currentdate = datestr(datetime);
        fid = fopen([filedir,'metadata/',filename,'.txt'],'w+');
        fprintf(fid,'%s\n',['Date: ',currentdate]);
        fprintf(fid,'%s\n',['Code filename: ',S(2).file]);

        % get git info
        lastslash = max(strfind(S(2).file,'/'));
        codefiledir = S(2).file(1:lastslash-1);
        cd(codefiledir)
        gitinfo = getGitInfo();

        fprintf(fid,'%s\n',['Git version hash: ',gitinfo.hash]);
        fprintf(fid,'%s\n',['Git version url: ',gitinfo.url]);
        fclose(fid);
    end
end
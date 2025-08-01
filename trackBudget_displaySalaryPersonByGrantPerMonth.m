function trackBudget_displaySalaryPersonByGrantPerMonth( hObject, eventdata )
global reportSalaryPersonByGrant
global personnel
global grants
global tB


nPersonnel = length(personnel);
nGrants = length(grants);
iMonth = reportSalaryPersonByGrant.iMonth;

str = '';

for iP = 1:nPersonnel
    
    if personnel(iP).primaryList == 1
        sName = personnel(iP).name;
        
        for iG = 1:nGrants
            
            if grants(iG).active == 1
                sGrant = sprintf("%s - %s", grants(iG).name, grants(iG).acct_number);
                
                for iM = iMonth:(iMonth+11)

                    if mod(iM,12)>0
                        sMMYY = sprintf( '%02d/1/%02d',mod(iM,12),floor(iM/12) );
                    else
                        sMMYY = sprintf( '12/1/%02d',floor(iM/12) );
                    end
                    sBase = sprintf( '%d',personnel(iP).salary_base(iM) );
                    sPaid = sprintf( '%.0f',personnel(iP).salaryByGrant(iG,iM)/12 );
                    sEffort = sprintf( '%0.0f%%', 100*personnel(iP).salaryByGrant(iG,iM)/personnel(iP).salary_base(iM) );

                    foos = sprintf('%s\t%s\t%s\t%s\t%s\t%s',sMMYY,sName,sBase,sGrant,sPaid,sEffort);
                    str = sprintf( '%s%s\n',str,foos );
                    
                end
            
            end
        end
        
    end
end

clipboard('copy',str);

disp( 'Paste to Google Sheet ''Next 12 Detail''. Make sure you clear old sheet data first.' )

% 
% 
% 
% 
% if ~isempty(hObject)
%     if strcmp(get(hObject,'string'),'>') 
%         reportSalaryPersonByGrant.iMonth = reportSalaryPersonByGrant.iMonth + 1;
%     elseif strcmp(get(hObject,'string'),'<') & reportSalaryPersonByGrant.iMonth>1
%         reportSalaryPersonByGrant.iMonth = reportSalaryPersonByGrant.iMonth - 1;
%     end
% end
% 
% 
% 
% 
% rnames = {};
% 
% cnames = {};
% cwid = {150};
% 
% 
% lstGrants = [];
% for ii=1:length(grants)
%     if grants(ii).active==1
%         lstGrants(end+1) = ii;
%     end
% end
% 
% d1 = {};
% personSum = zeros(length(personnel),1);
% 
% for iGrant = 1:length(lstGrants)
%     idxGrant = lstGrants(iGrant);
%     
%     % set to grant name
%     cnames{end+1} = sprintf('%s', grants(idxGrant).name);
%     cwid{end+1} = 75;
% 
%     foos = datestr(now,'mm/yy');
%     iM = str2num(foos(1:2));
%     iY = str2num(foos(4:5));
% 
%     iYg = str2num( grants(idxGrant).date_start((end-1):end) );
%     iMg = str2num( grants(idxGrant).date_start(1:2) );
%     iYgbpe = str2num( grants(idxGrant).date_end_budget_period((end-1):end) );
%     iMgbpe = str2num( grants(idxGrant).date_end_budget_period(1:2) );
%     iYge = str2num( grants(idxGrant).date_end_grant((end-1):end) );
%     iMge = str2num( grants(idxGrant).date_end_grant(1:2) );
% 
%     for iPerson = 1:length(grants(idxGrant).personnel)
%         idxPerson = grants(idxGrant).personnel(iPerson).nameIdx;
%         rnames{idxPerson} = personnel(idxPerson).name;    
%         if (reportSalaryPersonByGrant.iMonth-iYg*12-iMg+2) <= length(grants(idxGrant).personnel(iPerson).committed_salary_monthly)
%             d1{idxPerson,iGrant} = sprintf( '$%d', grants(idxGrant).personnel(iPerson).committed_salary_monthly(reportSalaryPersonByGrant.iMonth-iYg*12-iMg+2) );
%             personSum(idxPerson) = personSum(idxPerson) + grants(idxGrant).personnel(iPerson).committed_salary_monthly(reportSalaryPersonByGrant.iMonth-iYg*12-iMg+2);
%         else
%             d1{idxPerson,iGrant} = '';
%         end
%     end
% 
% end % grant loop
% 
% cnames{end+1} = 'Total Paid';
% cnames{end+1} = 'Total Expected';
% for idxPerson = 1:length(personnel)
%     d1{idxPerson,length(lstGrants)+1} = sprintf( '$%d', personSum(idxPerson) );
%     d1{idxPerson,length(lstGrants)+2} = sprintf( '$%d', personnel(idxPerson).salary_covered(reportSalaryPersonByGrant.iMonth+1) );
% end
% 
% 
% 
% % DISPLAY TABLE
% % Create the column and row names in cell arrays 
% 
% f = figure(20);
% if isempty(hObject)
%     clf
%     set(f,'Position',[44   400   869   147]);
%     set(f,'menubar','none')
%     set(f,'name', 'Grant Salaries by Month' )
%     set(f,'numbertitle','off')
%     set(f,'toolbar','figure')
% 
%     % Create the uitable
%     t = uitable(f,'Data',d1,...
%         'ColumnName',cnames,...
%         'RowName',rnames,...
%         'ColumnWidth',cwid);
%     
%     % Set width and height
%     t.Position(3) = t.Extent(3);
%     t.Position(4) = t.Extent(4);
%     
%     reportSalaryPersonByGrant.t = t;
%     
%     f.Position(3) = t.Extent(3) + 40;
%     f.Position(4) = t.Extent(4) + 80;
%     
%     b1 = uicontrol( 'style', 'pushbutton', 'string','<', 'position', [20 t.Extent(4)+40 30 30], 'callback', @trackBudget_displaySalaryPersonByGrantPerMonth );
%     b2 = uicontrol( 'style', 'pushbutton', 'string','>', 'position', [60 t.Extent(4)+40 30 30], 'callback', @trackBudget_displaySalaryPersonByGrantPerMonth );
%     
%     foos = sprintf( 'Month/Year  -  %02d/%02d',mod(reportSalaryPersonByGrant.iMonth,12)+1,floor(reportSalaryPersonByGrant.iMonth/12));
%     hGrant = uicontrol( 'style','text','string',foos,'position',[100 t.Extent(4)+40 200 30]);
%     reportSalaryPersonByGrant.hGrant = hGrant
% else
%     reportSalaryPersonByGrant.t.Data = d1;
%     set(reportSalaryPersonByGrant.t,'ColumnName',cnames)
%     
%     foos = sprintf( 'Month/Year  -  %02d/%02d',mod(reportSalaryPersonByGrant.iMonth,12)+1,floor(reportSalaryPersonByGrant.iMonth/12));
%     set(reportSalaryPersonByGrant.hGrant,'string',foos);
% end
% 
% 
% 
% % copy to clipboard
% size_d = size(d1);
% foos = sprintf( '%02d/1/%04d',mod(reportSalaryPersonByGrant.iMonth,12)+1,2000+floor(reportSalaryPersonByGrant.iMonth/12));
% str = sprintf('%s\t', foos);
% for i=1:length(cnames);str = sprintf('%s%s\t',str,cnames{i});end
% str = sprintf('%s\n',str);
% for i = 1:size_d(1)
%     str = sprintf('%s%s\t',str,rnames{i});
%     for j = 1:size_d(2)
%         if j == size_d(2)
%             str = sprintf('%s%s',str,d1{i,j});
%         else
%             str = sprintf('%s%s\t',str,d1{i,j});
%         end
%     end
%     str = sprintf('%s\n',str);
% end
% clipboard('copy',str);




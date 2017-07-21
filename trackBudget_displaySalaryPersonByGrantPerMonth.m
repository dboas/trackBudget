function trackBudget_displaySalaryPersonByGrantPerMonth( hObject, eventdata )
global reportSalaryPersonByGrant
global personnel
global grants
global tB


% if ~isempty(hObject)
%     if strcmp(get(hObject,'string'),'>') & reportMonthlySalary.iMonth<(length(grants(idxGrant).personnel(1).committed_salary_monthly)-12)
%         reportMonthlySalary.iMonth = reportMonthlySalary.iMonth + 1;
%     elseif strcmp(get(hObject,'string'),'<') & reportMonthlySalary.iMonth>1
%         reportMonthlySalary.iMonth = reportMonthlySalary.iMonth - 1;
%     end
% end




rnames = {};

cnames = {};
cwid = {150};


lstGrants = [];
for ii=1:length(grants)
    if grants(ii).active==1
        lstGrants(end+1) = ii;
    end
end

d1 = {};


for iGrant = 1:length(lstGrants)
    idxGrant = lstGrants(iGrant);
    
    % set to grant name
    cnames{end+1} = sprintf('%s', grants(idxGrant).name);
    cwid{end+1} = 75;

    foos = datestr(now,'mm/yy');
    iM = str2num(foos(1:2));
    iY = str2num(foos(4:5));

    iYg = str2num( grants(idxGrant).date_start((end-1):end) );
    iMg = str2num( grants(idxGrant).date_start(1:2) );
    iYgbpe = str2num( grants(idxGrant).date_end_budget_period((end-1):end) );
    iMgbpe = str2num( grants(idxGrant).date_end_budget_period(1:2) );
    iYge = str2num( grants(idxGrant).date_end_grant((end-1):end) );
    iMge = str2num( grants(idxGrant).date_end_grant(1:2) );

    for iPerson = 1:length(grants(idxGrant).personnel)
        idxPerson = grants(idxGrant).personnel(iPerson).nameIdx;
        rnames{idxPerson} = personnel(idxPerson).name;    
        d1{idxPerson,iGrant} = sprintf( '$%d', grants(idxGrant).personnel(iPerson).committed_salary_monthly(reportSalaryPersonByGrant.iMonth-iYg*12-iMg) );
    end

end % grant loop


% DISPLAY TABLE
% Create the column and row names in cell arrays 

f = figure(20);
if isempty(hObject)
    clf
    set(f,'Position',[44   400   869   147]);
    set(f,'menubar','none')
    set(f,'name', 'Grant Salaries by Month' )
    set(f,'numbertitle','off')
    set(f,'toolbar','figure')

    % Create the uitable
    t = uitable(f,'Data',d1,...
        'ColumnName',cnames,...
        'RowName',rnames,...
        'ColumnWidth',cwid);
    
    % Set width and height
    t.Position(3) = t.Extent(3);
    t.Position(4) = t.Extent(4);
    
    reportSalaryPersonByGrant.t = t;
    
    f.Position(3) = t.Extent(3) + 40;
    f.Position(4) = t.Extent(4) + 80;
    
    b1 = uicontrol( 'style', 'pushbutton', 'string','<', 'position', [20 t.Extent(4)+40 30 30], 'callback', @trackBudget_displaySalaryPersonByGrantPerMonth );
    b2 = uicontrol( 'style', 'pushbutton', 'string','>', 'position', [60 t.Extent(4)+40 30 30], 'callback', @trackBudget_displaySalaryPersonByGrantPerMonth );
    
    foos = sprintf( '%s  -  Start %02d/%02d  -  End %02d/%02d',grants(idxGrant).name, iMg, iYg, iMge, iYge);
    hGrant = uicontrol( 'style','text','string',foos,'position',[100 t.Extent(4)+40 200 30]);
    reportSalaryPersonByGrant.hGrant = hGrant;
else
    reportSalaryPersonByGrant.t.Data = d1;
    set(reportSalaryPersonByGrant.t,'ColumnName',cnames)
end



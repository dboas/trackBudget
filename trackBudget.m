function varargout = trackBudget(varargin)
% TRACKBUDGET MATLAB code for trackBudget.fig
%      TRACKBUDGET, by itself, creates a new TRACKBUDGET or raises the existing
%      singleton*.
%
%      H = TRACKBUDGET returns the handle to a new TRACKBUDGET or the handle to
%      the existing singleton*.
%
%      TRACKBUDGET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBUDGET.M with the given input arguments.
%
%      TRACKBUDGET('Property','Value',...) creates a new TRACKBUDGET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBudget_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBudget_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBudget

% Last Modified by GUIDE v2.5 10-Jul-2016 14:35:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBudget_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBudget_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trackBudget is made visible.
function trackBudget_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBudget (see VARARGIN)

% Choose default command line output for trackBudget
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

menuNewBudget_Callback(hObject, 1, handles)
menuLoadBudget_Callback(hObject, eventdata, handles)




% --- Outputs from this function are returned to the command line.
function varargout = trackBudget_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenuGrantName.
function popupmenuGrantName_Callback(hObject, eventdata, handles)
global tB

tB.idxGrant = tB.sortGrantList( get(hObject,'value') );

iY = str2num(datestr(now,'yy'));
iM = str2num(datestr(now,'mm'));
tB.idxMonthCurrent = iY*12 + iM;

updateGrants( handles );
updateProjectedBudgetBalance( handles );


% --- Executes on selection change in popupmenuPersonName.
function popupmenuPersonName_Callback(hObject, eventdata, handles)
global tB

tB.idxPeople = tB.sortPeopleList( get(hObject,'value') );
updatePeople( handles );



function editGrantAcctNum_Callback(hObject, eventdata, handles)
global tB
global grants

grants(tB.idxGrant).acct_number = get(hObject,'string');
updateSaveFileFlag( handles )


function editGrantAgency_Callback(hObject, eventdata, handles)
global tB
global grants

grants(tB.idxGrant).funding_agency = get(hObject,'string');
updateSaveFileFlag( handles )


function editGrantNumber_Callback(hObject, eventdata, handles)
global tB
global grants

grants(tB.idxGrant).grant_number = get(hObject,'string');
updateSaveFileFlag( handles )


function editGrantStartDate_Callback(hObject, eventdata, handles)
global tB
global grants

iYg_o = str2num( grants(tB.idxGrant).date_start((end-1):end) );
iMg_o = str2num( grants(tB.idxGrant).date_start(1:2) );

foos = datestr(datenum(get(hObject,'string'),'mm/dd/yy'),'mm/dd/yy');
set(hObject,'string',foos)
grants(tB.idxGrant).date_start = foos;

iYg = str2num( grants(tB.idxGrant).date_start((end-1):end) );
iMg = str2num( grants(tB.idxGrant).date_start(1:2) );
iYge = str2num( grants(tB.idxGrant).date_end_grant((end-1):end) );
iMge = str2num( grants(tB.idxGrant).date_end_grant(1:2) );
nMonthsInGrant = (iYge-iYg)*12 + (iMge-iMg+1);
nMonthsInGrant_o = (iYge-iYg_o)*12 + (iMge-iMg_o+1);

for iP = 1:length(grants(tB.idxGrant).personnel)
    if nMonthsInGrant > nMonthsInGrant_o
        foo = grants(tB.idxGrant).personnel(iP).committed_salary_monthly(:);
        grants(tB.idxGrant).personnel(iP).committed_salary_monthly = [zeros(nMonthsInGrant-nMonthsInGrant_o,1); foo];
        foo = grants(tB.idxGrant).personnel(iP).targetEffort(:);
        grants(tB.idxGrant).personnel(iP).targetEffort = [zeros(nMonthsInGrant-nMonthsInGrant_o,1); foo];
        foo = grants(tB.idxGrant).personnel(iP).currentEffort(:);
        grants(tB.idxGrant).personnel(iP).currentEffort = [zeros(nMonthsInGrant-nMonthsInGrant_o,1); foo];
    else
        grants(tB.idxGrant).personnel(iP).committed_salary_monthly( 1:(nMonthsInGrant_o-nMonthsInGrant) ) = [];
        grants(tB.idxGrant).personnel(iP).targetEffort( 1:(nMonthsInGrant_o-nMonthsInGrant) ) = [];
        grants(tB.idxGrant).personnel(iP).currentEffort( 1:(nMonthsInGrant_o-nMonthsInGrant) ) = [];
    end
end

if nMonthsInGrant > nMonthsInGrant_o
    foo = grants(tB.idxGrant).notesByMonth;
    grants(tB.idxGrant).notesByMonth  = cell(nMonthsInGrant,1);
    for ii = 1:nMonthsInGrant; grants(tB.idxGrant).notesByMonth{ii} = ''; end
    jj = 0;
    for ii = (nMonthsInGrant-nMonthsInGrant_o+1):nMonthsInGrant
        jj = jj + 1;
        grants(tB.idxGrant).notesByMonth{ii} = foo{jj};
    end
else
    foo = grants(tB.idxGrant).notesByMonth;
    grants(tB.idxGrant).notesByMonth  = cell(nMonthsInGrant,1);
    for ii = 1:nMonthsInGrant; grants(tB.idxGrant).notesByMonth{ii} = foo{ii+nMonthsInGrant_o-nMonthsInGrant}; end
end

updateGrantPersonnel( handles )
updateSaveFileFlag( handles )


function editGrantEndDate_Callback(hObject, eventdata, handles)
global tB
global grants

iYge_o = str2num( grants(tB.idxGrant).date_end_grant((end-1):end) );
iMge_o = str2num( grants(tB.idxGrant).date_end_grant(1:2) );

foos = datestr(datenum(get(hObject,'string'),'mm/dd/yy'),'mm/dd/yy');
set(hObject,'string',foos)
grants(tB.idxGrant).date_end_grant = foos;

iYg = str2num( grants(tB.idxGrant).date_start((end-1):end) );
iMg = str2num( grants(tB.idxGrant).date_start(1:2) );
iYge = str2num( grants(tB.idxGrant).date_end_grant((end-1):end) );
iMge = str2num( grants(tB.idxGrant).date_end_grant(1:2) );
nMonthsInGrant = (iYge-iYg)*12 + (iMge-iMg+1);
nMonthsInGrant_o = (iYge_o-iYg)*12 + (iMge_o-iMg+1);

for iP = 1:length(grants(tB.idxGrant).personnel)
    if nMonthsInGrant > nMonthsInGrant_o
        grants(tB.idxGrant).personnel(iP).committed_salary_monthly( (nMonthsInGrant_o+1):nMonthsInGrant ) = 0;
        grants(tB.idxGrant).personnel(iP).targetEffort( (nMonthsInGrant_o+1):nMonthsInGrant ) = 0;
        grants(tB.idxGrant).personnel(iP).currentEffort( (nMonthsInGrant_o+1):nMonthsInGrant ) = 0;
    else
        grants(tB.idxGrant).personnel(iP).committed_salary_monthly( (nMonthsInGrant+1):end ) = [];
        grants(tB.idxGrant).personnel(iP).targetEffort( (nMonthsInGrant+1):end ) = [];
        grants(tB.idxGrant).personnel(iP).currentEffort( (nMonthsInGrant+1):end ) = [];
    end
end

if nMonthsInGrant > nMonthsInGrant_o
    for ii=(nMonthsInGrant_o+1):nMonthsInGrant; grants(tB.idxGrant).notesByMonth{ii}=''; end
else
    foo = grants(tB.idxGrant).notesByMonth;
    grants(tB.idxGrant).notesByMonth = cell( nMonthsInGrant, 1);
    for ii=1:nMonthsInGrant; grants(tB.idxGrant).notesByMonth{ii} = foo{ii}; end
end

updateGrantPersonnel( handles )
updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles )


function editGrantPeriodEndDate_Callback(hObject, eventdata, handles)
global tB
global grants

foos = datestr(datenum(get(hObject,'string'),'mm/dd/yy'),'mm/dd/yy');
set(hObject,'string',foos)
grants(tB.idxGrant).date_end_budget_period = foos;
updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles )





% --------------------------------------------------------------------
% MENU ITEMS
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function menuNewBudget_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

if isempty(eventdata)
    eventdata = 0;
end

if eventdata == 0
    ch = menu('Create a new Budget?','Yes','No');
    if ch==2
        return
    end
end

grants = [];
personnel = [];
tB.nGrants = 0;
tB.idxGrant = 0;
tB.nPeople = 0;
tB.idxPeople = 0;

foos = datestr(now,'mm/yy');
iM = str2num(foos(1:2));
iY = str2num(foos(4:5));
tB.idxMonthCurrent = iY*12 + iM;
tB.idxMonthAxes = iY*12 + iM;

tB.pathnm = '';
tB.filenm = '';

foos = {''};
set(handles.popupmenuGrantName,'string',foos);
set(handles.popupmenuGrantPI,'string',foos);
set(handles.popupmenuPersonName,'string',foos);

updateGrants( handles );
updatePeople( handles );



% --------------------------------------------------------------------
function menuLoadBudget_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

[filenm, pathnm] = uigetfile('*.mat','Pick Budget to Load');
if filenm==0
    return
end

load([pathnm filenm]);
tB.pathnm = pathnm;
tB.filenm = filenm;


% update people
nPeople = length(personnel);

% fix personnel structure if needed
for ii=1:nPeople
    if ~isfield(personnel,'primaryList')
        personnel(ii).primaryList = 1;
    elseif isempty(personnel(ii).primaryList)
        personnel(ii).primaryList = 1;
    end
    
    for jj=1:length(personnel(ii).update)
        if ~isfield(personnel(ii).update(jj),'Desc')
            personnel(ii).update(jj).Desc = '';
        end
    end
end

% load people popup menu
if ~isfield(tB,'idxPeople')
    tB.idxPeople = 1;
end
sortPeopleList( handles )

tB.nPeople = nPeople;
updatePeople( handles );

set(handles.figure1,'name', sprintf('trackBudget - %s',tB.filenm) )


% update grants
nGrants = length(grants);

% fix grant structure if needed
for ii=1:nGrants
    if ~isfield(grants,'idxPI')
        grants(ii).idxPI = 1;
    elseif grants(ii).idxPI<1 | grants(ii).idxPI>nPeople
        grants(ii).idxPI = 1;
    elseif isempty(grants(ii).idxPI)
        grants(ii).idxPI = 1;
    end
    
    if ~isfield(grants,'overheadRate')
        grants(ii).overheadRate = 0.74;
    elseif isempty(grants(ii).overheadRate)
        grants(ii).overheadRate = 0.74;
    end
    
    if ~isfield(grants,'active')
        grants(ii).active = 1;
    elseif isempty(grants(ii).active)
        grants(ii).active = 1;
    end
    
    if ~isfield(grants,'notesByMonth')
        nMonths = length( grants(ii).personnel(1).committed_salary_monthly );
        grants(ii).notesByMonth = cell(nMonths,1);
    elseif isempty( grants(ii).notesByMonth )
        nMonths = length( grants(ii).personnel(1).committed_salary_monthly );
        grants(ii).notesByMonth = cell(nMonths,1);        
    end
    
    if ~isfield(grants,'personnelRange')
        grants(ii).personnelRange = [1 7];
    elseif isempty(grants(ii).personnelRange)
        grants(ii).personnelRange = [1 7];
    end
    
%     if ~isfield(grants(ii).personnel,'keyPersonnel')
%         nMonths = length( grants(ii).personnel(1).committed_salary_monthly );
%         for jj=1:length( grants(ii).personnel)
%             grants(ii).personnel(jj).keyPersonnel = 0;
%             grants(ii).personnel(jj).targetEffort = zeros(nMonths,1);
%             grants(ii).personnel(jj).currentEffort = zeros(nMonths,1);
%         end
%     elseif isempty(grants(ii).personnel(1).keyPersonnel)
%         nMonths = length( grants(ii).personnel(1).committed_salary_monthly );
%         for jj=1:length( grants(ii).personnel)
%             grants(ii).personnel(jj).keyPersonnel = 0;
%             grants(ii).personnel(jj).targetEffort = zeros(nMonths,1);
%             grants(ii).personnel(jj).currentEffort = zeros(nMonths,1);
%         end        
%     end
    
%     if ~isfield(grants(ii).budget(1),'notes')
%         nUpdates = length(grants(ii).budget);
%         for jj=1:nUpdates
%             grants(ii).budget(jj).notes = '';
%         end
%     elseif isempty(grants(ii).budget(1).notes)
%         nUpdates = length(grants(ii).budget);
%         for jj=1:nUpdates
%             grants(ii).budget(jj).notes = '';
%         end
%     end

    for iGrant = 1:length(grants)
        iYg = str2num( grants(iGrant).date_start((end-1):end) );
        iMg = str2num( grants(iGrant).date_start(1:2) );
        iYge = str2num( grants(iGrant).date_end_grant((end-1):end) );
        iMge = str2num( grants(iGrant).date_end_grant(1:2) );
        nMonthsInGrant = (iYge-iYg)*12 + (iMge-iMg+1);
        
        if length(grants(iGrant).notesByMonth)<nMonthsInGrant
            for jj=(length(grants(iGrant).notesByMonth)+1):nMonthsInGrant
                grants(iGrant).notesByMonth{jj} = '';
            end
        end
        
        for iPerson = 1:length(grants(iGrant).personnel)
            if length(grants(iGrant).personnel(iPerson).committed_salary_monthly)>nMonthsInGrant
                grants(iGrant).personnel(iPerson).committed_salary_monthly = grants(iGrant).personnel(iPerson).committed_salary_monthly(1:nMonthsInGrant);
            end
        end
        
    end

end

% load grants popup menu
if ~isfield(tB,'idxGrant')
    tB.idxGrant = 1;
end
sortGrantList( handles )

tB.nGrants = nGrants;
updateGrants( handles );
updateGrantPersonnel( handles );


% update projected grant budget
updateProjectedBudgetBalance( handles );




% --------------------------------------------------------------------
function menuSaveBudget_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

if isempty(tB.filenm)
    menuSaveBudgetAs_Callback(hObject, eventdata, handles);
else
    save([tB.pathnm tB.filenm],'grants','personnel','tB');
    set(handles.figure1,'name', sprintf('trackBudget - %s',tB.filenm) )
end


% --------------------------------------------------------------------
function menuSaveBudgetAs_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

filenm = '';
if isfield(tB,'filenm')
    filenm = tB.filenm;
end

[filenm, pathnm] = uiputfile('*.mat','Save budget', filenm);
if filenm==0
    return
end

save([pathnm filenm],'grants','personnel','tB');
tB.pathnm = pathnm;
tB.filenm = filenm;

set(handles.figure1,'name', sprintf('trackBudget - %s',tB.filenm) )



% --------------------------------------------------------------------
function menuGrantNew_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

prompt = {'Enter grant name:','Account Number','Funding Agency','Grant Number','Start Date','End Date','Period End Date','Overhead Rate'};
dlg_title = 'New Grant';
num_lines = 1;
def = {'','','','','','','',''};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end

tB.nGrants = tB.nGrants + 1;
grants(tB.nGrants).name = answer{1};

grants(tB.nGrants).acct_number = answer{2};
grants(tB.nGrants).funding_agency = answer{3};
grants(tB.nGrants).grant_number = answer{4};
grants(tB.nGrants).date_start = datestr(datenum(answer{5},'mm/dd/yy'),'mm/dd/yy');
grants(tB.nGrants).date_end_grant = datestr(datenum(answer{6},'mm/dd/yy'),'mm/dd/yy');
grants(tB.nGrants).date_end_budget_period = datestr(datenum(answer{7},'mm/dd/yy'),'mm/dd/yy');
grants(tB.nGrants).overheadRate = myStr2num( answer{8} );
grants(tB.nGrants).idxPI = 1;
grants(tB.nGrants).personnelRange = [1 7];
grants(tB.nGrants).active = 1;

% grants(tB.nGrants).budget(1).notes = '';

iYg = str2num( grants(tB.nGrants).date_start((end-1):end) );
iMg = str2num( grants(tB.nGrants).date_start(1:2) );
iYge = str2num( grants(tB.nGrants).date_end_grant((end-1):end) );
iMge = str2num( grants(tB.nGrants).date_end_grant(1:2) );
nMonthsInGrant = (iYge-iYg)*12 + (iMge-iMg+1);
grants(tB.nGrants).notesByMonth = cell(nMonthsInGrant,1);

tB.idxGrant = tB.nGrants;
sortGrantList( handles );
updateGrants( handles );
updateProjectedBudgetBalance( handles )

% whenever i add a grant, i need to add a row of zeros for each person to
%    personnel(tB.idxPeople).salaryByGrant
for ii=1:tB.nPeople
    personnel(ii).salaryByGrant(tB.nGrants,:) = 0;
end

updateSaveFileFlag( handles );



% --------------------------------------------------------------------
function menuPersonNew_Callback(hObject, eventdata, handles)
global tB
global personnel

formatOut = 'mm/dd/yy';

prompt = {'Name:','Date:','Base Salary:','Fringe Rate:','Salary Covered'};
dlg_title = 'New Person';
num_lines = 1;
def = {'', datestr(now,formatOut), '0', '0.35', '0' };
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end

tB.nPeople = tB.nPeople + 1;
tB.idxPeople = tB.nPeople;

personnel(tB.idxPeople).name = answer{1};
personnel(tB.idxPeople).update(1).date = answer{2};
personnel(tB.idxPeople).update(1).salary_base = myStr2num(answer{3});
personnel(tB.idxPeople).update(1).fringe_rate = myStr2num(answer{4});
personnel(tB.idxPeople).update(1).salary_covered = myStr2num(answer{5});
personnel(tB.idxPeople).update(1).Desc = '';
personnel(tB.idxPeople).idxUpdate = 1;
personnel(tB.idxPeople).primaryList = 1;

personnel(tB.idxPeople).salaryByGrant = zeros(tB.nGrants,50*12);

personnel(tB.idxPeople).salary_base = zeros(1,50*12);
personnel(tB.idxPeople).fringe_rate = zeros(1,50*12);
personnel(tB.idxPeople).salary_covered = zeros(1,50*12);

dateNew = datenum(answer{2},'mm/dd/yy');
iY = str2num(datestr(dateNew,'yy'));
iM = str2num(datestr(dateNew,'mm'));
personnel(tB.idxPeople).salary_base((iY*12+iM):end) = myStr2num(answer{3});
personnel(tB.idxPeople).fringe_rate((iY*12+iM):end) = myStr2num(answer{4});
personnel(tB.idxPeople).salary_covered((iY*12+iM):end) = myStr2num(answer{5});

sortPeopleList( handles );

updatePeople( handles );

updateSaveFileFlag( handles );




% handle string numebrs that might have commas
function val = myStr2num( foos )
foos2 = '';
jj = 1;
for ii=1:length(foos)
    if ~isempty(str2num(foos(ii))) || foos(ii)=='.' || foos(ii)=='-'
        foos2(jj) = foos(ii);
        jj = jj + 1;
    end
end
val = str2num(foos2);






function updateGrants( handles )
global tB
global grants

if tB.idxGrant>0    
    set(handles.editGrantAcctNum,'string',grants(tB.idxGrant).acct_number)
    set(handles.editGrantAgency,'string',grants(tB.idxGrant).funding_agency)
    set(handles.editGrantNumber,'string',grants(tB.idxGrant).grant_number)
    set(handles.editGrantOverheadRate,'string',num2str(grants(tB.idxGrant).overheadRate))
    set(handles.editGrantStartDate,'string',grants(tB.idxGrant).date_start)
    set(handles.editGrantEndDate,'string',grants(tB.idxGrant).date_end_grant)
    set(handles.editGrantPeriodEndDate,'string',grants(tB.idxGrant).date_end_budget_period)
    set(handles.checkboxGrantActive,'value',grants(tB.idxGrant).active)
    
    foos = get(handles.popupmenuPersonName,'string');
    set(handles.popupmenuGrantPI,'string',foos);
    set(handles.popupmenuGrantPI,'value', grants(tB.idxGrant).idxPI );

    for ii=1:3
        eval( sprintf('set(handles.editEncumberanceDate%d,''string'','''')',ii) )
        eval( sprintf('set(handles.editEncumberanceAmountDirect%d,''string'','''')',ii) )
        eval( sprintf('set(handles.editEncumberanceAmountTotal%d,''string'','''')',ii) )
        eval( sprintf('set(handles.editEncumberanceDesc%d,''string'','''')',ii) )
        
        eval( sprintf('set(handles.editEncumberanceDate%d,''enable'',''off'')',ii) )
        eval( sprintf('set(handles.editEncumberanceAmountDirect%d,''enable'',''off'')',ii) )
        eval( sprintf('set(handles.editEncumberanceAmountTotal%d,''enable'',''off'')',ii) )
        eval( sprintf('set(handles.editEncumberanceDesc%d,''enable'',''off'')',ii) )
        
        eval( sprintf('set(handles.editIncomeDate%d,''string'','''')',ii) )
        eval( sprintf('set(handles.editIncomeAmountDirect%d,''string'','''')',ii) )
        eval( sprintf('set(handles.editIncomeAmountTotal%d,''string'','''')',ii) )
        eval( sprintf('set(handles.editIncomeDesc%d,''string'','''')',ii) )
        
        eval( sprintf('set(handles.editIncomeDate%d,''enable'',''off'')',ii) )
        eval( sprintf('set(handles.editIncomeAmountDirect%d,''enable'',''off'')',ii) )
        eval( sprintf('set(handles.editIncomeAmountTotal%d,''enable'',''off'')',ii) )
        eval( sprintf('set(handles.editIncomeDesc%d,''enable'',''off'')',ii) )
    end
    
    if ~isempty( grants(tB.idxGrant).budget )
        set(handles.editBudgetUpdateNotes,'string', grants(tB.idxGrant).budget(end).notes )

        % encumberances
        for ii=1:3
%             eval( sprintf('set(handles.editEncumberanceDate%d,''string'','''')',ii) )
%             eval( sprintf('set(handles.editEncumberanceAmountDirect%d,''string'','''')',ii) )
%             eval( sprintf('set(handles.editEncumberanceAmountTotal%d,''string'','''')',ii) )
%             eval( sprintf('set(handles.editEncumberanceDesc%d,''string'','''')',ii) )
            
            eval( sprintf('set(handles.editEncumberanceDate%d,''enable'',''on'')',ii) )
            eval( sprintf('set(handles.editEncumberanceAmountDirect%d,''enable'',''on'')',ii) )
            eval( sprintf('set(handles.editEncumberanceAmountTotal%d,''enable'',''on'')',ii) )
            eval( sprintf('set(handles.editEncumberanceDesc%d,''enable'',''on'')',ii) )
        end
        if isfield(grants(tB.idxGrant).budget(end),'encumbered_non_salary')
            for ii=1:3
                eval( sprintf('set(handles.editEncumberanceDate%d,''string'',''%s'')',ii,...
                    grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).date ) )
                eval( sprintf('set(handles.editEncumberanceAmountDirect%d,''string'',''%s'')',ii,...
                    num2str(grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).amountDirect) ) )
                eval( sprintf('set(handles.editEncumberanceAmountTotal%d,''string'',''%s'')',ii,...
                    num2str(grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).amountTotal) ) )
                eval( sprintf('set(handles.editEncumberanceDesc%d,''string'',grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).description)', ii) );  
            end
        else
            % initialize encumbered_non_salary
            for ii=1:3
                grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).date = '';
                grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).amountDirect = 0;
                grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).amountTotal = 0;
                grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).description = '';
            end            
        end
        
        % income
        for ii=1:3
%             eval( sprintf('set(handles.editIncomeDate%d,''string'','''')',ii) )
%             eval( sprintf('set(handles.editIncomeAmountDirect%d,''string'','''')',ii) )
%             eval( sprintf('set(handles.editIncomeAmountTotal%d,''string'','''')',ii) )
%             eval( sprintf('set(handles.editIncomeDesc%d,''string'','''')',ii) )
            
            eval( sprintf('set(handles.editIncomeDate%d,''enable'',''on'')',ii) )
            eval( sprintf('set(handles.editIncomeAmountDirect%d,''enable'',''on'')',ii) )
            eval( sprintf('set(handles.editIncomeAmountTotal%d,''enable'',''on'')',ii) )
            eval( sprintf('set(handles.editIncomeDesc%d,''enable'',''on'')',ii) )
        end
        if isfield(grants(tB.idxGrant).budget(end),'income')
            for ii=1:3
                eval( sprintf('set(handles.editIncomeDate%d,''string'',''%s'')',ii,...
                    grants(tB.idxGrant).budget(end).income(ii).date ) )
                eval( sprintf('set(handles.editIncomeAmountDirect%d,''string'',''%s'')',ii,...
                    num2str(grants(tB.idxGrant).budget(end).income(ii).amountDirect) ) )
                eval( sprintf('set(handles.editIncomeAmountTotal%d,''string'',''%s'')',ii,...
                    num2str(grants(tB.idxGrant).budget(end).income(ii).amountTotal) ) )
                eval( sprintf('set(handles.editIncomeDesc%d,''string'',grants(tB.idxGrant).budget(end).income(ii).description)', ii) );  
            end
        else
            % initialize income
            for ii=1:3
                grants(tB.idxGrant).budget(end).income(ii).date = '';
                grants(tB.idxGrant).budget(end).income(ii).amountDirect = 0;
                grants(tB.idxGrant).budget(end).income(ii).amountTotal = 0;
                grants(tB.idxGrant).budget(end).income(ii).description = '';
            end            
        end
        
    end
else
    set(handles.editGrantAcctNum,'string','')
    set(handles.editGrantAgency,'string','')
    set(handles.editGrantNumber,'string','')
    set(handles.editGrantOverheadRate,'string','')
    set(handles.editGrantStartDate,'string','')
    set(handles.editGrantEndDate,'string','')
    set(handles.editGrantPeriodEndDate,'string','')
    set(handles.editBudgetUpdateNotes,'string','') 
    
end

updateGrantPersonnel( handles )





function updateGrantPersonnel( handles );
global tB
global grants
global personnel

for ii=1:7
    eval( sprintf('set(handles.editPersonnel%d,''string'','''');',ii) );
    eval( sprintf('set(handles.editPersonnelBase%d,''string'','''');',ii) );
    eval( sprintf('set(handles.editPersonnelSalaryCommit%d,''string'','''');',ii) );
    eval( sprintf('set(handles.editPersonnelTargetEffort%d,''string'','''');',ii) );
    eval( sprintf('set(handles.editPersonnelCurrentEffort%d,''string'','''');',ii) );
    eval( sprintf('set(handles.checkboxPersonnelKey%d,''value'',0);',ii) );
end

iY = floor(tB.idxMonthCurrent/12 - 0.01);
iM = tB.idxMonthCurrent - iY*12;
set(handles.textPersonnelDate,'string', sprintf('%02d/%02d',iM,iY) )


idxGrant = tB.idxGrant;
if idxGrant == 0
    return
end

if ~isfield(grants(idxGrant),'personnel') | isempty(grants(idxGrant).date_start)
    return
end


iY = str2num( grants(idxGrant).date_start((end-1):end) );
iM = str2num( grants(idxGrant).date_start(1:2) );
iMonthOfGrant = tB.idxMonthCurrent - iY*12 - iM + 1;
if iMonthOfGrant<1
    tB.idxMonthCurrent = iY*12 + iM;
    iY = floor(tB.idxMonthCurrent/12 - 0.01);
    iM = tB.idxMonthCurrent - iY*12;
    set(handles.textPersonnelDate,'string', sprintf('%02d/%02d',iM,iY) );
    iMonthOfGrant = 1;
end

nPersonnel = min(length(grants(idxGrant).personnel),7);
personnelOffset = grants(idxGrant).personnelRange(1)-1;

for ii=1:nPersonnel
    idxPerson = grants(idxGrant).personnel(ii+personnelOffset).nameIdx;
    eval( sprintf('set(handles.editPersonnel%d,''string'',''%s'');',ii,personnel(idxPerson).name) );
    eval( sprintf('set(handles.editPersonnelBase%d,''string'',''%s'');',ii,num2str(personnel(idxPerson).salary_base(tB.idxMonthCurrent))) );
    eval( sprintf('set(handles.checkboxPersonnelKey%d,''value'',%d);',ii,grants(idxGrant).personnel(ii+personnelOffset).keyPersonnel) );
    if iMonthOfGrant <= length(grants(idxGrant).personnel(ii+personnelOffset).committed_salary_monthly)
        eval( sprintf('set(handles.editPersonnelSalaryCommit%d,''string'',''%s'');',ii,num2str(grants(idxGrant).personnel(ii+personnelOffset).committed_salary_monthly(iMonthOfGrant)) ) );
        eval( sprintf('set(handles.editPersonnelTargetEffort%d,''string'',''%d%%'');',ii,grants(idxGrant).personnel(ii+personnelOffset).targetEffort(iMonthOfGrant)*100) );
        eval( sprintf('set(handles.editPersonnelCurrentEffort%d,''string'',''%d%%'');',ii,grants(idxGrant).personnel(ii+personnelOffset).currentEffort(iMonthOfGrant)*100) );
    else
        eval( sprintf('set(handles.editPersonnelSalaryCommit%d,''string'',''0'');',ii ) );
        eval( sprintf('set(handles.editPersonnelTargetEffort%d,''string'',''0%%'');',ii) );
        eval( sprintf('set(handles.editPersonnelCurrentEffort%d,''string'',''0%%'');',ii) );
    end
end

if iMonthOfGrant <= length(grants(idxGrant).notesByMonth)
    set(handles.editGrantMonthlyDesc,'string', grants(idxGrant).notesByMonth{iMonthOfGrant} );
else
    set(handles.editGrantMonthlyDesc,'string', '' );
end
foos{1} = sprintf('%d of %d',personnelOffset+1,personnelOffset+nPersonnel);
foos{2} = 'of';
foos{3} = sprintf('%d',length(grants(idxGrant).personnel) );
set(handles.textPersonnelNameUpDown,'string', foos );




function updatePeople( handles )
global tB
global personnel

if tB.idxPeople>0  & tB.nPeople>0
    idx = personnel(tB.idxPeople).idxUpdate;

    set(handles.editPersonDate,'string',personnel(tB.idxPeople).update(idx).date)
    set(handles.editPersonSalaryBase,'string',personnel(tB.idxPeople).update(idx).salary_base)
    set(handles.editPersonFringe,'string',personnel(tB.idxPeople).update(idx).fringe_rate)
    set(handles.editPersonSalaryCovered,'string',personnel(tB.idxPeople).update(idx).salary_covered)
    set(handles.editPersonSalaryUpdateDesc,'string',personnel(tB.idxPeople).update(idx).Desc);
    set(handles.checkboxPersonPrimary,'value', personnel(tB.idxPeople).primaryList );
    
    if idx==length(personnel(tB.idxPeople).update)
        set(handles.pushbuttonPersonSalaryUpdate,'enable','on')
        set(handles.pushbuttonPersonSalaryUpdate,'tooltipstring','')
    else
        set(handles.pushbuttonPersonSalaryUpdate,'enable','off')
        set(handles.pushbuttonPersonSalaryUpdate,'tooltipstring',sprintf('Advance to last update to enable\nthis button'))
    end
else
    set(handles.editPersonDate,'string','')
    set(handles.editPersonSalaryBase,'string','')
    set(handles.editPersonFringe,'string','')
    set(handles.editPersonSalaryCovered,'string','')    
    set(handles.checkboxPersonPrimary,'value',0);
end

updatePeopleAxes( handles )



function updatePeopleAxes( handles )
global tB
global personnel
global grants

axes( handles.axesPersonSalaryCommitPercent );

iY = floor( tB.idxMonthAxes/12 - 0.01  );
iM = tB.idxMonthAxes - iY*12;
foos = sprintf('%02d/%02d',iM,iY);
set(handles.textAxesDate,'string',foos);

if tB.idxPeople==0 | tB.nPeople==0
    cla
    return
end


iM0 = tB.idxMonthAxes - 2;
iM1 = tB.idxMonthAxes + 9;

sBase = personnel( tB.idxPeople ).salary_base(iM0:iM1);
sCovered = personnel( tB.idxPeople ).salary_covered(iM0:iM1);

sBG = personnel( tB.idxPeople ).salaryByGrant(:,iM0:iM1);
lstG = find( sum(sBG,2)>0 );

yrange = str2num(get(handles.editAxesRange,'string'));

if max(sum(sBG,1)) > 2*max(max(sBG(lstG,:))) & ~(get(handles.checkboxAxesRange,'value')==1 & yrange(2)>=max(sum(sBG,1)./sBase))
    hl = plot( ([sum(sBG,1)/10; sBG(lstG,:)]./(ones(length(lstG)+1,1)*sBase))', 'o-' );
    set(hl(1),'marker','x')
    hold on
    foo = ((sum(sBG,1)/10)./sCovered)';
    foo( find(isnan(foo)) ) = 1;
    hl(end+1) = plot( foo, '*:' );
%    col = get(hl(1),'color');
    set(hl(end),'color','k')%col)
    hold off
    foos2 = ',''Total / 10''';
    foos2b = ',''Total Covered / 10''';
else
    hl = plot( ([sum(sBG,1); sBG(lstG,:)]./(ones(length(lstG)+1,1)*sBase))', 'o-' );
    set(hl(1),'marker','x')
    hold on
    foo = ((sum(sBG,1))./sCovered)';
    foo( find(isnan(foo)) ) = 1;
    hl(end+1) = plot( foo, '*:' );
%    col = get(hl(1),'color');
    set(hl(end),'color','k')%col)
    hold off
    foos2 = ',''Total''';
    foos2b = ',''Total Covered''';
end
set(hl,'markersize',12)
xlabel( 'Month' )
ylabel( 'Percent Effort' )
set(gca,'fontsize',20)

% y range
if get(handles.checkboxAxesRange,'value')==1
    ylim(yrange)
end

% tick marks
xtick = [1:2:12];
set(gca,'xtick',xtick)
foos = [];
for ii=1:length(xtick)
    iY = floor( (iM0+xtick(ii)-1)/12 - 0.01  );
    iM = (iM0+xtick(ii)-1) - iY*12;
    foos{ii} = sprintf('%02d/%02d',iM,iY);
end
set(gca,'xticklabel',foos)
set(gca,'xgrid','on')
set(gca,'ygrid','on')

% legend
for ii=1:length(lstG)
    foos2 = sprintf( '%s,''%s''',foos2,grants(lstG(ii)).name );
end
eval( sprintf('legend(%s%s,''location'',''best'');',foos2(2:end),foos2b) )

% populate person salary distribution table
foo = {};
for ii=1:length(lstG)
    foo{ii,1} = grants(lstG(ii)).name;
    foo{ii,2} = num2str( sBG(lstG(ii),3) );
    foo{ii,3} = [num2str( round(100*sBG(lstG(ii),3)/sBase(3)) )  '%'];
end
if isempty(ii)
    ii=0;
end
foo{ii+1,1} = 'TOTAL';
foo{ii+1,2} = num2str( sum(sBG(lstG,3)) );
foo{ii+1,3} = [num2str( round(100*sum(sBG(lstG,3))/sBase(3)) ) '%'];
set(handles.uitablePersonSalaryDistribution,'data',foo)




function editBudgetDate_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetDate as text
%        str2double(get(hObject,'String')) returns contents of editBudgetDate as a double



function editBudgetSurplusDirect_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetSurplusDirect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetSurplusDirect as text
%        str2double(get(hObject,'String')) returns contents of editBudgetSurplusDirect as a double



function editBudgetSurplusTotal_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetSurplusTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetSurplusTotal as text
%        str2double(get(hObject,'String')) returns contents of editBudgetSurplusTotal as a double



function editBudgetGLbalanceDirect_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetGLbalanceDirect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetGLbalanceDirect as text
%        str2double(get(hObject,'String')) returns contents of editBudgetGLbalanceDirect as a double



function editBudgetGLbalanceTotal_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetGLbalanceTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetGLbalanceTotal as text
%        str2double(get(hObject,'String')) returns contents of editBudgetGLbalanceTotal as a double


% --- Executes on button press in pushbuttonBudgetUpdate.
function pushbuttonBudgetUpdate_Callback(hObject, eventdata, handles)
global tB
global grants

prompt = {'Date:','GL Balance Direct','GL Balance Total'};
dlg_title = sprintf('Budget Update for %s', grants(tB.idxGrant).name );
num_lines = 1;

formatOut = 'mm/dd/yy';

def = {datestr(now,formatOut), '', ''};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end

dateNew = datenum(answer{1},'mm/dd/yy');
dateLast = dateNew - 1;
iBudget = 1;
if isfield(grants(tB.idxGrant),'budget')
    if ~isempty(grants(tB.idxGrant).budget)
        dateLast = datenum( grants(tB.idxGrant).budget(end).date );
        iBudget = length(grants(tB.idxGrant).budget) + 1;
    end
end
if dateNew<=dateLast
    menu( 'Date must be greater than date of last salary update!','Okay');
    return
end

grants(tB.idxGrant).budget(iBudget).date = datestr(dateNew,'mm/dd/yy');
grants(tB.idxGrant).budget(iBudget).balance.GL_direct = myStr2num(answer{2});
grants(tB.idxGrant).budget(iBudget).balance.GL_total = myStr2num(answer{3});
grants(tB.idxGrant).budget(iBudget).notes = '';

if iBudget>1
    grants(tB.idxGrant).budget(iBudget).notes = grants(tB.idxGrant).budget(iBudget-1).notes;
    
    for ii=1:length(grants(tB.idxGrant).budget(iBudget-1).encumbered_non_salary)
        grants(tB.idxGrant).budget(iBudget).encumbered_non_salary(ii).date = grants(tB.idxGrant).budget(iBudget-1).encumbered_non_salary(ii).date;
        grants(tB.idxGrant).budget(iBudget).encumbered_non_salary(ii).amountDirect = grants(tB.idxGrant).budget(iBudget-1).encumbered_non_salary(ii).amountDirect;
        grants(tB.idxGrant).budget(iBudget).encumbered_non_salary(ii).amountTotal = grants(tB.idxGrant).budget(iBudget-1).encumbered_non_salary(ii).amountTotal;
        grants(tB.idxGrant).budget(iBudget).encumbered_non_salary(ii).description = grants(tB.idxGrant).budget(iBudget-1).encumbered_non_salary(ii).description;
    end
    
    for ii=1:length(grants(tB.idxGrant).budget(iBudget-1).income)
        grants(tB.idxGrant).budget(iBudget).income(ii).date = grants(tB.idxGrant).budget(iBudget-1).income(ii).date;
        grants(tB.idxGrant).budget(iBudget).income(ii).amountDirect = grants(tB.idxGrant).budget(iBudget-1).income(ii).amountDirect;
        grants(tB.idxGrant).budget(iBudget).income(ii).amountTotal = grants(tB.idxGrant).budget(iBudget-1).income(ii).amountTotal;
        grants(tB.idxGrant).budget(iBudget).income(ii).description = grants(tB.idxGrant).budget(iBudget-1).income(ii).description;
    end
end

updateGrants( handles )
updateProjectedBudgetBalance( handles );

updateSaveFileFlag( handles );


% --- Executes on button press in pushbuttonBudgetEdit.
function pushbuttonBudgetEdit_Callback(hObject, eventdata, handles)
global grants
global tB

iBudget = length( grants(tB.idxGrant).budget );
if iBudget==0
    pushbuttonBudgetUpdate_Callback(hObject, eventdata, handles);
    return
end

prompt = {'Date:','GL Balance Direct','GL Balance Total'};
dlg_title = sprintf('Edit Budget Update for %s', grants(tB.idxGrant).name );
num_lines = 1;

formatOut = 'mm/dd/yy';

def = { grants(tB.idxGrant).budget(iBudget).date, num2str(grants(tB.idxGrant).budget(iBudget).balance.GL_direct), ...
    num2str(grants(tB.idxGrant).budget(iBudget).balance.GL_total) };
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end

dateNew = datenum(answer{1},'mm/dd/yy');
dateLast = dateNew - 1;
if iBudget>1
    dateLast = datenum( grants(tB.idxGrant).budget(iBudget-1).date );
end    
if dateNew<=dateLast
    menu( 'Date must be greater than date of last salary update!','Okay');
    return
end

grants(tB.idxGrant).budget(iBudget).date = datestr(dateNew,'mm/dd/yy');
grants(tB.idxGrant).budget(iBudget).balance.GL_direct = myStr2num(answer{2});
grants(tB.idxGrant).budget(iBudget).balance.GL_total = myStr2num(answer{3});

updateProjectedBudgetBalance( handles );

updateSaveFileFlag( handles );



function updateProjectedBudgetBalance( handles )
global tB
global personnel
global grants

flag = 0;
if ~isfield(grants(tB.idxGrant),'budget')
    flag=1;
elseif length(grants(tB.idxGrant).budget)==0
    flag=1;
end
if flag == 1
    set(handles.editBudgetGLbalanceTotal,'string', '');
    set(handles.editBudgetGLbalanceDirect,'string', '');
    set(handles.editBudgetDate,'string', '');
    set(handles.editBudgetSurplusDirect,'string', '');
    set(handles.editBudgetSurplusTotal,'string', '');
    return
end

GL_direct = grants(tB.idxGrant).budget(end).balance.GL_direct;
GL_total = grants(tB.idxGrant).budget(end).balance.GL_total;

dateNew = datenum( grants(tB.idxGrant).budget(end).date ,'mm/dd/yy');
iY = str2num(datestr(dateNew,'yy'));
iM = str2num(datestr(dateNew,'mm')) + 1; % GL post includes the entire month. So base our calculations starting with next month, i.e. +1
iYg = str2num( grants(tB.idxGrant).date_start((end-1):end) );
iMg = str2num( grants(tB.idxGrant).date_start(1:2) );
iMonthOfGrant0 = iY*12 + iM - iYg*12 - iMg + 1;

iYge = str2num( grants(tB.idxGrant).date_end_grant((end-1):end) );
iMge = str2num( grants(tB.idxGrant).date_end_grant(1:2) );

nMonthsInGrant = (iYge-iYg)*12 + (iMge-iMg+1);

iMonthOfGrant0 = max(iMonthOfGrant0,1);  % also need to min against nMonthsInGrant

% committed salary. Divide by 12 to get per month rather than per year
committedSalary = zeros(1,nMonthsInGrant);
committedFringe = zeros(1,nMonthsInGrant);
nP = length(grants(tB.idxGrant).personnel);
for iP = 1:nP
    nameIdx = grants(tB.idxGrant).personnel(iP).nameIdx;
    fringe_rate = personnel(nameIdx).fringe_rate((iYg*12+iMg):(iYge*12+iMge));
    
    committedSalary(:) = committedSalary(:) + grants(tB.idxGrant).personnel(iP).committed_salary_monthly(:) / 12;
    committedFringe(:) = committedFringe(:) + grants(tB.idxGrant).personnel(iP).committed_salary_monthly(:) .* ...
        fringe_rate(:) / 12;
end

% encumberances
encumberedDirect = zeros(1,nMonthsInGrant);
encumberedTotal = zeros(1,nMonthsInGrant);
if isfield(grants(tB.idxGrant).budget(end),'encumbered_non_salary')
    for ii=1:length(grants(tB.idxGrant).budget(end).encumbered_non_salary)
        if ~isempty( grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).date )
            dateEnc = datenum( grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).date, 'mm/dd/yy' );
            iYenc = str2num(datestr(dateEnc,'yy'));
            iMenc = str2num(datestr(dateEnc,'mm'));
            iMonthOfGrantEnc = max(iYenc*12 + iMenc - iYg*12 - iMg + 1, 1);
        else
            iMonthOfGrantEnc = iMonthOfGrant0;
        end
        encumberedDirect(iMonthOfGrantEnc) = encumberedDirect(iMonthOfGrantEnc) + grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).amountDirect;
        encumberedTotal(iMonthOfGrantEnc) = encumberedTotal(iMonthOfGrantEnc) + grants(tB.idxGrant).budget(end).encumbered_non_salary(ii).amountTotal;
    end
end

% income
incomeDirect = zeros(1,nMonthsInGrant);
incomeTotal = zeros(1,nMonthsInGrant);
if isfield(grants(tB.idxGrant).budget(end),'income')
    for ii=1:length(grants(tB.idxGrant).budget(end).income)
        if ~isempty( grants(tB.idxGrant).budget(end).income(ii).date )
            dateInc = datenum( grants(tB.idxGrant).budget(end).income(ii).date, 'mm/dd/yy' );
            iYinc = str2num(datestr(dateInc,'yy'));
            iMinc = str2num(datestr(dateInc,'mm'));
            iMonthOfGrantInc = max(iYinc*12 + iMinc - iYg*12 - iMg + 1, 1);
        else
            iMonthOfGrantInc = iMonthOfGrant0;
        end
        incomeDirect(iMonthOfGrantInc) = incomeDirect(iMonthOfGrantInc) + grants(tB.idxGrant).budget(end).income(ii).amountDirect;
        incomeTotal(iMonthOfGrantInc) = incomeTotal(iMonthOfGrantInc) + grants(tB.idxGrant).budget(end).income(ii).amountTotal;
    end
end

% subtract committments from Direct and add income
grants(tB.idxGrant).budget(end).balance.projected_GL_direct = zeros(1,nMonthsInGrant);
grants(tB.idxGrant).budget(end).balance.projected_GL_direct(iMonthOfGrant0) = ...
    grants(tB.idxGrant).budget(end).balance.GL_direct - ...
    committedSalary(iMonthOfGrant0) - committedFringe(iMonthOfGrant0) - ...
    encumberedDirect(iMonthOfGrant0) + incomeDirect(iMonthOfGrant0);

for iMonth = (iMonthOfGrant0+1):nMonthsInGrant
    grants(tB.idxGrant).budget(end).balance.projected_GL_direct(iMonth) = ...
        grants(tB.idxGrant).budget(end).balance.projected_GL_direct(iMonth-1) - ...
            committedSalary(iMonth) - committedFringe(iMonth) - ...
            encumberedDirect(iMonth) + incomeDirect(iMonth);
end

% subtract committments from Total and add income
grants(tB.idxGrant).budget(end).balance.projected_GL_total = zeros(1,nMonthsInGrant);
grants(tB.idxGrant).budget(end).balance.projected_GL_total(iMonthOfGrant0) = ...
    grants(tB.idxGrant).budget(end).balance.GL_total - ...
    ( committedSalary(iMonthOfGrant0) + committedFringe(iMonthOfGrant0) ) * ...
    (1 + grants(tB.idxGrant).overheadRate) - encumberedTotal(iMonthOfGrant0) + incomeTotal(iMonthOfGrant0);

for iMonth = (iMonthOfGrant0+1):nMonthsInGrant
    grants(tB.idxGrant).budget(end).balance.projected_GL_total(iMonth) = ...
        grants(tB.idxGrant).budget(end).balance.projected_GL_total(iMonth-1) - ...
            ( committedSalary(iMonth) + committedFringe(iMonth) ) * ...
            (1 + grants(tB.idxGrant).overheadRate) - encumberedTotal(iMonth) + incomeTotal(iMonth);
end

% UPDATE GUI
set(handles.editBudgetGLbalanceTotal,'string', sprintf('%.0f',grants(tB.idxGrant).budget(end).balance.GL_total) );
set(handles.editBudgetGLbalanceDirect,'string', sprintf('%.0f',grants(tB.idxGrant).budget(end).balance.GL_direct) );
set(handles.editBudgetDate,'string', grants(tB.idxGrant).budget(end).date );

iYgbpe = str2num( grants(tB.idxGrant).date_end_budget_period((end-1):end) );
iMgbpe = str2num( grants(tB.idxGrant).date_end_budget_period(1:2) );

surplusDirect = grants(tB.idxGrant).budget(end).balance.projected_GL_direct((iYgbpe-iYg)*12 + (iMgbpe-iMg+1));
set(handles.editBudgetSurplusDirect,'string', sprintf('%.0f',surplusDirect) );

surplusTotal = grants(tB.idxGrant).budget(end).balance.projected_GL_total((iYgbpe-iYg)*12 + (iMgbpe-iMg+1));
set(handles.editBudgetSurplusTotal,'string', sprintf('%.0f',surplusTotal) );



function updateSaveFileFlag( handles )
global tB

set(handles.figure1,'name', sprintf('trackBudget - %s *',tB.filenm) )




function editBudgetDatePast_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetDatePast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetDatePast as text
%        str2double(get(hObject,'String')) returns contents of editBudgetDatePast as a double



function editBudgetSurplusDirectPast_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetSurplusDirectPast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetSurplusDirectPast as text
%        str2double(get(hObject,'String')) returns contents of editBudgetSurplusDirectPast as a double



function editBudgetSurplusTotalPast_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetSurplusTotalPast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetSurplusTotalPast as text
%        str2double(get(hObject,'String')) returns contents of editBudgetSurplusTotalPast as a double



function editBudgetGLbalanceDirectPast_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetGLbalanceDirectPast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetGLbalanceDirectPast as text
%        str2double(get(hObject,'String')) returns contents of editBudgetGLbalanceDirectPast as a double



function editBudgetGLbalanceTotalPast_Callback(hObject, eventdata, handles)
% hObject    handle to editBudgetGLbalanceTotalPast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBudgetGLbalanceTotalPast as text
%        str2double(get(hObject,'String')) returns contents of editBudgetGLbalanceTotalPast as a double


% --- Executes on button press in pushbuttonBudgetLeft.
function pushbuttonBudgetLeft_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBudgetLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonBudgetRight.
function pushbuttonBudgetRight_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonBudgetRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function editPersonnel1_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel1 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel1 as a double



function editPersonnel2_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel2 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel2 as a double



function editPersonnel3_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel3 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel3 as a double



function editPersonnel4_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel4 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel4 as a double



function editPersonnel5_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel5 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel5 as a double



function editPersonnel6_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel6 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel6 as a double



function editPersonnel7_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnel7 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnel7 as a double



function editPersonnelBase1_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase1 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase1 as a double



function editPersonnelBase2_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase2 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase2 as a double



function editPersonnelBase3_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase3 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase3 as a double



function editPersonnelBase4_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase4 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase4 as a double



function editPersonnelBase5_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase5 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase5 as a double



function editPersonnelBase6_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase6 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase6 as a double



function editPersonnelBase7_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelBase7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelBase7 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelBase7 as a double




function editPersonnelSalaryCommit_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

amnt = myStr2num(get(hObject,'string'));

idxGrant = tB.idxGrant;
personnelOffset = grants(idxGrant).personnelRange(1)-1;

iY = floor(tB.idxMonthCurrent/12 - 0.01);
iM = tB.idxMonthCurrent - iY*12;

iYg = str2num( grants(idxGrant).date_start((end-1):end) );
iMg = str2num( grants(idxGrant).date_start(1:2) );
iMonthOfGrant0 = tB.idxMonthCurrent - iYg*12 - iMg + 1;

prompt = {'Salary Commit change effective through MM/YY:'};
dlg_title = 'Salary commit change duration';
num_lines = 1;
def = { datestr(datenum( grants(idxGrant).date_end_grant, 'mm/dd/yy'),'mm/yy')  };
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    amnt = grants( tB.idxGrant ).personnel( eventdata+personnelOffset ).committed_salary_monthly( iY*12+iM-iYg*12-iMg+1 );
    eval( sprintf('set(handles.editPersonnelSalaryCommit%d,''string'',%s);',eventdata,num2str(amnt)) )
    return
end

foos = datestr(datenum( answer{1}, 'mm/yy'),'mm/yy');
iYe = str2num(foos(4:5));
iMe = str2num(foos(1:2));
iMonthOfGrant1 = iYe*12 + iMe - iYg*12 - iMg + 1;
if iMonthOfGrant1 < iMonthOfGrant0
    ch = menu('You entered a date earlier than current date. Assuming you meant current data.','Okay');
    iMonthOfGrant1 = iMonthOfGrant0;
end

grants( tB.idxGrant ).personnel( eventdata+personnelOffset ).committed_salary_monthly(iMonthOfGrant0:iMonthOfGrant1) = amnt;

idxPerson = grants( tB.idxGrant ).personnel( eventdata+personnelOffset ).nameIdx;

personnel(idxPerson).salaryByGrant(tB.idxGrant,(iY*12+iM):(iYe*12+iMe)) = amnt;

updatePeople( handles );

updateProjectedBudgetBalance( handles );

updateSaveFileFlag( handles )





% --- Executes on button press in pushbuttonPersonnelAdd.
function pushbuttonPersonnelAdd_Callback(hObject, eventdata, handles)
global tB
global grants
global personnel

idxPerson = tB.idxPeople;
idxGrant = tB.idxGrant;

if ~isfield(grants(idxGrant),'personnel')
    grants(idxGrant).personnel = [];
end

nPersonnel = length( grants(idxGrant).personnel );

nameIdx = [];
for ii=1:nPersonnel
    nameIdx(ii) = grants(idxGrant).personnel(ii).nameIdx;
end

if ~isempty( find(nameIdx==idxPerson) )
    menu( sprintf('Person ''%s'' is already part of grant',personnel(idxPerson).name) ,'Okay');
    return;
end

grants(idxGrant).personnel(nPersonnel+1).nameIdx = idxPerson;

yr0 = str2num( grants(idxGrant).date_start((end-1):end) );
mn0 = str2num( grants(idxGrant).date_start(1:2) );
yr1 = str2num( grants(idxGrant).date_end_grant((end-1):end) );
mn1 = str2num( grants(idxGrant).date_end_grant(1:2) );

nMonths = (yr1-yr0+1)*12 - (mn0-1) - (12-mn1);

grants(idxGrant).personnel(nPersonnel+1).committed_salary_monthly = zeros(nMonths,1);

grants(idxGrant).personnel(nPersonnel+1).keyPersonnel = 0;
grants(idxGrant).personnel(nPersonnel+1).targetEffort = zeros(nMonths,1);
grants(idxGrant).personnel(nPersonnel+1).currentEffort = zeros(nMonths,1);

updateGrantPersonnel( handles );
updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );





% --- Executes on button press in togglebuttonPersonnelHide.
function togglebuttonPersonnelHide_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonPersonnelHide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonPersonnelHide


% --- Executes on button press in pushbuttonPersonnelRemove.
function pushbuttonPersonnelRemove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonPersonnelRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkboxPersonnel1.
function checkboxPersonnel1_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel1


% --- Executes on button press in checkboxPersonnel2.
function checkboxPersonnel2_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel2


% --- Executes on button press in checkboxPersonnel3.
function checkboxPersonnel3_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel3


% --- Executes on button press in checkboxPersonnel4.
function checkboxPersonnel4_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel4


% --- Executes on button press in checkboxPersonnel5.
function checkboxPersonnel5_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel5


% --- Executes on button press in checkboxPersonnel6.
function checkboxPersonnel6_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel6


% --- Executes on button press in checkboxPersonnel7.
function checkboxPersonnel7_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPersonnel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPersonnel7


% --- Executes on button press in pushbuttonPersonnelDateLeft.
function pushbuttonPersonnelDateLeft_Callback(hObject, eventdata, handles)
global tB

tB.idxMonthCurrent = tB.idxMonthCurrent - 1;
updateGrantPersonnel( handles );


% --- Executes on button press in pushbuttonPersonnelDateRight.
function pushbuttonPersonnelDateRight_Callback(hObject, eventdata, handles)
global tB

tB.idxMonthCurrent = tB.idxMonthCurrent + 1;
updateGrantPersonnel( handles );


function editPersonDate_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonDate as text
%        str2double(get(hObject,'String')) returns contents of editPersonDate as a double



function editPersonSalaryBase_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonSalaryBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonSalaryBase as text
%        str2double(get(hObject,'String')) returns contents of editPersonSalaryBase as a double



function editPersonFringe_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonFringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonFringe as text
%        str2double(get(hObject,'String')) returns contents of editPersonFringe as a double



function editPersonSalaryCovered_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonSalaryCovered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonSalaryCovered as text
%        str2double(get(hObject,'String')) returns contents of editPersonSalaryCovered as a double


% --- Executes on button press in pushbuttonPersonSalaryUpdate.
function pushbuttonPersonSalaryUpdate_Callback(hObject, eventdata, handles)
global tB
global personnel

prompt = {'Date:','Base Salary:','Fringe Rate:','Salary Covered'};
dlg_title = sprintf('Salary Update for %s', personnel(tB.idxPeople).name );
num_lines = 1;

formatOut = 'mm/dd/yy';

def = {datestr(now,formatOut), num2str(personnel(tB.idxPeople).update(end).salary_base), ...
    num2str(personnel(tB.idxPeople).update(end).fringe_rate), num2str(personnel(tB.idxPeople).update(end).salary_covered)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end

dateNew = datenum(answer{1},'mm/dd/yy');
dateLast = datenum( personnel(tB.idxPeople).update(end).date );
if dateNew<=dateLast
    menu( 'Date must be greater than date of last salary update!','Okay');
    return
end

personnel(tB.idxPeople).update(end+1).date = datestr(dateNew,'mm/dd/yy');
personnel(tB.idxPeople).update(end).salary_base = myStr2num(answer{2});
personnel(tB.idxPeople).update(end).fringe_rate = myStr2num(answer{3});
personnel(tB.idxPeople).update(end).salary_covered = myStr2num(answer{4});
personnel(tB.idxPeople).update(end).Desc = '';

personnel(tB.idxPeople).idxUpdate = length( personnel(tB.idxPeople).update );

iY = str2num(datestr(dateNew,'yy'));
iM = str2num(datestr(dateNew,'mm'));
personnel(tB.idxPeople).salary_base((iY*12+iM):end) = myStr2num(answer{2});
personnel(tB.idxPeople).fringe_rate((iY*12+iM):end) = myStr2num(answer{3});
personnel(tB.idxPeople).salary_covered((iY*12+iM):end) = myStr2num(answer{4});

updatePeople( handles );
updatePeopleAxes( handles );
updateSaveFileFlag( handles );


% --- Executes on button press in pushbuttonSalaryEdit.
function pushbuttonSalaryEdit_Callback(hObject, eventdata, handles)
global tB
global personnel

prompt = {'Date:','Base Salary:','Fringe Rate:','Salary Covered'};
dlg_title = sprintf('Salary Update for %s', personnel(tB.idxPeople).name );
num_lines = 1;

formatOut = 'mm/dd/yy';

idxDate = personnel(tB.idxPeople).idxUpdate;

def = {personnel(tB.idxPeople).update(idxDate).date, ...
    num2str(personnel(tB.idxPeople).update(idxDate).salary_base), ...
    num2str(personnel(tB.idxPeople).update(idxDate).fringe_rate), num2str(personnel(tB.idxPeople).update(idxDate).salary_covered)};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    return
end

personnel(tB.idxPeople).update(idxDate).date = answer{1};
personnel(tB.idxPeople).update(idxDate).salary_base = myStr2num(answer{2});
personnel(tB.idxPeople).update(idxDate).fringe_rate = myStr2num(answer{3});
personnel(tB.idxPeople).update(idxDate).salary_covered = myStr2num(answer{4});
personnel(tB.idxPeople).update(idxDate).Desc = '';

for ii = 1:length(personnel(tB.idxPeople).update)
    dateNum = datenum( personnel(tB.idxPeople).update(ii).date, 'mm/dd/yy' );
    iY = str2num(datestr(dateNum,'yy'));
    iM = str2num(datestr(dateNum,'mm'));
    personnel(tB.idxPeople).salary_base((iY*12+iM):end) = personnel(tB.idxPeople).update(ii).salary_base;
    personnel(tB.idxPeople).fringe_rate((iY*12+iM):end) = personnel(tB.idxPeople).update(ii).fringe_rate;
    personnel(tB.idxPeople).salary_covered((iY*12+iM):end) = personnel(tB.idxPeople).update(ii).salary_covered;
end

updatePeople( handles );
updatePeopleAxes( handles );
updateSaveFileFlag( handles );


% --- Executes on button press in pushbuttonSalaryDateLeft.
function pushbuttonSalaryDateLeft_Callback(hObject, eventdata, handles)
global personnel
global tB

if personnel(tB.idxPeople).idxUpdate > 1
    personnel(tB.idxPeople).idxUpdate = personnel(tB.idxPeople).idxUpdate - 1;
    updatePeople( handles );
else
    ch = menu('Already at first salary update.','Okay');
end

% --- Executes on button press in pushbuttonSalaryDateRight.
function pushbuttonSalaryDateRight_Callback(hObject, eventdata, handles)
global personnel
global tB

if personnel(tB.idxPeople).idxUpdate < length(personnel(tB.idxPeople).update)
    personnel(tB.idxPeople).idxUpdate = personnel(tB.idxPeople).idxUpdate + 1;
    updatePeople( handles );
else
    ch = menu('Already at last salary update.','Okay');
end



function editPersonSalaryUpdateDesc_Callback(hObject, eventdata, handles)
global personnel
global tB

idxDate = personnel(tB.idxPeople).idxUpdate;
personnel(tB.idxPeople).update(idxDate).Desc = get(hObject,'string');
updateSaveFileFlag( handles );




% --- Executes on button press in pushbuttonAxesDateLeft.
function pushbuttonAxesDateLeft_Callback(hObject, eventdata, handles)
global tB

tB.idxMonthAxes = tB.idxMonthAxes - 1;
updatePeopleAxes( handles );


% --- Executes on button press in pushbuttonAxesDateRight.
function pushbuttonAxesDateRight_Callback(hObject, eventdata, handles)
global tB

tB.idxMonthAxes = tB.idxMonthAxes + 1;
updatePeopleAxes( handles );


% --- Executes on button press in checkboxAxesRange.
function checkboxAxesRange_Callback(hObject, eventdata, handles)
updatePeopleAxes( handles );


function editAxesRange_Callback(hObject, eventdata, handles)
updatePeopleAxes( handles );


% --- Executes on selection change in popupmenuGrantPI.
function popupmenuGrantPI_Callback(hObject, eventdata, handles)
global grants
global tB

grants(tB.idxGrant).idxPI = get(hObject,'value');
updateSaveFileFlag( handles );



function editGrantOverheadRate_Callback(hObject, eventdata, handles)
global grants
global tB

grants(tB.idxGrant).overheadRate = myStr2num( get(hObject,'string') );
updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );




function editEncumberanceDate_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = datestr(datenum(get(hObject,'string'),'mm/dd/yy'),'mm/dd/yy');
set(hObject,'string',foos);
grants(tB.idxGrant).budget(end).encumbered_non_salary(idx).date = foos;

updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );


function editEncumberanceAmountDirect_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = get(hObject,'string');
grants(tB.idxGrant).budget(end).encumbered_non_salary(idx).amountDirect = myStr2num(foos);

updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );


function editEncumberanceAmountTotal_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = get(hObject,'string');
grants(tB.idxGrant).budget(end).encumbered_non_salary(idx).amountTotal = myStr2num(foos);

updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );


function editEncumberanceDesc_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = get(hObject,'string');
grants(tB.idxGrant).budget(end).encumbered_non_salary(idx).description = foos;
updateSaveFileFlag( handles );


function editIncomeDate_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = datestr(datenum(get(hObject,'string'),'mm/dd/yy'),'mm/dd/yy');
set(hObject,'string',foos);
grants(tB.idxGrant).budget(end).income(idx).date = foos;

updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );



function editIncomeAmountDirect_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = get(hObject,'string');
grants(tB.idxGrant).budget(end).income(idx).amountDirect = myStr2num(foos);

updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );


function editIncomeAmountTotal_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = get(hObject,'string');
grants(tB.idxGrant).budget(end).income(idx).amountTotal = myStr2num(foos);

updateProjectedBudgetBalance( handles );
updateSaveFileFlag( handles );



function editIncomeDesc_Callback(hObject, eventdata, handles)
global grants
global tB

idx = eventdata;

foos = get(hObject,'string');
grants(tB.idxGrant).budget(end).income(idx).description = foos;
updateSaveFileFlag( handles );



% --- Executes on button press in checkboxPersonPrimary.
function checkboxPersonPrimary_Callback(hObject, eventdata, handles)
global personnel
global tB

personnel(tB.idxPeople).primaryList = get(hObject,'value');

sortPeopleList( handles );
updateSaveFileFlag( handles );


function sortPeopleList( handles )
global personnel
global tB

nNames = length(personnel);

names = {};
primaryList = [];
for ii=1:nNames
    names{ii} = personnel(ii).name;
    primaryList(ii) = personnel(ii).primaryList;
end

lst1 = find(primaryList==1);
lst2 = find(primaryList==0);

names1o = {};
for ii=1:length(lst1)
    names1o{ii} = names{lst1(ii)};
end
names2o = {};
for ii=1:length(lst2)
    names2o{ii} = names{lst2(ii)};
end

[names1, i1] = sort(names1o);
[names2, i2] = sort(names2o);

namesOrder = {};
kk = 0;
for ii=1:length(names1)
    kk = kk + 1;
    namesOrder{kk} = names1{ii};
end
for ii=1:length(names2)
    kk = kk + 1;
    namesOrder{kk} = names2{ii};
end
set(handles.popupmenuPersonName,'string',namesOrder);

tB.sortPeopleList = [lst1(i1) lst2(i2)];

ii = find(tB.sortPeopleList==tB.idxPeople);
set(handles.popupmenuPersonName,'value',ii)




function sortGrantList( handles )
global grants
global tB

nNames = length(grants);

names = {};
primaryList = [];
acctNum = {};
for ii=1:nNames
    names{ii} = grants(ii).name;
    acctNum{ii} = grants(ii).acct_number;
    primaryList(ii) = grants(ii).active;
end

lst1 = find(primaryList==1);
lst2 = find(primaryList==0);

names1o = {};
acctNum1o = {};
for ii=1:length(lst1)
    names1o{ii} = names{lst1(ii)};
    acctNum1o{ii} = acctNum{lst1(ii)};
end
names2o = {};
acctNum2o = {};
for ii=1:length(lst2)
    names2o{ii} = names{lst2(ii)};
    acctNum2o{ii} = acctNum{lst2(ii)};
end

if 0
    [names1, i1] = sort(names1o);
    [names2, i2] = sort(names2o);
else
    [acctNum1, i1] = sort(acctNum1o);
    [acctNum2, i2] = sort(acctNum2o);
end

namesOrder = {};
kk = 0;
for ii=1:length(i1)
    kk = kk + 1;
    if 0
        namesOrder{kk} = [names{lst1(i1(ii))} ' - ' acctNum{lst1(i1(ii))}];
    else
        namesOrder{kk} = [acctNum{lst1(i1(ii))} ' - ' names{lst1(i1(ii))}];
    end
end
for ii=1:length(i2)
    kk = kk + 1;
    if 0
        namesOrder{kk} = [names{lst2(i2(ii))} ' - ' acctNum{lst2(i2(ii))}];
    else
        namesOrder{kk} = ['- ' acctNum{lst2(i2(ii))} ' - ' names{lst2(i2(ii))}];
    end
end
set(handles.popupmenuGrantName,'string',namesOrder);

tB.sortGrantList = [lst1(i1) lst2(i2)];

ii = find(tB.sortGrantList==tB.idxGrant);
set(handles.popupmenuGrantName,'value',ii)




% --------------------------------------------------------------------
function menuReportSalaryShort6_Callback(hObject, eventdata, handles)
displaySalaryShort( 6 );

function menuReportSalaryShort12_Callback(hObject, eventdata, handles)
displaySalaryShort( 12 );

function menuReportSalaryShort24_Callback(hObject, eventdata, handles)
displaySalaryShort( 24 );


function displaySalaryShort( nMonths )
global personnel

foos = datestr(now,'mm/yy');
iM = str2num(foos(1:2));
iY = str2num(foos(4:5));
lstMonths = iY*12 + iM + [1:nMonths] - 1;


d = {};
short = [];
expected = [];
paid = [];
fringe_rate = [];
for iPerson = 1:length(personnel)
    d{iPerson,1} = personnel(iPerson).name;
    
    short(iPerson) = sum(personnel(iPerson).salary_covered(lstMonths))/12 - ...
        sum(sum(personnel(iPerson).salaryByGrant(:,lstMonths)))/12;
    expected(iPerson) = sum(personnel(iPerson).salary_covered(lstMonths))/12;
    paid(iPerson) = sum(sum(personnel(iPerson).salaryByGrant(:,lstMonths)))/12;
    fringe_rate(iPerson) = mean( personnel(iPerson).fringe_rate(lstMonths) );
    
    d{iPerson,2} = sprintf('          %.0f',short(iPerson));
    d{iPerson,3} = sprintf('          %.0f',expected(iPerson) );
    d{iPerson,4} = sprintf('          %.0f',paid(iPerson) );
end

[foo,lstOrder] = sort(abs(short),'descend');
d2 = {};
for ii = 1:length(lstOrder)
    d2{ii,1} = d{lstOrder(ii),1};
    d2{ii,2} = d{lstOrder(ii),2};
    d2{ii,3} = d{lstOrder(ii),3};
    d2{ii,4} = d{lstOrder(ii),4};
end

% SUMS
d2{end+1,1} = 'TOTAL SALARY';
d2{end,2} = sprintf('          %.0f',sum(short));
d2{end,3} = sprintf('          %.0f',sum(expected));
d2{end,4} = sprintf('          %.0f',sum(paid));

d2{end+1,1} = 'TOTAL BENEFITS';
d2{end,2} = sprintf('          %.0f',sum(short.*fringe_rate));
d2{end,3} = sprintf('          %.0f',sum(expected.*fringe_rate));
d2{end,4} = sprintf('          %.0f',sum(paid.*fringe_rate));

d2{end+1,1} = 'TOTAL';
d2{end,2} = sprintf('          %.0f',sum(short.*(1+fringe_rate)));
d2{end,3} = sprintf('          %.0f',sum(expected.*(1+fringe_rate)));
d2{end,4} = sprintf('          %.0f',sum(paid.*(1+fringe_rate)));

f = figure(11);
clf
set(f,'Position',[25 510 644 351]);
set(f,'menubar','none')
set(f,'name',sprintf('%d Months',nMonths) )
set(f,'numbertitle','off')

% Create the column and row names in cell arrays 
cnames = {'Person','Salary Short Fall','Expected','Paid'};
rnames = {};

% Create the uitable
t = uitable(f,'Data',d2,...
            'ColumnName',cnames,... 
            'RowName',rnames,...
            'ColumnWidth',{150,150,150,150});

% Set width and height
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);   

f.Position(3) = t.Extent(3) + 40;
f.Position(4) = t.Extent(4) + 40;


% --------------------------------------------------------------------
function menuReportGrantSurplus_Callback(hObject, eventdata, handles)
global grants
global tB
global personnel

foos = datestr(now,'mm/yy');
iM = str2num(foos(1:2));
iY = str2num(foos(4:5));

% Salary short fall
short = [];
for iPerson = 1:length(personnel)
    for iQ = 1:8
        if iQ==1
            lstMonths = iY*12 + iM ;
        else
            lstMonths = iY*12 + iM + [0:(iQ-1)*3];
        end

        short(iPerson,iQ) = sum(personnel(iPerson).salary_covered(lstMonths))/12 - ...
            sum(sum(personnel(iPerson).salaryByGrant(:,lstMonths)))/12;
        
        fringe_rate = mean( personnel(iPerson).fringe_rate(lstMonths) );
        short(iPerson,iQ) = short(iPerson,iQ) * (1+ fringe_rate);
    end
end

% Grant Direct and Totals
d1 = {};
d2 = {};
surplusDirect = [];
surplusTotal = [];
cnames = {'Grant'};
cwid = {150};
for iGrant = 1:tB.nGrants

    iYg = str2num( grants(iGrant).date_start((end-1):end) );
    iMg = str2num( grants(iGrant).date_start(1:2) );
    iDateG = iYg*12 + iMg;
    
    iYgbpe = str2num( grants(iGrant).date_end_budget_period((end-1):end) );
    iMgbpe = str2num( grants(iGrant).date_end_budget_period(1:2) );
    iDateBPE = iYgbpe*12 + iMgbpe;
    
    d1{iGrant,1} = [grants(iGrant).name ' - ' grants(iGrant).acct_number];
    d2{iGrant,1} = [grants(iGrant).name ' - ' grants(iGrant).acct_number];
    
    for iQ = 1:8
        iDate = iY*12 + iM + (iQ-1)*3;
        
        if iGrant==1
            cnames{end+1} = sprintf('%02d/%02d', mod(iM+(iQ-1)*3-1,12)+1, iY+floor( (iM+(iQ-1)*3-1)/12 ) );
            cwid{end+1} = 75;
        end

        if iDate>iDateBPE
            iDateBPE = iDateBPE + 12;
        end

        idx = iDateBPE - iDateG + 1;
        
        if idx<=length( grants(iGrant).budget(end).balance.projected_GL_direct )
            surplusDirect(iGrant,iQ) = grants(iGrant).budget(end).balance.projected_GL_direct( idx );
            d1{iGrant,iQ+1} = sprintf( '%.0f', surplusDirect(iGrant,iQ) );
            
            surplusTotal(iGrant,iQ) = grants(iGrant).budget(end).balance.projected_GL_total( idx );
            d2{iGrant,iQ+1} = sprintf( '%.0f', surplusTotal(iGrant,iQ) );
        else
            d1{iGrant,iQ+1} = '';
            d2{iGrant,iQ+1} = '';
        end
    end
    
end

% Sort by 1st quarter
[foo,lstOrder] = sort(abs(surplusTotal(:,1)),'descend');
d1b = {};
d2b = {};
for ii = 1:length(lstOrder)
    for jj = 1:size(d1,2)
        d1b{ii,jj} = d1{lstOrder(ii),jj};
        d2b{ii,jj} = d2{lstOrder(ii),jj};
    end
end


% TOTALS
d1b{end+1,1} = 'TOTAL';
d2b{end+1,1} = 'TOTAL';
for iQ = 1:8
    d1b{end,iQ+1} = sprintf('%.0f', sum(surplusDirect(:,iQ)));
    d2b{end,iQ+1} = sprintf('%.0f', sum(surplusTotal(:,iQ)));
end

% SALARY SHORT FALL
d1b{end+1,1} = 'SALARY/BENEFITS SHORT';
for iQ = 1:8
    d1b{end,iQ+1} = sprintf('%.0f', sum(short(:,iQ),1));
end

% CORRECTED DIRECT SURPLUS
d1b{end+1,1} = 'TOTAL CORRECTED';
for iQ = 1:8
    d1b{end,iQ+1} = sprintf('%.0f', sum(surplusDirect(:,iQ)) - sum(short(:,iQ),1));
end


% DISPLAY DIRECT
f = figure(12);
clf
set(f,'Position',[44   693   869   147]);
set(f,'menubar','none')
set(f,'name', 'Grant Projected Directs' )
set(f,'numbertitle','off')
set(f,'toolbar','figure')

% Create the column and row names in cell arrays 
rnames = {};

% Create the uitable
t = uitable(f,'Data',d1b,...
            'ColumnName',cnames,... 
            'RowName',rnames,...
            'ColumnWidth',cwid);

% Set width and height
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);   

f.Position(3) = t.Extent(3) + 40;
f.Position(4) = t.Extent(4) + 40;
f1 = f;

% DISPLAY TOTAL
f = figure(13);
clf
set(f,'Position',[44   400   869   147]);
set(f,'menubar','none')
set(f,'name', 'Grant Projected Totals' )
set(f,'numbertitle','off')
set(f,'toolbar','figure')

% Create the column and row names in cell arrays 
rnames = {};

% Create the uitable
t = uitable(f,'Data',d2b,...
            'ColumnName',cnames,... 
            'RowName',rnames,...
            'ColumnWidth',cwid);

% Set width and height
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);   

f.Position(3) = t.Extent(3) + 40;
f.Position(4) = t.Extent(4) + 40;
f.Position(2) = f1.Position(2) - f.Position(4) - 170;


function pushbuttonReportMonthlySalary_Callback(hObject, eventdata, handles)
global reportMonthlySalary

reportMonthlySalary.iMonth = 1;

trackBudget_displaySalaryMonthly( [], [] );


function menuReportSalaryPersonByGrantPerMonth_Callback(hObject, eventdata, handles)
global reportSalaryPersonByGrant

foos = datestr(now,'mm/yy');
iM = str2num(foos(1:2));
iY = str2num(foos(4:5));

reportSalaryPersonByGrant.iMonth = iY*12 + iM;

trackBudget_displaySalaryPersonByGrantPerMonth( [], [] );





function editGrantMonthlyDesc_Callback(hObject, eventdata, handles)
global grants
global tB

iY = str2num( grants(tB.idxGrant).date_start((end-1):end) );
iM = str2num( grants(tB.idxGrant).date_start(1:2) );
iMonthOfGrant = tB.idxMonthCurrent - iY*12 - iM + 1;


grants(tB.idxGrant).notesByMonth{iMonthOfGrant} = get(hObject,'string');

updateSaveFileFlag( handles );


% --- Executes on button press in checkboxPersonnelKey1.
function checkboxPersonnelKey_Callback(hObject, eventdata, handles)
global tB
global grants

if eventdata<=length(grants(tB.idxGrant).personnel)
    personnelOffset = grants(tB.idxGrant).personnelRange(1)-1;
    grants(tB.idxGrant).personnel(eventdata+personnelOffset).keyPersonnel = get(hObject,'Value');
else
    set(hObject,'Value',0);
end

updateSaveFileFlag( handles );





function editPersonnelTargetEffort_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelTargetEffort1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelTargetEffort1 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelTargetEffort1 as a double

global tB
global grants

if eventdata>length(grants(tB.idxGrant).personnel)
    set(hObject,'string',0);
    return
end

amnt = myStr2num(get(hObject,'string'));

idxGrant = tB.idxGrant;
personnelOffset = grants(idxGrant).personnelRange(1)-1;

iY = floor(tB.idxMonthCurrent/12 - 0.01);
iM = tB.idxMonthCurrent - iY*12;

iYg = str2num( grants(idxGrant).date_start((end-1):end) );
iMg = str2num( grants(idxGrant).date_start(1:2) );
iMonthOfGrant0 = tB.idxMonthCurrent - iYg*12 - iMg + 1;

prompt = {'Target Effort change effective through MM/YY:'};
dlg_title = 'Target Effort change duration';
num_lines = 1;
def = { datestr(datenum( grants(idxGrant).date_end_grant, 'mm/dd/yy'),'mm/yy')  };
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    amnt = grants( tB.idxGrant ).personnel( eventdata+personnelOffset ).targetEffort( iY*12+iM-iYg*12-iMg+1 ) * 100;
    eval( sprintf('set(handles.editPersonnelTargetEffort%d,''string'',''%s'');',eventdata,[num2str(amnt) '%']) )
    return
end

foos = datestr(datenum( answer{1}, 'mm/yy'),'mm/yy');
iYe = str2num(foos(4:5));
iMe = str2num(foos(1:2));
iMonthOfGrant1 = iYe*12 + iMe - iYg*12 - iMg + 1;

grants( tB.idxGrant ).personnel( eventdata+personnelOffset ).targetEffort(iMonthOfGrant0:iMonthOfGrant1) = amnt / 100;
eval( sprintf('set(handles.editPersonnelTargetEffort%d,''string'',''%s'');',eventdata,[num2str(amnt) '%']) )

% CALCULATE CURRENT EFFORT



function editPersonnelCurrentEffort1_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort1 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort1 as a double



function editPersonnelCurrentEffort2_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort2 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort2 as a double



function editPersonnelCurrentEffort3_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort3 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort3 as a double



function editPersonnelCurrentEffort4_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort4 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort4 as a double



function editPersonnelCurrentEffort5_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort5 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort5 as a double



function editPersonnelCurrentEffort6_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort6 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort6 as a double



function editPersonnelCurrentEffort7_Callback(hObject, eventdata, handles)
% hObject    handle to editPersonnelCurrentEffort7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPersonnelCurrentEffort7 as text
%        str2double(get(hObject,'String')) returns contents of editPersonnelCurrentEffort7 as a double



function editBudgetUpdateNotes_Callback(hObject, eventdata, handles)
global tB
global grants

grants(tB.idxGrant).budget(end).notes = get(hObject,'string');

updateSaveFileFlag( handles );


% --------------------------------------------------------------------
function menuReportPersonnelPercentCovered_Callback(hObject, eventdata, handles)
global personnel

foos = datestr(now,'mm/yy');
iM = str2num(foos(1:2));
iY = str2num(foos(4:5));

nMonths = 24;
skip = 3;
lstMonths = iY*12 + iM + [1:nMonths] - 1;


d = {};
iPerson = 0;
expected = [];
base = [];
percent = [];
name = {};
for ii = 1:length(personnel)
    if personnel(ii).primaryList==1
        iPerson = iPerson + 1;
        name{iPerson} = personnel(ii).name;
        
        expected(iPerson,:) = personnel(ii).salary_covered(lstMonths)/12;
        base(iPerson,:) = personnel(ii).salary_base(lstMonths)/12;
        percent(iPerson,:) = 100 * expected(iPerson,:)./base(iPerson,:);
    end
end
[foo,lstOrder] = sort(name);

for ii = 1:size(percent,1)
    d{ii,1} = name{lstOrder(ii)};
    kk = 1;
    for jj = 1:skip:nMonths
        kk = kk + 1;
        d{ii,kk} = sprintf('%.1f%%',percent(lstOrder(ii),jj));
    end
end

cnames = {'Person'};%,'Salary Short Fall','Expected','Paid'};
cwid = {150};
for jj = 1:skip:nMonths
    cnames{end+1} = sprintf('%d/%d',iM,iY);
    cwid{end+1} = 75;
    iM = iM + skip;
    if iM>12
        iM=mod(iM,12);
        iY = iY + 1;
    end
end

f = figure(14);
clf
set(f,'Position',[25 510 644 351]);
set(f,'menubar','none')
set(f,'name',sprintf('Salary Percent Covered') )
set(f,'numbertitle','off')

% Create the column and row names in cell arrays 
rnames = {};

% Create the uitable
t = uitable(f,'Data',d,...
            'ColumnName',cnames,... 
            'RowName',rnames,...
            'ColumnWidth',cwid);

% Set width and height
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);   

f.Position(3) = t.Extent(3) + 40;
f.Position(4) = t.Extent(4) + 40;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
foos = get(handles.figure1,'name');

if foos(end)=='*'
    ch = menu('Updates have not been saved. Save before quiting?','Yes','No','Cancel');
    if ch==3
        return;
    elseif ch==1
        menuSaveBudgetAs_Callback(hObject, eventdata, handles);        
    end
end

delete(hObject);


% --- Executes on button press in pushbuttonPersonnelNameDown.
function pushbuttonPersonnelNameDown_Callback(hObject, eventdata, handles)
global tB
global grants

idxGrant = tB.idxGrant;
pIdx = grants(idxGrant).personnelRange;

if ~isfield(grants(idxGrant),'personnel')
    grants(idxGrant).personnel = [];
end
nPersonnel = length( grants(idxGrant).personnel );

if pIdx(2)<nPersonnel
    grants(idxGrant).personnelRange = pIdx + 1;
    
    updateGrantPersonnel( handles );
end



% --- Executes on button press in pushbuttonPersonnelNameUp.
function pushbuttonPersonnelNameUp_Callback(hObject, eventdata, handles)
global tB
global grants

idxGrant = tB.idxGrant;
pIdx = grants(idxGrant).personnelRange;

if ~isfield(grants(idxGrant),'personnel')
    grants(idxGrant).personnel = [];
end
nPersonnel = length( grants(idxGrant).personnel );

if pIdx(1)>1
    grants(idxGrant).personnelRange = pIdx - 1;

    updateGrantPersonnel( handles );
end


% --- Executes on button press in checkboxGrantActive.
function checkboxGrantActive_Callback(hObject, eventdata, handles)
global tB
global grants

grants(tB.idxGrant).active = get(handles.checkboxGrantActive,'value');
updateSaveFileFlag( handles )



%PR_DOWNLOAD Load or download data and create dataset
%
%   [A,NEW] = PR_DOWNLOAD(URL,DATFILE,OPTIONS)
%
% INPUT
%   URL        URL of character file to be downloaded
%   DATFILE    Desired name of downloaded and uncompressed file
%              Default: name of the url-file, extended by .dat
%   OPTIONS    Structure with options used for parsing and constructing
%              a PRTools dataset
%
% OUTPUT
%   A          Dataset
%   NEW        Logical, TRUE if a new dataset has been created, FALSE if an
%              existing mat-file has been found and used.
%
% DESCRIPTION
% This routine facilitates downloading of character based datasets. DATFILE
% will be the name (or path with name) in which the URL is downloaded. If
% needed the URL file is unzipped and/or untarred first. After parsing a 
% PRTools dataset is constructed, stored in a mat-file (optional) and
% returned. The name of the mat-file is DATFILE extended by .mat.
%
% The directory specified in DATFILE, or if not supplied, the directory and
% the name of the calling routine, will be used for storing files. If the
% mat-file already exists it will be loaded and returned in A (no download
% and parsing). If DATFILE already exists it will be used (no download).
%
% OPTIONS should be a structure with the below fields, to be supplied in
% lower case. Missing fields are replaced by the given defaults.
% 
%   SIZE       = [];    Size of data to be downloaded, in MB. Not needed,
%                       just used to warn the user.
%   PARSE      = TRUE;  If FALSE, parsing is skipped. Just downloading and
%                       uncompression. A will be empty.
%   PARSEFUN   = [];    A handle of a user supplied parsing function. This
%                       function should operate on DATFILE (first parameter,
%                       substituted by PR_DOWNLOAD) and return a PRTools
%                       dataset. If PARSEFUN is not given, default parsing
%                       using PR_READDATASET will be used.
%   PARSEPARS  = {};    Cell array with additional parameters for PARSEFUN. 
%   FORMAT     = [];    Needed for default parsing, see PR_READDATASET.
%   NHEADLINES = 0;     Needed for default parsing, see PR_READDATASET. 
%   MISVALCHAR = '?';   Needed for default parsing, see PR_READDATASET.
%   DELIMETER  = ',';   Needed for default parsing, see PR_READDATASET.
%   EXTENSION  = 'dat'; Extension to be used for downloaded DATFILE.
%   MATFILE    = TRUE;  If FALSE, the dataset A will not be saved.
%   LABFEAT    = [];    Feature found in DATFILE and to be used as class
%                       label, see FEAT2LAB.
%   FEATNAMES  = [];    Desired feature names of dataset A, see SETFEATLAB.
%   CLASSNAMES = [];    Class names to be stored in A, see SETLABLIST.
%   USER       = [];    Additional information to be stored in the
%                       user-field of A, see SETUSER.
%   DSETNAME   = [];    Desired name of the dataset A.
%
%
% EXAMPLE
%  url = 'http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data';
%  opt.extension = 'dat'; % create iris.dat
%  opt.labfeat   = 5;     % use feature 5 for labeling
%  opt.matfile   = false; % don't create a mat-file
%  c = pr_download(url,[],opt) % load Iris dataset from UCI and parse
%
% SEE ALSO
% DATASETS, SETFEATDOM, GETFEATDOM, FEAT2LAB

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

%%
function [a,new] = pr_download(url,datname,varargin)

if nargin >= 3
  % this can be removed when all mfiles in prdatasets call the new version
  % of pr_download_uci
  if ~isstruct(varargin{1}) && ~isempty(varargin{1}) && isnumeric(varargin{1})
    [a,new] = pr_download_old(url,datname,varargin{:});
    return
  else
    opt = varargin{1};
  end
end

if nargin < 3, opt = []; end
if nargin < 2, datname = []; end

opt = download_opt(opt);  % set defaults where necessary

%% find directory to be used
if isempty(datname)
  datname = callername;
  dirname = fileparts(which(datname));
else
  [dirname,datname] = fileparts(datname);
end

%% set all necessary filenames
[~,urlname,urlext] = fileparts(url);
if isempty(datname)
  % will only be empty if called from command line
  datname = urlname;
  dirname = pwd;
end
urlname = [urlname urlext]; % name of file to be downloaded
matname = [datname '.mat']; % name of mat-file to be created
datname = [datname '.' opt.extension]; % name of datfile to be created
urlfile = fullfile(dirname,urlname);   % temp file for download
datfile = fullfile(dirname,datname);   % unpacked urlfile
matfile = fullfile(dirname,matname);   % final matfile

%% load mat-file if it exist
new = false; 
if exist(matfile,'file') == 2
  s = load(matfile);
  f = fieldnames(s);
%   a = getfield(s,f{1});
  a = s.(f{1});
  return  % we are done!!
end 

%% download the data file  if it doesn't exist
if exist(datfile,'file') ~= 2        % if datfile does not exist ...
  ask_download(urlname,opt.size);

  if ~usejava('jvm') && isunix 
    stat = unix(['wget -q -O ' urlfile ' ' url]);
    status = (stat == 0);
  else
    [~,status] = urlwrite(url,urlfile);
  end
  if status == 0
    error(['Server unreachable or file not found: ' url])
  end
  
  % assume file is created, uncompress if needed
  % delete compressed file
  if strcmp(urlext,'.zip')
    disp('Decompression ....')
    if ~usejava('jvm') && isunix
      unix(['unzip ' urlfile ' -d ' datfile]);
    else
      unzip(urlfile,datfile);
    end
  elseif strcmp(urlext,'.gz')
    disp('Decompression ....')
    gunzip(urlfile,datfile);
  elseif strcmp(urlext,'.tar') || strcmp(urlext,'.tgz') || strcmp(urlext,'.tar.gz')
    disp('Decompression ....')
    untar(urlfile,datfile);
  elseif ~strcmp(urlfile,datfile)
    copyfile(urlfile,datfile)
  end
  if exist(datfile,'dir') == 7
    dirn = dir(datfile);
    copyfile(fullfile(datfile,dirn(3).name),[datfile 'tmp']);
    delete([datfile '/*']);
    rmdir(datfile);
    copyfile([datfile 'tmp'],datfile);
    delete([datfile 'tmp']);
  end 
  if ~strcmp(urlfile,datfile)
    delete(urlfile);
  end
end

if ~opt.parse
  % no parsing desired, we are done
  return
end

%% datfile should now be there, read and convert to dataset  
disp('Parsing ...')
if isempty(opt.parsefun)
  a = pr_readdataset(datfile,opt.nheadlines,opt.delimeter, ...
                   opt.misvalchar,opt.format);
else
  % user defined parsing
  a = opt.parsefun(datfile,opt.parsepars{:});
end

%% set dataset fields
if ~isempty(opt.labfeat) && opt.labfeat > 0
  a = feat2lab(a,opt.labfeat);
end
if ~isempty(opt.classnames)
  a = setlablist(a,opt.classnames);
end
if ~isempty(opt.featnames)
  a = setfeatlab(a,opt.featnames);
end
if ~isempty(opt.user)
  a = setuser(a,opt.user);
end
if ~isempty(opt.user)
  a = setuser(a,opt.user);
end
if ~isempty(opt.dsetname)
  a = setname(a,opt.dsetname);
else
  a = setname(a,callername);
end

%% save if desired
if opt.matfile 
  save(matfile,'a');
  new = true;
end

return


function ask_download(urlname,size)
%% user controlled downloading
  global ASK
  if isempty(ASK)
    ASK = true;
  end
  
  if ASK
    if ~isempty(size) && size ~= 0
      siz = ['(' num2str(size) ' MB)']; 
    else
      siz = '';
    end
    q = input(['Dataset is not available, OK to download ' siz ' [y]/n ?'],'s');
    if ~isempty(q) && ~strcmp(q,'y')
      error('No dataset')
    end
  else
    siz = [];
  end
  
  if isempty(siz)
    disp(['Downloading ' urlname ' ....'])
  else
    disp(['Downloading ' urlname ' (' num2str(siz) ' MB) ....'])
  end
  
return

function opt = download_opt(opt_given)
%%
  opt.size       = [];
  opt.parse      = true;
  opt.parsefun   = [];
  opt.parsepars  = {};
  opt.format     = []; 
  opt.nheadlines = 0; 
  opt.misvalchar = '?'; 
  opt.delimeter  = ','; 
  opt.extension  = 'dat'; 
  opt.matfile    = true; 
  opt.labfeat    = []; 
  opt.featnames  = '';
  opt.classnames = '';
  opt.user       = [];
  opt.dsetname   = '';

  

  if (~isempty(opt_given))
    if (~isstruct(opt_given))
      error('OPTIONS should be a structure with at least one of the following fields: q, init, etol, optim, maxiter, itmap, isratio, st or inspect.');
    end
    fn = fieldnames(opt_given);
    if (~all(ismember(fn,fieldnames(opt))))
      error('Wrong field names; valid field names are: q, init, optim, etol, maxiter, itmap, isratio, st or inspect.')
    end 
    for i = 1:length(fn)
      opt.(fn{i}) = opt_given.(fn{i});
    end
  end
  
return

function name = callername
%%
[ss,~] = dbstack;
if length(ss) < 3
	name = [];
else
	name = ss(3).name;
end

function [a,new] = pr_download_old(url,varargin)
%% This is the old version of pr_download, to be called from the old 
%  version of pr_download_uci only (inside it). It can be removed when all
%  mfiles in prdataset make the new call to  pr_download_uci 
%
%PR_DOWNLOAD Load or download data and create dataset
%
%   A = PR_DOWNLOAD(URL,FILE,SIZE,NHEAD,FORMAT,MISVALCHAR,DELCHAR,NOSAVE)
%
% INPUT
%   URL          URL of character file to be downloaded
%   FILE         Filename to download
%   SIZE         Size of data to be downloaded in Mbytes
%   NHEAD        # of headerlines to skip
%   FORMAT       String or cell array defining the format
%                (default, automatic)
%   MISVALCHAR   Character used for missing values
%   DEL          Character delimiter used in the file (default ',')
%   NOSAVE       Logical, if TRUE A will not be saved, default FALSE
%
% OUTPUT
%   A            Unlabeled dataset
%
% DESCRIPTION
% This routine facilitates downloading of character based datasets. FILE
% should be the name (or path with name) in which the URL is downloaded. If
% needed the URL file is unzipped and/or untarred first. If FILE already
% exists it is used (no downloading). The file is parsed by TEXTSCAN using
% the format given in FORMAT (see TEXTSCAN) and the delimiter specified in
% DEL. If FORMAT is not given an attempt is made to derive it
% automatically.
%
% In case a mat-file name [FILE '.mat'] is found it will be used instead of
% downloading.
%
% Columns (features) given as characters (the '%s' fields in FORMAT) will 
% be stored as text based features. They will be replaced by indices to a
% set of strings stored in the corresponding feature domain (see
% SETFEATDOM). Use FEAT2LAB to use such a feature for labeling the dataset,
% see the below example.
%
% EXAMPLE
%  url = 'http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data';
%  c = pr_download(url,'iris.dat',[]); % load Iris dataset from UCI
%  % the labels are set as string (char) features in c(:,5)
%  a = feat2lab(c,5);  % use feature 5 for labeling
%
% SEE ALSO
% DATASETS, SETFEATDOM, GETFEATDOM, FEAT2LAB

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


[~,urlname,urlext] = fileparts(url);
[datname,siz,nhead,form,misval,del,nosave] = setdefaults(varargin,urlname,1,0,[],'?',',',false);

[dirname,datname] = fileparts(datname);
if isempty(dirname)
  dirname = fileparts(which(mfilename));
  % dirname = pwd;
end
urlname = [urlname urlext]; % name of file to be downloaded
matname = [datname '.mat']; % name of mat-file to be created
datname = [datname '.dat']; % name of datfile to be created
urlfile = fullfile(dirname,urlname); % temp file for download
datfile = fullfile(dirname,datname); % unpacked urlfile
matfile = fullfile(dirname,matname); % final matfile

new = true;                          % if matfile exists, use it
if exist(matfile,'file') == 2
  s = load(matfile);
  f = fieldnames(s);
  a = s.(f{1});
  new = false;
  return
end

if exist(datfile,'file') ~= 2        % if datfile does not exist ...
  ask_download_old(siz);
  if isempty(siz) || siz == 0
    disp(['Downloading ' urlname ' ....'])
  else
    disp(['Downloading ' urlname ' (' num2str(siz) ' MB) ....'])
  end

  %disp(['Downloading ' urlname ' ....']) % download into urlfile
  if ~usejava('jvm') && isunix 
    stat = unix(['wget -q -O ' urlfile ' ' url]);
    status = (stat == 0);
  else
    [~,status] = urlwrite(url,urlfile);
  end
  if status == 0
    error(['Server unreachable or file not found: ' url])
  end
  
  % assume file is created, uncompress if needed
  % delete compressed file
  if strcmp(urlext,'.zip')
    disp('Decompression ....')
    if ~usejava('jvm') && isunix
      unix(['unzip ' urlfile ' -d ' datfile]);
    else
      unzip(urlfile,datfile);
    end
  elseif strcmp(urlext,'.gz')
    disp('Decompression ....')
    gunzip(urlfile,datfile);
  elseif strcmp(urlext,'.tar') || strcmp(urlext,'.tgz') || strcmp(urlext,'.tar.gz')
    disp('Decompression ....')
    untar(urlfile,datfile);
  elseif ~strcmp(urlfile,datfile)
    copyfile(urlfile,datfile)
  end
  if exist(datfile,'dir') == 7
    dirn = dir(datfile);
    copyfile(fullfile(datfile,dirn(3).name),[datfile 'tmp']);
    delete([datfile '/*']);
    rmdir(datfile);
    copyfile([datfile 'tmp'],datfile);
    delete([datfile 'tmp']);
  end 
  if ~strcmp(urlfile,datfile)
    delete(urlfile);
  end
end

% datfile should now be there, read and parse it
fid = fopen(datfile);
if isempty(form)        % if no format given ...
  for j=1:nhead+1
    s = fgetl(fid);     % derive it from the first nonheader line
  end        
  s = mytextscan(s,'c',del,0); % use all %s for time being
  form = getform(s);    % convert fields to %n where appropriate
  fseek(fid,0,-1);      % restart
end

disp('Parsing ...')
c = mytextscan(fid,strrep(form,'n','s'),del,nhead);
a = cell2dset(c,form,misval);

if ~nosave % don't save if not needed (e.g. called by pr_download_uci)
  save(matfile,'a');
end

return

function ask_download_old(size)

  global ASK
  if isempty(ASK)
    ASK = true;
  end
  
  if ASK
    if ~isempty(size)
      siz = ['(' num2str(size) ' MB)']; 
    else
      siz = '';
    end
    q = input(['Dataset is not available, OK to download ' siz ' [y]/n ?'],'s');
    if ~isempty(q) && ~strcmp(q,'y')
      error('Dataset not found')
    end
  end
  
return

function form = getform(s)
s = char(s{1});
form = repmat('n',1,size(s,1));
for j=1:size(s,1)
  %n = textscan(char(s(j,:)),'%n');
	if ~isempty(regexp(s(j,:),'[^0-9+-.eE ]','once'))
    form(j) = 'c';
  end
end

function s = mytextscan(fid,forms,del,nhead)

form = repmat('%%',1,numel(forms));
form(2:2:end) = forms;
forms = strrep(form,'c','s');
if del == ' '
  s = textscan(fid,forms,'Headerlines',nhead);
else
  s = textscan(fid,forms,'Delimiter',del,'Headerlines',nhead);
end
if ~ischar(fid);
  fclose(fid);
end
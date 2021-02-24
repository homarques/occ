%PRDATASETS Checks availability of a PRTOOLS dataset (PRTools5 version!)
%
%   PRDATASETS
%
% Checks the availability of the PRDATASETS directory, downloads the
% Contents file and m-files if necessary and adds it to the search path. 
% Lists Contents file.
%
%   PRDATASETS ALL
%
% Download and save all data related to the m-files.
%
%		A = PRDATASETS(DSET)
%
% Checks the availability of the particular dataset DSET. DSET should be
% the name of the m-file. If it does not exist in the 'prdatasets'
% directory an attempt is made to download it from the PRTools web site.
% It is returned in A and the PRDATASETS directory is added to the path.
%
%		PRDATASETS(DSET,SIZE,URL)
%
% This command should be used inside a PRDATASETS m-file. It checks the 
% availability of the particular dataset file and downloads it if needed. 
% SIZE is the size of the dataset in Mbyte, just used to inform the user.
% In URL the web location may be supplied. Default is 
% http://prtools.tudelft.nl/prdatasets/DSET.mat
% Downloading is done interactively and should be approved by the user.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, PRDATAFILES

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function a = prdatasets(dset,siz,url)

global ASK
if isempty(ASK), ASK = true; end 

if nargin < 3, url = []; end
if nargin > 0 && isempty(url)
  url = ['http://prtools.tudelft.nl/prdatasets/' dset '.mat']; 
end
if nargin < 2, siz = []; end
if nargin < 1, dset = []; end
prtoolsdir = fileparts(which(mfilename));
toolsdir   = fileparts(prtoolsdir);
dirname    = fullfile(toolsdir,'prdatasets');

if exist('sonar','file') ~= 2
  if exist(dirname) ~= 7
    path = input(['The directory prdatasets is not found in the search path.' ... 
      prnewline 'If it exists, give the path, otherwise hit the return for an automatic download.' ...
      prnewline 'Path to prdatasets: '],'s');
    if ~isempty(path)
      dirname = path;
      addpath(dirname);
      feval(mfilename,dset,siz);
      return
    else
      % Load all m-files from prdataset5 !!!
      [ss,dirname] = prdownload('http://prtools.tudelft.nl/prdatasets5/prdatasets.zip',dirname);
      addpath(dirname)
    end
  else
    addpath(dirname);
  end
end

if isempty(dset) % just list Contents file
	type(fullfile(dirname,'Contents.m'))
	
elseif ~isempty(dset) && nargin == 1 % check / load m-file
	% this just loads the m-file in case it does not exist
  if strcmpi(dset,'all')
		if exist(dirname) ~= 7
			% no prdatasets in the path, just start
			feval(mfilename);
    end
    % load all data without asking
    ASK = false;
    files = dir([dirname '/*.m']);
    files = char({files(:).name});
    L = strmatch('Contents',files); % no data for Contents
    L = [L; strmatch('pr',files)];  % no data for support routines
    files(L,:) = [];
    for j=1:size(files,1)
      cmd = deblank(files(j,:));
      disp([prnewline cmd])
      feval(cmd(1:end-2));
    end
    ASK = true;
    
	elseif exist(fullfile(dirname,dset),'file') ~= 2 
    % load m-file
		prdownload(['http://prtools.tudelft.nl/prdatasets5/' dset '.m'],dirname);
		prdownload('http://prtools.tudelft.nl/prdatasets5/Contents.m',dirname);
    feval(dset);   % takes care that data is available as well
  else
    % existing dataset command found, load it.
    a = feval(dset);
	end
	
else   % load the data given by the url
	
	[pp,ff,xx] = fileparts(url);
	if exist(fullfile(dirname,[ff xx]),'file') ~= 2
    if ASK
      siz = ['(' num2str(siz) ' MB)'];
      q = input(['Dataset is not available, OK to download ' siz ' [y]/n ?'],'s');
      if ~isempty(q) && ~strcmp(q,'y')
        error('Dataset not found')
      end
    end
		prdownload(url,dirname);
    if isoctave % give it some time to synchronize
      rehash
      pause(5);
    end
		disp(['Dataset ' dset ' ready for use'])
	end
end

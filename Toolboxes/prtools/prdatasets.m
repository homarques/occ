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
% http://prtools.tudelft.nl/prdatasets5/DSET.mat
% Downloading is done interactively and should be approved by the user.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATASETS, PRDATAFILES

% Copyright: R.P.W. Duin

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
datadir    = fullfile(dirname,'data');

if exist('sonar','file') ~= 2
  if exist(dirname,'dir') ~= 7
    path = input(['The directory prdatasets is not found in the search path.' ... 
      prnewline 'If it exists, give the path, otherwise hit the return for an automatic download.' ...
      prnewline 'Path to prdatasets: '],'s');
    if ~isempty(path)
      dirname = path;
      addpath(dirname);
      feval(mfilename,dset,siz);
      return
    else
      % Load all m-files !!!
      [~,dirname] = prdownload('http://prtools.tudelft.nl/files/prdatasets.zip',dirname);
    end
  end
  if exist(datadir,'dir') ~= 7
    mkdir(datadir);
  end
  addpath(dirname,datadir);
end

if isempty(dset) && nargout == 0 % just list Contents file
	help(fullfile(dirname,'Contents'))
	
elseif ~isempty(dset) && nargin == 1 % check / load m-file
  % outdataed option, m-filoes should be available
	% this just loads the m-file in case it does not exist
  if strcmpi(dset,'all')
    error('This option is not supported anymore')
	elseif exist(fullfile(dirname,dset),'file') ~= 2 
    % outdated option, m-files should be available
    error(['No command found for downloading ' dset])
    % load m-file
% 		prdownload(['http://prtools.tudelft.nl/prdatasets5/' dset '.m'],dirname);
% 		prdownload('http://prtools.tudelft.nl/prdatasets5/Contents.m',dirname);
%     feval(dset);   % takes care that data is available as well
  else
    % existing dataset command found, load it.
    a = feval(dset);
	end
	
else   % load the data given by the url
	
	[~,ff,xx] = fileparts(url);
  datfile = [fullfile(datadir,ff) xx];
	if exist([datfile xx],'file') ~= 2
    if ASK
      siz = ['(' num2str(siz) ' MB)'];
      q = input(['Dataset is not available, OK to download ' siz ' [y]/n ?'],'s');
      if ~isempty(q) && ~strcmp(q,'y')
        error('Dataset not found')
      end
    end
		prdownload(url,datadir);
    disp(['Dataset ' dset ' ready for use'])
  end
  if nargout > 0
    a = pr_dataset(datfile);
  end
  
end

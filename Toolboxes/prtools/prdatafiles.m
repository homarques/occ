%PRDATAFILES Checks availability of a PRTools datafile (PRTools5 version!)
%
%   PRDATAFILES
%
% Checks the availability of the PRDATAFILES directory, downloads the
% Contents file and m-files if necessary and adds it to the search path. 
% Lists Contents file.
%
%   PRDATAFILES ALL
%
% Download and save all data related to the m-files (very time consuming!)
%
%		A = PRDATAFILES(DFILE)
%
% Checks the availability of the particular datafile DFILE. DFILE should be
% the name of the m-file. If it does not exist in the 'prdatafiles'
% directory an attempt is made to download it from the PRTools web site.
% It is returned in A and the PRDATAFILES directory is added to the path.
%
%   PRDATAFILES(DFILEDIR,SIZE,URL)
%
% This command should be used inside a PRDATAFILES m-file. It checks the 
% availability of the particular datafile directory DFILEDIR and downloads 
% it if needed. SIZE is the size of the datafile in Mbyte, just used to 
% inform the user. In URL the web location may be supplied. Default is 
% http://prtools.tudelft.nl/prdatafiles/DFILEDIR.zip
%
% All downloading is done interactively and should be approved by the user.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATAFILES, PRDATASETS, PRDOWNLOAD

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function a = prdatafiles(dfile,siz,url)

global ASK
if isempty(ASK), ASK = true; end 

if nargin < 1, dfile = ''; end
if nargin < 2, siz = []; end
if nargin < 3 || isempty(url)
	url = ['http://prtools.tudelft.nl/prdatafiles/' dfile '.zip']; 
end
prtoolsdir = fileparts(which(mfilename));
toolsdir   = fileparts(prtoolsdir);
dirname    = fullfile(toolsdir,'prdatafiles');
  
if exist('highway','file') ~= 2
  if exist(dirname,'dir') ~= 7
    path = input(['The directory prdatafiles is not found in the search path.' ... 
      prnewline 'If it exists, give the path, otherwise hit the return for an automatic download.' ...
      prnewline 'Path to prdatafiles: '],'s');
    if ~isempty(path)
      addpath(path);
      feval(mfilename,dfile,siz);
      return
    else
      % Load all m-files from prdatafiles5 !!!
      [~,dirname] = prdownload('http://prtools.tudelft.nl/prdatafiles5/prdatafiles.zip',dirname);
      addpath(dirname)
      if isoctave
        rehash
        pause(2);
      end
    end
  else
    addpath(dirname);
  end
end

if isempty(dfile) % just list Contents file
	type(fullfile(dirname,'Contents.m'))
	
elseif ~isempty(dfile) && nargin == 1 % check / load m-file
	% this just loads the m-file in case it does not exist
	if strcmpi(dfile,'all')
		if exist(dirname) ~= 7
			% no prdatafiles in the path, just start
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
    
	elseif exist(['prdatafiles/' dfile],'file') ~= 2 
    % load m-file
		prdownload(['http://prtools.tudelft.nl/prdatafiles5/' dfile '.m'],dirname);
		prdownload('http://prtools.tudelft.nl/prdatafiles5/Contents.m',dirname);
    feval(dfile);   % takes care that data is available as well
    
  else
    % existing datafile found, load it.
    a = feval(dfile);
	end
	
else   % dfile is now the name of the datafile directory
	     %It might be different from the m-file, so we cann't check it.
	if exist(fullfile(dirname,dfile),'dir') ~= 7
    if ASK
      csiz = ['(' num2str(siz) ' MB)'];
      q = input(['Datafile is not available, OK to download ' csiz ' [y]/n ?'],'s');
      if ~isempty(q) && ~strcmp(q,'y')
        error('Datafile not found')
      end
    end
		prdownload(url,dirname,siz);
    if isoctave % give it some time to synchronize
      rehash
      pause(2);
    end
		disp(['Datafile ' dfile ' ready for use'])
	end
end

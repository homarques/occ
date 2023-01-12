%PRDATAFILE Datafile class constructor. This is an extension of PRDATASET.
%
%    A = PRDATAFILE(DIRECTORY,TYPE,READCMD,P1,P2,P3, ...)
%    A = PRDATAFILE(DIRECTORY,READCMD,P1,P2,P3, ...)
%    A = PRDATAFILE(DIRECTORY,C)
%
% INPUT
%   DIRECTORY - Data directory
%   TYPE      - Datafile type (default 'raw')
%   READCMD   - Command (m-file) for reading files in DIRECTORY.
%               Default: IMREAD
%   C         - Cell array
%   P1,P2,P3  - Optional parameters of READCMD
%
% OUTPUT
%   A         - Datafile
%
% DESCRIPTION
% Datafiles prepare and enable the handling of datasets distributed over
% multiple files, i.e. all files of DIRECTORY. Datafiles inherit all
% dataset fields. Consequently, most commands defined on datasets also
% operate on datafiles with the exception of a number of trainable
% mappings. There are five types of datafiles defined (TYPE):
% 'raw'          Every file is interpreted as a single object in the
%                dataset. All objects in the same sub-directory of
%                DIRECTORY receive the name of that sub-directory as class
%                label. Files may be preprocessed before conversion to
%                dataset by FILTM. At conversion time they should have the
%                same size (number of features).
% 'cell'         All files in DIRECTORY should be mat-files containing just
%                a single variable being a cell array. Its elements are
%                interpreted as objects. The file names will be used as
%                labels during construction. This may be changed by the
%                user afterwards.
% 'pre-cooked'   It is expected that READCMD outputs for all files a
%                dataset with the same label list and the same feature size.
% 'half-baked'   All files in DIRECTORY should be mat-files,
%                containing a single dataset. All datasets should have the 
%                same label list and the same feature size.
% 'mature'       This is a datafile directory constructed by SAVEDATAFILE. 
%                It executes all processing before creation.
%
%
% For all datafile types holds that execution of mappings (by FILTM or 
% otherwise and conversion to a dataset (by DATASET) is postponed as long as 
% possible. Commands are stored inside one of the datafile fields. 
% Consequently, errors might be detected at a later stage.
%
% In case a cell array C is given as second parameter the datafile is
% constructed with a single file with content C. C can also be a cell array
% of cell arrays, one per class.
%
% The construction by DATAFILE still might be time consuming as for some types
% all files have to be checked. For that reason PRTools attempts to save a 
% mat-file with the DATAFILE definition in DIRECTORY. If it is encountered, it 
% is loaded avoiding a redefinition. 
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES, DATASETS, MAPPINGS, FILTM, SAVEDATAFILE, CREATEDATAFILE

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = prdatafile(datadir,type,readcmd,varargin)
    
  if nargin > 0 && isstruct(datadir)
    % convert structure to datafile
    b = datadir;
    if isfield(b,'prdataset')
      % a datafile that fits the prtools5 version
      % for some reason we receive a structure instead of a datafile
      % normal conversion is needed
      datasetfield = getfield(b,'prdataset');
      b = rmfield(b,'prdataset');
    elseif isfield(b,'dataset')
      % datafile of an old prtools version
      datasetfield = getfield(b,'dataset');
      b = rmfield(b,'dataset');
    end
    b = class(b,'prdatafile',prdataset);
    b.postproc = prmapping(b.postproc);
    b = setfield(b,'prdataset',prdataset(struct(datasetfield)));
    b.prdataset.lablist = datasetfield.lablist;
    b.prdataset.nlab = datasetfield.nlab;
    return
  end
  
  if nargin < 3, readcmd = 'imread'; end
  if nargin < 2, type = 'raw'; end
  
  if iscell(type)
    if exist(datadir,'dir') ~= 7
      mkdir(datadir);
    end
    if iscell(type{1,1})
      % cell array of cell arrays, one per class
      for j=1:numel(type)
        a = type{j};
        save(fullfile(datadir,['lab' num2str(j)]),'a');
      end
    else
      if size(type,1) == 1
        type = type';
      end
      for j=1:size(type,2)
        a = type(:,j);
        save(fullfile(datadir,['lab' num2str(j)]),'a');
      end
    end
    b = prdatafile(datadir,'cell');
    return
  end
      
  
  b.files   = []; % file names
  b.rootpath= []; % rootpath
  b.type    = []; % datafile type
  b.preproc = []; % desired preprocessing
  b.postproc= prmapping([]); % stored mappings for postprocessing
  
  b = class(b,'prdatafile',prdataset);
  superiorto('double','prdataset');
  
  if nargin == 0 %return empty datafile in case of no input parameters
    return
  end

  b = set(b,'version',prtver);
  b.type = type;
  
  if isempty(datadir) % return empty datafile
    return
  elseif ~ischar(datadir)
    error('Directory should be given in string')
  elseif exist(datadir) == 7
    ; % OK
  else
    if exist(datadir) == 0
      error('Directory not found')
    else
      error('Input is confusing (e.g. a Matlab command). Give full path or rename directory')
    end
  end
  
%  if isempty(strmatch(type,strvcat('raw','pre-cooked','half-baked','mature'),'exact'))
%    error('Non-existing datafile type supplied')
%  end
    
  % make sure datadir contains full path
  if (datadir(end) == filesep) || (datadir(end) == '/')
    datadir(end) = [];
  end
  dirinfo = what(datadir);
  [rpath,name,ext] = fileparts(dirinfo(end).path);
  rootpath = dirinfo(end).path;
  b.rootpath = rootpath;
  
  dirname = [name ext];
  
  matname = fullfile(datadir,[dirname '.mat']);
  if exist(matname,'file')==2 && ~strcmp(type,'patch') % pre-defined datafiles expected here
    % datafile already created and available as mat-file?
    s = prload(fullfile(datadir,[dirname '.mat']));  % yes, load it
    f = fieldnames(s);
    b = s.(f{1});
    b = setident(b); % convert old ident structures
    b.rootpath = rootpath;
  elseif strcmp(type,'raw')
    lablist = dirlist(datadir); % subdirs in datadir become labels
    b = setfiles(b,lablist); % in setfiles the real work is done
    if isempty(b.prdataset.ident)
      error('No proper (non-mat) files found in directory. Impossible to construct raw datafile.')
    end
    b = setpreproc(b,readcmd,varargin);
    b.prdataset = setlablist(b.prdataset,lablist);
    nlab = getident(b,'file_index');
    nlab = nlab(:,1) - 1;
    b.prdataset = setnlab(b.prdataset,nlab);
    b.prdataset = setobjsize(b.prdataset,length(nlab));
    b = set(b,'name',dirname);
    savemat(matname,b);
  elseif strcmp(type,'cell')
    b = setfiles(b,datadir);
    lablist = getfiles(b);
    for j=1:length(lablist)
      [pp,name,ext] = fileparts(lablist{j});
      lablist{j} = name;
    end
    b.prdataset = setlablist(b.prdataset,lablist);
    nlab = getident(b,'file_index');
    nlab = nlab(:,1);
    b.prdataset = setnlab(b.prdataset,nlab);
    b.prdataset = setobjsize( b.prdataset,length(nlab));
    b = set(b,'name',dirname);
    savemat(matname,b);
  elseif strcmp(type,'patch') % is this really used somewhere?
    if isempty(varargin) || length(varargin) < 3
      error('No or insufficient patch parameters found') 
    elseif length(varargin) == 3
      b.preproc(1).preproc = readcmd;
      b.preproc(1).pars = [];
      b.preproc(2).preproc = 'im_patch';
      b.preproc(2).pars = varargin;
    else
      b.preproc(1).preproc = readcmd;
      b.preproc(1).pars = varargin(1:end-3);
      b.preproc(2).preproc = 'im_patch';
      b.preproc(2).pars = varargin(end-2:end);
    end
    b = setfiles(b,datadir);
    lablist = getfiles(b);
    for j=1:length(lablist)
      [pp,name,ext] = fileparts(lablist{j});
      lablist{j} = name;
    end
    b.prdataset = setlablist(b.prdataset,lablist);
    nlab = getident(b,'file_index');
    nlab = nlab(:,1);
    b.prdataset = setnlab(b.prdataset,nlab);
    b.prdataset = setobjsize( b.prdataset,length(nlab));
    b.prdataset = setfeatsize(b.prdataset,getfeatsize(b));
    b = set(b,'name',dirname);
    %savemat(matname,b);      % better not to save as same dir may be used
                              % for other datafiles
  elseif strcmp(type,'half-baked') % combine all mat-files, expect datasets
    b = setfiles(b,datadir);
    b = set(b,'name',dirname);
    L = getident(b);  % rank objects according to idents
    [LL,J] = sort(L); % this is relevant for dissimilarity matrices
    %b = b(J,:)       % I want this, but ...
    data = b.prdataset; % Matlab forces me to do it like this
    data = data(J,:);
    b.prdataset = data;
    savemat(matname,b);
  elseif strcmp(type,'pre-cooked')
    b.preproc.preproc = readcmd;
    b.preproc.pars = varargin;
    b = setfiles(b,datadir);
    b = set(b,'name',dirname);
    savemat(matname,b);
  elseif strcmp(type,'mature')
    % mature file with missing mat-file
    error('No proper mat-file found')
  elseif nargin > 1
    % second parameter is not a proper type
    % may be it is a read-command for raw datafiles, try it
    try
      if nargin == 2
        b = prdatafile(datadir,'raw',type);
      elseif nargin == 3
        b = prdatafile(datadir,'raw',type,readcmd);
      else
        b = prdatafile(datadir,'raw',type,{readcmd varargin{:}});
      end
    catch
      error('Unparsable arument list in call to prdatafile()')
    end
  else
    error('Data directory not found or wrong')
  end
        
  % We are done, return datafile.
  
return

function names = dirlist(dirpath)
% directory name and path from root
    dirpath = deblank(dirpath);
    ss = what(dirpath);
    [rootpath,name,ext] = fileparts(ss(end).path);
    dirname = [name ext];
    
  % remove all .-files / dirs
    ddir = dir(dirpath);
    names = {ddir(:).name};
    cnames = char(names);
  % remove all .-files / dirs
    J = find(cnames(:,1) == '.');
    names(J) = [];
    cnames(J,:) = [];
  % get rid of Windows db files
    J = strmatch('Thumbs.db',cnames,'exact');
    names(J) = [];
  % we now have all filenames and dirnames in dirpath
  % find out whether they are proper
  % and what are the files and what the directories
    ftype = zeros(length(names),1);
    for j=1:length(names)
      ftype(j) = exist(fullfile(rootpath,dirname,names{j}));
    end
    if ~all(ftype == 2 | ftype == 7)
      error('Files should be ordinary data files or directories')
    end
    J = find(ftype == 7);
    names = names(J);

    function savemat(matname,b)
    try
      save(matname,'b');
    catch
      prwarning(1,'Datafile could not be saved');
    end
    
    

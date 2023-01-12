%SETFILES Set files (directory names) for datafile
%
%   A = SETFILES(A,DIRNAMES)
%
% INPUT
%   A         - Datafile
%   DIRNAMES  - Character array with directory (or file) names
%
% OUTPUT
%   A         - Datafile
%
% DESCRIPTION
% Set the filenames for a datafile. This constructs a new datafile,
% except for the PREPROC and POSTPROC fields.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function a = setfiles(a,dirs)
		
	if nargin < 2    % if not given
    
    a.files = [];  % empty field
    
	else
    %n = length(dirs);         % number of directories (raw) or files (mature)
    if strcmp(a.type,'raw')    % this is a raw datafile
			dirs = {''  dirs{:}};
      n = length(dirs);        % number of sub-directories
      dirsizes = cell(1,n);
      dirnames = cell(1,n);
      prprogress([],'Checking %5i directories: \n',n);
      prprogress([],'%5i\n',0);
			if n > 1
				s = sprintf('Checking %5i directories: ',n);
				prwaitbar(n,s);
			end
			for j=1:n               % find the files in each dir
       	prprogress([],'%5i\n',j);
				if n > 1, prwaitbar(n,j,[s int2str(j)]); end
				fnames = dir(fullfile(a.rootpath,dirs{j}));          
				L = ([fnames.isdir] == 0); % throw out subdirs
      	fnames = char(fnames(L,:).name);
				if ~isempty(fnames)
					% remove all .-files / dirs
					J = (fnames(:,1) == '.');
					fnames(J,:) = [];
				end
				[n1,n2] = size(fnames);
				xx = [fnames repmat(' ',n1,1)]';
				L = ceil(findstr('mat ',xx(:)')/(n2+1)); % throw out mat-files
        if ~isempty(L)
          prwarning(1,'Matfiles found in subdirs; first variable will be converted to double')
          %fnames(L,:) = [];
        end
				L = strmatch('Thumbs.db',fnames,'exact');
				fnames(L,:) = []; % get rid of Windows Thumb files
				nfiles = size(fnames,1);
				findex = [repmat(j,nfiles,1) [1:nfiles]'];
				dirsizes{j} = findex;
				dirnames{j} = fnames;
			end
			file_index = vertcat(dirsizes{:}); % create file_index
                                     % column 1: index in dirs (-->a.files)
                                     % column 2: index in dirlist of dir
																		 
      a.prdataset = setident(a.prdataset,[1:size(file_index,1)]','ident'); % obj number
		  a.prdataset = setident(a.prdataset,file_index,'file_index');    % file_index
			a.files = {dirs,dirnames};
      
		elseif strcmp(a.type,'patch')
			fnames = dir(a.rootpath);          
			L = [fnames.isdir] == 0; % throw out subdirs
    	fnames = char(fnames(L,:).name);
			[n1,n2] = size(fnames);
			xx = [fnames repmat(' ',n1,1)]';
			L = ceil(findstr('mat ',xx(:)')/(n2+1)); % throw out mat-files
			fnames(L,:) = [];
			if isempty(fnames)
				error('No files found in top directory')
			end
			fnames = cellstr(fnames);
			n = size(fnames,1);       % number of files
      dirsizes = cell(1,n);
      prprogress([],'Checking %5i files: \n',n);
      prprogress([],'%5i\n',0);
			if n > 1
				s = sprintf('Checking %5i files: ',n);
				prwaitbar(n,s);
			end
			preproc = a.preproc;
			for j=1:n               % find the cells in each file
       	prprogress([],'%5i\n',j);
				if n > 1, prwaitbar(n,j,[s int2str(j)]); end
				fname = fullfile(a.rootpath,fnames{j});
  			if isempty(preproc(1).preproc)
    			[pathstr,name,fext] = fileparts(fname);
					d = imread(fname,fext(2:end)); 
				else
					d = feval(preproc(1).preproc,fname,preproc(1).pars{:});
				end
				npatch = im_patch(d,preproc(1,2).pars{:},0);
				findex = [repmat(j,npatch,1) [1:npatch]'];
				dirsizes{j} = findex;
			end
			file_index = vertcat(dirsizes{:}); % create file_index
                                     % column 1: index in files 
                                     % column 2: index in cells
      a.prdataset = setident(a.prdataset,[1:size(file_index,1)]','ident'); % obj number
		  a.prdataset = setident(a.prdataset,file_index,'file_index');    % file_index
			a.files = fnames;
			
    elseif strcmp(a.type,'cell')
			files = dir([a.rootpath '/*.mat']);
			files = {files(:).name};
			n = length(files);       % number of files
      dirsizes = cell(1,n);
      prprogress([],'Checking %5i files: \n',n);
      prprogress([],'%5i\n',0);
			if n > 1
				s = sprintf('Checking %5i files: ',n);
				prwaitbar(n,s);
			end
			for j=1:n               % find the cells in each file
       	prprogress([],'%5i\n',j);
				if n > 1, prwaitbar(n,j,[s int2str(j)]); end
				fname = fullfile(a.rootpath,files{j});
        ss = load(fname);
				f = fieldnames(ss);
				b = ss.(f{1});
        if iscell(b)
          ncells = prod(size(b));
				  findex = [repmat(j,ncells,1) [1:ncells]'];
				  dirsizes{j} = findex;
        else
          error('Mat-file with just a cell variable expected')
				end
			end
			file_index = vertcat(dirsizes{:}); % create file_index
                                     % column 1: index in files 
                                     % column 2: index in cells
																		 
      a.prdataset = setident(a.prdataset,[1:size(file_index,1)]','ident'); % obj number
		  a.prdataset = setident(a.prdataset,file_index,'file_index');    % file_index
			a.files = files;
			
		elseif strcmp(a.type,'half-baked') || strcmp(a.type,'pre-cooked') 
			% create datafile from datasets stored as mat-files, 
			% or files read as datasets
			if strcmp(a.type,'half-baked')
				files = dir([a.rootpath '/*.mat']);
				files = {files(:).name};
				if isempty(files)
					error(['No mat-files found in ' a.rootpath])
				end
				ss = load(fullfile(a.rootpath,files{1}));
				f = fieldnames(ss);
				d = ss.(f{1});
				n = length(files); %DXD using length here is a good idea
			else % pre-cooked
				files = dirlist(a.rootpath);
				if isempty(files)
					error(['No files found in ''' dirs ''''])
				end
				[cmd,pars] = getpreproc(a,1);
				d = feval(cmd,deblank(files(1,:)),pars{:});
				n = size(files,1); %DXD using length here is a bad idea
			end
			if ~isdataset(d)
				error('datasets expected and not found in file')
			end
			identfields = fieldnames(getident(d,''));
			filenames = [];
			nlab = [];
			prprogress([],'Checking %5i  mat-files: \n',n);
			prprogress([],'%5i\n',0);
			if n > 1
				s = sprintf('Checking %5i  mat-files: ',n);
				prwaitbar(n,s);
			end
			objsize = zeros(1,n);
			ident = [];
			for j=1:n
				if strcmp(a.type,'half-baked')
					fname = fullfile(a.rootpath,files{j});
					ss = load(fname);
					f = fieldnames(ss);
					b = ss.(f{1});
				else
					fname = files(j,:);
					b = feval(cmd,deblank(files(j,:)),pars{:});
				end
				if ~isequal(b.lablist,d.lablist)		
					b.lablist
					d.lablist
					error('lablist fields of datasets should be identical')
				end
				if ~isequal(b.labtype,d.labtype)
					error('labtype fields of datasets should be identical')
				end
				if ~isequal(b.featlab,d.featlab)
					error('featlab fields of datasets should be identical')
				end
				if ~isequal(b.featdom,d.featdom)
					error('featdom fields of datasets should be identical')
				end
				if ~isequal(b.prior,d.prior)
					error('prior fields of datasets should be identical')
				end
				if ~isequal(b.cost,d.cost)
					error('cost fields of datasets should be identical')
				end
				if ~isequal(b.featsize,d.featsize)
					error('featsize fields of datasets should be identical')
				end
				if isstruct(b.ident) && ~isequal(fieldnames(b.ident),fieldnames(d.ident))
					error('ident fields of datasets should have same fields')
				end
				objsize(j) = size(b,1);
				prprogress([],'%5i\n',j);
				if n > 1, prwaitbar(n,j,[s int2str(j)]); end
				nlab = [nlab; b.nlab];
				filenames = strvcat(filenames,fname);
				b = setident(b);
				bident = b.ident;
				if isempty(ident)
					ident = bident;
				else
					for i=1:length(identfields)
						f  = ident.(identfields{i});
						fb = bident.(identfields{i});
						if size(f,2) ~= size(fb,2) && ischar(f)
							n = size(f,2) - size(fb,2);
							if n > 0
								fb = [fb repmat(' ',size(fb,1),n)];
							else
								f = [f repmat(' ',size(f,1),-n)];
							end
						end
						ident.(identfields{i}) = [f; fb];
					end
				end
			end
			a.files = files;
			d.data = [];
			d.targets = [];
			d.objsize = sum(objsize);
			d.nlab = nlab;
			file_index = zeros(d.objsize,2);
			next = 1;
			for j=1:n
				findexj = [repmat(j,objsize(j),1) [1:objsize(j)]'];
				file_index(next:next+objsize(j)-1,:) = findexj;
				next = next+objsize(j);
			end
			
			d = setident(d,ident,'');
			d = setident(d,file_index,'file_index');
			a.prdataset = d;
						
		else
			
      error('SETFILES should not be called for mature datafiles');
      % this is handled by SAVEDATAFILE during creation of the datafile
      
    end
		
		if n > 1, prwaitbar(0); end

	end
   
return
		
function filenames = dirlist(dirpath)

% directory name and path from root
		[rootpath,name,ext] = fileparts(dirpath);
		dirname = [name ext];

    ddir = dir(deblank(dirpath));
    if isempty(ddir)
      filenames = [];
      return
    end
		names = char(ddir.name);
	% remove all .-files / dirs
		J = names(:,1) == '.';
		names(J,:) = [];
		J = strmatch('Thumbs.db',names,'exact');
		names(J,:) = []; % get rid of Windows Thumb files
	% we now have all filenames and dirnames in dirpath
	% find out whether they are proper
	% and what are the files and what the directories
    ftype = zeros(size(names,1),1);
    for j=1:size(names,1)
      ftype(j) = exist(fullfile(rootpath,dirname,deblank(names(j,:))));
    end
		J = find(ftype == 2);
		filenames = [];
		if ~isempty(J)
			for j=1:length(J)
    		filenames = strvcat(filenames,fullfile(rootpath,dirname,names(J(j),:)));
			end
		end
		

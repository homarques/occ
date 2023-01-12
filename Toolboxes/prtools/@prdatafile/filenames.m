%FILENAMES Get filenames of datafile
%
%   [NAMES,DIRS,ROOT] = FILENAMES(A)
%   FULLNAMES = FILENAMES(A,'full')
%
% INPUT
%   A         DATAFILE
%
% OUTPUT
%   NAMES     Names of the files in which the objects of A are stored.
%   DIRS      Names of the directories in which the objects of A are
%             stored.   
%   ROOT      Rootdirectory of the datafile
%   FULLNAMES Full names, including path.
%
% DESCRIPTION
% This routine facilitates the retrieval of the files where the objects of
% A are stored. Note that this is mainly usefull for datafiles of the type
% 'raw', as otherwise multiple objects may be stored in the same file.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATAFILES

function [names,dirs,root] = filenames(a,full)

  if nargin < 2, full = []; end
	if isempty(a.rootpath)
			root = pwd;
		else
			root = a.rootpath;
	end

	m = size(a,1);
	findex = getident(a,'file_index');
  type = gettype(a);
	names = cell(1,m);
	dirs  = cell(1,m);
	
	for j=1:m
		names{j} = a.files{2}{findex(j,1)}(findex(j,2),:);
		dirs{j}  = a.files{1}{findex(j,1)};
	end
  
  if ~isempty(full) && ischar(full) && strcmp(full,'full')
    nams = cell(1,m);
    for j=1:m
      nams{j} = fullfile(fullfile(root,dirs{j}),names{j});
    end
    names = nams;
  end
  
	names= char(names);
	dirs = char(dirs);
    
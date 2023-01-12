%SETMAPPING_FILE Set filename of routine that defines or executes a mapping
%
%    W = SETMAPPING_FILE(W,MAPPING_FILE)

% $Id: setmapping_file.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setmapping_file(w,mapping_file)
		
if ~ischar(mapping_file)
	error('Name of executing m-file not found')
end
if ~exist(mapping_file)
	error([mapping_file ' not found in the search path'])
end

w.mapping_file = mapping_file;
return

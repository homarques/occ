%GETMAPPING_FILE Get mapping_file field in mapping
%
%    MAPPING_FILE = GETMAPPING_FILE(W)
%
% MAPPING_FILE is the file that will execute the mapping in a call
% as A*W or PRMAP(A,W).

% $Id: getmapping_file.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function mapping_file = getmapping_file(w)

		
mapping_file = w.mapping_file;
return

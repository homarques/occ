%ISTYPE Check datafile type
%
%   I = ISTYPE(A,TYPE)

function n = istype(a,type)

		
	n = strcmp(a.type,type);


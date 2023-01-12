%FIND Find nonzero elements in dataset

% $Id: find.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function [i,j,v] = find(a)
		if nargout <= 1
	i = find(a.data);
elseif nargout == 2
	[i,j] = find(a.data);
else
	[i,j,v] = find(a.data);
end
return

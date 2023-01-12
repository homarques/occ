%SUM Dataset overload

% $Id: sum.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function s = sum(a,dim)
	
	
	if nargin == 1
		s = sum(a.data);
	else
		s = sum(a.data,dim);
	end

	return

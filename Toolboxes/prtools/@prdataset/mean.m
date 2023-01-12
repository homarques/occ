%MEAN Dataset overload

% $Id: mean.m,v 1.1 2007/03/22 07:45:54 duin Exp $

function s = mean(a,dim)
	
	
	if nargin == 1
		s = mean(a.data);
	else
		s = mean(a.data,dim);
	end

	return

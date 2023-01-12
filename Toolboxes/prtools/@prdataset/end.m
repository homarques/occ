%END Dataset overload

% $Id: end.m,v 1.4 2007/04/05 06:28:11 davidt Exp $

function m = end(a,k,n);

		
	if n == 1
		m = length(a.data(:));
	elseif n == 2
		m = size(a.data,k);
	else
		error('Dataset should be 2-dimensional')
	end

	return

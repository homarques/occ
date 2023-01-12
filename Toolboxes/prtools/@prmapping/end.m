%END Mapping overload

% $Id: end.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function m = end(w,k,n)

		
	if n ~= 2
		error('Mappings have two dimensions')
	else
		m = size(w,k);
	end

	return

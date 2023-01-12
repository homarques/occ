%PROD Product of elements. Dataset overload

% $Id: prod.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function s = prod(a,dim)
		if nargin == 1
	s = prod(a.data);
else
	s = prod(a.data,dim);
end
return

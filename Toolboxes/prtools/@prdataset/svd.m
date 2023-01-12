%SVD Dataset overload

% $Id: svd.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function [u,s,v] = svd(a,n)

			
	nodatafile(a);

	if (nargin == 2)
		[u,s,v] = svd(a.data,n);
	else
		if (nargout == 1)
			u = svd(a.data);
		else
			[u,s,v] = svd(a.data);
		end
	end

return

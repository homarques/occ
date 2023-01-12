%GETSIZE Return size of a mapping
%
%   SIZE = GETSIZE(W)
%
% This function is identical to SIZE(W).

% $Id: getsize.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function [s1,s2] = getsize(w,dim)

	s = [prod(w.size_in) prod(w.size_out)];
	if (nargin == 2)
		s = s(dim);
	end
	if (nargout < 2)
		s1 = s;
	else
		s1 = s(1); s2 = s(2);
	end

return

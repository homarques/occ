
%MTIMES Mapping overload
%
%  D = MTIMES(A,W)
%  D = A*W
%
% These calls are identical to D = PRMAP(A,W).

% $Id: mtimes.m,v 1.3 2007/03/22 07:43:42 duin Exp $

function [d,varargout] = mtimes(a,b)

	if (nargout == 1)
		d = prmap(a,b);
  elseif (nargout > 1)
    varargout = repmat({[]},[1, nargout-1]);
		[d,varargout{:}] = prmap(a,b);
	else
		prmap(a,b)
	end

return

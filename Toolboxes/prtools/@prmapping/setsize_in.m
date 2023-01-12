%SETSIZE_IN Set size_in field (input dimensionality) in mapping
%
%    W = SETSIZE_IN(W,SIZE_IN)

% $Id: setsize_in.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setsize_in(w,size_in)
			if min(size(size_in)) > 1
		error('Input dimensionality should be given as scalar or row vector')
	end
	if min(size_in) < 0
		error('Input dimensionality should be >= 0')
	end
	w.size_in = size_in;
return

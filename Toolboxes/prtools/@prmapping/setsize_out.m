%SETSIZE_OUT Set size_out field (output dimensionality) in mapping
%
%    W = SETSIZE_OUT(W,SIZE_OUT)

% $Id: setsize_out.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setsize_out(w,size_out)

		
	if min(size(size_out)) > 1
		error('Output dimensionality should be given as scalar or row vector')
	end
	if min(size_out) < 0
		error('Output dimensionality should be >= 0')
	end
	w.size_out = size_out;

	return

%SETSIZE Set size_in as well as size_out field in mapping
%
%    W = SETSIZE(W,SIZE)
%
% Sets SIZE_IN = SIZE(1) and SIZE_OUT = SIZE(2), assuming both are
% scalars. If not, use SETSIZE_IN and SETSIZE_OUT

% $Id: setsize.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setsize(w,size)

		
	if length(size) ~= 2
		error('Size vector should have two components')
	end
	w = setsize_in(w,size(1));
	w = setsize_out(w,size(2));

	return

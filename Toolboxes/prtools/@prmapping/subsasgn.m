%SUBSASGN Subscript assignment overload for mappings
%
% This routine enables constructs like W.DATA = {DATA1, DATA2},
% i.e. the direct change of mapping fields.

% $Id: subsasgn.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = subsasgn(w,s,v)
		if strcmp(s(1).type,'.')
	w = set(w,s(1).subs,v);
else
	error('Operation undefined')
end
return

		


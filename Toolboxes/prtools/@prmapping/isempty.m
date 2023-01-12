%ISEMPTY Test on empty ammping
%
%    I = ISEMPTY(W)
%
% True if the mapping W is empty

% $Id: isempty.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function i = isempty(s)
			i = isempty(s.mapping_file);
return

%ISCOMBINER Test whether the argument is a combiner mapping
%
%   OK = ISCOMBINER(W)
%   ISCOMBINER(W)
%
% INPUT
%   W   Mapping
%
% OUTPUT
%   OK  1/0 indicating if the mapping type of W is COMBINER 
%
% DESCRIPTION
% If called without an output argument, ISCOMBINER generates an error
% if the mapping type of W is not a COMBINER.
%
% See HELP MAPPINGS for an explanation of 'COMBINER'.

% $Id: iscombiner.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function ok = iscombiner(w)

	ok = strcmp(w.mapping_type,'combiner');
	if (nargout == 0) && (~ok)
		error([prnewline 'Combiner mapping expected.'])
	end

return;
